import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/secrets.dart';

void main() async {
  print("--- STARTING ADVANCED DIAGNOSTIC v2.0 ---");
  
  // TRIM EVERYTHING to remove accidental spaces
  final cId = SALESFORCE_CLIENT_ID.trim();
  final cSecret = SALESFORCE_CLIENT_SECRET.trim();
  final username = SALESFORCE_USERNAME.trim();
  final password = SALESFORCE_PASSWORD.trim();
  final token = SALESFORCE_SECURITY_TOKEN.trim();

  print("\n1. Testing against PRODUCTION (login.salesforce.com)...");
  await tryLogin("https://login.salesforce.com/services/oauth2/token", cId, cSecret, username, password + token);

  print("\n2. Testing against SANDBOX (test.salesforce.com)...");
  await tryLogin("https://test.salesforce.com/services/oauth2/token", cId, cSecret, username, password + token);

  print("\n--------------------------------------");
  print("DIAGNOSTIC COMPLETE");
}

Future<void> tryLogin(String url, String cId, String cSecret, String uName, String pWord) async {
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "grant_type": "password",
        "client_id": cId,
        "client_secret": cSecret,
        "username": uName,
        "password": pWord,
      },
    );

    if (response.statusCode == 200) {
      print("   [SUCCESS] Logged in successfully!");
      print("   Access Token received.");
    } else {
      print("   [FAILED] Status: ${response.statusCode}");
      try {
        final err = jsonDecode(response.body);
        print("   Error: ${err['error']} - ${err['error_description']}");
      } catch (e) {
        print("   Response: ${response.body}");
      }
    }
  } catch (e) {
    print("   [ERROR] Connection failed: $e");
  }
}
