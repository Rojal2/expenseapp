import 'package:expenseapp/models/income_entry.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddIncomeScreen extends StatefulWidget {
  final IncomeEntry? incomeEntryToEdit;

  const AddIncomeScreen({super.key, this.incomeEntryToEdit});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'regular';

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  String? _selectedMonth;
  final List<String> _existingMonths = [];

  @override
  void initState() {
    super.initState();
    _fetchExistingRegularMonths();

    if (widget.incomeEntryToEdit != null) {
      final entry = widget.incomeEntryToEdit!;
      _amountController.text = entry.amount.toString();
      _descriptionController.text = entry.description ?? '';
      _selectedDate = entry.date;
      _selectedType = entry.type;

      if (_selectedType == 'regular') {
        _selectedMonth = _months[entry.date.month - 1];
      }
    } else {
      _selectedMonth = _months[DateTime.now().month - 1];
    }
  }

  Future<void> _fetchExistingRegularMonths() async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);

    final snapshot = await FirebaseFirestore.instance
        .collection('income')
        .where('type', isEqualTo: 'regular')
        .where('date', isGreaterThanOrEqualTo: startOfYear)
        .where('date', isLessThanOrEqualTo: endOfYear)
        .get();

    setState(() {
      _existingMonths.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['date'] is Timestamp) {
          final date = (data['date'] as Timestamp).toDate();
          _existingMonths.add(_months[date.month - 1]);
        }
      }
    });
  }

  Future<void> _addOrUpdateIncome() async {
    if (_formKey.currentState!.validate()) {
      DateTime entryDate;
      if (_selectedType == 'regular') {
        final now = DateTime.now();
        final monthIndex = _months.indexOf(_selectedMonth!);
        entryDate = DateTime(now.year, monthIndex + 1, 15);
      } else {
        entryDate = _selectedDate;
      }

      final incomeData = {
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'date': Timestamp.fromDate(entryDate),
        'type': _selectedType,
        'description': _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
      };

      if (widget.incomeEntryToEdit != null) {
        await FirebaseFirestore.instance
            .collection('income')
            .doc(widget.incomeEntryToEdit!.id)
            .update(incomeData);
      } else {
        await FirebaseFirestore.instance.collection('income').add(incomeData);
      }

      if (mounted) {
        Navigator.pop(context, true); // ✅ return true to trigger refresh
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.incomeEntryToEdit != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Income' : 'Add Income'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Regular'),
                      value: 'regular',
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                          _selectedMonth = _months[DateTime.now().month - 1];
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Irregular'),
                      value: 'irregular',
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_selectedType == 'regular')
                DropdownButtonFormField<String>(
                  value: _selectedMonth,
                  decoration: const InputDecoration(
                    labelText: 'Select Month',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  items: _months.map((String month) {
                    final isDisabled =
                        _existingMonths.contains(month) &&
                        widget.incomeEntryToEdit == null;
                    return DropdownMenuItem<String>(
                      value: month,
                      enabled: !isDisabled,
                      child: Text(
                        month,
                        style: TextStyle(
                          color: isDisabled ? Colors.grey : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMonth = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a month';
                    }
                    if (_existingMonths.contains(value) &&
                        widget.incomeEntryToEdit == null) {
                      return 'Entry for this month already exists';
                    }
                    return null;
                  },
                )
              else
                ListTile(
                  title: Text(
                    'Date: ${_selectedDate.toLocal().toShortString()}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _addOrUpdateIncome,
                  icon: const Icon(Icons.save),
                  label: Text(isEditing ? 'Update Income' : 'Save Income'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on DateTime {
  String toShortString() {
    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}
