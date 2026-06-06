import 'game.dart';

class EverdellGameRecord {
  const EverdellGameRecord({
    required this.id,
    required this.updatedAt,
    required this.game,
  });

  final String id;
  final DateTime updatedAt;
  final Game game;

  factory EverdellGameRecord.fromDetailJson(Map<String, dynamic> json) {
    final payload = Map<String, dynamic>.from(
      json['payload'] as Map<String, dynamic>,
    );
    final serverId = json['id'] as String;
    payload['id'] = serverId;

    return EverdellGameRecord(
      id: serverId,
      updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
      game: Game.fromJson(payload),
    );
  }

  String get updatedAtIso => updatedAt.toIso8601String();
}
