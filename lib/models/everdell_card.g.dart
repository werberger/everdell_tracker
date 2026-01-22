// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'everdell_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EverdellCardAdapter extends TypeAdapter<EverdellCard> {
  @override
  final int typeId = 10;

  @override
  EverdellCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EverdellCard(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as CardType,
      cardColor: fields[3] as CardColor,
      rarity: fields[4] as CardRarity,
      basePoints: fields[5] as int,
      imagePath: fields[6] as String,
      pairedWith: fields[7] as String?,
      conditionalScoring: fields[8] as ConditionalScoring?,
      module: fields[9] as String,
      hasImage: fields[10] as bool,
      countsTowardCitySize: fields[11] as bool,
      canShareSpace: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, EverdellCard obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.cardColor)
      ..writeByte(4)
      ..write(obj.rarity)
      ..writeByte(5)
      ..write(obj.basePoints)
      ..writeByte(6)
      ..write(obj.imagePath)
      ..writeByte(7)
      ..write(obj.pairedWith)
      ..writeByte(8)
      ..write(obj.conditionalScoring)
      ..writeByte(9)
      ..write(obj.module)
      ..writeByte(10)
      ..write(obj.hasImage)
      ..writeByte(11)
      ..write(obj.countsTowardCitySize)
      ..writeByte(12)
      ..write(obj.canShareSpace);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EverdellCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConditionalScoringAdapter extends TypeAdapter<ConditionalScoring> {
  @override
  final int typeId = 11;

  @override
  ConditionalScoring read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConditionalScoring(
      type: fields[0] as ConditionalScoringType,
      userPrompt: fields[1] as String?,
      calculationData: (fields[2] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ConditionalScoring obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.userPrompt)
      ..writeByte(2)
      ..write(obj.calculationData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConditionalScoringAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
