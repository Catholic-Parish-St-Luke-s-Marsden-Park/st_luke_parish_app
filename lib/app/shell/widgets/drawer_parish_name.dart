import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// "St Luke's Catholic Parish" over a gold rule and MARSDEN PARK, for the
/// side menu header (parish request, 2026-10-22). MARSDEN PARK is spaced
/// out so its first and last letters line up exactly with the name's, as on
/// the parish logo, and the two lines shrink together if large system text
/// would not otherwise fit.
class DrawerParishName extends StatefulWidget {
  const DrawerParishName({super.key});

  static const name = "St Luke's Catholic Parish";
  static const place = 'MARSDEN PARK';

  @override
  State<DrawerParishName> createState() => _DrawerParishNameState();
}

/// Where a line's ink (the visible letters) starts and ends, measured from
/// the left edge of its text box. Letters carry a little space either side
/// of their ink, different for each letter and font.
@immutable
class _Ink {
  const _Ink(this.left, this.right);

  final double left;
  final double right;
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

  /// The ink edges of both lines (MARSDEN PARK unspaced), measured for
  /// [_measuredFor]; null until measured.
  (_Ink, _Ink)? _ink;
  Object? _measuredFor;

  @override
  void initState() {
    super.initState();
    // The fonts may arrive after the first build; measure again once they
    // have, so the lines still end together.
    PaintingBinding.instance.systemFonts.addListener(_fontsChanged);
  }

  @override
  void dispose() {
    PaintingBinding.instance.systemFonts.removeListener(_fontsChanged);
    super.dispose();
  }

  void _fontsChanged() {
    if (!mounted) return;
    setState(() {
      _ink = null;
      _measuredFor = null;
    });
  }

  TextPainter _painter(String text, TextStyle style, TextScaler scaler) =>
      TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        maxLines: 1,
      )..layout();

  /// Draws [painter]'s text off screen and finds the first and last columns
  /// with ink.
  static Future<_Ink?> _inkOf(TextPainter painter, double pixelRatio) async {
    const pad = 8.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(pixelRatio);
    painter.paint(canvas, const Offset(pad, 0));
    final picture = recorder.endRecording();
    final width = ((painter.width + pad * 2) * pixelRatio).ceil();
    final height = (painter.height * pixelRatio).ceil();
    final image = await picture.toImage(width, height);
    picture.dispose();
    final bytes = await image.toByteData();
    image.dispose();
    if (bytes == null) return null;

    int? first;
    int? last;
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        // Alpha of the RGBA pixel; faint antialiasing is ignored.
        if (bytes.getUint8((y * width + x) * 4 + 3) > 96) {
          first ??= x;
          last = x + 1;
          break;
        }
      }
    }
    if (first == null || last == null) return null;
    return _Ink(first / pixelRatio - pad, last / pixelRatio - pad);
  }

  Future<void> _measure(
    Object key,
    TextPainter name,
    TextPainter place,
    double pixelRatio,
  ) async {
    try {
      final nameInk = await _inkOf(name, pixelRatio);
      final placeInk = await _inkOf(place, pixelRatio);
      if (!mounted || _measuredFor != key) return;
      if (nameInk != null && placeInk != null) {
        setState(() => _ink = (nameInk, placeInk));
      }
    } catch (error, stackTrace) {
      // The lines then line up by their text boxes instead, which is close.
      developer.log(
        'Could not measure the menu header letters',
        name: 'drawer_parish_name',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      name.dispose();
      place.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    // Measure with exactly the styles the Text widgets will draw with,
    // including what they take from the surrounding default style.
    final base = DefaultTextStyle.of(context).style;
    final nameStyle = base.merge(_nameStyle);
    final placeStyle = base.merge(_placeStyle).copyWith(letterSpacing: 0);

    final namePainter = _painter(DrawerParishName.name, nameStyle, scaler);
    final placePainter = _painter(DrawerParishName.place, placeStyle, scaler);
    final nameWidth = namePainter.width;
    final placeWidth = placePainter.width;

    final key = (nameStyle, placeStyle, scaler, pixelRatio);
    if (_measuredFor != key) {
      _measuredFor = key;
      _ink = null;
      unawaited(_measure(key, namePainter, placePainter, pixelRatio));
    } else {
      namePainter.dispose();
      placePainter.dispose();
    }

    // Until the letters are measured, line up the text boxes.
    final (nameInk, placeInk) =
        _ink ?? (_Ink(0, nameWidth), _Ink(0, placeWidth));
    // Spread MARSDEN PARK so its ink spans the name's ink: the extra width
    // goes in the gaps between letters (letter spacing is not enlarged by
    // the system text size), and the line is nudged so the M starts where
    // the S does.
    final gaps = DrawerParishName.place.length - 1;
    final nameSpan = nameInk.right - nameInk.left;
    final placeSpan = placeInk.right - placeInk.left;
    final spacing = ((nameSpan - placeSpan) / gaps).clamp(0.0, double.infinity);
    // Letter spacing is shared out half before and half after each
    // letter, so the M also moves in by half a gap; take that back.
    final shift = nameInk.left - placeInk.left - spacing / 2;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: SizedBox(
        width: nameWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DrawerParishName.name,
              maxLines: 1,
              softWrap: false,
              style: nameStyle,
            ),
            // The gold rule runs exactly under the letters.
            Container(
              height: 1.5,
              width: nameSpan,
              margin: EdgeInsets.only(left: nameInk.left, top: 6, bottom: 6),
              color: AppColors.gold,
            ),
            // Half a gap of letter spacing also follows the last letter;
            // let it hang past the edge rather than wrap.
            Transform.translate(
              offset: Offset(shift, 0),
              child: OverflowBox(
                alignment: AlignmentDirectional.centerStart,
                maxWidth: double.infinity,
                fit: OverflowBoxFit.deferToChild,
                child: Text(
                  DrawerParishName.place,
                  maxLines: 1,
                  softWrap: false,
                  style: placeStyle.copyWith(letterSpacing: spacing),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
