import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
              textAlign: TextAlign.center,
            ),)
            const Sizedbox(height:20),



            Expanded(child: ListView(
              padding: const EdgeInsets.symmetric(horizontal:20),
              children: [
                landmarkButton(
                  context,
                  imagePath:'lib/temple_tooth.jpeg'
                  title:"Temple of Tooth",
                  Description:
                  "The Temple of the Tooth Relic in Kandy, Sri Lanka, is a sacred Buddhist temple..."

                ),
                landmarkButton(
                  context,
                  imagePath:'lib/ldambulla_temple.jpg'
                  title:"Dambulla Cave Temple",
                  Description:"Dambulla Cave Temple is a UNESCO World Heritage Site featuring intricate murals...",


                ),
                
              ],
            ))










          ],  
        ),
      )
    )
  )
}


}
