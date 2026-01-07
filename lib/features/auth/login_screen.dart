import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_info.dart';
import '../../core/l10n/app_localizations.dart';

/// Login Screen
class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onRegisterTap;
  final VoidCallback? onForgotPasswordTap;

  const LoginScreen({
    super.key,
    this.onLoginSuccess,
    this.onRegisterTap,
    this.onForgotPasswordTap,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: AppInfo.usernameDefault);
  final _passwordController = TextEditingController(text: AppInfo.passwordDefault);
  bool _isLoading = false;
  bool _obscurePassword = true;

  // @override
  // void initState() {
  //   super.initState();
  //   print('usernameDefault: "${AppInfo.usernameDefault}"');
  //   print('passwordDefault: "${AppInfo.passwordDefault}"');
  // }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: size.height * 0.08),

                // Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        AppInfo.launcherIcon,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.apps_rounded,
                          size: 56,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue to Super App',
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
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleLogin(),
                ),

                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: widget.onForgotPasswordTap,
                    child: const Text('Forgot Password?'),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Button
                FilledButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign In'),
                ),

                // Google Login Section (conditional)
                if (AppInfo.enableGoogleLogin) ...[
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: colorScheme.outline)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or continue with',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      Expanded(child: Divider(color: colorScheme.outline)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Social Login Buttons
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleLogin,
                    icon: Icon(
                      Icons.g_mobiledata,
                      size: 24,
                      color: colorScheme.primary,
                    ),
                    label: const Text('Continue with Google'),
                  ),
                ],

                const SizedBox(height: 32),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: widget.onRegisterTap,
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    debugPrint('[LOGIN_SCREEN] >>> _handleLogin() called');
    
    if (!_formKey.currentState!.validate()) {
      debugPrint('[LOGIN_SCREEN] Form validation failed');
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    debugPrint('[LOGIN_SCREEN] Attempting login with email: $email');
    debugPrint('[LOGIN_SCREEN] Password length: ${password.length}');

    setState(() => _isLoading = true);

    try {
      debugPrint('[LOGIN_SCREEN] Getting authService from provider...');
      final authService = ref.read(authServiceProvider);
      debugPrint('[LOGIN_SCREEN] authService type: ${authService.runtimeType}');
      
      debugPrint('[LOGIN_SCREEN] Calling signInWithEmailAndPassword...');
      final result = await authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('[LOGIN_SCREEN] <<< Login result received:');
      debugPrint('[LOGIN_SCREEN]   success: ${result.success}');
      debugPrint('[LOGIN_SCREEN]   errorMessage: ${result.errorMessage}');
      debugPrint('[LOGIN_SCREEN]   user: ${result.user?.email ?? "null"}');

      if (mounted) {
        setState(() => _isLoading = false);

        if (result.success) {
          debugPrint('[LOGIN_SCREEN] Login SUCCESS, calling onLoginSuccess callback');
          widget.onLoginSuccess?.call();
        } else {
          final errorMsg = result.errorMessage ?? 'Login failed';
          debugPrint('[LOGIN_SCREEN] Login FAILED: $errorMsg');

          // Use localized message in production, show detailed error only in debug
          final l10n = AppLocalizations.of(context);
          final displayMessage = kReleaseMode 
              ? l10n.loginFailed 
              : 'ERR: $errorMsg';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(displayMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[LOGIN_SCREEN] !!! EXCEPTION caught: $e');
      debugPrint('[LOGIN_SCREEN] StackTrace: $stackTrace');
      if (mounted) {
        setState(() => _isLoading = false);

        // Use localized message in production, show detailed error only in debug
        final l10n = AppLocalizations.of(context);
        final displayMessage = kReleaseMode 
            ? l10n.loginFailed 
            : '${l10n.loginFailed}: ${e.toString()}';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(displayMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.signInWithGoogle();

      if (mounted) {
        setState(() => _isLoading = false);

        if (result.success) {
          widget.onLoginSuccess?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Google login failed'),
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
