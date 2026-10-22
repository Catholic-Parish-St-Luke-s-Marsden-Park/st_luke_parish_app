import 'package:go_router/go_router.dart';

import 'shell/app_shell.dart';

/// Single top-level route hosting [AppShell]. Drawer destinations
/// (Resources, Faith Formation, The Rosary, Divine Mercy Chaplet) are pushed via the standard Navigator,
/// available even under `MaterialApp.router`.
final appRouter = GoRouter(
  routes: [GoRoute(path: '/', builder: (context, state) => const AppShell())],
);
