import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddExpenseScreen extends StatefulWidget {
  final String? expenseId; // null = new, non-null = edit
  final Map<String, dynamic>? expenseData;

  const AddExpenseScreen({super.key, this.expenseId, this.expenseData});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _category = 'Food';
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Drinks',
    'Other',
  ];

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.expenseData != null) {
      _amountController.text = widget.expenseData!['amount'].toString();
      _noteController.text = widget.expenseData!['note'] ?? '';
      _category = widget.expenseData!['category'] ?? 'Food';
      _selectedDate = (widget.expenseData!['date'] as Timestamp).toDate();
    }
  }

  Future<void> _saveExpense() async {
    try {
      setState(() => _loading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not signed in');

      final amount = double.tryParse(_amountController.text.trim());
      if (amount == null) throw Exception('Invalid amount');

      final data = {
        'amount': amount,
        'category': _category,
        'note': _noteController.text.trim(),
        'date': Timestamp.fromDate(_selectedDate),
        'description': _noteController.text.trim(),
      };

      final colRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('expenses');

      if (widget.expenseId == null) {
        // Add
        await colRef.add(data);
      } else {
        // Update
        await colRef.doc(widget.expenseId).update(data);
      }

      if (mounted) {
        Navigator.pop(context); // close after save
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.expenseId == null ? 'Expense added!' : 'Expense updated!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expenseId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Expense' : 'Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _category = val!),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: Text(
                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator()
                    : Text(isEditing ? 'Update Expense' : 'Save Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
