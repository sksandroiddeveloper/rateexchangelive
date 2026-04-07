import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rateexchangelive/models/currency.dart';

class ResultCard extends StatelessWidget {
  final Currency fromCurrency;
  final Currency toCurrency;
  final double amount;
  final double converted;
  final double rate;
  final bool isLoading;

  const ResultCard({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    required this.converted,
    required this.rate,
    required this.isLoading,
  });

  String _fmt(double v, String code) {
    if (code == 'JPY' || code == 'KRW') return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final inverseRate = rate > 0 ? 1 / rate : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Converted', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const Spacer(),
              if (isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.white54,
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                        ClipboardData(text: _fmt(converted, toCurrency.code)));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                  child: const Icon(Icons.copy, size: 14, color: Colors.white54),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                toCurrency.flag,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${_fmt(converted, toCurrency.code)} ${toCurrency.code}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.2), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(
                label: '1 ${fromCurrency.code}',
                value: '= ${rate.toStringAsFixed(4)} ${toCurrency.code}',
              ),
              const SizedBox(width: 8),
              _InfoChip(
                label: '1 ${toCurrency.code}',
                value: '= ${inverseRate.toStringAsFixed(4)} ${fromCurrency.code}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.jetBrainsMono(
                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
