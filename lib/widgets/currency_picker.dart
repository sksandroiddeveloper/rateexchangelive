import 'package:flutter/material.dart';
import 'package:rateexchangelive/models/currency.dart';

class CurrencyPicker extends StatelessWidget {
  final Currency selected;
  final ValueChanged<Currency> onChanged;
  final bool darkMode;

  const CurrencyPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark || darkMode;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selected.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selected.code,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    selected.symbol,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? Colors.white54
                          : Colors.black.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 16,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CurrencyPickerSheet(
        selected: selected,
        onSelected: (c) {
          Navigator.pop(ctx);
          onChanged(c);
        },
      ),
    );
  }
}

class _CurrencyPickerSheet extends StatefulWidget {
  final Currency selected;
  final ValueChanged<Currency> onSelected;

  const _CurrencyPickerSheet({
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  String _search = '';

  List<Currency> get _filtered => Currency.all
      .where((c) =>
          _search.isEmpty ||
          c.code.toLowerCase().contains(_search.toLowerCase()) ||
          c.name.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (ctx, scroll) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Select Currency',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _search = v),
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: scroll,
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final c = _filtered[i];
                final isSelected = c.code == widget.selected.code;
                return ListTile(
                  leading: Text(c.flag,
                      style: const TextStyle(fontSize: 24)),
                  title: Text(c.code,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? const Color(0xFF1565C0)
                            : null,
                      )),
                  subtitle: Text(c.name, style: const TextStyle(fontSize: 12)),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xFF1565C0))
                      : null,
                  onTap: () => widget.onSelected(c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
