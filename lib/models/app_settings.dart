import 'package:hive/hive.dart';

part 'app_settings.g.dart';

enum CardEntryMethod {
  simple,
  byType,
  byColor,
}

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  final bool separatePointTokens;

  @HiveField(1)
  final bool autoConvertResources;

  @HiveField(2)
  final bool darkMode;

  @HiveField(3)
  final int? cardEntryMethodIndex;

  AppSettings({
    required this.separatePointTokens,
    required this.autoConvertResources,
    required this.darkMode,
    this.cardEntryMethodIndex,
  });

  CardEntryMethod get cardEntryMethod =>
      CardEntryMethod.values[cardEntryMethodIndex ?? 0];

  factory AppSettings.defaults() {
    return AppSettings(
      separatePointTokens: true,
      autoConvertResources: true,
      darkMode: false,
      cardEntryMethodIndex: 0,
    );
  }

  AppSettings copyWith({
    bool? separatePointTokens,
    bool? autoConvertResources,
    bool? darkMode,
    int? cardEntryMethodIndex,
  }) {
    return AppSettings(
      separatePointTokens: separatePointTokens ?? this.separatePointTokens,
      autoConvertResources: autoConvertResources ?? this.autoConvertResources,
      darkMode: darkMode ?? this.darkMode,
      cardEntryMethodIndex: cardEntryMethodIndex ?? (this.cardEntryMethodIndex ?? 0),
    );
  }
}
