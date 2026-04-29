# flutter-stock-trading

Stock trading mobile app POC built with Flutter + Riverpod. Targets emerging-market stock exchanges (the seed data is Ghana Stock Exchange) and demonstrates a brokerage-ready architecture.

## What's in here

- **Watchlist** - live-updating list of tracked stocks (price, % change)
- **Stock detail** - 30-day price history chart (fl_chart), key stats, order placement bottom sheet
- **Portfolio** - positions, market value, unrealized P&L (real-time as prices tick)
- **Order entry** - buy/sell with shares slider + estimated total (mock fill - hook your brokerage API here)
- **Repository pattern** - StockRepository streams price ticks; swap mock with WebSocket / REST market data feed (Twelve Data, Alpha Vantage, brokerage WebSocket) by replacing _tick()
- **State management** - Riverpod (StreamProvider for prices, StateNotifierProvider for watchlist + positions)
- **Routing** - go_router with shell route + bottom navigation
- **Material 3 dark theme**

## Architecture

```
lib/
  main.dart                          # ProviderScope + GoRouter + ShellRoute
  src/
    data/
      models/
        stock.dart                   # Stock, Position, Order, OrderSide, OrderStatus
      stock_repository.dart          # Mock real-time tick stream + Riverpod providers
    features/
      watchlist/
        watchlist_screen.dart
      stock_detail/
        stock_detail_screen.dart     # Chart + stats + order entry sheet
      portfolio/
        portfolio_screen.dart        # Positions + total value + unrealized P&L
```

## Wiring real market data

Replace the mock _tick() in stock_repository.dart with a WebSocket subscription:

```dart
final ws = WebSocketChannel.connect(Uri.parse('wss://your-broker/quote'));
ws.stream.listen((msg) {
  final tick = jsonDecode(msg as String);
  _stocks[tick['symbol']] = _stocks[tick['symbol']]!.copyWith(
    price: tick['price'],
    history: [..._stocks[tick['symbol']]!.history.skip(1), tick['price']],
  );
  _controller.add(Map.of(_stocks));
});
```

For order placement, wire the buy/sell button in _OrderSheet._OrderSheetState to your brokerage REST endpoint (signed request, idempotency key, order state machine pending -> filled/canceled).

## Run

```bash
flutter pub get
flutter run
```

## Why this stack

- Flutter - 1 codebase iOS + Android, fast iteration, native performance for chart-heavy UI
- Riverpod - compile-safe state, per-screen lifecycle, easy to mock for tests
- fl_chart - clean line/candlestick charts; cheap to swap with TradingView WebView for advanced overlays
- go_router - declarative routing matching deep links if you add /stock/:symbol web/share links
- Hive - local cache for offline watchlist + last-known prices (already in pubspec)

## Security checklist (when wiring brokerage API)

- 256-bit at-rest encryption for tokens (Keychain / Keystore via flutter_secure_storage)
- Cert pinning on the brokerage host
- Biometric unlock before order placement (local_auth)
- Session inactivity timeout (auto-logout after N min idle)
- Jailbreak/root detection before unlocking trading screens
- Audit log of every order placed (server-side, not client)

## Status

POC scaffold. Mock data + mock orders. Real brokerage API integration is a 2-4 week add depending on the broker's API quality.
