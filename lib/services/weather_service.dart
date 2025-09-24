import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenWeatherService {
  static const String _apiKey = '3b79d90246a89add1c375b9c21303e9d';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const String _geoUrl = 'http://api.openweathermap.org/geo/1.0/direct'; // Geocoding API

  /// 🌍 Convert City to Latitude & Longitude
  Future<Map<String, double>?> getCoordinates(String city) async {
    try {
      final url = Uri.parse('$_geoUrl?q=$city&limit=1&appid=$_apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          return {
            "lat": data[0]["lat"],
            "lon": data[0]["lon"]
          };
        } else {
          throw Exception("No data found for the city.");
        }
      } else {
        throw Exception("Failed to fetch coordinates.");
      }
    } catch (e) {
      print("Error fetching coordinates: $e");
      return null;
    }
  }

  /// 🌦️ Fetch Weather Data Using Latitude & Longitude
  Future<Map<String, dynamic>?> fetchWeather(double lat, double lon) async {
    try {
      final url = Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "temperature": data['main']['temp'],
          "condition": data['weather'][0]['description'],
        };
      } else {
        throw Exception("Failed to fetch weather data.");
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }
}
