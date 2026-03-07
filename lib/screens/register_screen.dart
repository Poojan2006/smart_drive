import 'package:flutter/material.dart';
import '../database/auth_service.dart';
import '../theme/app_theme.dart';
import '../database/contact_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController contactsCtrl = TextEditingController();

  void _register() async {
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

    final contacts = contactsCtrl.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (contacts.isEmpty) {
      _showMsg("At least one emergency contact required");
      return;
    }

    if (contacts.length > 5) {
      _showMsg("Maximum 5 emergency contacts allowed");
      return;
    }

    for (final c in contacts) {
      if (!RegExp(r'^\+?[0-9]{10,13}$').hasMatch(c)) {
        _showMsg("Invalid phone number: $c");
        return;
      }
    }

    final userId = await AuthService.register(username, password);
    await ContactService.saveContacts(userId, contacts);

    if (!mounted) return; // Check mounted before using context

    _showMsg("Registration successful");
    Navigator.pop(context);
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
              bottom: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentColor.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withValues(alpha: 0.15),
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
                        Icons.person_add_alt_1_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Create Account",
                        style: AppTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Join SmartDrive today",
                        style: AppTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),

                      TextField(
                        controller: userCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: AppTheme.glassInputDecoration(
                          label: "Username",
                          prefixIcon: Icons.person_rounded,
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: passCtrl,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: AppTheme.glassInputDecoration(
                          label: "Password",
                          hint: "Minimum 6 characters",
                          prefixIcon: Icons.lock_rounded,
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: contactsCtrl,
                        maxLines: 3,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: AppTheme.glassInputDecoration(
                          label: "Emergency Contacts",
                          hint: "One number per line (max 5)",
                          prefixIcon: Icons.contact_phone_rounded,
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
                          onPressed: _register,
                          style: AppTheme.primaryButtonStyle.copyWith(
                            backgroundColor: WidgetStateProperty.all(Colors.transparent),
                            shadowColor: WidgetStateProperty.all(Colors.transparent),
                          ),
                          child: Text(
                            "REGISTER",
                            style: AppTheme.buttonText,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: AppTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: "Login",
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
