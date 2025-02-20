import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
{
  List<Map<String, dynamic>> model3dlist = [
    {
      "model3dUrl" : "https://lfgyrawtejihaevuxtvf.supabase.co/storage/v1/object/public/SL%20Tower%203D//SL%20Tower.glb",
      "photoUrl" : "https://lfgyrawtejihaevuxtvf.supabase.co/storage/v1/object/public/SL%20Tower%20IMG//SL%20Tower.png",
      "name" : "Sigiriya"
    },
  ];

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
                  child: const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom:16),
                      child: Text(
                        "Sigiriya AR View",
                        style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3
                    )
                    ),
                  ),
            ),
            ),

              ],

            ),
          )
    ),
    );
  }
}
