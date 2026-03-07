# SmartDrive

SmartDrive is an innovative Flutter-based mobile application designed to enhance driving safety and convenience through advanced AI-powered features. Leveraging cutting-edge technologies like face detection, speech recognition, real-time navigation, and intelligent alerts, SmartDrive aims to make every journey safer and more enjoyable.

## 🚀 Features

### Core Functionality
- **Face Detection & Drowsiness Monitoring**: Uses Google ML Kit to detect driver fatigue and provide timely alerts
- **Voice Commands**: Integrated speech-to-text and text-to-speech for hands-free operation
- **Real-time Navigation**: Interactive maps with turn-by-turn directions using Flutter Map
- **Emergency Contacts**: Quick access to emergency services and predefined contacts
- **Location Tracking**: GPS-based location services for route optimization and safety

### AI & Machine Learning
- **AI-Powered Assistance**: Integration with Google Generative AI for intelligent responses
- **Face Recognition**: Advanced face detection for driver monitoring
- **Smart Alerts**: Context-aware notifications for safety and navigation

### User Experience
- **Dark Theme**: Modern, eye-friendly dark UI design
- **Wake Lock**: Keeps screen active during navigation
- **Audio Feedback**: Sound alerts for important notifications
- **Customizable Settings**: Personalized user preferences and configurations

### Technical Features
- **Offline Support**: Local database storage using SQLite
- **Cross-Platform**: Built with Flutter for iOS and Android compatibility
- **Camera Integration**: Real-time camera access for face detection
- **Permission Management**: Comprehensive permission handling for location, camera, and microphone

## 📱 Screenshots

*(Add screenshots here once available)*

## 🛠️ Installation

### Prerequisites
- Flutter SDK (^3.9.2)
- Dart SDK (^3.9.2)
- Android Studio or Xcode for platform-specific development
- Git

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/smart_drive.git
   cd smart_drive
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure platform-specific settings:**

   **For Android:**
   - Ensure `minSdkVersion` is set to 21 or higher in `android/app/build.gradle`
   - Add necessary permissions in `android/app/src/main/AndroidManifest.xml`

   **For iOS:**
   - Update `ios/Runner/Info.plist` with required permissions
   - Ensure iOS deployment target is 11.0 or higher

4. **Run the app:**
   ```bash
   flutter run
   ```

### Build for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📖 Usage

1. **Launch the App**: Open SmartDrive on your device
2. **Login/Register**: Create an account or log in with existing credentials
3. **Grant Permissions**: Allow camera, location, and microphone access
4. **Start Driving**: Begin your journey with real-time monitoring
5. **Voice Commands**: Use voice commands for navigation and controls
6. **Emergency Access**: Quick emergency contact access when needed

### Key Interactions
- **Face Monitoring**: Keep your face visible to the camera for drowsiness detection
- **Voice Control**: Say "Navigate to [destination]" or "Call emergency"
- **Map Navigation**: Tap on the map to set destinations
- **Settings**: Customize alerts, themes, and preferences

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                 # Application entry point
├── database/                 # Local database services
├── models/                   # Data models
├── screens/                  # UI screens (Login, Settings, etc.)
├── services/                 # Business logic and external integrations
│   ├── ai_service.dart       # AI integration
│   ├── face_detector/        # Face detection services
│   ├── navigation_service.dart # Navigation logic
│   └── salesforce_auth_services.dart # Authentication
├── theme/                    # App theming
├── widgets/                  # Reusable UI components
└── secrets.dart              # API keys and secrets
```

### Dependencies

#### Core Dependencies
- **Flutter SDK**: UI framework
- **sqflite**: Local database storage
- **camera**: Camera access for face detection
- **google_mlkit_face_detection**: Face detection ML
- **geolocator**: GPS location services
- **speech_to_text**: Voice input
- **flutter_tts**: Text-to-speech output
- **flutter_map**: Interactive maps
- **audioplayers**: Audio playback for alerts

#### AI & Cloud
- **google_generative_ai**: AI-powered features
- **http**: Network requests

#### Utilities
- **permission_handler**: Permission management
- **wakelock_plus**: Screen wake lock
- **google_fonts**: Custom typography
- **path**: File system paths

## 🔧 Configuration

### API Keys
Create a `secrets.dart` file in the `lib/` directory with your API keys:

```dart
const String googleApiKey = 'your_google_api_key';
const String salesforceClientId = 'your_salesforce_client_id';
const String salesforceClientSecret = 'your_salesforce_client_secret';
```

### Environment Variables
For different environments, create `.env` files and use the `flutter_dotenv` package if needed.

## 🧪 Testing

Run tests with:
```bash
flutter test
```

### Test Coverage
- Unit tests for services
- Widget tests for UI components
- Integration tests for key workflows

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

### Development Guidelines
- Follow Flutter best practices
- Write tests for new features
- Update documentation
- Ensure cross-platform compatibility

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Google ML Kit for face detection capabilities
- Flutter community for the amazing framework
- Open source contributors

## 📞 Support

For support, email support@smartdrive.com or join our Discord community.

---

**SmartDrive** - Drive Smart, Drive Safe! 🚗💨
