import 'package:children_tracking_mobileapp/pages/child_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:children_tracking_mobileapp/services/child_service.dart'; 
import 'package:children_tracking_mobileapp/pages/add_child_page.dart';
import 'package:children_tracking_mobileapp/models/child_models.dart';
import 'package:provider/provider.dart';
import 'package:children_tracking_mobileapp/provider/auth_provider.dart';
import 'package:children_tracking_mobileapp/components/custom_app_bar.dart';

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

  late final ChildService _childService = ChildService();

  @override
  void initState() {
    super.initState();
    _loadAuthDataAndFetchChildren(); // New method to load data first
  }

  Future<void> _loadAuthDataAndFetchChildren() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _authToken = auth.token;
    _userId = auth.userId;

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
    if (_userId == null || _authToken == null) {
      setState(() {
        _errorMessage = 'Authentication data is missing. Cannot fetch children.';
        _isLoading = false;
      });
      return;
    }
    try {
      final children = await _childService.fetchChildren(userId: _userId!, authToken: _authToken!);
      setState(() {
        _children = children;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

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
      appBar: const CustomAppBar(
        title: 'Your Children',
        icon: Icons.child_care,
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
                          Icon(Icons.child_care, size: 64, color: Colors.blueAccent),
                          const SizedBox(height: 18),
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
                        IconData genderIcon;
                        Color genderColor;
                        switch (child.gender) {
                          case 0:
                            genderIcon = Icons.male;
                            genderColor = Colors.blueAccent;
                            break;
                          case 1:
                            genderIcon = Icons.female;
                            genderColor = Colors.pinkAccent;
                            break;
                          case 2:
                            genderIcon = Icons.transgender;
                            genderColor = Colors.purpleAccent;
                            break;
                          default:
                            genderIcon = Icons.help_outline;
                            genderColor = Colors.grey;
                        }
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChildDetailPage(childId: child.id),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade100.withOpacity(0.18),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              color: Colors.blue.shade50, // Use a light blue background instead of white
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Gender avatar
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundColor: genderColor.withOpacity(0.15),
                                          child: Icon(genderIcon, color: genderColor, size: 32),
                                        ),
                                        const SizedBox(width: 18),
                                        // Child info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                child.name,
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Birth Date: ${child.birthDate.toLocal().toString().split(' ')[0]}',
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(genderIcon, color: genderColor, size: 18),
                                                  const SizedBox(width: 6),
                                                  Text(_getGenderString(child.gender)),
                                                  const SizedBox(width: 16),
                                                  Icon(Icons.restaurant, color: Colors.orange, size: 18),
                                                  const SizedBox(width: 6),
                                                  Text(_getFeedingTypeString(child.feedingType)),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              // Allergies as chips
                                              Wrap(
                                                spacing: 6,
                                                runSpacing: 2,
                                                children: child.allergies.isEmpty
                                                    ? [
                                                        Chip(
                                                          label: const Text('No allergies'),
                                                          backgroundColor: Colors.green.shade50,
                                                          labelStyle: const TextStyle(color: Colors.green),
                                                        ),
                                                      ]
                                                    : _getAllergiesString(child.allergies)
                                                        .split(', ')
                                                        .map((allergy) => Chip(
                                                              label: Text(allergy),
                                                              backgroundColor: Colors.red.shade50,
                                                              labelStyle: const TextStyle(color: Colors.redAccent),
                                                            ))
                                                        .toList(),
                                              ),
                                              if (child.note.isNotEmpty && child.note != 'N/A')
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Text(
                                                    'Note: ${child.note}',
                                                    style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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