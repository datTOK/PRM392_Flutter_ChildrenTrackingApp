import 'package:children_tracking_mobileapp/pages/blog.dart';
import 'package:children_tracking_mobileapp/pages/home.dart';
import 'package:children_tracking_mobileapp/pages/login.dart';
import 'package:children_tracking_mobileapp/pages/settings.dart';
import 'package:children_tracking_mobileapp/pages/child_page.dart';
import 'package:children_tracking_mobileapp/pages/consultant_page.dart';
import 'package:children_tracking_mobileapp/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            cardTheme: CardThemeData(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.white,
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.black87),
              headlineSmall: TextStyle(color: Colors.black87),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.grey,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            cardTheme: CardThemeData(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.grey.shade900,
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white70),
              headlineSmall: TextStyle(color: Colors.white),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: const LoginPage(),
        );
      },
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _selectedIndex = 0;

  // List of pages to display
  final List<Widget> _pages = [
    const HomePage(), // Your existing HomePage content
    const BlogPage(),
    const ChildPage(),
    const ConsultantPage(), // Consultant tab before Settings
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
            Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GNav(
            backgroundColor:
                Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
                Colors.black,
            gap: 8,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.blue.shade700,
            padding: const EdgeInsets.all(20),
            selectedIndex: _selectedIndex, // Set the selected index for GNav
            onTabChange: (index) {
              setState(() {
                _selectedIndex =
                    index; // Update the selected index on tab change
              });
            },
            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.book, text: 'Blogs'),
              GButton(
                icon: Icons.baby_changing_station_outlined,
                text: 'Your Childs',
              ),
              GButton(
                icon: Icons.medical_services, // Consultant tab before Settings
                text: 'Consultant',
              ),
              GButton(icon: Icons.settings, text: 'Settings'),
            ],
          ),
        ),
      ),
    );
  }
}
