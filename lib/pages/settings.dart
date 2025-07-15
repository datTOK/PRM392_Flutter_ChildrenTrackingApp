import 'package:flutter/material.dart';
import 'package:children_tracking_mobileapp/pages/login.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = true;
  String _profileErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _profileErrorMessage = '';
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      setState(() {
        _profileErrorMessage = 'No access token found. Please log in again.';
        _isLoadingProfile = false;
      });
      _showSnackBar(_profileErrorMessage, backgroundColor: Colors.orange);
      return;
    }

    final String apiUrl = 'https://restapi-dy71.onrender.com/api/Auth/me';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accept': 'text/plain',
          'Authorization': 'Bearer $accessToken', 
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _userProfile = responseData; 
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _profileErrorMessage = 'Unauthorized. Please log in again.';
        });
        _showSnackBar(_profileErrorMessage, backgroundColor: Colors.orange);
        _logout(context); 
      }
      else {
        setState(() {
          _profileErrorMessage = 'Failed to load profile: ${response.reasonPhrase}';
        });
        _showSnackBar(_profileErrorMessage);
      }
    } catch (e) {
      setState(() {
        _profileErrorMessage = 'Error fetching profile: $e';
      });
      _showSnackBar(_profileErrorMessage);
    } finally {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  void _showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken'); 
    await prefs.remove('userId');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min, 
          children: [
            const Text(
              'Settings',
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoadingProfile
              ? const CircularProgressIndicator()
              : _profileErrorMessage.isNotEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_profileErrorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchUserProfile,
                          child: const Text('Retry Load Profile'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _logout(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.settings, size: 80, color: Colors.blueGrey),
                        const SizedBox(height: 20),
                        const Text(
                          'Manage your app settings here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.black87),
                        ),
                        const SizedBox(height: 30),
                        if (_userProfile != null) ...[
                          Text(
                            'Welcome, ${_userProfile!['name'] ?? 'User'}!',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Email: ${_userProfile!['email'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Role: ${_userProfile!['role'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 30),
                        ],
                        ElevatedButton(
                          onPressed: () => _logout(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}