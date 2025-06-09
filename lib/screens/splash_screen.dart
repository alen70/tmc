import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Assuming these screens are in these locations or adjust imports accordingly
import 'package:trackmycash/screens/auth_screen.dart';
import 'package:trackmycash/screens/lock_screen.dart';     // Actual LockScreen
import 'package:trackmycash/screens/lock_setup_screen.dart';

import 'main_nav_scaffold.dart'; // For LockType enum and pref keys

// --- Define or Import SharedPreferences Keys and LockType ---
// If these are in lock_setup_screen.dart, ensure it's imported.
// Example:
// enum LockType { none, pin, password } // Already in lock_setup_screen.dart
// const String _prefLockType = 'app_lock_type'; // Already in lock_setup_screen.dart
// const String _prefUserAuthToken = 'user_auth_token'; // Define your auth token key
// --- End Definitions ---


// Your existing UserStatus enum is good for categorizing states.
// We'll map the detailed check to these statuses.
enum UserStatus {
  loggedInAndLockSet, // Navigate to LockScreen
  loggedInNoLock,     // Navigate to DashboardScreen
  loggedOut,          // Navigate to AuthScreen
  // Potentially add:
  // firstTimeOrNeedsLockSetup, // If you want to force lock setup after registration
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Key for storing the auth token, ensure this is the same one used in your LoginScreen
  static const String _prefUserAuthToken = 'user_auth_token';


  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate some loading time if needed, or remove if checks are fast enough
    await Future.delayed(const Duration(seconds: 1)); // Reduced delay for faster startup

    UserStatus status = await _checkUserStatus();

    if (!mounted) return;

    _navigateBasedOnStatus(status);
  }

  // Updated user status check
  Future<UserStatus> _checkUserStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 1. Check for user authentication token
    bool isLoggedIn = prefs.getString(_prefUserAuthToken) != null;

    if (isLoggedIn) {
      // 2. User is logged in, now check for app lock settings
      String? lockTypeString = prefs.getString(_prefLockType as String); // from lock_setup_screen.dart

      if (lockTypeString != null && lockTypeString != LockType.none.toString()) {
        // User is logged in AND has an app lock (PIN/Password) set.
        return UserStatus.loggedInAndLockSet;
      } else {
        // User is logged in BUT either no lock type is saved, or it's explicitly set to 'none'.
        return UserStatus.loggedInNoLock;
      }
    } else {
      // 3. User is NOT logged in (no auth token found).
      return UserStatus.loggedOut;
    }
  }

  // Updated navigation logic to use actual screens
  void _navigateBasedOnStatus(UserStatus status) {
    Widget targetScreen;

    switch (status) {
      case UserStatus.loggedInAndLockSet:
        targetScreen = const LockScreen();
        print("SplashScreen: Navigating to LockScreen");
        break;
      case UserStatus.loggedInNoLock:
      // Navigate to MainNavScaffold instead of DashboardScreen directly
        targetScreen = const MainNavScaffold();
        print("SplashScreen: Navigating to MainNavScaffold (was Dashboard)");
        break;
      case UserStatus.loggedOut:
      default:
        targetScreen = const AuthScreen();
        print("SplashScreen: Navigating to AuthScreen");
        break;
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => targetScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFE8F5E9); // Your existing background

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Your existing Image and Text widgets
            Image.asset(
              'assets/images/app_icon.png',
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.money, // Keep your fallback icon
                size: 100,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'TrackMyCash',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 32),
            CircularProgressIndicator(
              color: Colors.green.shade700, // Matched color
              strokeWidth: 3, // Slightly thicker for better visibility
            ),
          ],
        ),
      ),
    );
  }
}

class _prefLockType {
}

// Remove PlaceholderScreen if it's no longer needed elsewhere,
// or keep it if other parts of your app still use it for temporary UI.
// class PlaceholderScreen extends StatelessWidget {
//   final String title;
//   const PlaceholderScreen({super.key, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(title)),
//       body: Center(
//         child: Text(
//           'This is the $title',
//           style: const TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }
// }