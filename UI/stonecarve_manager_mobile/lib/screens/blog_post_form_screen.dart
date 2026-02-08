import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/blog_post.dart';
import '../models/blog_post_requests.dart';
import '../providers/blog_post_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class BlogPostFormScreen extends StatefulWidget {
  final AuthProvider authProvider;
  final BlogPost? existingPost;
  const BlogPostFormScreen({
    Key? key,
    required this.authProvider,
    this.existingPost,
  }) : super(key: key);

  @override
  State<BlogPostFormScreen> createState() => _BlogPostFormScreenState();
}

class _BlogPostFormScreenState extends State<BlogPostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final BlogPostProvider _provider;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _summaryController;
  late TextEditingController _featuredImageUrlController;
  File? _featuredImageFile;
  bool _isPublished = false;
  bool _isTutorial = false;
  bool _isActive = true;
  int? _authorId;
  int? _categoryId;
  bool _loading = false;
  String? _error;

  Future<void> _pickFeaturedImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _featuredImageFile = File(pickedFile.path);
        // Clear URL field if file is picked
        _featuredImageUrlController.clear();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _provider = BlogPostProvider('BlogPost', apiUrl: kApiUrl);
    final post = widget.existingPost;
    _titleController = TextEditingController(text: post?.title ?? '');
    _contentController = TextEditingController(text: post?.content ?? '');
    _summaryController = TextEditingController(text: post?.summary ?? '');
    _featuredImageUrlController = TextEditingController(
      text: post?.featuredImageUrl ?? '',
    );
    _isPublished = post?.isPublished ?? false;
    _isTutorial = post?.isTutorial ?? false;
    _isActive = post?.isActive ?? true;
    _authorId = post?.authorId;
    _categoryId = post?.categoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _summaryController.dispose();
    _featuredImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Get the featured image URL from text field (if provided)
      final featuredImageUrl = _featuredImageUrlController.text.isNotEmpty
          ? _featuredImageUrlController.text
          : null;

      int? createdPostId;

      if (widget.existingPost == null) {
        print('🔵 [BlogFormScreen] Inserting new blog post...');
        final newPost = await _provider.insertBlogPost(
          context,
          BlogPostInsertRequest(
            title: _titleController.text,
            content: _contentController.text,
            summary: _summaryController.text.isNotEmpty
                ? _summaryController.text
                : null,
            featuredImageUrl: featuredImageUrl,
            isPublished: _isPublished,
            isTutorial: _isTutorial,
            isActive: _isActive,
            authorId:
                _authorId ?? 1, // TODO: Replace with actual author selection
            categoryId:
                _categoryId ??
                1, // TODO: Replace with actual category selection
          ),
        );
        createdPostId = newPost.id;
        print(
          '✅ [BlogFormScreen] Blog post inserted successfully with ID: $createdPostId',
        );
      } else {
        print(
          '🔵 [BlogFormScreen] Updating blog post ${widget.existingPost!.id}...',
        );
        await _provider.updateBlogPost(
          context,
          widget.existingPost!.id,
          BlogPostUpdateRequest(
            title: _titleController.text,
            content: _contentController.text,
            summary: _summaryController.text.isNotEmpty
                ? _summaryController.text
                : null,
            featuredImageUrl: featuredImageUrl,
            isPublished: _isPublished,
            isTutorial: _isTutorial,
            isActive: _isActive,
            authorId: _authorId,
            categoryId: _categoryId,
          ),
        );
        createdPostId = widget.existingPost!.id;
        print('✅ [BlogFormScreen] Blog post updated successfully');
      }

      // Upload featured image AFTER creating the post (if image file was selected)
      if (_featuredImageFile != null && createdPostId != null) {
        print(
          '🔵 [BlogFormScreen] Uploading featured image for post $createdPostId...',
        );
        final uploadedImageUrl = await _provider.uploadFeaturedImage(
          context,
          _featuredImageFile!,
        );
        print('✅ [BlogFormScreen] Featured image uploaded: $uploadedImageUrl');

        // Update the post with the uploaded image URL
        await _provider.updateBlogPost(
          context,
          createdPostId,
          BlogPostUpdateRequest(
            title: _titleController.text,
            content: _contentController.text,
            summary: _summaryController.text.isNotEmpty
                ? _summaryController.text
                : null,
            featuredImageUrl: uploadedImageUrl,
            isPublished: _isPublished,
            isTutorial: _isTutorial,
            isActive: _isActive,
            authorId: _authorId ?? 1,
            categoryId: _categoryId ?? 1,
          ),
        );
        print('✅ [BlogFormScreen] Post updated with featured image URL');
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e, stackTrace) {
      print('❌ [BlogFormScreen] Error saving blog post: $e');
      print('❌ [BlogFormScreen] Stack trace: $stackTrace');
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingPost == null ? 'Add Blog Post' : 'Edit Blog Post',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Enter a descriptive title',
                ),
                validator: (value) => Validators.validateLengthRange(
                  value,
                  5,
                  200,
                  fieldName: 'Title',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content *',
                  hintText: 'Write your blog post content',
                  alignLabelWithHint: true,
                ),
                minLines: 6,
                maxLines: 20,
                validator: (value) => Validators.validateMinLength(
                  value,
                  50,
                  fieldName: 'Content',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _summaryController,
                decoration: const InputDecoration(
                  labelText: 'Summary (optional)',
                  hintText: 'Brief summary for preview',
                ),
                maxLength: 500,
                maxLines: 3,
                validator: (value) => value != null && value.isNotEmpty
                    ? Validators.validateLengthRange(
                        value,
                        10,
                        500,
                        fieldName: 'Summary',
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Featured Image',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_featuredImageFile != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _featuredImageFile!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _featuredImageFile = null;
                          });
                        },
                      ),
                    ),
                  ],
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickFeaturedImage,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Upload Featured Image'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              const SizedBox(height: 8),
              const Text(
                'Or enter image URL:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              TextFormField(
                controller: _featuredImageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Featured Image URL (optional)',
                  hintText: 'https://example.com/image.jpg',
                ),
                enabled: _featuredImageFile == null,
                validator: (value) => value != null && value.isNotEmpty
                    ? Validators.validateUrl(value, required: false)
                    : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _isPublished,
                onChanged: (v) => setState(() => _isPublished = v),
                title: const Text('Published'),
              ),
              SwitchListTile(
                value: _isTutorial,
                onChanged: (v) => setState(() => _isTutorial = v),
                title: const Text('Tutorial'),
              ),
              SwitchListTile(
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                title: const Text('Active'),
              ),
              // TODO: Add dropdowns for author and category selection
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
