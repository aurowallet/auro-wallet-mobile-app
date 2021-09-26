import 'package:permission_handler/permission_handler.dart';

class CameraUtils {
  static Future<bool> canOpenCamera() async {
    var status = await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
    if (status != PermissionStatus.granted) {
      var future = await PermissionHandler()
          .requestPermissions([PermissionGroup.camera]);
      for (final item in future.entries) {
        if (item.value != PermissionStatus.granted) {
          return false;
        }
      }
    }
    return true;
  }
}