import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rateexchangelive/models/currency.dart';
import 'package:rateexchangelive/widgets/currency_picker.dart';

class RatesScreen extends StatefulWidget {
  final ExchangeRate? exchangeRate;
  final bool isLoading;
  final VoidCallback onRefresh;

  const RatesScreen({
    super.key,
    required this.exchangeRate,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  State<RatesScreen> createState() => _RatesScreenState();
}

class _RatesScreenState extends State<RatesScreen> {
  Currency _base = Currency.findByCode('USD');
  String _search = '';

  List<Currency> get _filtered {
    return Currency.all.where((c) {
      if (c.code == _base.code) return false;
      if (_search.isEmpty) return true;
      return c.code.toLowerCase().contains(_search.toLowerCase()) ||
          c.name.toLowerCase().contains(_search.toLowerCase());
    }).toList();
  }

  String _fmtRate(double rate, String code) {
    if (code == 'JPY' || code == 'KRW') return rate.toStringAsFixed(2);
    if (rate >= 100) return rate.toStringAsFixed(2);
    if (rate >= 10) return rate.toStringAsFixed(3);
    return rate.toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Rates'),
        actions: [
          IconButton(
            icon: widget.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh),
            onPressed: widget.onRefresh,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? const Color(0xFF0D1B2A) : const Color(0xFF1565C0),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Base currency',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 8),
                CurrencyPicker(
                  selected: _base,
                  onChanged: (c) => setState(() => _base = c),
                  darkMode: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search currency...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: widget.exchangeRate == null
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) {
                      final c = _filtered[i];
                      final rate = widget.exchangeRate!
                          .convert(1, _base.code, c.code);
                      return _RateRow(
                        currency: c,
                        rate: rate,
                        rateStr: _fmtRate(rate, c.code),
                        baseCode: _base.code,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  final Currency currency;
  final double rate;
  final String rateStr;
  final String baseCode;

  const _RateRow({
    required this.currency,
    required this.rate,
    required this.rateStr,
    required this.baseCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        leading: Text(
          currency.flag,
          style: const TextStyle(fontSize: 26),
        ),
        title: Text(
          currency.code,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        subtitle: Text(
          currency.name,
          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              rateStr,
              style: GoogleFonts.jetBrainsMono(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: const Color(0xFF1565C0),
              ),
            ),
            Text(
              '1 $baseCode',
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
