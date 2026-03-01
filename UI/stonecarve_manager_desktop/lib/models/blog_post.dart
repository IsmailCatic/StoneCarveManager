class BlogImage {
  final int id;
  final String imageUrl;
  final String? altText;
  final int displayOrder;
  final DateTime uploadedAt;
  final int blogPostId;

  BlogImage({
    required this.id,
    required this.imageUrl,
    this.altText,
    required this.displayOrder,
    required this.uploadedAt,
    required this.blogPostId,
  });

  factory BlogImage.fromJson(Map<String, dynamic> json) {
    return BlogImage(
      id: json['id'],
      imageUrl: json['imageUrl'],
      altText: json['altText'],
      displayOrder: json['displayOrder'] ?? 0,
      uploadedAt: DateTime.parse(json['uploadedAt']),
      blogPostId: json['blogPostId'],
    );
  }
}

class BlogPost {
  final int id;
  final String title;
  final String content;
  final String? summary;
  final String? featuredImageUrl;
  final bool isPublished;
  final bool isTutorial;
  final int viewCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final DateTime? updatedAt;
  final int authorId;
  final String? authorName;
  final int categoryId;
  final String? categoryName;
  final List<BlogImage> images;

  BlogPost({
    required this.id,
    required this.title,
    required this.content,
    this.summary,
    this.featuredImageUrl,
    required this.isPublished,
    required this.isTutorial,
    required this.viewCount,
    required this.isActive,
    required this.createdAt,
    this.publishedAt,
    this.updatedAt,
    required this.authorId,
    this.authorName,
    required this.categoryId,
    this.categoryName,
    required this.images,
  });

  BlogPost copyWith({
    int? id,
    String? title,
    String? content,
    String? summary,
    String? featuredImageUrl,
    bool? isPublished,
    bool? isTutorial,
    int? viewCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? publishedAt,
    DateTime? updatedAt,
    int? authorId,
    String? authorName,
    int? categoryId,
    String? categoryName,
    List<BlogImage>? images,
  }) {
    return BlogPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      featuredImageUrl: featuredImageUrl ?? this.featuredImageUrl,
      isPublished: isPublished ?? this.isPublished,
      isTutorial: isTutorial ?? this.isTutorial,
      viewCount: viewCount ?? this.viewCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      images: images ?? this.images,
    );
  }

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    // Sanitize featuredImageUrl - treat "string" or empty values as null
    String? featuredImageUrl = json['featuredImageUrl'];
    if (featuredImageUrl == 'string' ||
        featuredImageUrl?.isEmpty == true ||
        featuredImageUrl?.length == 0) {
      featuredImageUrl = null;
    }

    return BlogPost(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      summary: json['summary'],
      featuredImageUrl: featuredImageUrl,
      isPublished: json['isPublished'],
      isTutorial: json['isTutorial'],
      viewCount: json['viewCount'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      authorId: json['authorId'],
      authorName: json['authorName'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => BlogImage.fromJson(e))
          .toList(),
    );
  }
}
