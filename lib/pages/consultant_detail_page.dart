import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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
    print('[DEBUG] _fetchConsultantDetail called');
    if (_memberId == null) return;
    setState(() => _loading = true);
    try {
      final url =
          'https://restapi-dy71.onrender.com/api/Consultation/member/$_memberId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
          'accept': '*/*',
        },
      );
      print('[DEBUG] Consultant API response: ${response.body}');
      print('[DEBUG] Looking for consultant id: ${widget.consultantId}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded['data'] ?? [];
        setState(() {
          _consultant = data.firstWhere(
            (c) => c['id'] == widget.consultantId,
            orElse: () => null,
          );
        });
        print('[DEBUG] Consultant found: ${_consultant != null}');
        if (_consultant != null) {
          print('[DEBUG] Consultant rating: ${_consultant!['rating']}');
        }
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
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) => SingleChildScrollView(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top: 24,
                                        bottom:
                                            MediaQuery.of(
                                              context,
                                            ).viewInsets.bottom +
                                            24,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      (_consultant!['child']?['name']
                                                              ?.toString() ??
                                                          _consultant!['childId']
                                                              ?.toString() ??
                                                          'Consultant'),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      _formatDate(
                                                        _consultant!['createdAt']
                                                            ?.toString(),
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
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
                                            ],
                                          ),
                                          const SizedBox(height: 18),
                                          // Rating
                                          if (_consultant!['rating'] != null)
                                            _InfoBox(
                                              label: 'Rating',
                                              value: _consultant!['rating']
                                                  .toString(),
                                            ),
                                          // Member Info
                                          if (_consultant!['member'] != null)
                                            _InfoBox(
                                              label: 'Member Information',
                                              value:
                                                  '${_consultant!['member']['name'] ?? ''}\n${_consultant!['member']['email'] ?? ''}',
                                            ),
                                          // Doctor Info
                                          if (_consultant!['doctor'] != null)
                                            _InfoBox(
                                              label: 'Doctor Information',
                                              value:
                                                  '${_consultant!['doctor']['name'] ?? ''}\n${_consultant!['doctor']['email'] ?? ''}',
                                            ),
                                          // Child Info
                                          if (_consultant!['child'] != null)
                                            _InfoBox(
                                              label: 'Child Information',
                                              value:
                                                  _consultant!['child']['name']
                                                      ?.toString() ??
                                                  '',
                                            ),
                                          // Timestamps
                                          _InfoBox(
                                            label: 'Timestamps',
                                            value:
                                                'Created: ${_formatDate(_consultant!['createdAt']?.toString())}\nUpdated: ${_formatDate(_consultant!['updatedAt']?.toString())}',
                                          ),
                                          // ConsultantId
                                          _InfoBox(
                                            label: 'Consultant ID',
                                            value:
                                                _consultant!['id']
                                                    ?.toString() ??
                                                '',
                                          ),
                                          // Request message
                                          if (_consultant!['message'] != null &&
                                              _consultant!['message']
                                                  .toString()
                                                  .isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 18.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Request Message:',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Container(
                                                    width: double.infinity,
                                                    padding:
                                                        const EdgeInsets.all(
                                                          12,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      _consultant!['message']
                                                          .toString(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
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
                              onPressed:
                                  _consultantStatusText(
                                        _consultant!['status'],
                                      ) ==
                                      'Completed'
                                  ? () => ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'This consultation has ended. Forum is no longer accessible.',
                                            ),
                                          ),
                                        )
                                  : () => showForumModal(
                                      context,
                                      _consultant!['id']?.toString() ?? '',
                                      _consultant!['message']?.toString() ?? '',
                                    ),
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
                              onPressed:
                                  _consultantStatusText(
                                        _consultant!['status'],
                                      ) !=
                                      'Completed'
                                  ? () => ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'You can only rate after the consultation is completed.',
                                            ),
                                          ),
                                        )
                                  : () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        builder: (context) => _RatingModal(
                                          consultationId:
                                              _consultant!['id']?.toString() ??
                                              '',
                                          accessToken: _accessToken,
                                          initialRating:
                                              (_consultant!['rating'] is num)
                                              ? (_consultant!['rating'] as num)
                                                    .toDouble()
                                              : 0.0,
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
                              onPressed: () async {
                                try {
                                  final response = await http.patch(
                                    Uri.parse(
                                      'https://restapi-dy71.onrender.com/api/Consultation/${_consultant!['id']}/status',
                                    ),
                                    headers: {
                                      if (_accessToken != null)
                                        'Authorization': 'Bearer $_accessToken',
                                      'accept': '*/*',
                                      'Content-Type': 'application/json',
                                    },
                                    body: jsonEncode({'status': 'Completed'}),
                                  );
                                  print(
                                    '[DEBUG] PATCH /api/Consultation/${_consultant!['id']}/status status: ${response.statusCode}',
                                  );
                                  print(
                                    '[DEBUG] Response body: ${response.body}',
                                  );
                                  if (response.statusCode == 200) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Consultant ended successfully!',
                                        ),
                                      ),
                                    );
                                    setState(() {
                                      _consultant!['status'] =
                                          1; // Mark as completed in UI
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to end consultant: ${response.body}',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
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

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  const _InfoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

void showForumModal(
  BuildContext context,
  String consultationId,
  String requestMessage,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
        Navigator.of(context).maybePop();
      },
      child: GestureDetector(
        onTap:
            () {}, // Prevent tap events from propagating to the outer GestureDetector
        child: _ForumModal(
          consultationId: consultationId,
          requestMessage: requestMessage,
        ),
      ),
    ),
  );
}

