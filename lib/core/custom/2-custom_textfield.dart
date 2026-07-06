import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';

/// Custom text field widget — mirrors CustomDropdown API exactly.
///
/// Border rule: NO border by default; red border only when [errorText] is set.
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

  /// Border radius — defaults to 8.r internally.
  final BorderRadius? borderRadius;

  /// Padding inside the field container.
  final EdgeInsetsGeometry? contentPadding;

  // ── Text styles ──────────────────────────────────────────────────────────

  final TextStyle? valueStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;
  final TextStyle? counterStyle;

  // ── Sizing (optional fixed box) ────────────────────────────────────────────

  /// Fixed width (interpreted in .w). Null → expands to parent.
  final double? width;

  /// Fixed height (interpreted in .h). Null → sizes to content.
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

  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.hint,
    this.label,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.obscureText = false,
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
    this.borderRadius,
    this.contentPadding,
    this.valueStyle,
    this.hintStyle,
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
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
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

  void _onFocusChange() {
    setState(() {}); // rebuild so suffix eye-icon tint can update if needed
    widget.onFocusChanged?.call(_focusNode.hasFocus);
  }

  void _onTextChange() {
    if (!mounted) return;
    setState(() => _charCount = _controller.text.length);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    if (_needsTextListener) _controller.removeListener(_onTextChange);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  bool get _isMultiline => (widget.maxLines ?? 1) != 1 || widget.minLines != null;

  // ── Opt-in helpers ─────────────────────────────────────────────────────────

  /// Effective character limit: explicit [maxLength], else 500 when a counter
  /// is requested, else none.
  int? get _effectiveMaxLength =>
      widget.maxLength ?? (widget.showCharCount ? 500 : null);

  bool get _showCounter => widget.showCharCount || widget.maxLength != null;

  bool get _hasValidation =>
      widget.submitted || widget.onlyDigits || widget.restrictByDirection;

  bool get _needsTextListener => _showCounter || _hasValidation;

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
      if (isRtl && !RegExp(r'^[؀-ۿ\s]+$').hasMatch(text)) {
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

  @override
  Widget build(BuildContext context) {
    final resolvedError = _resolvedError;
    final hasError = resolvedError != null && resolvedError.isNotEmpty;
    final radius = widget.borderRadius ?? BorderRadius.circular(4.r);
    final isDisabled = !widget.enabled;

    // ── Suffix icon resolution ─────────────────────────────────────────────
    // Priority: explicit suffixIcon > password-toggle eye > nothing
    Widget? resolvedSuffix = widget.suffixIcon;
    if (resolvedSuffix == null && widget.obscureText && !_isMultiline) {
      resolvedSuffix = GestureDetector(
        onTap: () => setState(() => _obscured = !_obscured),
        child: Icon(
          _obscured
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20.sp,
          color: hasError
              ? AppColors.red
              : isDisabled
              ? AppColors.text.withOpacity(0.3)
              : AppColors.text.withOpacity(0.5),
        ),
      );
    }

    // ── Content padding ────────────────────────────────────────────────────
    final effectivePadding = widget.contentPadding ??
        EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ──────────────────────────────────────────────────────────
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label,
              style: widget.labelStyle ??
                  StyleText.fontSize14Weight500.copyWith(
                    color: hasError
                        ? AppColors.red
                        : isDisabled
                        ? AppColors.text.withOpacity(0.4)
                        : AppColors.text,
                  ),
              children: widget.required
                  ? [
                TextSpan(
                  text: '',
                  style: StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
                ),
              ]
                  : [],
            ),
          ),
          SizedBox(height: 6.h),
        ],

        // ── Field ──────────────────────────────────────────────────────────
        SizedBox(
          width: widget.width?.w,
          height: widget.height?.h,
          child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          obscureText: _effectiveObscure,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: _effectiveMaxLength,
          keyboardType: _isMultiline
              ? TextInputType.multiline
              : (widget.keyboardType ??
                  (widget.onlyDigits ? TextInputType.number : null)),
          inputFormatters: _resolvedFormatters,
          textAlign: widget.textAlign,
          textDirection: widget.textDirection,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          style: widget.valueStyle ??
              StyleText.fontSize14Weight400.copyWith(
                color: isDisabled
                    ? AppColors.text.withOpacity(0.4)
                    : AppColors.text,
              ),
          // Hide the built-in counter — we render our own below
          buildCounter: _effectiveMaxLength != null
              ? (_, {required currentLength, required isFocused, maxLength}) =>
          const SizedBox.shrink()
              : null,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: effectivePadding,
            filled: true,
            // No hover overlay tint on desktop/web
            hoverColor: Colors.transparent,
            fillColor: isDisabled
                ? (widget.fillColor ?? AppColors.card).withOpacity(0.5)
                : widget.fillColor ?? AppColors.card,

            // ── No border rule ────────────────────────────────────────────
            // Default / focused / disabled → no border at all.
            // Error → red border.
            border: hasError
                ? OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: AppColors.red, width: 1.5.w),
            )
                : OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide.none,
            ),
            enabledBorder: hasError
                ? OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: AppColors.red, width: 1.5.w),
            )
                : OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide.none,
            ),
            focusedBorder: hasError
                ? OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: AppColors.red, width: 1.5.w),
            )
                : OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: AppColors.red, width: 1.5.w),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: AppColors.red, width: 1.5.w),
            ),
            // ─────────────────────────────────────────────────────────────

            hintText: widget.hint,
            hintStyle: widget.hintStyle ??
                StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.text.withOpacity(0.4),
                ),

            prefixIcon: widget.prefixIcon != null
                ? Padding(
              padding: EdgeInsets.only(left: 12.w, right: 8.w),
              child: widget.prefixIcon,
            )
                : null,
            prefixIconConstraints: const BoxConstraints(),

            suffixIcon: resolvedSuffix != null
                ? Padding(
              padding: EdgeInsets.only(left: 8.w, right: 12.w),
              child: resolvedSuffix,
            )
                : null,
            suffixIconConstraints: const BoxConstraints(),

            // Suppress built-in error / helper — we render our own
            errorText: null,
            helperText: null,
            counterText: '',
          ),
          ),
        ),

        // ── Error / Helper / Counter row ───────────────────────────────────
        if (hasError || widget.helperText != null || _showCounter) ...[
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: error or helper
              Expanded(
                child: hasError
                    ? Text(
                  resolvedError!,
                  style: widget.errorStyle ??
                      StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
                )
                    : widget.helperText != null
                    ? Text(
                  widget.helperText!,
                  style: widget.helperStyle ??
                      StyleText.fontSize12Weight400.copyWith(
                        color: AppColors.text.withOpacity(0.5),
                      ),
                )
                    : const SizedBox.shrink(),
              ),

              // Right: character counter
              if (_showCounter && _effectiveMaxLength != null) ...[
                SizedBox(width: 8.w),
                Text(
                  '$_charCount / ${_effectiveMaxLength}',
                  style: widget.counterStyle ??
                      StyleText.fontSize12Weight400.copyWith(
                        color: _charCount > _effectiveMaxLength!
                            ? AppColors.red
                            : AppColors.text.withOpacity(0.4),
                      ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private input formatters (self-contained — no external dependencies)
// ─────────────────────────────────────────────────────────────────────────────

/// Blocks English letters (used for Arabic/RTL fields).
class _ArabicOnlyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final hasEnglishLetters = RegExp(r'[a-zA-Z]').hasMatch(newValue.text);
    if (hasEnglishLetters) return oldValue;
    return newValue;
  }
}

/// Blocks Arabic characters (used for English/LTR fields).
class _EnglishOnlyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final hasArabicCharacters = RegExp(r'[؀-ۿ]').hasMatch(newValue.text);
    if (hasArabicCharacters) return oldValue;
    return newValue;
  }
}

/// Capitalises the first letter of every word.
class _CapitalizeTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final capitalizedText = newValue.text.split(' ').map((word) {
      if (word.isEmpty) return word;
      if (word.length == 1) return word.toUpperCase();
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return TextEditingValue(
      text: capitalizedText,
      selection: TextSelection.collapsed(offset: capitalizedText.length),
    );
  }
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
  onChanged: (v) => debugPrint(v),
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
