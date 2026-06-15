import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'data/models/business_card.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
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
      child: const CardCaptureApp(),
    ),
  );
}

class CardCaptureApp extends StatelessWidget {
  const CardCaptureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardCapture',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/shell': (context) => const ShellScreen(),
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
