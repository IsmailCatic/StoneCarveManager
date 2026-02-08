class BlogPostSearch {
  final bool? isPublished;
  final int? authorId;
  final int? categoryId;

  BlogPostSearch({this.isPublished, this.authorId, this.categoryId});

  Map<String, dynamic> toJson() => {
    if (isPublished != null) 'isPublished': isPublished,
    if (authorId != null) 'authorId': authorId,
    if (categoryId != null) 'categoryId': categoryId,
  };
}

class BlogPostInsertRequest {
  final String title;
  final String content;
  final String? summary;
  final String? featuredImageUrl;
  final bool isPublished;
  final bool isTutorial;
  final bool isActive;
  final int authorId;
  final int categoryId;

  BlogPostInsertRequest({
    required this.title,
    required this.content,
    this.summary,
    this.featuredImageUrl,
    this.isPublished = false,
    this.isTutorial = false,
    this.isActive = true,
    required this.authorId,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    if (summary != null) 'summary': summary,
    if (featuredImageUrl != null) 'featuredImageUrl': featuredImageUrl,
    'isPublished': isPublished,
    'isTutorial': isTutorial,
    'isActive': isActive,
    'authorId': authorId,
    'categoryId': categoryId,
  };
}

class BlogPostUpdateRequest {
  final String? title;
  final String? content;
  final String? summary;
  final String? featuredImageUrl;
  final bool? isPublished;
  final bool? isTutorial;
  final bool? isActive;
  final int? authorId;
  final int? categoryId;

  BlogPostUpdateRequest({
    this.title,
    this.content,
    this.summary,
    this.featuredImageUrl,
    this.isPublished,
    this.isTutorial,
    this.isActive,
    this.authorId,
    this.categoryId,
  });

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (content != null) 'content': content,
    if (summary != null) 'summary': summary,
    if (featuredImageUrl != null) 'featuredImageUrl': featuredImageUrl,
    if (isPublished != null) 'isPublished': isPublished,
    if (isTutorial != null) 'isTutorial': isTutorial,
    if (isActive != null) 'isActive': isActive,
    if (authorId != null) 'authorId': authorId,
    if (categoryId != null) 'categoryId': categoryId,
  };
}
