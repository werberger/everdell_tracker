class EverdellProfile {
  const EverdellProfile({
    required this.id,
    required this.username,
    required this.displayName,
    this.email,
  });

  final int id;
  final String username;
  final String displayName;
  final String? email;

  factory EverdellProfile.fromJson(Map<String, dynamic> json) {
    final displayName = (json['display_name'] as String?)?.trim();
    return EverdellProfile(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      displayName: (displayName != null && displayName.isNotEmpty)
          ? displayName
          : (json['username'] as String? ?? ''),
      email: json['email'] as String?,
    );
  }
}
