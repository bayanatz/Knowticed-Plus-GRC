/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: custom_dropdown.dart
/// Description: `CustomDropdown` widget — split out of `1-custom_dropdown.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_dropdown.dart';

// Split from 1-custom_dropdown.dart to keep every file under 700 lines.

/// Custom dropdown widget
class CustomDropdown<T> extends StatefulWidget {
  final T? value;
  final List<DropdownItem<T>> items;
  final ValueChanged<T>? onChanged;
  final String? hint;
  final String? label;
  final String? errorText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool required;
  final Color? fillColor;

  /// Optional override for the hint text AND the chevron colour.
  ///
  /// ADDED 11/10/2026. By default both follow the app-wide rule
  /// ([kDropdownHintColor] / [kDropdownTrailingIconColor]). A dropdown that
  /// sits in a toolbar beside another control (e.g. Approvals' Department
  /// dropdown next to the Filter button) can pass that control's colour so the
  /// two read as one row. Null keeps the default — no existing dropdown changes.
  final Color? accentColor;
  final double? maxOverlayHeight;
  final EdgeInsetsGeometry? triggerPadding;

  /// Fixed height for the TRIGGER, or null to let it size itself. ADDED
  /// 17/8/2026; every existing dropdown leaves it null and is unaffected.
  ///
  /// INTERPRETED IN `.sp` and scaled here — pass the raw design number (`36`),
  /// not `36.sp`, exactly as `CustomTextField.height` documents. A pre-scaled
  /// value would be scaled twice.
  ///
  /// It sizes the TRIGGER only, never the label or the error line: a dropdown
  /// with a label is a Column of three pieces, and pinning the whole Column
  /// would squeeze the label instead of the box.
  ///
  /// Prefer this over [triggerPadding] when the box has to match something of
  /// a known height — a 46pt table row, a field beside it. `contentPadding`
  /// pads the input AREA, not the trigger (see `CustomSortButton`), so padding
  /// is the wrong lever for a target height.
  final double? height;

  /// Gap between the label and the field, overriding [kFieldLabelGap].
  ///
  /// ADDED 8/9/2026. [kFieldLabelGap] is 6 and is deliberately shared so that a
  /// row of fields lines up — see its own doc. This exists for a screen that
  /// asked for a tighter label, and it defaults to the constant, so every
  /// existing caller is unchanged and the app-wide rule still holds for
  /// anything that does not opt out.
  final double? labelGap;

  /// Whether the suffix slot is BUILT AT ALL. ADDED 16/8/2026.
  ///
  /// Passing `suffixIcon: SizedBox(width: 0)` was not enough to get rid of it:
  /// the slot was still created, still wrapped in its `Padding`, and — because
  /// `InputDecorator` lays the suffix out after the input area — it kept that
  /// area alive on the right of the trigger. On a form field that is invisible;
  /// on `CustomSortButton`, a 100.sp button with no chevron, it read as a hole
  /// after the label.
  ///
  /// False builds no suffix at all, so the trigger ends at the prefix.
  /// Defaults to true, so every existing dropdown keeps its chevron.
  final bool showSuffixIcon;

  /// Padding around [prefixIcon] / [suffixIcon] inside the trigger.
  ///
  /// ADDED 16/8/2026. These used to be hardcoded at 12/8 and 8/12, which is
  /// right for a full-width form field and far too generous for a compact
  /// toolbar button: on a 100.sp sort button the two of them plus the icon ate
  /// everything but ~20pt, so the label rendered as "Sor". Left null they keep
  /// the original values, so every existing form field is untouched.
  final EdgeInsetsGeometry? prefixIconPadding;
  final EdgeInsetsGeometry? suffixIconPadding;

  /// Whether the 14.sp label / 12.sp hint rule is applied. ADDED 16/8/2026.
  ///
  /// True for every FORM dropdown, which is what the rule is about: a dropdown
  /// sits beside a `CustomTextField` in every form in the app, so the two have
  /// to agree about how big a title and a placeholder are.
  ///
  /// `CustomSortButton` sets it false. It is not a form field — it is a toolbar
  /// button that happens to be built from this widget, its "hint" is the button
  /// LABEL, and next to the 14.sp Filter button beside it a 12.sp "Sort" would
  /// just look like a mistake.
  final bool enforceTypeScale;

  /// Keeps [hint] on the trigger even after something is selected, instead of
  /// swapping it for the selected item's label. ADDED 16/8/2026.
  ///
  /// For a form field the selected value IS the answer, so replacing the hint
  /// with it is right. For an ACTION button — Sort — the label names what the
  /// button does, and swapping it for "Last Updated" leaves a control on the
  /// toolbar that no longer says what it is. The selection is still shown, both
  /// by the highlighted row in the menu and by the button's own fill; it just
  /// is not shown by overwriting the label.
  ///
  /// Defaults to false, so every existing dropdown behaves exactly as before.
  final bool alwaysShowHint;

  /// Corner radius for both the trigger and the open overlay.
  ///
  /// Optional — when null it defaults to `BorderRadius.circular(4.r)`, so every
  /// existing dropdown keeps its current look. Pass a value to override (e.g.
  /// `BorderRadius.circular(8.r)`).
  final BorderRadius? borderRadius;
  final TextStyle? valueStyle;

  /// Size / weight / family of the placeholder.
  ///
  /// The COLOUR is not taken from here — it is always [kDropdownHintColor].
  final TextStyle? hintStyle;
  final TextStyle? itemStyle;
  final TextStyle? labelStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;
  final double? itemHeight;
  final double overlayElevation;
  final double? overlayOffset;
  final bool showDivider;
  final Color? dividerColor;
  final Widget? emptyWidget;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  const CustomDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.hint,
    this.label,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.required = false,
    this.fillColor,
    this.accentColor,
    this.maxOverlayHeight,
    this.triggerPadding,
    this.height,
    this.labelGap,
    this.prefixIconPadding,
    this.suffixIconPadding,
    this.showSuffixIcon = true,
    this.enforceTypeScale = true,
    this.alwaysShowHint = false,
    this.borderRadius,
    this.valueStyle,
    this.hintStyle,
    this.itemStyle,
    this.labelStyle,
    this.errorStyle,
    this.helperStyle,
    this.itemHeight,
    this.overlayElevation = 4,
    this.overlayOffset,
    this.showDivider = false,
    this.dividerColor,
    this.emptyWidget,
    this.onOpen,
    this.onClose,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}
