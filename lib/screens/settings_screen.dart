import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const SettingsScreen({super.key, required this.onToggleTheme});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  String _selectedDecimals = '2';
  String _refreshInterval = '60s';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    _darkMode = isDark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Appearance'),
          _settingCard([
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between light and dark theme'),
              secondary: const Icon(Icons.dark_mode_outlined),
              value: _darkMode,
              activeColor: const Color(0xFF1565C0),
              onChanged: (v) {
                setState(() => _darkMode = v);
                widget.onToggleTheme();
              },
            ),
          ]),

          _sectionTitle('Display'),
          _settingCard([
            ListTile(
              leading: const Icon(Icons.pin_outlined),
              title: const Text('Decimal Places'),
              trailing: DropdownButton<String>(
                value: _selectedDecimals,
                underline: const SizedBox(),
                items: ['2', '3', '4', '6'].map((v) =>
                  DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) => setState(() => _selectedDecimals = v!),
              ),
            ),
          ]),

          _sectionTitle('Data'),
          _settingCard([
            ListTile(
              leading: const Icon(Icons.refresh_outlined),
              title: const Text('Auto-refresh Interval'),
              trailing: DropdownButton<String>(
                value: _refreshInterval,
                underline: const SizedBox(),
                items: ['30s', '60s', '5m', 'Manual'].map((v) =>
                  DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) => setState(() => _refreshInterval = v!),
              ),
            ),
            SwitchListTile(
              title: const Text('Rate Alerts'),
              subtitle: const Text('Get notified on big rate changes'),
              secondary: const Icon(Icons.notifications_outlined),
              value: _notifications,
              activeColor: const Color(0xFF1565C0),
              onChanged: (v) => setState(() => _notifications = v),
            ),
          ]),

          _sectionTitle('About'),
          _settingCard([
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Version'),
              trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
            ),
            ListTile(
              leading: const Icon(Icons.api_outlined),
              title: const Text('Data Provider'),
              trailing: const Text('CurrencyAPI.com',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Built with Flutter'),
              trailing: const Text('❤️ Dart', style: TextStyle(fontSize: 12)),
            ),
          ]),

          const SizedBox(height: 32),
          Center(
            child: Text(
              '⚡ RateRush v1.0.0',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.35),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1565C0),
        letterSpacing: 0.1,
      ),
    ),
  );

  Widget _settingCard(List<Widget> children) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Column(children: children),
    );
  }
}
