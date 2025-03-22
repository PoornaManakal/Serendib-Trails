import 'package:flutter/material.dart';

void main(){
  runApp(AugmentedReality());
}

class AugmentedReality extends StatelessWidget{
  const AugmentedReality({super.key});

@override
Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Colors.white,
      body:SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           const SizedBox(height:30),
           const Text(
            "Historical Landmarks",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: Center,
           ),
           const SizedBox(height: 10),
           const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Explore the rich history of famous landmarks and discover their over time.",
              style: TextStyle(
                fontSize: 16
                color: Colors.black
              ),
              textAlign: Center,
            ),)
          ],  
        ),
      )
    )
  )
}


}
