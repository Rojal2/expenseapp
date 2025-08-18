import 'package:expenseapp/screens/add_expense.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';

class ListExpenseScreen extends StatelessWidget {
  const ListExpenseScreen({super.key});

  Future<void> _deleteExpense(BuildContext context, String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .doc(id)
        .delete();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Expense deleted!')));
  }

  Future<void> _editExpense(BuildContext context, Expense exp) async {
    final expenseData = {
      'amount': exp.amount,
      'note': exp.note,
      'category': exp.category,
      'date': Timestamp.fromDate(exp.date),
    };

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddExpenseScreen(expenseId: exp.id, expenseData: expenseData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: user == null
          ? const Center(child: Text('Not signed in'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('expenses')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No expenses yet.'));
                }

                final expenses = snapshot.data!.docs
                    .map(
                      (doc) => Expense.fromMap(
                        doc.id,
                        doc.data() as Map<String, dynamic>,
                      ),
                    )
                    .toList();

                // Calculate total expense
                final totalExpense = expenses.fold<double>(
                  0,
                  (sum, exp) => sum + exp.amount,
                );

                return Column(
                  children: [
                    // Total expense at top
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.red.shade50,
                      child: Text(
                        "Total Expense: ₹${totalExpense.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (context, i) {
                          final exp = expenses[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(exp.category[0].toUpperCase()),
                              ),
                              title: Text('${exp.category} - ₹${exp.amount}'),
                              subtitle: Text(
                                '${exp.note.trim()}\n${exp.date.toLocal().toString().split(' ')[0]}',
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => _editExpense(context, exp),
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
                                          title: const Text('Delete Expense'),
                                          content: const Text(
                                            'Are you sure you want to delete this expense?',
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
                                        _deleteExpense(context, exp.id);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
