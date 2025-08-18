import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FinanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get combined income vs expense for a given period
  Future<Map<String, Map<String, double>>> getIncomeVsExpense({
    String period = 'month', // 'week' or 'month'
  }) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    DateTime now = DateTime.now();
    DateTime startDate;

    if (period == 'week') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
    } else {
      startDate = DateTime(now.year, now.month, 1);
    }

    // Fetch expenses
    QuerySnapshot expenseSnapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();

    // Fetch income
    QuerySnapshot incomeSnapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('income')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();

    Map<String, double> expensesByDate = {};
    for (var doc in expenseSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      final date = data['date'] is Timestamp
          ? (data['date'] as Timestamp).toDate()
          : DateTime.tryParse(data['date'] ?? '') ?? DateTime.now();

      String key = "${date.day}/${date.month}";
      double amount = (data['amount'] ?? 0).toDouble();
      expensesByDate[key] = (expensesByDate[key] ?? 0) + amount;
    }

    Map<String, double> incomeByDate = {};
    for (var doc in incomeSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      final date = data['date'] is Timestamp
          ? (data['date'] as Timestamp).toDate()
          : DateTime.tryParse(data['date'] ?? '') ?? DateTime.now();

      String key = "${date.day}/${date.month}";
      double amount = (data['amount'] ?? 0).toDouble();
      incomeByDate[key] = (incomeByDate[key] ?? 0) + amount;
    }

    // Combine income and expense
    Map<String, Map<String, double>> combined = {};
    Set<String> allKeys = {...expensesByDate.keys, ...incomeByDate.keys};
    for (var key in allKeys) {
      combined[key] = {
        'expense': expensesByDate[key] ?? 0,
        'income': incomeByDate[key] ?? 0,
      };
    }

    return combined;
  }
}
