import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trader_app/providers/market_provider.dart';

class TradingControls extends StatefulWidget {
  const TradingControls({super.key});

  @override
  State<TradingControls> createState() => _TradingControlsState();
}

class _TradingControlsState extends State<TradingControls> {
  final _priceController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isBuyOrder = true;
  String _orderType = 'LIMIT';

  @override
  void dispose() {
    _priceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitOrder() {
    // Implement order submission logic here
    final price = double.tryParse(_priceController.text);
    final amount = double.tryParse(_amountController.text);

    if (price == null || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid price and amount')),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm ${_isBuyOrder ? 'Buy' : 'Sell'} Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: $_orderType'),
            Text('Price: $price'),
            Text('Amount: $amount'),
            Text('Total: ${(price * amount).toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // Implement actual order submission here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order submitted successfully')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order type selector
              Row(
                children: [
                  const Text('Order Type:'),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _orderType,
                    items: ['MARKET', 'LIMIT', 'STOP_LIMIT']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _orderType = value);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Buy/Sell toggle
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('BUY'),
                    icon: Icon(Icons.arrow_upward, color: Colors.green),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('SELL'),
                    icon: Icon(Icons.arrow_downward, color: Colors.red),
                  ),
                ],
                selected: {_isBuyOrder},
                onSelectionChanged: (value) {
                  setState(() => _isBuyOrder = value.first);
                },
              ),
              const SizedBox(height: 12),

              // Price and amount inputs
              if (_orderType != 'MARKET') ...[
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
              const SizedBox(height: 12),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitOrder,
                  style: FilledButton.styleFrom(
                    backgroundColor: _isBuyOrder ? Colors.green : Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    _isBuyOrder ? 'Place Buy Order' : 'Place Sell Order',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
