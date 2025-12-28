import 'package:flutter/material.dart';
import 'package:super_app/core/constants/app_info.dart';

/// Privacy Policy Screen
class PrivacyScreen extends StatelessWidget {
  final VoidCallback? onBackTap;

  const PrivacyScreen({
    super.key,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackTap ?? () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacy Policy',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          'Last updated: Mei 2025',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onPrimaryContainer
                                        .withValues(alpha: 0.8),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildSection(
              context,
              title: 'Introduction',
              content:
                  'Super App ("we" or "us" or "our") respects the privacy of our users ("user" or "you"). This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
            ),

            _buildSection(
              context,
              title: 'Information We Collect',
              content:
                  'We may collect information about you in a variety of ways including:\n\n'
                  '• Personal Data: Name, email address, phone number, profile picture\n'
                  '• Transaction Data: Payment information, transaction history\n'
                  '• Device Data: Device type, operating system, unique device identifiers\n'
                  '• Usage Data: How you interact with our app, features used, time spent',
            ),

            _buildSection(
              context,
              title: 'How We Use Your Information',
              content:
                  'We use the information we collect to:\n\n'
                  '• Provide, maintain, and improve our services\n'
                  '• Process transactions and send related information\n'
                  '• Send promotional communications (with your consent)\n'
                  '• Respond to your comments and questions\n'
                  '• Protect against fraud and unauthorized transactions',
            ),

            _buildSection(
              context,
              title: 'Data Sharing',
              content:
                  'We may share your information with:\n\n'
                  '• Service providers who assist in our operations\n'
                  '• Business partners for joint offerings\n'
                  '• Law enforcement when required by law\n'
                  '• Third parties with your consent',
            ),

            _buildSection(
              context,
              title: 'Data Security',
              content:
                  'We implement appropriate technical and organizational security measures to protect your personal information. However, no method of transmission over the Internet or electronic storage is 100% secure.',
            ),

            _buildSection(
              context,
              title: 'Your Rights',
              content:
                  'You have the right to:\n\n'
                  '• Access your personal data\n'
                  '• Correct inaccurate data\n'
                  '• Request deletion of your data\n'
                  '• Object to processing of your data\n'
                  '• Data portability',
            ),

            _buildSection(
              context,
              title: 'Cookies and Tracking',
              content:
                  'We may use cookies and similar tracking technologies to track activity on our app and store certain information. You can instruct your device to refuse all cookies or to indicate when a cookie is being sent.',
            ),

            _buildSection(
              context,
              title: "Children's Privacy",
              content:
                  'Our app is not intended for children under 13. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and you are aware that your child has provided us with personal data, please contact us.',
            ),

            _buildSection(
              context,
              title: 'Changes to This Policy',
              content:
                  'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
            ),

            _buildSection(
              context,
              title: 'Contact Us',
              content:
                  'If you have any questions about this Privacy Policy, please contact us at:\n\n'
                  'Email: ${AppInfo.emailSupport}\n'
                  'Phone: ${AppInfo.phoneSupport}\n'
                  'Address: Jakarta, Indonesia',
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}
