import 'package:expenseapp/screens/add_budget.dart';
import 'package:flutter/material.dart';
import '../models/budget_estimation.dart';
import '../services/budget_service.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  int? selectedMonth = DateTime.now().month; // null = All months
  int selectedYear = DateTime.now().year;

  final List<String> monthNames = const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Filters Row with enhanced styling
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        decoration: const InputDecoration(
                          labelText: 'Month',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        value: selectedMonth,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All', style: TextStyle(fontSize: 16)),
                          ),
                          ...List.generate(12, (i) {
                            return DropdownMenuItem(
                              value: i + 1,
                              child: Text(
                                monthNames[i],
                                style: const TextStyle(
                                  fontSize: 16,
                                ), // Style added
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) => setState(() => selectedMonth = val),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        value: selectedYear,
                        items:
                            List.generate(5, (i) => DateTime.now().year - 4 + i)
                                .map(
                                  (yr) => DropdownMenuItem(
                                    value: yr,
                                    child: Text(
                                      '$yr',
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ), // Style added
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedYear = val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Budget List + Total
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
                  final totalBudget = budgets.fold<double>(
                    0,
                    (sum, b) => sum + b.estimatedAmount,
                  );

                  return Column(
                    children: [
                      // Total Budget
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Total Budget: ₹${totalBudget.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Budget List
                      Expanded(
                        child: ListView.builder(
                          itemCount: budgets.length,
                          itemBuilder: (context, i) {
                            final budget = budgets[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              child: ListTile(
                                title: Text(
                                  '${budget.category} - ₹${budget.estimatedAmount.toStringAsFixed(0)}',
                                ),
                                subtitle: Text(
                                  'Month: ${monthNames[budget.month - 1]}, Year: ${budget.year}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
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
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
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
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await BudgetService().deleteBudget(
                                            budget.id,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
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
