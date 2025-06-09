import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; // For charts

// Assuming CurrencyManager is accessible (e.g., from a shared service)
// String get currentCurrencySymbol => CurrencyManager().currencySymbol;
String get currentCurrencySymbol => "Rs."; // Mock for now

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now(); // For the calendar next to tabs

  // Mock data - replace with actual data management
  double _mockTotalIncome = 5500.0;
  double _mockTotalExpenses = 2100.0;
  List<GoalMock> _mockGoals = [
    GoalMock(name: "New Phone", current: 300, target: 800),
    GoalMock(name: "Vacation", current: 150, target: 1000),
  ];
  String _userName = "User";


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // For 'Summary' and 'Trend'
    _loadUserName(); //
  }

  void _loadUserName() async {
    // In a real app, load from SharedPreferences or user service
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate loading
    if(mounted) {
      setState(() {
        _userName = "John"; // Replace with actual dynamic name
      });
    }
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  // --- Placeholder Modals ---
  void _showAddIncomeModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Income"),
        content: SingleChildScrollView( // To prevent overflow if content is long
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(label: "Category (e.g., Salary, Freelance)"),
              _buildTextField(label: "Amount", keyboardType: TextInputType.number),
              _buildDateField("Date"),
              // TODO: User addable categories
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () { /* TODO: Save Income */ Navigator.pop(context); }, child: const Text("Add")),
        ],
      ),
    );
  }

  void _showAddExpenseModal() {
    String? expenseType; // 'Fixed' or 'Daily'
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Expense"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown or Radio buttons for Fixed/Daily
              StatefulBuilder( // To update dropdown inside dialog
                  builder: (BuildContext context, StateSetter setStateDialog) {
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "Expense Type"),
                      value: expenseType,
                      items: ['Fixed', 'Daily'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setStateDialog(() {
                          expenseType = newValue;
                        });
                      },
                    );
                  }
              ),
              _buildTextField(label: "Category (e.g., Groceries, Rent)"),
              _buildTextField(label: "Amount", keyboardType: TextInputType.number),
              _buildTextField(label: "Set Expense Limit (Optional)", keyboardType: TextInputType.number),
              _buildDateField("Date"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () { /* TODO: Save Expense */ Navigator.pop(context); }, child: const Text("Add")),
        ],
      ),
    );
  }

  void _showAddGoalModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Goal"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(label: "Goal Name (e.g., New Laptop)"),
              _buildTextField(label: "Target Amount", keyboardType: TextInputType.number),
              _buildDateField("Target Date"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () { /* TODO: Save Goal */ Navigator.pop(context); }, child: const Text("Add")),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildDateField(String label) {
    // This is a simplified version. You'd likely use a button to show a DatePicker.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: DateFormat('yyyy-MM-dd').format(DateTime.now()), // Show current date as hint
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        readOnly: true, // Make it read-only
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (picked != null) {
            // TODO: Update a state variable in the dialog to hold the picked date
            // This requires making the dialog's content a StatefulWidget or using a ValueNotifier.
            print("$label Date selected: ${DateFormat('yyyy-MM-dd').format(picked)}");
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$label Date selected (mock): ${DateFormat('yyyy-MM-dd').format(picked)}"))
            );
          }
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // AppBar is handled by MainNavScaffold
      body: NestedScrollView( // Important for collapsing app bar with tabs
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false, // No back button if part of MainNavScaffold
              title: Text("${_getGreeting()}, $_userName!", style: TextStyle(fontWeight: FontWeight.w500)),
              centerTitle: false,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Match scaffold
              foregroundColor: colorScheme.onBackground,
              elevation: 0, // No shadow for a cleaner look integrated with content
              pinned: true, // Keeps the greeting visible
              floating: true, // Greeting reappears when scrolling up
              forceElevated: innerBoxIsScrolled, // Show shadow when content scrolls under
              bottom: PreferredSize( // Combined TabBar and Date Picker
                preferredSize: const Size.fromHeight(kToolbarHeight + 10), // Adjust height as needed
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TabBar(
                          controller: _tabController,
                          labelColor: colorScheme.primary,
                          unselectedLabelColor: colorScheme.onSurfaceVariant.withOpacity(0.7),
                          indicatorColor: colorScheme.primary,
                          indicatorWeight: 2.5,
                          isScrollable: false, // If more tabs, set to true
                          tabs: const [
                            Tab(text: 'Summary'),
                            Tab(text: 'Trend'),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today_outlined, color: colorScheme.primary),
                        tooltip: "Select Date",
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != _selectedDate) {
                            setState(() {
                              _selectedDate = picked;
                              // TODO: Trigger data reload for the new date
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Data for ${DateFormat.yMMMd().format(_selectedDate)} (mock)."))
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 8), // Padding for the calendar icon
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSummaryTab(context),
            _buildTrendTab(context),
          ],
        ),
      ),
      floatingActionButton: _buildSpeedDialFAB(),
    );
  }

  SpeedDial _buildSpeedDialFAB() {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      activeBackgroundColor: Theme.of(context).colorScheme.secondary,
      activeForegroundColor: Theme.of(context).colorScheme.onSecondary,
      buttonSize: const Size(56.0, 56.0),
      childrenButtonSize: const Size(60.0, 60.0),
      visible: true,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      tooltip: 'Add Entry',
      heroTag: 'speed-dial-hero-tag',
      elevation: 8.0,
      shape: const CircleBorder(),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.arrow_downward_rounded),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          label: 'Add Income',
          onTap: _showAddIncomeModal,
        ),
        SpeedDialChild(
          child: const Icon(Icons.arrow_upward_rounded),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          label: 'Add Expense',
          onTap: _showAddExpenseModal,
        ),
        SpeedDialChild(
          child: const Icon(Icons.flag_rounded),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          label: 'Add Goal',
          onTap: _showAddGoalModal,
        ),
      ],
    );
  }

  // --- Summary Tab ---
  Widget _buildSummaryTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalsCard(),
          const SizedBox(height: 20),
          Text("Income vs Expenses", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          _buildPieChartCard(), // Placeholder for pie chart
          const SizedBox(height: 10),
          _buildBarChartCard(), // Placeholder for bar chart
          const SizedBox(height: 20),
          Text("Financial Goals", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ..._mockGoals.map((goal) => _buildGoalProgressCard(goal)).toList(),
          const SizedBox(height: 20),
          Text("Budget Alerts", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          _buildBudgetAlertCard("You've spent 85% of your Dining budget!", Colors.orange.shade100, Colors.orange.shade800),
          // Add more alerts or a list here
          const SizedBox(height: 20),
          _buildImportExportSection(),
        ],
      ),
    );
  }

  Widget _buildTotalsCard() {
    double netBalance = _mockTotalIncome - _mockTotalExpenses;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTotalItem("Income", _mockTotalIncome, Colors.green.shade600),
            _buildTotalItem("Expenses", _mockTotalExpenses, Colors.red.shade600),
            _buildTotalItem("Net Balance", netBalance, Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey.shade700)),
        const SizedBox(height: 4),
        Text("$currentCurrencySymbol${amount.toStringAsFixed(0)}", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPieChartCard() {
    // Placeholder for Pie Chart. Use fl_chart or similar here.
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 200,
        alignment: Alignment.center,
        child: PieChart( // Basic Example - Customize extensively
            PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [ // Replace with dynamic data
                  PieChartSectionData(color: Colors.blue, value: 40, title: '40%', radius: 50, titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  PieChartSectionData(color: Colors.red, value: 30, title: '30%', radius: 50, titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  PieChartSectionData(color: Colors.green, value: 20, title: '20%', radius: 50, titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  PieChartSectionData(color: Colors.orange, value: 10, title: '10%', radius: 50, titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                ]
            )
        ),
        // child: const Text("Beautiful Pie Chart Area (Income/Expense Categories)", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
      ),
    );
  }
  Widget _buildBarChartCard() {
    // Placeholder for Bar Chart. Use fl_chart.
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 200,
        alignment: Alignment.center,
        child: BarChart( // Basic Example
            BarChartData(
              // Read fl_chart docs for customization
                alignment: BarChartAlignment.spaceAround,
                maxY: 20, // Adjust based on your data
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.lightBlue, width: 15)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: Colors.lightBlue, width: 15)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: Colors.lightBlue, width: 15)]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: Colors.red, width: 15)]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 13, color: Colors.lightBlue, width: 15)]),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 5)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                    const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10);
                    String text;
                    switch (value.toInt()) {
                      case 0: text = 'Jan'; break; case 1: text = 'Feb'; break; case 2: text = 'Mar'; break;
                      case 3: text = 'Apr'; break; case 4: text = 'May'; break; default: text = ''; break;
                    }
                    return SideTitleWidget(axisSide: meta.axisSide, space: 4.0, child: Text(text, style: style));
                  })),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                )
            )
        ),
        // child: const Text("Beautiful Bar Graph Area (Income vs Expenses Monthly)",textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
      ),
    );
  }


  Widget _buildGoalProgressCard(GoalMock goal) {
    double progress = (goal.target > 0) ? (goal.current / goal.target) : 0.0;
    progress = progress.clamp(0.0, 1.0); // Ensure progress is between 0 and 1

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(width: 10),
                Text("${(progress * 100).toStringAsFixed(0)}%", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 4),
            Text("$currentCurrencySymbol${goal.current.toStringAsFixed(0)} / $currentCurrencySymbol${goal.target.toStringAsFixed(0)}", style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetAlertCard(String message, Color backgroundColor, Color textColor) {
    return Card(
      color: backgroundColor,
      elevation: 0, // Flat design for alerts often looks good
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: textColor, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: TextStyle(color: textColor, fontWeight: FontWeight.w500))),
          ],
        ),
      ),
    );
  }

  // --- Trend Tab ---
  Widget _buildTrendTab(BuildContext context) {
    // Placeholder - Implement charts and insights here
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Income & Expense Trends (Monthly)", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Container(
            height: 250,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8)
            ),
            alignment: Alignment.center,
            child: const Text("Trend Chart Area (e.g., Line chart with fl_chart)", style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 20),
          Text("Financial Health Insights", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          _buildInsightCard("Your spending on 'Dining Out' increased by 15% this month compared to last month.", Colors.blue.shade50),
          _buildInsightCard("You are consistently saving 20% of your income. Great job!", Colors.green.shade50),
          // Add more insight cards
          const SizedBox(height: 20),
          _buildImportExportSection(), // Can also be here or only in summary
        ],
      ),
    );
  }

  Widget _buildInsightCard(String insightText, Color cardColor) {
    return Card(
      color: cardColor,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(insightText, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }


  // --- Bottom Section: Import/Export ---
  Widget _buildImportExportSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Data Management", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.file_download_outlined),
                label: const Text("Export Data"),
                onPressed: () {
                  // TODO: Implement Export Logic (CSV, XLSX, PDF)
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Export functionality coming soon!"))
                  );
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.file_upload_outlined),
                label: const Text("Import Data"),
                onPressed: () {
                  // TODO: Implement Import Logic
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Import functionality coming soon!"))
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Mock Data Class for Goals ---
class GoalMock {
  final String name;
  final double current;
  final double target;
  GoalMock({required this.name, required this.current, required this.target});
}

// --- Error Handling (Conceptual) ---
// You would call this from your data saving/validation logic
void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating, // Or .fixed
    ),
  );
}
// Example usage:
// if (amount <= 0) {
//   showErrorSnackbar(context, "Amount must be greater than $currentCurrencySymbol 0");
//   return;
// }