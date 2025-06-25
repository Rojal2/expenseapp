class Budget {
  final String year;
  final Map<String, double> monthlyBudgets;
  final double yearlyBudget;

  Budget({
    required this.year,
    required this.monthlyBudgets,
    required this.yearlyBudget,
  });

  Map<String, dynamic> toMap() => {
    'monthlyBudgets': monthlyBudgets,
    'yearlyBudget': yearlyBudget,
  };

  factory Budget.fromMap(String year, Map<String, dynamic> map) {
    final monthly = Map<String, double>.from(map['monthlyBudgets'] ?? {});
    return Budget(
      year: year,
      monthlyBudgets: monthly,
      yearlyBudget: (map['yearlyBudget'] as num).toDouble(),
    );
  }
}
