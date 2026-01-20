import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/chore.dart';
import '../models/expense.dart';
import '../models/group.dart';
import '../models/week_plan.dart';
import '../utils/week_key.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService(this._db);

  DocumentReference<Map<String, dynamic>> userRef(String uid) => _db.collection('users').doc(uid);
  DocumentReference<Map<String, dynamic>> groupRef(String groupId) => _db.collection('groups').doc(groupId);

  CollectionReference<Map<String, dynamic>> choresRef(String groupId) =>
      groupRef(groupId).collection('chores');

  CollectionReference<Map<String, dynamic>> weeksRef(String groupId) =>
      groupRef(groupId).collection('weeks');

  CollectionReference<Map<String, dynamic>> expensesRef(String groupId) =>
      groupRef(groupId).collection('expenses');

  Future<bool> userDocExists(String uid) async {
  final snap = await userRef(uid).get();
  return snap.exists;
}
  Future<void> ensureUserDoc({
    required String uid,
    required String email,
    required String name,
    required int roomNumber,
  }) async {
    final ref = userRef(uid);
    final snap = await ref.get();
    if (snap.exists) return;
    await ref.set({
      'email': email,
      'name': name,
      'groupId': null,
      'role': 'member',
      'roomNumber': roomNumber,
    });
  }

  Stream<AppUser?> watchAppUser(String uid) {
    return userRef(uid).snapshots().map((d) {
      final data = d.data();
      if (data == null) return null;
      return AppUser.fromMap(uid, data);
    });
  }

  Stream<Group?> watchGroup(String groupId) {
    return groupRef(groupId).snapshots().map((d) {
      final data = d.data();
      if (data == null) return null;
      return Group.fromMap(d.id, data);
    });
  }

  Stream<List<Chore>> watchChores(String groupId) {
    return choresRef(groupId).where('active', isEqualTo: true).snapshots().map((q) {
      return q.docs.map((d) => Chore.fromMap(d.id, d.data())).toList()
        ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    });
  }

  Stream<List<Expense>> watchRecentExpenses(String groupId, {int limit = 20}) {
    return expensesRef(groupId).orderBy('date', descending: true).limit(limit).snapshots().map((q) {
      return q.docs.map((d) => Expense.fromMap(d.id, d.data())).toList();
    });
  }

  Stream<WeekPlan?> watchWeekPlan(String groupId, String weekId) {
    return weeksRef(groupId).doc(weekId).snapshots().map((d) {
      final data = d.data();
      if (data == null) return null;
      return WeekPlan.fromMap(d.id, data);
    });
  }

  Future<String> createGroup({
    required String creatorUid,
    required String groupName,
  }) async {
    final groupId = _generateGroupId();
    final groupDoc = groupRef(groupId);
    final userDoc = userRef(creatorUid);

    await _db.runTransaction((tx) async {
      tx.set(groupDoc, {
        'name': groupName,
        'members': [creatorUid],
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'roomCount': 13,
        'rotationStartRoom': 4,
      });
      tx.update(userDoc, {'groupId': groupId, 'role': 'admin'});
    });

    await _seedDefaultChores(groupId);
    return groupId;
  }

  Future<void> joinGroup({
    required String uid,
    required String groupId,
  }) async {
    final groupDoc = groupRef(groupId);
    final userDoc = userRef(uid);

    await _db.runTransaction((tx) async {
      final gSnap = await tx.get(groupDoc);
      if (!gSnap.exists) {
        throw StateError('Group not found');
      }
      final members = ((gSnap.data()?['members'] as List?)?.cast<String>() ?? <String>[]);
      if (!members.contains(uid)) {
        members.add(uid);
      }
      tx.update(groupDoc, {'members': members});
      tx.update(userDoc, {'groupId': groupId, 'role': 'member'});
    });
  }

  Future<void> addChore({
    required String groupId,
    required String title,
  }) async {
    final doc = choresRef(groupId).doc();
    await doc.set(Chore(id: doc.id, title: title, active: true).toMap());
  }

  Future<void> addExpense({
    required String groupId,
    required String title,
    required double amount,
    required String paidByUid,
    required DateTime date,
  }) async {
    final doc = expensesRef(groupId).doc();
    await doc.set(Expense(id: doc.id, title: title, amount: amount, paidBy: paidByUid, date: date).toMap());
  }

  Future<void> toggleCompleted({
    required String groupId,
    required String weekId,
    required String choreId,
    required bool value,
  }) async {
    await weeksRef(groupId).doc(weekId).set({
      'completed': {choreId: value},
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> ensureCurrentWeekPlan({
  required String groupId,
}) async {
  final weekId = WeekKey.nowIsoWeekId();
  final weekDoc = weeksRef(groupId).doc(weekId);

  final choresQuerySnap =
      await choresRef(groupId).where('active', isEqualTo: true).get();

  final chores = choresQuerySnap.docs
      .map((d) => Chore.fromMap(d.id, d.data()))
      .toList()
    ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

  await _db.runTransaction((tx) async {
    final weekSnap = await tx.get(weekDoc);
    if (weekSnap.exists) return;

    final groupSnap = await tx.get(groupRef(groupId));
    final groupData = groupSnap.data();
    if (groupData == null) throw StateError('Group not found');

    final roomCount = (groupData['roomCount'] as int?) ?? 13;
    final startRoom = (groupData['rotationStartRoom'] as int?) ?? 1; // 1..13
    final offset = WeekKey.weekIndex(weekId) % roomCount;

    final assignments = <String, int>{};
    final completed = <String, bool>{};

    for (var i = 0; i < chores.length; i++) {
      final chore = chores[i];
      final room = (((startRoom - 1) + i + offset) % roomCount) + 1; // 1..13
      assignments[chore.id] = room as int;
      completed[chore.id] = false;
    }

    tx.set(weekDoc, {
      'assignments': assignments,
      'completed': completed,
      'roomCount': roomCount,
      'rotationStartRoom': startRoom,
      'rotationOffset': offset,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
  });
}

  Future<void> saveMessagingToken({
    required String uid,
    required String token,
    required String platform,
  }) async {
    final ref = userRef(uid).collection('tokens').doc(token);
    await ref.set({
      'platform': platform,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> _seedDefaultChores(String groupId) async {
    final defaults = <String>[
      'Trash',
      'Kitchen cleaning',
      'Bathroom cleaning',
      'Hallway / common area',
    ];

    final batch = _db.batch();
    for (final title in defaults) {
      final doc = choresRef(groupId).doc();
      batch.set(doc, Chore(id: doc.id, title: title, active: true).toMap());
    }
    await batch.commit();
  }

  String _generateGroupId() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    return List.generate(6, (_) => alphabet[r.nextInt(alphabet.length)]).join();
  }
}
