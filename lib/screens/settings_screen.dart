import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackmycash/screens/auth_screen.dart';
import 'package:trackmycash/screens/lock_setup_screen.dart';

// --- Global Currency Manager ---
class CurrencyManager {
  static final CurrencyManager _instance = CurrencyManager._internal();
  factory CurrencyManager() => _instance;
  CurrencyManager._internal();

  String _currencySymbol = "Rs."; // Default currency
  String get currencySymbol => _currencySymbol;

  Future<void> setCurrency(String newSymbol) async {
    _currencySymbol = newSymbol;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_symbol', newSymbol);
    print("Currency changed to: $_currencySymbol");
  }

  Future<void> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _currencySymbol = prefs.getString('currency_symbol') ?? "Rs.";
  }
}

String get currentCurrencySymbol => CurrencyManager().currencySymbol;
// --- End Currency Manager ---

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userEmail = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await CurrencyManager().loadCurrency();
    await _loadUserEmail();
    if (mounted) setState(() {});
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('user_email') ?? "user@example.com (Mock)";
  }

  void _navigateToLockSettings() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const LockSetupScreen(isComingFromSettings: true),
    ));
  }

  void _navigateToProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile screen coming soon!"),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Account?", style: TextStyle(color: Theme.of(context).colorScheme.error)),
        content: const Text(
          "This will permanently delete your account and data. This action cannot be undone.",
        ),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context, false)),
          TextButton(
            child: Text("Delete", style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Simulated backend API call
      await Future.delayed(const Duration(seconds: 1));
      await _logout(isAccountDeletion: true);
    }
  }

  Future<void> _logout({bool isAccountDeletion = false}) async {
    final confirmed = isAccountDeletion
        ? true
        : await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context, false)),
          TextButton(
            child: Text("Log Out", style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
            (route) => false,
      );
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("About TrackMyCash"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Version: 1.0.0 (Development)"),
            const SizedBox(height: 8),
            const Text("Manage your finances with ease."),
            const SizedBox(height: 16),
            Text("Default Currency: $currentCurrencySymbol"),
            const SizedBox(height: 16),
            Text("© ${DateTime.now().year} Your Company Name"),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void _changeCurrency() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Currency switcher coming soon! Current: $currentCurrencySymbol"),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Theme.of(context).iconTheme.color),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")), // Optional
      body: ListView(
        children: [
          _sectionTitle("Security"),
          _settingsTile(
            icon: Icons.lock_outline,
            title: "App Lock",
            subtitle: "Change PIN or password",
            onTap: _navigateToLockSettings,
          ),
          const Divider(),

          _sectionTitle("Account"),
          _settingsTile(
            icon: Icons.person_outline,
            title: "Profile",
            subtitle: _userEmail,
            onTap: _navigateToProfile,
          ),
          _settingsTile(
            icon: Icons.delete_forever_outlined,
            iconColor: errorColor,
            title: "Delete Account",
            subtitle: "Permanently remove your account",
            onTap: _deleteAccount,
            trailing: Icon(Icons.warning_amber_rounded, color: errorColor),
          ),
          const Divider(),

          _sectionTitle("Preferences"),
          _settingsTile(
            icon: Icons.attach_money,
            title: "Currency",
            subtitle: "Current: $currentCurrencySymbol",
            onTap: _changeCurrency,
            trailing: Text(
              currentCurrencySymbol,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const Divider(),

          _sectionTitle("Info & Support"),
          _settingsTile(
            icon: Icons.info_outline,
            title: "About",
            onTap: _showAboutDialog,
          ),
          _settingsTile(
            icon: Icons.logout,
            iconColor: errorColor,
            title: "Log Out",
            onTap: () => _logout(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
