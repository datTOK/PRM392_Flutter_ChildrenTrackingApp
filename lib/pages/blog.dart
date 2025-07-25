import 'package:flutter/material.dart';
import 'package:children_tracking_mobileapp/services/blog_service.dart';
import 'package:children_tracking_mobileapp/pages/blog_detail.dart';
import 'package:children_tracking_mobileapp/utils/snackbar.dart';
import 'package:children_tracking_mobileapp/components/custom_app_bar.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  bool _isLoading = false;
  List<dynamic> _blogPosts = [];
  late final BlogService _blogService = BlogService();

  @override
  void initState() {
    super.initState();
    _fetchBlogPosts();
  }

  Future<void> _fetchBlogPosts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final posts = await _blogService.fetchBlogPosts();
      setState(() {
        _blogPosts = posts;
      });
    } catch (e) {
      showAppSnackBar(context, 'Error fetching blog posts: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Blog Posts',
        icon: Icons.library_books,
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
                  margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  color: Colors.blue.shade50,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Blog image with gradient overlay
                        Stack(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 170,
                              child: Image.network(
                                post['imageUrl'] ?? 'https://via.placeholder.com/150',
                                fit: BoxFit.cover,
                                isAntiAlias: true,
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.08),
                                      Colors.black.withOpacity(0.18),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post['title'] ?? 'No Title',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.indigo,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                (post['content'] ?? 'No Content')
                                        .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')
                                        .substring(
                                          0,
                                          (post['content'] ?? 'No Content')
                                                      .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '').length > 100
                                              ? 100
                                              : (post['content'] ?? 'No Content')
                                                  .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '').length,
                                        ) + '...',
                                style: const TextStyle(fontSize: 15, color: Colors.black87),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
