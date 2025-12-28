import 'package:flutter/material.dart';
import 'package:super_app/core/constants/app_info.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
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
              hintText: 'Search help articles...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Quick Help
          Text(
            'Quick Help',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),

          _buildHelpCategory(
            context,
            icon: Icons.account_circle_outlined,
            title: 'Account & Profile',
            subtitle: 'Manage your account settings',
          ),
          _buildHelpCategory(
            context,
            icon: Icons.payment_outlined,
            title: 'Payments & Transactions',
            subtitle: 'Payment methods, history, refunds',
          ),
          _buildHelpCategory(
            context,
            icon: Icons.security_outlined,
            title: 'Security & Privacy',
            subtitle: 'Account security, privacy settings',
          ),
          _buildHelpCategory(
            context,
            icon: Icons.apps_outlined,
            title: 'Using the App',
            subtitle: 'Features, navigation, tips',
          ),

          const SizedBox(height: 24),

          // Contact Us
          Text(
            'Contact Us',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
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
                  title: const Text('Live Chat'),
                  subtitle: const Text('Chat with our support team'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showContactDialog(context, 'Live Chat'),
                ),
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
                      Icons.email_outlined,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: const Text('Email Support'),
                  subtitle: Text(AppInfo.emailSupport),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showContactDialog(context, 'Email'),
                ),
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
                  title: const Text('Call Center'),
                  subtitle: Text('${AppInfo.phoneSupport} (24 hours)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showContactDialog(context, 'Phone'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Report Issue
          Text(
            'Report an Issue',
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
                    'Having trouble?',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let us know about any issues you experience. We\'ll get back to you as soon as possible.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showReportDialog(context),
                    icon: const Icon(Icons.bug_report_outlined),
                    label: const Text('Report an Issue'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // FAQ
          Text(
            'Frequently Asked Questions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),

          _buildFaqItem(
            context,
            question: 'How do I reset my password?',
            answer:
                'You can reset your password by going to Settings > Account > Change Password, or use the "Forgot Password" option on the login screen.',
          ),
          _buildFaqItem(
            context,
            question: 'How do I update my profile?',
            answer:
                'Go to Profile > Edit Profile to update your personal information, profile picture, and other details.',
          ),
          _buildFaqItem(
            context,
            question: 'How do I contact customer support?',
            answer:
                'You can reach us through Live Chat, Email, or Call Center. Check the "Contact Us" section above for details.',
          ),

          const SizedBox(height: 32),
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
              content: Text('Opening $title...'),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $method...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report an Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the issue you\'re experiencing...',
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
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report submitted. Thank you!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
