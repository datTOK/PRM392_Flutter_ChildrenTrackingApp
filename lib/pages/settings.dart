import 'package:flutter/material.dart';
import 'package:children_tracking_mobileapp/pages/login.dart'; // Import LoginPage for navigation

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _logout(BuildContext context) {
    // In a real app, you would clear any stored authentication tokens here
    // For example, using shared_preferences or flutter_secure_storage

    // Navigate back to the LoginPage and remove all routes from the stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false, // This predicate ensures all previous routes are removed
    );
  }

  @override
  Widget build(BuildContext context) {
    // Removed Scaffold and AppBar, now only returns the body content
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, // Logout button color
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
    );
  }
}