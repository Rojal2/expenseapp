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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // fetch all incomes from Firestore
    var incomes = await _incomeService.getAllIncomes();

    setState(() {
      _entries = incomes;
      _loading = false;
    });
  }

  // Helper: group incomes by month (you can also group by year or category later)
  Map<String, double> _groupByMonth(List<IncomeEntry> entries) {
    final Map<String, double> grouped = {};
    for (var e in entries) {
      final monthKey =
          "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}";
      grouped[monthKey] = (grouped[monthKey] ?? 0) + e.amount;
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_entries.isEmpty) return const Center(child: Text('No income yet'));

    final data = _groupByMonth(_entries);

    return Padding(
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
              title: '${e.key}\n${e.value.toStringAsFixed(0)}',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
