import 'package:flutter/material.dart';
import 'package:trackmycash/screens/register_screen.dart';
// import 'package:trackmycash/screens/login_screen.dart'; // Placeholder
// import 'package:trackmycash/screens/register_screen.dart'; // Placeholder
// For now, using the common PlaceholderScreen from splash_screen.dart

import 'login_screen.dart';


class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  get child => null;

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFE8F5E9); // Same as SplashScreen or from Theme
    final Color primaryColor = Colors.green.shade700;
    final Color buttonTextColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView( // Added for smaller screens if content overflows
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons stretch
            children: <Widget>[
              // App Icon
              Image.asset(
                'assets/images/app_icon.png', // Make sure this path is correct
                width: 100.0, // Slightly smaller than splash, or your preference
                height: 100.0,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.money, // Fallback icon
                  size: 100,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 20.0),

              // App Name
              Text(
                'TrackMyCash',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 48.0), // More space before buttons

              // Login Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  Navigator.push( // Use push to allow back navigation
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()), // Navigate to LoginScreen
                  );
                },
                child: Text(
                  'Login',
                  style: TextStyle(color: buttonTextColor),
                ),
              ),
              const SizedBox(height: 16.0),

              // Register Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  Navigator.push( // Use push to allow back navigation
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()), // Navigate to RegisterScreen
                  );
                },
                child: Text(
                  'Register',
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}