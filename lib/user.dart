import 'dart:convert';

class User {
  final int id;
  final String name;
  final String email;
  final String? username;
  final String? profilePicture;
  final String? bio;
  final String? phoneNumber;
  final DateTime? lastLoginAt;
  final String status;

  User(
      {required this.id,
      required this.name,
      required this.email,
      this.username,
      this.profilePicture,
      this.bio,
      this.phoneNumber,
      this.lastLoginAt,
      this.status = 'offline'});

  // Factory constructor to create a User from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        username: json['username'] as String?,
        profilePicture: json['profile_picture'] as String?,
        bio: json['bio'] as String?,
        phoneNumber: json['phone_number'] as String?,
        lastLoginAt: json['last_login_at'] != null
            ? DateTime.parse(json['last_login_at'])
            : null,
        status: json['status'] as String? ?? 'offline');
  }

  // Convert User to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'profile_picture': profilePicture,
      'bio': bio,
      'phone_number': phoneNumber,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'status': status
    };
  }

  // Create a copy of the user with optional parameter updates
  User copyWith(
      {int? id,
      String? name,
      String? email,
      String? username,
      String? profilePicture,
      String? bio,
      String? phoneNumber,
      DateTime? lastLoginAt,
      String? status}) {
    return User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        username: username ?? this.username,
        profilePicture: profilePicture ?? this.profilePicture,
        bio: bio ?? this.bio,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        lastLoginAt: lastLoginAt ?? this.lastLoginAt,
        status: status ?? this.status);
  }

  // Convenience getters
  bool get isOnline => status == 'online';
  String get displayName => username ?? name;

  // Get profile picture URL or default
  String get profilePictureUrl {
    if (profilePicture == null || profilePicture!.isEmpty) {
      return 'assets/default_profile.png'; // Add a default profile image
    }
    return profilePicture!;
  }

  // Generate a string representation of the user
  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email}';
  }

  // Equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ email.hashCode;
  }

  // Static method to parse a list of users from JSON
  static List<User> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => User.fromJson(json)).toList();
  }
}

// Example of a UserDto (Data Transfer Object) for registration
class UserRegistrationDto {
  final String name;
  final String email;
  final String password;
  final String? username;

  UserRegistrationDto(
      {required this.name,
      required this.email,
      required this.password,
      this.username});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'username': username
    };
  }
}

// Example of a UserUpdateDto
class UserUpdateDto {
  final String? name;
  final String? username;
  final String? bio;
  final String? profilePicture;

  UserUpdateDto({this.name, this.username, this.bio, this.profilePicture});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (username != null) data['username'] = username;
    if (bio != null) data['bio'] = bio;
    if (profilePicture != null) data['profile_picture'] = profilePicture;

    return data;
  }
}
