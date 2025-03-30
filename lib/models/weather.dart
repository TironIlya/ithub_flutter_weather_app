import 'dart:convert';

class Weather {
  final String city;
  final double temperature;
  final String description;

  Weather({required this.city, required this.temperature, required this.description});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['location']['name'] ?? 'Неизвестный город',
      temperature: (json['current']['temp_c'] as num).toDouble(),
      description: utf8.decode(json['current']['condition']['text'].toString().codeUnits),
    );
  }
}
