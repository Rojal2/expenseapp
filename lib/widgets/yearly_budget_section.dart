import 'package:flutter/material.dart';
import 'package:expenseapp/models/budget.dart';

class YearlyBudgetSection extends StatelessWidget {
  final TextEditingController budgetController;
  final VoidCallback onSetBudget;
  final Budget? budget;
  final double suggestedBudget;

  const YearlyBudgetSection({
    super.key,
    required this.budgetController,
    required this.onSetBudget,
    required this.budget,
    required this.suggestedBudget,
  });

  @override
  Widget build(BuildContext context) {
    return _buildCard(
      icon: Icons.savings,
      title: 'Yearly Budget',
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: budgetController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _buildInputDecoration(
                    'Yearly Budget',
                    Icons.calendar_today,
                    context,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: onSetBudget,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                style: _buildButtonStyle(context),
              ),
            ],
          ),
          if (budget != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Current Yearly Budget: ₹${budget!.yearlyBudget}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          if (suggestedBudget > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Suggested Budget: ₹${suggestedBudget.toStringAsFixed(2)}',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
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

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon,
    BuildContext context,
  ) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIcon: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
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
