import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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

  Color _statusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      case 'Doctor_Accepted':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _consultantStatusText(dynamic status) {
    switch (status) {
      case 0:
      case '0':
        return 'Ongoing';
      case 1:
      case '1':
        return 'Completed';
      default:
        return status?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Consultant Details'),
        backgroundColor: Colors.green[400],
        centerTitle: true,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _consultant == null
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info section (left)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.green[100],
                                child: Icon(
                                  Icons.child_care,
                                  color: Colors.green[700],
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                (_consultant!['child']?['name']?.toString() ??
                                    _consultant!['childId']?.toString() ??
                                    'Child'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Doctor: ${_consultant!['doctor']?['name']?.toString() ?? _consultant!['doctorId']?.toString() ?? 'N/A'}',
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
                                      _consultantStatusText(
                                        _consultant!['status'],
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: _statusColor(
                                      _consultantStatusText(
                                        _consultant!['status'],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _formatDate(
                                      _consultant!['createdAt']?.toString(),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              if (_consultantStatusText(
                                        _consultant!['status'],
                                      ) ==
                                      'Completed' &&
                                  _consultant!['rating'] != null)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Rating: ${_consultant!['rating']?.toString() ?? ''}',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              if (_firstMessage != null &&
                                  _firstMessage!['message'] != null &&
                                  _firstMessage!['message']
                                      .toString()
                                      .isNotEmpty)
                                Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'First Message:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _firstMessage!['message']?.toString() ??
                                            '',
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        // Action buttons (right)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.info_outline),
                              label: const Text('View'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[400],
                                foregroundColor: Colors.white,
                                minimumSize: const Size(120, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) => SizedBox(
                                    height: 300,
                                    child: Center(
                                      child: Text(
                                        'View Details screen (to be implemented)',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.forum),
                              label: const Text('Forum'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[400],
                                foregroundColor: Colors.white,
                                minimumSize: const Size(120, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) => SizedBox(
                                    height: 300,
                                    child: Center(
                                      child: Text(
                                        'Forum screen (to be implemented)',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.star),
                              label: const Text('Rating'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber[700],
                                foregroundColor: Colors.white,
                                minimumSize: const Size(120, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) => SizedBox(
                                    height: 300,
                                    child: Center(
                                      child: Text(
                                        'Rating screen (to be implemented)',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.stop_circle),
                              label: const Text('End'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[400],
                                foregroundColor: Colors.white,
                                minimumSize: const Size(120, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) => SizedBox(
                                    height: 300,
                                    child: Center(
                                      child: Text(
                                        'End Consultant screen (to be implemented)',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                );
                              },
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
