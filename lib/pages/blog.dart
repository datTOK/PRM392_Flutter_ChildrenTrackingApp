import 'package:flutter/material.dart';
import 'package:children_tracking_mobileapp/services/blog_service.dart';
import 'package:children_tracking_mobileapp/pages/blog_detail.dart';
import 'package:children_tracking_mobileapp/utils/snackbar.dart';

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
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: Row(
          mainAxisSize: MainAxisSize.min, 
          children: [
            const Text(
              'Blog Posts',
            ),
            const SizedBox(width: 5), 
            Icon(Icons.library_books, size: 26),
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
