class User {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? phoneNumber;
  bool? isActive;
  bool? isBlocked;
  String? profileImageUrl;
  DateTime? createdAt;
  DateTime? lastLoginAt;
  List<String> roles;
  String? role; // for insert

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.phoneNumber,
    this.isActive,
    this.isBlocked,
    this.profileImageUrl,
    this.createdAt,
    this.lastLoginAt,
    required this.roles,
    this.role,
  });

  User.fromJson(Map<String, dynamic> json, {required this.roles}) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    isActive = json['isActive'];
    isBlocked = json['isBlocked'];
    createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null;
    lastLoginAt = json['lastLoginAt'] != null
        ? DateTime.parse(json['lastLoginAt'])
        : null;
    profileImageUrl = json['profileImageUrl'];
    roles = List<String>.from(json['roles'] ?? []);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'isActive': isActive,
      'isBlocked': isBlocked,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'roles': roles,
    };
  }

  Map<String, dynamic> toInsertJson() => {
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "password": password,
    "phoneNumber": phoneNumber,
    "profileImageUrl": profileImageUrl,
    "isActive": isActive,
    "isBlocked": isBlocked,
    "role": role,
  };

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  String get displayName => fullName.isNotEmpty ? fullName : 'Unknown User';
}
