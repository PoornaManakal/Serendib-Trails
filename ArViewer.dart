import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class ArViewer extends StatefulWidget {
  final String modelPath;

  const ArViewer({required this.modelPath, super.key});

  @override
  State<ArViewer> createState() => _ArViewerState();
}

class _ArViewerState extends State<ArViewer> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;
  ARLocationManager? arLocationManager;
  List<ARNode> nodes = [];
  bool isModelPlaced = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AR Viewer"), backgroundColor: Colors.teal),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: _onARViewCreated,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isModelPlaced ? null : () => _addARObject(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text("Place Model", style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: isModelPlaced ? _removeAllARObjects : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text("Remove All", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isModelPlaced
                    ? "Model placed! Use gestures to rotate/scale"
                    : "Scan the area and tap 'Place Model' to place the 3D model in AR",
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onARViewCreated(
      ARSessionManager sessionManager,
      ARObjectManager objectManager,
      ARAnchorManager anchorManager,
      ARLocationManager locationManager) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;
    arLocationManager = locationManager;

    arSessionManager.onInitialize(
      showFeaturePoints: true,
      showPlanes: true,
      showWorldOrigin: false,
      handlePans: true,
      handleRotation: true,
    );

    arObjectManager.onInitialize();
    arSessionManager.onPlaneOrPointTap = _handlePlaneOrPointTapped;
  }

  Future<void> _handlePlaneOrPointTapped(List<ARHitTestResult> hitResults) async {
    if (!isModelPlaced && hitResults.isNotEmpty) {
      var singleHit = hitResults.firstWhere(
            (hit) => hit.type == ARHitTestResultType.plane,
        orElse: () => hitResults.first,
      );
      await _addARObjectAtHit(singleHit);
    }
  }

  Future<void> _addARObjectAtHit(ARHitTestResult hit) async {
    var newNode = ARNode(
      type: NodeType.localGLTF2,
      uri: widget.modelPath,
      scale: vm.Vector3(0.2, 0.2, 0.2),
      position: hit.worldTransform.getTranslation(),
      rotation: vm.Quaternion.fromRotation(
          hit.worldTransform.getRotation()
      ).asVector4(),
    );

    bool? didAdd = await arObjectManager.addNode(newNode);
    if (didAdd == true) {
      nodes.add(newNode);
      setState(() => isModelPlaced = true);
    }
  }

  Future<void> _addARObject() async {
    if (arObjectManager == null) return;

    var cameraPose = await arSessionManager.getCameraPose();
    var cameraPosition = cameraPose?.getTranslation() ?? vm.Vector3.zero();

    var newNode = ARNode(
      type: NodeType.localGLTF2,
      uri: widget.modelPath,
      scale: vm.Vector3(0.2, 0.2, 0.2),
      position: vm.Vector3(
        cameraPosition.x,
        cameraPosition.y,
        cameraPosition.z - 1.0,
      ),
      rotation: vm.Vector4(0, 0, 0, 0),
    );

    try {
      bool? didAdd = await arObjectManager.addNode(newNode);
      if (didAdd == true) {
        nodes.add(newNode);
        setState(() => isModelPlaced = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Model placed successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error placing model: ${e.toString()}")),
      );
    }
  }

  Future<void> _removeAllARObjects() async {
    for (var node in nodes) {
      await arObjectManager.removeNode(node);
    }
    nodes.clear();
    setState(() => isModelPlaced = false);
  }

  @override
  void dispose() {
    arSessionManager.dispose();
    super.dispose();
  }
}

extension on vm.Quaternion {
  asVector4() {}
}
