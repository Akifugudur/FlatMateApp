import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/services/auth_service.dart';
import 'src/services/firestore_service.dart';
import 'src/services/messaging_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  final authService = AuthService(FirebaseAuth.instance);
  final firestoreService = FirestoreService(FirebaseFirestore.instance);
  final messagingService = MessagingService(FirebaseMessaging.instance, firestoreService, authService);

  runApp(FlatMateApp(
    authService: authService,
    firestoreService: firestoreService,
    messagingService: messagingService,
  ));
}