import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

abstract class FaceDetectorService {
  Future<List<Face>> processImage(InputImage inputImage);
  void close();
}
