import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
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
