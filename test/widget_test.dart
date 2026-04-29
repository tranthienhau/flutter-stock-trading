import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_stock_trading/main.dart';

void main() {
  testWidgets('App boots and shows watchlist', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: StockTradingApp()));
    await tester.pump();
    expect(find.text('Ghana Stock Exchange'), findsOneWidget);
  });
}
