import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetProvider extends ChangeNotifier {
  double _monthlyIncome = 0.0;
  double get monthlyIncome => _monthlyIncome;

  Future<void> loadIncome() async {
    final prefs = await SharedPreferences.getInstance();
    _monthlyIncome = prefs.getDouble('monthlyIncome') ?? 0.0;
    notifyListeners();
  }

  Future<void> setIncome(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthlyIncome', value);
    _monthlyIncome = value;
    notifyListeners();
  }
}
