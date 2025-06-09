import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackmycash/screens/main_nav_scaffold.dart';

enum LockType { none, pin, password }

const String _prefLockType = 'app_lock_type';
const String _prefLockPin = 'app_lock_pin';
const String _prefLockPassword = 'app_lock_password';

class LockSetupScreen extends StatefulWidget {
  final bool isComingFromSettings;

  const LockSetupScreen({super.key, this.isComingFromSettings = false});

  @override
  State<LockSetupScreen> createState() => _LockSetupScreenState();
}

class _LockSetupScreenState extends State<LockSetupScreen> {
  LockType _selectedLockType = LockType.none;
  final _formKey = GlobalKey<FormState>();

  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPinVisible = false;
  bool _isConfirmPinVisible = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveLockPreferencesAndNavigate() async {
    if (_selectedLockType != LockType.none && !_formKey.currentState!.validate()) {
      setState(() => _errorMessage = "Please correct the errors above.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      switch (_selectedLockType) {
        case LockType.pin:
          await prefs.setString(_prefLockPin, _pinController.text); // 🔒 Consider hashing
          await prefs.remove(_prefLockPassword);
          break;
        case LockType.password:
          await prefs.setString(_prefLockPassword, _passwordController.text); // 🔒 Consider hashing
          await prefs.remove(_prefLockPin);
          break;
        case LockType.none:
          await prefs.remove(_prefLockPin);
          await prefs.remove(_prefLockPassword);
          break;
      }

      await prefs.setString(_prefLockType, _selectedLockType.toString());

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavScaffold()),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to save lock settings: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Future<void> _onSkip() async {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavScaffold()),
          (route) => false,
    );
  }

  String? _validatePin(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a PIN';
    if (value.length < 4 || value.length > 6) return 'PIN must be 4–6 digits';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'PIN must be numeric';
    return null;
  }

  String? _validateConfirmPin(String? value) =>
      value != _pinController.text ? 'PINs do not match' : null;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) =>
      value != _passwordController.text ? 'Passwords do not match' : null;

  Widget _buildLockOptionSelection(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Choose your preferred app lock method:",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        ...LockType.values.where((type) => type != LockType.none).map(
              (type) => RadioListTile<LockType>(
            title: Text(
              type == LockType.pin ? '4–6 Digit PIN' : 'Password',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              type == LockType.pin
                  ? 'Quick and easy numeric code.'
                  : 'Alphanumeric, more secure.',
            ),
            value: type,
            groupValue: _selectedLockType,
            onChanged: (value) {
              setState(() {
                _selectedLockType = value!;
                _pinController.clear();
                _confirmPinController.clear();
                _passwordController.clear();
                _confirmPasswordController.clear();
                _errorMessage = null;
              });
            },
            activeColor: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Icon prefixIcon,
    required bool isObscured,
    required VoidCallback toggleVisibility,
    required FormFieldValidator<String> validator,
    required TextInputAction action,
    VoidCallback? onSubmit,
    List<TextInputFormatter>? formatters,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscured,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(isObscured
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined),
          onPressed: toggleVisibility,
        ),
      ),
      validator: validator,
      textInputAction: action,
      inputFormatters: formatters,
      onFieldSubmitted: (_) => onSubmit?.call(),
      onChanged: (_) => setState(() => _errorMessage = null),
    );
  }

  Widget _buildPinFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _pinController,
          label: 'Enter PIN',
          prefixIcon: const Icon(Icons.pin_outlined),
          isObscured: !_isPinVisible,
          toggleVisibility: () =>
              setState(() => _isPinVisible = !_isPinVisible),
          validator: _validatePin,
          action: TextInputAction.next,
          formatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPinController,
          label: 'Confirm PIN',
          prefixIcon: const Icon(Icons.pin_outlined),
          isObscured: !_isConfirmPinVisible,
          toggleVisibility: () =>
              setState(() => _isConfirmPinVisible = !_isConfirmPinVisible),
          validator: _validateConfirmPin,
          action: TextInputAction.done,
          onSubmit: _saveLockPreferencesAndNavigate,
          formatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _passwordController,
          label: 'Enter Password',
          prefixIcon: const Icon(Icons.lock_outline),
          isObscured: !_isPasswordVisible,
          toggleVisibility: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
          validator: _validatePassword,
          action: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          prefixIcon: const Icon(Icons.lock_outline),
          isObscured: !_isConfirmPasswordVisible,
          toggleVisibility: () =>
              setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
          validator: _validateConfirmPassword,
          action: TextInputAction.done,
          onSubmit: _saveLockPreferencesAndNavigate,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.green.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up App Lock'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: widget.isComingFromSettings,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: TextStyle(
            color: primaryColor, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Icon(Icons.lock_person_outlined, size: 60, color: primaryColor),
                const SizedBox(height: 16),
                const Text("Secure Your App",
                    textAlign: TextAlign.center,
                    style:
                    TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  widget.isComingFromSettings
                      ? "Change or remove your app lock."
                      : "Add an extra layer of security to protect your financial data.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 32),
                _buildLockOptionSelection(primaryColor),
                const SizedBox(height: 24),
                if (_selectedLockType == LockType.pin) _buildPinFields(),
                if (_selectedLockType == LockType.password)
                  _buildPasswordFields(),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(_errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center),
                  ),
                if (_selectedLockType != LockType.none)
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _saveLockPreferencesAndNavigate,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding:
                        const EdgeInsets.symmetric(vertical: 16)),
                    child: Text(
                      widget.isComingFromSettings
                          ? 'Update Lock'
                          : 'Set Lock',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 16),
                if (!widget.isComingFromSettings ||
                    (_selectedLockType == LockType.none &&
                        widget.isComingFromSettings))
                  TextButton(
                    onPressed: _isLoading ? null : _onSkip,
                    child: Text(
                      widget.isComingFromSettings
                          ? 'No Lock Set (Tap to Secure)'
                          : 'Skip For Now',
                      style: TextStyle(color: primaryColor, fontSize: 16),
                    ),
                  ),
                if (widget.isComingFromSettings &&
                    _selectedLockType != LockType.none)
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Remove App Lock?"),
                        content: const Text(
                            "Are you sure you want to remove the app lock?"),
                        actions: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context),
                              child: const Text("Cancel")),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _onSkip();
                            },
                            child: const Text("Remove",
                                style:
                                TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                    child: const Text('Remove App Lock',
                        style: TextStyle(color: Colors.red, fontSize: 16)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
