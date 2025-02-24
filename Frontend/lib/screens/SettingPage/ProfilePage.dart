import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? user;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  bool isMaleSelected = true;
  String email = "";
  String profilePicUrl = "";

  FocusNode nameFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode dobFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          nameController.text = userDoc["name"] ?? "";
          phoneController.text = userDoc["phone"] ?? "";
          email = userDoc["email"] ?? "";
          profilePicUrl = userDoc["profilePic"] ?? "";
          dobController.text = userDoc["dob"] ?? "";
          isMaleSelected = userDoc["gender"] == "Male";
        });
      }
    }
  }

  Future<void> _saveUserData() async {
    if (user != null) {
      await _firestore.collection("users").doc(user!.uid).set({
        "name": nameController.text,
        "phone": phoneController.text,
        "dob": dobController.text,
        "gender": isMaleSelected ? "Male" : "Female",
        "profilePic": profilePicUrl,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File file = File(pickedFile.path);
    String fileName = "profile_pictures/${user!.uid}.jpg";

    try {
      UploadTask uploadTask = _storage.ref().child(fileName).putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save image URL in Firestore
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .update({'profilePic': downloadUrl});

      setState(() {
        profilePicUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Profile picture updated!"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to upload image"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _deleteProfilePicture() async {
    if (user == null || profilePicUrl.isEmpty) return;

    try {
      // Remove image from Firebase Storage
      await _storage.refFromURL(profilePicUrl).delete();

      // Remove image URL from Firestore
      await _firestore
          .collection("users")
          .doc(user!.uid)
          .update({"profilePic": ""});

      setState(() {
        profilePicUrl = "";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Profile picture deleted!"),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to delete profile picture"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xFFFDF6F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Profile",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profilePicUrl.isNotEmpty
                        ? NetworkImage(profilePicUrl)
                        : AssetImage("lib/assets/images/default_profile.jpg")
                            as ImageProvider,
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: CircleAvatar(
                            backgroundColor: Color(0xFF0B5739),
                            radius: 18,
                            child: Icon(Icons.camera_alt,
                                color: Colors.white, size: 18),
                          ),
                        ),
                        SizedBox(width: 8),
                        if (profilePicUrl
                            .isNotEmpty) // Show delete button only if an image exists
                          SizedBox(width: 8),
                        if (profilePicUrl.isNotEmpty)
                          GestureDetector(
                            onTap: _deleteProfilePicture,
                            child: CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 18,
                              child: Icon(Icons.delete,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildLabel("Name"),
            _buildTextField(nameController, "Enter your name", nameFocusNode),
            _buildLabel("Email"),
            TextField(
              controller: TextEditingController(text: email),
              readOnly: true,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[300],
              ),
            ),
            _buildLabel("Phone Number"),
            _buildTextField(
                phoneController, "Enter phone number", phoneFocusNode),
            _buildLabel("Date of Birth"),
            _buildTextField(
                dobController, "Enter your date of birth", dobFocusNode),
            _buildLabel("Gender"),
            Row(
              children: [
                _genderButton("Male", isMaleSelected, () {
                  setState(() {
                    isMaleSelected = true;
                  });
                }),
                SizedBox(width: 10),
                _genderButton("Female", !isMaleSelected, () {
                  setState(() {
                    isMaleSelected = false;
                  });
                }),
              ],
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _saveUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0B5739),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Save",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, FocusNode focusNode) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF0B5739)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _genderButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF0B5739) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? Colors.white : Colors.black,
              ),
              SizedBox(width: 5),
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
