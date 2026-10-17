/// Module: settings/se8_watermark
///
///*************************** FILE INFO ****************************///
/// File Name: slider_row.dart
/// Description: `_SliderRow` widget — split out of `watermark_panel.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../watermark_panel.dart';

// Split from watermark_panel.dart to keep every file under 700 lines.

class _SliderRow extends StatelessWidget {
  final String label;
  final String value;
  final Slider slider;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.slider,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // CHANGED 31/8/2026 — dropped `maxLines: 1` +
              // `TextOverflow.ellipsis`. "Quantity (Density)" is the longest
              // label here and it truncated to "Quantity (Densi…" on a narrow
              // panel. It wraps now: the row grows by a line instead of hiding
              // which control the reader is looking at.
              Expanded(
                child: Text(
                  label,
                  style: StyleText.fontSize16Weight500.copyWith(
                    fontSize: _Type.rowLabel,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // The read-out chip Figma draws on the right of every row.
              Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  value,
                  style: StyleText.fontSize16Weight500.copyWith(
                    fontSize: _Type.readout,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
          // The stock Slider reserves a lot of vertical padding; the design's
          // rows are tight, so the track is squeezed back with a narrower theme
          // rather than by fighting the widget's own layout.
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: AppColors.primary,
              // CHANGED 2/9/2026 — the unfilled half of every slider was
              // `AppColors.card`, the same fill the read-out chip beside it
              // uses, so on the card the two ran together and the track's
              // remaining length was hard to judge. `AppColors.background` is
              // the page behind the card, so the empty part now reads as a
              // groove cut into the card rather than as another chip.
              inactiveTrackColor: AppColors.background,
              thumbColor: AppColors.primary,
              overlayShape: SliderComponentShape.noOverlay,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: SizedBox(height: 24, child: slider),
          ),
        ],
      ),
    );
  }
}
