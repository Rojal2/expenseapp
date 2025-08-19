import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/financial_goal.dart';
import '../services/financial_goal_service.dart';

class FinancialGoalWidget extends StatelessWidget {
  final FinancialGoalService financialGoalService;

  const FinancialGoalWidget({super.key, required this.financialGoalService});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = now.month;
    final year = now.year;

    return StreamBuilder<FinancialGoal?>(
      stream: financialGoalService.getGoalForMonth(month, year),
      builder: (context, snapshot) {
        final goal = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Financial Goals - ${DateFormat.MMMM().format(DateTime(year, month))} $year",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 16),
                if (goal != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGoalRow(
                        "Income Goal",
                        goal.incomeGoal,
                        Colors.green,
                      ),
                      _buildGoalRow(
                        "Expense Goal",
                        goal.expenseGoal,
                        Colors.red,
                      ),
                      _buildGoalRow(
                        "Saving Goal",
                        goal.savingGoal,
                        Colors.blue,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text("Edit"),
                            onPressed: () async {
                              await _showGoalDialog(context, goal);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text("Delete"),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Delete Goal"),
                                  content: const Text(
                                    "Are you sure you want to delete this financial goal?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await financialGoalService.deleteFinancialGoal(
                                  goal,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _showGoalDialog(context, null);
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Set Financial Goals for this month"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalRow(String title, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$title:",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showGoalDialog(
    BuildContext context,
    FinancialGoal? goal,
  ) async {
    final incomeController = TextEditingController(
      text: goal?.incomeGoal.toString() ?? '',
    );
    final expenseController = TextEditingController(
      text: goal?.expenseGoal.toString() ?? '',
    );
    final savingController = TextEditingController(
      text: goal?.savingGoal.toString() ?? '',
    );

    final now = DateTime.now();
    final month = now.month;
    final year = now.year;

    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          goal == null ? "Set Financial Goals" : "Edit Financial Goals",
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: incomeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter income goal",
                prefixIcon: Icon(Icons.arrow_upward, color: Colors.green),
              ),
            ),
            TextField(
              controller: expenseController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter expense goal",
                prefixIcon: Icon(Icons.arrow_downward, color: Colors.red),
              ),
            ),
            TextField(
              controller: savingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter saving goal",
                prefixIcon: Icon(Icons.savings, color: Colors.blue),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final income = double.tryParse(incomeController.text) ?? 0;
              final expense = double.tryParse(expenseController.text) ?? 0;
              final saving = double.tryParse(savingController.text) ?? 0;
              Navigator.pop(ctx, {
                'income': income,
                'expense': expense,
                'saving': saving,
              });
            },
            child: Text(goal == null ? "Set" : "Update"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      await financialGoalService.setFinancialGoal(
        FinancialGoal(
          id: goal?.id ?? '',
          incomeGoal: result['income'] ?? 0,
          expenseGoal: result['expense'] ?? 0,
          savingGoal: result['saving'] ?? 0,
          month: month,
          year: year,
        ),
      );
    }
  }
}
