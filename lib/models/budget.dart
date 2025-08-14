class Budget {
  final int year;
  final Map<String, double> monthlyBudgets;
  final double yearlyBudget;

  double get totalMonthlyBudgets {
    if (monthlyBudgets.isEmpty) return 0.0;
    return monthlyBudgets.values.fold(0.0, (sum, item) => sum + item);
  }

  Budget({
    required this.year,
    required this.monthlyBudgets,
    required this.yearlyBudget,
  });

  Budget copyWith({double? yearlyBudget, Map<String, double>? monthlyBudgets}) {
    return Budget(
      yearlyBudget: yearlyBudget ?? this.yearlyBudget,
      monthlyBudgets: monthlyBudgets ?? this.monthlyBudgets,
      year: 2025,
    );
  }

  Map<String, dynamic> toMap() => {
    'monthlyBudgets': monthlyBudgets,
    'yearlyBudget': yearlyBudget,
  };

  factory Budget.fromMap(String year, Map<String, dynamic> map) {
    final monthly = Map<String, double>.from(map['monthlyBudgets'] ?? {});
    return Budget(
      year: 2025,
      monthlyBudgets: monthly,
      yearlyBudget: (map['yearlyBudget'] as num).toDouble(),
    );
  }
}
