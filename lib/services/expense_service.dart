import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetch expenses by date range
  Future<Map<String, double>> getExpensesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    QuerySnapshot snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    Map<String, double> categoryTotals = {};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      String category = data['category'] ?? 'Other';
      double amount = (data['amount'] ?? 0).toDouble();
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }

    return categoryTotals;
  }
}
