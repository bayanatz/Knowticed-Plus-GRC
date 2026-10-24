/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: custom_text_field_builders.dart
/// Description: UI builder methods of `_CustomTextFieldState` — split out of `2-custom_textfield.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_textfield.dart';

// Split from 2-custom_textfield.dart to keep every file under 700 lines.

extension _CustomTextFieldStateBuilders on _CustomTextFieldState {
  /// Owner 22/10/2026 (Notification Control): a field marked Arabic
  /// (`textDirection: rtl`) lays out right-to-left even inside an English
  /// screen — label and text on the right, the character counter on the left.
  ///
  /// The mirror case (owner 22/10/2026, Arabic screen): an English field
  /// (`textDirection: ltr` with a Latin label, e.g. "Title") lays out
  /// left-to-right inside an Arabic screen — label on the left, counter on
  /// the right. An LTR field with an ARABIC label (an email or phone field
  /// labelled in Arabic) keeps the screen's direction.
  Widget _buildView(BuildContext context) {
    final TextDirection? own = widget.textDirection;
    final TextDirection ambient = Directionality.of(context);
    final bool arabicLabel =
        RegExp('[\u0600-\u06FF]').hasMatch(widget.label ?? '');
    if (own == null ||
        own == ambient ||
        (own == TextDirection.ltr && arabicLabel)) {
      return _buildFieldView(context);
    }
    return Directionality(
      textDirection: own,
      child: Builder(builder: _buildFieldView),
    );
  }

  /// "13 / 500" → "١٣ / ٥٠٠" for an Arabic field. Bidi lays Arabic digits
  /// out right-to-left, so it shows "٥٠٠ / ١٣" — count / limit read RTL,
  /// as in Figma.
  String _counterDigits(String text, bool arabic) {
    // 23/10/2026 (Moataz): a field with no stated direction counts in Arabic
    // digits on the Arabic screen too, not only an explicitly RTL field.
    if (!arabic) return text;
    return text.replaceAllMapped(
      RegExp('[0-9]'),
      (Match m) => String.fromCharCode(0x0660 + int.parse(m.group(0)!)),
    );
  }

