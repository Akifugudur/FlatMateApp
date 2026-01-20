class Group {
  final String id;
  final String name;
  final List<String> members;

  const Group({required this.id, required this.name, required this.members});

  factory Group.fromMap(String id, Map<String, dynamic> data) {
    final members = (data['members'] as List?)?.cast<String>() ?? <String>[];
    return Group(
      id: id,
      name: (data['name'] ?? '') as String,
      members: members,
    );
  }
}