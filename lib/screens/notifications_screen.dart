import 'package:flutter/material.dart';
import 'package:tailmate/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: const Icon(Icons.notifications, color: AppTheme.primaryColor),
              ),
              title: Text('Notification ${index + 1}'),
              subtitle: const Text('This is a sample notification message'),
              trailing: const Text('2h ago', style: TextStyle(color: Colors.grey)),
            ),
          );
        },
      ),
    );
  }
} 