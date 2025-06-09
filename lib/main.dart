import 'package:flutter/material.dart';
import 'package:trackmycash/screens/splash_screen.dart'; // Import your splash screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackMyCash',
      theme: ThemeData(
        // You can define your app's theme here
        // For example, to make the primary color green:
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        // If you want a specific font to be default, define it here
        // fontFamily: 'YourCustomFont',
      ),
      debugShowCheckedModeBanner: false, // Optionally remove the debug banner
      home: const SplashScreen(), // Start with your SplashScreen
    );
  }
}