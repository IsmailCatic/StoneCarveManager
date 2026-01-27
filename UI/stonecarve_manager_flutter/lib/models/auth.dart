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
  String? profilePicture;
  DateTime? dateOfBirth;

  RegisterRequest({
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.profilePicture,
    this.dateOfBirth,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'profilePicture': profilePicture,
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
    if (json['roles'] != null) {
      roles = List<String>.from(json['roles']);
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
