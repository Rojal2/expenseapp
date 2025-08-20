import 'package:expenseapp/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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

    final total = categoryData.values.fold(0.0, (a, b) => a + b);

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
          children: categoryData.keys.map((cat) {
            final color = _colorForCategory(cat);
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
                Text(cat, style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  List<PieChartSectionData> _getSections(double total) {
    return categoryData.entries.map((entry) {
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
        color: _colorForCategory(entry.key),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      );
    }).toList();
  }

  Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'shopping':
        return Colors.redAccent;
      case 'entertainment':
        return Colors.pinkAccent;
      case 'bills':
        return Colors.deepPurple;
      case 'food':
        return Colors.blueAccent;
      case 'transport':
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }
}
