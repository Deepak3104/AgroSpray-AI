import 'package:agro_spray/core/routes/app_routes.dart';
import 'package:agro_spray/core/utils/request_state.dart';
import 'package:agro_spray/core/utils/validators.dart';
import 'package:agro_spray/providers/profile_provider.dart';
import 'package:agro_spray/providers/theme_provider.dart';
import 'package:agro_spray/widgets/app_text_field.dart';
import 'package:agro_spray/widgets/loading_overlay.dart';
import 'package:agro_spray/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _loadedName;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final profileProvider = context.read<ProfileProvider>();
    if (_nameController.text.trim().isNotEmpty) {
      await profileProvider.updateName(_nameController.text.trim());
    }
    if (_passwordController.text.isNotEmpty) {
      await profileProvider.changePassword(_passwordController.text);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = profileProvider.user;

    if (user?.name != null && user!.name != _loadedName) {
      _loadedName = user.name;
      _nameController.text = user.name;
    }

    return LoadingOverlay(
      isLoading: profileProvider.status == RequestStatus.loading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'A')),
                title: Text(user?.name ?? 'AgroSpray User'),
                subtitle: Text(user?.email ?? ''),
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(label: 'Full name', controller: _nameController, validator: (value) => Validators.requiredField(value, fieldName: 'Full name'), prefixIcon: Icons.person_outline),
                  const SizedBox(height: 16),
                  AppTextField(label: 'New password', controller: _passwordController, validator: (value) => value != null && value.isNotEmpty ? Validators.password(value) : null, obscureText: true, prefixIcon: Icons.lock_outline),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Confirm new password',
                    controller: _passwordConfirmController,
                    validator: (value) {
                      if (_passwordController.text.isEmpty && (value == null || value.isEmpty)) {
                        return null;
                      }
                      return Validators.confirmPassword(value, _passwordController.text);
                    },
                    obscureText: true,
                    prefixIcon: Icons.lock_reset_outlined,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(label: 'Update profile', onPressed: _updateProfile, icon: Icons.save_rounded),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (value) => context.read<ThemeProvider>().toggleDarkMode(value),
                    title: const Text('Dark mode'),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<ProfileProvider>().logout();
                      if (mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                      }
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
