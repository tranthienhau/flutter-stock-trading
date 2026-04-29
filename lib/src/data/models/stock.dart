class Stock {
  const Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePct,
    required this.history,
    required this.volume,
  });

  final String symbol;
  final String name;
  final double price;
  final double changePct;
  final List<double> history;
  final int volume;

  bool get isUp => changePct >= 0;
}

class Position {
  const Position({
    required this.symbol,
    required this.shares,
    required this.avgCost,
  });

  final String symbol;
  final double shares;
  final double avgCost;

  double marketValue(double price) => shares * price;
  double unrealizedPnl(double price) => (price - avgCost) * shares;
  double unrealizedPnlPct(double price) =>
      avgCost == 0 ? 0 : ((price - avgCost) / avgCost) * 100;
}

class Order {
  const Order({
    required this.id,
    required this.symbol,
    required this.side,
    required this.shares,
    required this.limitPrice,
    required this.status,
    required this.placedAt,
  });

  final String id;
  final String symbol;
  final OrderSide side;
  final double shares;
  final double? limitPrice;
  final OrderStatus status;
  final DateTime placedAt;
}

enum OrderSide { buy, sell }

enum OrderStatus { pending, filled, canceled }
