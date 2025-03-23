import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:serendib_trails/screens/main_screen.dart'; // Import flutter_dotenv

class SendFeedbackPage extends StatefulWidget {
  @override
  _SendFeedbackPageState createState() => _SendFeedbackPageState();
}

class _SendFeedbackPageState extends State<SendFeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  Future<void> _sendFeedback() async {
    if (_formKey.currentState!.validate()) {
      // Get credentials from .env file
      final serviceId =  dotenv.env['EMAILJS_SERVICE_ID'];
      final templateId =dotenv.env['EMAILJS_TEMPLATE_ID'];
      final userId = dotenv.env['EMAILJS_USER_ID'];

      if (serviceId == null || templateId == null || userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('EmailJS credentials are missing.')),
        );
        return;
      }

      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

      final response = await http.post(
        url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'first_name': _firstNameController.text,
            'last_name': _lastNameController.text,
            'email': _emailController.text,
            'message': _messageController.text,
          },
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feedback sent successfully!'),
          backgroundColor: Colors.green,),
        );
        _firstNameController.clear();
        _lastNameController.clear();
        _emailController.clear();
        _messageController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send feedback. Please try again.'),
          backgroundColor: Colors.red,),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (route) => false,
        );
        return false;
      },
    child:Scaffold(
      appBar: AppBar(
            backgroundColor: Color(0xFF0B5739),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                  (route) => false,
                );
                
              },
            ),
            title: Text("Send Feedback",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              hintText: "First name",
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
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
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              hintText: "Last name",
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Text("Email"),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "example@email.com",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                Text("Message"),
                TextFormField(
                  controller: _messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Type your message here...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your message';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "lib/assets/images/teamlogo.png",
                          width: 40,
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
                      onPressed: _sendFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0B5739),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          Text("Send", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
    );
  }
}
