import 'package:flutter/material.dart';

class ArviewFor3dObjects extends StatefulWidget
{
  String name;
  String model3durl;

  ArviewFor3dObjects ({super.key, required this.name, required this.model3durl});

  @override
  State<ArviewFor3dObjects> createState() => _ArviewFor3dObjectsState();
}

class _ArviewFor3dObjectsState extends State<ArviewFor3dObjects> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.name} AR View'),
        centerTitle: true,
      ),
    );
  }
}
