import 'dart:convert';
import 'package:weatherapp/models/weather_data_model.dart';
import 'package:http/http.dart' as http;

class Datasource {
  String appId = "e09bae7fd85e852eb5a30abf6db03fbe";

  Future<WeatherDataModel> getWeatherData(String cityName) async {
    final String url =
      "https://api.openweathermap.org/data/2.5/weather?q=$cityName&units=metric&appid=$appId";

    try {
      final response = await http.get(Uri.parse(url));
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json["cod"] == 200) {
        return WeatherDataModel.fromJson(json);
      } else {
        throw Exception(json["message"]);
      }
    } catch (e){
      print(e);
      throw Exception(e);
    }
  } 
}