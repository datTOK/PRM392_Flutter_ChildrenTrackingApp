import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:children_tracking_mobileapp/pages/add_child_page.dart';
import 'package:provider/provider.dart'; 
import 'package:children_tracking_mobileapp/provider/theme_provider.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _quickActions = [
    {'name': 'Add Child', 'icon': Icons.child_care, 'color': Colors.lightBlue},
    {'name': 'Toggle Theme', 'icon': Icons.brightness_6, 'color': Colors.red},
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Health', 'icon': FontAwesomeIcons.heartPulse, 'color': Colors.redAccent},
    {'name': 'Development', 'icon': FontAwesomeIcons.brain, 'color': Colors.blueAccent},
    {'name': 'Education', 'icon': FontAwesomeIcons.bookOpenReader, 'color': Colors.greenAccent},
    {'name': 'Nutrition', 'icon': FontAwesomeIcons.appleWhole, 'color': Colors.orangeAccent},
    {'name': 'Safety', 'icon': FontAwesomeIcons.shieldHalved, 'color': Colors.purpleAccent},
    {'name': 'Activities', 'icon': FontAwesomeIcons.gamepad, 'color': Colors.yellow.shade700},
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false); 

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white 
                : Colors.blue.shade800, 
            child: const Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, Parent!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                    ),
                    Text(
                      'Welcome back to your child\'s journey.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Center(
            child: Lottie.network(
              'https://lottie.host/af600d14-bfcd-4e0e-a582-9405a1071cc9/2EbAObm1Uz.json',
              height: 250,
              repeat: true,
              reverse: false,
              animate: true,
              frameRate: FrameRate.max,
            ),
          ),
          const SizedBox(height: 30),

          // Quick Actions Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _quickActions.map((action) {
                return Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        if (action['name'] == 'Add Child') {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddChildPage()),
                          );
                          if (result == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Child added successfully!')),
                            );
                          }
                        } else if (action['name'] == 'Toggle Theme') {
                          themeProvider.toggleTheme(); 
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Toggled theme to ${themeProvider.themeMode.name}')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Quick action: ${action['name']}')),
                          );
                        }
                      },
                      customBorder: const CircleBorder(),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: action['color'],
                        child: Icon(
                          action['icon'] as IconData,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['name'],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'Explore Categories',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 5.0,
                childAspectRatio: 0.9,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Theme.of(context).cardTheme.color, 
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tapped on ${category['name']}')),
                      );
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          category['icon'],
                          size: 40,
                          color: category['color'],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          category['name'],
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}