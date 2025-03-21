import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:weatherapp/constants/colors.dart';
import 'package:weatherapp/providers/weather_data_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    Provider.of<WeatherDataProvider>(context, listen: false)
        .fetchCurrentLocationWeather();
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherDataProvider>(context);
    final weatherInfo = weatherProvider.weatherInfo;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [gradient1, gradient2, gradient3],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Search Bar
                SizedBox(
                  height: 50,
                  child: TextField(
                    onSubmitted: (value) {
                      weatherProvider.fetchData(value);
                    },
                    style: const TextStyle(
                      color: primaryTextColor,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      enabledBorder: _inputBorder(),
                      focusedBorder: _inputBorder(),
                      contentPadding: const EdgeInsets.only(left: 20),
                      suffixIcon: const Icon(
                        Icons.search,
                        color: Color.fromARGB(85, 255, 255, 255),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Current Location
                Text(
                  "📍 ${weatherInfo?.cityName ?? 'Loading...'}",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                // Weather Icon and Temperature
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      weatherInfo?.icon != null
                          ? Image.network(weatherInfo!.icon, height: 100, width: 100)
                          : SizedBox(height: 100, width: 100),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _richText(weatherInfo?.currentTemp, "°C", 70, 40),
                          _richText(weatherInfo?.feelsLike, "°C", 15, 15,
                              prefix: "Feels Like "),
                        ],
                      ),
                    ],
                  ),
                ),
                // Weather Details
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: secondaryBgColor,
                        border: Border.all(
                          color: const Color.fromARGB(212, 2, 43, 14),
                          width: 5,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            _weatherDetailTile(WeatherIcons.strong_wind, "Wind Speed",
                                "${weatherInfo?.windSpeed ?? 0} Km/h"),
                            _weatherDetailTile(WeatherIcons.humidity, "Humidity",
                                "${weatherInfo?.humidity ?? 0}%"),
                            _weatherDetailTile(
                                WeatherIcons.cloud, "Clouds", "${weatherInfo?.clouds ?? 0}%"),
                            _weatherDetailTile(
                                WeatherIcons.barometer, "Pressure", "${weatherInfo?.pressure ?? 0}mb"),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Input Border Style
  OutlineInputBorder _inputBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(
        color: Color.fromARGB(255, 0, 0, 0),
        width: 2,
      ),
      borderRadius: BorderRadius.all(Radius.circular(50)),
    );
  }

  // Weather Info Text
  RichText _richText(num? value, String unit, double size1, double size2,
      {String prefix = ""}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$prefix${value ?? 0}",
            style: TextStyle(
              fontSize: size1,
              color: primaryTextColor,
            ),
          ),
          TextSpan(
            text: unit,
            style: TextStyle(
              fontSize: size2,
              color: primaryTextColor,
              fontFeatures: const [FontFeature.superscripts()],
            ),
          ),
        ],
      ),
    );
  }

  // Weather Detail Tile
  ListTile _weatherDetailTile(IconData icon, String title, String value) {
    return ListTile(
      leading: BoxedIcon(icon, color: primaryTextColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, color: primaryTextColor),
      ),
      trailing: Text(
        value,
        style: const TextStyle(fontSize: 15, color: primaryTextColor),
      ),
    );
  }
}
