import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:children_tracking_mobileapp/provider/auth_provider.dart';
import 'package:children_tracking_mobileapp/utils/date_format.dart';
import 'package:children_tracking_mobileapp/utils/mappers.dart'; 

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
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _memberId = auth.userId;
    _accessToken = auth.token;
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
          'https://restapi-dy71.onrender.com/api/Request/member/$_memberId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
          'accept': '*/*',
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded['data'] ?? [];
        setState(() {
          _request = data.firstWhere(
            (req) => req['id'] == widget.requestId,
            orElse: () => null,
          );
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
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Request Details'),
        backgroundColor: Colors.blue[400],
        centerTitle: true,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _request == null
              ? const Center(child: Text('No data found.'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 8,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.lightBlue[100],
                              child: Icon(
                                Icons.child_care,
                                color: Colors.blue[700],
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              (_request!['child']?['name']?.toString() ??
                                  _request!['childId']?.toString() ??
                                  'Child'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Doctor: ${_request!['doctor']?['name']?.toString() ?? _request!['doctorId']?.toString() ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Chip(
                                  label: Text(
                                    // Use statusText to get the string representation for the label
                                    statusText(_request!['status']),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: statusColor(
                                    // Pass the string representation of the status to statusColor
                                    statusText(_request!['status']),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  formatDate(
                                      _request!['createdAt']?.toString()),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (_request!['message'] != null &&
                                _request!['message'].toString().isNotEmpty)
                              Column(
                                children: [
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Message:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _request!['message']?.toString() ?? '',
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}