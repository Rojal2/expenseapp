import 'package:expenseapp/screens/add_budget.dart';
import 'package:flutter/material.dart';
import '../models/budget_estimation.dart';
import '../services/budget_service.dart';
import 'add_budget.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                DropdownButton<int>(
                  value: selectedMonth,
                  items: List.generate(12, (i) {
                    return DropdownMenuItem(
                      value: i + 1,
                      child: Text('${i + 1}'),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedMonth = val);
                  },
                ),
                const SizedBox(width: 20),
                DropdownButton<int>(
                  value: selectedYear,
                  items: List.generate(5, (i) => DateTime.now().year - 2 + i)
                      .map(
                        (yr) => DropdownMenuItem(value: yr, child: Text('$yr')),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedYear = val);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Budget>>(
              stream: BudgetService().getBudgetsForMonth(
                selectedMonth,
                selectedYear,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No budgets yet.'));
                }

                final budgets = snapshot.data!;
                return ListView.builder(
                  itemCount: budgets.length,
                  itemBuilder: (context, i) {
                    final budget = budgets[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: Text(
                          '${budget.category} - ₹${budget.estimatedAmount.toStringAsFixed(0)}',
                        ),
                        subtitle: Text(
                          'Month: ${budget.month}, Year: ${budget.year}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AddBudgetScreen(budget: budget),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Budget'),
                                    content: const Text(
                                      'Are you sure you want to delete this budget?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await BudgetService().deleteBudget(budget.id);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
