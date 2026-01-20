import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'auth_service.dart';
import 'firestore_service.dart';

class MessagingService {
  final FirebaseMessaging _messaging;
  final FirestoreService _firestore;
  final AuthService _auth;

  MessagingService(this._messaging, this._firestore, this._auth);

  Future<void> init() async {
    await _messaging.requestPermission();

    _messaging.onTokenRefresh.listen((token) async {
      final user = _auth.currentUser;
      if (user == null) return;
      await _firestore.saveMessagingToken(
        uid: user.uid,
        token: token,
        platform: Platform.operatingSystem,
      );
    });

    final token = await _messaging.getToken();
    final user = _auth.currentUser;
    if (token != null && user != null) {
      await _firestore.saveMessagingToken(
        uid: user.uid,
        token: token,
        platform: Platform.operatingSystem,
      );
    }
  }
}