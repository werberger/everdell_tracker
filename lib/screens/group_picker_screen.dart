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

    return Scaffold(
      appBar: AppBar(title: const Text('Choose scorebook')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Pick the Everdell group for this device. Games will sync with other members of that group.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (session.errorMessage != null) ...[
            Text(
              session.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 12),
          ],
          if (session.loading && session.groups.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ))
          else if (session.groups.isEmpty)
            const Text('No groups yet. Create one or join with an invite code.')
          else
            ...session.groups.map(
              (group) => Card(
                child: ListTile(
                  title: Text(group.name),
                  subtitle: Text('${group.memberCount} member(s)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: session.loading
                      ? null
                      : () => session.selectGroup(group),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text('Create a group', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _createNameController,
            decoration: const InputDecoration(
              labelText: 'Group name',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _createGroup(),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: session.loading ? null : _createGroup,
            child: const Text('Create group'),
          ),
          const SizedBox(height: 24),
          Text('Join a group', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _inviteCodeController,
            decoration: const InputDecoration(
              labelText: 'Invite code',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (_) => _joinGroup(),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: session.loading ? null : _joinGroup,
            child: const Text('Join group'),
          ),
        ],
      ),
    );
  }
}
