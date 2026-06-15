class EverdellPlayer {
  const EverdellPlayer({
    required this.id,
    required this.name,
    required this.displayName,
    this.nickname = '',
    this.isLinkedToMe = false,
    this.displayNameSource = 'player',
    this.displayAvatarUrl,
  });

  final String id;
  final String name;
  final String displayName;
  final String nickname;
  final bool isLinkedToMe;
  final String displayNameSource;
  final String? displayAvatarUrl;

  /// Last 4 characters of UUID — subtle disambiguator when names collide.
  String get shortId => id.length >= 4 ? id.substring(id.length - 4).toUpperCase() : id;

  /// Label for pickers/lists; appends short id when multiple players share a name.
  String pickerLabel(List<EverdellPlayer> roster) {
    final sameName = roster
        .where((p) => p.displayName.toLowerCase() == displayName.toLowerCase())
        .length;
    if (sameName > 1) {
      return '$displayName · $shortId';
    }
    return displayName;
  }

  factory EverdellPlayer.fromJson(Map<String, dynamic> json) {
    return EverdellPlayer(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String? ?? json['name'] as String,
      nickname: json['nickname'] as String? ?? '',
      isLinkedToMe: json['is_linked_to_me'] as bool? ?? false,
      displayNameSource: json['display_name_source'] as String? ?? 'player',
      displayAvatarUrl: json['display_avatar_url'] as String?,
    );
  }
}
