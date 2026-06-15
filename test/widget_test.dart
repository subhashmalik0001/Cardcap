import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:card_capture/main.dart';
import 'package:card_capture/presentation/providers/cards_provider.dart';
import 'package:card_capture/presentation/providers/scan_provider.dart';
import 'package:card_capture/data/repositories/card_repository.dart';

import 'package:card_capture/presentation/providers/auth_provider.dart';

void main() {
  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    final repository = CardRepository();
    
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => CardsProvider(repository: repository)),
            ChangeNotifierProvider(create: (_) => ScanProvider(repository: repository)),
          ],
          child: const CardCaptureApp(),
        ),
      );

      // Verify splash screen renders title
      expect(find.text('CardCapture'), findsOneWidget);
    });
  });
}
