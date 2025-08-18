import 'package:flutter/material.dart';
import '../models/budget_estimation.dart';
import '../services/budget_service.dart';

class AddBudgetScreen extends StatefulWidget {
  final Budget? budget;
  const AddBudgetScreen({super.key, this.budget});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _category = '';
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _category = widget.budget!.category;
      _amountController.text = widget.budget!.estimatedAmount.toString();
      _month = widget.budget!.month;
      _year = widget.budget!.year;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget == null ? 'Add Budget' : 'Edit Budget'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter category' : null,
                onChanged: (val) => _category = val,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Estimated Amount',
                ),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter amount' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  DropdownButton<int>(
                    value: _month,
                    items: List.generate(12, (i) {
                      return DropdownMenuItem(
                        value: i + 1,
                        child: Text('${i + 1}'),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) setState(() => _month = val);
                    },
                  ),
                  const SizedBox(width: 20),
                  DropdownButton<int>(
                    value: _year,
                    items: List.generate(5, (i) => DateTime.now().year - 2 + i)
                        .map(
                          (yr) =>
                              DropdownMenuItem(value: yr, child: Text('$yr')),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _year = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await BudgetService().addOrUpdateBudget(
                        Budget(
                          id: widget.budget?.id ?? '',
                          category: _category,
                          estimatedAmount: double.parse(_amountController.text),
                          month: _month,
                          year: _year,
                        ),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
