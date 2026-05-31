class UserProfile {
  final String uid;
  final String displayName;
  final String email;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      displayName: map['display_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'display_name': displayName,
        'email': email,
      };

  UserProfile copyWith({String? displayName, String? email}) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
    );
  }
}
