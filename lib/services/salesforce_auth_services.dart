import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../secrets.dart';

class SalesforceAuthService {
  static String? _accessToken;
  static String? _instanceUrl;

  /// Authenticates with Salesforce and retrieves the Access Token.
  static Future<bool> authenticate() async {
    try {
      final response = await http.post(
        Uri.parse("https://login.salesforce.com/services/oauth2/token"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "grant_type": "password",
          "client_id": SALESFORCE_CLIENT_ID,
          "client_secret": SALESFORCE_CLIENT_SECRET,
          "username": SALESFORCE_USERNAME,
          "password": "$SALESFORCE_PASSWORD$SALESFORCE_SECURITY_TOKEN",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        _instanceUrl = data['instance_url'];
        debugPrint("Salesforce Auth Success. Instance: $_instanceUrl");
        return true;
      } else {
        debugPrint("Salesforce Auth Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Salesforce Auth Error: $e");
      return false;
    }
  }

  /// Creates a Drowsiness_Log__c record in Salesforce.
  static Future<void> createDrowsinessRecord({
    required double lat,
    required double lon,
    required String riskLevel,
  }) async {
    if (_accessToken == null) {
      final success = await authenticate();
      if (!success) return;
    }

    try {
      final uri = Uri.parse("$_instanceUrl/services/data/v60.0/sobjects/Drowsiness_Log__c");
      
      final body = {
        "Location__Latitude__s": lat,
        "Location__Longitude__s": lon,
        "Risk_Level__c": riskLevel,
        "Timestamp__c": DateTime.now().toIso8601String(),
        // Add User_ID__c if you have a field for it
      };

      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $_accessToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        debugPrint("Salesforce Record Created Successfully: ${response.body}");
      } else if (response.statusCode == 401) {
        // Token might be expired, retry once
        debugPrint("Salesforce Token Expired. Retrying...");
        _accessToken = null;
        await createDrowsinessRecord(lat: lat, lon: lon, riskLevel: riskLevel);
      } else {
        debugPrint("================ SALESFORCE ERROR ================");
        debugPrint("Status Code: ${response.statusCode}");
        debugPrint("Response Body: ${response.body}");
        debugPrint("==================================================");
      }
    } catch (e) {
      debugPrint("Error creating Salesforce record: $e");
    }
  }
  
  // Kept for backward compatibility if needed, but redirects to authenticate
  static Future<void> generateToken() async {
    await authenticate();
  }
}