  Widget _buildFieldView(BuildContext context) {
    final resolvedError = _formField?.errorText ?? _resolvedError;
    final hasError = resolvedError != null && resolvedError.isNotEmpty;
    final radius = widget.borderRadius ?? BorderRadius.circular(4.r);
    final isDisabled = !widget.enabled;

    // ── Suffix icon resolution ─────────────────────────────────────────────
    // Priority: explicit suffixIcon > password-toggle eye > nothing
    Widget? resolvedSuffix = widget.suffixIcon;
    if (resolvedSuffix == null && widget.obscureText && !_isMultiline) {
      resolvedSuffix = GestureDetector(
        onTapDown: (_) => HapticController.low(),
        onTap: () => rebuild(() => _obscured = !_obscured),
        child: Icon(
          _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20.sp,
          color: hasError
              ? AppColors.red
              : isDisabled
                  ? AppColors.text.withValues(alpha: 0.3)
                  : AppColors.text.withValues(alpha: 0.5),
        ),
      );
    }

    // ── Content padding ────────────────────────────────────────────────────
    // A fixed-height single-line field gets NO vertical padding: the box
    // height comes from [height] (see [_pinsHeight]) and the text is centred
    // in it, so padding would only push the content past that height.
    //
    // ADDED 21/9/2026 — the password mask. Centring puts the LINE box in the
    // middle, but the mask glyph sits below that line's visual centre (it is
    // drawn on the font's math axis, not mid cap-height), so on screen the
    // stars read ~2.sp low next to the centred lock and eye icons. Extra
    // bottom padding moves the centred line up by half of it. Only while
    // there is masked text: the hint keeps the normal centring.
    final bool nudgeMask = widget.contentPadding == null &&
        _pinsHeight &&
        _effectiveObscure &&
        _controller.text.isNotEmpty;
    final effectivePadding = widget.contentPadding ??
        (nudgeMask
            ? EdgeInsets.fromLTRB(12.sp, 0, 12.sp, 4.sp)
            : EdgeInsets.symmetric(
                horizontal: 12.sp,
                vertical: _pinsHeight ? 0 : 10.sp,
              ));

    // ── Label 14.sp / hint 12.sp, ALWAYS (16/8/2026) ───────────────────────
    //
    // The two sizes are the field's contract, not a default a caller can talk
    // it out of. [CustomTextField.labelStyle] and [CustomTextField.hintStyle]
    // still decide colour, weight, letter spacing and everything else — the
    // font SIZE is reapplied on top of whatever comes in.
    //
    // This is a rule and not a suggestion because the call sites had drifted
    // the other way round: several form cards pass a 12pt label and a 14pt
    // hint, so the placeholder was rendering LARGER than the field's own title
    // and the forms disagreed with each other screen by screen. Fixing the
    // callers one at a time fixes today's screens; fixing it here is what
    // makes tomorrow's screen right without anyone remembering the rule.
    final double labelFontSize = 14.sp;
    // D-208 (20/10/2026): the placeholder is the SAME size as the value (14).
    final double hintFontSize = (widget.hintFontSize ?? 14).sp;

    final TextStyle labelStyle = (widget.labelStyle ??
            StyleText.fontSize14Weight500.copyWith(
              color: hasError
                  ? AppColors.red
                  : isDisabled
                      ? AppColors.text
                      : AppColors.text,
            ))
        .copyWith(fontSize: labelFontSize);

    // CHANGED 14/10/2026 (KH vertical report p.3 "why hint color not the
    // same"): the default hint was text @ 40%, a different grey from every
    // dropdown hint (kDropdownHintColor = secondaryText) on the same form.
    final TextStyle hintStyle = (widget.hintStyle ??
            StyleText.fontSize12Weight400.copyWith(
              color: AppColors.secondaryText,
            ))
        .copyWith(
      fontSize: hintFontSize,
      // 23/10/2026: the hint is merged over the field's style, so the tight
      // mask spacing (obscuredLetterSpacing) leaked into "Enter Your Password"
      // and squashed its letters together. The hint always spaces normally.
      letterSpacing: widget.obscuredLetterSpacing == null ? null : 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ──────────────────────────────────────────────────────────
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label,
              style: labelStyle,
              children: widget.required
                  ? [
                      TextSpan(
                        text: '',
                        // Same size as the label it trails, so the asterisk cannot
                        // sit off the title's baseline.
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.red,
                          fontSize: labelFontSize,
                        ),
                      ),
                    ]
                  : [],
            ),
          ),
          // D-209 (20/10/2026): label → field gap halved (was 6).
          SizedBox(height: kFieldLabelGap.sp),
        ],

        // ── Field ──────────────────────────────────────────────────────────
        SizedBox(
          width: widget.width?.sp,
          height: _height?.sp,
          child: TextField(
            // ADDED 17/10/2026: a tap anywhere outside the field closes the
            // keyboard (it stayed open over the Messages list).
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            obscureText: _effectiveObscure,
            obscuringCharacter: widget.obscuringCharacter,
            // `expands: true` requires BOTH of these to be null — see
            // [_fillsHeight]. `textAlignVertical: top` keeps the caret on the
            // first line of the stretched box instead of centring it.
            maxLines: widget.obscureText
                ? 1
                : (_fillsHeight ? null : widget.maxLines),
            minLines: _fillsHeight ? null : widget.minLines,
            expands: _fillsHeight,
            // CHANGED 8/9/2026 — a single-line field with a fixed height now
            // centres its text instead of leaving the alignment unset.
            //
            // `null` means InputDecorator decides, and with `isDense: true` it
            // lays the content out at its natural height and pins it to the TOP
            // of the box. That is invisible while the padding happens to fill
            // the box, and obvious the moment it does not — see the note in
            // AppSearchTextField, whose 38-high search box read as top-aligned.
            //
            // Multi-line keeps `top`: a stretched box must start its caret on
            // the first line, not in the middle of the box.
            textAlignVertical: _fillsHeight
                ? TextAlignVertical.top
                : (_height != null ? TextAlignVertical.center : null),
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
            style: (widget.valueStyle ??
                    StyleText.fontSize14Weight400.copyWith(
                      color: isDisabled ? AppColors.text : AppColors.text,
                    ))
                .copyWith(
              letterSpacing:
                  _effectiveObscure ? widget.obscuredLetterSpacing : null,
            ),
            // Hide the built-in counter — we render our own below
            buildCounter: _effectiveMaxLength != null
                ? (
                    _, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) =>
                    const SizedBox.shrink()
                : null,
            decoration: InputDecoration(
              isDense: true,
              // 21/9/2026 — held to [height] like CustomDropdown /
              // CustomDateField, so a row of the three paints one height.
              constraints: _pinsHeight
                  ? BoxConstraints.tightFor(height: _height!.sp)
                  : null,
              contentPadding: effectivePadding,
              filled: true,
              // No hover overlay tint on desktop/web
              hoverColor: Colors.transparent,
              fillColor: isDisabled
                  ? (widget.fillColor ?? AppColors.background)
                  : widget.fillColor ?? AppColors.background,

              // ── No border rule ────────────────────────────────────────────
              // Default / focused / disabled → no border at all.
              // Error → red border.
              border: hasError
                  ? OutlineInputBorder(
                      borderRadius: radius,
                      borderSide: BorderSide(
                        color: AppColors.red,
                        width: 1.5.sp,
                      ),
                    )
                  : OutlineInputBorder(
                      borderRadius: radius,
                      borderSide: BorderSide.none,
                    ),
              enabledBorder: hasError
                  ? OutlineInputBorder(
                      borderRadius: radius,
                      borderSide: BorderSide(
                        color: AppColors.red,
                        width: 1.5.sp,
                      ),
                    )
                  : OutlineInputBorder(
                      borderRadius: radius,
                      borderSide: BorderSide.none,
                    ),
              focusedBorder: hasError
                  ? OutlineInputBorder(
                      borderRadius: radius,
                      borderSide: BorderSide(
                        color: AppColors.red,
                        width: 1.5.sp,
                      ),
                    )
                  : OutlineInputBorder(
                      borderRadius: radius,
                      borderSide: widget.focusBorderColor == null
                          ? BorderSide.none
                          : BorderSide(
                              color: widget.focusBorderColor!,
                              width: 1.sp,
                            ),
                    ),
              disabledBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(color: AppColors.red, width: 1.5.sp),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(color: AppColors.red, width: 1.5.sp),
              ),
              // ─────────────────────────────────────────────────────────────

              hintText: widget.hint,
              hintStyle: hintStyle,

              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: EdgeInsets.only(left: 12.sp, right: 8.sp),
                      child: widget.prefixIcon,
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(),

              suffixIcon: resolvedSuffix != null
                  ? Padding(
                      padding: EdgeInsets.only(left: 8.sp, right: 12.sp),
                      child: resolvedSuffix,
                    )
                  : (_pinsHeight ? SizedBox(width: 12.sp) : null),
              suffixIconConstraints: _pinsHeight
                  ? BoxConstraints(
                      minHeight: _height!.sp,
                      maxHeight: _height!.sp,
                    )
                  : const BoxConstraints(),

              // Suppress built-in error / helper — we render our own
              errorText: null,
              helperText: null,
              counterText: '',
            ),
          ),
        ),

        // ── Error / Helper / Counter row ───────────────────────────────────
        if (hasError || widget.helperText != null || _showCounter) ...[
          // TIGHTENED 22/8/2026: a message needs air between it and the field,
          // but a bare character counter is a footnote ON the box — the 4.sp
          // here plus the dead space fixed by [_fillsHeight] read as a stray
          // margin under the field. No gap when the counter is all there is.
          if (hasError || widget.helperText != null) SizedBox(height: 4.sp),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: error or helper
              Expanded(
                child: hasError
                    ? Text(
                        resolvedError,
                        style: widget.errorStyle ??
                            StyleText.fontSize12Weight400.copyWith(
                              color: AppColors.red,
                            ),
                      )
                    : widget.helperText != null
                        ? Text(
                            widget.helperText!,
                            style: widget.helperStyle ??
                                StyleText.fontSize12Weight400.copyWith(
                                  color: AppColors.text.withValues(alpha: 0.5),
                                ),
                          )
                        : const SizedBox.shrink(),
              ),

              // Right: character counter
              if (_showCounter && _effectiveMaxLength != null) ...[
                SizedBox(width: 8.sp),
                // Forced LTR: "13 / 500" is a numeric expression, so in an RTL
                // field the bidi algorithm would otherwise reorder it to
                // "500 / 13".
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    // FIXED 13/8/2026: the counter was always ASCII, so an
                    // Arabic field showed "0 / 500" under Arabic text. The
                    // numerals follow the field, not the app: an RTL field
                    // counts in Arabic-Indic digits, an explicitly LTR field
                    // stays Latin, and a field that states no direction
                    // follows the active locale.
                    //
                    // The forced LTR wrapper above still matters — "٠ / ٥٠٠"
                    // is a numeric expression and bidi would otherwise flip it
                    // to "٥٠٠ / ٠".
                    // Owner 22/10/2026: an Arabic field counts in Arabic
                    // digits (Figma ١٥٠/٠) — an exception to D-145, which
                    // keeps every other number Western.
                    _counterDigits(
                      '${LocalizedNumber.forLocale(_charCount, _counterLocale(context))}'
                      ' / '
                      '${LocalizedNumber.forLocale(_effectiveMaxLength!, _counterLocale(context))}',
                      _counterLocale(context) == 'ar',
                    ),
                    textDirection: TextDirection.ltr,
                    style: widget.counterStyle ??
                        StyleText.fontSize12Weight400.copyWith(
                          color: _charCount > _effectiveMaxLength!
                              ? AppColors.red
                              : AppColors.text.withValues(alpha: 0.4),
                        ),
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
