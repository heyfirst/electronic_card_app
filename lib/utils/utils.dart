import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

// Token storage keys
const String tokenKey = 'guest_token';
const String usernameKey = 'guest_username';

// Custom exception for token generation with detailed error info
class TokenGenerationException implements Exception {
  final int statusCode;
  final String responseBody;

  TokenGenerationException(this.statusCode, this.responseBody);

  @override
  String toString() => 'TokenGenerationException: $statusCode - $responseBody';
}

class TokenUtils {
  // Token management methods
  static Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(tokenKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting stored token: $e');
      }
      return null;
    }
  }

  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, token);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving token: $e');
      }
    }
  }

  static Future<void> clearStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      await prefs.remove(usernameKey);
      if (kDebugMode) {
        debugPrint('Token cleared from storage');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing token: $e');
      }
    }
  }

  static Future<String> generateGuestToken() async {
    try {
      if (kDebugMode) {
        debugPrint('Generating guest token...');
      }
      final response = await http
          .post(
            Uri.parse(ApiConfig.guestTokens),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint('Token generation response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        if (kDebugMode) {
          debugPrint('Token generated successfully');
        }
        return token;
      } else {
        if (kDebugMode) {
          debugPrint('Token generation failed: ${response.body}');
        }

        // For 403 errors, include the response body for special handling in wishes.dart
        if (response.statusCode == 403) {
          throw TokenGenerationException(response.statusCode, response.body);
        }

        throw Exception('ไม่สามารถสร้าง token ได้: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error generating token: $e');
      }
      rethrow;
    }
  }

  static Future<String> getOrGenerateToken() async {
    String? token = await getStoredToken();
    if (token == null) {
      token = await generateGuestToken();
      await saveToken(token);
    }
    return token;
  }

  // Check token allowdate - this can be implemented based on your specific requirements
  static Future<void> checkTokenAllowDate() async {
    // Implementation depends on your specific requirements
    // This is a placeholder that can be customized as needed
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.guestTokens),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getOrGenerateToken()}',
        },
      );

      if (response.statusCode == 200) {
        // Process allowdate logic here if needed
        if (kDebugMode) {
          debugPrint('Token allowdate check successful');
        }
      } else if (response.statusCode == 403) {
        final data = json.decode(response.body);
        if (kDebugMode) {
          debugPrint('Token allowdate check forbidden: ${data['message']}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking token allowdate: $e');
      }
    }
  }
}
