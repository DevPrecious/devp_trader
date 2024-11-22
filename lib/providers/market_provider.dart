import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:decimal/decimal.dart';

class MarketProvider with ChangeNotifier {
  final String _baseUrl = 'https://api.binance.com/api/v3';
  WebSocketChannel? _channel;
  
  List<Map<String, dynamic>> _candleData = [];
  Map<String, dynamic> _currentPrice = {};
  String _currentSymbol = 'BTCUSDT';
  String _interval = '1h';
  bool _isLoading = false;
  String _error = '';

  List<Map<String, dynamic>> get candleData => _candleData;
  Map<String, dynamic> get currentPrice => _currentPrice;
  String get currentSymbol => _currentSymbol;
  String get interval => _interval;
  bool get isLoading => _isLoading;
  String get error => _error;

  MarketProvider() {
    _initializeMarketData();
  }

  Future<void> _initializeMarketData() async {
    await fetchCandleData();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    _channel?.sink.close();
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://stream.binance.com:9443/ws/${_currentSymbol.toLowerCase()}@trade'),
    );

    _channel!.stream.listen(
      (message) {
        final data = json.decode(message);
        _currentPrice = {
          'price': Decimal.parse(data['p']),
          'quantity': Decimal.parse(data['q']),
          'time': DateTime.fromMillisecondsSinceEpoch(data['T']),
        };
        notifyListeners();
      },
      onError: (error) {
        _error = 'WebSocket Error: $error';
        notifyListeners();
      },
    );
  }

  Future<void> fetchCandleData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(Uri.parse(
        '$_baseUrl/klines?symbol=$_currentSymbol&interval=$_interval&limit=100',
      ));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _candleData = data.map((candle) => {
          'time': DateTime.fromMillisecondsSinceEpoch(candle[0]),
          'open': Decimal.parse(candle[1]),
          'high': Decimal.parse(candle[2]),
          'low': Decimal.parse(candle[3]),
          'close': Decimal.parse(candle[4]),
          'volume': Decimal.parse(candle[5]),
        }).toList();
        _error = '';
      } else {
        _error = 'Failed to fetch candle data: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching candle data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeSymbol(String symbol) async {
    _currentSymbol = symbol.toUpperCase();
    await _initializeMarketData();
  }

  void changeInterval(String newInterval) {
    _interval = newInterval;
    fetchCandleData();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}
