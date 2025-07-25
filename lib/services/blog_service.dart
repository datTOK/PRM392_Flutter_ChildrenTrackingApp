import 'dart:convert';
import 'package:http/http.dart' as http;

class BlogService {
  final String baseUrl;
  BlogService({this.baseUrl = 'https://restapi-dy71.onrender.com/api'});

  Future<List<dynamic>> fetchBlogPosts() async {
    final String apiUrl = '$baseUrl/Blog';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'text/plain',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData['data'] ?? [];
    } else {
      throw Exception('Failed to load blog posts: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>?> fetchBlogDetail(String blogId) async {
    final String apiUrl = '$baseUrl/Blog/$blogId';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'text/plain',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData['blog'];
    } else {
      throw Exception('Failed to load blog details: ${response.reasonPhrase}');
    }
  }
} 