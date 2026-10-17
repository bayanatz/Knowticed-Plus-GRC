/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_textfield.dart
/// Description: Declares `CustomTextField`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:flutter/material.dart';
import 'package:grc_module/core/custom/inputs/field_sizing.dart';
import 'package:grc_module/core/helper/localized_number.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

part 'custom_textfield/script_input_formatter.dart';
part 'custom_textfield/custom_text_field_logic.dart';
part 'custom_textfield/custom_text_field_builders.dart';

/// Custom text field widget — mirrors CustomDropdown API exactly.
///
/// Border rule: NO border by default; red border only when [errorText] is set.
///
/// Type-size rule (16/8/2026): the LABEL is always 14.sp and the HINT always
/// 12.sp. [labelStyle] and [hintStyle] still control colour, weight and the
/// rest — only the font size is fixed by the widget.
class CustomTextField extends StatefulWidget {
  // ── Controller / Focus ───────────────────────────────────────────────────

  /// Text editing controller. If null an internal one is created.
  final TextEditingController? controller;

  /// Focus node. If null an internal one is created.
  final FocusNode? focusNode;

  // ── Content ──────────────────────────────────────────────────────────────

  /// Initial value (only used when [controller] is null).
  final String? initialValue;

  /// Placeholder text.
  final String? hint;

  /// Label displayed above the field.
  final String? label;

  /// Error message — also triggers the red border.
  final String? errorText;

  /// ADDED 17/10/2026 (opt-in, from Qiyas's copy): a `Form` validator. When
  /// set, the field is wrapped in a [FormField] so an enclosing [Form] can
  /// validate it (`formKey.currentState!.validate()`); its message paints the
  /// same red border and re-checks as the user types. Null keeps the plain
  /// field every other caller has.
  final FormFieldValidator<String>? validator;

  /// Helper text displayed below the field.
  final String? helperText;

  // ── Icons ────────────────────────────────────────────────────────────────

  /// Widget shown at the start of the field.
  final Widget? prefixIcon;

  /// Widget shown at the end of the field (overrides the password-toggle eye).
  final Widget? suffixIcon;

  // ── Behaviour ────────────────────────────────────────────────────────────

  /// Whether the field is interactive.
  final bool enabled;

  /// Whether the field is read-only (tappable but not editable).
  final bool readOnly;

  /// Adds a red " *" to the label.
  final bool required;

  /// Hides text (password mode). Shows an eye-toggle unless [suffixIcon] is
  /// provided.
  final bool obscureText;

  /// The character shown for each hidden glyph while [obscureText] is on.
  /// Defaults to the Flutter default '•'; pass '*' for a star mask.
  final String obscuringCharacter;

  /// Maximum number of lines. 1 = single-line (default). null = unlimited.
  final int? maxLines;

  /// Minimum number of lines for multiline fields.
  final int? minLines;

  /// Hard character limit. Shows a counter when set.
  final int? maxLength;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Input formatters (e.g. digits-only).
  final List<TextInputFormatter>? inputFormatters;

  /// Text alignment inside the field.
  final TextAlign textAlign;

  /// Text direction (useful for RTL/LTR mixed content).
  final TextDirection? textDirection;

  /// Action button on the keyboard.
  final TextInputAction? textInputAction;

  /// Auto-capitalisation strategy.
  final TextCapitalization textCapitalization;

  /// Whether to enable autocorrect.
  final bool autocorrect;

  /// Whether to show text-suggestions.
  final bool enableSuggestions;

  // ── Callbacks ────────────────────────────────────────────────────────────

  /// Called on every keystroke.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (presses the keyboard action button).
  final ValueChanged<String>? onSubmitted;

  /// Called when the field gains or loses focus.
  final ValueChanged<bool>? onFocusChanged;

  /// Called when the field is tapped (useful when [readOnly] is true).
  final VoidCallback? onTap;

  // ── Appearance ───────────────────────────────────────────────────────────

  /// Background fill color.
  final Color? fillColor;

  /// ADDED 17/10/2026 (Moataz: the search "when I press on it gets a border
  /// … the secondary"): a border in this colour while the field has focus.
  /// Null keeps the house rule — no border unless there is an error.
  final Color? focusBorderColor;

  /// Border radius — defaults to 8.r internally.
  final BorderRadius? borderRadius;

  /// Padding inside the field container.
  final EdgeInsetsGeometry? contentPadding;

  // ── Text styles ──────────────────────────────────────────────────────────

  final TextStyle? valueStyle;

  /// Hint style. Its font SIZE is ignored — the hint is always 12.sp,
  /// unless [hintFontSize] is given.
  final TextStyle? hintStyle;

