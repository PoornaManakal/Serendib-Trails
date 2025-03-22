import 'package:flutter/material.dart';

class SendFeedbackPage extends StatefulWidget {
  @override
  _SendFeedbackPageState createState() => _SendFeedbackPageState();
}

class _SendFeedbackPageState extends State<SendFeedbackPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("First Name"),
                        TextField(
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                              hintText: "First name",
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)))),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Last Name"),
                        TextField(
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: "Last name",
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text("Email"),
              TextField(
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: "example@email.com",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                ),
              ),
              SizedBox(height: 15),
              Text("Message"),
              TextField(
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Type your message here...",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "lib/assets/images/teamlogo.png", // Replace with your actual image path
                        width: 40, // Adjust size as needed
                        height: 40,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Team Serendib Trails",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Implement send feedback functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("Send", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
