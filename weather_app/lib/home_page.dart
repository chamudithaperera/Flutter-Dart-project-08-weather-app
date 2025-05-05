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
        return const Color(0xFF1E88E5); // Bright ocean blue
      case 'clouds':
        return const Color(0xFF1976D2); // Medium ocean blue
      case 'rain':
        return const Color(0xFF1565C0); // Deep ocean blue
      case 'snow':
        return const Color(0xFF0D47A1); // Dark ocean blue
      case 'thunderstorm':
        return const Color(0xFF0D47A1); // Dark ocean blue
      case 'drizzle':
        return const Color(0xFF1565C0); // Deep ocean blue
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return const Color(0xFF1976D2); // Medium ocean blue
      default:
        return const Color(0xFF1E88E5); // Bright ocean blue
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E88E5).withOpacity(0.8),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFF1E88E5), const Color(0xFF1565C0)],
            ),
          ),
        ),
        title:
            _isSearching
                ? Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search location...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
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
                  ),
                )
                : const Text(
                  'Weather App',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
        actions: [
          if (!_isSearching)
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.search, size: 24, color: Colors.white),
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
      body: Stack(
        children: [
          // Main content
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF1E88E5), const Color(0xFF1565C0)],
              ),
            ),
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                    : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            margin: const EdgeInsets.only(top: 110, bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Location and Time
                                Text(
                                  _locationName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _weather != null && _weather!.date != null
                                      ? DateFormat(
                                        'EEEE, h a',
                                      ).format(_weather!.date!.toLocal())
                                      : '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Weather Icon, Temp, Desc
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getWeatherIcon(_weather?.weatherMain),
                                      size: 64,
                                      color: Colors.amber[600],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: Text(
                                    _weather != null &&
                                            _weather!.temperature != null
                                        ? '${_weather!.temperature!.celsius!.round()}°'
                                        : '--',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    _weather?.weatherDescription ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Today Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Today',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildTodayInfo(
                                      'Pressure',
                                      _weather?.pressure != null
                                          ? '${_weather!.pressure}mb'
                                          : '--',
                                    ),
                                    _buildTodayInfo(
                                      'Humidity',
                                      _weather?.humidity != null
                                          ? '${_weather!.humidity}%'
                                          : '--',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Hourly Forecast
                                _hourlyForecast.isNotEmpty
                                    ? SizedBox(
                                      height: 80,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _hourlyForecast.length,
                                        itemBuilder: (context, index) {
                                          final weather =
                                              _hourlyForecast[index];
                                          final time = DateFormat(
                                            'HH:00',
                                          ).format(weather.date!);
                                          return Container(
                                            width: 60,
                                            margin: const EdgeInsets.only(
                                              right: 12,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  time,
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Icon(
                                                  _getWeatherIcon(
                                                    weather.weatherMain,
                                                  ),
                                                  color: Colors.amber[600],
                                                  size: 24,
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  weather.temperature != null
                                                      ? '${weather.temperature!.celsius!.round()}°'
                                                      : '--',
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                          // More Weather Details Card
                          if (_weather != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'More Details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildTodayInfo(
                                        'Wind',
                                        _weather!.windSpeed != null
                                            ? '${_weather!.windSpeed} m/s'
                                            : '--',
                                      ),
                                      _buildTodayInfo(
                                        'Wind Dir',
                                        _weather!.windDegree != null
                                            ? '${_weather!.windDegree}°'
                                            : '--',
                                      ),
                                      _buildTodayInfo(
                                        'Feels Like',
                                        _weather!.tempFeelsLike?.celsius != null
                                            ? '${_weather!.tempFeelsLike!.celsius!.round()}°'
                                            : '--',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildTodayInfo(
                                        'Min Temp',
                                        _weather!.tempMin?.celsius != null
                                            ? '${_weather!.tempMin!.celsius!.round()}°'
                                            : '--',
                                      ),
                                      _buildTodayInfo(
                                        'Max Temp',
                                        _weather!.tempMax?.celsius != null
                                            ? '${_weather!.tempMax!.celsius!.round()}°'
                                            : '--',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildTodayInfo(
                                        'Sunrise',
                                        _weather!.sunrise != null
                                            ? DateFormat('h:mm a').format(
                                              _weather!.sunrise!.toLocal(),
                                            )
                                            : '--',
                                      ),
                                      _buildTodayInfo(
                                        'Sunset',
                                        _weather!.sunset != null
                                            ? DateFormat('h:mm a').format(
                                              _weather!.sunset!.toLocal(),
                                            )
                                            : '--',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
          ),
          // Search overlay
          if (_isSearching)
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Search location...',
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear, color: Colors.black),
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
                    ),
                  ),
                  Expanded(
                    child:
                        _isSearchingSuggestions && _searchSuggestions.isNotEmpty
                            ? ListView.builder(
                              itemCount: _searchSuggestions.length,
                              itemBuilder: (context, index) {
                                final location = _searchSuggestions[index];
                                final state =
                                    location['state'] != null
                                        ? ', ${location['state']}'
                                        : '';
                                return ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  title: Text(
                                    '${location['name']}$state',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    location['country'],
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                  ),
                                  onTap: () => _searchLocation(location),
                                );
                              },
                            )
                            : _searchController.text.isNotEmpty
                            ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No locations found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                            : const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Start typing to search locations',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTodayInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 13),
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
