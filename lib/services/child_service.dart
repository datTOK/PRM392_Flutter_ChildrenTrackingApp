import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:children_tracking_mobileapp/models/child_models.dart';

class ChildService {
  final String baseUrl;
  ChildService({this.baseUrl = 'https://restapi-dy71.onrender.com/api'});

  Future<List<Child>> fetchChildren({required String userId, required String authToken}) async {
    final url = Uri.parse('$baseUrl/Child/user/$userId');
    final response = await http.get(
      url,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $authToken',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['data'] is List) {
        return (responseData['data'] as List)
            .map((childJson) => Child.fromJson(childJson))
            .toList();
      } else {
        throw Exception('Invalid data format from API');
      }
    } else {
      throw Exception('Failed to load children: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Child> fetchChildById({required String childId, required String authToken}) async {
    final url = Uri.parse('$baseUrl/Child/$childId');
    final response = await http.get(
      url,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $authToken',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['child'] != null) {
        return Child.fromJson(responseData['child']);
      } else {
        throw Exception('Child data not found in API response.');
      }
    } else {
      throw Exception('Failed to load child details: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> addChild({
    required String name,
    required int gender,
    required String birthDate,
    required String note,
    required int feedingType,
    required List<int> allergies,
    required String authToken,
  }) async {
    final url = Uri.parse('$baseUrl/Child');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'name': name,
        'gender': gender,
        'birthDate': birthDate,
        'note': note,
        'feedingType': feedingType,
        'allergies': allergies,
      }),
    );
    if (!(response.statusCode == 200 || response.statusCode == 201)) {
      throw Exception('Failed to add child: ${response.statusCode} - ${response.body}');
    }
  }
} 