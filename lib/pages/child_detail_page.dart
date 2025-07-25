import 'package:flutter/material.dart';
import 'package:children_tracking_mobileapp/services/child_service.dart';
import 'package:children_tracking_mobileapp/services/growth_data_service.dart';
import 'package:children_tracking_mobileapp/models/child_models.dart';
import 'package:children_tracking_mobileapp/pages/child_growth_data_page.dart';
import 'package:provider/provider.dart';
import 'package:children_tracking_mobileapp/provider/auth_provider.dart';

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

  late final ChildService _childService = ChildService();
  late final GrowthDataService _growthDataService = GrowthDataService();

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
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _authToken = auth.token;
    if (_authToken == null) {
      setState(() {
        _isLoadingChildDetails = false;
        _childDetailsErrorMessage = 'Authentication data not found. Please log in again.';
      });
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
    try {
      final child = await _childService.fetchChildById(childId: widget.childId, authToken: _authToken!);
      setState(() {
        _child = child;
        _isLoadingChildDetails = false;
      });
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
      try {
        await _growthDataService.addGrowthData(
          childId: widget.childId,
          height: double.parse(_heightController.text),
          weight: double.parse(_weightController.text),
          headCircumference: double.tryParse(_headCircumferenceController.text) ?? 0.0,
          armCircumference: double.tryParse(_armCircumferenceController.text) ?? 0.0,
          inputDate: _selectedInputDate!.toIso8601String(),
          authToken: _authToken!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Growth data added successfully!')),
        );
        _heightController.clear();
        _weightController.clear();
        _headCircumferenceController.clear();
        _armCircumferenceController.clear();
        _inputDateController.clear();
        setState(() {
          _selectedInputDate = null;
        });
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
                              color: Colors.blue.shade50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Baby avatar icon
                                    CircleAvatar(
                                      radius: 38,
                                      backgroundColor: Colors.blueAccent.withOpacity(0.15),
                                      child: Icon(Icons.child_care, color: Colors.blueAccent, size: 44),
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      _child!.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 26,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Divider(height: 30, thickness: 1, color: Colors.blue.shade100),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.cake, color: Colors.indigo, size: 20),
                                        const SizedBox(width: 6),
                                        Text(
                                          _child!.birthDate.toLocal().toString().split(' ')[0],
                                          style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.wc, color: Colors.indigo, size: 20),
                                        const SizedBox(width: 6),
                                        Text(
                                          _getGenderString(_child!.gender),
                                          style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.restaurant, color: Colors.orange, size: 20),
                                        const SizedBox(width: 6),
                                        Text(
                                          _getFeedingTypeString(_child!.feedingType),
                                          style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Allergies as chips
                                    Align(
                                      alignment: Alignment.center,
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 2,
                                        children: _child!.allergies.isEmpty
                                            ? [
                                                Chip(
                                                  label: const Text('No allergies'),
                                                  backgroundColor: Colors.green.shade50,
                                                  labelStyle: const TextStyle(color: Colors.green),
                                                ),
                                              ]
                                            : _getAllergiesString(_child!.allergies)
                                                .split(', ')
                                                .map((allergy) => Chip(
                                                      label: Text(allergy),
                                                      backgroundColor: Colors.red.shade50,
                                                      labelStyle: const TextStyle(color: Colors.redAccent),
                                                    ))
                                                .toList(),
                                      ),
                                    ),
                                    if (_child!.note.isNotEmpty && _child!.note != 'N/A')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.sticky_note_2, color: Colors.indigo, size: 20),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                _child!.note,
                                                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87, fontSize: 16),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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