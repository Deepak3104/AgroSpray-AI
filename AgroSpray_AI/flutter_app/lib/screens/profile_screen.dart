import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(auth.user?.displayName?.isNotEmpty == true ? auth.user!.displayName![0].toUpperCase() : 'A')),
              title: Text(auth.user?.displayName ?? 'AgroSpray User'),
              subtitle: Text(auth.user?.email ?? ''),
            ),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            value: theme.themeMode == ThemeMode.dark,
            title: const Text('Dark mode'),
            onChanged: (value) => context.read<ThemeProvider>().setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
