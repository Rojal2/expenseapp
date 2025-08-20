import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/income_service.dart';
import 'package:intl/intl.dart';

class IncomeChart extends StatefulWidget {
  const IncomeChart({super.key});

  @override
  State<IncomeChart> createState() => _IncomeChartState();
}

class _IncomeChartState extends State<IncomeChart> {
  final IncomeService _incomeService = IncomeService();
  Map<String, double> _data = {};
  bool _loading = true;

  // Dropdown selections
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;
  int? _selectedWeek;

  String _currentPeriodLabel = '';

  List<int> get yearOptions {
    int currentYear = DateTime.now().year;
    return List.generate(5, (i) => currentYear - i);
  }

  List<int> get monthOptions {
    if (_selectedYear == DateTime.now().year) {
      return List.generate(DateTime.now().month, (i) => i + 1);
    } else {
      return List.generate(12, (i) => i + 1);
    }
  }

  List<int> get weekOptions {
    if (_selectedMonth == null) return [];
    int totalWeeks = 4;
    DateTime now = DateTime.now();
    if (_selectedYear == now.year && _selectedMonth == now.month) {
      int currentWeek = ((now.day - 1) / 7).ceil() + 1;
      if (currentWeek < 4) totalWeeks = currentWeek;
    }
    return List.generate(totalWeeks, (i) => i + 1);
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => _loading = true);

    DateTime startDate;
    DateTime endDate;
    DateTime now = DateTime.now();

    if (_selectedMonth == null) {
      startDate = DateTime(_selectedYear, 1, 1);
      endDate = DateTime(_selectedYear, 12, 31);
      if (endDate.isAfter(now)) endDate = now;
      _currentPeriodLabel = 'Year $_selectedYear';
    } else if (_selectedWeek == null) {
      startDate = DateTime(_selectedYear, _selectedMonth!, 1);
      endDate = DateTime(_selectedYear, _selectedMonth! + 1, 0);
      if (endDate.isAfter(now)) endDate = now;
      _currentPeriodLabel =
          '${DateFormat.MMMM().format(startDate)} $_selectedYear';
    } else {
      startDate = DateTime(
        _selectedYear,
        _selectedMonth!,
        1,
      ).add(Duration(days: (_selectedWeek! - 1) * 7));
      endDate = startDate.add(const Duration(days: 6));
      if (endDate.isAfter(now)) endDate = now;
      _currentPeriodLabel =
          'Week $_selectedWeek: ${DateFormat('MMM dd').format(startDate)} – ${DateFormat('MMM dd').format(endDate)}';
    }

    Map<String, double> data = await _incomeService
        .getIncomeBreakdownByCategory(startDate: startDate, endDate: endDate);

    setState(() {
      _data = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filters
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDropdown<int>(
                value: _selectedYear,
                items: yearOptions
                    .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedYear = val;
                      _selectedMonth = null;
                      _selectedWeek = null;
                      fetchData();
                    });
                  }
                },
              ),
              _buildDropdown<int?>(
                hint: const Text('Month'),
                value: _selectedMonth,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Months'),
                  ),
                  ...monthOptions
                      .map(
                        (m) => DropdownMenuItem<int?>(
                          value: m,
                          child: Text(DateFormat.MMMM().format(DateTime(0, m))),
                        ),
                      )
                      .toList(),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedMonth = val;
                    _selectedWeek = null;
                    fetchData();
                  });
                },
              ),
              _buildDropdown<int?>(
                hint: const Text('Week'),
                value: _selectedWeek,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Weeks'),
                  ),
                  ...weekOptions
                      .map(
                        (w) => DropdownMenuItem<int?>(
                          value: w,
                          child: Text('Week $w'),
                        ),
                      )
                      .toList(),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedWeek = val;
                    fetchData();
                  });
                },
              ),
            ],
          ),
        ),

        // Current period label
        if (_currentPeriodLabel.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              _currentPeriodLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey,
              ),
            ),
          ),

        // Chart & Legends & Total Income
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // Pie chart
                        AspectRatio(
                          aspectRatio: 1.2,
                          child: PieChart(
                            PieChartData(
                              sections: _data.entries
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    final key = entry.value.key;
                                    final value = entry.value.value;
                                    final total = _data.values.fold(
                                      0.0,
                                      (sum, v) => sum + v,
                                    );
                                    final percentage = total > 0
                                        ? (value / total) * 100
                                        : 0.0;

                                    return PieChartSectionData(
                                      color: Colors
                                          .primaries[entry.key %
                                              Colors.primaries.length]
                                          .withOpacity(0.8),
                                      value: value,
                                      radius: 100,
                                      title:
                                          '${percentage.toStringAsFixed(1)}%',
                                      titleStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  })
                                  .toList(),
                              sectionsSpace: 3,
                              centerSpaceRadius: 50,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

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
                            final percentage = total > 0
                                ? (value / total) * 100
                                : 0.0;
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
                              const Icon(
                                Icons.attach_money,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Total Income: \$${_data.values.fold(0.0, (sum, v) => sum + v).toStringAsFixed(2)}',
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

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    Widget? hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          hint: hint,
          style: const TextStyle(color: Colors.blueGrey, fontSize: 16),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
          dropdownColor: Colors.white,
        ),
      ),
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
