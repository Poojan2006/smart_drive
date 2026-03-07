import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'face_detector_service.dart';

class FaceDetectorMobile implements FaceDetectorService {
  final FaceDetector _faceDetector;

  FaceDetectorMobile()
    : _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,
          enableTracking: false,
          enableContours: false,
          enableLandmarks: false,
        ),
      );

  @override
  Future<List<Face>> processImage(InputImage inputImage) {
    return _faceDetector.processImage(inputImage);
  }

  @override
  void close() {
    _faceDetector.close();
  }
}

FaceDetectorService getFaceDetector() => FaceDetectorMobile();
