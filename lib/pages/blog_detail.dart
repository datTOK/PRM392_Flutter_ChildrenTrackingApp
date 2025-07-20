import 'package:flutter/material.dart';
import 'package:children_tracking_mobileapp/services/blog_service.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:children_tracking_mobileapp/utils/snackbar.dart';

class BlogDetailPage extends StatefulWidget {
  final String blogId; 

  const BlogDetailPage({super.key, required this.blogId});

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _blogPost;
  String _errorMessage = '';
  late final BlogService _blogService = BlogService();

  @override
  void initState() {
    super.initState();
    _fetchBlogDetails();
  }

  Future<void> _fetchBlogDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final blog = await _blogService.fetchBlogDetail(widget.blogId);
      setState(() {
        _blogPost = blog;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching blog details: $e';
      });
      showAppSnackBar(context, _errorMessage);
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
        title: Text(_blogPost?['title'] ?? 'Blog Detail'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _blogPost == null
                  ? const Center(child: Text('Blog post not found.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_blogPost!['imageUrl'] != null)
                            InstaImageViewer(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    _blogPost!['imageUrl'],
                                    width: double.infinity,
                                    isAntiAlias: true,
                                  ),
                                ),
                              ),
                            ),
                          Text(
                            _blogPost!['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Displaying content with HTML rendering (you'll need a package for this)
                          // For now, displaying as plain text or using a simple RichText
                          // If content is HTML, consider using flutter_html or flutter_widget_from_html
                          Text(
                            _blogPost!['content'] != null
                                ? _blogPost!['content'].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '') 
                                : 'No Content',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          if (_blogPost!['contentImageUrls'] != null && _blogPost!['contentImageUrls'].isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Related Images:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, 
                                    crossAxisSpacing: 8.0,
                                    mainAxisSpacing: 8.0,
                                  ),
                                  itemCount: _blogPost!['contentImageUrls'].length,
                                  itemBuilder: (context, index) {
                                    return InstaImageViewer(
                                      child: Image.network(
                                        _blogPost!['contentImageUrls'][index],
                                        fit: BoxFit.cover,
                                        isAntiAlias: true,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
    );
  }
}