import 'package:flutter/material.dart';
import 'package:expenseapp/models/budget.dart';

class BudgetProgressSection extends StatelessWidget {
  final Map<String, double> monthlyExpenses;
  final Budget? budget;
  final List<String> months;

  const BudgetProgressSection({
    super.key,
    required this.monthlyExpenses,
    required this.budget,
    required this.months,
  });

  @override
  Widget build(BuildContext context) {
    return _buildCard(
      icon: Icons.show_chart,
      title: 'Budget Progress',
      context: context,
      child: GridView.builder(
        // Keep shrinkWrap true as it's likely inside a Column/SingleChildScrollView
        shrinkWrap: true,
        // *** This line was removed to allow internal GridView scrolling. ***
        // *** IMPORTANT: Ensure the PARENT of this BudgetProgressSection (e.g., the main screen's body) is also scrollable. ***
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 12,
        itemBuilder: (context, index) =>
            _buildBudgetProgressItem(context, index),
      ),
    );
  }

  Widget _buildBudgetProgressItem(BuildContext context, int index) {
    final key = (index + 1).toString().padLeft(2, '0');
    final spent = monthlyExpenses[key] ?? 0;
    final budgetAmount = budget?.monthlyBudgets[key] ?? 0;
    final percent = budgetAmount > 0
        ? (spent / budgetAmount).clamp(0.0, 1.0)
        : 0.0;
    final isCurrentMonth = DateTime.now().month == index + 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: isCurrentMonth
            ? LinearGradient(
                colors: [
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.1),
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.05),
                ],
              )
            : null,
        border: Border.all(
          color: isCurrentMonth
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).dividerColor,
          width: isCurrentMonth ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isCurrentMonth
            ? [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            months[index],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Theme.of(context).colorScheme.surface.withValues(
                alpha: 0.5,
              ), // Corrected: Use withOpacity instead of withValues
              color: percent < 1.0
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.red,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₹${spent.toStringAsFixed(0)} / ₹${budgetAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${(percent * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
    required BuildContext context,
  }) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).dividerColor, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 28),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.onSurface),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
