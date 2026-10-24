/// Module: settings/se8_watermark
///
///*************************** FILE INFO ****************************///
/// File Name: style_card.dart
/// Description: `_StyleCard` widget — split out of `watermark_panel.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../watermark_panel.dart';

// Split from watermark_panel.dart to keep every file under 700 lines.

// ── Watermark Style ─────────────────────────────────────────────────────────

class _StyleCard extends StatelessWidget {
  final WatermarkSettings settings;

  /// Large horizontal view: sliders two per row, Style + Text Colour on one
  /// row, so the left column fits without scrolling.
  final bool compact;

  const _StyleCard({required this.settings, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final WatermarkCubit cubit = context.read<WatermarkCubit>();

    // ADDED 31/8/2026 — the Text / Bubble pair Figma opens this card with.
    // It had no field behind it before, so it could not be drawn at all.
    final Widget styleRow = Wrap(
      spacing: 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          l.watermarkStyleLabel,
          style: StyleText.fontSize16Weight500.copyWith(
            fontSize: _Type.rowLabel,
            color: AppColors.secondaryText,
          ),
        ),
        for (final WatermarkStyleMode mode in WatermarkStyleMode.values)
          _RadioOption(
            label: mode == WatermarkStyleMode.text
                ? l.watermarkStyleText
                : l.watermarkStyleBubble,
            selected: settings.styleMode == mode,
            onTap: () => cubit.setStyleMode(mode),
          ),
      ],
    );

    final Widget opacity = _SliderRow(
      label: l.opacity,
      // Localised numerals, like every other figure in the app.
      value:
          '${LocalizedNumber.of(context, (settings.opacity * 100).round())}%',
      slider: Slider(
        value: settings.opacity,
        min: WatermarkSettings.minOpacity,
        max: WatermarkSettings.maxOpacity,
        // Whole percents. Without divisions the slider hands back the raw
        // double and the read-out chip showed things like "23.836 px" — a
        // precision the control does not actually offer.
        divisions: 95,
        onChanged: cubit.setOpacity,
      ),
    );

    final Widget density = _SliderRow(
      label: l.quantityDensity,
      value: LocalizedNumber.of(context, settings.density),
      slider: Slider(
        value: settings.density.toDouble(),
        min: WatermarkSettings.minDensity.toDouble(),
        max: WatermarkSettings.maxDensity.toDouble(),
        divisions: WatermarkSettings.maxDensity - WatermarkSettings.minDensity,
        onChanged: (double v) => cubit.setDensity(v.round()),
      ),
    );

    final Widget size = _SliderRow(
      label: l.size,
      // Figma reads "12.0 px"; `LocalizedNumber` drops a trailing .0, so
      // this renders "12 px" / "١٢ بكسل". Keeping the numeral localised
      // matters more here than the trailing zero.
      value:
          '${LocalizedNumber.of(context, settings.fontSize.round())} ${l.px}',
      slider: Slider(
        value: settings.fontSize,
        min: WatermarkSettings.minFontSize,
        max: WatermarkSettings.maxFontSize,
        divisions:
            (WatermarkSettings.maxFontSize - WatermarkSettings.minFontSize)
                .round(),
        onChanged: cubit.setFontSize,
      ),
    );

    final Widget angle = _SliderRow(
      label: l.angle,
      value: '${LocalizedNumber.of(context, settings.angle.round())}°',
      slider: Slider(
        value: settings.angle,
        min: WatermarkSettings.minAngle,
        max: WatermarkSettings.maxAngle,
        divisions:
            (WatermarkSettings.maxAngle - WatermarkSettings.minAngle).round(),
        onChanged: cubit.setAngle,
      ),
    );

    final Widget color =
        _ColorRow(color: settings.color, onChanged: cubit.setColor);

    if (compact) {
      // Owner 21/10/2026: large view — 2 sliders per row (4 rows -> 2) and Style beside Text Colour, so the left column never scrolls.
      Widget pair(Widget a, Widget b) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: a),
              const SizedBox(width: 16),
              Expanded(child: b),
            ],
          );
      return _Card(
        title: l.watermarkStyle,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Padding(
                  // Centres the 20-high radios on the 40-high colour field.
                  padding: const EdgeInsets.only(bottom: 10),
                  child: styleRow,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: color),
            ],
          ),
          const SizedBox(height: 8),
          pair(opacity, density),
          pair(size, angle),
        ],
      );
    }

    return _Card(
      title: l.watermarkStyle,
      children: <Widget>[
        styleRow,
        // Owner 21/10/2026: 12 -> 8 so the left column fits without scrolling.
        const SizedBox(height: 8),
        opacity,
        density,
        size,
        angle,
        color,
      ],
    );
  }
}
