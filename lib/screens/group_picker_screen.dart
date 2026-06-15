import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/online_session_provider.dart';

class GroupPickerScreen extends StatefulWidget {
  const GroupPickerScreen({super.key});

  @override
  State<GroupPickerScreen> createState() => _GroupPickerScreenState();
}

class _GroupPickerScreenState extends State<GroupPickerScreen> {
  final _createNameController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  bool _showCreateForm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnlineSessionProvider>().loadGroups();
    });
  }

  @override
  void dispose() {
    _createNameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final name = _createNameController.text.trim();
    if (name.isEmpty) return;
    await context.read<OnlineSessionProvider>().createGroup(name);
  }

  Future<void> _joinGroup() async {
    final code = _inviteCodeController.text.trim();
    if (code.isEmpty) return;
    await context.read<OnlineSessionProvider>().joinGroup(code);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<OnlineSessionProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Choose scorebook')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Pick your household scorebook, or join one with an invite code.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          if (session.errorMessage != null) ...[
            Text(
              session.errorMessage!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 12),
          ],
          if (session.loading && session.groups.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (session.groups.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No scorebooks yet. Join with an invite code below, '
                  'or create a new one.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            )
          else
            ...session.groups.map(
              (group) => Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
                    ),
                  ),
                  title: Text(
                    group.name,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text('${group.memberCount} member(s)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: session.loading
                      ? null
                      : () => session.selectGroup(group),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text('Join a scorebook', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _inviteCodeController,
            decoration: const InputDecoration(
              labelText: 'Invite code',
              hintText: 'Enter the code from a group member',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (_) => _joinGroup(),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: session.loading ? null : _joinGroup,
            child: const Text('Join scorebook'),
          ),
          const SizedBox(height: 32),
          if (!_showCreateForm)
            OutlinedButton(
              onPressed: session.loading
                  ? null
                  : () => setState(() => _showCreateForm = true),
              child: const Text('Create a new scorebook'),
            )
          else ...[
            Text('Create a scorebook', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _createNameController,
              decoration: const InputDecoration(
                labelText: 'Scorebook name',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              autofocus: true,
              onSubmitted: (_) => _createGroup(),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: session.loading ? null : _createGroup,
              child: const Text('Create'),
            ),
            TextButton(
              onPressed: () => setState(() {
                _showCreateForm = false;
                _createNameController.clear();
              }),
              child: const Text('Cancel'),
            ),
          ],
        ],
      ),
    );
  }
}
