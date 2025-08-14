import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/budget.dart';

class AnalyticsSection extends StatelessWidget {
  final Map<String, double> monthlyExpenses;
  final Budget? budget;

  const AnalyticsSection({
    super.key,
    required this.monthlyExpenses,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (monthlyExpenses.isNotEmpty) ...[
              _buildExpenseChart(),
              const SizedBox(height: 20),
              _buildBudgetComparison(),
            ] else
              const Center(child: Text('No expense data available')),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment
              .spaceAround, // Fixed: Using correct alignment property
          maxY: _getMaxExpense() * 1.2,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final months = monthlyExpenses.keys.toList();
                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                    return Text(
                      _formatMonthLabel(months[value.toInt()]),
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: _createBarGroups(),
        ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups() {
    final months = monthlyExpenses.keys.toList();
    return months.asMap().entries.map((entry) {
      final index = entry.key;
      final month = entry.value;
      final amount = monthlyExpenses[month] ?? 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: amount, // Fixed: Using named parameter instead of positional
            color: _getBarColor(month),
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  Color _getBarColor(String month) {
    if (budget?.monthlyBudgets[month] != null) {
      final budgetAmount = budget!.monthlyBudgets[month]!;
      final expenseAmount = monthlyExpenses[month] ?? 0.0;
      return expenseAmount > budgetAmount ? Colors.red : Colors.green;
    }
    return Colors.blue;
  }

  double _getMaxExpense() {
    if (monthlyExpenses.isEmpty) return 0.0;
    return monthlyExpenses.values.reduce((a, b) => a > b ? a : b);
  }

  String _formatMonthLabel(String monthKey) {
    // Assuming monthKey format is "YYYY-MM"
    final parts = monthKey.split('-');
    if (parts.length == 2) {
      final month = int.tryParse(parts[1]) ?? 1;
      const monthNames = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return monthNames[month];
    }
    return monthKey;
  }

  Widget _buildBudgetComparison() {
    if (budget == null) {
      return const Text('No budget data available for comparison');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget vs Expenses',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...monthlyExpenses.entries.map((entry) {
          final month = entry.key;
          final expense = entry.value;
          final budgetAmount = budget!.monthlyBudgets[month] ?? 0.0;

          return _buildComparisonRow(
            _formatMonthLabel(month),
            budgetAmount,
            expense,
          );
        }),
      ],
    );
  }

  Widget _buildComparisonRow(String month, double budget, double expense) {
    final isOverBudget = budget > 0 && expense > budget;
    final percentage = budget > 0 ? (expense / budget) * 100 : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(month),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: isOverBudget ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: budget > 0 ? (expense / budget).clamp(0.0, 1.0) : 0.0,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              isOverBudget ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget: \$${budget.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Spent: \$${expense.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
