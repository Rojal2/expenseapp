import 'package:flutter/material.dart';

class Expense {
  final double amount;
  final String description;
  final String category;
  final DateTime date;

  Expense({
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
  });
}

class ExpenseProvider extends ChangeNotifier {
  final List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  double get totalExpenses => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void removeExpense(Expense expense) {
    _expenses.remove(expense);
    notifyListeners();
  }
}
