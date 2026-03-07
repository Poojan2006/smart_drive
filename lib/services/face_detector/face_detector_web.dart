import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'face_detector_service.dart';

class FaceDetectorWeb implements FaceDetectorService {
  @override
  Future<List<Face>> processImage(InputImage inputImage) async {
    // Web support not implemented yet
    return [];
  }

  @override
  void close() {}
}

FaceDetectorService getFaceDetector() => FaceDetectorWeb();
