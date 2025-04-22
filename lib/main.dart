import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailmate/config/supabase_config.dart';
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
import 'package:tailmate/models/service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Validate Supabase configuration
    SupabaseConfig.validateConfig();
    
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: true,
    );
    print('Supabase initialized successfully');
  } catch (e, stackTrace) {
    print('Error initializing Supabase: $e');
    print('Stack trace: $stackTrace');
    // You might want to show an error dialog or handle this differently
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
    
    return MaterialApp(
      title: 'TailMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const OnboardingScreen(), // Start with onboarding screen
      routes: {
        '/chat': (context) => ChatScreen(
              provider: ModalRoute.of(context)!.settings.arguments
                  as ServiceProviderModel,
            ),
        '/chat-history': (context) => const ChatHistoryScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/service_providers': (context) {
          final service = ModalRoute.of(context)!.settings.arguments as Service;
          return ServiceProvidersScreen(service: service);
        },
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