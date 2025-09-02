import 'package:flutter/material.dart';
import 'expense_chart.dart';
import 'income_chart.dart';
import 'expense_income_comparison_chart.dart';
import 'package:intl/intl.dart';

enum AnalyticsMode { expense, income, comparison }

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  AnalyticsMode _mode = AnalyticsMode.expense;

  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;
  int? _selectedWeek;

  List<int> get yearOptions {
    int currentYear = DateTime.now().year;
    return List.generate(5, (i) => currentYear - i);
  }

  List<int> get monthOptions => List.generate(12, (i) => i + 1);
  List<int> get weekOptions => List.generate(4, (i) => i + 1);

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    Widget? hint,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueGrey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            hint: hint,
            isExpanded: true,
            style: const TextStyle(color: Colors.blueGrey, fontSize: 16),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
            dropdownColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getPeriodData() {
    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate;
    String periodLabel;

    if (_selectedMonth == null) {
      startDate = DateTime(_selectedYear, 1, 1);
      endDate = DateTime(_selectedYear, 12, 31);
      if (endDate.isAfter(now)) endDate = now;
      periodLabel = '$_selectedYear';
    } else if (_selectedWeek == null) {
      startDate = DateTime(_selectedYear, _selectedMonth!, 1);
      endDate = DateTime(_selectedYear, _selectedMonth! + 1, 0);
      if (endDate.isAfter(now)) endDate = now;
      periodLabel = '${DateFormat.MMMM().format(startDate)} $_selectedYear';
    } else {
      DateTime firstDayOfMonth = DateTime(_selectedYear, _selectedMonth!, 1);
      startDate = firstDayOfMonth.add(Duration(days: (_selectedWeek! - 1) * 7));
      endDate = startDate.add(const Duration(days: 6));

      DateTime lastDayOfMonth = DateTime(_selectedYear, _selectedMonth! + 1, 0);
      if (endDate.isAfter(lastDayOfMonth)) endDate = lastDayOfMonth;
      if (endDate.isAfter(now)) endDate = now;

      periodLabel =
          'Week $_selectedWeek: ${DateFormat('MMM dd').format(startDate)} – ${DateFormat('MMM dd').format(endDate)}';
    }

    return {
      'startDate': startDate,
      'endDate': endDate,
      'periodLabel': periodLabel,
    };
  }

  @override
  Widget build(BuildContext context) {
    final periodData = _getPeriodData();
    final startDate = periodData['startDate'];
    final endDate = periodData['endDate'];
    final periodLabel = periodData['periodLabel'];

    Widget chartWidget;
    switch (_mode) {
      case AnalyticsMode.expense:
        chartWidget = ExpenseChart(
          startDate: startDate,
          endDate: endDate,
          periodLabel: periodLabel,
        );
        break;
      case AnalyticsMode.income:
        chartWidget = IncomeChart(
          startDate: startDate,
          endDate: endDate,
          periodLabel: periodLabel,
        );
        break;
      case AnalyticsMode.comparison:
        chartWidget = const ExpenseIncomeComparisonChart();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mode Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueGrey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
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
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16,
                    ),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Period Filters (Year / Month / Week)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildDropdown<int>(
                  value: _selectedYear,
                  items: yearOptions
                      .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedYear = val;
                        _selectedMonth = null;
                        _selectedWeek = null;
                      });
                    }
                  },
                ),
                const SizedBox(width: 12),
                _buildDropdown<int?>(
                  hint: const Text('Month'),
                  value: _selectedMonth,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All Months'),
                    ),
                    ...monthOptions.map(
                      (m) => DropdownMenuItem<int?>(
                        value: m,
                        child: Text(DateFormat.MMMM().format(DateTime(0, m))),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedMonth = val;
                      _selectedWeek = null;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _buildDropdown<int?>(
                  hint: const Text('Week'),
                  value: _selectedWeek,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All Weeks'),
                    ),
                    ...weekOptions.map(
                      (w) => DropdownMenuItem<int?>(
                        value: w,
                        child: Text('Week $w'),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedWeek = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Chart fills the rest of screen
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: chartWidget,
            ),
          ),
        ],
      ),
    );
  }
}
