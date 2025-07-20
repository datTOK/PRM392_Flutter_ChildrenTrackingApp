import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl;
  AuthService({this.baseUrl = 'https://restapi-dy71.onrender.com/api'});

  Future<void> register({required String name, required String email, required String password}) async {
    final url = Uri.parse('$baseUrl/Auth/register');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'text/plain',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    if (!(response.statusCode == 200 || response.statusCode == 201)) {
      try {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Unknown error');
      } catch (_) {
        throw Exception('Registration failed: ${response.reasonPhrase ?? 'Unknown error'} (Status Code: ${response.statusCode})');
      }
    }
  }

  Future<Map<String, String>> login({required String email, required String password}) async {
    final url = Uri.parse('$baseUrl/Auth/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'text/plain',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String? accessToken = responseData['accessToken'];
      if (accessToken != null) {
        // Decode JWT to get userId
        final parts = accessToken.split('.');
        if (parts.length == 3) {
          final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
          final Map<String, dynamic> jwtPayload = json.decode(payload);
          final String? userId = jwtPayload['userId'];
          if (userId != null) {
            return {'accessToken': accessToken, 'userId': userId};
          }
        }
        throw Exception('Login failed: User ID not found in token.');
      } else {
        throw Exception('Login failed: Access token not found.');
      }
    } else {
      throw Exception('Login failed: ${response.reasonPhrase ?? 'Unknown error'}');
    }
  }

  Future<void> logout() async {
    // If you have a logout endpoint, call it here. Otherwise, this is handled client-side.
    // For now, this is a placeholder.
    return;
  }

  Future<Map<String, dynamic>> fetchUserProfile({required String accessToken}) async {
    final url = Uri.parse('$baseUrl/Auth/me');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'text/plain',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      throw Exception('Failed to load profile: ${response.reasonPhrase}');
    }
  }
} 