import 'dart:convert'; // For utf8
import 'package:crypto/crypto.dart'; // For sha256 hashing
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trackmycash/screens/lock_setup_screen.dart';

import 'main_nav_scaffold.dart'; // For LockType enum and pref keys

/// NOTE: This basic hashing example is NOT production ready!
/// Use strong hashing (bcrypt/argon2) with salt for real apps.
String _basicHash(String input) {
  if (input.isEmpty) return "";
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with SingleTickerProviderStateMixin {
  LockType _currentLockType = LockType.none;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _inputController = TextEditingController();
  bool _isInputVisible = false;
  bool _isLoading = true;
  String? _errorMessage;

  late final AnimationController _animationController;
  late final Animation<double> _shakeAnimation;

  int _failedAttempts = 0;
  static const int _maxFailedAttempts = 5;

  @override
  void initState() {
    super.initState();
    _initLockScreen();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  Future<void> _initLockScreen() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final lockTypeStr = prefs.getString(_prefLockType as String);

      if (lockTypeStr == null || lockTypeStr == LockType.none.toString()) {
        // No lock set - navigate directly
        _navigateToDashboard();
        return;
      }

      if (lockTypeStr == LockType.pin.toString()) {
        _currentLockType = LockType.pin;
      } else if (lockTypeStr == LockType.password.toString()) {
        _currentLockType = LockType.password;
      } else {
        _currentLockType = LockType.none;
        _navigateToDashboard();
        return;
      }
    } catch (e) {
      _errorMessage = "Failed to load lock settings.";
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateInput(String? val) {
    if (val == null || val.isEmpty) {
      return _currentLockType == LockType.pin ? 'Please enter your PIN' : 'Please enter your Password';
    }
    if (_currentLockType == LockType.pin) {
      if (!RegExp(r'^\d+$').hasMatch(val)) return 'PIN must contain digits only';
      if (val.length < 4) return 'PIN is too short (min 4 digits)';
    } else if (_currentLockType == LockType.password) {
      if (val.length < 6) return 'Password is too short (min 6 chars)';
    }
    return null;
  }

  Future<void> _submitLock() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      _animationController.forward(from: 0);
      return;
    }

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final storedHash = _currentLockType == LockType.pin
        ? prefs.getString(_prefLockPin as String)
        : prefs.getString(_prefLockPassword as String);

    final inputHash = _basicHash(_inputController.text);

    // TODO: Replace storedHash comparison with proper hashed credentials
    final bool isAuthenticated = storedHash == _inputController.text; // For now plain text comparison

    if (isAuthenticated) {
      _failedAttempts = 0;
      _navigateToDashboard();
    } else {
      _failedAttempts++;
      _inputController.clear();
      _animationController.forward(from: 0);

      if (_failedAttempts >= _maxFailedAttempts) {
        _errorMessage = "Too many failed attempts. Try again later.";
      } else {
        _errorMessage = _currentLockType == LockType.pin
            ? 'Incorrect PIN. Please try again.'
            : 'Incorrect Password. Please try again.';
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _navigateToAppContent() { // New, more generic name
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      // Navigate to MainNavScaffold instead of DashboardScreen
      MaterialPageRoute(builder: (_) => const MainNavScaffold()),
          (route) => false, // Remove all previous routes (LockScreen, SplashScreen, etc.)
    );
    print("LockScreen: Navigating to MainNavScaffold");
  }

  @override
  void dispose() {
    _animationController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.green.shade700;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          );
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: _isLoading && _currentLockType == LockType.none
                ? const CircularProgressIndicator()
                : Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    _currentLockType == LockType.pin ? Icons.pin_rounded : Icons.lock_person_outlined,
                    size: 70,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _currentLockType == LockType.pin ? 'Enter Your PIN' : 'Enter Your Password',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please enter your credentials to unlock the app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      labelText: _currentLockType == LockType.pin ? 'PIN' : 'Password',
                      hintText: 'Enter your ${_currentLockType.name}',
                      prefixIcon: Icon(_currentLockType == LockType.pin ? Icons.key_outlined : Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_isInputVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _isInputVisible = !_isInputVisible),
                      ),
                    ),
                    obscureText: !_isInputVisible,
                    keyboardType: _currentLockType == LockType.pin ? TextInputType.number : TextInputType.visiblePassword,
                    inputFormatters: _currentLockType == LockType.pin ? [FilteringTextInputFormatter.digitsOnly] : [],
                    validator: _validateInput,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => (_isLoading || _failedAttempts >= _maxFailedAttempts) ? null : _submitLock(),
                    onChanged: (_) => setState(() => _errorMessage = null),
                    enabled: _failedAttempts < _maxFailedAttempts,
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 14.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: (_isLoading || _failedAttempts >= _maxFailedAttempts) ? null : _submitLock,
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text('Unlock', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 24),
                  // Optional: Forgot PIN/Password flow
                  // if (_failedAttempts > 1)
                  //   TextButton(
                  //     onPressed: _forgotCredentials,
                  //     child: Text(
                  //       _currentLockType == LockType.pin ? 'Forgot PIN?' : 'Forgot Password?',
                  //       style: TextStyle(color: primaryColor),
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _navigateToDashboard {
}

class _prefLockPassword {
}

class _prefLockPin {
}

class _prefLockType {
}
