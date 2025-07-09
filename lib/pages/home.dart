import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:children_tracking_mobileapp/pages/add_child_page.dart'; 
import 'package:children_tracking_mobileapp/pages/child_page.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _quickActions = [
    {'name': 'Add Child', 'icon': Icons.child_care, 'color': Colors.lightBlue},
    {'name': 'Track Growth', 'icon': Icons.show_chart, 'color': Colors.green},
    {'name': 'Emergency', 'icon': Icons.emergency, 'color': Colors.red},
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            color: Colors.blue.shade800,
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
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Welcome back to your child\'s journey.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Center(
            // Center the Lottie animation
            child: Lottie.network(
              'https://lottie.host/af600d14-bfcd-4e0e-a582-9405a1071cc9/2EbAObm1Uz.json', // Example Lottie URL
              height: 250, // Adjust height as needed
              repeat: true, // Loop the animation
              reverse: false,
              animate: true,
              frameRate: FrameRate.max,
            ),
          ),
          const SizedBox(height: 30),

          // Quick Actions Section
          const Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
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
                        // Implement specific actions based on the name
                        if (action['name'] == 'Add Child') {
                          // Navigate to AddChildPage
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddChildPage()),
                          );
                          // If AddChildPage returns true (child added successfully)
                          // you might want to switch to the "Your Children" tab
                          if (result == true) {
                            // This assumes RootPage has a method to change the selected index
                            // If RootPage is in main.dart, you might need a different approach
                            // For now, we can just show a snackbar or let the user manually navigate
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Child added successfully!')),
                            );

                            // OPTIONAL: If you want to automatically switch to the ChildPage tab
                            // This requires access to the RootPage's state, which is more complex.
                            // A simpler approach is to use a callback or just let the user navigate.
                            // For a quick fix, let's just make sure ChildPage refreshes when it's viewed again.
                            // The ChildPage already has logic to refresh on initState when it loads.
                          }
                        } else if (action['name'] == 'Track Growth') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Navigating to Track Growth')),
                          );
                        } else if (action['name'] == 'Emergency') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opening Emergency Contacts')),
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
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'Explore Categories',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
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
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tapped on ${category['name']}')),
                      );
                      // TODO: Implement navigation to category specific page or content
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
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