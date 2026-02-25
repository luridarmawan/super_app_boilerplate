import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_info.dart';
import '../../core/l10n/app_localizations.dart';

/// Forgot Password Screen
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackTap;

  const ForgotPasswordScreen({
    super.key,
    this.onBackTap,
  });

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: AppInfo.usernameDefault);
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.forgotPassword),
        leading: widget.onBackTap != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBackTap,
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Icon Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Description
                Text(
                  l10n.forgotPassword,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.forgotPasswordDesc,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterEmail;
                    }
                    if (!value.contains('@')) {
                      return l10n.pleaseEnterValidEmail;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleResetPassword(),
                ),

                const SizedBox(height: 32),

                // Reset Button
                FilledButton(
                  onPressed: _isLoading ? null : _handleResetPassword,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.resetPassword),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final email = _emailController.text.trim();

      final result = await authService.sendPasswordResetEmail(email);

      if (mounted) {
        setState(() => _isLoading = false);

        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).resetEmailSent),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          // Go back after a delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              widget.onBackTap?.call();
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Error resetting password'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
