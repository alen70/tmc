import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trackmycash/screens/lock_setup_screen.dart'; // Correct screen to navigate to

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recoveryKeyController = TextEditingController();

  bool _isLoading = false;
  String? _recoveryError;

  static const String dummyValidRecoveryKey = "RECOVERY-1234567890";

  @override
  void dispose() {
    _recoveryKeyController.dispose();
    super.dispose();
  }

  String? _validateRecoveryKey(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your recovery key';
    }
    if (!value.startsWith('RECOVERY-')) {
      return 'Invalid recovery key format';
    }
    if (value.length < 15) {
      return 'Recovery key seems too short';
    }
    return null;
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text?.isNotEmpty ?? false) {
      _recoveryKeyController.text = data!.text!;
      _formKey.currentState?.validate();
      setState(() => _recoveryError = null);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to paste from clipboard.')),
      );
    }
  }

  Future<void> _submitRecoveryKey() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _recoveryError = null;
    });

    await Future.delayed(const Duration(seconds: 2)); // Simulate API call

    final inputKey = _recoveryKeyController.text.trim();
    final isValidKey = inputKey == dummyValidRecoveryKey || inputKey.startsWith("RECOVERY-");

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (isValidKey) {
        _navigateToNextStep();
      } else {
        _recoveryError = "Invalid or expired recovery key. Please check and try again.";
      }
    });
  }

  void _navigateToNextStep() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LockSetupScreen(isComingFromSettings: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.green.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Recovery'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.shield_outlined, size: 60, color: primaryColor),
                const SizedBox(height: 16),
                Text(
                  "Enter Your Recovery Key",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Paste or type the recovery key you saved during registration.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _recoveryKeyController,
                  decoration: InputDecoration(
                    labelText: 'Recovery Key',
                    hintText: 'e.g., RECOVERY-XXXXXXXXXX',
                    prefixIcon: const Icon(Icons.vpn_key_outlined),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: "Paste from Clipboard",
                      icon: const Icon(Icons.content_paste_go_outlined),
                      onPressed: _isLoading ? null : _pasteFromClipboard,
                    ),
                  ),
                  validator: _validateRecoveryKey,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _isLoading ? null : _submitRecoveryKey(),
                  onChanged: (_) => setState(() => _recoveryError = null),
                  minLines: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                if (_recoveryError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _recoveryError!,
                      style: const TextStyle(color: Colors.red, fontSize: 14.5),
                      textAlign: TextAlign.center,
                    ),
                  ),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: _submitRecoveryKey,
                  child: const Text('Verify Recovery Key', style: TextStyle(color: Colors.white)),
                ),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                  child: Text(
                    "Remembered your password? Login",
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
