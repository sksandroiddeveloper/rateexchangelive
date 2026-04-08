# 💱 RateExchangeLive

A real-time currency exchange rate Flutter app with a built-in converter, live rate tracking, trader profiles, and a user discovery system.

---

## 📱 Screenshots

| Watchlist | Converter | Detail View | User Profile |
|-----------|-----------|-------------|--------------|
| Live rates for your watchlist | Convert between 25 currencies | Chart + quick convert table | Trader stats + watchlist |

---

## ✨ Features

- **Live Exchange Rates** — Fetches real-time rates from [open.er-api.com](https://open.er-api.com) (free, no API key required)
- **Currency Converter** — Convert between 25 currencies with a swap button
- **Watchlist Tab** — Track your favourite currency pairs at a glance
- **All Currencies Tab** — Browse all 25 supported currencies
- **Detail Screen** — Price chart (7D / 14D / 30D), min/max stats, and a quick convert table per pair
- **User Profiles** — Public + trader profiles with stats, watchlist, and recent activity
- **Leaderboard** — Discover top traders ranked by total profit
- **Search** — Find traders by username, name, country, or favourite pair
- **Follow System** — Follow/unfollow traders and view your following list
- **Dark / Light Mode** — Toggle in the app bar, respects system preference
- **Auto Refresh** — Rates refresh automatically every 60 seconds
- **Pull to Refresh** — Manual refresh on any list screen

---

## 🗂 Project Structure

```
lib/
├── main.dart                  # App entry point, theme mode state
├── theme.dart                 # Light & dark ThemeData
│
├── models/
│   ├── currency.dart          # Currency & ExchangeRate models, kCurrencies list
│   └── user_profile.dart      # UserProfile & TradeActivity models, mock data
│
├── services/
│   ├── exchange_rate_service.dart   # API calls, caching (5 min TTL)
│   └── user_service.dart            # Search, leaderboard, follow logic
│
├── screens/
│   ├── home_screen.dart       # Tab bar: Watchlist + All Currencies
│   ├── detail_screen.dart     # Per-pair chart, stats, quick convert
│   └── users_screen.dart      # Leaderboard, search, following tabs
│
└── widgets/
    ├── converter_card.dart    # Currency converter widget + picker sheet
    └── rate_tile.dart         # Rate list tile + shimmer loading state
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code with Flutter plugin

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/rateexchangelive.git
cd rateexchangelive

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Build for release

```bash
# Android
flutter build apk --release

# iOS
flutter build ipa --release
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|--------|---------|---------|
| `http` | ^1.2.0 | API requests to exchange rate endpoint |
| `intl` | ^0.19.0 | Number and date formatting |
| `fl_chart` | ^0.68.0 | Price chart on the detail screen |
| `shimmer` | ^3.0.0 | Skeleton loading states |
| `shared_preferences` | ^2.2.2 | Persist user preferences locally |
| `cupertino_icons` | ^1.0.6 | iOS-style icons |

---

## 🌐 API

Rates are fetched from the **Open Exchange Rates API (free tier)**:

```
GET https://open.er-api.com/v6/latest/{BASE_CURRENCY}
```

- No API key required
- Updates every 24 hours on the server
- The app caches responses for **5 minutes** to avoid redundant calls
- Auto-refreshes in the background every **60 seconds**

To switch to a different provider (e.g. Frankfurter, ExchangeRate.host), update `ExchangeRateService` in `lib/services/exchange_rate_service.dart`.

---

## 👤 User Profiles

The app includes a complete user discovery system:

- **Public profile** — display name, avatar, bio, country, join date
- **Trader profile** — win rate, total trades, profit %, favourite pairs, watchlist
- **Recent activity** — last trades with direction (buy/sell) and profit
- **Leaderboard** — ranked by total profit percentage
- **Search** — filter by username, name, country, or currency pair
- **Follow system** — follow/unfollow with live follower count updates

> **Note:** User data is currently mocked in `lib/models/user_profile.dart`. To connect a real backend, replace the methods in `UserService` with your API calls.

---

## 🛠 Customisation

### Add a new currency

Open `lib/models/currency.dart` and add to the `kCurrencies` list:

```dart
Currency(code: 'PKR', name: 'Pakistani Rupee', flag: '🇵🇰', symbol: '₨'),
```

### Change the watchlist defaults

In `lib/screens/home_screen.dart`, edit the `_watchlist` list:

```dart
final List<String> _watchlist = [
  'EUR', 'GBP', 'JPY', 'CAD', 'AUD', ...
];
```

### Connect a real user backend

Replace the methods in `lib/services/user_service.dart`:

```dart
Future<List<UserProfile>> getLeaderboard() async {
  final response = await http.get(Uri.parse('https://your-api.com/users/leaderboard'));
  // parse and return
}
```

### Use real historical chart data

In `lib/screens/detail_screen.dart`, replace `_generateSimulatedHistory()` with a real API call:

```dart
Future<List<FlSpot>> _fetchHistory(String from, String to, int days) async {
  final response = await http.get(Uri.parse(
    'https://your-history-api.com/history?from=$from&to=$to&days=$days'
  ));
  // parse into List<FlSpot>
}
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch — `git checkout -b feature/your-feature`
3. Commit your changes — `git commit -m 'Add your feature'`
4. Push to the branch — `git push origin feature/your-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

- [open.er-api.com](https://open.er-api.com) — Free exchange rate API
- [fl_chart](https://pub.dev/packages/fl_chart) — Beautiful Flutter charts
- [Flutter](https://flutter.dev) — Cross-platform mobile framework
