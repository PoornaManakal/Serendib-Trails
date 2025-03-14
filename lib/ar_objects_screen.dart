import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fest/app_colors.dart';
import 'package:vector_math/vector_math_64.dart';

class ARObjectsScreen extends StatefulWidget {
  const ARObjectsScreen({Key? key, required this.object, required this.isLocal})
      : super(key: key);
  final String object;
  final bool isLocal;

  @override
  State<ARObjectsScreen> createState() => _ARObjectsScreenState();
}

class _ARObjectsScreenState extends State<ARObjectsScreen> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  ARNode? localObjectNode;
  ARNode? webObjectNode;
  bool isAdd = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: ARView(onARViewCreated: onARViewCreated),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.isLocal
            ? onLocalObjectButtonPressed
            : onWebObjectAtButtonPressed,
        child: Icon(isAdd ? Icons.remove : Icons.add),
      ),
    );
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;

    this.arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: "assets/triangle.png",
      showWorldOrigin: true,
      handleTaps: false,
    );
    this.arObjectManager.onInitialize();
  }