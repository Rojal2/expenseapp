import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/income_entry.dart';

class IncomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch incomes with optional date filters
  Future<List<IncomeEntry>> getIncomes({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    Query query = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('income')
        .orderBy('date', descending: true);

    if (startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }
    if (endDate != null) {
      query = query.where(
        'date',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map(
          (doc) =>
              IncomeEntry.fromMap(doc.id, doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  /// Add or update income entry
  Future<void> addOrUpdateIncome(IncomeEntry entry) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final collection = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('income');

    if (entry.id.isEmpty) {
      await collection.add(entry.toMap());
    } else {
      await collection.doc(entry.id).set(entry.toMap());
    }
  }

  /// Delete income
  Future<void> deleteIncome(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('income')
        .doc(id)
        .delete();
  }

  /// Group incomes by category
  Future<Map<String, double>> getIncomeBreakdownByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final incomes = await getIncomes(startDate: startDate, endDate: endDate);
    final Map<String, double> grouped = {};

    for (var e in incomes) {
      final key = e.type ?? 'Uncategorized'; // category field in IncomeEntry
      grouped[key] = (grouped[key] ?? 0) + e.amount;
    }
    return grouped;
  }
}
