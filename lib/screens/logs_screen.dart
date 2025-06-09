import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Replace with actual currency symbol retrieval (via a manager or user settings)
String get currentCurrencySymbol => "Rs.";

enum LogEntryType { income, expense, goal }

class LogEntry {
  final String id;
  final DateTime date;
  final LogEntryType type;
  final String description;
  final double amount;
  final String category;
  final double targetAmount;
  final double currentProgress;

  LogEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.description,
    this.amount = 0.0,
    this.category = '',
    this.targetAmount = 0.0,
    this.currentProgress = 0.0,
  });
}

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<LogEntry> _allLogEntries = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMockLogEntries();
  }

  void _loadMockLogEntries() {
    final now = DateTime.now();
    _allLogEntries.addAll([
      LogEntry(
        id: 'inc1',
        date: now.subtract(const Duration(days: 1)),
        type: LogEntryType.income,
        description: 'Salary March',
        amount: 50000,
        category: 'Salary',
      ),
      LogEntry(
        id: 'exp1',
        date: now.subtract(const Duration(days: 1, hours: 2)),
        type: LogEntryType.expense,
        description: 'Groceries',
        amount: 2500,
        category: 'Food',
      ),
      LogEntry(
        id: 'goal1',
        date: now.subtract(const Duration(days: 5)),
        type: LogEntryType.goal,
        description: 'New Laptop Fund',
        targetAmount: 75000,
        currentProgress: 15000,
      ),
      LogEntry(
        id: 'inc2',
        date: now.subtract(const Duration(days: 3)),
        type: LogEntryType.income,
        description: 'Freelance Project',
        amount: 10000,
        category: 'Freelance',
      ),
      LogEntry(
        id: 'exp2',
        date: now.subtract(const Duration(days: 2, hours: 5)),
        type: LogEntryType.expense,
        description: 'Movie Tickets',
        amount: 600,
        category: 'Entertainment',
      ),
      LogEntry(
        id: 'exp3',
        date: now,
        type: LogEntryType.expense,
        description: 'Dinner Out',
        amount: 1200,
        category: 'Food',
      ),
      LogEntry(
        id: 'goal2',
        date: now.subtract(const Duration(days: 10)),
        type: LogEntryType.goal,
        description: 'Vacation Savings',
        targetAmount: 100000,
        currentProgress: 20000,
      ),
    ]);

    _allLogEntries.sort((a, b) => b.date.compareTo(a.date));
    if (mounted) setState(() {});
  }

  List<LogEntry> _getEntriesForType(LogEntryType type) {
    return _allLogEntries.where((e) => e.type == type).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: theme.colorScheme.surfaceVariant,
            child: TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor:
              theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              indicatorColor: theme.colorScheme.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Income'),
                Tab(text: 'Expenses'),
                Tab(text: 'Goals'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLogList(_getEntriesForType(LogEntryType.income)),
                _buildLogList(_getEntriesForType(LogEntryType.expense)),
                _buildLogList(_getEntriesForType(LogEntryType.goal)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogList(List<LogEntry> entries) {
    if (entries.isEmpty) {
      return const Center(
        child: Text('No entries yet.', style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.builder(
      itemCount: entries.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) => _buildLogListItem(entries[index]),
    );
  }

  Widget _buildLogListItem(LogEntry entry) {
    final dateStr = DateFormat('EEE, MMM d, yyyy').format(entry.date);
    String subtitle = '';
    Color amountColor = Colors.black;
    IconData icon;

    switch (entry.type) {
      case LogEntryType.income:
        subtitle =
        '${entry.description} (${currentCurrencySymbol}${entry.amount.toStringAsFixed(2)}) - ${entry.category}';
        amountColor = Colors.green.shade700;
        icon = Icons.arrow_downward_rounded;
        break;
      case LogEntryType.expense:
        subtitle =
        '${entry.description} (${currentCurrencySymbol}${entry.amount.toStringAsFixed(2)}) - ${entry.category}';
        amountColor = Colors.red.shade700;
        icon = Icons.arrow_upward_rounded;
        break;
      case LogEntryType.goal:
        final progressPercent = (entry.targetAmount > 0)
            ? entry.currentProgress / entry.targetAmount
            : 0.0;
        subtitle =
        '${entry.description}\nTarget: ${currentCurrencySymbol}${entry.targetAmount.toStringAsFixed(2)} | Progress: ${(progressPercent * 100).toStringAsFixed(0)}%';
        amountColor = Colors.blue.shade700;
        icon = Icons.flag_rounded;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(icon, color: amountColor),
        title: Text(dateStr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
          onSelected: (value) {
            if (value == 'edit') {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Edit "${entry.description}" (coming soon)')));
            } else if (value == 'delete') {
              _confirmDelete(entry);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
        isThreeLine: entry.type == LogEntryType.goal,
      ),
    );
  }

  void _confirmDelete(LogEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text(
            "Are you sure you want to delete '${entry.description}'? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allLogEntries.removeWhere((e) => e.id == entry.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("'${entry.description}' deleted."),
                backgroundColor: Colors.orange,
              ));
            },
            child: Text("Delete", style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }
}
