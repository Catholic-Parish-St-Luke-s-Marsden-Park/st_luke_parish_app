import 'package:flutter/material.dart';

import '../../../features/ask_luke/presentation/screens/ask_luke_screen.dart';
import '../../../shared/widgets/app_pill_button.dart';

/// AppBar pill that performs a full-screen navigation to [AskLukeScreen].
class AskLukePill extends StatelessWidget {
  const AskLukePill({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPillButton(
      label: 'Ask Luke',
      icon: Icons.chat_bubble_outline_rounded,
      onPressed: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AskLukeScreen()));
      },
    );
  }
}
