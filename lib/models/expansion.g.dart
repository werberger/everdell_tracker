// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expansion.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpansionAdapter extends TypeAdapter<Expansion> {
  @override
  final int typeId = 2;

  @override
  Expansion read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Expansion.base;
      case 1:
        return Expansion.pearlbrook;
      case 2:
        return Expansion.spirecrest;
      case 3:
        return Expansion.bellfaire;
      case 4:
        return Expansion.mistwood;
      case 5:
        return Expansion.newleaf;
      default:
        return Expansion.base;
    }
  }

  @override
  void write(BinaryWriter writer, Expansion obj) {
    switch (obj) {
      case Expansion.base:
        writer.writeByte(0);
        break;
      case Expansion.pearlbrook:
        writer.writeByte(1);
        break;
      case Expansion.spirecrest:
        writer.writeByte(2);
        break;
      case Expansion.bellfaire:
        writer.writeByte(3);
        break;
      case Expansion.mistwood:
        writer.writeByte(4);
        break;
      case Expansion.newleaf:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpansionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
