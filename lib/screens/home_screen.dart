import 'package:flutter/material.dart';
import 'package:rateexchangelive/screens/converter_screen.dart';
import 'package:rateexchangelive/screens/rates_screen.dart';
import 'package:rateexchangelive/screens/favorites_screen.dart';
import 'package:rateexchangelive/screens/settings_screen.dart';
import 'package:rateexchangelive/models/currency.dart';
import 'package:rateexchangelive/services/currency_service.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  ExchangeRate? _exchangeRate;
  bool _isLoading = true;
  String _statusText = 'Fetching rates...';

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Fetching rates...';
    });
    final rate = await CurrencyService.fetchLatest();
    setState(() {
      _exchangeRate = rate;
      _isLoading = false;
      _statusText = 'Updated ${_formatTime(rate.updatedAt)}';
    });
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final screens = [
      ConverterScreen(
        exchangeRate: _exchangeRate,
        isLoading: _isLoading,
        statusText: _statusText,
        onRefresh: _loadRates,
      ),
      RatesScreen(
        exchangeRate: _exchangeRate,
        isLoading: _isLoading,
        onRefresh: _loadRates,
      ),
      FavoritesScreen(
        exchangeRate: _exchangeRate,
        isLoading: _isLoading,
      ),
      SettingsScreen(onToggleTheme: widget.onToggleTheme),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        indicatorColor: const Color(0xFF1565C0).withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.currency_exchange_outlined),
            selectedIcon: Icon(Icons.currency_exchange, color: Color(0xFF1565C0)),
            label: 'Convert',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: Color(0xFF1565C0)),
            label: 'Rates',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border_outlined),
            selectedIcon: Icon(Icons.star, color: Color(0xFF1565C0)),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: Color(0xFF1565C0)),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
