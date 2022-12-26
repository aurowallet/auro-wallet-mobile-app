import 'package:permission_handler/permission_handler.dart';

class CameraUtils {
  static Future<bool> canOpenCamera() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      if (!await Permission.camera.request().isGranted) {
        return false;
      }
    }
    return true;
  }
}