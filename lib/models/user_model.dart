class UserModel {
  final String uid;
  String name;
  final String email;
  String? profileImageUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImageUrl,
  });

  // Named constructor from Firestore map
  UserModel.fromMap(Map<String, dynamic> map)
      : uid = map['uid'] ?? '',
        name = map['name'] ?? '',
        email = map['email'] ?? '',
        profileImageUrl = map['profileImageUrl'];

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Encapsulated update methods
  void updateName(String newName) {
    name = newName;
  }

  void updateProfileImage(String url) {
    profileImageUrl = url;
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }
}
