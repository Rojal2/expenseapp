import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/analytics_service.dart';

class ComparisonChartWidget extends StatefulWidget {
  const ComparisonChartWidget({super.key});

  @override
  State<ComparisonChartWidget> createState() => _ComparisonChartWidgetState();
}

class _ComparisonChartWidgetState extends State<ComparisonChartWidget> {
  Map<int, Map<String, double>> weeklyData = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final service = AnalyticsService();
    final comparison = await service.getComparison();
    setState(() {
      weeklyData = Map<int, Map<String, double>>.from(
        comparison['weeklyComparison'] ?? {},
      );
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    final weeks = weeklyData.keys.toList()..sort();
    final maxY = weeklyData.values
        .map((e) => e.values.reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);

    return AspectRatio(
      aspectRatio: 1.6,
      child: BarChart(
        BarChartData(
          maxY: maxY + 50,
          barGroups: weeks
              .map(
                (week) => BarChartGroupData(
                  x: week,
                  barsSpace: 4,
                  barRods: [
                    BarChartRodData(
                      toY: weeklyData[week]!['expense']!,
                      color: Colors.red,
                      width: 10,
                    ),
                    BarChartRodData(
                      toY: weeklyData[week]!['coveredByIrregular']!,
                      color: Colors.orange,
                      width: 10,
                    ),
                    BarChartRodData(
                      toY: weeklyData[week]!['coveredByMonthly']!,
                      color: Colors.green,
                      width: 10,
                    ),
                  ],
                ),
              )
              .toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    'W${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
          ),
        ),
      ),
    );
  }
}
