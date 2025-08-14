import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../providers/expense_provider.dart';

class BudgetSummary extends StatefulWidget {
  const BudgetSummary({super.key});

  @override
  State<BudgetSummary> createState() => _BudgetSummaryState();
}

class _BudgetSummaryState extends State<BudgetSummary> {
  final TextEditingController _incomeController = TextEditingController();
  bool _alertShown = false;

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final monthlyIncome = budgetProvider.monthlyIncome;
    final totalExpenses = expenseProvider.totalExpenses;
    final savings = monthlyIncome - totalExpenses;

    if (savings < 0 && !_alertShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alert: You have exceeded your monthly budget!'),
            backgroundColor: Colors.red,
          ),
        );
        _alertShown = true;
      });
    } else if (savings >= 0 && _alertShown) {
      _alertShown = false;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Monthly Income: \$${monthlyIncome.toStringAsFixed(2)}'),
            TextField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Set Monthly Income',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(_incomeController.text);
                if (value != null) {
                  budgetProvider.setIncome(value);
                  _incomeController.clear();
                }
              },
              child: const Text('Save Income'),
            ),
            const SizedBox(height: 16),
            Text('Total Expenses: \$${totalExpenses.toStringAsFixed(2)}'),
            Text(
              'Savings: \$${savings.toStringAsFixed(2)}',
              style: TextStyle(
                color: savings < 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
