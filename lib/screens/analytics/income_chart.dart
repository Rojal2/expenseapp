import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/income_entry.dart';
import '../../services/income_service.dart';

class IncomeChart extends StatefulWidget {
  const IncomeChart({super.key});

  @override
  State<IncomeChart> createState() => _IncomeChartState();
}

class _IncomeChartState extends State<IncomeChart> {
  final IncomeService _incomeService = IncomeService();

  List<IncomeEntry> _entries = [];
  bool _loading = true;

  String _selectedPeriod = 'month';
  int? _selectedYear;
  int? _selectedMonth;
  int? _selectedWeek;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    DateTime? start;
    DateTime? end;

    final now = DateTime.now();

    if (_selectedYear != null) {
      start = DateTime(_selectedYear!);
      end = DateTime(_selectedYear!, 12, 31, 23, 59, 59);
    }

    if (_selectedMonth != null) {
      start = DateTime(_selectedYear ?? now.year, _selectedMonth!);
      end = DateTime(
        _selectedYear ?? now.year,
        _selectedMonth!,
        31,
        23,
        59,
        59,
      );
    }

    if (_selectedWeek != null && start != null) {
      final weekStart = start.add(Duration(days: (_selectedWeek! - 1) * 7));
      final weekEnd = weekStart.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );
      start = weekStart;
      end = weekEnd;
    }

    var incomes = await _incomeService.getIncomes(
      startDate: start,
      endDate: end,
    );

    setState(() {
      _entries = incomes;
      _loading = false;
    });
  }

  Map<String, double> _groupEntries() {
    final Map<String, double> grouped = {};
    for (var e in _entries) {
      String key;
      if (_selectedPeriod == 'month') {
        key = "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}";
      } else if (_selectedPeriod == 'week') {
        final week = ((e.date.day - 1) ~/ 7) + 1;
        key = "Week $week";
      } else {
        key = e.date.year.toString();
      }
      grouped[key] = (grouped[key] ?? 0) + e.amount;
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_entries.isEmpty) return const Center(child: Text('No income yet'));

    final data = _groupEntries();

    return Column(
      children: [
        // Filters
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DropdownButton<String>(
              value: _selectedPeriod,
              items: [
                'month',
                'week',
                'year',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                setState(() {
                  _selectedPeriod = v!;
                  _selectedWeek = null;
                  _selectedMonth = null;
                  fetchData();
                });
              },
            ),
            DropdownButton<int>(
              hint: const Text('Year'),
              value: _selectedYear,
              items: List.generate(5, (i) => DateTime.now().year - i)
                  .map(
                    (y) =>
                        DropdownMenuItem(value: y, child: Text(y.toString())),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _selectedYear = v;
                  _selectedMonth = null;
                  _selectedWeek = null;
                  fetchData();
                });
              },
            ),
            if (_selectedPeriod != 'year')
              DropdownButton<int>(
                hint: const Text('Month'),
                value: _selectedMonth,
                items: List.generate(12, (i) => i + 1)
                    .map(
                      (m) =>
                          DropdownMenuItem(value: m, child: Text(m.toString())),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedMonth = v;
                    _selectedWeek = null;
                    fetchData();
                  });
                },
              ),
            if (_selectedPeriod == 'week' && _selectedMonth != null)
              DropdownButton<int>(
                hint: const Text('Week'),
                value: _selectedWeek,
                items: List.generate(4, (i) => i + 1)
                    .map((w) => DropdownMenuItem(value: w, child: Text('W$w')))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedWeek = v;
                    fetchData();
                  });
                },
              ),
          ],
        ),

        // Pie chart
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: PieChart(
              PieChartData(
                sections: data.entries.map((e) {
                  final color =
                      Colors.primaries[data.keys.toList().indexOf(e.key) %
                          Colors.primaries.length];
                  return PieChartSectionData(
                    color: color,
                    value: e.value,
                    title: e.value.toStringAsFixed(0),
                    radius: 70,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
