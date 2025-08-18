import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../services/analytics_service.dart';

class ExpenseChartWidget extends StatefulWidget {
  const ExpenseChartWidget({super.key});

  @override
  State<ExpenseChartWidget> createState() => _ExpenseChartWidgetState();
}

class _ExpenseChartWidgetState extends State<ExpenseChartWidget> {
  Map<String, double> categoryData = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final service = AnalyticsService();
    final data = await service.getExpenseByCategory();
    setState(() {
      categoryData = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    final categories = categoryData.keys.toList();
    final maxAmount = categoryData.values.isEmpty
        ? 0.0
        : categoryData.values.reduce((a, b) => a > b ? a : b);

    return AspectRatio(
      aspectRatio: 1.4,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxAmount + 50,
          barGroups: categories
              .asMap()
              .entries
              .map(
                (entry) => BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: categoryData[entry.value]!,
                      width: 18,
                      color: Colors.redAccent,
                    ),
                  ],
                  showingTooltipIndicators: [0],
                ),
              )
              .toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < categories.length) {
                    return Text(
                      categories[index],
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
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
