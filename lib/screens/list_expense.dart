import 'package:expenseapp/screens/add_expense.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';

class ListExpenseScreen extends StatefulWidget {
  const ListExpenseScreen({super.key});

  @override
  State<ListExpenseScreen> createState() => _ListExpenseScreenState();
}

class _ListExpenseScreenState extends State<ListExpenseScreen> {
  int? selectedMonth = DateTime.now().month; // null means "All months"
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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(child: Text('Not signed in'))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Filters Row
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
                                  child: Text('All'),
                                ),
                                ...List.generate(12, (i) {
                                  return DropdownMenuItem(
                                    value: i + 1,
                                    child: Text(
                                      monthNames[i],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (val) =>
                                  setState(() => selectedMonth = val),
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
                                  List.generate(
                                        5,
                                        (i) => DateTime.now().year - 4 + i,
                                      )
                                      .map(
                                        (yr) => DropdownMenuItem(
                                          value: yr,
                                          child: Text(
                                            '$yr',
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => selectedYear = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Expense List
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _getExpenseStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
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

                        final totalExpense = expenses.fold<double>(
                          0,
                          (sum, exp) => sum + exp.amount,
                        );

                        return Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.red.shade100,
                                        child: Text(
                                          exp.category[0].toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.red.shade800,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        '${exp.category} - ₹${exp.amount.toStringAsFixed(2)}',
                                      ),
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
                                            onPressed: () =>
                                                _editExpense(context, exp),
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
                                                  title: const Text(
                                                    'Delete Expense',
                                                  ),
                                                  content: const Text(
                                                    'Are you sure you want to delete this expense?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            true,
                                                          ),
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
                  ),
                ],
              ),
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

  Stream<QuerySnapshot> _getExpenseStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    Query collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('expenses');

    DateTime startDate;
    DateTime endDate;

    if (selectedMonth != null) {
      // Start of month
      startDate = DateTime(selectedYear, selectedMonth!, 1);
      // End of month
      if (selectedMonth == 12) {
        endDate = DateTime(
          selectedYear + 1,
          1,
          1,
        ).subtract(const Duration(milliseconds: 1));
      } else {
        endDate = DateTime(
          selectedYear,
          selectedMonth! + 1,
          1,
        ).subtract(const Duration(milliseconds: 1));
      }
    } else {
      // Whole year
      startDate = DateTime(selectedYear, 1, 1);
      endDate = DateTime(
        selectedYear + 1,
        1,
        1,
      ).subtract(const Duration(milliseconds: 1));
    }

    collectionRef = collectionRef
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate);

    return collectionRef.orderBy('date', descending: true).snapshots();
  }

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
      'description': exp.description,
    };
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddExpenseScreen(expenseId: exp.id, expenseData: expenseData),
      ),
    );
  }
}
