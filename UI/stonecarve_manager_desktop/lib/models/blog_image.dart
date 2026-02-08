class BlogImageResponse {
  final int id;
  final String imageUrl;
  final String? altText;
  final int displayOrder;
  final DateTime uploadedAt;
  final int blogPostId;

  BlogImageResponse({
    required this.id,
    required this.imageUrl,
    this.altText,
    required this.displayOrder,
    required this.uploadedAt,
    required this.blogPostId,
  });

  factory BlogImageResponse.fromJson(Map<String, dynamic> json) {
    return BlogImageResponse(
      id: json['id'],
      imageUrl: json['imageUrl'],
      altText: json['altText'],
      displayOrder: json['displayOrder'] ?? 0,
      uploadedAt: DateTime.parse(json['uploadedAt']),
      blogPostId: json['blogPostId'],
    );
  }
}
