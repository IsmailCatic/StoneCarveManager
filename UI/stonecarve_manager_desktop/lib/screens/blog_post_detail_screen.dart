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
      final newImgResponse = await _provider.uploadBlogImage(
        context,
        _post!.id,
        BlogImageUploadRequest(filePath: imageFile.path),
      );
      print('✅ [BlogDetailScreen] Image uploaded successfully');
      // Convert BlogImageResponse to BlogImage
      final newImg = BlogImage(
        id: newImgResponse.id,
        imageUrl: newImgResponse.imageUrl,
        altText: newImgResponse.altText,
        displayOrder: newImgResponse.displayOrder,
        uploadedAt: newImgResponse.uploadedAt,
        blogPostId: newImgResponse.blogPostId,
      );
      setState(() {
        _post = _post!.copyWith(images: [..._post!.images, newImg]);
      });
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
        setState(() {
          final imgs = [..._post!.images];
          imgs.removeAt(index);
          _post = _post!.copyWith(images: imgs);
        });
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
    return Scaffold(
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
                if (result == true) _fetch();
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
                  Text(
                    _post!.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final imageUrl = _getBestImageUrl();
                      if (imageUrl == null) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: 64,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No image available',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print(
                            '❌ [BlogDetailScreen] Error loading image from URL: $imageUrl',
                          );
                          print('❌ [BlogDetailScreen] Error: $error');
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text('Failed to load image'),
                              ],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (_post!.isPublished)
                        const Chip(
                          label: Text('Published'),
                          backgroundColor: Colors.greenAccent,
                        ),
                      if (_post!.isTutorial)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Chip(
                            label: Text('Tutorial'),
                            backgroundColor: Colors.blueAccent,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _post!.summary ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(_post!.content),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Images:',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}
