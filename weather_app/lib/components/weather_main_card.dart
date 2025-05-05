import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import '../widgets/weather_icon.dart';

class WeatherMainCard extends StatelessWidget {
  final String locationName;
  final Weather? weather;
  final DateTime? date;

  const WeatherMainCard({
    super.key,
    required this.locationName,
    required this.weather,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            locationName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date != null ? DateFormat('EEEE, h a').format(date!.toLocal()) : '',
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          // Weather Icon, Temp, Desc
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [WeatherIcon(weatherMain: weather?.weatherMain)],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              weather != null && weather!.temperature != null
                  ? '${weather!.temperature!.celsius!.round()}°'
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
              weather?.weatherDescription ?? '',
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
