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
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButton<AnalyticsMode>(
              value: _mode,
              items: const [
                DropdownMenuItem(
                  value: AnalyticsMode.expense,
                  child: Text('Expenses'),
                ),
                DropdownMenuItem(
                  value: AnalyticsMode.income,
                  child: Text('Income'),
                ),
                DropdownMenuItem(
                  value: AnalyticsMode.comparison,
                  child: Text('Expense vs Income'),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _mode = val);
              },
            ),
          ),
          Expanded(child: chartWidget),
        ],
      ),
    );
  }
}
