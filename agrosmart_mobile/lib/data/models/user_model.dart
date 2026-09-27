class UserModel {
  final int? id;
  final String username;
  final String email;
  final String? phone;
  final String? location;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    this.phone,
    this.location,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'location': location,
    };
  }
}
