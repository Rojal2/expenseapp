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
        ) // ← cast here
        .toList();
  }

  /// Group incomes by period
  Future<Map<String, double>> getIncomeBreakdown({
    String period = 'month',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final incomes = await getIncomes(startDate: startDate, endDate: endDate);

    final Map<String, double> grouped = {};
    for (var e in incomes) {
      String key;
      if (period == 'month') {
        key = "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}";
      } else if (period == 'week') {
        final week = ((e.date.day - 1) ~/ 7) + 1; // 1-4 weeks
        key =
            "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-W$week";
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
