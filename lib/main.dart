import 'package:children_tracking_mobileapp/pages/blog.dart'; // Make sure this import is correct
import 'package:children_tracking_mobileapp/pages/home.dart';
import 'package:children_tracking_mobileapp/pages/login.dart';
import 'package:children_tracking_mobileapp/pages/settings.dart';
import 'package:children_tracking_mobileapp/pages/child_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), 
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _selectedIndex = 0; // To keep track of the selected tab

  // List of pages to display
  final List<Widget> _pages = [
    const HomePage(), // Your existing HomePage content
    const BlogPage(), 
    const ChildPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Children Tracking App"),
      //   centerTitle: true,
      //   shape: const RoundedRectangleBorder(
      //     borderRadius: BorderRadius.only(
      //         bottomRight: Radius.circular(25),
      //         bottomLeft: Radius.circular(25)),
      //   ),
      //   toolbarHeight: 40,
      //   elevation: 5.00,
      //   backgroundColor: Colors.black,
      //   foregroundColor: Colors.white,
      // ),
      body: _pages[_selectedIndex], 
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: GNav(
            backgroundColor: Colors.black,
            gap: 8,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade700,
            padding: const EdgeInsets.all(20),
            selectedIndex: _selectedIndex, // Set the selected index for GNav
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index; // Update the selected index on tab change
              });
            },
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.book,
                text: 'Blogs',
              ),
              GButton(
                icon: Icons.baby_changing_station_outlined,
                text: 'Your Childs',
              ),
              GButton(
                icon: Icons.settings,
                text: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}