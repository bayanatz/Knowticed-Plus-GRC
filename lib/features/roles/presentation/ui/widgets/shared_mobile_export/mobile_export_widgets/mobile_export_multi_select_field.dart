/// Module: roles/shared_mobile_export
///
///*************************** FILE INFO ****************************///
/// File Name: mobile_export_multi_select_field.dart
/// Description: `MobileExportMultiSelectField` widget — split out of `mobile_export_widgets.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../mobile_export_widgets.dart';

// Split from mobile_export_widgets.dart to keep every file under 700 lines.

/// The multi-select twin of [MobileExportDropdownField].
///
/// ADDED 10/9/2026. Some of the export form's fields name a SET, not a value —
/// "Column To Export" above all, whose Arabic label has always been the plural
/// "الأعمدة المراد تصديرها". A single-value dropdown there let the admin ask
/// for exactly one column or for all twelve and for nothing in between, so the
/// three columns they actually wanted were not expressible.
///
/// `CustomMultiSelectFilter` is the app's multi-select — it mirrors
/// `CustomDropdown` in look and behaviour, ticks each row with `CustomCheckBox`
/// and keeps the overlay open while picking. This wrapper adds exactly the same
/// Figma geometry [MobileExportDropdownField] adds and nothing else, so the two
/// field kinds are indistinguishable until the overlay opens.
///
/// THE TRIGGER ALWAYS SHOWS THE HINT (10/9/2026)
/// `alwaysShowHint: true` — the box keeps saying "Select Country" however many
/// countries are ticked, and the ticks in the overlay are the read-back. The
/// default comma-joined preview is wrong for a 36-tall box: it says the field's
/// name and its answer in the same 315 points, so the second pick ellipsises it
/// into "France, Ger…" and the field stops naming what it is for.
///
/// THE BOX MEASURES 36 AND CENTRES ITS HINT, LIKE ITS SINGLE-VALUE TWIN
/// `CustomMultiSelectFilter` applies `height` to the decorator's CHILD by
/// default, where `CustomDropdown` wraps the whole decorator. That difference
/// cost two things: the same 9/7 padding drew a 36 box next to a 50 one,
/// because a vertical inset is ADDED to a sized child rather than absorbed by
/// it; and a 36-tall child has no text in it to take a baseline from, so
/// `InputDecorator` baseline-aligned `hintText` to the child's bottom edge and
/// the placeholder sat ON the bottom border.
///
/// `heightSizesWholeTrigger: true` puts it on `CustomDropdown`'s footing —
/// the box is clamped from outside, the child keeps its natural height, and the
/// hint is centred. Everything below is then byte-identical to
/// [MobileExportDropdownField], which is the point: the two field kinds must
/// measure and read alike sitting one above the other.
class MobileExportMultiSelectField extends StatelessWidget {
  const MobileExportMultiSelectField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.values,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final String hint;
  final List<MultiSelectDropdownItem<String>> items;

  /// The current picks. Empty is a legal, meaningful state — each caller says
  /// what it means; for Column To Export it means "every column".
  final List<String> values;

  /// Fires with the WHOLE new selection, not with the item that changed.
  final ValueChanged<List<String>> onChanged;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return CustomMultiSelectFilter<String>(
      label: label,
      hint: hint,
      items: items,
      values: values,
      enabled: enabled,
      onChanged: onChanged,
      alwaysShowHint: true,
      // `CustomMultiSelectFilter` is the one field in the app that never came
      // onto `kDropdownHintColor` — it defaults to `text` at 40% where every
      // other field uses `secondaryText` at 50%. That was invisible while the
      // hint disappeared on the first pick; with [alwaysShowHint] the hint IS
      // the field's permanent face, and these boxes sit directly under the two
      // date calendars, which do use the shared grey.
      hintStyle:
          StyleText.fontSize12Weight400.copyWith(color: kDropdownHintColor),
      height: MobileExportMetrics.fieldHeight,
      heightSizesWholeTrigger: true,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(MobileExportMetrics.fieldRadius.r),
      triggerPadding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
    );
  }
}
