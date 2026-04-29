import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/stock.dart';
import '../../data/stock_repository.dart';

class StockDetailScreen extends ConsumerWidget {
  const StockDetailScreen({super.key, required this.symbol});
  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stocksAsync = ref.watch(allStocksProvider);

    return Scaffold(
      appBar: AppBar(title: Text(symbol)),
      body: stocksAsync.when(
        data: (all) {
          final stock = all[symbol];
          if (stock == null) {
            return const Center(child: Text('Stock not found'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(stock.name,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('GH₵ ${stock.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.displaySmall),
              Text(
                '${stock.isUp ? '+' : ''}${stock.changePct.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: stock.isUp ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(height: 220, child: _Chart(history: stock.history)),
              const SizedBox(height: 24),
              _Stats(stock: stock),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _showOrderSheet(context, stock, OrderSide.buy),
                      child: const Text('Buy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => _showOrderSheet(context, stock, OrderSide.sell),
                      child: const Text('Sell'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showOrderSheet(BuildContext context, Stock stock, OrderSide side) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _OrderSheet(stock: stock, side: side),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.history});
  final List<double> history;

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (int i = 0; i < history.length; i++)
        FlSpot(i.toDouble(), history[i]),
    ];
    final isUp = history.last >= history.first;
    final color = isUp ? Colors.greenAccent : Colors.redAccent;
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.18),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.stock});
  final Stock stock;

  @override
  Widget build(BuildContext context) {
    final low = stock.history.reduce((a, b) => a < b ? a : b);
    final high = stock.history.reduce((a, b) => a > b ? a : b);
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      children: [
        _StatCell('Volume', stock.volume.toString()),
        _StatCell('30d Low', 'GH₵ ${low.toStringAsFixed(2)}'),
        _StatCell('30d High', 'GH₵ ${high.toStringAsFixed(2)}'),
        _StatCell('Symbol', stock.symbol),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _OrderSheet extends StatefulWidget {
  const _OrderSheet({required this.stock, required this.side});
  final Stock stock;
  final OrderSide side;

  @override
  State<_OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends State<_OrderSheet> {
  double shares = 10;

  @override
  Widget build(BuildContext context) {
    final estimated = shares * widget.stock.price;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.side == OrderSide.buy ? 'Buy' : 'Sell'} ${widget.stock.symbol}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Slider(
            value: shares,
            min: 1,
            max: 1000,
            divisions: 100,
            label: '${shares.round()} shares',
            onChanged: (v) => setState(() => shares = v),
          ),
          Text('${shares.round()} shares @ GH₵ ${widget.stock.price.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          Text(
            'Estimated total: GH₵ ${estimated.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Order placed (mock - brokerage API not yet wired)',
                  ),
                ),
              );
              Navigator.of(context).pop();
            },
            child: Text(widget.side == OrderSide.buy ? 'Place Buy Order' : 'Place Sell Order'),
          ),
        ],
      ),
    );
  }
}
