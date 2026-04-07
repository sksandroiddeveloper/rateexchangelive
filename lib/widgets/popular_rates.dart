import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rateexchangelive/models/currency.dart';

class PopularRates extends StatelessWidget {
  final ExchangeRate exchangeRate;
  final Currency baseCurrency;
  final ValueChanged<Currency> onTap;

  static const _popularCodes = [
    'EUR', 'GBP', 'JPY', 'INR', 'AUD', 'CAD', 'CHF', 'CNY'
  ];

  const PopularRates({
    super.key,
    required this.exchangeRate,
    required this.baseCurrency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final currencies = _popularCodes
        .where((c) => c != baseCurrency.code)
        .map(Currency.findByCode)
        .take(6)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'POPULAR RATES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface.withOpacity(0.45),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.4,
          ),
          itemCount: currencies.length,
          itemBuilder: (ctx, i) {
            final c = currencies[i];
            final rate = exchangeRate.convert(1, baseCurrency.code, c.code);
            final rateStr = _fmtRate(rate, c.code);
            // Simulated change for demo
            final isUp = i % 3 != 2;
            final change = (0.05 + (i * 0.03)).toStringAsFixed(2);

            return GestureDetector(
              onTap: () => onTap(c),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161B22) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.grey.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(c.flag, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '${baseCurrency.code}/${c.code}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rateStr,
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          size: 14,
                          color: isUp ? const Color(0xFF43A047) : const Color(0xFFE53935),
                        ),
                        Text(
                          '$change%',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isUp
                                ? const Color(0xFF43A047)
                                : const Color(0xFFE53935),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _fmtRate(double rate, String code) {
    if (code == 'JPY' || code == 'KRW') return rate.toStringAsFixed(1);
    if (rate >= 10) return rate.toStringAsFixed(2);
    return rate.toStringAsFixed(4);
  }
}
