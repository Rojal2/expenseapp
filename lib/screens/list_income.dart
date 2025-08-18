import 'package:expenseapp/models/income_entry.dart';
import 'package:expenseapp/screens/add_income.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeListScreen extends StatelessWidget {
  const IncomeListScreen({super.key});

  Future<void> _editIncomeEntry(BuildContext context, IncomeEntry entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddIncomeScreen(incomeEntryToEdit: entry),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income List'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('income')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final incomeDocs = snapshot.data!.docs;
          final incomes = incomeDocs
              .map(
                (doc) => IncomeEntry.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();

          if (incomes.isEmpty) {
            return const Center(
              child: Text(
                'No income records found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Calculate total income
          final totalIncome = incomes.fold<double>(
            0,
            (sum, entry) => sum + entry.amount,
          );

          return Column(
            children: [
              // Total income summary
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

              // List of incomes
              Expanded(
                child: ListView.builder(
                  itemCount: incomes.length,
                  itemBuilder: (context, index) {
                    final entry = incomes[index];
                    final isRegular =
                        entry.description?.toLowerCase() == 'regular';

                    return Dismissible(
                      key: Key(entry.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: const Text(
                              'Are you sure you want to delete this income entry?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await FirebaseFirestore.instance
                              .collection('income')
                              .doc(entry.id)
                              .delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Income entry deleted'),
                            ),
                          );
                        }
                        return confirmed ?? false;
                      },
                      child: Card(
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
                            '${(entry.description ?? 'No description').trim()} - ${isRegular ? 'Regular' : 'Irregular'}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.teal,
                                ),
                                onPressed: () =>
                                    _editIncomeEntry(context, entry),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.grey,
                                ),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Confirm Deletion'),
                                      content: const Text(
                                        'Are you sure you want to delete this income entry?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    await FirebaseFirestore.instance
                                        .collection('income')
                                        .doc(entry.id)
                                        .delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Income entry deleted'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddIncomeScreen()),
        ),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
