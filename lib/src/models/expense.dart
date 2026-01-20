class Expense {
  final String id;
  final String title;
  final double amount;
  final String paidBy;
  final DateTime date;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.date,
  });

  factory Expense.fromMap(String id, Map<String, dynamic> data) {
    final amountNum = data['amount'];
    final amount = amountNum is int ? amountNum.toDouble() : (amountNum as num?)?.toDouble() ?? 0.0;

    final dateRaw = data['date'];
    DateTime date;
    if (dateRaw is String) {
      date = DateTime.tryParse(dateRaw)?.toLocal() ?? DateTime.now();
    } else {
      date = DateTime.now();
    }

    return Expense(
      id: id,
      title: (data['title'] ?? '') as String,
      amount: amount,
      paidBy: (data['paidBy'] ?? '') as String,
      date: date,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'amount': amount,
        'paidBy': paidBy,
        'date': date.toUtc().toIso8601String(),
      };
}
