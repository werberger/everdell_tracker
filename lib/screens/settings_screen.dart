import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../providers/online_session_provider.dart';
import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';
import 'app_gate_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final session = context.watch<OnlineSessionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          if (auth.profile != null) ...[
            ListTile(
              title: Text(auth.profile!.displayName),
              subtitle: Text(
                session.activeGroup != null
                    ? 'Scorebook: ${session.activeGroup!.name}'
                    : 'No scorebook selected',
              ),
            ),
            if (session.activeGroup != null &&
                session.activeGroup!.inviteCode.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.key_outlined),
                title: const Text('Invite code'),
                subtitle: Text(
                  session.activeGroup!.inviteCode,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy_outlined),
                  tooltip: 'Copy invite code',
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: session.activeGroup!.inviteCode),
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invite code copied to clipboard'),
                      ),
                    );
                  },
                ),
              ),
            ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: const Text('Change scorebook'),
              onTap: () async {
                context.read<GameProvider>().clearGames();
                context.read<PlayerProvider>().clearRoster();
                await session.clearActiveGroup();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AppGateScreen()),
                  (_) => false,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () async {
                context.read<GameProvider>().clearGames();
                context.read<PlayerProvider>().clearRoster();
                await session.clearActiveGroup();
                await auth.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AppGateScreen()),
                  (_) => false,
                );
              },
            ),
            const Divider(),
          ],
          SwitchListTile(
            title: const Text('Separate Point Tokens'),
            subtitle: const Text('Track point tokens separately from cards'),
            value: settings.separatePointTokens,
            onChanged: settings.setSeparatePointTokens,
          ),
          SwitchListTile(
            title: const Text('Auto-convert Resources'),
            subtitle: const Text('Convert 3 resources into 1 point'),
            value: settings.autoConvertResources,
            onChanged: settings.setAutoConvertResources,
          ),
          const Divider(),
          ListTile(
            title: const Text('Card Entry Method'),
            subtitle: const Text('How to enter card points'),
          ),
          RadioListTile<CardEntryMethod>(
            title: const Text('Simple'),
            subtitle: const Text('Construction & Critter Points (total)'),
            value: CardEntryMethod.simple,
            groupValue: settings.cardEntryMethod,
            onChanged: (value) {
              if (value != null) settings.setCardEntryMethod(value);
            },
          ),
          RadioListTile<CardEntryMethod>(
            title: const Text('By Type'),
            subtitle: const Text('Separate Construction and Critter points'),
            value: CardEntryMethod.byType,
            groupValue: settings.cardEntryMethod,
            onChanged: (value) {
              if (value != null) settings.setCardEntryMethod(value);
            },
          ),
          RadioListTile<CardEntryMethod>(
            title: const Text('By Card Color'),
            subtitle: const Text('Track points by card color (Green, Red, Blue, Tan, Purple)'),
            value: CardEntryMethod.byColor,
            groupValue: settings.cardEntryMethod,
            onChanged: (value) {
              if (value != null) settings.setCardEntryMethod(value);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Visual Card Selection Layout'),
            subtitle: const Text('Choose how cards are displayed when selecting cards'),
          ),
          RadioListTile<bool>(
            title: const Text('Table Top (Grid)'),
            subtitle: const Text('Cards displayed in organized grid by type'),
            value: false,
            groupValue: settings.settings.useFanLayout,
            onChanged: (value) {
              if (value != null) settings.setUseFanLayout(value);
            },
          ),
          RadioListTile<bool>(
            title: const Text('Fan (Carousel)'),
            subtitle: const Text('Cards displayed in hand-like fan with swipe navigation'),
            value: true,
            groupValue: settings.settings.useFanLayout,
            onChanged: (value) {
              if (value != null) settings.setUseFanLayout(value);
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: settings.darkMode,
            onChanged: settings.setDarkMode,
          ),
        ],
      ),
    );
  }
}
