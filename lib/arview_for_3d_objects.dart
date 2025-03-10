import 'package:ar_flutter_plugin_engine/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_engine/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin_engine/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_engine/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_engine/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin_engine/models/ar_node.dart';
import 'package:ar_flutter_plugin_engine/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vectorMath64;

class ArviewFor3dObjects extends StatefulWidget
{
  String name;
  String model3durl;

  ArviewFor3dObjects ({super.key, required this.name, required this.model3durl});

  @override
  State<ArviewFor3dObjects> createState() => _ArviewFor3dObjectsState();
}

class _ArviewFor3dObjectsState extends State<ArviewFor3dObjects> {

  ARSessionManager? sessionManagerAR;
  ARObjectManager? objectManagerAR;
  ARAnchorManager? anchorManagerAR;
  List<ARNode> allNodesList = [];
  List<ARAnchor> allAnchors = [];


  createARView(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager locationManagerAR)
  {
    sessionManagerAR = arSessionManager;
    objectManagerAR = arObjectManager;
    anchorManagerAR = arAnchorManager;

    sessionManagerAR!.onInitialize(
      handleRotation: true,
      handlePans: true,
      showWorldOrigin: true,
      showFeaturePoints: false,
      showPlanes: true,
    );
    objectManagerAR!.onInitialize();

    sessionManagerAR!.onPlaneOrPointTap = detectPlaneAndLetUserTap;
    objectManagerAR!.onPanStart = duringOnPanStarted;
    objectManagerAR!.onPanChange = duringOnPanChanged;
    objectManagerAR!.onPanEnd = duringOnPanEnded;
    objectManagerAR!.onRotationStart = duringOnRotationStarted;
    objectManagerAR!.onRotationChange = duringOnRotationChanged;
    objectManagerAR!.onRotationEnd = duringOnRotationEnded;

  }

  duringOnPanStarted(String object3DNodeName)
  {
    print("Panning Node Started = " + object3DNodeName);
  }

  duringOnPanChanged(String object3DNodeName)
  {
    print("Panning Node Continued = " + object3DNodeName);
  }

  duringOnPanEnded(String object3DNodeName, Matrix4 transformationMatrix4)
  {
    print("Panning Node Ended = " + object3DNodeName);

    final pannedNode = allNodesList.firstWhere((node) => node.name == object3DNodeName);
  }

  duringOnRotationStarted(String object3DNodeName)
  {
    print("Rotating Node Started = " + object3DNodeName);
  }

  duringOnRotationChanged(String object3DNodeName)
  {
    print("Rotating Node Continued = " + object3DNodeName);
  }

  duringOnRotationEnded(String object3DNodeName, Matrix4 transformationMatrix4)
  {
    print("Rotating Node Ended = " + object3DNodeName);

    final pannedNode = allNodesList.firstWhere((node) => node.name == object3DNodeName);
  }


  Future<void> detectPlaneAndLetUserTap(List<ARHitTestResult> hitTapResultsList) async
  {
    var userHitTapResults = hitTapResultsList.firstWhere((ARHitTestResult userHitPoint)=> userHitPoint.type == ARHitTestResultType.plane);

    if (userHitTapResults != null)
      {
        var planeARAnchor = ARPlaneAnchor(transformation: userHitTapResults.worldTransform);

        bool? anchorAdded = await anchorManagerAR!.addAnchor(planeARAnchor);

        if(anchorAdded!)
          {
            allAnchors.add(planeARAnchor);

            var object3DNewNode = ARNode(
              type: NodeType.webGLB,
              uri: widget.model3durl,
              scale: vectorMath64.Vector3(0.62, 0.62, 0.62),
              position: vectorMath64.Vector3(0, 0, 0),
              rotation: vectorMath64.Vector4(1, 0, 0, 0),
            );

            bool? addARNodeToAnchor = await objectManagerAR!.addNode(object3DNewNode, planeAnchor: planeARAnchor);
            if(addARNodeToAnchor!)
              {
                allNodesList.add(object3DNewNode);
              }
            else
              {
                sessionManagerAR!.onError("Adding Node to Anchor Failed");
              }

          }
        else
        {
          sessionManagerAR!.onError("Filed Anchor cannot be added");
        }
      }
  }

  Future<void>remove3DObject() async
  {
    allAnchors.forEach((each3dobject)
    {
      anchorManagerAR!.removeAnchor(each3dobject);
    });

    allAnchors = [];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    sessionManagerAR!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.name} AR View'),
        centerTitle: true,
      ),
      body: Stack(
        children: [

          ARView(
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            onARViewCreated: createARView,
          ),

          Padding(
            padding: const EdgeInsets.all(17),
            child: Align(
              alignment: Alignment.bottomRight,
              child: MaterialButton(
                  onPressed: ()
              {
                remove3DObject();
              },
                color: Colors.white,
                height: 35,
                minWidth: 41,
                padding: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17)
                ),
                child: const Icon(Icons.cleaning_services_rounded, color: Colors.black,),


            ),
          ),

          ),
        ],
      )
      
    );
  }
}
