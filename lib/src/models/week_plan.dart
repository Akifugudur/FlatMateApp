class WeekPlan {
  final String id; // yyyy-Www
  final Map<String, int> assignments; // choreId -> roomNumber (1..13)
  final Map<String, bool> completed; // choreId -> bool

  const WeekPlan({
    required this.id,
    required this.assignments,
    required this.completed,
  });

  factory WeekPlan.fromMap(String id, Map<String, dynamic> data) {
    final a = (data['assignments'] as Map?)?.cast<String, dynamic>() ?? {};
    final c = (data['completed'] as Map?)?.cast<String, dynamic>() ?? {};

    return WeekPlan(
      id: id,
      assignments: a.map((k, v) {
        final n = v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
        return MapEntry(k, n);
      }),
      completed: c.map((k, v) => MapEntry(k, v == true)),
    );
  }
}