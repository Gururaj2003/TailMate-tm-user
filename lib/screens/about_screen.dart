import 'package:flutter/material.dart';
import 'package:tailmate/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About TailMate'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pets,
                  size: 60,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'TailMate',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              context,
              'About Us',
              'TailMate is your trusted companion in pet care. We connect pet owners with reliable and professional pet service providers to ensure your furry friends receive the best care possible.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Our Mission',
              'To make pet care accessible, convenient, and reliable for all pet owners while providing opportunities for passionate pet care professionals.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Contact Information',
              'Email: support@tailmate.com\nPhone: +1 (555) 123-4567\nAddress: 123 Pet Street, Pawsome City, PC 12345',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Follow Us',
              'Stay connected with us on social media for updates, tips, and pet care advice.',
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(Icons.public, () {}),
                const SizedBox(width: 16),
                _buildSocialButton(Icons.alternate_email, () {}),
                const SizedBox(width: 16),
                _buildSocialButton(Icons.photo_camera, () {}),
              ],
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

  Widget _buildSocialButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 32,
      color: AppTheme.primaryColor,
    );
  }
} 