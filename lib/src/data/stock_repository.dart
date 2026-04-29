import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/stock.dart';

class StockRepository {
  StockRepository() {
    _seed();
    _tick();
  }

  final _stocks = <String, Stock>{};
  final _controller = StreamController<Map<String, Stock>>.broadcast();
  final _rng = Random(42);
  Timer? _timer;

  Stream<Map<String, Stock>> watchAll() => _controller.stream;

  Stock? get(String symbol) => _stocks[symbol];

  void _seed() {
    final seed = [
      ('GCB', 'GCB Bank', 5.20),
      ('MTNGH', 'MTN Ghana', 1.45),
      ('EGH', 'Ecobank Ghana', 8.10),
      ('CAL', 'CAL Bank', 0.92),
      ('TLW', 'Tullow Oil', 26.30),
      ('FML', 'Fan Milk', 3.40),
      ('TOTAL', 'TotalEnergies GH', 9.80),
      ('UNIL', 'Unilever Ghana', 6.05),
    ];
    for (final (sym, name, price) in seed) {
      _stocks[sym] = Stock(
        symbol: sym,
        name: name,
        price: price,
        changePct: 0,
        history: List.generate(30, (_) => price * (0.92 + _rng.nextDouble() * 0.16)),
        volume: 50000 + _rng.nextInt(450000),
      );
    }
  }

  void _tick() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      for (final entry in _stocks.entries.toList()) {
        final s = entry.value;
        final delta = (_rng.nextDouble() - 0.5) * 0.02;
        final newPrice = (s.price * (1 + delta)).clamp(0.01, 9999.0);
        final history = [...s.history.skip(1), newPrice.toDouble()];
        final base = s.history.first;
        final pct = ((newPrice - base) / base) * 100;
        _stocks[entry.key] = Stock(
          symbol: s.symbol,
          name: s.name,
          price: double.parse(newPrice.toStringAsFixed(2)),
          changePct: double.parse(pct.toStringAsFixed(2)),
          history: history,
          volume: s.volume,
        );
      }
      _controller.add(Map.of(_stocks));
    });
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}

final stockRepoProvider = Provider<StockRepository>((ref) {
  final r = StockRepository();
  ref.onDispose(r.dispose);
  return r;
});

final allStocksProvider = StreamProvider<Map<String, Stock>>((ref) {
  return ref.watch(stockRepoProvider).watchAll();
});

final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, List<String>>((ref) {
  return WatchlistNotifier();
});

class WatchlistNotifier extends StateNotifier<List<String>> {
  WatchlistNotifier() : super(const ['GCB', 'MTNGH', 'TLW', 'EGH']);

  void add(String symbol) {
    if (state.contains(symbol)) return;
    state = [...state, symbol];
  }

  void remove(String symbol) {
    state = state.where((s) => s != symbol).toList();
  }
}

final positionsProvider =
    StateNotifierProvider<PositionsNotifier, List<Position>>((ref) {
  return PositionsNotifier();
});

class PositionsNotifier extends StateNotifier<List<Position>> {
  PositionsNotifier()
      : super(const [
          Position(symbol: 'GCB', shares: 100, avgCost: 4.80),
          Position(symbol: 'MTNGH', shares: 500, avgCost: 1.30),
          Position(symbol: 'TLW', shares: 20, avgCost: 24.10),
        ]);

  void addPosition(Position p) {
    state = [...state, p];
  }
}
