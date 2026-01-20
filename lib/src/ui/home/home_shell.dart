// FILE: lib/src/ui/home/home_shell.dart
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/week_key.dart';
import '../group/group_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/expenses_page.dart';
import 'pages/settings_page.dart';
import 'pages/tasks_page.dart';

class HomeShell extends StatefulWidget {
  final AuthService authService;
  final FirestoreService firestoreService;
  final String uid;

  const HomeShell({
    super.key,
    required this.authService,
    required this.firestoreService,
    required this.uid,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int idx = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: widget.firestoreService.watchAppUser(widget.uid),
      builder: (context, snap) {
        final appUser = snap.data;
        if (appUser == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (appUser.groupId == null) {
          return GroupPage(
            uid: appUser.uid,
            firestoreService: widget.firestoreService,
            authService: widget.authService,
          );
        }

        final groupId = appUser.groupId!;
        final weekId = WeekKey.nowIsoWeekId();

        final pages = <Widget>[
          DashboardPage(
            uid: appUser.uid,
            groupId: groupId,
            weekId: weekId,
            firestoreService: widget.firestoreService,
          ),
          TasksPage(
            groupId: groupId,
            weekId: weekId,
          ),
          ExpensesPage(
            uid: appUser.uid,
            groupId: groupId,
            firestoreService: widget.firestoreService,
          ),
          SettingsPage(
            appUser: appUser,
            authService: widget.authService,
            firestoreService: widget.firestoreService,
          ),
        ];

        return Scaffold(
          body: pages[idx],
          bottomNavigationBar: NavigationBar(
            selectedIndex: idx,
            onDestinationSelected: (v) => setState(() => idx = v),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
              NavigationDestination(icon: Icon(Icons.checklist), label: 'Task'),
              NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Expenses'),
              NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
        );
      },
    );
  }
}