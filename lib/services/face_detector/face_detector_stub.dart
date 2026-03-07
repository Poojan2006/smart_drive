import 'face_detector_service.dart';

// ignore: unused_import
import 'face_detector_mobile.dart'
    if (dart.library.html) 'face_detector_web.dart';

FaceDetectorService getFaceDetectorService() {
  return getFaceDetector();
}
