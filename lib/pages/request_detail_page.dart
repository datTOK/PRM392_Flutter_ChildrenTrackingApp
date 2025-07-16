import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RequestDetailPage extends StatefulWidget {
  final String requestId;
  const RequestDetailPage({Key? key, required this.requestId})
    : super(key: key);

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  Map<String, dynamic>? _request;
  bool _loading = false;
  String? _memberId;
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _loadMemberIdAndFetch();
  }

  Future<void> _loadMemberIdAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    _memberId = prefs.getString('userId');
    _accessToken = prefs.getString('accessToken');
    if (_memberId == null) {
      // Handle not logged in
      return;
    }
    _fetchRequestDetail();
  }

  Future<void> _fetchRequestDetail() async {
    if (_memberId == null) return;
    setState(() => _loading = true);
    try {
      final url =
          'https://restapi-dy71.onrender.com/api/Request/member/$_memberId?id=${widget.requestId}';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
          'accept': '*/*',
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          _request = (decoded['data'] as List?)?.isNotEmpty == true
              ? decoded['data'][0]
              : null;
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Details')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _request == null
          ? const Center(child: Text('No data found.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Doctor: ${_request!['doctorId'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Child: ${_request!['childId'] ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      Text('Message: ${_request!['message'] ?? ''}'),
                      const SizedBox(height: 8),
                      Text('Status: ${_request!['status'] ?? ''}'),
                      const SizedBox(height: 8),
                      Text('Created: ${_request!['createdAt'] ?? ''}'),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
