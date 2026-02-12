import 'package:flutter/material.dart';
import 'package:super_app/core/constants/app_info.dart';
import 'package:super_app/core/l10n/app_localizations.dart';

/// Help & Report Screen
class HelpScreen extends StatelessWidget {
  final VoidCallback? onBackTap;

  const HelpScreen({
    super.key,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpAndSupport),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackTap ?? () => Navigator.of(context).pop(),
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
                    onPressed: () => _showReportDialog(context),
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

  void _showReportDialog(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.sendFeedback),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: l10n.feedbackHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.feedbackSubmittedThankYou),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(l10n.submit),
          ),
        ],
      ),
    );
  }
}
