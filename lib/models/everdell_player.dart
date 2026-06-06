class EverdellPlayer {
  const EverdellPlayer({
    required this.id,
    required this.name,
    required this.displayName,
    this.displayAvatarUrl,
  });

  final String id;
  final String name;
  final String displayName;
  final String? displayAvatarUrl;

  factory EverdellPlayer.fromJson(Map<String, dynamic> json) {
    return EverdellPlayer(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String? ?? json['name'] as String,
      displayAvatarUrl: json['display_avatar_url'] as String?,
    );
  }
}
