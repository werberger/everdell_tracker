import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/online_session_provider.dart';
import 'group_picker_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AppGateScreen extends StatefulWidget {
  const AppGateScreen({super.key});

  @override
  State<AppGateScreen> createState() => _AppGateScreenState();
}

class _AppGateScreenState extends State<AppGateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    final session = context.read<OnlineSessionProvider>();
    await auth.restoreSession();
    if (!mounted) return;
    if (auth.isAuthenticated) {
      await session.restoreActiveGroup();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final session = context.watch<OnlineSessionProvider>();

    if (auth.status == AuthStatus.unknown || auth.status == AuthStatus.checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    if (!session.hasActiveGroup) {
      return const GroupPickerScreen();
    }

    return const HomeScreen();
  }
}
