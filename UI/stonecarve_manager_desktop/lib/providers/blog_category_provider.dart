import 'package:stonecarve_manager_flutter/providers/base_provider.dart';

class BlogCategoryModel {
  int? id;
  String? name;
  int? postCount;
  DateTime? createdAt;
  DateTime? updatedAt;

  BlogCategoryModel({
    this.id,
    this.name,
    this.postCount,
    this.createdAt,
    this.updatedAt,
  });

  factory BlogCategoryModel.fromJson(Map<String, dynamic> json) {
    return BlogCategoryModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      postCount: json['postCount'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (name != null) 'name': name,
  };
}

class BlogCategoryProvider extends BaseProvider<BlogCategoryModel> {
  BlogCategoryProvider() : super('BlogCategory');

  @override
  BlogCategoryModel fromJson(data) => BlogCategoryModel.fromJson(data);

  Future<BlogCategoryModel> createBlogCategory(String name) async {
    return await insert({'name': name});
  }

  Future<BlogCategoryModel> updateBlogCategory(int id, String name) async {
    return await update(id, {'name': name});
  }

  Future<bool> deleteBlogCategory(int id) async {
    return await delete(id);
  }
}
