import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../features/prayer_request/presentation/screens/prayer_request_screen.dart';
import '../../features/resources/presentation/screens/resources_screen.dart';

/// Side drawer chrome hosting the 2 secondary destinations: Resources and
/// Prayer Request.
class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "St Luke's Parish",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'MORE',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_rounded),
              title: const Text('Resources'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ResourcesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border_rounded),
              title: const Text('Prayer Request'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PrayerRequestScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
