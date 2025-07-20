import 'package:flutter/material.dart';
import 'package:children_tracking_mobileapp/services/child_service.dart';
import 'package:provider/provider.dart';
import 'package:children_tracking_mobileapp/provider/auth_provider.dart';
import 'package:children_tracking_mobileapp/utils/snackbar.dart';

class AddChildPage extends StatefulWidget {
  const AddChildPage({super.key});

  @override
  State<AddChildPage> createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _selectedGenderString;
  int? _selectedGenderInt;
  DateTime? _selectedDate;

  int? _selectedFeedingType;
  List<int> _selectedAllergies = [];

  // Map string gender to integer for API
  // !! IMPORTANT: CONFIRM THESE MAPPINGS WITH YOUR BACKEND API DOCS !!
  final Map<String, int> _genderMapping = {
    'Male': 0,
    'Female': 1,
    'Other': 2,
  };

  // Example for Feeding Type (you'll need to confirm these from your API)
  final Map<String, int> _feedingTypeMapping = {
    'Breastfeeding': 0,
    'Formula': 1,
    'Mixed': 2,
    'Solid Foods': 3,
  };

  // Example for Allergies (you'll need to confirm these from your API)
  final Map<String, int> _allergyMapping = {
    'Cow\'s Milk': 0,
    'Eggs': 1,
    'Peanuts': 2,
    'Tree Nuts': 3,
    'Soy': 4,
    'Wheat': 5,
    'Fish': 6,
    'Shellfish': 7,
  };

  bool _isAddingChild = false; // New state variable for loading indicator
  late final ChildService _childService = ChildService();

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _addChild() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGenderInt == null) {
        showAppSnackBar(context, 'Please select a gender');
        return;
      }
      if (_selectedDate == null) {
        showAppSnackBar(context, 'Please select a birth date');
        return;
      }
      if (_selectedFeedingType == null) {
        showAppSnackBar(context, 'Please select a feeding type');
        return;
      }
      setState(() {
        _isAddingChild = true;
      });
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final String? accessToken = auth.token;
      if (accessToken == null) {
        showAppSnackBar(context, 'Authentication token not found. Please log in.');
        setState(() {
          _isAddingChild = false;
        });
        return;
      }
      final String name = _nameController.text;
      final String note = _noteController.text;
      final int gender = _selectedGenderInt!;
      final String birthDate = _selectedDate!.toIso8601String();
      final int feedingType = _selectedFeedingType!;
      final List<int> allergies = _selectedAllergies;
      try {
        await _childService.addChild(
          name: name,
          gender: gender,
          birthDate: birthDate,
          note: note,
          feedingType: feedingType,
          allergies: allergies,
          authToken: accessToken,
        );
        showAppSnackBar(context, 'Child added successfully!');
        _nameController.clear();
        _birthDateController.clear();
        _noteController.clear();
        setState(() {
          _selectedGenderString = null;
          _selectedGenderInt = null;
          _selectedDate = null;
          _selectedFeedingType = null;
          _selectedAllergies = [];
        });
        Navigator.pop(context, true);
      } catch (e) {
        showAppSnackBar(context, 'An error occurred: $e');
      } finally {
        setState(() {
          _isAddingChild = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Child'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Child\'s Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter child\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _birthDateController,
                decoration: const InputDecoration(
                  labelText: 'Birth Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectBirthDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select birth date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedGenderString,
                hint: const Text('Select Gender'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _genderMapping.keys.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGenderString = newValue;
                    _selectedGenderInt = _genderMapping[newValue];
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _selectedFeedingType,
                hint: const Text('Select Feeding Type'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _feedingTypeMapping.entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.value,
                    child: Text(entry.key),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedFeedingType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a feeding type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Allergies (Select all that apply)',
                  border: OutlineInputBorder(),
                ),
                child: Column(
                  children: _allergyMapping.entries.map((entry) {
                    return CheckboxListTile(
                      title: Text(entry.key),
                      value: _selectedAllergies.contains(entry.value),
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedAllergies.add(entry.value);
                          } else {
                            _selectedAllergies.remove(entry.value);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),
              _isAddingChild
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _addChild,
                      style: ElevatedButton.styleFrom(                       
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Add Child',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}