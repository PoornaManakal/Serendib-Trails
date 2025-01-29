import 'package:flutter/material.dart';
import 'package:serendib_trails/screens/select_interests_screen.dart';

class NewLog extends StatelessWidget {
  const NewLog({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: ResetPasswordScreen(),
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // Variables to control password visibility
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 100),
                Text(
                  "Create a new password.",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Enter a new password to reset the old one.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 40),
                TextField(
                  obscureText: _isPasswordHidden, // Control password visibility
                  decoration: InputDecoration(
                    labelText: "New password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordHidden
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordHidden =
                              !_isPasswordHidden; // Toggle visibility
                        });
                      },
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  obscureText:
                      _isConfirmPasswordHidden, // Control confirm password visibility
                  decoration: InputDecoration(
                    labelText: "Confirm new password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordHidden
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordHidden =
                              !_isConfirmPasswordHidden; // Toggle visibility
                        });
                      },
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SelectInterestsScreen()),
                      );

                      // Handle login action here
                    },
                    child: Text(
                      "Log in ",
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 10, 73, 25),
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
