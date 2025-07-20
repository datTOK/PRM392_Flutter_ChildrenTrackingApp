import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:children_tracking_mobileapp/provider/auth_provider.dart';

class DoctorSelectionPage extends StatefulWidget {
  const DoctorSelectionPage({Key? key}) : super(key: key);

  @override
  State<DoctorSelectionPage> createState() => _DoctorSelectionPageState();
}

class _DoctorSelectionPageState extends State<DoctorSelectionPage> {
  List<dynamic> _doctors = [];
  List<dynamic> _filteredDoctors = [];
  bool _loading = false;
  String _search = '';
  String? _accessToken;
  List<dynamic> _children = [];
  String? _selectedChildId;
  String _message = '';
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchDoctors();
  }

  Future<void> _loadTokenAndFetchDoctors() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _accessToken = auth.token;
    _userId = auth.userId;
    _fetchDoctors();
    _fetchChildren();
  }

  Future<void> _fetchDoctors() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(
        Uri.parse('https://restapi-dy71.onrender.com/api/User/doctors'),
        headers: {
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
          'accept': '*/*',
        },
      );
      print('[DEBUG] Doctor API response: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('[DEBUG] Doctor data: ' + decoded.toString());
        setState(() {
          _doctors = decoded['data'] ?? [];
          _filteredDoctors = _doctors;
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchChildren() async {
    if (_userId == null) return;
    try {
      final response = await http.get(
        Uri.parse('https://restapi-dy71.onrender.com/api/Child/user/$_userId'),
        headers: {
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
          'accept': '*/*',
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          _children = decoded['data'] ?? [];
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _search = value;
      _filteredDoctors = _doctors.where((doc) {
        final name = doc['name']?.toString().toLowerCase() ?? '';
        return name.contains(_search.toLowerCase());
      }).toList();
    });
  }

  void _showRequestConsultantSheet(
    BuildContext context,
    String doctorId,
    String doctorName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request Consultant for Dr. $doctorName',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedChildId,
                    items: _children.map<DropdownMenuItem<String>>((child) {
                      return DropdownMenuItem<String>(
                        value: child['id']?.toString(),
                        child: Text(child['name']?.toString() ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() => _selectedChildId = value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Select Child',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Message to doctor',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setModalState(() => _message = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _sendConsultantRequest(context, doctorId);
                      },
                      child: const Text('Send Request'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _sendConsultantRequest(
    BuildContext context,
    String doctorId,
  ) async {
    if (_selectedChildId == null || _message.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a child and enter a message.'),
        ),
      );
      return;
    }
    final requestBody = {
      'childId': _selectedChildId,
      'doctorId': doctorId,
      'message': _message,
    };
    print('[DEBUG] Sending request body: ' + requestBody.toString());
    try {
      final response = await http.post(
        Uri.parse('https://restapi-dy71.onrender.com/api/Request'),
        headers: {
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      print('[DEBUG] Status code: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send request: ${response.body}')),
        );
      }
    } catch (e) {
      print('[DEBUG] Exception: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildStarRating(double rating) {
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.amber, size: 18);
        } else if (index == fullStars && halfStar) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 18);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 18);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Doctor')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by doctor name...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                    itemCount: _filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = _filteredDoctors[index];
                      final rating = (doctor['rating'] is num)
                          ? (doctor['rating'] as num).toDouble()
                          : 0.0;
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 4,
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Doctor',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                doctor['name']?.toString() ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                doctor['email']?.toString() ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              _buildStarRating(rating),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.add_comment),
                                  label: const Text('Request Consultant'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ), // Slight roundness
                                    ),
                                  ),
                                  onPressed: () {
                                    _showRequestConsultantSheet(
                                      context,
                                      doctor['id']?.toString() ?? '',
                                      doctor['name']?.toString() ?? '',
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
