import 'package:flutter/material.dart';
import 'my_card_home_screen.dart';
import 'my_card_details_screen.dart';
import 'card_designer_screen.dart';

class MyCardScreen extends StatefulWidget {
  const MyCardScreen({super.key});

  @override
  State<MyCardScreen> createState() => _MyCardScreenState();
}

class _MyCardScreenState extends State<MyCardScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = _navigatorKey.currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        }
      },
      child: Navigator(
        key: _navigatorKey,
        initialRoute: '/my-card/home',
        onGenerateRoute: (RouteSettings settings) {
          Widget builder;
          switch (settings.name) {
            case '/my-card/home':
              builder = const MyCardHomeScreen();
              break;
            case '/my-card/details':
              builder = const MyCardDetailsScreen();
              break;
            case '/my-card/designer':
              builder = const CardDesignerScreen();
              break;
            default:
              builder = const MyCardHomeScreen();
          }
          return MaterialPageRoute(
            builder: (context) => builder,
            settings: settings,
          );
        },
      ),
    );
  }
}
