import 'package:flutter/material.dart';
import 'package:tailmate/theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Acceptance of Terms',
              'By accessing and using TailMate, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              '2. Use License',
              'Permission is granted to temporarily use TailMate for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              '3. User Account',
              'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              '4. Service Booking',
              'All service bookings are subject to availability. We reserve the right to refuse or cancel any booking at any time for any reason.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              '5. Cancellation Policy',
              'Cancellations must be made at least 24 hours before the scheduled service. Late cancellations may be subject to fees.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              '6. Limitation of Liability',
              'TailMate shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the service.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              '7. Changes to Terms',
              'We reserve the right to modify these terms at any time. Your continued use of the service following any changes indicates your acceptance of the new terms.',
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