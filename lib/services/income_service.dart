import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/income_entry.dart';

class IncomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all income entries for the current user
  Future<List<IncomeEntry>> getAllIncomes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('income')
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => IncomeEntry.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Example: if you still want breakdowns (month/year)
  Future<Map<String, double>> getIncomeBreakdown({
    String period = 'month',
  }) async {
    final incomes = await getAllIncomes();

    final Map<String, double> grouped = {};
    for (var e in incomes) {
      String key;
      if (period == 'month') {
        key = "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}";
      } else if (period == 'year') {
        key = e.date.year.toString();
      } else {
        key = e.date.toIso8601String();
      }

      grouped[key] = (grouped[key] ?? 0) + e.amount;
    }
    return grouped;
  }
}
