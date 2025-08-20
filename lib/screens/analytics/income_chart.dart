import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/income_service.dart';
import 'package:intl/intl.dart';

class IncomeChart extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String periodLabel;

  const IncomeChart({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.periodLabel,
  });

  @override
  State<IncomeChart> createState() => _IncomeChartState();
}

class _IncomeChartState extends State<IncomeChart> {
  final IncomeService _incomeService = IncomeService();
  late Future<Map<String, double>> _futureData;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(covariant IncomeChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      _fetchData();
    }
  }

  void _fetchData() {
    _futureData = _incomeService.getIncomeBreakdownByCategory(
      startDate: widget.startDate,
      endDate: widget.endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: _futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No income data available for this period.'),
          );
        }

        final data = snapshot.data!;
        final total = data.values.fold(0.0, (sum, v) => sum + v);

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Period label
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    widget.periodLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                // Pie chart
                AspectRatio(
                  aspectRatio: 1.2,
                  child: PieChart(
                    PieChartData(
                      sections: data.entries.toList().asMap().entries.map((
                        entry,
                      ) {
                        final key = entry.value.key;
                        final value = entry.value.value;
                        final percentage = total > 0
                            ? (value / total) * 100
                            : 0.0;

                        return PieChartSectionData(
                          color: Colors
                              .primaries[entry.key % Colors.primaries.length]
                              .withOpacity(0.8),
                          value: value,
                          radius: 100,
                          title: '${percentage.toStringAsFixed(1)}%',
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 3,
                      centerSpaceRadius: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Legends
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.entries.toList().asMap().entries.map((entry) {
                    final key = entry.value.key;
                    final value = entry.value.value;
                    final percentage = total > 0 ? (value / total) * 100 : 0.0;
                    final color = Colors
                        .primaries[entry.key % Colors.primaries.length]
                        .withOpacity(0.8);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: _buildLegendItem(
                        color: color,
                        text:
                            '$key: \$${value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Total Income
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.attach_money, color: Colors.blueGrey),
                      const SizedBox(width: 8),
                      Text(
                        'Total Income: \$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
