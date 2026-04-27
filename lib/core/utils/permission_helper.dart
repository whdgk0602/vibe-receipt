import 'package:permission_handler/permission_handler.dart';

/// 앱에서 필요한 권한들을 한번에 관리
class PermissionHelper {
  PermissionHelper._();

  /// 측정 시작 전 마이크 권한을 확인/요청
  static Future<bool> ensureMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// 사진 촬영/선택용 카메라 + 사진 권한
  static Future<bool> ensureCameraAndPhotos() async {
    final results = await [
      Permission.camera,
      Permission.photos,
    ].request();
    return results.values.every((s) => s.isGranted || s.isLimited);
  }

  /// 갤러리 저장용 (안드로이드 12 이하 WRITE_EXTERNAL_STORAGE, 그 이상은 photos)
  static Future<bool> ensureGallerySave() async {
    final photos = await Permission.photos.request();
    if (photos.isGranted || photos.isLimited) return true;
    final storage = await Permission.storage.request();
    return storage.isGranted;
  }
}
