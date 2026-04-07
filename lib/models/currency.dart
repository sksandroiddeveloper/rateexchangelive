class Currency {
  final String code;
  final String name;
  final String flag;
  final String symbol;

  const Currency({
    required this.code,
    required this.name,
    required this.flag,
    required this.symbol,
  });

  static const List<Currency> all = [
    Currency(code: 'USD', name: 'US Dollar',         flag: '🇺🇸', symbol: '\$'),
    Currency(code: 'EUR', name: 'Euro',               flag: '🇪🇺', symbol: '€'),
    Currency(code: 'GBP', name: 'British Pound',     flag: '🇬🇧', symbol: '£'),
    Currency(code: 'JPY', name: 'Japanese Yen',      flag: '🇯🇵', symbol: '¥'),
    Currency(code: 'INR', name: 'Indian Rupee',      flag: '🇮🇳', symbol: '₹'),
    Currency(code: 'AUD', name: 'Australian Dollar', flag: '🇦🇺', symbol: 'A\$'),
    Currency(code: 'CAD', name: 'Canadian Dollar',   flag: '🇨🇦', symbol: 'C\$'),
    Currency(code: 'CHF', name: 'Swiss Franc',       flag: '🇨🇭', symbol: 'Fr'),
    Currency(code: 'CNY', name: 'Chinese Yuan',      flag: '🇨🇳', symbol: '¥'),
    Currency(code: 'AED', name: 'UAE Dirham',        flag: '🇦🇪', symbol: 'د.إ'),
    Currency(code: 'SGD', name: 'Singapore Dollar',  flag: '🇸🇬', symbol: 'S\$'),
    Currency(code: 'MXN', name: 'Mexican Peso',      flag: '🇲🇽', symbol: '\$'),
    Currency(code: 'BRL', name: 'Brazilian Real',    flag: '🇧🇷', symbol: 'R\$'),
    Currency(code: 'KRW', name: 'South Korean Won',  flag: '🇰🇷', symbol: '₩'),
    Currency(code: 'HKD', name: 'Hong Kong Dollar',  flag: '🇭🇰', symbol: 'HK\$'),
    Currency(code: 'NOK', name: 'Norwegian Krone',   flag: '🇳🇴', symbol: 'kr'),
    Currency(code: 'SEK', name: 'Swedish Krona',     flag: '🇸🇪', symbol: 'kr'),
    Currency(code: 'NZD', name: 'New Zealand Dollar',flag: '🇳🇿', symbol: 'NZ\$'),
    Currency(code: 'ZAR', name: 'South African Rand',flag: '🇿🇦', symbol: 'R'),
    Currency(code: 'TRY', name: 'Turkish Lira',      flag: '🇹🇷', symbol: '₺'),
  ];

  static Currency findByCode(String code) {
    return all.firstWhere(
          (c) => c.code == code,
      orElse: () => all.first,
    );
  }
}

class ExchangeRate {
  final String baseCurrency;
  final Map<String, double> rates;
  final DateTime updatedAt;
  final bool isLive; // ✅ true = from API, false = fallback

  const ExchangeRate({
    required this.baseCurrency,
    required this.rates,
    required this.updatedAt,
    this.isLive = false,
  });

  double getRate(String targetCode) => rates[targetCode] ?? 1.0;

  double convert(double amount, String from, String to) {
    if (from == baseCurrency) return amount * getRate(to);
    final inBase = amount / getRate(from);
    return inBase * getRate(to);
  }
}

class FavoriteConversion {
  final String fromCode;
  final String toCode;

  const FavoriteConversion({required this.fromCode, required this.toCode});

  Map<String, dynamic> toJson() => {'from': fromCode, 'to': toCode};

  factory FavoriteConversion.fromJson(Map<String, dynamic> json) =>
      FavoriteConversion(fromCode: json['from'], toCode: json['to']);
}