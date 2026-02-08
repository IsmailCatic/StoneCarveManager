import 'package:flutter/material.dart';
import '../models/blog_post.dart';
import '../providers/blog_post_provider.dart';
import '../models/blog_post_requests.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/app_drawer.dart';
import 'blog_post_form_screen.dart';
import 'blog_post_detail_screen.dart';

class BlogPostListScreen extends StatefulWidget {
  final AuthProvider authProvider;
  const BlogPostListScreen({Key? key, required this.authProvider})
    : super(key: key);

  @override
  State<BlogPostListScreen> createState() => _BlogPostListScreenState();
}

class _BlogPostListScreenState extends State<BlogPostListScreen> {
  late final BlogPostProvider _provider;
  List<BlogPost> _posts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('🔵 [BlogListScreen] Initializing with API URL: $kApiUrl');
    _provider = BlogPostProvider('BlogPost', apiUrl: kApiUrl);
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      print('🔵 [BlogListScreen] Starting to fetch posts...');
      final posts = await _provider.fetchBlogPosts(context);
      print('✅ [BlogListScreen] Received ${posts.length} posts');
      setState(() {
        _posts = posts;
        _loading = false;
      });
    } catch (e, stackTrace) {
      print('❌ [BlogListScreen] Error fetching posts: $e');
      print('❌ [BlogListScreen] Stack trace: $stackTrace');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blog Posts & Tutorials')),
      drawer: const AppDrawer(currentRoute: '/blog'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error Loading Blog Posts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchPosts,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchPosts,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _posts.length,
                itemBuilder: (context, i) {
                  final post = _posts[i];

                  // Get best image URL (featured or first gallery image)
                  String? getImageUrl() {
                    // Check if featured image is valid (not "string" placeholder)
                    if (post.featuredImageUrl != null &&
                        post.featuredImageUrl!.isNotEmpty &&
                        post.featuredImageUrl != 'string' &&
                        post.featuredImageUrl!.length > 5) {
                      return post.featuredImageUrl;
                    }
                    // Fallback to first gallery image
                    if (post.images.isNotEmpty) {
                      return post.images.first.imageUrl;
                    }
                    return null;
                  }

                  final imageUrl = getImageUrl();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlogPostDetailScreen(
                              authProvider: widget.authProvider,
                              postId: post.id,
                            ),
                          ),
                        );
                        if (result == true) _fetchPosts();
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageUrl != null)
                            Image.network(
                              imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print(
                                  '❌ [BlogListScreen] Error loading image: $error',
                                );
                                return Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade400,
                                        Colors.purple.shade400,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      post.isTutorial
                                          ? Icons.school
                                          : Icons.article,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            )
                          else
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.purple.shade400,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  post.isTutorial
                                      ? Icons.school
                                      : Icons.article,
                                  size: 64,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        post.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (post.isPublished)
                                      const Icon(
                                        Icons.public,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    if (post.isTutorial)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 4),
                                        child: Icon(
                                          Icons.school,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  post.summary ??
                                      (post.content.length > 120
                                          ? '${post.content.substring(0, 120)}...'
                                          : post.content),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.visibility,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${post.viewCount} views',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (post.publishedAt != null)
                                      Text(
                                        _formatDate(post.publishedAt!),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  BlogPostFormScreen(authProvider: widget.authProvider),
            ),
          );
          if (result == true) _fetchPosts();
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Blog Post',
      ),
    );
  }
}
