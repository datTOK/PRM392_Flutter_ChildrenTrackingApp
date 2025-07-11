import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:children_tracking_mobileapp/pages/child_page.dart';
import 'package:children_tracking_mobileapp/pages/child_growth_data_page.dart'; 

class ChildDetailPage extends StatefulWidget {
  final String childId;

  const ChildDetailPage({super.key, required this.childId});

  @override
  State<ChildDetailPage> createState() => _ChildDetailPageState();
}

class _ChildDetailPageState extends State<ChildDetailPage> {
  Child? _child;
  bool _isLoadingChildDetails = true;
  bool _isSubmittingGrowthData = false;
  String? _childDetailsErrorMessage;

  String? _authToken;

  final _growthFormKey = GlobalKey<FormState>();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _headCircumferenceController = TextEditingController();
  final TextEditingController _armCircumferenceController = TextEditingController();
  final TextEditingController _inputDateController = TextEditingController();
  DateTime? _selectedInputDate;

  @override
  void initState() {
    super.initState();
    _loadAuthDataAndFetchChildDetails();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _headCircumferenceController.dispose();
    _armCircumferenceController.dispose();
    _inputDateController.dispose();
    super.dispose();
  }

  Future<void> _loadAuthDataAndFetchChildDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('accessToken');

    if (_authToken == null) {
      setState(() {
        _isLoadingChildDetails = false;
        _childDetailsErrorMessage = 'Authentication data not found. Please log in again.';
      });
      // Optionally navigate back to login page
      return;
    }
    await _fetchChildDetails();
  }

  Future<void> _fetchChildDetails() async {
    setState(() {
      _isLoadingChildDetails = true;
      _childDetailsErrorMessage = null;
    });

    if (_authToken == null) {
      setState(() {
        _childDetailsErrorMessage = 'Authentication token is missing. Cannot fetch child details.';
        _isLoadingChildDetails = false;
      });
      return;
    }

    final url = Uri.parse('https://child-tracking-dotnet.onrender.com/api/Child/${widget.childId}');

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
        if (responseData['child'] != null) {
          setState(() {
            _child = Child.fromJson(responseData['child']);
            _isLoadingChildDetails = false;
          });
        } else {
          setState(() {
            _childDetailsErrorMessage = 'Child data not found in API response.';
            _isLoadingChildDetails = false;
          });
        }
      } else {
        setState(() {
          _childDetailsErrorMessage = 'Failed to load child details: ${response.statusCode} - ${response.body}';
          _isLoadingChildDetails = false;
        });
      }
    } catch (e) {
      setState(() {
        _childDetailsErrorMessage = 'An error occurred: $e';
        _isLoadingChildDetails = false;
      });
    }
  }

  Future<void> _addGrowthData() async {
    if (_growthFormKey.currentState!.validate()) {
      setState(() {
        _isSubmittingGrowthData = true;
      });

      if (_authToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found. Please log in.')),
        );
        setState(() {
          _isSubmittingGrowthData = false;
        });
        return;
      }

      final url = Uri.parse('https://child-tracking-dotnet.onrender.com/api/GrowthData?childId=${widget.childId}');

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $_authToken',
          },
          body: jsonEncode({
            'height': double.parse(_heightController.text),
            'weight': double.parse(_weightController.text),
            'headCircumference': double.tryParse(_headCircumferenceController.text) ?? 0.0,
            'armCircumference': double.tryParse(_armCircumferenceController.text) ?? 0.0,
            'inputDate': _selectedInputDate!.toIso8601String(),
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Growth data added successfully!')),
          );
          // Clear form
          _heightController.clear();
          _weightController.clear();
          _headCircumferenceController.clear();
          _armCircumferenceController.clear();
          _inputDateController.clear();
          setState(() {
            _selectedInputDate = null;
          });
          // No need to fetch growth data here, as it's on a different page now
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add growth data: ${response.statusCode} - ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        setState(() {
          _isSubmittingGrowthData = false;
        });
      }
    }
  }

  Future<void> _selectInputDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedInputDate ?? DateTime.now(),
      firstDate: DateTime(2000), // Adjust as needed
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedInputDate) {
      setState(() {
        _selectedInputDate = picked;
        _inputDateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  // Helper methods from ChildPage to display gender, feeding type, allergies
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

  // Helper method to build a row for child details
  Widget _buildDetailRow(String label, String value, {FontStyle? fontStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Fixed width for labels
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontStyle: fontStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_child?.name ?? 'Child Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Child Details Section
              _isLoadingChildDetails
                  ? const Center(child: CircularProgressIndicator())
                  : _childDetailsErrorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Error loading child details: $_childDetailsErrorMessage',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red, fontSize: 16),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _fetchChildDetails,
                                  child: const Text('Retry Child Details'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _child == null
                          ? const Center(child: Text('No child details available.'))
                          : Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _child!.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      )
                                    ),
                                    const Divider(height: 30, thickness: 1),
                                    _buildDetailRow('ID', _child!.id),
                                    _buildDetailRow('Birth Date', _child!.birthDate.toLocal().toString().split(' ')[0]),
                                    _buildDetailRow('Gender', _getGenderString(_child!.gender)),
                                    _buildDetailRow('Feeding Type', _getFeedingTypeString(_child!.feedingType)),
                                    _buildDetailRow('Allergies', _getAllergiesString(_child!.allergies)),
                                    if (_child!.note.isNotEmpty && _child!.note != 'N/A')
                                      _buildDetailRow('Note', _child!.note, fontStyle: FontStyle.italic),
                                  ],
                                ),
                              ),
                            ),
              const SizedBox(height: 30),

              // Add Growth Data Section
              Text(
                'Add New Growth Data',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _growthFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _inputDateController,
                          decoration: const InputDecoration(
                            labelText: 'Date of Measurement',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: () => _selectInputDate(context),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a date';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Height (cm)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter height';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Weight (kg)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter weight';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _headCircumferenceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Head Circumference (cm) (Optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _armCircumferenceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Arm Circumference (cm) (Optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _isSubmittingGrowthData
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _addGrowthData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Add Growth Data', style: TextStyle(fontSize: 18)),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Navigation Button to Growth Data Page
              if (_child != null) // Only show if child details are loaded
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChildGrowthDataPage(
                            childId: widget.childId,
                            childName: _child!.name, // Pass child's name
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.show_chart),
                    label: const Text('View Growth Charts & Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}