import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService {
  static const storage = FlutterSecureStorage();
  static const baseUrl = 'http://localhost:3020/api/v1/';

  static Future<Map<String, dynamic>> getUser() async {
    try {
      final token = await storage.read(key: 'jwt');
      if (token == null) throw Exception('Token not found');

      final url = Uri.parse(baseUrl + 'user');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getTarget() async{
    try {
      final token = await storage.read(key: 'jwt');
      if (token == null) throw Exception('Token not found');

      final url = Uri.parse(baseUrl + 'user/target');
      final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          }
      );
      if (response.statusCode == 200)  {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(jsonList);
      } else {
        throw Exception('Failed to fetch user target: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createTarget({
    required String name,
    required double objective,
    required DateTime deadline,
    required double finePercentage, // Changed parameter name for clarity
    required String category,
  }) async {
    try {
      final token = await storage.read(key: 'jwt');
      if (token == null) throw Exception('Token not found');

      final url = Uri.parse(baseUrl + 'user/target');
      final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'name': name,
            'objective': objective,
            'deadline': deadline.toIso8601String(), // Convert DateTime to ISO string
            'fine': finePercentage, // Send percentage, not calculated amount
            'category': category
          })
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

  static Future<Map<String, dynamic>> deposite({
    required int id,
    required double amount,
    required int number
}) async {
    try{
      final token = await storage.read(key: 'jwt');
      if (token == null) throw Exception('Token not found');

      final url = Uri.parse(baseUrl + 'user/pay');
      final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'targetId': id,
            'amount': amount,
            'number': number
          })
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print(response.body);
        print('hello');
        print(data);
        return data;
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['error']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}