import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

late List<CameraDescription> cameras;

Future<void> initCameras() async {
  try {
    cameras = await availableCameras();
    debugPrint("Cameras initialized: ${cameras.length} camera(s) found");
  } catch (e) {
    debugPrint("Error getting cameras: $e");
    cameras = [];
  }
}
