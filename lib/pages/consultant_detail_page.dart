import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ConsultantDetailPage extends StatefulWidget {
  final String consultantId;
  const ConsultantDetailPage({Key? key, required this.consultantId})
    : super(key: key);

  @override
  State<ConsultantDetailPage> createState() => _ConsultantDetailPageState();
}

class _ConsultantDetailPageState extends State<ConsultantDetailPage> {
  Map<String, dynamic>? _consultant;
  Map<String, dynamic>? _firstMessage;
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
    _fetchConsultantDetail();
    _fetchFirstMessage();
  }

  Future<void> _fetchConsultantDetail() async {
    if (_memberId == null) return;
    setState(() => _loading = true);
    try {
      final url =
          'https://restapi-dy71.onrender.com/api/Consultation/member/$_memberId?id=${widget.consultantId}';
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
          _consultant = (decoded['data'] as List?)?.isNotEmpty == true
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

  Future<void> _fetchFirstMessage() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://restapi-dy71.onrender.com/api/ConsultationMessage/consultation/${widget.consultantId}',
        ),
      );
      if (response.statusCode == 200) {
        final messages = jsonDecode(response.body);
        if (messages is List && messages.isNotEmpty) {
          setState(() {
            _firstMessage = messages[0];
          });
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultant Details')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _consultant == null
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
                        'Consultant ID: ${_consultant!['_id'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Doctor: ${_consultant!['doctor']?['name'] ?? _consultant!['doctorId'] ?? 'N/A'}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Child: ${_consultant!['child']?['name'] ?? _consultant!['childId'] ?? 'N/A'}',
                      ),
                      const SizedBox(height: 8),
                      Text('Status: ${_consultant!['status'] ?? ''}'),
                      const SizedBox(height: 8),
                      if (_consultant!['status'] == 'Completed')
                        Text('Rating: ${_consultant!['rating'] ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      Text('Created: ${_consultant!['createdAt'] ?? ''}'),
                      const SizedBox(height: 8),
                      Text('Updated: ${_consultant!['updatedAt'] ?? ''}'),
                      const SizedBox(height: 8),
                      if (_firstMessage != null)
                        Text(
                          'First Message: ${_firstMessage!['message'] ?? ''}',
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
