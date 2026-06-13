import 'package:agro_spray/core/utils/request_state.dart';
import 'package:agro_spray/core/utils/validators.dart';
import 'package:agro_spray/providers/auth_provider.dart';
import 'package:agro_spray/widgets/app_text_field.dart';
import 'package:agro_spray/widgets/loading_overlay.dart';
import 'package:agro_spray/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await context.read<AuthProvider>().forgotPassword(_emailController.text.trim());
    if (!mounted) {
      return;
    }
    final message = context.read<AuthProvider>().status == RequestStatus.success
        ? 'Password reset email sent.'
        : context.read<AuthProvider>().errorMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return LoadingOverlay(
      isLoading: authProvider.status == RequestStatus.loading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Reset password')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Forgot password?', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text('Enter your email and we will send a secure reset link.', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'Email',
                      controller: _emailController,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(label: 'Send reset link', onPressed: _submit, icon: Icons.send_rounded),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
