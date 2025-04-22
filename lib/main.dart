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
  try {
    print('Starting app initialization...');
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter binding initialized');
    
    print('Starting Supabase initialization...');
    
    // Validate Supabase configuration
    print('Validating Supabase configuration...');
    SupabaseConfig.validateConfig();
    print('Configuration validated successfully');
    
    print('Initializing Supabase with URL: ${SupabaseConfig.url}');
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: true,
    );
    
    final supabaseClient = Supabase.instance.client;
    
    // Test the connection with a simple query
    print('Testing Supabase connection...');
    try {
      final response = await supabaseClient.from('services').select('count').limit(1);
      print('Connection test response: $response');
      
      if (response == null) {
        throw Exception('Null response from database');
      }
      
      print('Supabase connection test successful');
    } catch (e) {
      print('Error testing Supabase connection: $e');
      if (e.toString().contains('network')) {
        print('Network error detected');
        throw Exception('Please check your internet connection and try again');
      } else if (e.toString().contains('auth')) {
        print('Auth error detected');
        throw Exception('Authentication error: ${e.toString()}');
      } else {
        print('Unknown error during connection test');
        throw Exception('Failed to connect to the server: ${e.toString()}');
      }
    }

    print('Setting up providers...');
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider(supabaseClient)),
          ChangeNotifierProvider(create: (_) => PetProvider(supabaseClient)),
          ChangeNotifierProvider(create: (_) => ServiceProvider(supabaseClient)),
          ChangeNotifierProvider(create: (_) => ChatProvider(supabaseClient)),
        ],
        child: const TailMateApp(),
      ),
    );
    print('App started successfully');
  } catch (e) {
    print('Fatal error during app initialization: $e');
    print('Stack trace: ${StackTrace.current}');
    // You might want to show an error screen or handle this differently
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize app: $e'),
          ),
        ),
      ),
    );
  }
}

class TailMateApp extends StatelessWidget {
  const TailMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('Building TailMateApp...');
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'TailMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const OnboardingScreen(),
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