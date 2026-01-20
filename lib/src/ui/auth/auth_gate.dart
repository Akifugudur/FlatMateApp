import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'login_page.dart';
import '../home/home_shell.dart';

class AuthGate extends StatelessWidget {
  final AuthService authService;
  final FirestoreService firestoreService;

  const AuthGate({
    super.key,
    required this.authService,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges(),
      builder: (context, snap) {
        final user = snap.data;
        if (user == null) {
          return LoginPage(authService: authService, firestoreService: firestoreService);
        }
        return HomeShell(authService: authService, firestoreService: firestoreService, uid: user.uid);
      },
    );
  }
}