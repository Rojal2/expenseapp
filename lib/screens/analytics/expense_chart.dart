import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/expense_service.dart';
import 'package:intl/intl.dart';

class ExpenseChart extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String periodLabel;

  const ExpenseChart({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.periodLabel,
  });

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  final ExpenseService _expenseService = ExpenseService();
  Map<String, double> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void didUpdateWidget(covariant ExpenseChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startDate != oldWidget.startDate ||
        widget.endDate != oldWidget.endDate) {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    setState(() {
      _loading = true;
    });

    Map<String, double> data = await _expenseService.getExpensesByDateRange(
      startDate: widget.startDate,
      endDate: widget.endDate,
    );

    setState(() {
      _data = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.periodLabel.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              widget.periodLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 1.2,
                          child: PieChart(
                            PieChartData(
                              sections: _data.entries
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    final value = entry.value.value;
                                    final total = _data.values.fold(
                                      0.0,
                                      (sum, v) => sum + v,
                                    );
                                    final percentage = total == 0
                                        ? 0
                                        : (value / total) * 100;
                                    final color = Colors
                                        .primaries[entry.key %
                                            Colors.primaries.length]
                                        .withOpacity(0.8);
                                    return PieChartSectionData(
                                      color: color,
                                      value: value,
                                      radius: 100,
                                      title:
                                          '${percentage.toStringAsFixed(1)}%',
                                      titleStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                      titlePositionPercentageOffset: 0.55,
                                    );
                                  })
                                  .toList(),
                              sectionsSpace: 3,
                              centerSpaceRadius: 60,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Legends
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _data.entries.toList().asMap().entries.map((
                            entry,
                          ) {
                            final key = entry.value.key;
                            final value = entry.value.value;
                            final total = _data.values.fold(
                              0.0,
                              (sum, v) => sum + v,
                            );
                            final percentage = total == 0
                                ? 0
                                : (value / total) * 100;
                            final color = Colors
                                .primaries[entry.key % Colors.primaries.length]
                                .withOpacity(0.8);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: _buildLegendItem(
                                color: color,
                                text:
                                    '$key: \$${value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        // Total
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
                              const Icon(
                                Icons.attach_money,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Total Expenses: \$${_data.values.fold(0.0, (sum, v) => sum + v).toStringAsFixed(2)}',
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
                ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
