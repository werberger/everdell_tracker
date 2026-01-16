import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  final bool separatePointTokens;

  @HiveField(1)
  final bool autoConvertResources;

  @HiveField(2)
  final bool darkMode;

  AppSettings({
    required this.separatePointTokens,
    required this.autoConvertResources,
    required this.darkMode,
  });

  factory AppSettings.defaults() {
    return AppSettings(
      separatePointTokens: true,
      autoConvertResources: true,
      darkMode: false,
    );
  }

  AppSettings copyWith({
    bool? separatePointTokens,
    bool? autoConvertResources,
    bool? darkMode,
  }) {
    return AppSettings(
      separatePointTokens: separatePointTokens ?? this.separatePointTokens,
      autoConvertResources: autoConvertResources ?? this.autoConvertResources,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
