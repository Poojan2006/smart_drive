import 'package:flutter/material.dart';
import '../database/auth_service.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';
import '../main.dart'; // for cameras list

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  void _login() async {
    final username = userCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (username.length < 3) {
      _showMsg("Username must be at least 3 characters");
      return;
    }

    if (password.length < 6) {
      _showMsg("Password must be at least 6 characters");
      return;
    }

    try {
      final user = await AuthService.login(username, password);
      // Mounted check is already here implicitly if we use context below, but good practice
      if (!mounted) return;

      if (user == null) {
        _showMsg("Invalid credentials");
        return;
      }

      final userId = user['id'] as int;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OnboardingScreen(cameras: cameras, userId: userId),
        ),
      );
    } catch (e) {
      if (mounted) {
        _showMsg("Login Error: $e");
        debugPrint("Login Error: $e");
      }
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Background ambient glow
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 100,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: AppTheme.glassContainer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_person_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Welcome Back",
                        style: AppTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Sign in to continue your journey",
                        style: AppTheme.bodyMedium,
                      ),
                      const SizedBox(height: 48),

                      TextField(
                        controller: userCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: AppTheme.glassInputDecoration(
                          label: "Username",
                          prefixIcon: Icons.person_rounded,
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: passCtrl,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: AppTheme.glassInputDecoration(
                          label: "Password",
                          prefixIcon: Icons.lock_rounded,
                        ),
                      ),

                      const SizedBox(height: 40),

                      Container(
                        width: double.infinity,
                        height: 56,
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
                          onPressed: _login,
                          style: AppTheme.primaryButtonStyle.copyWith(
                            backgroundColor: WidgetStateProperty.all(Colors.transparent),
                            shadowColor: WidgetStateProperty.all(Colors.transparent),
                          ),
                          child: Text(
                            "LOGIN",
                            style: AppTheme.buttonText,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: AppTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: "Register",
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
