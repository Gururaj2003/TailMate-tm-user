import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailmate/screens/splash_screen.dart';
import 'package:tailmate/theme/app_theme.dart';
import 'package:tailmate/providers/theme_provider.dart';
import 'package:tailmate/providers/pet_provider.dart';
import 'package:tailmate/providers/service_provider.dart';
import 'package:tailmate/providers/chat_provider.dart';
import 'package:tailmate/providers/user_provider.dart';
import 'package:tailmate/screens/chat_screen.dart';
import 'package:tailmate/screens/home_screen.dart';
import 'package:tailmate/screens/auth/login_screen.dart';
import 'package:tailmate/screens/pet_detail_screen.dart';
import 'package:tailmate/screens/pet_list_screen.dart';
import 'package:tailmate/screens/profile_screen.dart';
import 'package:tailmate/screens/auth/register_screen.dart';
import 'package:tailmate/screens/service_details_screen.dart';
import 'package:tailmate/screens/service_provider_details.dart';
import 'package:tailmate/screens/service_providers_screen.dart';
import 'package:tailmate/screens/services_tab.dart';
import 'package:tailmate/screens/settings_screen.dart';
import 'package:tailmate/screens/onboarding_screen.dart';
import 'package:tailmate/models/service_provider_model.dart';
import 'package:tailmate/screens/chat_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Supabase.initialize(
      url: 'https://vbbjpxjubbfjcgtiituc.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZiYmpweGp1YmJmamNndGlpdHVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEyNDE2ODIsImV4cCI6MjA1NjgxNzY4Mn0.cU73zqfgob-Ho0SZzZTwtuv_BVbphwb4bzV6LdjNUQk',
      debug: true, // Enable debug mode for more detailed logs
    );
    print('Supabase initialized successfully');
  } catch (e) {
    print('Error initializing Supabase: $e');
    // Show error dialog or handle the error appropriately
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const TailMateApp(),
    ),
  );
}

class TailMateApp extends StatelessWidget {
  const TailMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final supabase = Supabase.instance.client;
    
    return MaterialApp(
      title: 'TailMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasError) {
            print('Auth state error: ${snapshot.error}');
            return const OnboardingScreen();
          }

          final session = snapshot.data?.session;
          if (session == null) {
            return const OnboardingScreen();
          }

          return const HomeScreen();
        },
      ),
      routes: {
        '/chat': (context) => ChatScreen(
              provider: ModalRoute.of(context)!.settings.arguments
                  as ServiceProviderModel,
            ),
        '/chat-history': (context) => const ChatHistoryScreen(),
      },
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(
            physics: const BouncingScrollPhysics(),
          ),
          child: child!,
        );
      },
    );
  }
} 