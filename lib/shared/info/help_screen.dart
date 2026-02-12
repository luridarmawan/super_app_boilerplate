import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_app/core/constants/app_info.dart';
import 'package:super_app/core/l10n/app_localizations.dart';
import 'package:super_app/core/config/app_config.dart';
import 'package:super_app/core/network/api_client.dart';

/// Help & Report Screen
class HelpScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackTap;

  const HelpScreen({
    super.key,
    this.onBackTap,
  });

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpAndSupport),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackTap ?? () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search Box
          TextField(
            decoration: InputDecoration(
              hintText: l10n.searchHelpArticles,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Quick Help
          if (AppInfo.supportQuickHelpEnable) ...[
            Text(
              l10n.quickHelp,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),

            _buildHelpCategory(
              context,
              icon: Icons.account_circle_outlined,
              title: l10n.accountAndProfile,
              subtitle: l10n.manageAccountSettings,
            ),
            _buildHelpCategory(
              context,
              icon: Icons.payment_outlined,
              title: l10n.paymentsAndTransactions,
              subtitle: l10n.paymentMethodsHistory,
            ),
            _buildHelpCategory(
              context,
              icon: Icons.security_outlined,
              title: l10n.securityAndPrivacy,
              subtitle: l10n.accountSecurityPrivacy,
            ),
            _buildHelpCategory(
              context,
              icon: Icons.apps_outlined,
              title: l10n.usingTheApp,
              subtitle: l10n.featuresNavigationTips,
            ),

            const SizedBox(height: 24),
          ],

          // Contact Us
          Text(
            l10n.contactUs,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                if (AppInfo.supportLiveChatEnable) ...[
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.chat_outlined,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(l10n.liveChat),
                    subtitle: Text(l10n.chatWithSupport),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showContactDialog(context, l10n.liveChat),
                  ),
                  const Divider(height: 1),
                ],
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.email_outlined,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(l10n.emailSupport),
                  subtitle: Text(AppInfo.emailSupport),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showContactDialog(context, l10n.emailSupport),
                ),
                if (AppInfo.supportCallCenterEnable) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.phone_outlined,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(l10n.callCenter),
                    subtitle: Text('${AppInfo.phoneSupport} (${l10n.twentyFourHours})'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showContactDialog(context, l10n.callCenter),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Feedback & Ideas
          Text(
            l10n.feedbackAndIdeas,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.weLoveToHearFromYou,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.feedbackDesc,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showFeedbackDialog(context),
                    icon: const Icon(Icons.feedback_outlined),
                    label: Text(l10n.sendFeedback),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // FAQ
          Text(
            l10n.faq,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),

          _buildFaqItem(
            context,
            question: l10n.howToResetPassword,
            answer: l10n.resetPasswordAnswer,
          ),
          _buildFaqItem(
            context,
            question: l10n.howToUpdateProfile,
            answer: l10n.updateProfileAnswer,
          ),
          _buildFaqItem(
            context,
            question: l10n.howToContactSupport,
            answer: l10n.contactSupportAnswer,
          ),

          const SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _buildHelpCategory(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.opening} $title...'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context, String method) {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.opening} $method...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Validates the feedback message for suspicious or dangerous content.
  /// Returns null if valid, or an error message string if invalid.
  String? _validateFeedbackMessage(String message, AppLocalizations l10n) {
    final trimmed = message.trim();

    // Check empty
    if (trimmed.isEmpty) {
      return l10n.feedbackMessageRequired;
    }

    // Check minimum length
    if (trimmed.length < 10) {
      return l10n.feedbackMessageTooShort;
    }

    // Check for suspicious/dangerous patterns
    // - Script injection: <script>, javascript:, on[event]=
    // - SQL injection: common patterns like DROP TABLE, UNION SELECT, etc.
    // - Command injection: shell commands
    // - Excessive special characters
    final dangerousPatterns = [
      RegExp(r'<\s*script', caseSensitive: false),
      RegExp(r'javascript\s*:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
      RegExp(r'<\s*iframe', caseSensitive: false),
      RegExp(r'<\s*object', caseSensitive: false),
      RegExp(r'<\s*embed', caseSensitive: false),
      RegExp(r'<\s*form', caseSensitive: false),
      RegExp(r'<\s*img\s+[^>]*onerror', caseSensitive: false),
      RegExp(r"(DROP|DELETE|INSERT|UPDATE|ALTER)\s+(TABLE|DATABASE|INTO)", caseSensitive: false),
      RegExp(r"UNION\s+(ALL\s+)?SELECT", caseSensitive: false),
      RegExp(r";\s*(DROP|DELETE|INSERT|UPDATE|ALTER)\b", caseSensitive: false),
      RegExp(r'(--|/\*|\*/)', caseSensitive: false),
      RegExp(r'(\bexec\b|\beval\b)\s*\(', caseSensitive: false),
      RegExp(r'(\brm\s+-rf\b|\bsudo\b|\bchmod\b|\bchown\b)', caseSensitive: false),
      RegExp(r'(\\x[0-9a-fA-F]{2}|\\u[0-9a-fA-F]{4})', caseSensitive: false),
      RegExp(r'data\s*:\s*text/html', caseSensitive: false),
    ];

    for (final pattern in dangerousPatterns) {
      if (pattern.hasMatch(trimmed)) {
        return l10n.feedbackMessageInvalid;
      }
    }

    return null; // valid
  }

  void _showFeedbackDialog(BuildContext context) {
    final l10n = context.l10n;
    final feedbackUrl = AppInfo.supportFeedbackUrl;

    // Check if feedback URL is configured
    if (feedbackUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.feedbackUrlNotConfigured),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final messageController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l10n.sendFeedback),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                maxLines: 4,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: l10n.feedbackHint,
                  errorText: errorText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                // Validate message
                final validationError = _validateFeedbackMessage(
                  messageController.text,
                  l10n,
                );

                if (validationError != null) {
                  setDialogState(() {
                    errorText = validationError;
                  });
                  return;
                }

                // Close dialog and submit
                Navigator.of(dialogContext).pop();
                _submitFeedback(
                  context,
                  message: messageController.text.trim(),
                );
              },
              child: Text(l10n.submit),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeedback(
    BuildContext context, {
    required String message,
  }) async {
    final l10n = context.l10n;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show sending indicator
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Text(l10n.feedbackSending),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 30),
      ),
    );

    try {
      final user = ref.read(currentUserProvider);
      final dio = ref.read(dioProvider);

      final response = await dio.post(
        AppInfo.supportFeedbackUrl,
        data: {
          'name': user?.displayName ?? '',
          'email': user?.email ?? '',
          'message': message,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      debugPrint('[Feedback] Response status: ${response.statusCode}');
      debugPrint('[Feedback] Response data: ${response.data}');

      // Dismiss sending snackbar and show success
      scaffoldMessenger.hideCurrentSnackBar();

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(l10n.feedbackSubmittedThankYou),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(l10n.feedbackSendFailed),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } on DioException catch (e) {
      debugPrint('[Feedback] DioException: ${e.message}');
      debugPrint('[Feedback] Response: ${e.response?.data}');

      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(l10n.feedbackSendFailed),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (e) {
      debugPrint('[Feedback] Error: $e');

      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(l10n.feedbackSendFailed),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
