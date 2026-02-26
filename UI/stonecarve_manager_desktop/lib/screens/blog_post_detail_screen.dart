import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/blog_post.dart';
import '../models/blog_image_upload_request.dart';
import '../providers/blog_post_provider.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import 'blog_post_form_screen.dart';

class BlogPostDetailScreen extends StatefulWidget {
  final AuthProvider authProvider;
  final int postId;
  const BlogPostDetailScreen({
    Key? key,
    required this.authProvider,
    required this.postId,
  }) : super(key: key);

  @override
  State<BlogPostDetailScreen> createState() => _BlogPostDetailScreenState();
}

class _BlogPostDetailScreenState extends State<BlogPostDetailScreen> {
  late final BlogPostProvider _provider;
  BlogPost? _post;
  bool _loading = true;
  String? _error;
  File? _imageFile;
  bool _uploading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    print('🔵 [BlogDetailScreen] Initializing for post ID: ${widget.postId}');
    print('🔵 [BlogDetailScreen] API URL: $kApiUrl');
    _provider = BlogPostProvider('BlogPost', apiUrl: kApiUrl);
    _fetch();
  }

  String? _getValidImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;

    // Check if it's a placeholder/invalid value from backend (e.g., "string")
    if (imageUrl == 'string' || imageUrl.length < 5) {
      print(
        '⚠️ [BlogDetailScreen] Invalid featuredImageUrl detected: "$imageUrl"',
      );
      return null;
    }

    // If URL already starts with http:// or https://, return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // If it's a relative path, prepend the base API URL
    // Remove /api from kApiUrl and add the image path
    final baseUrl = kApiUrl.replaceAll('/api', '');
    final cleanPath = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
    return '$baseUrl$cleanPath';
  }

  String? _getBestImageUrl() {
    // Try featured image first
    final featuredUrl = _getValidImageUrl(_post?.featuredImageUrl);
    if (featuredUrl != null) return featuredUrl;

    // Fallback to first image in gallery if available
    if (_post != null && _post!.images.isNotEmpty) {
      final firstImage = _post!.images.first.imageUrl;
      print(
        'ℹ️ [BlogDetailScreen] Using first gallery image as fallback: $firstImage',
      );
      return firstImage;
    }

    return null;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage(_imageFile!);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    if (_post == null) return;
    setState(() {
      _uploading = true;
    });
    try {
      print('🔵 [BlogDetailScreen] Uploading image for post ${_post!.id}');
      await _provider.uploadBlogImage(
        context,
        _post!.id,
        BlogImageUploadRequest(filePath: imageFile.path),
      );
      print('✅ [BlogDetailScreen] Image uploaded successfully');

      // Reload the post to show the new image
      await _fetch();
      _hasChanges = true;

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Image uploaded!')));
      }
    } catch (e, stackTrace) {
      print('❌ [BlogDetailScreen] Error uploading image: $e');
      print('❌ [BlogDetailScreen] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  Future<void> _deleteImage(int imageId, int index) async {
    if (_post == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _provider.deleteBlogImage(context, _post!.id, imageId);

        // Reload the post to reflect the deletion
        await _fetch();
        _hasChanges = true;

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Image deleted!')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting image: $e')));
        }
      }
    }
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      print('🔵 [BlogDetailScreen] Fetching post ${widget.postId}...');
      final post = await _provider.getBlogPost(context, widget.postId);
      print('✅ [BlogDetailScreen] Successfully loaded post: ${post.title}');

      setState(() {
        _post = post;
        _loading = false;
      });

      // NOTE: View tracking is NOT implemented in admin app
      // Admins just view statistics, they don't increment view count
      // View tracking is implemented in the MOBILE app for end users
    } catch (e, stackTrace) {
      print('❌ [BlogDetailScreen] Error fetching post: $e');
      print('❌ [BlogDetailScreen] Stack trace: $stackTrace');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_hasChanges);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Blog Post Details'),
          actions: [
            if (_post != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlogPostFormScreen(
                        authProvider: widget.authProvider,
                        existingPost: _post,
                      ),
                    ),
                  );
                  if (result == true) {
                    _fetch();
                    _hasChanges = true;
                  }
                },
              ),
            if (_post != null)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Post'),
                      content: const Text(
                        'Are you sure you want to delete this blog post?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    try {
                      await _provider.deleteBlogPost(context, _post!.id);
                      if (mounted) {
                        Navigator.of(context).pop(true);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error deleting post: $e')),
                        );
                      }
                    }
                  }
                },
              ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : _post == null
            ? const Center(child: Text('Not found'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with image and title side by side
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Featured Image - constrained to 35% width
                        Builder(
                          builder: (context) {
                            final imageUrl = _getBestImageUrl();
                            return Container(
                              width: 320,
                              height: 220,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: imageUrl == null
                                  ? Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade300,
                                            Colors.purple.shade300,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.article_outlined,
                                              size: 48,
                                              color: Colors.white,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'No image',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        imageUrl,
                                        width: 320,
                                        height: 220,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.broken_image,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text('Failed to load'),
                                                  ],
                                                ),
                                              );
                                            },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            );
                          },
                        ),
                        const SizedBox(width: 24),
                        // Title and metadata - takes remaining space
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _post!.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (_post!.isPublished)
                                    Chip(
                                      label: const Text('Published'),
                                      backgroundColor: Colors.green.shade100,
                                      avatar: const Icon(
                                        Icons.check_circle,
                                        size: 18,
                                        color: Colors.green,
                                      ),
                                    ),
                                  if (!_post!.isPublished)
                                    Chip(
                                      label: const Text('Draft'),
                                      backgroundColor: Colors.grey.shade200,
                                      avatar: const Icon(
                                        Icons.unpublished,
                                        size: 18,
                                      ),
                                    ),
                                  if (_post!.isTutorial)
                                    Chip(
                                      label: const Text('Tutorial'),
                                      backgroundColor: Colors.blue.shade100,
                                      avatar: const Icon(
                                        Icons.school,
                                        size: 18,
                                        color: Colors.blue,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    size: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_post!.viewCount} views',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  if (_post!.publishedAt != null) ...[
                                    Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${_post!.publishedAt!.day}/${_post!.publishedAt!.month}/${_post!.publishedAt!.year}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (_post!.summary != null &&
                                  _post!.summary!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  _post!.summary!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade700,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Content section
                    Text(
                      'Content',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _post!.content,
                      style: const TextStyle(fontSize: 15, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    // Images Gallery section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Image Gallery',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: _uploading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.add_a_photo),
                          tooltip: 'Add Image',
                          onPressed: _uploading ? null : _pickImage,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _post!.images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final img = _post!.images[i];
                          final validUrl = _getValidImageUrl(img.imageUrl);
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: validUrl != null
                                    ? Image.network(
                                        validUrl,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          print(
                                            '❌ [BlogDetailScreen] Error loading image ${img.id}: $error',
                                          );
                                          return Container(
                                            width: 120,
                                            height: 120,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        width: 120,
                                        height: 120,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _deleteImage(img.id, i),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
