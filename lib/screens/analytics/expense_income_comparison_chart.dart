import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/finance_service.dart';

class ExpenseIncomeComparisonChart extends StatefulWidget {
  const ExpenseIncomeComparisonChart({super.key});

  @override
  State<ExpenseIncomeComparisonChart> createState() =>
      _ExpenseIncomeComparisonChartState();
}

class _ExpenseIncomeComparisonChartState
    extends State<ExpenseIncomeComparisonChart> {
  final FinanceService _financeService = FinanceService();
  Map<String, Map<String, double>> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var data = await _financeService.getIncomeVsExpense(period: 'month');
    setState(() {
      _data = Map.fromEntries(_sortKeys(data));
      _loading = false;
    });
  }

  Iterable<MapEntry<String, Map<String, double>>> _sortKeys(
    Map<String, Map<String, double>> map,
  ) {
    List<MapEntry<String, Map<String, double>>> entries = map.entries.toList();
    entries.sort((a, b) {
      List<int> aParts = a.key.split('/').map(int.parse).toList();
      List<int> bParts = b.key.split('/').map(int.parse).toList();
      DateTime aDate = DateTime(DateTime.now().year, aParts[1], aParts[0]);
      DateTime bDate = DateTime(DateTime.now().year, bParts[1], bParts[0]);
      return aDate.compareTo(bDate);
    });
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_data.isEmpty)
      return const Center(child: Text('No data for comparison'));

    final keys = _data.keys.toList();
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(),
          barGroups: keys.asMap().entries.map((entry) {
            final index = entry.key;
            final key = entry.value;
            final values = _data[key]!;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values['expense']!,
                  color: Colors.red,
                  width: 8,
                ),
                BarChartRodData(
                  toY: values['income']!,
                  color: Colors.green,
                  width: 8,
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= keys.length)
                    return const SizedBox();
                  return Text(
                    keys[index],
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          ),
        ),
      ),
    );
  }

  double _getMaxY() {
    double max = 0;
    _data.forEach((key, value) {
      max = [
        max,
        value['expense']!,
        value['income']!,
      ].reduce((a, b) => a > b ? a : b);
    });
    return max * 1.2; // padding above max
  }
}
