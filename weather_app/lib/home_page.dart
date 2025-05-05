import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather/weather.dart';
import 'consts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _locationName = 'Getting location...';
  bool _isLoading = true;
  Weather? _weather;
  List<Weather> _hourlyForecast = [];
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

  Future<void> _fetchHourlyForecast(double lat, double lon) async {
    try {
      List<Weather> forecast = await _wf.fiveDayForecastByLocation(lat, lon);

      // Sort and filter the forecast for next 24 hours
      final now = DateTime.now();
      final next24Hours = now.add(const Duration(hours: 24));

      setState(() {
        _hourlyForecast =
            forecast
                .where(
                  (weather) =>
                      weather.date!.isAfter(now) &&
                      weather.date!.isBefore(next24Hours),
                )
                .toList()
              ..sort((a, b) => a.date!.compareTo(b.date!));
      });
    } catch (e) {
      print('Error fetching hourly forecast: $e');
    }
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

      // Get hourly forecast
      await _fetchHourlyForecast(position.latitude, position.longitude);

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

      // Get hourly forecast for searched location
      await _fetchHourlyForecast(location['lat'], location['lon']);

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

  Color _getWeatherColor(String? weatherMain) {
    switch (weatherMain?.toLowerCase()) {
      case 'clear':
        return const Color(0xFF47BFDF);
      case 'clouds':
        return const Color(0xFF54717A);
      case 'rain':
        return const Color(0xFF57575D);
      case 'snow':
        return const Color(0xFF7BE495);
      case 'thunderstorm':
        return const Color(0xFF4A536B);
      case 'drizzle':
        return const Color(0xFF57575D);
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return const Color(0xFF54717A);
      default:
        return const Color(0xFF47BFDF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search location...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
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
                )
                : const Text(
                  'Weather App',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        actions: [
          if (!_isSearching)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(Icons.search, size: 30, color: Colors.white),
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
          _isSearching
              ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _getWeatherColor(_weather?.weatherMain),
                      _getWeatherColor(_weather?.weatherMain).withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    if (_isSearchingSuggestions &&
                        _searchSuggestions.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: _searchSuggestions.length,
                          itemBuilder: (context, index) {
                            final location = _searchSuggestions[index];
                            final state =
                                location['state'] != null
                                    ? ', ${location['state']}'
                                    : '';
                            return ListTile(
                              leading: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                              title: Text(
                                '${location['name']}$state',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                location['country'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              onTap: () => _searchLocation(location),
                            );
                          },
                        ),
                      )
                    else if (_searchController.text.isNotEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No locations found',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      )
                    else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Start typing to search locations',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              )
              : _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
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
                        colors: [
                          _getWeatherColor(_weather?.weatherMain),
                          _getWeatherColor(
                            _weather?.weatherMain,
                          ).withOpacity(0.8),
                        ],
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
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getWeatherIcon(_weather!.weatherMain),
                              size: 100,
                              color: Colors.white,
                            ),
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
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

                        const SizedBox(height: 20),

                        // Hourly Forecast Section
                        if (_hourlyForecast.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Hourly Forecast',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildHourlyForecast(),
                        ],
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
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
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

  Widget _buildHourlyForecast() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _hourlyForecast.length,
        itemBuilder: (context, index) {
          final weather = _hourlyForecast[index];
          final time = DateFormat('HH:00').format(weather.date!);

          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  time,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Icon(
                  _getWeatherIcon(weather.weatherMain),
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(height: 8),
                Text(
                  '${weather.temperature?.celsius?.round()}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
