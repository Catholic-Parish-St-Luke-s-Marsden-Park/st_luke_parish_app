import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

class StLukeApp extends StatelessWidget {
  const StLukeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "St Luke's Parish",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
