import 'package:hive/hive.dart';

part 'app_settings.g.dart';

enum CardEntryMethod {
  simple,
  byType,
  byColor,
  visual, // Visual card selection method
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

  @HiveField(4)
  final bool useFanLayout; // true = fan/carousel, false = table top/grid

  AppSettings({
    required this.separatePointTokens,
    required this.autoConvertResources,
    required this.darkMode,
    this.cardEntryMethodIndex,
    this.useFanLayout = false, // Default to table top
  });

  CardEntryMethod get cardEntryMethod =>
      CardEntryMethod.values[cardEntryMethodIndex ?? 0];

  factory AppSettings.defaults() {
    return AppSettings(
      separatePointTokens: true,
      autoConvertResources: true,
      darkMode: false,
      cardEntryMethodIndex: 3, // visual = index 3
      useFanLayout: false, // Default to table top
    );
  }

  AppSettings copyWith({
    bool? separatePointTokens,
    bool? autoConvertResources,
    bool? darkMode,
    int? cardEntryMethodIndex,
    bool? useFanLayout,
  }) {
    return AppSettings(
      separatePointTokens: separatePointTokens ?? this.separatePointTokens,
      autoConvertResources: autoConvertResources ?? this.autoConvertResources,
      darkMode: darkMode ?? this.darkMode,
      cardEntryMethodIndex: cardEntryMethodIndex ?? (this.cardEntryMethodIndex ?? 0),
      useFanLayout: useFanLayout ?? this.useFanLayout,
    );
  }
}