  /// Optional override for the hint's font size (in `.sp`). Defaults to 12.sp
  /// to preserve the app-wide rule; pass e.g. 16 for a field that needs a
  /// larger placeholder (the User-Management search box).
  final double? hintFontSize;

  /// Label style. Its font SIZE is ignored — the label is always 14.sp.
  final TextStyle? labelStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;
  final TextStyle? counterStyle;

  // ── Sizing (optional fixed box) ────────────────────────────────────────────

  /// Fixed width (interpreted in .sp). Null → expands to parent.
  final double? width;

  /// Fixed height (interpreted in .sp). Null → sizes to content.
  final double? height;

  // ── Built-in validation (opt-in) ───────────────────────────────────────────

  /// When true, an empty field shows a "required" error (use after a submit
  /// attempt). Only takes effect together with the other validation flags.
  final bool submitted;

  /// Restricts input to digits and validates the value is numeric.
  final bool onlyDigits;

  /// Restricts input to the script implied by [textDirection]
  /// (Arabic for RTL, English otherwise) and validates accordingly.
  final bool restrictByDirection;

  /// Auto-capitalises the first letter of each word (LTR, non-digit only).
  final bool autoCapitalize;

  /// Shows a character counter even when [maxLength] is null (limit = 500).
  final bool showCharCount;

  /// Suppress the counter WITHOUT giving up the character limit.
  ///
  /// ADDED 2/9/2026. [_showCounter] treats any [maxLength] as "show a
  /// counter", so a field that just wants a hard cap — the group name, capped
  /// at 100 — had no way to keep the cap and lose the "0 / 100" line. Passing
  /// `showCharCount: false` did nothing, because maxLength alone was enough.
  ///
  /// Defaults to false, so every existing field keeps the counter it has.
  final bool hideCounter;

  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.hint,
    this.label,
    this.errorText,
    this.validator,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChanged,
    this.onTap,
    this.fillColor,
    this.focusBorderColor,
    this.borderRadius,
    this.contentPadding,
    this.valueStyle,
    this.hintStyle,
    this.hintFontSize,
    this.labelStyle,
    this.errorStyle,
    this.helperStyle,
    this.counterStyle,
    this.width,
    this.height,
    this.submitted = false,
    this.onlyDigits = false,
    this.restrictByDirection = false,
    this.autoCapitalize = false,
    this.showCharCount = false,
    this.hideCounter = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  /// Lets this screen's builder/logic extensions refresh it (setState
  /// itself may only be called inside the State class).
  void rebuild(VoidCallback fn) => setState(fn);

  // Set only when [CustomTextField.validator] is supplied — lets the text
  // listener push edits into the FormField so autovalidation re-runs.
  FormFieldState<String>? _formField;

  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  bool _obscured = true; // tracks password visibility toggle

  // Live character count (only needed when maxLength is set)
  int _charCount = 0;

