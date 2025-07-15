import 'package:children_tracking_mobileapp/pages/child_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:children_tracking_mobileapp/pages/add_child_page.dart';

// Data model for a Child (based on your API response)
class Child {
  final String id;
  final String name;
  final DateTime birthDate;
  final String note;
  final int gender;
  final int feedingType;
  final List<int> allergies;
  final String guardianId;

  Child({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.note,
    required this.gender,
    required this.feedingType,
    required this.allergies,
    required this.guardianId,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      name: json['name'],
      birthDate: DateTime.parse(json['birthDate']),
      note: json['note'] ?? 'N/A', // Handle potentially null note
      gender: json['gender'],
      feedingType: json['feedingType'],
      allergies: List<int>.from(json['allergies'] ?? []),
      guardianId: json['guardianId'],
    );
  }
}

class ChildPage extends StatefulWidget {
  const ChildPage({super.key});

  @override
  State<ChildPage> createState() => _ChildPageState();
}

class _ChildPageState extends State<ChildPage> {
  List<Child> _children = [];
  bool _isLoading = true;
  String? _errorMessage;

  String? _userId;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadAuthDataAndFetchChildren(); // New method to load data first
  }

  Future<void> _loadAuthDataAndFetchChildren() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('accessToken');
    _userId = prefs.getString('userId');

    if (_authToken == null || _userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Authentication data not found. Please log in again.';
      });
      // Optionally navigate back to login page
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      return;
    }
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Ensure userId and authToken are available before making the call
    if (_userId == null || _authToken == null) {
      setState(() {
        _errorMessage = 'Authentication data is missing. Cannot fetch children.';
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('https://restapi-dy71.onrender.com/api/Child/user/$_userId');
    try {
      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] is List) {
          setState(() {
            _children = (responseData['data'] as List)
                .map((childJson) => Child.fromJson(childJson))
                .toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Invalid data format from API';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load children: ${response.statusCode} - ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  // Helper to map gender int to a display string (you'll need to define your mappings)
  String _getGenderString(int genderInt) {
    switch (genderInt) {
      case 0: return 'Male';
      case 1: return 'Female';
      case 2: return 'Other';
      default: return 'Unknown';
    }
  }

  String _getFeedingTypeString(int feedingTypeInt) {
    switch (feedingTypeInt) {
      case 0: return 'Breastfeeding';
      case 1: return 'Formula';
      case 2: return 'Mixed';
      case 3: return 'Solid Foods';
      default: return 'Unknown';
    }
  }

  String _getAllergiesString(List<int> allergies) {
    if (allergies.isEmpty) return 'None';
    Map<int, String> allergyMap = {
      0: 'Cow\'s Milk',
      1: 'Eggs',
      2: 'Peanuts',
      3: 'Tree Nuts',
      4: 'Soy',
      5: 'Wheat',
      6: 'Fish',
      7: 'Shellfish',
    };
    return allergies.map((id) => allergyMap[id] ?? 'Unknown').join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min, 
          children: [
            const Text(
              'Your Children',
            ),
            const SizedBox(width: 5), 
            Lottie.network(
              'https://lottie.host/13656411-0ba0-4803-a4a3-c210c69e6830/Do97hU6owW.json', 
              height: 60, 
              width: 40, 
              repeat: true,
              animate: true,
              reverse: true
            ),
          ],
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        toolbarHeight: 60, 
        elevation: 5.00,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: $_errorMessage',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadAuthDataAndFetchChildren, // Retry will re-load auth data
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _children.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No children added yet.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Tap the + button to add a child!',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _children.length,
                      itemBuilder: (context, index) {
                        final child = _children[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChildDetailPage(childId: child.id),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    child.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Birth Date: ${child.birthDate.toLocal().toString().split(' ')[0]}'),
                                  Text('Gender: ${_getGenderString(child.gender)}'),
                                  Text('Feeding Type: ${_getFeedingTypeString(child.feedingType)}'),
                                  Text('Allergies: ${_getAllergiesString(child.allergies)}'),
                                  if (child.note.isNotEmpty && child.note != 'N/A') // Check for 'N/A' as well
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text('Note: ${child.note}', style: const TextStyle(fontStyle: FontStyle.italic)),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddChildPage()),
          );
          if (result == true) {
            _fetchChildren(); 
          }
        },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}