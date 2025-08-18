import 'package:flutter/material.dart';
import '../../services/analytics_service.dart';

class ComparisonChartWidget extends StatefulWidget {
  const ComparisonChartWidget({super.key});

  @override
  State<ComparisonChartWidget> createState() => _ComparisonChartWidgetState();
}

class _ComparisonChartWidgetState extends State<ComparisonChartWidget> {
  final AnalyticsService _service = AnalyticsService();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Comparison Chart: Weekly expense vs Irregular & Monthly Income',
      ),
    );
  }
}
