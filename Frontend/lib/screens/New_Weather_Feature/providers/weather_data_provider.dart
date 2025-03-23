import 'package:flutter/material.dart';
import 'package:weatherapp/dataSource.dart';
import 'package:weatherapp/models/weather_data_model.dart';
import 'package:geolocator/geolocator.dart';

class WeatherDataProvider extends ChangeNotifier {
  WeatherDataModel? _weatherDataModel;

  WeatherDataModel? get weatherInfo => _weatherDataModel;

  Future<void> fetchData(String cityName) async {
    _weatherDataModel = await Datasource().getWeatherData(cityName);
    notifyListeners();
  }

  Future<void> fetchCurrentLocationWeather() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Location permissions are denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("Location permissions are permanently denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      double lat = position.latitude; 
      double lon = position.longitude;

      _weatherDataModel = await Datasource().getWeatherDataByCoords(lat, lon);
      notifyListeners();
    } catch (e) {
      print("Error fetching location: $e");
    }
  }
}
