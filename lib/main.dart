import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trader_app/screens/home_screen.dart';
import 'package:trader_app/providers/market_provider.dart';
import 'package:trader_app/providers/theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Advanced Trading App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness:
              themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
