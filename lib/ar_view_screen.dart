import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector64;

class ArEarthMapScreen extends StatefulWidget {
  const ArEarthMapScreen({super.key});

  @override
  State<ArEarthMapScreen> createState() => _ArEarthMapScreenState();
}



class _ArEarthMapScreenState extends State<ArEarthMapScreen>
{
  ArCoreController? augmentedRealityCoreController;

  augmentedRealityViewCreated(ArCoreController coreController)
  {
    augmentedRealityCoreController = coreController;

    displayHeartModel(augmentedRealityCoreController!);
  }

  displayHeartModel(ArCoreController coreController) async {
    try {
      debugPrint("💚 HEART: Loading heart model...");

      final node = ArCoreReferenceNode(
        name: "HeartModel",
        objectUrl: "flutter_assets/assets/models/heart.glb",
        position: vector64.Vector3(0, 0, -0.8),
        scale: vector64.Vector3(0.5, 0.5, 0.5),
      );

      await coreController.addArCoreNode(node);

      debugPrint("💚 HEART: Model added successfully");
    } catch (e) {
      debugPrint("💚 HEART ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
        appBar: AppBar(
          title: const Text('AR Earth Map'),
          centerTitle: true,
        ),
        body: ArCoreView(
          onArCoreViewCreated: augmentedRealityViewCreated,)
    );
  }
}
