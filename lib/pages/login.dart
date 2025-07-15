import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:children_tracking_mobileapp/main.dart'; // Assuming RootPage is in main.dart

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  // Helper function to decode JWT and extract payload
  Map<String, dynamic>? _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null; // Not a valid JWT format
      }
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return json.decode(payload);
    } catch (e) {
      print('Error decoding JWT: $e');
      return null;
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final String apiUrl = 'https://restapi-dy71.onrender.com/api/Auth/login';
    final Map<String, String> data = {
      'email': _emailController.text,
      'password': _passwordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accept': 'text/plain',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String? accessToken = responseData['accessToken'];

        if (accessToken != null) {
          // Decode the access token to get user ID
          final Map<String, dynamic>? jwtPayload = _decodeJwt(accessToken);
          final String? userId = jwtPayload?['userId']; // Extract userId from payload

          if (userId != null) {
            // Save both the access token and user ID
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('accessToken', accessToken);
            await prefs.setString('userId', userId); // Save userId

            _showSnackBar('Login successful!', backgroundColor: Colors.green);
            // Navigate to RootPage (your main app content)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RootPage()),
            );
          } else {
            _showSnackBar('Login failed: User ID not found in token.');
          }
        } else {
          _showSnackBar('Login failed: Access token not found.');
        }
      } else {
        _showSnackBar('Login failed: ${response.reasonPhrase ?? 'Unknown error'}');
      }
    } catch (e) {
      _showSnackBar('Error during login: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.network(
                'https://lottie.host/1ce27522-55ba-4f73-a824-4c2dc116d2c9/q97IkZp70L.json',
                height: 200,
                repeat: true,
                reverse: false,
                animate: true,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.black,
                    )
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Login',
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