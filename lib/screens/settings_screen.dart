import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
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
