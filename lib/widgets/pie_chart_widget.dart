import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> dataMap; // e.g. {'Food': 40, 'Transport': 30}

  const ExpensePieChart({super.key, required this.dataMap});

  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> sections = dataMap.entries.map((entry) {
      final color = entry.key == 'Food'
          ? Colors.deepPurple
          : entry.key == 'Transport'
          ? Colors.purpleAccent
          : Colors.blueAccent;
      return PieChartSectionData(
        value: entry.value,
        color: color,
        title: entry.key,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Expense Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
                swapAnimationDuration: const Duration(milliseconds: 800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
