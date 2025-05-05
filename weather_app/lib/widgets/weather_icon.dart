import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String? weatherMain;
  final double size;
  final Color color;

  const WeatherIcon({
    super.key,
    required this.weatherMain,
    this.size = 64,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(_getWeatherIcon(weatherMain), size: size, color: color);
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
