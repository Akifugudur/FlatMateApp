class Chore {
  final String id;
  final String title;
  final bool active;

  const Chore({required this.id, required this.title, required this.active});

  factory Chore.fromMap(String id, Map<String, dynamic> data) {
    return Chore(
      id: id,
      title: (data['title'] ?? '') as String,
      active: (data['active'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'active': active,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      };
}