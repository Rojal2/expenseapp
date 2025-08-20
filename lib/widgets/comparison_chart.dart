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

    // Combine totals across all weeks
    double totalExpense = 0, totalIncome = 0;
    for (final week in weeklyData.values) {
      totalExpense += week['expense'] ?? 0;
      totalIncome +=
          (week['coveredByIrregular'] ?? 0) + (week['coveredByMonthly'] ?? 0);
    }

    final total = totalExpense + totalIncome;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 60,
              startDegreeOffset: -90,
              borderData: FlBorderData(show: false),
              sections: [
                PieChartSectionData(
                  value: totalExpense,
                  title: '${(totalExpense / total * 100).toStringAsFixed(1)}%',
                  color: Colors.redAccent,
                  radius: 70,
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: totalIncome,
                  title: '${(totalIncome / total * 100).toStringAsFixed(1)}%',
                  color: Colors.greenAccent,
                  radius: 70,
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendDot(Colors.redAccent, "Expenses"),
            const SizedBox(width: 16),
            _legendDot(Colors.greenAccent, "Income"),
          ],
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
