class AppUser {
  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phone,
    this.role = 'farmer',
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final String? phone;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      phone: map['phone'] as String?,
      role: map['role'] as String? ?? 'farmer',
      createdAt: map['createdAt'] == null ? null : DateTime.tryParse(map['createdAt'].toString()),
      updatedAt: map['updatedAt'] == null ? null : DateTime.tryParse(map['updatedAt'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'phone': phone,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
