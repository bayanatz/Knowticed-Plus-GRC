/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: custom_text_field_logic.dart
/// Description: Logic and event handlers of `_CustomTextFieldState` — split out of `2-custom_textfield.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_textfield.dart';

// Split from 2-custom_textfield.dart to keep every file under 700 lines.

extension _CustomTextFieldStateLogic on _CustomTextFieldState {
  /// [_needsTextListener] evaluated against a PREVIOUS widget, so
  /// [didUpdateWidget] can tell whether the answer changed.
  bool _neededTextListener(CustomTextField old) =>
      old.showCharCount ||
      old.maxLength != null ||
      old.submitted ||
      old.onlyDigits ||
      old.restrictByDirection ||
      old.obscureText ||
      old.validator != null;

  bool get _isMultiline =>
      (widget.maxLines ?? 1) != 1 || widget.minLines != null;

  /// Whether the input should STRETCH to fill the fixed box instead of sizing
  /// itself to its line count.
  ///
  /// FIXED 22/8/2026 — this is the "space between the field and the counter"
  /// bug. The field is wrapped in `SizedBox(height: …)`, but a `TextField` does
  /// not fill a tight height: `InputDecorator` lays its container out at the
  /// height its CONTENT needs and only the RenderBox is stretched to the
  /// constraint. The filled background is painted over `containerHeight`, so
  /// when the box is taller than seven lines of text the remainder is
  /// transparent dead space — invisible, but still occupying layout, which is
  /// exactly the gap that pushed `158 / 500` away from the bottom of the box.
  ///
  /// `expands: true` makes the input take the full height it is given, so the
  /// painted box ends where the SizedBox ends and the counter sits right under
  /// it. It requires `maxLines` and `minLines` to both be null, hence the
  /// overrides below; the character limit is enforced by `maxLength`, not by
  /// the line count, so nothing is lost.
  ///
  /// Single-line fields are deliberately excluded: `expands` would let them
  /// accept newlines.
  /// The box height: the screen's, else 36 for a single-line field (D-18).
  double? get _height =>
      widget.height ?? (_isMultiline ? null : FieldSizing.height);

  bool get _fillsHeight => widget.height != null && _isMultiline;

  /// ADDED 16/9/2026 — a single-line field with a fixed [height] PAINTS that
  /// height. Without this the SizedBox was the given height but the filled
  /// box (InputDecorator's container) was only as tall as its content, so a
  /// `height: 38` field and a `height: 38` [CustomDropdown] side by side drew
  /// two different boxes. InputDecorator makes its container at least as
  /// tall as the suffix icon, so the suffix slot is pinned to [height]
  /// (see the decoration below); with no suffix of its own, a 12.sp spacer
  /// takes the slot, the same space the end padding gave.
  ///
  /// CHANGED 21/9/2026 — password fields are pinned too. They used to be
  /// excluded, so a `height: 36` password field kept 10.sp vertical padding,
  /// no centred suffix slot, and its mask sat off-centre next to the pinned
  /// email field above it. `obscureText` already forces `maxLines: 1`, and
  /// the eye toggle takes the pinned suffix slot like any other suffix.
  bool get _pinsHeight => _height != null && !_isMultiline;

  // ── Opt-in helpers ─────────────────────────────────────────────────────────

  /// Effective character limit: explicit [maxLength], else 500 when a counter
  /// is requested, else none.
  int? get _effectiveMaxLength =>
      widget.maxLength ?? (widget.showCharCount ? 500 : null);

  bool get _showCounter =>
      !widget.hideCounter && (widget.showCharCount || widget.maxLength != null);

  /// Locale whose numerals the character counter uses.
  ///
  /// Keyed off the field's own [CustomTextField.textDirection] so a bilingual
  /// form counts each side in its own script, falling back to the active
  /// locale when the field does not state a direction.
  String _counterLocale(BuildContext context) {
    switch (widget.textDirection) {
      case TextDirection.rtl:
        return 'ar';
      case TextDirection.ltr:
        return 'en';
      case null:
        return Localizations.localeOf(context).languageCode;
    }
  }

