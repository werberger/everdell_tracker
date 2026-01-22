import 'package:hive/hive.dart';

part 'expansion.g.dart';

@HiveType(typeId: 2)
enum Expansion {
  @HiveField(0)
  base,
  @HiveField(1)
  pearlbrook,
  @HiveField(2)
  spirecrest,
  @HiveField(3)
  bellfaire,
  @HiveField(4)
  mistwood,
  @HiveField(5)
  newleaf,
}

extension ExpansionLabel on Expansion {
  String get label {
    switch (this) {
      case Expansion.base:
        return 'Base';
      case Expansion.pearlbrook:
        return 'Pearlbrook';
      case Expansion.spirecrest:
        return 'Spirecrest';
      case Expansion.bellfaire:
        return 'Bellfaire';
      case Expansion.mistwood:
        return 'Mistwood';
      case Expansion.newleaf:
        return 'Newleaf';
    }
  }

  // JSON serialization
  String toJson() => name;
}

// Helper function for JSON deserialization
Expansion expansionFromJson(String json) {
  return Expansion.values.firstWhere((e) => e.name == json);
}
