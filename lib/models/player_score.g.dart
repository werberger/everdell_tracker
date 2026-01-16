// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_score.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerScoreAdapter extends TypeAdapter<PlayerScore> {
  @override
  final int typeId = 1;

  @override
  PlayerScore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerScore(
      playerId: fields[0] as String,
      playerName: fields[1] as String,
      pointTokens: fields[2] as int?,
      cardPoints: fields[3] as int?,
      basicEvents: fields[4] as int?,
      specialEvents: fields[5] as int?,
      prosperityPoints: fields[6] as int?,
      journeyPoints: fields[7] as int?,
      leftoverBerries: fields[8] as int?,
      leftoverResin: fields[9] as int?,
      leftoverPebbles: fields[10] as int?,
      leftoverWood: fields[11] as int?,
      pearlPoints: fields[12] as int?,
      wonderPoints: fields[13] as int?,
      weatherPoints: fields[14] as int?,
      garlandPoints: fields[15] as int?,
      ticketPoints: fields[16] as int?,
      totalScore: fields[17] as int,
      tiebreakerResources: fields[18] as int,
      isWinner: fields[19] as bool,
      isQuickEntry: fields[20] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerScore obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.playerId)
      ..writeByte(1)
      ..write(obj.playerName)
      ..writeByte(2)
      ..write(obj.pointTokens)
      ..writeByte(3)
      ..write(obj.cardPoints)
      ..writeByte(4)
      ..write(obj.basicEvents)
      ..writeByte(5)
      ..write(obj.specialEvents)
      ..writeByte(6)
      ..write(obj.prosperityPoints)
      ..writeByte(7)
      ..write(obj.journeyPoints)
      ..writeByte(8)
      ..write(obj.leftoverBerries)
      ..writeByte(9)
      ..write(obj.leftoverResin)
      ..writeByte(10)
      ..write(obj.leftoverPebbles)
      ..writeByte(11)
      ..write(obj.leftoverWood)
      ..writeByte(12)
      ..write(obj.pearlPoints)
      ..writeByte(13)
      ..write(obj.wonderPoints)
      ..writeByte(14)
      ..write(obj.weatherPoints)
      ..writeByte(15)
      ..write(obj.garlandPoints)
      ..writeByte(16)
      ..write(obj.ticketPoints)
      ..writeByte(17)
      ..write(obj.totalScore)
      ..writeByte(18)
      ..write(obj.tiebreakerResources)
      ..writeByte(19)
      ..write(obj.isWinner)
      ..writeByte(20)
      ..write(obj.isQuickEntry);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerScoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
