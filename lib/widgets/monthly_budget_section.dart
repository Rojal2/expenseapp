import 'package:flutter/material.dart';

class MonthlyBudgetSection extends StatelessWidget {
  final Map<String, TextEditingController> monthlyControllers;
  final VoidCallback onSaveMonthlyBudgets;
  final List<String> months;

  const MonthlyBudgetSection({
    super.key,
    required this.monthlyControllers,
    required this.onSaveMonthlyBudgets,
    required this.months,
  });

  @override
  Widget build(BuildContext context) {
    return _buildCard(
      icon: Icons.calendar_view_month,
      title: 'Monthly Budgets',
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) =>
                _buildMonthlyBudgetItem(context, index),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onSaveMonthlyBudgets,
              icon: const Icon(Icons.save),
              label: const Text('Save Monthly Budgets'),
              style: _buildButtonStyle(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBudgetItem(BuildContext context, int index) {
    final key = (index + 1).toString().padLeft(2, '0');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          months[index],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: monthlyControllers[key],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Budget',
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(
              Icons.currency_rupee,
              size: 18,
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ),
      ],
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

  ButtonStyle _buildButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      foregroundColor: Theme.of(context).colorScheme.onSecondary,
      shape: const StadiumBorder(),
    );
  }
}
