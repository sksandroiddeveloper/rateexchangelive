import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rateexchangelive/models/currency.dart';
import 'package:rateexchangelive/widgets/currency_picker.dart';
import 'package:rateexchangelive/widgets/result_card.dart';
import 'package:rateexchangelive/widgets/quick_amounts.dart';
import 'package:rateexchangelive/widgets/popular_rates.dart';

class ConverterScreen extends StatefulWidget {
  final ExchangeRate? exchangeRate;
  final bool isLoading;
  final String statusText;
  final VoidCallback onRefresh;

  const ConverterScreen({
    super.key,
    required this.exchangeRate,
    required this.isLoading,
    required this.statusText,
    required this.onRefresh,
  });

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen>
    with SingleTickerProviderStateMixin {
  Currency _fromCurrency = Currency.findByCode('USD');
  Currency _toCurrency = Currency.findByCode('EUR');
  final TextEditingController _amountController =
  TextEditingController(text: '100');
  late AnimationController _swapController;
  double _convertedAmount = 0;
  double _currentRate = 0;

  @override
  void initState() {
    super.initState();
    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _calculate();
  }

  @override
  void didUpdateWidget(ConverterScreen old) {
    super.didUpdateWidget(old);
    if (old.exchangeRate != widget.exchangeRate) _calculate();
  }

  void _calculate() {
    final rate = widget.exchangeRate;
    if (rate == null) return;
    final amount = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _convertedAmount =
          rate.convert(amount, _fromCurrency.code, _toCurrency.code);
      _currentRate = rate.convert(1, _fromCurrency.code, _toCurrency.code);
    });
  }

  void _swap() async {
    HapticFeedback.lightImpact();
    _swapController.forward(from: 0);
    setState(() {
      final tmp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = tmp;
    });
    _calculate();
  }

  void _setAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(0);
    _calculate();
  }

  String _fmtConverted(double v, String code) {
    if (code == 'JPY' || code == 'KRW') return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D1B2A) : const Color(0xFF1565C0);

    return Scaffold(
      body: CustomScrollView(
        // ✅ Fix overflow: keyboard won't push content
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverAppBar(
            expandedHeight: 110, // ✅ reduced height to avoid overflow
            pinned: true,
            backgroundColor: bg,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RateRush', // ✅ removed emoji — fixes Noto font warning
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.exchangeRate?.isLive == true
                              ? const Color(0xFF43A047)
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.statusText,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              if (widget.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: widget.onRefresh,
                ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // From card
                  _buildCurrencyCard(
                    label: 'From',
                    currency: _fromCurrency,
                    isInput: true,
                    onCurrencyChanged: (c) {
                      setState(() => _fromCurrency = c);
                      _calculate();
                    },
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),

                  // Swap button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: RotationTransition(
                      turns: Tween(begin: 0.0, end: 0.5)
                          .animate(_swapController),
                      child: FloatingActionButton.small(
                        heroTag: 'swap',
                        onPressed: _swap,
                        backgroundColor: const Color(0xFF1565C0),
                        child:
                        const Icon(Icons.swap_vert, color: Colors.white),
                      ),
                    ),
                  ),

                  // To card
                  _buildCurrencyCard(
                    label: 'To',
                    currency: _toCurrency,
                    isInput: false,
                    onCurrencyChanged: (c) {
                      setState(() => _toCurrency = c);
                      _calculate();
                    },
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms)
                      .slideY(begin: 0.2),

                  const SizedBox(height: 14),

                  // Result card
                  ResultCard(
                    fromCurrency: _fromCurrency,
                    toCurrency: _toCurrency,
                    amount: double.tryParse(_amountController.text) ?? 0,
                    converted: _convertedAmount,
                    rate: _currentRate,
                    isLoading: widget.isLoading,
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

                  const SizedBox(height: 14),

                  // Quick amounts
                  QuickAmounts(onSelected: _setAmount)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms),

                  const SizedBox(height: 14),

                  // Popular rates
                  if (widget.exchangeRate != null)
                    PopularRates(
                      exchangeRate: widget.exchangeRate!,
                      baseCurrency: _fromCurrency,
                      onTap: (c) {
                        setState(() => _toCurrency = c);
                        _calculate();
                      },
                    ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

                  // ✅ bottom padding so content clears nav bar
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyCard({
    required String label,
    required Currency currency,
    required bool isInput,
    required ValueChanged<Currency> onCurrencyChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.grey.withOpacity(0.12),
        ),
      ),
      padding: const EdgeInsets.all(14), // ✅ reduced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CurrencyPicker(
                  selected: currency,
                  onChanged: onCurrencyChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isInput
                    ? TextField(
                  controller: _amountController,
                  onChanged: (_) => _calculate(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.right,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                    isDense: true, // ✅ reduces input height
                    contentPadding: EdgeInsets.zero,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                )
                    : Text(
                  _fmtConverted(_convertedAmount, _toCurrency.code),
                  textAlign: TextAlign.right,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _swapController.dispose();
    super.dispose();
  }
}