import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailmate/theme/app_theme.dart';
import 'package:tailmate/screens/settings_screen.dart';
import 'package:tailmate/screens/payment_screen.dart';
import 'package:tailmate/providers/user_provider.dart';
import 'package:tailmate/screens/auth/login_screen.dart';
import 'package:tailmate/screens/edit_profile_screen.dart';
import 'package:tailmate/screens/notifications_screen.dart';
import 'package:tailmate/screens/help_center_screen.dart';
import 'package:tailmate/screens/feedback_screen.dart';
import 'package:tailmate/screens/about_screen.dart';
import 'package:tailmate/screens/privacy_policy_screen.dart';
import 'package:tailmate/screens/terms_screen.dart';
import 'package:tailmate/screens/booking_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.userProfile;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user?.profileImage != null
                            ? NetworkImage(user!.profileImage!)
                            : null,
                        child: user?.profileImage == null
                            ? const Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? 'Guest User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Account Settings'),
                    _buildMenuItem(
                      context,
                      'Edit Profile',
                      Icons.edit,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      'Notifications',
                      Icons.notifications,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      'Payment Methods',
                      Icons.payment,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentScreen(),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      'Booking History',
                      Icons.history,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BookingHistoryScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Support'),
                    _buildMenuItem(
                      context,
                      'Help Center',
                      Icons.help,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpCenterScreen(),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      'Feedback',
                      Icons.feedback,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeedbackScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'About'),
                    _buildMenuItem(
                      context,
                      'About TailMate',
                      Icons.info,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      'Privacy Policy',
                      Icons.privacy_tip,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      'Terms of Service',
                      Icons.description,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildMenuItem(
                      context,
                      'Sign Out',
                      Icons.logout,
                      () async {
                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        await userProvider.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                      isSignOut: true,
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isSignOut = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSignOut ? Colors.red : AppTheme.primaryColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSignOut ? Colors.red : null,
          ),
        ),
        trailing: isSignOut
            ? null
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
} 