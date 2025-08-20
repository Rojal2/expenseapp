import 'package:flutter/material.dart';
import 'expense_chart.dart';
import 'income_chart.dart';
import 'expense_income_comparison_chart.dart';

enum AnalyticsMode { expense, income, comparison }

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  AnalyticsMode _mode = AnalyticsMode.expense;

  @override
  Widget build(BuildContext context) {
    Widget chartWidget;
    // Determines which chart widget to display based on the selected mode.
    switch (_mode) {
      case AnalyticsMode.expense:
        chartWidget = const ExpenseChart();
        break;
      case AnalyticsMode.income:
        chartWidget = const IncomeChart();
        break;
      case AnalyticsMode.comparison:
        chartWidget = const ExpenseIncomeComparisonChart();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Colors.blueGrey, // AppBar background color
        foregroundColor: Colors.white, // AppBar text color
        centerTitle: true, // Centers the title
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              // Styling for the dropdown container
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12), // Rounded corners
                border: Border.all(
                  color: Colors.blueGrey.shade200,
                ), // Subtle border
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2), // Shadow for depth
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2), // Drop shadow effect
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                // Hides the default underline of the DropdownButton
                child: DropdownButton<AnalyticsMode>(
                  value: _mode,
                  items: [
                    // Apply consistent styling to each DropdownMenuItem's child text
                    DropdownMenuItem(
                      value: AnalyticsMode.expense,
                      child: Text(
                        'Expenses',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                      ),
                    ),
                    DropdownMenuItem(
                      value: AnalyticsMode.income,
                      child: Text(
                        'Income',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                      ),
                    ),
                    DropdownMenuItem(
                      value: AnalyticsMode.comparison,
                      child: Text(
                        'Expense vs Income',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    // Updates the state and re-renders the appropriate chart
                    if (val != null) setState(() => _mode = val);
                  },
                  // Styling for the dropdown text and icon
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 16),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.blueGrey,
                  ), // Custom dropdown icon
                  dropdownColor:
                      Colors.white, // Background color of the dropdown menu
                ),
              ),
            ),
          ),
          // Expanded widget ensures the chart takes up the remaining available space
          Expanded(child: chartWidget),
        ],
      ),
    );
  }
}
