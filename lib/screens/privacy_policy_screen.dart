import 'package:flutter/material.dart';
import 'package:tailmate/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Information We Collect',
              'We collect information that you provide directly to us, including your name, email address, phone number, and pet information when you register for an account or use our services.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              '2. How We Use Your Information',
              'We use the information we collect to provide, maintain, and improve our services, to communicate with you, and to personalize your experience.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              '3. Information Sharing',
              'We do not share your personal information with third parties except as described in this policy or with your consent.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              '4. Data Security',
              'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              '5. Your Rights',
              'You have the right to access, correct, or delete your personal information. You can also object to or restrict certain processing of your information.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              '6. Contact Us',
              'If you have any questions about this Privacy Policy, please contact us at privacy@tailmate.com.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
} 