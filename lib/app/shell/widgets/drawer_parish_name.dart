import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// "St Luke's Catholic Parish" over a gold rule and MARSDEN PARK, for the
/// side menu header (parish request, 2026-10-22). MARSDEN PARK is spaced
/// out to end exactly where the name does, as on the parish logo, and the
/// two lines shrink together if large system text would not otherwise fit.
class DrawerParishName extends StatefulWidget {
  const DrawerParishName({super.key});

  static const name = "St Luke's Catholic Parish";
  static const place = 'MARSDEN PARK';

  @override
  State<DrawerParishName> createState() => _DrawerParishNameState();
}

class _DrawerParishNameState extends State<DrawerParishName> {
  static final _nameStyle = AppTypography.display(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.15,
  );

  static const _placeStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  @override
  void initState() {
    super.initState();
    // The heading font may arrive after the first build; measure again
    // once it has, so the two lines still end together.
    PaintingBinding.instance.systemFonts.addListener(_fontsChanged);
  }

  @override
  void dispose() {
    PaintingBinding.instance.systemFonts.removeListener(_fontsChanged);
    super.dispose();
  }

  void _fontsChanged() {
    if (mounted) setState(() {});
  }

  double _widthOf(String text, TextStyle style, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final nameWidth = _widthOf(DrawerParishName.name, _nameStyle, scaler);
    final placeWidth = _widthOf(DrawerParishName.place, _placeStyle, scaler);
    // Spread the leftover width over the gaps between letters. (Letter
    // spacing is not enlarged by the system text size, so no scaling.)
    final gaps = DrawerParishName.place.length - 1;
    final spare = (nameWidth - placeWidth).clamp(0.0, double.infinity);
    final spacing = spare / gaps;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: SizedBox(
        width: nameWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DrawerParishName.name, maxLines: 1, style: _nameStyle),
            Container(
              height: 1.5,
              margin: const EdgeInsets.symmetric(vertical: 6),
              color: AppColors.gold,
            ),
            // Letter spacing also follows the last letter; let that
            // trailing space hang past the edge rather than wrap.
            OverflowBox(
              alignment: AlignmentDirectional.centerStart,
              maxWidth: double.infinity,
              fit: OverflowBoxFit.deferToChild,
              child: Text(
                DrawerParishName.place,
                maxLines: 1,
                softWrap: false,
                style: _placeStyle.copyWith(letterSpacing: spacing),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
