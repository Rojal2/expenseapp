import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/analytics_service.dart'; // Add this import

class IncomeChartWidget extends StatefulWidget {
  const IncomeChartWidget({super.key});

  @override
  State<IncomeChartWidget> createState() => _IncomeChartWidgetState();
}

class _IncomeChartWidgetState extends State<IncomeChartWidget> {
  Map<int, double> monthlyIncome = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final service = AnalyticsService();
    final data = await service.getMonthlyIncome();
    setState(() {
      monthlyIncome = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    final months = List.generate(12, (index) => index + 1);
    final maxY = monthlyIncome.values.isEmpty
        ? 0.0
        : monthlyIncome.values.reduce((a, b) => a > b ? a : b);

    return AspectRatio(
      aspectRatio: 1.4,
      child: BarChart(
        BarChartData(
          maxY: maxY + 50,
          barGroups: months
              .map(
                (month) => BarChartGroupData(
                  x: month,
                  barRods: [
                    BarChartRodData(
                      toY: monthlyIncome[month] ?? 0,
                      color: Colors.green,
                      width: 18,
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
                  return Text(
                    value.toInt().toString(),
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
