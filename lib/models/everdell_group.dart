class EverdellGroup {
  const EverdellGroup({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.memberCount,
  });

  final String id;
  final String name;
  final String inviteCode;
  final int memberCount;

  factory EverdellGroup.fromJson(Map<String, dynamic> json) {
    return EverdellGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      inviteCode: json['invite_code'] as String? ?? '',
      memberCount: json['member_count'] as int? ?? 0,
    );
  }
}
