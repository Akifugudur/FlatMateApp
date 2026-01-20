class AppUser {
  final String uid;
  final String email;
  final String name;
  final String? groupId;
  final String role; // admin | member
  final int roomNumber;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.groupId,
    required this.role,
    required this.roomNumber,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    final rn = data['roomNumber'];
    final roomNumber = rn is int ? rn : int.tryParse(rn?.toString() ?? '') ?? 0;
    
    return AppUser(
      uid: uid,
      email: (data['email'] ?? '') as String,
      name: (data['name'] ?? '') as String,
      groupId: data['groupId'] as String?,
      role: (data['role'] ?? 'member') as String,
      roomNumber: roomNumber,
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'name': name,
        'groupId': groupId,
        'role': role,
        'roomNumber': roomNumber,
      };
}