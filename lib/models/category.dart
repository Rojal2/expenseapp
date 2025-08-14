// In models/category.dart

import 'package:flutter/material.dart';

class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;
  final double? monthlyBudget;
  final bool isDefault;

  const ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
    this.monthlyBudget,
    this.isDefault = false,
  });
}
