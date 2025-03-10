import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/home.dart';
import 'package:weatherapp/providers/weather_data_provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => WeatherDataProvider(), 
    child:const MyApp(),
  ));
}

class MyApp extends StatelessWidget { 
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home:const Home()
    );
  }
}
