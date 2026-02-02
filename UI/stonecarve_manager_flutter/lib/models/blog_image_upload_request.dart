class BlogImageUploadRequest {
  final String filePath; // Local file path to upload
  final String? altText;
  final int displayOrder;

  BlogImageUploadRequest({
    required this.filePath,
    this.altText,
    this.displayOrder = 0,
  });

  // For multipart upload, handled in provider/service
  Map<String, String> toFields() => {
    if (altText != null) 'altText': altText!,
    'displayOrder': displayOrder.toString(),
  };
}
