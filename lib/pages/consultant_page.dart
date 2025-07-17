import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:children_tracking_mobileapp/pages/request_detail_page.dart';
import 'package:children_tracking_mobileapp/pages/consultant_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsultantPage extends StatefulWidget {
  const ConsultantPage({Key? key}) : super(key: key);

  @override
  State<ConsultantPage> createState() => _ConsultantPageState();
}

class _ConsultantPageState extends State<ConsultantPage> {
  bool _requestsExpanded = false;
  bool _consultantsExpanded = false;
  List<dynamic> _requests = [];
  List<dynamic> _consultants = [];
  bool _loadingRequests = false;
  bool _loadingConsultants = false;
  int _requestPage = 1;
  int _consultantPage = 1;
  final int _pageSize = 10;
  String _requestSearch = '';
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
    // Now call your fetch methods
    _fetchRequests();
    _fetchConsultants();
  }

  Future<void> _fetchRequests() async {
    if (_memberId == null) return;
    setState(() => _loadingRequests = true);
    try {
      final queryParams =
          '?page=$_requestPage&size=$_pageSize' +
          (_requestSearch.isNotEmpty ? '&search=$_requestSearch' : '');
      final url =
          'https://restapi-dy71.onrender.com/api/Request/member/$_memberId$queryParams';
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
          _requests = decoded['data'] ?? [];
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _loadingRequests = false);
    }
  }

  Future<void> _fetchConsultants() async {
    if (_memberId == null) return;
    setState(() => _loadingConsultants = true);
    try {
      final queryParams = '?page=$_consultantPage&size=$_pageSize';
      final url =
          'https://restapi-dy71.onrender.com/api/Consultation/member/$_memberId$queryParams';
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
          _consultants = decoded['data'] ?? [];
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _loadingConsultants = false);
    }
  }

  void _navigateToDoctorSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DoctorSelectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultant'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search requests...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _requestSearch = value;
                    _requestPage = 1;
                  });
                  _fetchRequests();
                },
              ),
              const SizedBox(height: 8),
              _buildDropdownBar(
                title: 'Requests',
                expanded: _requestsExpanded,
                onTap: () =>
                    setState(() => _requestsExpanded = !_requestsExpanded),
                loading: _loadingRequests,
                items: _requests,
                itemBuilder: (item) => _RequestCard(item: item),
                page: _requestPage,
                onPrev: () {
                  setState(() {
                    _requestPage--;
                  });
                  _fetchRequests();
                },
                onNext: () {
                  setState(() {
                    _requestPage++;
                  });
                  _fetchRequests();
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownBar(
                title: 'Consultants',
                expanded: _consultantsExpanded,
                onTap: () => setState(
                  () => _consultantsExpanded = !_consultantsExpanded,
                ),
                loading: _loadingConsultants,
                items: _consultants,
                itemBuilder: (item) => _ConsultantCard(item: item),
                page: _consultantPage,
                onPrev: () {
                  setState(() {
                    _consultantPage--;
                  });
                  _fetchConsultants();
                },
                onNext: () {
                  setState(() {
                    _consultantPage++;
                  });
                  _fetchConsultants();
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline, size: 28),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Contact our Doctors',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                onPressed: _navigateToDoctorSelection,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownBar({
    required String title,
    required bool expanded,
    required VoidCallback onTap,
    required bool loading,
    required List items,
    required Widget Function(dynamic) itemBuilder,
    int? page,
    VoidCallback? onPrev,
    VoidCallback? onNext,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
            onTap: onTap,
          ),
          if (expanded)
            loading
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    children: [
                      if (items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No data found.'),
                        )
                      else
                        ...items.map(itemBuilder).toList(),
                      if (page != null && onPrev != null && onNext != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: page > 1 ? onPrev : null,
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(12),
                                ),
                                child: const Icon(Icons.chevron_left),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Text(
                                  'Page $page',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: items.length == _pageSize
                                    ? onNext
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(12),
                                ),
                                child: const Icon(Icons.chevron_right),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final dynamic item;
  const _RequestCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.request_page, color: Colors.blue),
      title: Text(
        'Doctor: ${item['doctor']?['name']?.toString() ?? item['doctorId']?.toString() ?? 'N/A'}',
      ),
      subtitle: Text('Status: ${statusText(item['status'])}'),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RequestDetailPage(requestId: item['_id'] ?? item['id']),
            ),
          );
        },
      ),
    );
  }
}

class _ConsultantCard extends StatelessWidget {
  final dynamic item;
  const _ConsultantCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.medical_services, color: Colors.green),
      title: Text(
        'Doctor: ${item['doctor']?['name']?.toString() ?? item['doctorId']?.toString() ?? 'N/A'}',
      ),
      subtitle: Text(
        'Status: ${consultantStatusText(item['status'])}\nCreated: ${item['createdAt']?.toString() ?? ''}',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ConsultantDetailPage(consultantId: item['_id'] ?? item['id']),
            ),
          );
        },
      ),
    );
  }
}

String statusText(dynamic status) {
  switch (status) {
    case 0:
    case '0':
      return 'Pending';
    case 1:
    case '1':
      return 'Admin_Rejected';
    case 2:
    case '2':
      return 'Admin_Accepted';
    case 3:
    case '3':
      return 'Doctor_Accepted';
    case 4:
    case '4':
      return 'Doctor_Rejected';
    default:
      return status?.toString() ?? '';
  }
}

String consultantStatusText(dynamic status) {
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

// Placeholder for doctor selection page
class DoctorSelectionPage extends StatelessWidget {
  const DoctorSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Doctor')),
      body: const Center(child: Text('Doctor list will be shown here.')),
    );
  }
}
