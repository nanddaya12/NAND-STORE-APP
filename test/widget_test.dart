import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nand_store/main.dart';
import 'package:nand_store/providers/store_provider.dart';
import 'package:nand_store/providers/auth_provider.dart';

void main() {
  testWidgets('App smoke test - find NAND STORE title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => StoreProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app title is present.
    expect(find.text('NAND STORE'), findsOneWidget);

    // Let the splash timer expire to avoid pending timer errors during disposal
    await tester.pump(const Duration(seconds: 3));
  });
}
