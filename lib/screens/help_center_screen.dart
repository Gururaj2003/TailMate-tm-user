import 'package:flutter/material.dart';
import 'package:tailmate/theme/app_theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            'Frequently Asked Questions',
            [
              'How do I book a service?',
              'How can I cancel a booking?',
              'What payment methods are accepted?',
              'How do I contact a service provider?',
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Contact Support',
            [
              'Email: support@tailmate.com',
              'Phone: +1 (555) 123-4567',
              'Live Chat: Available 24/7',
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Resources',
            [
              'User Guide',
              'Terms of Service',
              'Privacy Policy',
              'Community Guidelines',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
} 