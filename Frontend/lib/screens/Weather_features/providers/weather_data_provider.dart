import 'package:flutter/material.dart';
import 'package:weatherapp/dataSource.dart';
import 'package:weatherapp/models/weather_data_model.dart';

class WeatherDataProvider extends ChangeNotifier {
  WeatherDataModel? _weatherDataModel;

  WeatherDataModel? get weatherInfo => _weatherDataModel;

  Future<void> fetchData(String cityName) async {
    _weatherDataModel = await Datasource().getWeatherData(cityName);
    notifyListeners();
  }
}
 