import 'package:flutter/material.dart';
import 'package:super_app/core/constants/app_info.dart';

/// Terms of Service Screen
class TosScreen extends StatelessWidget {
  final VoidCallback? onBackTap;

  const TosScreen({
    super.key,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
                    Icons.description_outlined,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terms of Service',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          'Last updated: December 2024',
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
              title: '1. Acceptance of Terms',
              content:
                  'By accessing and using Super App, you accept and agree to be bound by the terms and provisions of this agreement. If you do not agree to these terms, please do not use our services.',
            ),

            _buildSection(
              context,
              title: '2. Use License',
              content:
                  'Permission is granted to temporarily download one copy of Super App for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title.',
            ),

            _buildSection(
              context,
              title: '3. User Account',
              content:
                  'To use certain features of Super App, you must register for an account. You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account.',
            ),

            _buildSection(
              context,
              title: '4. Privacy',
              content:
                  'Your use of Super App is also governed by our Privacy Policy. Please review our Privacy Policy, which also governs the Site and informs users of our data collection practices.',
            ),

            _buildSection(
              context,
              title: '5. User Conduct',
              content:
                  'You agree not to use Super App for any unlawful purpose or any purpose prohibited under this clause. You agree not to use Super App in any way that could damage, disable, overburden, or impair the service.',
            ),

            _buildSection(
              context,
              title: '6. Intellectual Property',
              content:
                  'Super App and its original content, features, and functionality are owned by Super App and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.',
            ),

            _buildSection(
              context,
              title: '7. Termination',
              content:
                  'We may terminate or suspend your account and bar access to Super App immediately, without prior notice or liability, under our sole discretion, for any reason whatsoever and without limitation.',
            ),

            _buildSection(
              context,
              title: '8. Limitation of Liability',
              content:
                  'In no event shall Super App, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages.',
            ),

            _buildSection(
              context,
              title: '9. Changes to Terms',
              content:
                  'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. We will provide notice of any changes by posting the new Terms on this page.',
            ),

            _buildSection(
              context,
              title: '10. Contact Information',
              content:
                  'If you have any questions about these Terms, please contact us at:\n\nEmail: ${AppInfo.emailSupport}\nPhone: ${AppInfo.phoneSupport}\nAddress: Jakarta, Indonesia',
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
