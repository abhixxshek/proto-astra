class Contract {
  final String contract;
  final String last;
  final String change;
  final String tradeTime;

  Contract({
    required this.contract,
    required this.last,
    required this.change,
    required this.tradeTime,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      contract: json['contract'],
      last: json['last'],
      change: json['change'],
      tradeTime: json['tradeTime'],
    );
  }
}

class Commodity {
  final String name;
  final List<Contract> contracts;

  Commodity({required this.name, required this.contracts});

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      name: json['name'],
      contracts: (json['contracts'] as List)
          .map((c) => Contract.fromJson(c))
          .toList(),
    );
  }
}

class MarketCategory {
  final String name;
  final List<Commodity> commodities;

  MarketCategory({required this.name, required this.commodities});

  factory MarketCategory.fromJson(Map<String, dynamic> json) {
    return MarketCategory(
      name: json['name'],
      commodities: (json['commodities'] as List)
          .map((c) => Commodity.fromJson(c))
          .toList(),
    );
  }
}