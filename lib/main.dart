import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/card_repository.dart';
import 'presentation/providers/cards_provider.dart';
import 'presentation/providers/scan_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/my_card_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/shell/shell_screen.dart';
import 'presentation/screens/review/review_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/my_card/my_card_details_screen.dart';
import 'presentation/screens/my_card/card_designer_screen.dart';
import 'data/models/business_card.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://zsjinlmpmbxkjghxhoqh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzamlubG1wbWJ4a2pnaHhob3FoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE1MDM1NjQsImV4cCI6MjA5NzA3OTU2NH0.FrSaNtVGp1U2lp_vtzEK7GFvXLOYoKXov5kMRit_cWw',
  );
  
  final cardRepository = CardRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CardsProvider(repository: cardRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ScanProvider(repository: cardRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => MyCardProvider()..init(),
        ),
      ],
      child: const NebulaApp(),
    ),
  );
}

class NebulaApp extends StatelessWidget {
  const NebulaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nebula',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/shell': (context) => const ShellScreen(),
        '/my-card/details': (context) => const MyCardDetailsScreen(),
        '/my-card/designer': (context) => const CardDesignerScreen(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/review') {
          final card = settings.arguments as BusinessCard;
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ReviewScreen(card: card),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        }
        return null;
      },
    );
  }
}
