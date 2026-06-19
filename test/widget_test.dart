import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nebula/main.dart';
import 'package:nebula/presentation/providers/cards_provider.dart';
import 'package:nebula/presentation/providers/scan_provider.dart';
import 'package:nebula/data/repositories/card_repository.dart';

import 'package:nebula/presentation/providers/auth_provider.dart';

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
          child: const NebulaApp(),
        ),
      );

      // Verify splash screen renders title
      expect(find.text('Nebula'), findsOneWidget);
    });
  });
}
