import 'dart:async' show Future, Timer;
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui'; // REQUIRED for BackdropFilter
import 'screens/login_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart'; // For MethodChannel
import 'package:permission_handler/permission_handler.dart'; // For SMS permission
import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:http/http.dart' as http; // Twilio removed
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'database/contact_service.dart';
import 'services/navigation_service.dart';
import 'screens/settings_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/face_detector/face_detector_service.dart';
import 'services/face_detector/face_detector_stub.dart';
import 'services/salesforce_auth_services.dart';
import 'widgets/chat_bottom_sheet.dart';
import 'secrets.dart'; // Import your secrets
import 'theme/app_theme.dart'; // Import the new theme
import 'package:wakelock_plus/wakelock_plus.dart'; // Keep screen awake

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartDrive',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryColor,
          brightness: Brightness.dark,
          secondary: AppTheme.accentColor,
        ),
        scaffoldBackgroundColor: AppTheme.backgroundColor,
        textTheme: TextTheme(
          bodyLarge: AppTheme.bodyLarge,
          bodyMedium: AppTheme.bodyMedium,
          headlineLarge: AppTheme.headlineLarge,
        ),
      ),

      // The starting point remains the OnboardingScreen
      home: const LoginScreen(),
    );
  }
}

// =========================================================================
// 1. ONBOARDING SCREENS (Unchanged)
// =========================================================================

class OnboardingScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final int userId; // Add userId

  const OnboardingScreen({
    super.key,
    required this.cameras,
    required this.userId,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),

        children: [_buildWelcomePage(context), _buildSafetyPage(context)],
      ),
    );
  }



  // --- Page 1: Welcome (No back button needed as it's the first page) ---
  Widget _buildWelcomePage(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 80,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Logo / Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "SmartDrive",
                  style: AppTheme.headlineLarge.copyWith(fontSize: 42, letterSpacing: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "Your intelligent co-pilot for safer formatting journeys.",
                  style: AppTheme.bodyLarge.copyWith(fontSize: 18, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 2),
                // Modern Action Button
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppTheme.buttonGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubic,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Get Started", style: AppTheme.buttonText.copyWith(fontSize: 18)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Page 2: Safety Info & Start Button (Back button added) ---
  Widget _buildSafetyPage(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40), // Space for back button
                  Text(
                    "Safety First",
                    style: AppTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please review these important safety guidelines.",
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      child: AppTheme.glassContainer(
                        child: Column(
                          children: [
                            _buildSafetyPoint(
                              Icons.location_on_rounded,
                              "Location Tracking",
                              "We track location to send help in emergencies.",
                            ),
                            const Divider(color: Colors.white10),
                            _buildSafetyPoint(
                              Icons.visibility_rounded,
                              "Face Monitoring",
                              "Ensure your face is visible to the camera at all times.",
                            ),
                            const Divider(color: Colors.white10),
                            _buildSafetyPoint(
                              Icons.volume_up_rounded,
                              "Alarms",
                              "Loud alarms will sound if drowsiness is detected.",
                            ),
                            const Divider(color: Colors.white10),
                            _buildSafetyPoint(
                              Icons.emergency_share_rounded,
                              "Emergency Alerts",
                              "SMS alerts sent to contacts if no response.",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Start Button
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppTheme.buttonGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DrowsinessDetectorScreen(
                              cameras: widget.cameras,
                              userId: widget.userId,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        "START MONITORING",
                        style: AppTheme.buttonText.copyWith(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Back Button
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyPoint(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: AppTheme.accentColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.headlineMedium.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// 2. DETECTOR SCREEN (Emergency Contact UI Changes)
// =========================================================================

class DrowsinessDetectorScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final int userId;

  const DrowsinessDetectorScreen({
    super.key,
    required this.cameras,
    required this.userId,
  });

  @override
  State<DrowsinessDetectorScreen> createState() =>
      _DrowsinessDetectorScreenState();
}

class _DrowsinessDetectorScreenState extends State<DrowsinessDetectorScreen> {
  late CameraController _controller;
  late FaceDetectorService _faceDetector;
  static const platform = MethodChannel('com.example.smart_drive/sms');

  // NEW STATE VARIABLE FOR EMERGENCY CONTACTS (using a Set for unique numbers)
  Set<String> _emergencyContacts = {};

  bool _isDetecting = false;
  int closedSeconds = 0;
  Timer? _timer;
  bool alarmOn = false;
  final AudioPlayer _player = AudioPlayer();

  // DEBUG & SIMULATION VARIABLES
  bool _simulationMode = false;
  String _debugFaceInfo = "No Face";
  double? _debugLeftEye;
  double? _debugRightEye;

  // Navigation
  final NavigationService _navService = NavigationService();
  final TextEditingController _searchController = TextEditingController();
  List<LatLng> _routePoints = [];
  int? _currentSpeedLimit;
  List<Map<String, dynamic>> _nearbyPOIs = [];
  bool _showPOISidebar = false;

  // Location Variables
  Position? _currentPosition;
  String _locationStatus = "Initializing GPS...";
  bool _cameraError = false;

  // --- NEW: Monitoring Modes ---
  bool _isBatterySaver = false; // Black screen mode
  bool _isNightMode = false;    // Flash/Light mode

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _faceDetector = getFaceDetectorService();
    _determinePosition();
    _startCamera();
    SalesforceAuthService.generateToken();
    WakelockPlus.enable(); // Keep screen awake during monitoring
  }

  @override
  void dispose() {
    WakelockPlus.disable(); // Allow screen to sleep when leaving
    _timer?.cancel();
    _player.stop();
    _controller.dispose();
    _faceDetector.close(); // Corrected from .dispose() to .close()
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final contacts = await ContactService.getContacts(widget.userId);

    setState(() {
      _emergencyContacts = contacts.toSet();
    });
  }

  // --- NEW: Method to show the pop-up dialog for number input ---
  void _showAddContactDialog() {
    // Controller to manage the 5 lines of text input
    final TextEditingController textController = TextEditingController(
      text: _emergencyContacts.join('\n'), // Pre-fill with existing contacts
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            "Emergency Contacts (Max 5)",
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: TextField(
              controller: textController,
              keyboardType: TextInputType.phone,
              maxLines: 5, // Allows up to 5 lines of input
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText:
                    "Enter one mobile number per line\nExample:\n+11234567890\n+19876543210",
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurpleAccent),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "SAVE",
                style: TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                // 1. Split the text by newline and filter out empty lines
                final List<String> lines = textController.text
                    .split('\n')
                    .map((line) => line.trim())
                    .where((line) => line.isNotEmpty)
                    .toList();

                // 2. Take only the first 5 numbers
                final Set<String> newContacts = Set.from(lines.take(5));

                // 3. Update the global constant and local state (for display purposes)
                // NOTE: In a real app, you would save this to SharedPreferences or a database.
                // For this demo, we update the local state.
                setState(() {
                  _emergencyContacts = newContacts;
                  // In a production app, you would update the ALERT_CONTACTS global/logic here
                  // ALERT_CONTACTS = newContacts.toList();
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  // -----------------------------------------------------------------------

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setLocationStatus(
        "Location services are disabled. Cannot send location.",
      );
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setLocationStatus("Location permission denied. Cannot send location.");
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _setLocationStatus("Location permission permanently denied.");
      return Future.error('Location permissions are permanently denied');
    }

    _setLocationStatus("GPS ready.");
    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        _currentPosition = position;
        _setLocationStatus("GPS active.");
      }
    });

    // Update Speed Limit periodically (lazy check)
    if (DateTime.now().second % 10 == 0) {
      // Check every ~10s
      _updateSpeedLimit();
    }
  }

  void _updateSpeedLimit() async {
    if (_currentPosition == null) {
      debugPrint("Speed Limit: No position");
      return;
    }
    debugPrint(
      "Fetching speed limit for: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}",
    );
    final limit = await _navService.getSpeedLimit(
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
    );
    debugPrint("Speed Limit Result: $limit");
    if (mounted && limit != _currentSpeedLimit) {
      setState(() {
        _currentSpeedLimit = limit;
      });
      debugPrint("Speed Limit Updated: $_currentSpeedLimit");
    }
  }

  void _fetchNearbyPOIs() async {
    debugPrint("POI: Starting fetch...");
    if (_currentPosition == null) {
      debugPrint("POI: No position available");
      return;
    }
    final center = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );
    debugPrint("POI: Fetching for $center");

    // Fetch only hospitals
    final hospitals = await _navService.getNearbyPOIs(center, 'hospital');
    debugPrint("POI: Found ${hospitals.length} hospitals");

    if (mounted) {
      setState(() {
        _nearbyPOIs = hospitals;
      });
      debugPrint("POI: State updated with ${_nearbyPOIs.length} POIs");
    }
  }

  void _navigateToPOI(Map<String, dynamic> poi) async {
    if (_currentPosition == null) return;

    final dest = LatLng(poi['lat'], poi['lon']);
    final start = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );
    final points = await _navService.getRoute(start, dest);

    setState(() {
      _routePoints = points;
      _showPOISidebar = false; // Close sidebar after selecting
    });
  }

  String _buildLocationContext() {
    final parts = <String>[];
    if (_currentPosition != null) {
      parts.add(
        "Location: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}",
      );
    }
    if (_currentSpeedLimit != null) {
      parts.add("Speed Limit: $_currentSpeedLimit km/h");
    }
    if (_nearbyPOIs.isNotEmpty) {
      final hospitalNames = _nearbyPOIs
          .take(3)
          .map((p) => p['name'])
          .join(", ");
      parts.add("Nearby Hospitals: $hospitalNames");
    }
    return parts.join("\n");
  }

  void _startNavigation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _currentPosition == null) return;

    // 1. Find Destination
    final dest = await _navService.searchPlace(query);
    if (dest != null) {
      // 2. Get Route
      final start = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      final points = await _navService.getRoute(start, dest);

      setState(() {
        _routePoints = points;
      });
    }
  }

  void _setLocationStatus(String status) {
    if (mounted) {
      setState(() {
        _locationStatus = status;
      });
    }
  }

  void _startCamera() async {
    if (widget.cameras.isEmpty) return;

    final frontCamera = widget.cameras.length > 1
        ? widget.cameras[1]
        : widget.cameras.first;

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _controller.initialize();
      if (!mounted) return;
      await _controller.startImageStream(_processCameraImage);
    } on CameraException catch (e) {
      debugPrint("Camera initialization error: $e");
      _cameraError = true;
    }

    setState(() {});
  }

  Uint8List _yuv420toNv21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final y = image.planes[0].bytes;
    final u = image.planes[1].bytes;
    final v = image.planes[2].bytes;

    final int yRowStride = image.planes[0].bytesPerRow;
    final int uRowStride = image.planes[1].bytesPerRow;
    final int vRowStride = image.planes[2].bytesPerRow;
    final int uPixelStride = image.planes[1].bytesPerPixel ?? 1;
    final int vPixelStride = image.planes[2].bytesPerPixel ?? 1;

    final nv21 = Uint8List(width * height * 3 ~/ 2);

    int dstIndex = 0;
    if (yRowStride == width) {
      nv21.setAll(0, y);
      dstIndex = y.length;
    } else {
      for (int i = 0; i < height; i++) {
        nv21.setAll(
          dstIndex,
          y.sublist(i * yRowStride, i * yRowStride + width),
        );
        dstIndex += width;
      }
    }

    for (int i = 0; i < height ~/ 2; i++) {
      for (int j = 0; j < width ~/ 2; j++) {
        final uIndex = i * uRowStride + j * uPixelStride;
        final vIndex = i * vRowStride + j * vPixelStride;
        nv21[dstIndex++] = v[vIndex];
        nv21[dstIndex++] = u[uIndex];
      }
    }
    return nv21;
  }

  InputImage? _convertCameraImage(CameraImage image, CameraDescription camera) {
    if (image.format.group != ImageFormatGroup.yuv420) {
      return null;
    }
    final bytes = _yuv420toNv21(image);
    final InputImageFormat inputFormat = InputImageFormat.nv21;

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation:
          InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
          InputImageRotation.rotation0deg,
      format: inputFormat,
      bytesPerRow: image.planes.first.bytesPerRow,
    );
    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  void _processCameraImage(CameraImage image) async {
    if (!mounted || _isDetecting) return;

    // 1. SIMULATION MODE CHECK
    if (_simulationMode) {
      if (mounted) {
        setState(() {
          _debugFaceInfo = "SIMULATION";
          _debugLeftEye = 0.0;
          _debugRightEye = 0.0;
        });
        _startClosedTimer(); // Force timer increment
      }
      return;
    }

    final inputImage = _convertCameraImage(image, _controller.description);
    if (inputImage == null) return;

    _isDetecting = true;
    try {
      final faces = await _faceDetector.processImage(inputImage);
      if (!mounted || !_controller.value.isStreamingImages) return;

      if (faces.isEmpty) {
        _resetClosedTimer();
        if (mounted) {
          setState(() {
            _debugFaceInfo = "No Face Found";
            _debugLeftEye = null;
            _debugRightEye = null;
          });
        }
      } else {
        final face = faces.first;
        if (mounted) {
          setState(() {
            _debugFaceInfo = "Face Detected";
            _debugLeftEye = face.leftEyeOpenProbability;
            _debugRightEye = face.rightEyeOpenProbability;
          });
        }

        if (face.leftEyeOpenProbability != null &&
            face.rightEyeOpenProbability != null) {
          final bool eyesClosed =
              face.leftEyeOpenProbability! < 0.2 &&
              face.rightEyeOpenProbability! < 0.2;
          eyesClosed ? _startClosedTimer() : _resetClosedTimer();
        } else {
          _resetClosedTimer();
        }
      }
    } on Exception catch (e) {
      debugPrint("ML Kit Processing Error (Handled): $e");
      if (mounted) {
        setState(() {
          _debugFaceInfo = "Error: $e";
        });
      }
    } finally {
      if (mounted) {
        _isDetecting = false;
      }
    }
  }

  void _startClosedTimer() {
    if (_timer != null && _timer!.isActive) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        closedSeconds++;
      });
      if (closedSeconds == 5 && !alarmOn) {
        _playAlarm();
      }
      if (closedSeconds == 12) {
        _sendSMSAlert();
      }
    });
  }

  void _resetClosedTimer() {
    if (closedSeconds > 0 || alarmOn) {
      closedSeconds = 0;
      _timer?.cancel();
      if (alarmOn) {
        _stopAlarm();
      }
      setState(() {});
    }
  }

  Future<void> _playAlarm() async {
    debugPrint("TRIGGERING ALARM START");
    alarmOn = true;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource("alarm_sound.mp3"));
      debugPrint("ALARM PLAY COMMAND SENT");
    } catch (e) {
      debugPrint("ERROR PLAYING ALARM: $e");
    }
    setState(() {});
  }

  Future<void> _stopAlarm() async {
    alarmOn = false;
    await _player.stop();
    setState(() {});
  }

  Future<void> _sendSMSAlert() async {
    debugPrint("Attempting to send SMS alert...");

    String locationLink = "Location Unavailable.";

    if (_currentPosition != null) {
      final lat = _currentPosition!.latitude;
      final lon = _currentPosition!.longitude;
      locationLink = "Current Location: https://maps.google.com/?q=$lat,$lon";
    }

    // NOTE: For the SMS logic to use the dynamically added numbers,
    // you would replace ALERT_CONTACTS with _emergencyContacts.toList() here.
    final messageBody =
        'EMERGENCY: Driver drowsiness detected! Eyes closed for >12s. $locationLink';
    debugPrint("Sending message: $messageBody");

    // --- SALESFORCE INTEGRATION ---
    if (_currentPosition != null) {
      SalesforceAuthService.createDrowsinessRecord(
          lat: _currentPosition!.latitude,
          lon: _currentPosition!.longitude,
          riskLevel: "Critical (SMS Sent)"
      );
    }
    // -----------------------------

    // Check SMS Permission
    if (await Permission.sms.request().isGranted) {
      for (var contact in _emergencyContacts) {
        try {
          final String result = await platform.invokeMethod('sendSMS', {
            'phone': contact,
            'message': messageBody,
          });
          debugPrint('SMS Result for $contact: $result');
        } on PlatformException catch (e) {
          debugPrint("Failed to send SMS to $contact: '${e.message}'.");
        }
      }
    } else {
      debugPrint("SMS Permission Denied");
    }
  }



  // --- UI Build (Glass Status Overlay & AppBar modified) ---
  @override
  Widget build(BuildContext context) {
    // Battery Saver Mode (Black Screen)
    if (_isBatterySaver) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onDoubleTap: () => setState(() => _isBatterySaver = false),
          child: Container(
            color: Colors.black,
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.nights_stay_rounded, color: Colors.white24, size: 60),
                  const SizedBox(height: 20),
                  const Text("Monitoring Active", style: TextStyle(color: Colors.white24, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text("Double tap to wake", style: TextStyle(color: Colors.white12, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!_cameraError && !_controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true, // Make map fill screen
      appBar: AppBar(
        title: const Text("SmartDrive Co-Pilot"),
        elevation: 0,
        backgroundColor: Colors.transparent, // Glass-like AppBar
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            _stopAlarm();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // Night Mode Toggle
          IconButton(
            icon: Icon(
              _isNightMode ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
              color: _isNightMode ? Colors.amber : Colors.white,
            ),
            onPressed: () async {
              setState(() => _isNightMode = !_isNightMode);
              // Attempt to toggle hardware flash
              try {
                await _controller.setFlashMode(
                  _isNightMode ? FlashMode.torch : FlashMode.off,
                );
              } catch (e) {
                debugPrint("Hardware flash not supported/failed: $e");
              }
            },
            tooltip: "Night Mode",
          ),
          // Battery Saver Toggle
          IconButton(
            icon: const Icon(Icons.battery_saver_rounded, color: Colors.white),
            onPressed: () => setState(() => _isBatterySaver = true),
            tooltip: "Battery Saver",
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 6.0,
            ),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              _emergencyContacts.isEmpty
                  ? "No Contacts"
                  : "${_emergencyContacts.length} Contacts",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.blueAccent),
            onPressed:
                _showAddContactDialog, // Keep generic one or remove if moving to settings
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'Settings',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    simulationMode: _simulationMode,
                    userId: widget.userId,
                    currentContacts: _emergencyContacts.toList(),
                    onSimulationModeChanged: (val) {
                      setState(() {
                        _simulationMode = val;
                        if (!val) _resetClosedTimer();
                      });
                    },
                  ),
                ),
              );
              // Refresh contacts on return
              _loadContacts();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_active,
              color: Colors.orangeAccent,
            ),
            tooltip: 'Test Alarm',
            onPressed: () {
              if (alarmOn) {
                _stopAlarm();
              } else {
                _playAlarm();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. OpenStreetMap (FlutterMap) Background
          FlutterMap(
            options: MapOptions(
              initialCenter: _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    )
                  : const LatLng(37.7749, -122.4194), // Default SF
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.smart_drive',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 5.0,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.navigation,
                        color: Colors.blueAccent,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Speed Limit Sign
          if (_currentSpeedLimit != null)
            Positioned(
              top: 120,
              left: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 70,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "LIMIT",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "$_currentSpeedLimit",
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Search Bar (Bottom Glassmorphic)
          Positioned(
            bottom: 120, // Moved to bottom
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search destination...",
                      hintStyle: GoogleFonts.outfit(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.directions,
                          color: Colors.blueAccent,
                        ),
                        onPressed: _startNavigation,
                      ),
                    ),
                    onSubmitted: (_) => _startNavigation(),
                  ),
                ),
              ),
            ),
          ),

          // POI Sidebar
          if (_showPOISidebar)
            Positioned(
              top: 60,
              right: 16,
              bottom: 200,
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            "Nearby POIs",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Divider(color: Colors.white24, height: 1),
                        Expanded(
                          child: _nearbyPOIs.isEmpty
                              ? Center(
                                  child: Text(
                                    "No POIs found",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white54,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _nearbyPOIs.length,
                                  itemBuilder: (context, index) {
                                    final poi = _nearbyPOIs[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        poi['name'],
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: const Icon(
                                        Icons.navigation,
                                        color: Colors.blueAccent,
                                        size: 16,
                                      ),
                                      onTap: () => _navigateToPOI(poi),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // POI Toggle FAB
          Positioned(
            top: 200,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.deepPurpleAccent,
              onPressed: () {
                setState(() {
                  _showPOISidebar = !_showPOISidebar;
                  if (_showPOISidebar && _nearbyPOIs.isEmpty) {
                    _fetchNearbyPOIs();
                  }
                });
              },
              child: Icon(
                _showPOISidebar ? Icons.close : Icons.local_hospital,
                color: Colors.white,
              ),
            ),
          ),

          // 2. Camera Preview (Floating Picture-in-Picture)
          Positioned(
            top: 100,
            right: 20,
            width: 120,
            height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: alarmOn ? Colors.red : Colors.greenAccent,
                    width: 3,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 10),
                  ],
                ),
                child: _cameraError
                    ? const Center(
                        child: Icon(Icons.videocam_off, color: Colors.white54),
                      )
                    : CameraPreview(_controller),
              ),
            ),
          ),

          // 3. Glass Status Alert (Centered Top)
          Positioned(
            top: 100,
            left: 20,
            right: 160, // Avoid overlapping camera
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: alarmOn
                    ? Colors.red.withValues(alpha: 0.8)
                    : Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white24),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alarmOn ? "WAKE UP!" : "Driver Alert",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Status: $_locationStatus",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  if (closedSeconds > 0)
                    Text(
                      "Eyes Closed: ${closedSeconds}s",
                      style: const TextStyle(
                        color: Colors.yellowAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  const Divider(color: Colors.white24, height: 10),
                  // DEBUG INFO
                  Text(
                    "Face: $_debugFaceInfo",
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  if (_debugLeftEye != null)
                    Text(
                      "L: ${_debugLeftEye!.toStringAsFixed(2)} | R: ${_debugRightEye!.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        "Simulate Drowsy",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Switch(
                        value: _simulationMode,
                        onChanged: (val) {
                          setState(() {
                            _simulationMode = val;
                            if (!val) _resetClosedTimer();
                          });
                        },
                        activeThumbColor: Colors.redAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 4. Chatbot FAB (Bottom Left)
          Positioned(
            bottom: 30,
            left: 20,
            child: FloatingActionButton(
              heroTag: 'chat_fab',
              backgroundColor: Colors.deepPurpleAccent,
              child: const Icon(Icons.chat_bubble, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) =>
                      ChatBottomSheet(locationContext: _buildLocationContext()),
                );
              },
            ),
          ),
          // Night Mode Overlay
          if (_isNightMode)
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 50), // Thick white border
                  color: Colors.white.withValues(alpha: 0.7), // High visibility overlay (act as light source)
                ),
                child: Center(
                  child: Container(
                    width: 300,
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
