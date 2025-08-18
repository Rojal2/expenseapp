import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/expense_service.dart';
import 'package:intl/intl.dart';

class ExpenseChart extends StatefulWidget {
  const ExpenseChart({super.key});

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  final ExpenseService _expenseService = ExpenseService();
  Map<String, double> _data = {};
  bool _loading = true;

  // Dropdown selections
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth; // optional
  int? _selectedWeek; // optional

  String _currentPeriodLabel = '';

  /// Last 5 years
  List<int> get yearOptions {
    int currentYear = DateTime.now().year;
    return List.generate(5, (i) => currentYear - i);
  }

  /// Months limited by year
  List<int> get monthOptions {
    if (_selectedYear == DateTime.now().year) {
      return List.generate(DateTime.now().month, (i) => i + 1);
    } else {
      return List.generate(12, (i) => i + 1);
    }
  }

  /// Weeks in selected month, max 4 weeks
  List<int> get weekOptions {
    if (_selectedMonth == null) return [];
    int totalWeeks = 4; // fixed 4 weeks
    DateTime now = DateTime.now();
    // If current month/year, limit to current week
    if (_selectedYear == now.year && _selectedMonth == now.month) {
      int currentWeek = ((now.day - 1) / 7).ceil() + 1;
      if (currentWeek < 4) totalWeeks = currentWeek;
    }
    return List.generate(totalWeeks, (i) => i + 1);
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      _loading = true;
    });

    DateTime startDate;
    DateTime endDate;
    DateTime now = DateTime.now();

    // Determine start/end based on selected filters
    if (_selectedMonth == null) {
      // Whole year
      startDate = DateTime(_selectedYear, 1, 1);
      endDate = DateTime(_selectedYear, 12, 31);
      if (endDate.isAfter(now)) endDate = now;
      _currentPeriodLabel = 'Year: $_selectedYear';
    } else if (_selectedWeek == null) {
      // Whole month
      startDate = DateTime(_selectedYear, _selectedMonth!, 1);
      endDate = DateTime(_selectedYear, _selectedMonth! + 1, 0);
      if (endDate.isAfter(now)) endDate = now;
      _currentPeriodLabel =
          'Month: ${DateFormat.MMMM().format(startDate)} $_selectedYear';
    } else {
      // Specific week (4 weeks max)
      startDate = DateTime(
        _selectedYear,
        _selectedMonth!,
        1,
      ).add(Duration(days: (_selectedWeek! - 1) * 7));
      endDate = startDate.add(const Duration(days: 6));
      if (endDate.isAfter(now)) endDate = now;
      _currentPeriodLabel =
          'Week $_selectedWeek: ${DateFormat('MMM dd').format(startDate)} – ${DateFormat('MMM dd').format(endDate)}';
    }

    String startStr = DateFormat('yyyy-MM-dd').format(startDate);
    String endStr = DateFormat('yyyy-MM-dd').format(endDate);

    Map<String, double> data = await _expenseService.getExpensesByDateRange(
      startStr: startStr,
      endStr: endStr,
    );

    setState(() {
      _data = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dropdowns
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Year dropdown
              DropdownButton<int>(
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
                      fetchData();
                    });
                  }
                },
              ),
              const SizedBox(width: 16),
              // Month dropdown (optional)
              DropdownButton<int?>(
                hint: const Text('Month'),
                value: _selectedMonth,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Months'),
                  ),
                  ...monthOptions
                      .map(
                        (m) => DropdownMenuItem<int?>(
                          value: m,
                          child: Text(DateFormat.MMMM().format(DateTime(0, m))),
                        ),
                      )
                      .toList(),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedMonth = val;
                    _selectedWeek = null;
                    fetchData();
                  });
                },
              ),
              const SizedBox(width: 16),
              // Week dropdown (optional)
              DropdownButton<int?>(
                hint: const Text('Week'),
                value: _selectedWeek,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Weeks'),
                  ),
                  ...weekOptions
                      .map(
                        (w) => DropdownMenuItem<int?>(
                          value: w,
                          child: Text('Week $w'),
                        ),
                      )
                      .toList(),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedWeek = val;
                    fetchData();
                  });
                },
              ),
            ],
          ),
        ),
        // Period label
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            _currentPeriodLabel,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        // PieChart + legend
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _buildPieChartWithLegend(_data),
        ),
      ],
    );
  }

  Widget _buildPieChartWithLegend(Map<String, double> data) {
    if (data.isEmpty) return const Center(child: Text('No expenses yet'));

    final colors = List.generate(
      data.length,
      (i) => Colors.primaries[i % Colors.primaries.length].withOpacity(0.8),
    );

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: data.entries
                  .toList()
                  .asMap()
                  .entries
                  .map(
                    (entry) => PieChartSectionData(
                      color: colors[entry.key],
                      value: entry.value.value,
                      radius: 80, // bigger radius
                      showTitle: true,
                      title: entry.value.value.toStringAsFixed(0),
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                  .toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 50,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: data.entries
              .toList()
              .asMap()
              .entries
              .map(
                (entry) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 16, height: 16, color: colors[entry.key]),
                    const SizedBox(width: 4),
                    Text('${entry.value.key}'),
                  ],
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
