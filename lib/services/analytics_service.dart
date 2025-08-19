import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';
import '../models/income_entry.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ------------------ EXPENSES ------------------
  Future<List<Expense>> fetchExpenses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .get();

    return snapshot.docs
        .map((doc) => Expense.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Aggregate expenses by category
  Future<Map<String, double>> getExpenseByCategory() async {
    final expenses = await fetchExpenses();
    final Map<String, double> result = {};
    for (var e in expenses) {
      result[e.category] = (result[e.category] ?? 0) + e.amount;
    }
    return result;
  }

  // Aggregate weekly expenses
  Future<Map<int, double>> getWeeklyExpenses({int? year}) async {
    final expenses = await fetchExpenses();
    final Map<int, double> result = {};
    final currentYear = year ?? DateTime.now().year;

    for (var e in expenses.where((e) => e.date.year == currentYear)) {
      final week = _weekNumber(e.date);
      result[week] = (result[week] ?? 0) + e.amount;
    }

    return result;
  }

  // Aggregate monthly expenses
  Future<Map<int, double>> getMonthlyExpenses({int? year}) async {
    final expenses = await fetchExpenses();
    final Map<int, double> result = {};
    final currentYear = year ?? DateTime.now().year;

    for (var e in expenses.where((e) => e.date.year == currentYear)) {
      final month = e.date.month;
      result[month] = (result[month] ?? 0) + e.amount;
    }

    return result;
  }

  int _weekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    return ((date.difference(firstDayOfYear).inDays) / 7).ceil();
  }

  // ------------------ INCOME ------------------
  Future<List<IncomeEntry>> fetchIncome() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('income')
        .get();

    return snapshot.docs
        .map((doc) => IncomeEntry.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Aggregate irregular income (entries that are not monthly)
  Future<double> getIrregularIncome({int? year}) async {
    final incomes = await fetchIncome();
    final currentYear = year ?? DateTime.now().year;
    // For example: consider entries not on 1st day of month as irregular
    final irregular = incomes.where(
      (e) => e.date.year == currentYear && e.date.day != 1,
    );
    return irregular.fold<double>(
      0.0,
      (totalAmount, e) => totalAmount + e.amount,
    );
  }

  // Aggregate monthly income (assuming 1st of month is monthly)
  Future<Map<int, double>> getMonthlyIncome({int? year}) async {
    final incomes = await fetchIncome();
    final currentYear = year ?? DateTime.now().year;
    final Map<int, double> result = {};

    for (var e in incomes.where(
      (e) => e.date.year == currentYear && e.date.day == 1,
    )) {
      result[e.date.month] = (result[e.date.month] ?? 0) + e.amount;
    }

    return result;
  }

  // Aggregate yearly income
  Future<double> getYearlyIncome({int? year}) async {
    final incomes = await fetchIncome();
    final currentYear = year ?? DateTime.now().year;

    final total = incomes
        .where((e) => e.date.year == currentYear)
        .fold(0.0, (total, e) => total + e.amount);

    return total;
  }

  // ------------------ EXPENSE vs INCOME COMPARISON ------------------
  Future<Map<String, dynamic>> getComparison({int? year}) async {
    final weeklyExpenses = await getWeeklyExpenses(year: year);
    final irregularIncome = await getIrregularIncome(year: year);
    final monthlyIncome = await getMonthlyIncome(year: year);

    // For each week, decide coverage: first irregular, then monthly
    final Map<int, Map<String, double>> comparison = {};
    for (var week in weeklyExpenses.keys) {
      double expense = weeklyExpenses[week]!;
      double coveredByIrregular = expense <= irregularIncome
          ? expense
          : irregularIncome;
      double remaining = (expense - coveredByIrregular).clamp(
        0,
        double.infinity,
      );
      int month = DateTime.now().month; // Simplification: map week to month
      double coveredByMonthly = remaining <= (monthlyIncome[month] ?? 0)
          ? remaining
          : (monthlyIncome[month] ?? 0);

      comparison[week] = {
        'expense': expense,
        'coveredByIrregular': coveredByIrregular,
        'coveredByMonthly': coveredByMonthly,
      };
    }

    return {
      'weeklyComparison': comparison,
      'irregularIncome': irregularIncome,
      'monthlyIncome': monthlyIncome,
    };
  }
}
