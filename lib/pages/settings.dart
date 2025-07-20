import 'package:flutter/material.dart';
import 'package:children_tracking_mobileapp/pages/login.dart';
import 'package:provider/provider.dart';
import 'package:children_tracking_mobileapp/provider/auth_provider.dart';
import 'package:children_tracking_mobileapp/services/auth_service.dart';
import 'package:children_tracking_mobileapp/utils/snackbar.dart';

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
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final String? accessToken = auth.token;
    if (accessToken == null) {
      setState(() {
        _profileErrorMessage = 'No access token found. Please log in again.';
        _isLoadingProfile = false;
      });
      showAppSnackBar(context, _profileErrorMessage, backgroundColor: Colors.orange);
      return;
    }
    try {
      final profile = await AuthService().fetchUserProfile(accessToken: accessToken);
      setState(() {
        _userProfile = profile;
      });
    } on Exception catch (e) {
      setState(() {
        _profileErrorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      showAppSnackBar(context, _profileErrorMessage, backgroundColor: Colors.orange);
      if (_profileErrorMessage.contains('Unauthorized')) {
        _logout(context);
      }
    } finally {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  void _logout(BuildContext context) async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
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
        automaticallyImplyLeading: false,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.settings,
              size: 28,
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
        toolbarHeight: 70,
        elevation: 8.0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isLoadingProfile
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading profile...', style: TextStyle(fontSize: 16)),
                  ],
                )
              : _profileErrorMessage.isNotEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                        const SizedBox(height: 20),
                        Text(
                          _profileErrorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: _fetchUserProfile,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry Load Profile', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.blueGrey,
                          child: Icon(Icons.person, size: 80, color: Colors.white),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'Welcome, ${_userProfile!['name'] ?? 'User'}!',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.headlineSmall?.color),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Card(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                _buildProfileDetailRow(
                                  context,
                                  icon: Icons.email,
                                  label: 'Email:',
                                  value: _userProfile!['email'] ?? 'N/A',
                                ),
                                const Divider(height: 20, thickness: 1),
                                _buildProfileDetailRow(
                                  context,
                                  icon: Icons.work,
                                  label: 'Role:',
                                  value: _userProfile!['role'] ?? 'N/A',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            'Logout',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 8,
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}