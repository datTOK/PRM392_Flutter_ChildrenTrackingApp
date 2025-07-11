import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:children_tracking_mobileapp/pages/blog_detail.dart';
import 'package:lottie/lottie.dart'; 

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  bool _isLoading = false;
  List<dynamic> _blogPosts = [];

  @override
  void initState() {
    super.initState();
    _fetchBlogPosts();
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

  Future<void> _fetchBlogPosts() async {
    setState(() {
      _isLoading = true;
    });

    final String apiUrl = 'https://child-tracking-dotnet.onrender.com/api/Blog';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accept': 'text/plain',
        },
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // Handle the blog posts as needed
        setState(() {
          _blogPosts = responseData['data'] ?? [];
        });
      } else {
        _showSnackBar('Failed to load blog posts: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showSnackBar('Error fetching blog posts: $e');
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
        title: Row(
          mainAxisSize: MainAxisSize.min, 
          children: [
            const Text(
              'Blog Posts',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _blogPosts.isEmpty
          ? const Center(child: Text('No blog posts available.'))
          : ListView.builder(
              itemCount: _blogPosts.length,
              itemBuilder: (context, index) {
                final post = _blogPosts[index];
                return Card(
                      margin: const EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 20.0,
                      shadowColor: Colors.blue.shade100,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlogDetailPage(
                                blogId: post['id'], 
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(post['title'] ?? 'No Title'),
                              subtitle: Text(
                                // Limiting subtitle content for preview
                                (post['content'] ?? 'No Content').replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '').substring(
                                  0,
                                  (post['content'] ?? 'No Content').replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '').length > 100
                                      ? 100
                                      : (post['content'] ?? 'No Content').replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '').length,
                                ) + '...',
                              ),
                              tileColor: Colors.blue.shade300,
                            ),
                            Image.network(
                              post['imageUrl'] ?? 'https://via.placeholder.com/150',
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              isAntiAlias: true,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
