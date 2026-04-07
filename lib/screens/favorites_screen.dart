import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:rateexchangelive/models/currency.dart';

class FavoritesScreen extends StatefulWidget {
  final ExchangeRate? exchangeRate;
  final bool isLoading;

  const FavoritesScreen({
    super.key,
    required this.exchangeRate,
    required this.isLoading,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<FavoriteConversion> _favorites = [];

  static const _defaultFavorites = [
    FavoriteConversion(fromCode: 'USD', toCode: 'EUR'),
    FavoriteConversion(fromCode: 'USD', toCode: 'GBP'),
    FavoriteConversion(fromCode: 'USD', toCode: 'JPY'),
    FavoriteConversion(fromCode: 'USD', toCode: 'INR'),
    FavoriteConversion(fromCode: 'EUR', toCode: 'GBP'),
    FavoriteConversion(fromCode: 'GBP', toCode: 'INR'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('favorites');
      if (raw != null) {
        final list = (jsonDecode(raw) as List)
            .map((e) => FavoriteConversion.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() => _favorites = list);
        return;
      }
    } catch (_) {}
    setState(() => _favorites = List.from(_defaultFavorites));
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'favorites', jsonEncode(_favorites.map((e) => e.toJson()).toList()));
  }

  void _remove(int index) {
    setState(() => _favorites.removeAt(index));
    _save();
  }

  String _fmtRate(double rate, String code) {
    if (code == 'JPY' || code == 'KRW') return rate.toStringAsFixed(2);
    return rate.toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_border, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('No favorites yet',
                      style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favorites.length,
              itemBuilder: (ctx, i) {
                final fav = _favorites[i];
                final from = Currency.findByCode(fav.fromCode);
                final to = Currency.findByCode(fav.toCode);
                final rate = widget.exchangeRate?.convert(1, from.code, to.code);

                return Dismissible(
                  key: Key('${fav.fromCode}_${fav.toCode}'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _remove(i),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.06)
                            : Colors.grey.withOpacity(0.1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(from.flag,
                                      style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 6),
                                  Text(from.code,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15)),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child:
                                        Icon(Icons.arrow_forward, size: 14),
                                  ),
                                  Text(to.flag,
                                      style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 6),
                                  Text(to.code,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${from.name} → ${to.name}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.45),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (rate != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _fmtRate(rate, to.code),
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1565C0),
                                  ),
                                ),
                                Text(
                                  '1 ${from.code}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.4),
                                  ),
                                ),
                              ],
                            )
                          else
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
