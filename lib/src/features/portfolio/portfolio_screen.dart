import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/stock_repository.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stocksAsync = ref.watch(allStocksProvider);
    final positions = ref.watch(positionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio')),
      body: stocksAsync.when(
        data: (all) {
          double totalValue = 0;
          double totalPnl = 0;
          for (final p in positions) {
            final price = all[p.symbol]?.price ?? p.avgCost;
            totalValue += p.marketValue(price);
            totalPnl += p.unrealizedPnl(price);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Total value', style: Theme.of(context).textTheme.labelMedium),
              Text('GH₵ ${totalValue.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.displaySmall),
              Text(
                '${totalPnl >= 0 ? '+' : ''}GH₵ ${totalPnl.toStringAsFixed(2)} unrealized',
                style: TextStyle(
                  color: totalPnl >= 0 ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Text('Positions',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...positions.map((p) {
                final stock = all[p.symbol];
                final price = stock?.price ?? p.avgCost;
                final pnl = p.unrealizedPnl(price);
                final pnlPct = p.unrealizedPnlPct(price);
                return Card(
                  child: ListTile(
                    onTap: () => context.go('/stock/${p.symbol}'),
                    title: Text(p.symbol),
                    subtitle: Text(
                      '${p.shares.toStringAsFixed(0)} shares @ GH₵ ${p.avgCost.toStringAsFixed(2)}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('GH₵ ${p.marketValue(price).toStringAsFixed(2)}'),
                        Text(
                          '${pnl >= 0 ? '+' : ''}${pnlPct.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: pnl >= 0 ? Colors.greenAccent : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
