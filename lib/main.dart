import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';
import 'providers/online_session_provider.dart';
import 'providers/player_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/app_gate_screen.dart';
import 'services/everdell_api/everdell_api_service.dart';
import 'services/platform_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlatformStorageService.initialize();
  runApp(const EverdellApp());
}

class EverdellApp extends StatelessWidget {
  const EverdellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<EverdellApiService>(
          create: (_) => EverdellApiService(),
          dispose: (_, api) => api.dispose(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              AuthProvider(api: context.read<EverdellApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              OnlineSessionProvider(api: context.read<EverdellApiService>()),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (context) => GameProvider(
            api: context.read<EverdellApiService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => PlayerProvider(
            api: context.read<EverdellApiService>(),
          ),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Everdell Tracker',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green,
                brightness: Brightness.dark,
              ),
            ),
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AppGateScreen(),
          );
        },
      ),
    );
  }
}
