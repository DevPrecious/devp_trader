import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:trader_app/providers/market_provider.dart';
import 'package:trader_app/providers/theme_provider.dart';
import 'package:trader_app/widgets/market_depth.dart';
import 'package:trader_app/widgets/trading_controls.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DEVP TRADING BOT'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: marketProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Symbol selector and interval controls
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Symbol',
                            hintText: 'Enter trading pair (e.g., BTCUSDT)',
                          ),
                          onSubmitted: (value) =>
                              marketProvider.changeSymbol(value),
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: marketProvider.interval,
                        items: ['1m', '5m', '15m', '1h', '4h', '1d']
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            marketProvider.changeInterval(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // Candlestick chart
                Expanded(
                  flex: 3,
                  child: marketProvider.candleData.isEmpty
                      ? const Center(child: Text('No data available'))
                      : Candlesticks(
                          candles: marketProvider.candleData
                              .map((e) => Candle(
                                    date: e['time'],
                                    high: e['high'].toDouble(),
                                    low: e['low'].toDouble(),
                                    open: e['open'].toDouble(),
                                    close: e['close'].toDouble(),
                                    volume: e['volume'].toDouble(),
                                  ))
                              .toList(),
                        ),
                ),

                // Market depth and order book
                const Expanded(
                  flex: 2,
                  child: MarketDepth(),
                ),

                // Trading controls
                const Expanded(
                  flex: 2,
                  child: TradingControls(),
                ),
              ],
            ),
    );
  }
}
