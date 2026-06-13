import 'package:agro_spray/core/routes/app_routes.dart';
import 'package:agro_spray/core/utils/request_state.dart';
import 'package:agro_spray/core/utils/validators.dart';
import 'package:agro_spray/providers/auth_provider.dart';
import 'package:agro_spray/widgets/app_text_field.dart';
import 'package:agro_spray/widgets/loading_overlay.dart';
import 'package:agro_spray/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await context.read<AuthProvider>().register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
    if (!mounted) {
      return;
    }
    final authProvider = context.read<AuthProvider>();
    if (authProvider.status == RequestStatus.success && authProvider.user != null) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return LoadingOverlay(
      isLoading: authProvider.status == RequestStatus.loading,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Create account', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text('Set up your AgroSpray workspace in minutes.', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 24),
                      AppTextField(label: 'Full name', controller: _nameController, validator: (value) => Validators.requiredField(value, fieldName: 'Full name'), prefixIcon: Icons.person_outline),
                      const SizedBox(height: 16),
                      AppTextField(label: 'Email', controller: _emailController, validator: Validators.email, keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined),
                      const SizedBox(height: 16),
                      AppTextField(label: 'Password', controller: _passwordController, validator: Validators.password, obscureText: _obscurePassword, prefixIcon: Icons.lock_outline, suffixIcon: _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, onSuffixPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                      const SizedBox(height: 16),
                      AppTextField(label: 'Confirm password', controller: _confirmPasswordController, validator: (value) => Validators.confirmPassword(value, _passwordController.text), obscureText: true, prefixIcon: Icons.lock_reset_outlined),
                      const SizedBox(height: 24),
                      PrimaryButton(label: 'Register', onPressed: _register, icon: Icons.person_add_alt_1_rounded),
                      if (authProvider.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(authProvider.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?'),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                            child: const Text('Sign in'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
