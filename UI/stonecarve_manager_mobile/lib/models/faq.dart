class Faq {
  final int id;
  final String question;
  final String answer;
  final String? category;
  final int displayOrder;
  final bool isActive;
  final int viewCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Faq({
    required this.id,
    required this.question,
    required this.answer,
    this.category,
    required this.displayOrder,
    required this.isActive,
    required this.viewCount,
    required this.createdAt,
    this.updatedAt,
  });

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      id: json['id'] as int,
      question: json['question'] as String,
      answer: json['answer'] as String,
      category: json['category'] as String?,
      displayOrder: json['displayOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      viewCount: json['viewCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'category': category,
    'displayOrder': displayOrder,
    'isActive': isActive,
    'viewCount': viewCount,
    'createdAt': createdAt.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };
}

class FaqInsertRequest {
  final String question;
  final String answer;
  final String? category;
  final int displayOrder;
  final bool isActive;

  FaqInsertRequest({
    required this.question,
    required this.answer,
    this.category,
    this.displayOrder = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'question': question,
    'answer': answer,
    if (category != null) 'category': category,
    'displayOrder': displayOrder,
    'isActive': isActive,
  };
}

class FaqUpdateRequest {
  final String? question;
  final String? answer;
  final String? category;
  final int? displayOrder;
  final bool? isActive;

  FaqUpdateRequest({
    this.question,
    this.answer,
    this.category,
    this.displayOrder,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (question != null) map['question'] = question;
    if (answer != null) map['answer'] = answer;
    if (category != null) map['category'] = category;
    if (displayOrder != null) map['displayOrder'] = displayOrder;
    if (isActive != null) map['isActive'] = isActive;
    return map;
  }
}
