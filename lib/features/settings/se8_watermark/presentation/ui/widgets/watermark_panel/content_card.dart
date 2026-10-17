/// Module: settings/se8_watermark
///
///*************************** FILE INFO ****************************///
/// File Name: content_card.dart
/// Description: `_ContentCard` widget — split out of `watermark_panel.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../watermark_panel.dart';

// Split from watermark_panel.dart to keep every file under 700 lines.

// ── Watermark Content ───────────────────────────────────────────────────────

class _ContentCard extends StatelessWidget {
  final WatermarkSettings settings;

  const _ContentCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final WatermarkCubit cubit = context.read<WatermarkCubit>();

    String label(WatermarkField field) {
      switch (field) {
        case WatermarkField.employeeEmail:
          return l.employeeEmail;
        case WatermarkField.employeePhone:
          return l.employeePhone;
        case WatermarkField.employeeName:
          return l.employeeName;
      }
    }

    return _Card(
      title: l.watermarkContent,
      children: <Widget>[
        // FIXED 31/8/2026 (second pass) — the three chips were stacking one per
        // row instead of sitting side by side as Figma draws them.
        //
        // Cause: `_FieldChip` used `Container(alignment: Alignment.center)` with
        // no width. A Container with a non-null `alignment` and no size of its
        // own EXPANDS to `constraints.biggest`, and a Wrap hands its children
        // the full line width as a loose maximum — so every chip claimed the
        // whole row and only one fitted per line. The Wrap was innocent; the
        // Container was the greedy one.
        //
        // Back to a Row of `Expanded` cells, which is what Figma actually
        // shows: three equal-width chips across the card. That was the ORIGINAL
        // layout, and the reason it got replaced was ellipsis — so the fix for
        // that is inside `_FieldChip` (a scale-down instead of a truncation),
        // not a different layout out here.
        Row(
          children: <Widget>[
            for (final WatermarkField field
                in WatermarkField.values) ...<Widget>[
              if (field != WatermarkField.values.first)
                const SizedBox(width: 8),
              Expanded(
                child: _FieldChip(
                  label: label(field),
                  selected: settings.field == field,
                  onTap: () => cubit.selectField(field),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        // Wrap here too: "Display With" plus two labelled checkboxes overflows a
        // narrow card once the Arabic strings are in ("العرض مع", "التاريخ",
        // "الوقت" are all wider than the English).
        Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(
              l.displayWith,
              style: StyleText.fontSize16Weight500.copyWith(
                fontSize: _Type.rowLabel,
                color: AppColors.secondaryText,
              ),
            ),
            _CheckOption(
              label: l.date,
              checked: settings.showDate,
              onChanged: cubit.toggleDate,
            ),
            _CheckOption(
              label: l.time,
              checked: settings.showTime,
              onChanged: cubit.toggleTime,
            ),
          ],
        ),
      ],
    );
  }
}
