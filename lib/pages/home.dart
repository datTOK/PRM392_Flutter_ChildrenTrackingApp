import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:children_tracking_mobileapp/pages/add_child_page.dart';
import 'package:provider/provider.dart'; 
import 'package:children_tracking_mobileapp/provider/theme_provider.dart'; 
import 'package:children_tracking_mobileapp/utils/snackbar.dart';
import 'package:children_tracking_mobileapp/components/custom_app_bar.dart';
import 'package:children_tracking_mobileapp/services/blog_service.dart';
import 'package:children_tracking_mobileapp/pages/blog_detail.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
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

  // Blog feature state
  bool _isLoadingBlogs = false;
  List<dynamic> _featureBlogs = [];
  String? _blogError;
  late final BlogService _blogService = BlogService();
  AnimationController? _blogFadeController;

  @override
  void initState() {
    super.initState();
    _fetchFeatureBlogs();
    _blogFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _blogFadeController?.dispose();
    super.dispose();
  }

  Future<void> _fetchFeatureBlogs() async {
    setState(() {
      _isLoadingBlogs = true;
      _blogError = null;
    });
    try {
      final blogs = await _blogService.fetchBlogPosts();
      setState(() {
        _featureBlogs = blogs.take(3).toList();
      });
      _blogFadeController?.forward(from: 0);
    } catch (e) {
      setState(() {
        _blogError = 'Could not load blogs.';
      });
    } finally {
      setState(() {
        _isLoadingBlogs = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Children Tracking',
        icon: Icons.home_rounded,
        gradientColors: [Colors.blue, Colors.blueAccent],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Introduction Card (with gradient and icon)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade400,
                        Colors.indigo.shade400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.family_restroom, color: Colors.blue.shade700, size: 38),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Welcome to Children Tracking!',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Track your child\'s growth, health, and development. Access expert blogs, manage records, and more—all in one place.',
                                style: TextStyle(fontSize: 16, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Lottie Animation
              Center(
                child: Lottie.network(
                  'https://lottie.host/af600d14-bfcd-4e0e-a582-9405a1071cc9/2EbAObm1Uz.json',
                  height: 200,
                  repeat: true,
                  reverse: false,
                  animate: true,
                  frameRate: FrameRate.max,
                ),
              ),
              const SizedBox(height: 24),
              // Quick Actions Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                child: Text(
                  'Quick Actions',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _quickActions.map((action) {
                    return Column(
                      children: [
                        Material(
                          elevation: 6,
                          shape: const CircleBorder(),
                          color: action['color'],
                          child: InkWell(
                            onTap: () async {
                              if (action['name'] == 'Add Child') {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AddChildPage()),
                                );
                                if (result == true) {
                                  showAppSnackBar(context, 'Child added successfully!');
                                }
                              } else if (action['name'] == 'Toggle Theme') {
                                themeProvider.toggleTheme(); 
                                showAppSnackBar(context, 'Toggled theme to ${themeProvider.themeMode.name}');
                              } else {
                                showAppSnackBar(context, 'Quick action: ${action['name']}');
                              }
                            },
                            customBorder: const CircleBorder(),
                            child: SizedBox(
                              width: 70,
                              height: 70,
                              child: Icon(
                                action['icon'] as IconData,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          action['name'],
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
              // Featured Blog Section (moved below Quick Actions, show only one blog)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Blog',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    // Removed the See All button
                  ],
                ),
              ),
              if (_isLoadingBlogs)
                const Center(child: CircularProgressIndicator()),
              if (_blogError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(_blogError!, style: const TextStyle(color: Colors.red)),
                ),
              if (!_isLoadingBlogs && _blogError == null && _featureBlogs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('No blogs available at the moment.'),
                ),
              if (!_isLoadingBlogs && _featureBlogs.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: AnimatedBuilder(
                    animation: _blogFadeController!,
                    builder: (context, child) {
                      final blog = _featureBlogs.first;
                      return Opacity(
                        opacity: _blogFadeController!.value,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlogDetailPage(blogId: blog['id']),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Blog image with overlay
                                  if (blog['imageUrl'] != null)
                                    SizedBox(
                                      height: 120,
                                      width: double.infinity,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Image.network(
                                              blog['imageUrl'],
                                              fit: BoxFit.cover,
                                              isAntiAlias: true,
                                            ),
                                          ),
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.black.withOpacity(0.15),
                                                    Colors.black.withOpacity(0.35),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Container(
                                      height: 120,
                                      color: Colors.grey.shade200,
                                      child: const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                                    ),
                                  // Blog info
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          blog['title'] ?? 'No Title',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          (blog['content'] ?? 'No Content')
                                                  .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')
                                                  .substring(
                                                    0,
                                                    min(70, (blog['content'] ?? 'No Content').replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '').length),
                                                  ) + '...',
                                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 32),
              // Categories Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                child: Text(
                  'Explore Categories',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 14.0,
                    mainAxisSpacing: 14.0,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return InkWell(
                      onTap: () {
                        showAppSnackBar(context, 'Tapped on ${category['name']}');
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        color: theme.cardTheme.color ?? Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: (category['color'] as Color).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(14),
                              child: FaIcon(
                                category['icon'],
                                size: 32,
                                color: category['color'],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              category['name'],
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
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
        ),
      ),
    );
  }
}