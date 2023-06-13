class User {
  const User({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.selfIntroduction,
    this.blockUsers,
    this.rawValues,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      name: map['name'] as String,
      profileImage: map['profile_image'] as String,
      selfIntroduction: map['self_introduction'] as String? ?? '',
      rawValues: map,
      blockUsers: map['block_users'] as List?,
    );
  }

  final int id;
  final String name;
  final String profileImage;
  final String selfIntroduction;
  final List? blockUsers;
  final Map<String, dynamic>? rawValues;
}
