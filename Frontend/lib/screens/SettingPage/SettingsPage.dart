import 'package:flutter/material.dart';
import 'package:serendib_trails/screens/SettingPage/SendFeedback.dart';


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0B5739),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Settings",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text("App language"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to the App Language settings page
              //Navigator.push(
              //context,
              //MaterialPageRoute(builder: (context) => LanguageSettingsPage()),
              //);
            },
          ),
          ListTile(
            title: Text("Notification"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to the Notification settings page
              //Navigator.push(
              //context,
              // MaterialPageRoute(builder: (context) => NotificationSettingsPage()),
              // );
            },
          ),
          ListTile(
            title: Text("Update version"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to the Update Version page
              // Navigator.push(
              // context,
              //  MaterialPageRoute(builder: (context) => UpdateVersionPage()),
              //);
            },
          ),
          ListTile(
            title: Text("Send Feedback"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              //Navigate to the Update Version page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SendFeedbackPage()),
              );
            },
          ),
        ],
      ),
      
    );
  }
}
