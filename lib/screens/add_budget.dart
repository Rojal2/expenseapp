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

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Drinks',
    'Other',
  ];

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
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _category = widget.budget!.category;
      _amountController.text = widget.budget!.estimatedAmount.toString();
      _month = widget.budget!.month;
      _year = widget.budget!.year;
    } else {
      _category = _categories.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget == null ? 'Add Budget' : 'Edit Budget'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Category Dropdown
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  prefixIcon: Icon(Icons.category),
                ),
                child: DropdownButton<String>(
                  value: _category,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _category = val);
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Estimated Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Estimated Amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter amount' : null,
              ),
              const SizedBox(height: 20),

              // Month & Year Dropdowns
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Month',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                      child: DropdownButton<int>(
                        value: _month,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: List.generate(12, (i) {
                          return DropdownMenuItem(
                            value: i + 1,
                            child: Text(monthNames[i]),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) setState(() => _month = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                      child: DropdownButton<int>(
                        value: _year,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items:
                            List.generate(5, (i) => DateTime.now().year - 4 + i)
                                .map(
                                  (yr) => DropdownMenuItem(
                                    value: yr,
                                    child: Text('$yr'),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _year = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Budget'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await BudgetService().addOrUpdateBudget(
                          Budget(
                            id: widget.budget?.id ?? '',
                            category: _category,
                            estimatedAmount: double.parse(
                              _amountController.text,
                            ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
