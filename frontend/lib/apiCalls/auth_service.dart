import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  // Create an instance of FlutterSecureStorage
  static const storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String dob,
    required String region,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final url = Uri.parse('http://localhost:3020/api/signup');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fname': firstName,
          'lname': lastName,
          'dob': dob,
          'region': region,
          'email': email,
          'tell': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'message': jsonDecode(response.body)['message']};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['error']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email_or_phone,
    required String password,
  }) async {
    try {
      final url = Uri.parse("http://localhost:3020/api/login");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email_or_phone": email_or_phone,
          "password": password,
        }),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        // Store the token securely
        await storage.write(key: 'jwt', value: token);

        return {'success': true, 'verify': true, 'token': token};
      } else if(response.statusCode == 403){
        return {'success': true, 'verify': false };
      } else {
        final error = jsonDecode(response.body)['error'];
        return {'success': false, 'message': error};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyAccount({
    required String code,
  }) async {
    try {
      final url = Uri.parse("http://localhost:3020/api/verify-account");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "token": code,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': jsonDecode(response.body)['message']};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['error']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> resendCode({
    required String email_or_tell,
  }) async {
    try {
      final url = Uri.parse("http://localhost:3020/api/resend-verification");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email_or_phone": email_or_tell,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': jsonDecode(response.body)['message']};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['error']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // A method to retrieve the token for future requests
  static Future<String?> getToken() async {
    return await storage.read(key: 'r');
  }

  // Additional helpful methods for token management
  static Future<void> deleteToken() async {
    await storage.delete(key: 'jwt');
  }

  static Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'jwt');
    return token != null && token.isNotEmpty;
  }

  // Method to logout (clears the token)
  static Future<void> logout() async {
    await storage.delete(key: 'jwt');
  }
}