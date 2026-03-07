import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/contact_service.dart';
import '../screens/login_screen.dart';
import '../services/salesforce_auth_services.dart';

class SettingsScreen extends StatefulWidget {
  final bool simulationMode;
  final ValueChanged<bool> onSimulationModeChanged;
  final int userId;
  final List<String> currentContacts;

  const SettingsScreen({
    super.key,
    required this.simulationMode,
    required this.onSimulationModeChanged,
    required this.userId,
    required this.currentContacts,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _simulationMode;
  late List<String> _contacts;
  final TextEditingController _contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _simulationMode = widget.simulationMode;
    _contacts = List.from(widget.currentContacts);
  }

  void _addContact() async {
    final number = _contactController.text.trim();
    if (number.isEmpty) return;

    // In a real app, validate phone number format
    if (_contacts.length >= 5) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Max 5 contacts allowed")));
      return;
    }

    try {
      await ContactService.addContact(widget.userId, number);
      if (!mounted) return;
      setState(() {
        _contacts.add(number);
      });
      _contactController.clear();
      // Only pop if we were showing a dialog, but here we are in settings page.
      // We assume valid input.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error adding contact: $e")));
    }
  }

  void _deleteContact(String number) async {
    try {
      await ContactService.deleteContact(widget.userId, number);
      if (!mounted) return;
      setState(() {
        _contacts.remove(number);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting contact: $e")));
    }
  }

  void _logout() {
    // Clear navigation stack and go to Login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                "Settings",
                style: GoogleFonts.outfit(color: Colors.white),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section: General
                    _sectionHeader("General"),
                    _glassContainer(
                      child: SwitchListTile(
                        title: Text(
                          "Simulation Mode",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          "Simulate drowsiness for testing",
                          style: GoogleFonts.outfit(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        value: _simulationMode,
                        activeThumbColor: Colors.deepPurpleAccent,
                        onChanged: (val) {
                          setState(() {
                            _simulationMode = val;
                          });
                          widget.onSimulationModeChanged(val);
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Section: Emergency Contacts
                    _sectionHeader(
                      "Emergency Contacts (${_contacts.length}/5)",
                    ),
                    _glassContainer(
                      child: Column(
                        children: [
                          ..._contacts.map(
                            (contact) => ListTile(
                              title: Text(
                                contact,
                                style: GoogleFonts.outfit(color: Colors.white),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _deleteContact(contact),
                              ),
                            ),
                          ),
                          if (_contacts.length < 5)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _contactController,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                      ),
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        hintText: "Add phone number...",
                                        hintStyle: const TextStyle(
                                          color: Colors.white38,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle,
                                      color: Colors.deepPurpleAccent,
                                      size: 30,
                                    ),
                                    onPressed: _addContact,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Section: Account
                    _sectionHeader("Account"),
                  _sectionHeader("Account"),
                    _glassContainer(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.cloud_sync,
                              color: Colors.blueAccent,
                            ),
                            title: Text(
                              "Test Salesforce Connection",
                              style: GoogleFonts.outfit(color: Colors.white),
                            ),
                            onTap: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Testing...")),
                              );
                              // Test with dummy data
                              await SalesforceAuthService.createDrowsinessRecord(
                                lat: 37.77,
                                lon: -122.41,
                                riskLevel: "Test Connection",
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Test Sent. Check DEBUG CONSOLE for result.")),
                              );
                            },
                          ),
                          const Divider(color: Colors.white24, height: 1),
                          ListTile(
                            leading: const Icon(
                              Icons.logout,
                              color: Colors.redAccent,
                            ),
                            title: Text(
                              "Sign Out",
                              style: GoogleFonts.outfit(color: Colors.white),
                            ),
                            onTap: _logout,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.deepPurpleAccent,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _glassContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: child,
    );
  }
}
