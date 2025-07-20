import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:children_tracking_mobileapp/models/growth_models.dart';

class GrowthDataService {
  final String baseUrl;
  GrowthDataService({this.baseUrl = 'https://restapi-dy71.onrender.com/api'});

  Future<List<GrowthData>> fetchGrowthData({required String childId, required String authToken}) async {
    final url = Uri.parse('$baseUrl/GrowthData/child/$childId');
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
            .map((growthJson) => GrowthData.fromJson(growthJson))
            .toList();
      } else {
        throw Exception('Invalid growth data format from API');
      }
    } else {
      throw Exception('Failed to load growth data: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> addGrowthData({
    required String childId,
    required double height,
    required double weight,
    required double headCircumference,
    required double armCircumference,
    required String inputDate,
    required String authToken,
  }) async {
    final url = Uri.parse('$baseUrl/GrowthData?childId=$childId');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'height': height,
        'weight': weight,
        'headCircumference': headCircumference,
        'armCircumference': armCircumference,
        'inputDate': inputDate,
      }),
    );
    if (!(response.statusCode == 200 || response.statusCode == 201)) {
      throw Exception('Failed to add growth data: ${response.statusCode} - ${response.body}');
    }
  }
} 