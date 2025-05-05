import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather/weather.dart';
import 'consts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _locationName = 'Getting location...';
  bool _isLoading = true;
  Weather? _weather;
  final WeatherFactory _wf = WeatherFactory(OPEN_WEATHER_API_KEY);
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchSuggestions = [];
  bool _isSearchingSuggestions = false;

  // List of major cities
  final List<String> _cities = [
    'New York, US',
    'London, UK',
    'Tokyo, Japan',
    'Paris, France',
    'Sydney, Australia',
    'Berlin, Germany',
    'Moscow, Russia',
    'Dubai, UAE',
    'Singapore',
    'Hong Kong',
    'Amsterdam, Netherlands',
    'Rome, Italy',
    'Bangkok, Thailand',
    'Istanbul, Turkey',
    'Seoul, South Korea',
    'Barcelona, Spain',
    'Vienna, Austria',
    'Athens, Greece',
    'Cairo, Egypt',
    'Mumbai, India',
    'Beijing, China',
    'Toronto, Canada',
    'Mexico City, Mexico',
    'São Paulo, Brazil',
    'Buenos Aires, Argentina',
    'Cape Town, South Africa',
    'Auckland, New Zealand',
    'Oslo, Norway',
    'Stockholm, Sweden',
    'Helsinki, Finland',
    'Warsaw, Poland',
    'Prague, Czech Republic',
    'Budapest, Hungary',
    'Lisbon, Portugal',
    'Dublin, Ireland',
    'Brussels, Belgium',
    'Copenhagen, Denmark',
    'Zurich, Switzerland',
    'Vienna, Austria',
    'Madrid, Spain',
    'Milan, Italy',
    'Munich, Germany',
    'Frankfurt, Germany',
    'Hamburg, Germany',
    'Manchester, UK',
    'Birmingham, UK',
    'Glasgow, UK',
    'Edinburgh, UK',
    'Liverpool, UK',
    'Bristol, UK',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocationSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchSuggestions = [];
        _isSearchingSuggestions = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$OPEN_WEATHER_API_KEY',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _searchSuggestions =
              data
                  .map(
                    (item) => {
                      'name': item['name'],
                      'country': item['country'],
                      'state': item['state'],
                      'lat': item['lat'],
                      'lon': item['lon'],
                    },
                  )
                  .toList();
          _isSearchingSuggestions = true;
        });
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      setState(() {
        _searchSuggestions = [];
        _isSearchingSuggestions = false;
      });
    }
  }

  void _onSearchChanged() {
    _fetchLocationSuggestions(_searchController.text);
  }

  Future<void> _getCurrentLocation() async {
    try {
      var status = await Permission.location.request();

      if (status.isDenied) {
        setState(() {
          _locationName = 'Location permission denied';
          _isLoading = false;
        });
        return;
      }

      if (status.isPermanentlyDenied) {
        setState(() {
          _locationName = 'Location permission permanently denied';
          _isLoading = false;
        });
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Location Permission Required'),
                  content: const Text(
                    'Please enable location permission in app settings to continue.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        openAppSettings();
                        Navigator.pop(context);
                      },
                      child: const Text('Open Settings'),
                    ),
                  ],
                ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get weather data
      Weather weather = await _wf.currentWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _weather = weather;
        _locationName = weather.areaName ?? 'Unknown Location';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationName = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchLocation(Map<String, dynamic> location) async {
    setState(() {
      _isLoading = true;
      _isSearching = false;
      _searchSuggestions = [];
    });

    try {
      Weather weather = await _wf.currentWeatherByLocation(
        location['lat'],
        location['lon'],
      );
      setState(() {
        _weather = weather;
        _locationName = '${location['name']}, ${location['country']}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationName = 'Location not found';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search location...',
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _isSearching = false;
                              _searchSuggestions = [];
                            });
                          },
                        ),
                      ),
                      onSubmitted: (value) {
                        if (_searchSuggestions.isNotEmpty) {
                          _searchLocation(_searchSuggestions[0]);
                        }
                      },
                      autofocus: true,
                    ),
                    if (_isSearchingSuggestions &&
                        _searchSuggestions.isNotEmpty)
                      Container(
                        color: Colors.white,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _searchSuggestions.length,
                          itemBuilder: (context, index) {
                            final location = _searchSuggestions[index];
                            final state =
                                location['state'] != null
                                    ? ', ${location['state']}'
                                    : '';
                            return ListTile(
                              title: Text(
                                '${location['name']}$state, ${location['country']}',
                              ),
                              onTap: () => _searchLocation(location),
                            );
                          },
                        ),
                      ),
                  ],
                )
                : const Text('Weather App'),
        actions: [
          if (!_isSearching)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(Icons.search, size: 30, color: Colors.black),
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
                tooltip: 'Search',
              ),
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _getCurrentLocation,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height:
                        MediaQuery.of(context).size.height -
                        AppBar().preferredSize.height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.blue.shade300, Colors.blue.shade500],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Location
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _locationName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Weather Icon
                        if (_weather != null)
                          Icon(
                            _getWeatherIcon(_weather!.weatherMain),
                            size: 100,
                            color: Colors.white,
                          ),
                        const SizedBox(height: 20),

                        // Temperature
                        if (_weather != null)
                          Text(
                            '${_weather!.temperature?.celsius?.round()}°C',
                            style: const TextStyle(
                              fontSize: 72,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                        // Weather Description
                        if (_weather != null)
                          Text(
                            _weather!.weatherDescription ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),

                        const SizedBox(height: 40),

                        // Additional Weather Info
                        if (_weather != null)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildWeatherInfo(
                                  Icons.water_drop,
                                  '${_weather!.humidity}%',
                                  'Humidity',
                                ),
                                _buildWeatherInfo(
                                  Icons.air,
                                  '${_weather!.windSpeed} m/s',
                                  'Wind',
                                ),
                                _buildWeatherInfo(
                                  Icons.thermostat,
                                  '${_weather!.tempMax?.celsius?.round()}°',
                                  'Max',
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildWeatherInfo(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(String? weatherMain) {
    switch (weatherMain?.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.grain;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'drizzle':
        return Icons.grain;
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return Icons.cloud;
      default:
        return Icons.wb_sunny;
    }
  }
}
