import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>(); // key for  form validation
  final TextEditingController _emailController = TextEditingController();

  
  bool _isLoading = false;

  Future<void> _Reset() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password Reset Email Sent'),
            backgroundColor: Colors.green,
          ),
        );
        _emailController.clear();
        await Future.delayed(const Duration(milliseconds: 1000));

        Navigator.pushReplacementNamed(context, '/signin');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password Reset Failed'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, 
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),

              // Header Text
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "Password Reset ?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B5739),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Align(
                alignment: Alignment.topLeft, // align to the top left corner
                child: Padding(
                  padding: EdgeInsets.all(20), // add padding around the text
                  child: Text(
                    "Enter your Email and we will send you a link to reset your password.",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Email Input Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    filled: true,
                    fillColor:
                        Colors.white12, // Keeps the semi-transparent background
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Colors.black87, width: 1.5), // Default border
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Colors.black87,
                          width: 1.5), // Unfocused border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF0B5739),
                          width: 2.0), // Focused border color
                    ),
                  ),
                  style: const TextStyle(
                      color: Color(0xFF0B5739)), // Text color when typing
                  cursorColor: Color(0xFF0B5739), // Cursor color when typing
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
                        .hasMatch(value)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              const SizedBox(height: 20),

              _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF0B5739)), // Change color
                    )
                  :

                  // email send Button
                  Container(
                      width: 300,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color(0xFF0B5739),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextButton(
                        onPressed: () {
                          _Reset();
                        },
                        child: const Text(
                          'Send Email',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
