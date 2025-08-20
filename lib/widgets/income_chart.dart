import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/analytics_service.dart';

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

    final total = monthlyIncome.values.fold(0.0, (a, b) => a + b);

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 60,
              startDegreeOffset: -90,
              borderData: FlBorderData(show: false),
              sections: _getSections(total),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 6,
          children: monthlyIncome.keys.map((month) {
            final color = _colorForMonth(month);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Text('M$month', style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  List<PieChartSectionData> _getSections(double total) {
    return monthlyIncome.entries.map((entry) {
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      return PieChartSectionData(
        value: entry.value,
        title: '$percentage%',
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        color: _colorForMonth(entry.key),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      );
    }).toList();
  }

  Color _colorForMonth(int month) {
    final colors = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.yellow.shade700,
      Colors.greenAccent,
      Colors.teal,
      Colors.blueAccent,
      Colors.indigo,
      Colors.purple,
      Colors.pinkAccent,
      Colors.cyan,
      Colors.lime,
      Colors.brown,
    ];
    return colors[(month - 1) % colors.length];
  }
}
