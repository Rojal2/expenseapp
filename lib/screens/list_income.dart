import 'package:expenseapp/models/income_entry.dart';
import 'package:expenseapp/screens/add_income.dart';
import 'package:expenseapp/services/income_service.dart';
import 'package:flutter/material.dart';

class IncomeListScreen extends StatefulWidget {
  const IncomeListScreen({super.key});

  @override
  State<IncomeListScreen> createState() => _IncomeListScreenState();
}

class _IncomeListScreenState extends State<IncomeListScreen> {
  int? selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  final IncomeService _incomeService = IncomeService();

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

  Stream<List<IncomeEntry>> _incomeStream() async* {
    final startDate = selectedMonth != null
        ? DateTime(selectedYear, selectedMonth!, 1)
        : DateTime(selectedYear, 1, 1);
    final endDate = selectedMonth != null
        ? DateTime(selectedYear, selectedMonth! + 1, 0)
        : DateTime(selectedYear, 12, 31);

    final incomes = await _incomeService.getIncomes(
      startDate: startDate,
      endDate: endDate,
    );
    yield incomes;
  }

  Future<void> _editIncomeEntry(IncomeEntry entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddIncomeScreen(incomeEntryToEdit: entry),
      ),
    );
    setState(() {}); // refresh list
  }

  Future<void> _deleteIncomeEntry(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Income'),
        content: const Text(
          'Are you sure you want to delete this income entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _incomeService.deleteIncome(id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Income entry deleted')));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income List'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        decoration: const InputDecoration(
                          labelText: 'Month',
                          border: InputBorder.none,
                        ),
                        value: selectedMonth,
                        items:
                            [
                              const DropdownMenuItem<int?>(
                                // Explicitly typing the DropdownMenuItem
                                value: null,
                                child: Text('All'),
                              ),
                            ] +
                            List.generate(
                              12,
                              (i) => DropdownMenuItem<int?>(
                                // Explicitly typing the DropdownMenuItem
                                value:
                                    i +
                                    1, // i + 1 is an int, which is assignable to int?
                                child: Text(monthNames[i]),
                              ),
                            ),
                        onChanged: (val) => setState(() => selectedMonth = val),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          border: InputBorder.none,
                        ),
                        value: selectedYear,
                        items: List.generate(5, (i) => DateTime.now().year - 4 + i)
                            .map(
                              (yr) => DropdownMenuItem<int>(
                                // Explicitly typing the DropdownMenuItem for years
                                value: yr,
                                child: Text('$yr'),
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
            Expanded(
              child: StreamBuilder<List<IncomeEntry>>(
                stream: _incomeStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final incomes = snapshot.data!;
                  if (incomes.isEmpty)
                    return const Center(
                      child: Text(
                        'No income records found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );

                  final totalIncome = incomes.fold<double>(
                    0,
                    (sum, e) => sum + e.amount,
                  );

                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.teal.shade50,
                        child: Text(
                          "Total Income: ₹${totalIncome.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: incomes.length,
                          itemBuilder: (context, index) {
                            final entry = incomes[index];
                            final isRegular =
                                entry.type?.toLowerCase() == 'regular';

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isRegular
                                      ? Colors.teal
                                      : Colors.orange,
                                  child: Icon(
                                    isRegular
                                        ? Icons.calendar_today
                                        : Icons.event_note,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  '₹${entry.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(
                                  '${entry.description ?? 'No description'} - ${isRegular ? 'Regular' : 'Irregular'}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => _editIncomeEntry(entry),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _deleteIncomeEntry(entry.id),
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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddIncomeScreen()),
          );
          setState(() {});
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
