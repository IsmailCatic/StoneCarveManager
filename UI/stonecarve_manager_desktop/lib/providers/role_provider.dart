import 'package:stonecarve_manager_flutter/providers/base_provider.dart';

class RoleModel {
  int? id;
  String? name;
  String? description;
  bool? isActive;
  DateTime? createdAt;
  int? userCount;

  RoleModel({
    this.id,
    this.name,
    this.description,
    this.isActive,
    this.createdAt,
    this.userCount,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool?,
      userCount: json['userCount'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (isActive != null) 'isActive': isActive,
  };
}

class RoleProvider extends BaseProvider<RoleModel> {
  RoleProvider() : super('Role');

  @override
  RoleModel fromJson(data) => RoleModel.fromJson(data);

  Future<RoleModel> createRole({
    required String name,
    String? description,
    bool isActive = true,
  }) async {
    return await insert({
      'name': name,
      if (description != null && description.isNotEmpty)
        'description': description,
      'isActive': isActive,
    });
  }

  Future<RoleModel> updateRole(
    int id, {
    String? name,
    String? description,
    bool? isActive,
  }) async {
    return await update(id, {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isActive != null) 'isActive': isActive,
    });
  }

  Future<bool> deleteRole(int id) async {
    return await delete(id);
  }
}
