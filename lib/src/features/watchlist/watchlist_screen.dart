import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/stock_repository.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stocksAsync = ref.watch(allStocksProvider);
    final watchlist = ref.watch(watchlistProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ghana Stock Exchange')),
      body: stocksAsync.when(
        data: (all) {
          final items = watchlist
              .map((sym) => all[sym])
              .whereType()
              .toList();
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final s = items[i];
              return ListTile(
                onTap: () => context.go('/stock/${s.symbol}'),
                leading: CircleAvatar(child: Text(s.symbol[0])),
                title: Text(s.symbol,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(s.name),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('GH₵ ${s.price.toStringAsFixed(2)}'),
                    Text(
                      '${s.isUp ? '+' : ''}${s.changePct.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: s.isUp ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
