import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vakit/main.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('tr_TR', null);
  });

  testWidgets('VakitApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: VakitApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Ana namaz vakitleri ekranının başarıyla açıldığını doğrula
    expect(find.text('İstanbul'), findsOneWidget);
    expect(find.text('Vakitler'), findsOneWidget);
  });
}
