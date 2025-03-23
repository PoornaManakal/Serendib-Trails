import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weatherapp/models/weather_data_model.dart';

class Datasource {
  String appId = "e09bae7fd85e852eb5a30abf6db03fbe";

  Future<WeatherDataModel?> getWeatherData(String cityName) async {
    if (cityName.trim().isEmpty) {
      print("Error: City name is empty");
      return null;
    }

    final String url =
        "https://api.openweathermap.org/data/2.5/weather?q=$cityName&units=metric&appid=$appId";

    try {
      final response = await http.get(Uri.parse(url));
      final Map<String, dynamic> json = jsonDecode(response.body);

      if (json["cod"] == 200) {
        return WeatherDataModel.fromJson(json);
      } else {
        print("API Error: ${json["message"]}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  Future<WeatherDataModel?> getWeatherDataByCoords(double lat, double lon) async {
    final String url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$appId";

    try {
      final response = await http.get(Uri.parse(url));
      final Map<String, dynamic> json = jsonDecode(response.body);

      if (json["cod"] == 200) {
        return WeatherDataModel.fromJson(json);
      } else {
        print("API Error: ${json["message"]}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }
}
