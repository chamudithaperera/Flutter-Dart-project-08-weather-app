import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather/weather.dart';
import 'consts.dart';

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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.search, size: 30, color: Colors.black),
              onPressed: () {
                // TODO: Implement search functionality
                print('Search icon pressed');
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _locationName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
