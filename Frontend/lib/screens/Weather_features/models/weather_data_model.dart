class WeatherDataModel {
  final String cityName;
  final double currentTemp;
  final double feelsLike;
  final double windSpeed;
  final int humidity;
  final int clouds;
  final int pressure; 
  final String icon;

  WeatherDataModel({
    required this.cityName,
    required this.currentTemp,
    required this.feelsLike,
    required this.windSpeed,
    required this.humidity,
    required this.clouds,
    required this.pressure,

    required this.icon,
  });

  factory WeatherDataModel.fromJson(Map<String, dynamic> map) {
    return WeatherDataModel(
      cityName: map["name"] ?? "Unknown City",
      currentTemp: (map["main"]["temp"] ?? 0.0).toDouble(),
      feelsLike: (map["main"]["feels_like"] ?? 0.0).toDouble(),
      windSpeed: (map["wind"]["speed"] ?? 0.0).toDouble(),
      humidity: (map["main"]["humidity"] ?? 0).toInt(),
      clouds: (map["clouds"]["all"] ?? 0).toInt(),
      pressure: (map["main"]["pressure"] ?? 0).toInt(),

      icon: "https://openweathermap.org/img/wn/${map["weather"][0]["icon"]}@2x.png",
    );
  }
}
