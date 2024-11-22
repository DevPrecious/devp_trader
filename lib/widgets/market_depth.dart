import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trader_app/providers/market_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class MarketDepth extends StatelessWidget {
  const MarketDepth({super.key});

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);
    final currentPrice = marketProvider.currentPrice;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Market Depth',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  // Bid side (left)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bids',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 5, // Show top 5 bids
                            itemBuilder: (context, index) {
                              // Simulate bid prices (replace with real data)
                              final price = currentPrice.isNotEmpty
                                  ? (currentPrice['price'].toDouble() * (1 - 0.001 * (index + 1)))
                                  : 0.0;
                              return ListTile(
                                dense: true,
                                title: Text(
                                  price.toStringAsFixed(2),
                                  style: const TextStyle(color: Colors.green),
                                ),
                                trailing: Text('0.${index + 1}'), // Simulated volume
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(),
                  // Ask side (right)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Asks',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 5, // Show top 5 asks
                            itemBuilder: (context, index) {
                              // Simulate ask prices (replace with real data)
                              final price = currentPrice.isNotEmpty
                                  ? (currentPrice['price'].toDouble() * (1 + 0.001 * (index + 1)))
                                  : 0.0;
                              return ListTile(
                                dense: true,
                                title: Text(
                                  price.toStringAsFixed(2),
                                  style: const TextStyle(color: Colors.red),
                                ),
                                trailing: Text('0.${index + 1}'), // Simulated volume
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (currentPrice.isNotEmpty) ...[
              const Divider(),
              Text(
                'Last Price: ${currentPrice['price']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