class _ForumModal extends StatefulWidget {
  final String consultationId;
  final String requestMessage;
  const _ForumModal({
    required this.consultationId,
    required this.requestMessage,
  });

  @override
  State<_ForumModal> createState() => _ForumModalState();
}

class _ForumModalState extends State<_ForumModal> {
  List<dynamic> _messages = [];
  bool _loading = false;
  String? _accessToken;
  String? _userId;
  String? _userName;
  String? _userRole;
  String _input = '';
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadUserAndFetchMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndFetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _userId = prefs.getString('userId');
    _userName = prefs.getString('userName');
    _userRole = prefs.getString('userRole');
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final response = await http.get(
        Uri.parse(
          'https://restapi-dy71.onrender.com/api/ConsultationMessage/consultation/${widget.consultationId}',
        ),
        headers: {
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
          'accept': '*/*',
        },
      );
      print(
        '[DEBUG] GET /api/ConsultationMessage/consultation/${widget.consultationId} status: ${response.statusCode}',
      );
      print('[DEBUG] Response body: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List messages = decoded['data'] ?? [];
        if (mounted) {
          setState(() {
            _messages = messages;
            _messages.sort(
              (a, b) => DateTime.parse(
                a['createdAt'],
              ).compareTo(DateTime.parse(b['createdAt'])),
            );
          });
        }
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _postMessage() async {
    if (_input.trim().isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse('https://restapi-dy71.onrender.com/api/ConsultationMessage'),
        headers: {
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': _input,
          'consultationId': widget.consultationId,
        }),
      );
      print(
        '[DEBUG] POST /api/ConsultationMessage status: ${response.statusCode}',
      );
      print('[DEBUG] Response body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          setState(() {
            _input = '';
            _controller.clear();
          });
          _fetchMessages();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to post message: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _endConsultant() async {
    try {
      final response = await http.patch(
        Uri.parse(
          'https://restapi-dy71.onrender.com/api/Consultation/${widget.consultationId}/status',
        ),
        headers: {
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': 'Completed'}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consultant ended successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to end consultant: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.requestMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Request Message: ${widget.requestMessage}'),
                ),
              ),
            const SizedBox(height: 8),
            // Chat box
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6.0,
                              horizontal: 2,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.blue[100],
                                  child: Text(
                                    (msg['sender']?['name']?.toString() ??
                                        'U')[0],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              msg['sender']?['name']
                                                      ?.toString() ??
                                                  'Unknown',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.green[200],
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                msg['sender']?['role']
                                                        ?.toString() ??
                                                    '',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              _formatDate(
                                                msg['createdAt']?.toString(),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(msg['message']?.toString() ?? ''),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Ask or post a question ...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _input = value),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _postMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Post'),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _RatingModal extends StatefulWidget {
  final String consultationId;
  final String? accessToken;
  final double initialRating;
  const _RatingModal({
    required this.consultationId,
    required this.accessToken,
    required this.initialRating,
  });

  @override
  State<_RatingModal> createState() => _RatingModalState();
}

class _RatingModalState extends State<_RatingModal> {
  double _rating = 0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  Future<void> _submitRating() async {
    setState(() => _submitting = true);
    try {
      final response = await http.patch(
        Uri.parse(
          'https://restapi-dy71.onrender.com/api/Consultation/${widget.consultationId}/rating',
        ),
        headers: {
          if (widget.accessToken != null)
            'Authorization': 'Bearer ${widget.accessToken}',
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'rating': _rating.toInt()}),
      );
      print(
        '[DEBUG] PATCH /api/Consultation/${widget.consultationId}/rating status: ${response.statusCode}',
      );
      print('[DEBUG] Response body: ${response.body}');
      if (response.statusCode == 200) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thank you!'),
            content: Text(
              'Your rating of ${_rating.toInt()} stars has been submitted.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit rating: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _submitting = false);
    }
  }

  Widget _buildStar(int value) {
    IconData icon = _rating >= value ? Icons.star : Icons.star_border;
    return GestureDetector(
      onTap: () => setState(() => _rating = value.toDouble()),
      child: Icon(icon, color: Colors.amber[700], size: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 32,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Rate this Consultation',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => _buildStar(index + 1)),
            ),
            const SizedBox(height: 10),
            Text(
              '${_rating.toInt()} / 5',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Rating',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
