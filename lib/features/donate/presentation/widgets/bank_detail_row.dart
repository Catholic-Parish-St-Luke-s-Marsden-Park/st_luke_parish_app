import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// One labelled bank detail, e.g. "BSB  067 950", with a copy button when
/// [copyable]. Wraps rather than truncating at large text sizes.
class BankDetailRow extends StatelessWidget {
  const BankDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.copyable = true,
  });

  final String label;
  final String value;
  final bool copyable;

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    await Clipboard.setData(ClipboardData(text: value));
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label copied')));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryNavy,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (copyable)
            IconButton(
              onPressed: () => _copy(context),
              tooltip: 'Copy $label',
              // A full 48x48 target, whatever the theme's density.
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              color: AppColors.primaryNavy,
              icon: const Icon(Icons.copy_rounded),
            ),
        ],
      ),
    );
  }
}
