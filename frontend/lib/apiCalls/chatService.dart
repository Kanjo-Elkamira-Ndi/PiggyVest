import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  // Change this to your actual API URL
  static const String baseUrl = 'http://localhost:8000';

  // For Android emulator, use: http://10.0.2.2:8000
  // For iOS simulator, use: http://localhost:8000
  // For physical device, use your computer's IP: http://192.168.1.XXX:8000

  static Future<Map<String, dynamic>> sendMessage(String question) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'question': question,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> sendFeedback(
      String question,
      String correctAnswer,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/feedback'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'question': question,
          'correct_answer': correctAnswer,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  static Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}