import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../providers/online_session_provider.dart';
import '../providers/player_provider.dart';
import 'home_screen.dart';

class ScorebookLoaderScreen extends StatefulWidget {
  const ScorebookLoaderScreen({super.key});

  @override
  State<ScorebookLoaderScreen> createState() => _ScorebookLoaderScreenState();
}

class _ScorebookLoaderScreenState extends State<ScorebookLoaderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadScorebook());
  }

  Future<void> _loadScorebook() async {
    final group = context.read<OnlineSessionProvider>().activeGroup;
    if (group == null) {
      return;
    }

    final gameProvider = context.read<GameProvider>();
    final playerProvider = context.read<PlayerProvider>();
    await Future.wait([
      gameProvider.loadGames(group.id),
      playerProvider.loadRoster(group.id),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final playerProvider = context.watch<PlayerProvider>();
    final loading = gameProvider.loading || playerProvider.loading;
    final error = gameProvider.errorMessage ?? playerProvider.errorMessage;

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(error, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loadScorebook,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const HomeScreen();
  }
}