  @override
  void initState() {
    super.initState();

    // Controller
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.initialValue);
      _ownsController = true;
    }

    // Focus node
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }

    _focusNode.addListener(_onFocusChange);

    if (_needsTextListener) {
      _charCount = _controller.text.length;
      _controller.addListener(_onTextChange);
    }
  }

  /// Adopts a controller or focus node the parent swapped underneath us.
  /// ADDED 16/8/2026.
  ///
  /// THE BUG THIS FIXES
  /// ------------------
  /// [initState] read `widget.controller` once and the state never looked at it
  /// again, so a parent that handed this field a DIFFERENT controller on a
  /// later build kept talking to the first one. When the parent then disposed
  /// that first controller — the normal thing to do with a controller you have
  /// replaced — the next rebuild threw:
  ///
  ///     A TextEditingController was used after being disposed.
  ///
  /// from `TextField`'s own `didUpdateWidget`, because the field was still
  /// wired to the dead object. `create_table_page` hits this every time its
  /// column list is replaced: it builds fresh controllers per column id and
  /// disposes the old ones after the frame.
  ///
  /// A `State` that caches anything out of its widget owes it a
  /// `didUpdateWidget`. This is that debt paid.
  ///
  /// ORDER MATTERS: the listener comes off the OLD object before the new one is
  /// adopted, and the old one is disposed only if WE made it. `removeListener`
  /// is documented as safe on an already-disposed notifier, which is what makes
  /// the parent-disposes-first ordering survivable; `addListener` is not, so it
  /// only ever touches the new one.
  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      final TextEditingController previous = _controller;
      final bool previousWasOurs = _ownsController;

      previous.removeListener(_onTextChange);

      if (widget.controller != null) {
        _controller = widget.controller!;
        _ownsController = false;
      } else {
        // The parent stopped supplying one. Keep the text on screen rather than
        // blanking the field — `.text` is a plain getter and stays readable on
        // a disposed controller, so this is safe even in the ordering above.
        _controller = TextEditingController(text: previous.text);
        _ownsController = true;
      }

      if (_needsTextListener) {
        _charCount = _controller.text.length;
        _controller.addListener(_onTextChange);
      }

      // Ours to dispose only if we created it. An external controller belongs
      // to the parent and disposing it here would break the caller's next use.
      if (previousWasOurs) previous.dispose();
    } else if (_needsTextListener != _neededTextListener(oldWidget)) {
      // Same controller, but the field just gained or lost its counter /
      // validation, which is what decides whether the listener is wanted.
      if (_needsTextListener) {
        _charCount = _controller.text.length;
        _controller.addListener(_onTextChange);
      } else {
        _controller.removeListener(_onTextChange);
      }
    }

    if (widget.focusNode != oldWidget.focusNode) {
      final FocusNode previous = _focusNode;
      final bool previousWasOurs = _ownsFocusNode;

      previous.removeListener(_onFocusChange);

      if (widget.focusNode != null) {
        _focusNode = widget.focusNode!;
        _ownsFocusNode = false;
      } else {
        _focusNode = FocusNode();
        _ownsFocusNode = true;
      }

      _focusNode.addListener(_onFocusChange);
      if (previousWasOurs) previous.dispose();
    }
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {}); // rebuild so suffix eye-icon tint can update if needed
    widget.onFocusChanged?.call(_focusNode.hasFocus);
  }

  void _onTextChange() {
    if (!mounted) return;
    setState(() => _charCount = _controller.text.length);
    _formField?.didChange(_controller.text);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    // UNCONDITIONAL (16/8/2026), was gated on `_needsTextListener`. That getter
    // reads the CURRENT widget, so a field that had a counter when the listener
    // was attached and lost it before disposal left the listener behind on a
    // controller the parent goes on using. `removeListener` is a no-op when
    // there is nothing to remove, and is safe on a disposed notifier.
    _controller.removeListener(_onTextChange);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No validator → plain field, unchanged behaviour.
    if (widget.validator == null) return _buildView(context);
    return FormField<String>(
      validator: (_) => widget.validator!(_controller.text),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (FormFieldState<String> state) {
        _formField = state;
        return _buildView(context);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private input formatters (self-contained — no external dependencies)
// ─────────────────────────────────────────────────────────────────────────────

/// Blocks English letters (used for Arabic/RTL fields).
class _ArabicOnlyInputFormatter extends _ScriptInputFormatter {
  _ArabicOnlyInputFormatter() : super(RegExp(r'[a-zA-Z]'));
}

/// Blocks Arabic characters (used for English/LTR fields).
class _EnglishOnlyInputFormatter extends _ScriptInputFormatter {
  _EnglishOnlyInputFormatter() : super(RegExp(r'[؀-ۿ]'));
}

// ─────────────────────────────────────────────────────────────────────────────
// Usage examples
// ─────────────────────────────────────────────────────────────────────────────

/*
// ── Simple text ──────────────────────────────────────────────────────────────
CustomTextField(
  label: 'Full Name',
  hint: 'Enter your name',
  required: true,
  prefixIcon: Icon(Icons.person_outline, size: 18.sp),
  onChanged: (v) {},
)

// ── Password ─────────────────────────────────────────────────────────────────
CustomTextField(
  label: 'Password',
  hint: 'Enter password',
  required: true,
  obscureText: true,
  textInputAction: TextInputAction.done,
)

// ── Multiline ────────────────────────────────────────────────────────────────
CustomTextField(
  label: 'Notes',
  hint: 'Write something…',
  maxLines: 5,
  minLines: 3,
  maxLength: 500,
  helperText: 'Max 500 characters',
)

// ── Read-only ────────────────────────────────────────────────────────────────
CustomTextField(
  label: 'Email',
  controller: TextEditingController(text: 'amr@example.com'),
  readOnly: true,
  prefixIcon: Icon(Icons.email_outlined, size: 18.sp),
)

// ── Digits only ──────────────────────────────────────────────────────────────
CustomTextField(
  label: 'Phone',
  hint: '05xxxxxxxx',
  keyboardType: TextInputType.phone,
  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  maxLength: 10,
)

// ── Error state ──────────────────────────────────────────────────────────────
CustomTextField(
  label: 'Username',
  errorText: 'Username is already taken',
)

// ── Disabled ─────────────────────────────────────────────────────────────────
CustomTextField(
  label: 'Role',
  controller: TextEditingController(text: 'Admin'),
  enabled: false,
)
*/
