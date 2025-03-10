import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Serendib Trails",
          style: TextStyle(
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(21),
            child: Column(
              children: [

                Container(
                  width: double.infinity,
                  height: 253,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(19),
                    image:  const DecorationImage(
                         image: NetworkImage("https://www.remotelands.com/storage/media/600/conversions/b130130005-banner-size.jpg"),
                         fit: BoxFit.cover,
                    )
                  ),
            ),
              ],
            ),
          )
    ),
    );
  }
}
