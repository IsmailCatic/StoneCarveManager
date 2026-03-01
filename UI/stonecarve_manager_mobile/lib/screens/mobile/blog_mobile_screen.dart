import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/blog_post.dart';
import '../../models/blog_post_requests.dart';
import '../../providers/blog_post_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/mobile/app_drawer_mobile.dart';
import 'blog_detail_mobile_screen.dart';

class BlogMobileScreen extends StatefulWidget {
  const BlogMobileScreen({Key? key}) : super(key: key);

  @override
  State<BlogMobileScreen> createState() => _BlogMobileScreenState();
}

class _BlogMobileScreenState extends State<BlogMobileScreen>
    with SingleTickerProviderStateMixin {
  late final BlogPostProvider _provider;
  late TabController _tabController;

  List<BlogPost> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Category filter — name for display, id for backend query
  String _selectedCategory = 'All';
  int? _selectedCategoryId;
  // populated from first unfiltered load: categoryName → categoryId
  final Map<String, int> _categoryIdMap = {};
  final List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _provider = BlogPostProvider('BlogPost', apiUrl: kApiUrl);
    _loadPosts();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      // Reset category when switching tabs and re-fetch from backend
      setState(() {
        _selectedCategory = 'All';
        _selectedCategoryId = null;
        _categories
          ..clear()
          ..add('All');
        _categoryIdMap.clear();
      });
      _loadPosts();
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final isBlogTab = _tabController.index == 0;

    try {
      // Send all filters to backend — same pattern as desktop app
      final search = BlogPostSearch(
        isPublished: true,
        isTutorial: !isBlogTab,
        categoryId: _selectedCategoryId,
      );

      final posts = await _provider.fetchBlogPosts(context, search: search);

      // On unfiltered load, populate category chips from returned posts
      if (_selectedCategoryId == null) {
        final catSet = <String>{'All'};
        final idMap = <String, int>{};
        for (var post in posts) {
          if (post.categoryName != null && post.categoryName!.isNotEmpty) {
            catSet.add(post.categoryName!);
            idMap[post.categoryName!] = post.categoryId;
          }
        }
        _categories
          ..clear()
          ..addAll(catSet);
        _categoryIdMap
          ..clear()
          ..addAll(idMap);
      }

      // Sort by publish date (newest first) — backend returns unsorted
      posts.sort((a, b) {
        final aDate = a.publishedAt ?? a.createdAt;
        final bDate = b.publishedAt ?? b.createdAt;
        return bDate.compareTo(aDate);
      });

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Blog',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Stories, insights, and news from our workshop',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Blog Posts'),
                Tab(text: 'Tutorials'),
              ],
            ),
          ),
        ),
      ),
      drawer: const AppDrawerMobile(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : Column(
              children: [
                _buildCategoryFilter(),
                Expanded(
                  child: _posts.isEmpty ? _buildEmptyState() : _buildBlogList(),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((category) {
            final isSelected = category == _selectedCategory;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Text(category),
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = category;
                    // Look up categoryId for backend query
                    _selectedCategoryId = (category == 'All')
                        ? null
                        : _categoryIdMap[category];
                  });
                  // Re-fetch from backend with new category filter
                  _loadPosts();
                },
                backgroundColor: Colors.grey[100],
                selectedColor: Colors.blue.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.blue : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                checkmarkColor: Colors.blue,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBlogList() {
    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildBlogCard(post);
        },
      ),
    );
  }

  Widget _buildBlogCard(BlogPost post) {
    final imageUrl = _getPostImageUrl(post);
    final isTutorial = post.isTutorial;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogDetailMobileScreen(postId: post.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (imageUrl != null)
              Stack(
                children: [
                  Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                  // Category badge
                  if (post.categoryName != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isTutorial
                              ? Colors.orange.withOpacity(0.9)
                              : Colors.blue.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          post.categoryName!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Summary
                  if (post.summary != null && post.summary!.isNotEmpty)
                    Text(
                      post.summary!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      post.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 12),

                  // Author & Date
                  Row(
                    children: [
                      if (post.authorName != null) ...[
                        Icon(Icons.person, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          post.authorName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(post.publishedAt ?? post.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
  }

  Widget _buildEmptyState() {
    final isBlogTab = _tabController.index == 0;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isBlogTab ? Icons.article_outlined : Icons.school_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isBlogTab ? 'No blog posts yet' : 'No tutorials yet',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new content',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Failed to load posts',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPosts,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getPostImageUrl(BlogPost post) {
    // Priority: featuredImageUrl -> first gallery image
    if (post.featuredImageUrl != null &&
        post.featuredImageUrl!.isNotEmpty &&
        post.featuredImageUrl != 'string') {
      return post.featuredImageUrl;
    }
    if (post.images.isNotEmpty) {
      return post.images.first.imageUrl;
    }
    return null;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else {
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}