  bool get _hasValidation =>
      widget.submitted || widget.onlyDigits || widget.restrictByDirection;

  // `obscureText` added 21/9/2026: the mask nudge below depends on whether
  // the field is empty, so it has to rebuild as the user types.
  bool get _needsTextListener =>
      _showCounter ||
      _hasValidation ||
      widget.obscureText ||
      widget.validator != null;

  /// Resolves the error to display: explicit [errorText] wins, otherwise the
  /// built-in validation (only active when a validation flag is set).
  String? get _resolvedError {
    final explicit = widget.errorText;
    if (explicit != null && explicit.isNotEmpty) return explicit;
    if (!_hasValidation) return null;

    final text = _controller.text;
    final isEmpty = text.trim().isEmpty;
    final isRtl = widget.textDirection == TextDirection.rtl;
    final hasArabic = RegExp(r'[؀-ۿ]').hasMatch(text);

    if (widget.submitted && isEmpty) {
      return isRtl ? 'هذا الحقل مطلوب' : 'This field is required.';
    }
    if (!isEmpty && widget.restrictByDirection) {
      if (!isRtl && hasArabic) return 'Please use English characters only.';

      // FIXED 26/8/2026 — the RTL branch used to be a WHITELIST:
      //
      //     if (isRtl && !RegExp(r'^[؀-ۿ\s]+$').hasMatch(text))
      //
      // which demanded the whole value be Arabic letters and whitespace and
      // nothing else. That rejected every ASCII punctuation mark a real
      // sentence needs — `.` `,` `(` `)` `"` `'` `:` `;` — and Latin digits
      // with them, so an ordinary Arabic service description like
      // "…وتحديد السجلات الناقصة." was marked invalid over its own full stop.
      // Arabic punctuation passed only by accident: `،` `؛` `؟` sit inside the
      // 0600–06FF block, so the whitelist admitted them while refusing their
      // ASCII equivalents — the same mark, accepted or rejected depending on
      // which keyboard produced it.
      //
      // It also disagreed with the rule actually being ENFORCED.
      // [_ArabicOnlyInputFormatter] blocks `[a-zA-Z]` and nothing else, so the
      // formatter let the user type a full stop and the validator then failed
      // the field for containing it: two different definitions of "Arabic
      // only" in one widget, and the stricter one had no formatter behind it
      // to stop the input in the first place.
      //
      // Now a BLACKLIST, mirroring both the formatter and the LTR branch
      // directly above. The field objects to the foreign SCRIPT — which is
      // what its message says — and stays out of the way of punctuation,
      // numbers and symbols.
      if (isRtl && RegExp(r'[a-zA-Z]').hasMatch(text)) {
        return 'الرجاء استخدام الأحرف العربية فقط.';
      }
    }
    if (widget.onlyDigits &&
        text.isNotEmpty &&
        !RegExp(r'^\d+$').hasMatch(text)) {
      return 'Only numbers are allowed.';
    }
    return null;
  }

  /// Builds input formatters from the opt-in flags, then appends any caller
  /// supplied [inputFormatters].
  List<TextInputFormatter>? get _resolvedFormatters {
    final list = <TextInputFormatter>[];
    if (widget.autoCapitalize &&
        widget.textDirection != TextDirection.rtl &&
        !widget.onlyDigits) {
      list.add(_CapitalizeTextFormatter());
    }
    if (widget.restrictByDirection) {
      if (widget.textDirection == TextDirection.rtl) {
        list.add(_ArabicOnlyInputFormatter());
      } else if (!widget.onlyDigits) {
        list.add(_EnglishOnlyInputFormatter());
      }
    }
    if (widget.onlyDigits) {
      list.add(FilteringTextInputFormatter.digitsOnly);
    }
    if (widget.inputFormatters != null) list.addAll(widget.inputFormatters!);
    return list.isEmpty ? null : list;
  }

  // Effective obscure: only applies when the prop is true AND not multiline
  bool get _effectiveObscure =>
      widget.obscureText && !_isMultiline && _obscured;
}
