class LoginRequest {
  String? email;
  String? password;

  LoginRequest({this.email, this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class RegisterRequest {
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  DateTime? dateOfBirth;

  RegisterRequest({
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.dateOfBirth,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };
  }
}

class AuthResponse {
  String? token;
  String? refreshToken;
  int? userId;
  String? username;
  List<String>? roles;

  AuthResponse({
    this.token,
    this.refreshToken,
    this.userId,
    this.username,
    this.roles,
  });

  AuthResponse.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    refreshToken = json['refreshToken'];
    userId = json['userId'];
    username = json['username'];

    // Support both "roles" (plural) and "role" (singular) from backend
    if (json['roles'] != null) {
      roles = List<String>.from(json['roles']);
    } else if (json['role'] != null) {
      // Fallback: if backend sends "role" instead of "roles"
      final roleValue = json['role'];
      if (roleValue is List) {
        roles = List<String>.from(roleValue);
      } else if (roleValue is String) {
        roles = [roleValue];
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'userId': userId,
      'username': username,
      'roles': roles,
    };
  }
}
