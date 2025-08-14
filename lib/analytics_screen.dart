import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models/expense.dart';
import 'dart:collection';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () => Provider.of<ThemeProvider>(
              context,
              listen: false,
            ).toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile/Settings',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Profile'),
                  content: Text('Email: ${user.email ?? "-"}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await FirebaseAuth.instance.signOut();
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('expenses')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/empty.png', height: 120),
                const SizedBox(height: 16),
                const Text(
                  'No expenses yet.',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            );
          }
          final expenses = snapshot.data!.docs
              .map(
                (doc) =>
                    Expense.fromMap(doc.id, doc.data() as Map<String, dynamic>),
              )
              .toList();

          // Summary calculations
          final totalSpent = expenses.fold(0.0, (total, e) => total + e.amount);
          final categoryCounts = <String, int>{};
          for (var e in expenses) {
            categoryCounts[e.category] = (categoryCounts[e.category] ?? 0) + 1;
          }
          final mostFrequentCategory = categoryCounts.isNotEmpty
              ? categoryCounts.entries
                    .reduce((a, b) => a.value > b.value ? a : b)
                    .key
              : '-';
          final highestExpense = expenses.isNotEmpty
              ? expenses.reduce((a, b) => a.amount > b.amount ? a : b)
              : null;

          // Pie chart data: total by category
          final Map<String, double> categoryTotals = {};
          for (var e in expenses) {
            categoryTotals[e.category] =
                (categoryTotals[e.category] ?? 0) + e.amount;
          }

          // Bar chart data: total by day (last 7 days)
          final Map<String, double> dayTotals = SplayTreeMap();
          final now = DateTime.now();
          for (int i = 6; i >= 0; i--) {
            final day = DateTime(now.year, now.month, now.day - i);
            final key = '${day.month}/${day.day}';
            dayTotals[key] = 0;
          }
          for (var e in expenses) {
            final key = '${e.date.month}/${e.date.day}';
            if (dayTotals.containsKey(key)) {
              dayTotals[key] = dayTotals[key]! + e.amount;
            }
          }

          // Line chart data: last 30 days
          final Map<String, double> lineTotals = SplayTreeMap();
          for (int i = 29; i >= 0; i--) {
            final day = DateTime(now.year, now.month, now.day - i);
            final key = '${day.month}/${day.day}';
            lineTotals[key] = 0;
          }
          for (var e in expenses) {
            final key = '${e.date.month}/${e.date.day}';
            if (lineTotals.containsKey(key)) {
              lineTotals[key] = lineTotals[key]! + e.amount;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Summary cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SummaryCard(
                      label: 'Total Spent',
                      value: '₹${totalSpent.toStringAsFixed(2)}',
                      color: Colors.deepPurple,
                      icon: Icons.account_balance_wallet_rounded,
                    ),
                    _SummaryCard(
                      label: 'Top Category',
                      value: mostFrequentCategory,
                      color: Colors.orange,
                      icon: Icons.category,
                    ),
                    _SummaryCard(
                      label: 'Highest',
                      value: highestExpense != null
                          ? '₹${highestExpense.amount.toStringAsFixed(2)}'
                          : '-',
                      color: Colors.red,
                      icon: Icons.trending_up,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Expenses by Category',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sections: categoryTotals.entries.map((e) {
                        final color =
                            Colors.primaries[categoryTotals.keys
                                    .toList()
                                    .indexOf(e.key) %
                                Colors.primaries.length];
                        return PieChartSectionData(
                          color: color,
                          value: e.value,
                          title: '${e.key}\n₹${e.value.toStringAsFixed(0)}',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Expenses by Day (last 7 days)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY:
                          (dayTotals.values.isNotEmpty
                              ? dayTotals.values.reduce((a, b) => a > b ? a : b)
                              : 100) +
                          10,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= dayTotals.keys.length) {
                                return const SizedBox();
                              }
                              return Text(dayTotals.keys.elementAt(idx));
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        for (int i = 0; i < dayTotals.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: dayTotals.values.elementAt(i),
                                color: Colors.deepPurple,
                                width: 18,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Spending Trend (last 30 days)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY:
                          (lineTotals.values.isNotEmpty
                              ? lineTotals.values.reduce(
                                  (a, b) => a > b ? a : b,
                                )
                              : 100) +
                          10,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= lineTotals.keys.length) {
                                return const SizedBox();
                              }
                              return Text(
                                lineTotals.keys.elementAt(idx),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (int i = 0; i < lineTotals.length; i++)
                              FlSpot(
                                i.toDouble(),
                                lineTotals.values.elementAt(i),
                              ),
                          ],
                          isCurved: true,
                          color: Colors.deepPurple,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withAlpha(26),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
