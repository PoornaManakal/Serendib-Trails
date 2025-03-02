import 'package:flutter/material.dart';

import 'arview_for_3d_objects.dart';


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

                //Image with texts
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

                const SizedBox(height : 19,),

                Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 9,
                      mainAxisSpacing: 9,
                      children : model3dlist.map((each3dItem)
                        {
                          return Card(
                            elevation: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(19),
                                image: DecorationImage(
                                  image: NetworkImage(each3dItem["photoUrl"]),
                                  fit: BoxFit.cover,
                                ),
                              ),

                              child : Transform.translate(
                                  offset: const Offset(0, 60),
                                  child: Padding(
                                    padding: const EdgeInsets.all(9),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [

                                        SizedBox(
                                          width: 55,
                                          child: Center(
                                            child: ElevatedButton(
                                              onPressed: ()
                                              {
                                                Navigator.push(context, MaterialPageRoute(builder: (c)=> ArviewFor3dObjects(
                                                    name: each3dItem["name"],
                                                    model3durl: each3dItem["model3dUrl"]
                                                )));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.all(0),
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(17),
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.phone_android_sharp,
                                                color: Colors.black,
                                              ),
                        ),
                                        ),
                        ),
                                      ],
                          )
                                  )
                              ),
                            ),
                          );
                        }).toList(),
                    )
                )],
            ),
          )
    ),
    );
  }
}
