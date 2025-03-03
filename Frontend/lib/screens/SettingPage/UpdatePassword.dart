import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serendib_trails/screens/Login_Screens/SignIn_screen.dart';

class UpdatePasswordPage extends StatefulWidget {
  @override
  _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  int _currentIndex = 4; // Default index for settings

  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool ispasswordHidden = true;

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        String email = user!.email!;

        // Reauthenticate the user
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: _oldPasswordController.text,
        );

        await user.reauthenticateWithCredential(credential);

        // Update the password
        await user.updatePassword(_newPasswordController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password updated successfully'),
          backgroundColor: Colors.green,),
        );

        // Clear the text fields
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        await FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SigninScreen()),
          (Route<dynamic> route) => false,
        );


        
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update password'),
          backgroundColor: Colors.red,),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0B5739),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Update Password",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Old Password",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              _buildTextField("Old password", _oldPasswordController),
              SizedBox(height: 15),
              Text(
                "New Password",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              _buildTextField("New password", _newPasswordController),
              SizedBox(height: 15),
              Text(
                "Confirm Password",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              _buildTextField("Confirm password", _confirmPasswordController),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0B5739),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _updatePassword,
                  child: Text(
                    "Update password",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      obscureText: ispasswordHidden,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(ispasswordHidden ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              ispasswordHidden = !ispasswordHidden;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $hint';
        }
        if (value.length < 6) {
          return "Password must be at least 6 characters";
        }
        if (hint == "Confirm password" && value != _newPasswordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}