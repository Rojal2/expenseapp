import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetDetailScreen extends StatefulWidget {
  final String budgetId;
  final Map<String, dynamic> budgetData;

  const BudgetDetailScreen({
    required this.budgetId,
    required this.budgetData,
    Key? key,
  }) : super(key: key);

  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> {
  final _expenseController = TextEditingController();
  final _emailController = TextEditingController();

  Future<void> _addExpense() async {
    final amount = double.tryParse(_expenseController.text);
    if (amount == null) return;

    await FirebaseFirestore.instance
        .collection('budgets')
        .doc(widget.budgetId)
        .collection('expenses')
        .add({
          'amount': amount,
          'addedBy': FirebaseAuth.instance.currentUser!.uid,
          'date': Timestamp.now(),
        });

    _expenseController.clear();
  }

  Future<void> _inviteCollaborator() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not found')));
      return;
    }

    final collaboratorUid = query.docs.first.id;

    await FirebaseFirestore.instance
        .collection('budgets')
        .doc(widget.budgetId)
        .update({
          'participants': FieldValue.arrayUnion([collaboratorUid]),
        });

    _emailController.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Collaborator invited!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.budgetData['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add expense
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expenseController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Expense Amount',
                    ),
                  ),
                ),
                IconButton(onPressed: _addExpense, icon: const Icon(Icons.add)),
              ],
            ),
            const SizedBox(height: 20),
            // Invite collaborator
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Collaborator Email',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _inviteCollaborator,
                  icon: const Icon(Icons.person_add),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Shared expenses list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('budgets')
                    .doc(widget.budgetId)
                    .collection('expenses')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty)
                    return const Center(child: Text('No expenses yet.'));
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final exp = docs[index];
                      return ListTile(
                        title: Text('₹${exp['amount']}'),
                        subtitle: Text('Added by: ${exp['addedBy']}'),
                        trailing: Text(exp['date'].toDate().toString()),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
