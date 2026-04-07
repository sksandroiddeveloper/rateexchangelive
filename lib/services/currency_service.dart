import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rateexchangelive/models/currency.dart';

class CurrencyService {
  static const String _apiKey = 'cur_live_Si8zWmpw12ijiaT4bgZhe6ol4fwsaYGNi47RaBMf';
  static const String _baseUrl = 'https://api.currencyapi.com/v3';

  // Updated fallback rates - April 2026 (used only if API call fails)
  static const Map<String, double> _fallbackRates = {
    'USD': 1.0,
    'EUR': 0.8665,
    'GBP': 0.7557,
    'JPY': 159.70,
    'INR': 93.07,
    'AUD': 1.5812,
    'CAD': 1.3834,
    'CHF': 0.8923,
    'CNY': 7.2431,
    'AED': 3.6725,
    'SGD': 1.3421,
    'MXN': 17.12,
    'BRL': 4.9731,
    'KRW': 1328.5,
    'HKD': 7.8241,
    'NOK': 10.52,
    'SEK': 10.41,
    'NZD': 1.6312,
    'ZAR': 18.87,
    'TRY': 32.14,
  };

  // ✅ Call this once in main() to confirm live API is working
  // You will see output in your Flutter debug console
  static Future<void> debugApiCheck() async {
    print('🔍 Testing CurrencyAPI...');
    try {
      final uri = Uri.parse(
        '$_baseUrl/latest?apikey=$_apiKey&base_currency=USD&currencies=EUR,GBP,INR,JPY',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final meta = json['meta'] as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>;

        print('✅ API is LIVE — last updated: ${meta['last_updated_at']}');
        print('   EUR = ${data['EUR']['value']}');
        print('   GBP = ${data['GBP']['value']}');
        print('   INR = ${data['INR']['value']}');
        print('   JPY = ${data['JPY']['value']}');
        print('   ↳ These are REAL-TIME values from CurrencyAPI ✓');
      } else {
        print('❌ API error: ${response.statusCode}');
        print('   Body: ${response.body}');
        print('   ↳ App will use fallback rates');
      }
    } catch (e) {
      print('❌ API exception: $e');
      print('   ↳ App will use fallback rates');
    }
  }

  static Future<ExchangeRate> fetchLatest({String base = 'USD'}) async {
    try {
      final codes = Currency.all.map((c) => c.code).join(',');
      final uri = Uri.parse(
        '$_baseUrl/latest?apikey=$_apiKey&base_currency=$base&currencies=$codes',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final meta = json['meta'] as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>;
        final rates = <String, double>{};

        data.forEach((key, value) {
          rates[key] = (value['value'] as num).toDouble();
        });

        // ✅ This confirms data is live, not fallback
        print('✅ Live rates loaded — updated: ${meta['last_updated_at']}');

        return ExchangeRate(
          baseCurrency: base,
          rates: rates,
          updatedAt: DateTime.now(),
          isLive: true, // ← marks as real-time
        );
      } else {
        print('❌ CurrencyAPI error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('❌ CurrencyAPI exception: $e');
    }

    print('⚠️ Using fallback rates (offline/demo mode)');
    return _fallback(base);
  }

  static Future<Map<DateTime, double>> fetchHistorical({
    required String from,
    required String to,
    int days = 7,
  }) async {
    final result = <DateTime, double>{};
    final now = DateTime.now();

    try {
      final dateFrom =
      now.subtract(Duration(days: days)).toIso8601String().split('T')[0];
      final dateTo = now.toIso8601String().split('T')[0];
      final uri = Uri.parse(
        '$_baseUrl/range?apikey=$_apiKey&datetime_start=${dateFrom}T00:00:00Z'
            '&datetime_end=${dateTo}T00:00:00Z&base_currency=$from&currencies=$to',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>;
        data.forEach((dateStr, rateData) {
          final date = DateTime.tryParse(dateStr);
          if (date != null && rateData[to] != null) {
            result[date] = (rateData[to]['value'] as num).toDouble();
          }
        });
      }
    } catch (e) {
      print('Historical fetch error: $e');
      final baseRate = _fallbackRates[to] ?? 1.0;
      for (int i = days - 1; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final variance = (baseRate * 0.015) * (i % 3 == 0 ? 1 : -0.5);
        result[date] = baseRate + variance * ((i % 5) - 2) * 0.1;
      }
    }

    return result;
  }

  static ExchangeRate _fallback(String base) {
    if (base == 'USD') {
      return ExchangeRate(
        baseCurrency: 'USD',
        rates: Map.from(_fallbackRates),
        updatedAt: DateTime.now(),
        isLive: false,
      );
    }
    final baseToUsd = 1.0 / (_fallbackRates[base] ?? 1.0);
    final rates = <String, double>{};
    _fallbackRates.forEach((code, usdRate) {
      rates[code] = usdRate * baseToUsd;
    });
    return ExchangeRate(
      baseCurrency: base,
      rates: rates,
      updatedAt: DateTime.now(),
      isLive: false,
    );
  }
}