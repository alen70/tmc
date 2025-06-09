import 'package:flutter/material.dart';

class BankIntegrationScreen extends StatefulWidget {
  const BankIntegrationScreen({super.key});

  @override
  State<BankIntegrationScreen> createState() => _BankIntegrationScreenState();
}

class _BankIntegrationScreenState extends State<BankIntegrationScreen> {
  final List<Map<String, String>> _linkedAccounts = [];

  bool _isLinking = false;

  static const List<String> _mockBanks = [
    "Bank of Example",
    "Mock Trust Bank",
    "Demo Financial",
    "Test Credit Union",
    "Sample Savings & Loan"
  ];

  Future<void> _mockShowBankSelection() async {
    setState(() => _isLinking = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    String? selectedBank;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Your Bank"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _mockBanks.length,
                  itemBuilder: (_, index) {
                    final bank = _mockBanks[index];
                    return RadioListTile<String>(
                      title: Text(bank),
                      value: bank,
                      groupValue: selectedBank,
                      onChanged: (value) => setDialogState(() => selectedBank = value),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: selectedBank == null
                      ? null
                      : () => Navigator.of(dialogContext).pop(selectedBank),
                  child: const Text("Continue"),
                ),
              ],
            );
          },
        );
      },
    );

    setState(() => _isLinking = false);

    if (result != null) {
      _mockSimulateAccountLink(result);
    } else {
      _showSnackBar("Bank linking cancelled.", color: Colors.orange);
    }
  }

  Future<void> _mockSimulateAccountLink(String bankName) async {
    setState(() => _isLinking = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final newAccount = {
      "bankName": bankName,
      "accountType": "Checking Account (Mock)",
      "lastFour": (1000 + DateTime.now().millisecond % 9000).toString(),
      "logoAsset": "assets/logos/generic_bank_logo.png",
    };

    setState(() {
      _linkedAccounts.add(newAccount);
      _isLinking = false;
    });

    _showSnackBar("$bankName linked successfully!", color: Colors.green);
  }

  void _showSnackBar(String message, {required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_off, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              "No Bank Accounts Linked",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Link your bank accounts to automatically track transactions.",
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(Map<String, String> account, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(Icons.account_balance_wallet_outlined,
            size: 40, color: Theme.of(context).colorScheme.primary),
        title: Text(account["bankName"] ?? "Unknown Bank",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          "${account["accountType"]} ****${account["lastFour"]}",
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
          onPressed: () {
            setState(() => _linkedAccounts.removeAt(index));
            _showSnackBar("${account["bankName"]} unlinked.", color: Colors.blueGrey);
          },
        ),
      ),
    );
  }

  Widget _buildLinkedAccountsList() {
    if (_linkedAccounts.isEmpty) return _buildEmptyState();

    return ListView.builder(
      itemCount: _linkedAccounts.length,
      itemBuilder: (_, index) => _buildAccountCard(_linkedAccounts[index], index),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _buildLinkedAccountsList()),
          if (_isLinking)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_link, color: Colors.white),
              label: const Text(
                "Link New Bank Account",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size.fromHeight(50),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isLinking ? null : _mockShowBankSelection,
            ),
          ),
        ],
      ),
    );
  }
}
