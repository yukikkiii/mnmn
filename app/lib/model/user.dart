class User {
  const User({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.selfIntroduction,
    this.rawValues,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      name: map['name'] as String,
      profileImage: map['profile_image'] as String,
      selfIntroduction: map['self_introduction'] as String? ?? '',
      rawValues: map,
    );
  }

  final int id;
  final String name;
  final String profileImage;
  final String selfIntroduction;
  final Map<String, dynamic>? rawValues;
}
