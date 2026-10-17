/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_dropdown.dart
/// Description: Declares `DropdownItem`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:flutter/material.dart';
import 'package:grc_module/core/custom/inputs/field_sizing.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/custom/helpers/custom_svg.dart';

import 'package:grc_module/core/theme/app_animations.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

part 'custom_dropdown/dropdown_overlay.dart';
part 'custom_dropdown/custom_dropdown.dart';
part 'custom_dropdown/k_dropdown_hint_color.dart';

/// The fill behind a dropdown TRIGGER, and the colour of its chevron.
///
/// ADDED 12/9/2026. Controls that are not dropdowns but have to READ as one —
/// the publish-date From/To fields in the Knowledge Hub filter dialog sit
/// directly under three of these — used to hardcode their own copies of both
/// values, and drifted: the date field drew its calendar glyph at full
/// `AppColors.secondaryText` while the chevron beside it was half-opacity, so
/// two fields in the same column showed two different icon weights.
///
/// Getters, not `const`: the AppColors entries resolve against the active
/// theme, so both have to be read at build time.
Color get kDropdownFillColor => AppColors.background;

/// The chevron dims while the field is empty and takes its normal colour once
/// something is chosen, so an unanswered field reads as unanswered at a glance
/// rather than only by its hint text. [hasValue] is the same "something is
/// selected" test that drives the trigger's `isEmpty` and `hintText`.
// CHANGED 30/9/2026 (Role QA p.6): at 50% opacity the chevron (and the
// calendar icon, which follows this colour) almost disappeared on the grey
// field fill. Both states are now the full secondary-text grey.
// CHANGED 14/10/2026 (KH vertical report p.4): once a value is chosen the
// chevron takes the value's colour (black), not the hint grey.
Color kDropdownTrailingIconColor({required bool hasValue}) =>
    hasValue ? AppColors.text : AppColors.secondaryText;

/// Vertical gap between a field's label and the field itself.
///
/// ADDED 29/8/2026. Three controls that routinely stand side by side in one row
/// each had their own idea of this gap — `CustomDropdown` used 3,
/// `CustomDateField` used 6, and screens that hand-roll a labelled box
/// (Adding New Access) used 8. Since the gap sits ABOVE the field, a different
/// gap means the FIELDS start at different heights: a row of three read as
/// stepped rather than aligned, and no amount of matching the field heights
/// fixed it.
///
/// Raw, not `.sp`: callers apply `.sp` at the point of use, so a value that has
/// already been scaled is never scaled twice.
///
/// Anything drawing a label above a field should use this rather than its own
/// number — that is the whole point of it being here.
const double kFieldLabelGap = 6;

/// A dropdown item model
class DropdownItem<T> {
  final T value;
  final String label;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;

  const DropdownItem({
    required this.value,
    required this.label,
    this.leading,
    this.trailing,
    this.enabled = true,
  });
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>>
    with SingleTickerProviderStateMixin {
  /// The box height: the screen's, else the shared 36 (D-18, 17/10/2026).
  double? get _fieldHeight => widget.height ?? FieldSizing.height;

  // ── CompositedTransformTarget link ──────────────────────
  final _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // We need the trigger height to position the follower below it.
  // We read it after layout via a GlobalKey on the trigger Container.
  final _triggerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    // MUST run BEFORE `_animController.dispose()` — see [_removeOverlayEntry].
    // Disposing the controller CANCELS the ticker future, so anything waiting
    // on the close animation to take the entry down never runs.
    _removeOverlayEntry();
    _animController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;
    _isOpen ? _closeOverlay() : _openOverlay();
  }

  void _openOverlay() {
    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final triggerSize = renderBox.size;
    final verticalOffset = widget.overlayOffset ?? 2.sp; // ← 2.sp gap

    // Determine whether to open upward or downward
    final globalOffset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - globalOffset.dy - triggerSize.height;
    final spaceAbove = globalOffset.dy;
    final openUpward = spaceBelow < 150.sp && spaceAbove > spaceBelow;

    // A previous entry may still be fading out (tap to close, tap again inside
    // the 180ms reverse). Overwriting `_overlayEntry` while it is still
    // inserted would strand it in the Overlay, and its full-screen dismiss
    // layer would keep eating every tap in the app. Drop it first.
    _removeOverlayEntry();

    _overlayEntry = OverlayEntry(
      builder: (_) => _DropdownOverlay<T>(
        layerLink: _layerLink,
        triggerSize: triggerSize,
        // Where the trigger actually sits on screen. The overlay needs it to
        // keep a menu that is WIDER than its trigger from running off the
        // edge — see [_horizontalShift].
        triggerGlobalX: globalOffset.dx,
        verticalOffset: verticalOffset,
        openUpward: openUpward,
        items: widget.items,
        maxHeight: widget.maxOverlayHeight ?? 240.sp,
        itemHeight: widget.itemHeight ?? 36.sp,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(4.r),
        elevation: widget.overlayElevation,
        itemStyle: widget.itemStyle,
        showDivider: widget.showDivider,
        dividerColor: widget.dividerColor,
        emptyWidget: widget.emptyWidget,
        fadeAnimation: _fadeAnimation,
        scaleAnimation: _scaleAnimation,
        selectedValue: widget.value,
        onSelected: (item) {
          _closeOverlay();
          widget.onChanged?.call(item.value);
        },
        onDismiss: _closeOverlay,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animController.forward(from: 0);
    setState(() => _isOpen = true);
    widget.onOpen?.call();
  }

  /// Takes the overlay entry down NOW, without waiting for the close
  /// animation. Safe to call more than once.
  ///
  /// FIXED 30/8/2026 — RELEASE-ONLY FREEZE AFTER PICKING AN ITEM.
  ///
  /// `_closeOverlay` used to remove the entry only from
  /// `_animController.reverse().then(...)`, i.e. 180ms later. Selecting an item
  /// calls `onChanged`, and every call site keys this widget off the selected
  /// value (`key: ValueKey(selected)`), so the parent's `setState` gives the
  /// dropdown a NEW key on the very next frame: the old `State` is disposed
  /// long before those 180ms are up, and disposing an `AnimationController`
  /// CANCELS its `TickerFuture` — `TickerFuture.then()` listens on the primary
  /// completer, which is never completed on cancel, so the callback simply
  /// never fires and the `OverlayEntry` stays in the Overlay forever.
  ///
  /// The stranded entry is invisible (`showWhenUnlinked: false` hides the menu
  /// once its LayerLink loses the leader) but its `Positioned.fill`
  /// `HitTestBehavior.translucent` dismiss layer is not — it sits over the
  /// whole app and swallows every pointer event. That is the "screen freezes
  /// and nothing responds again" report.
  ///
  /// Debug builds hid it: `_closeOverlay()` ran first in `dispose()` and its
  /// `setState` (`mounted` is still true inside `dispose`) tripped
  /// `markNeedsBuild`'s `_lifecycleState != defunct` assertion, which aborted
  /// `dispose()` before `_animController.dispose()` — the controller survived,
  /// the reverse finished, and the entry was removed. Asserts are compiled out
  /// in release, so there the controller really is disposed and the entry
  /// really does leak. Same code, opposite outcome.
  void _removeOverlayEntry() {
    final OverlayEntry? entry = _overlayEntry;
    if (entry == null) return;
    _overlayEntry = null; // null first: `remove()` must never run twice
    entry.remove();
  }

  void _closeOverlay() {
    final OverlayEntry? entry = _overlayEntry;
    if (entry == null) return;

    // Being disposed / already detached: nothing is left to drive the close
    // animation, so take the entry down immediately.
    if (!mounted) {
      _removeOverlayEntry();
      return;
    }

    setState(() => _isOpen = false);
    widget.onClose?.call();

    // `whenCompleteOrCancel`, not `then`: it also fires when the ticker is
    // cancelled (controller disposed mid-animation), so the entry comes down
    // either way. The identity check keeps it from removing an entry that
    // `dispose()` or a re-open has already dealt with.
    _animController.reverse().whenCompleteOrCancel(() {
      if (identical(_overlayEntry, entry)) _removeOverlayEntry();
    });
  }

  DropdownItem<T>? get _selectedItem {
    try {
      return widget.items.firstWhere((e) => e.value == widget.value);
    } catch (_) {
      return null;
    }
  }

  /// Label 14.sp, hint 12.sp, ALWAYS (16/8/2026).
  ///
  /// The same contract `CustomTextField` carries, and for the same reason: a
  /// dropdown sits next to a text field in every form in the app, so the two
  /// have to agree about how big a title and a placeholder are. They did not —
  /// the hint here defaulted to 14 while the field's was 12, so a Permissions
  /// dropdown beside a Description box showed a visibly larger placeholder.
  ///
  /// [labelStyle] / [hintStyle] still decide colour, weight and everything
  /// else; only the font size is reapplied on top.
  static const double _labelSize = 14;
  static const double _hintSize = 12;

  /// The SELECTED value on the trigger, same size as the hint (13/9/2026).
  ///
  /// It was 14 while the hint beside it was 12, so the trigger visibly grew
  /// the moment something was picked — the text jumped a size on selection.
  /// A trigger reads as one control, so both of its states are 12.sp.
  static const double _valueSize = 12;

  /// [base] with the scale's size forced on, or untouched when the caller
  /// opted out via [CustomDropdown.enforceTypeScale].
  TextStyle _scaled(TextStyle base, double size) =>
      widget.enforceTypeScale ? base.copyWith(fontSize: size.sp) : base;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    // ── Trigger ──────────────────────────────────────────
    // Uses InputDecorator so the rendered height is pixel-identical to a
    // CustomTextField with the same contentPadding.
    final Widget trigger = _sized(
      CompositedTransformTarget(
        link: _layerLink,
        child: GestureDetector(
          onTapDown: (_) => HapticController.low(), // finger-down (X-104)
          onTap: _toggleDropdown,
          // InputDecorator asserts it must have a bounded width. When this
          // dropdown is placed in a parent that provides an unbounded width
          // (e.g. a Row/Column without Expanded/Flexible/SizedBox), fall back
          // to sizing the trigger to its intrinsic width so it never crashes
          // with "InputDecorator cannot have an unbounded width".
          child: LayoutBuilder(
            builder: (context, constraints) {
              final trigger = _buildTrigger(context);
              return constraints.maxWidth.isFinite
                  ? trigger
                  : IntrinsicWidth(child: trigger);
            },
          ),
        ),
      ),
    );

    // NO LABEL, NO ERROR, NO HELPER → NO COLUMN (16/8/2026).
    //
    // The Column below stacks three optional pieces. When none of them are
    // present it wraps a single child and changes nothing visually — but it
    // does change LAYOUT: a Column hands its children UNBOUNDED height, so a
    // caller that sizes this dropdown with a SizedBox (a toolbar button next
    // to other 38pt buttons, say) never reaches the InputDecorator. The
    // decorator then lays out at its own intrinsic height and the Column,
    // pinned to the SizedBox, reports "RenderFlex overflowed by N pixels".
    //
    // Returning the trigger bare lets the caller's constraint through, and
    // InputDecorator already clamps itself to the height it is given — so a
    // bounded parent gets exactly the height it asked for and an unbounded one
    // behaves exactly as before.
    final bool hasSurroundingText =
        widget.label != null || hasError || widget.helperText != null;
    if (!hasSurroundingText) return trigger;

    // ── Label ──────────────────────────────────────────
    final List<Widget> above = <Widget>[
      if (widget.label != null) ...[
        RichText(
          text: TextSpan(
            text: widget.label,
            style: _scaled(
              widget.labelStyle ??
                  StyleText.fontSize14Weight500.copyWith(
                    color: hasError
                        ? AppColors.red
                        : widget.enabled
                            ? AppColors.text
                            : AppColors.text,
                  ),
              _labelSize,
            ),
            children: widget.required
                ? [
                    TextSpan(
                      text: ' *',
                      style: _scaled(
                        StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.red,
                        ),
                        _labelSize,
                      ),
                    ),
                  ]
                : [],
          ),
        ),
        // CHANGED 29/8/2026: was 3. See [kFieldLabelGap].
        // [labelGap] overrides it per caller; null keeps the shared value.
        SizedBox(height: (widget.labelGap ?? kFieldLabelGap).sp),
      ],
    ];

    // ── Error / Helper ─────────────────────────────────
    final List<Widget> below = <Widget>[
      if (hasError) ...[
        SizedBox(height: 4.sp),
        Text(
          widget.errorText!,
          style: widget.errorStyle ??
              StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
        ),
      ] else if (widget.helperText != null) ...[
        SizedBox(height: 4.sp),
        Text(
          widget.helperText!,
          style: widget.helperStyle ??
              StyleText.fontSize12Weight400.copyWith(
                color: AppColors.text.withValues(alpha: 0.5),
              ),
        ),
      ],
    ];

    // A BOUNDED PARENT SIZES THE TRIGGER, NOT THE STACK (18/8/2026).
    //
    // The comment above explains why the no-label case returns the trigger
    // bare. The labelled case had the mirror-image problem and no equivalent
    // guard: label + 6sp + trigger is roughly 63pt, so any caller that wrote
    // `SizedBox(height: 36, child: CustomDropdown(label: ...))` — the obvious
    // way to make a dropdown match a 36pt row of controls, and what several
    // screens actually did — clamped the whole stack and got
    // "A RenderFlex overflowed by 27 pixels on the bottom" pointing at the
    // Column below.
    //
    // `height:` is the parameter that means "size the trigger" (see `_sized`),
    // and call sites should prefer it. But a widget should not paint a red
    // stripe because its caller constrained it: when the incoming height is
    // bounded, hand the label and helper their natural height and let the
    // trigger absorb the remainder, exactly as `height:` would have.
    // Unbounded parents keep the previous behaviour byte for byte.
    // `Flexible(fit: loose)` and not `Expanded`: loose means the trigger keeps
    // its natural height whenever there is room for it, and only gives ground
    // when there is not. `Expanded` would force it to fill, so a dropdown
    // sitting in a tall Row (bounded, but with height to spare) would stretch
    // to the full row — a regression the striped overflow would have hidden.
    //
    // The bounded check is required, not cosmetic: a flex child inside a
    // Column with an unbounded main axis is a hard error in Flutter, and the
    // common case here — a dropdown in a scroll view — is exactly that.
    return LayoutBuilder(
      builder: (context, constraints) {
        final Widget sizedTrigger = constraints.hasBoundedHeight
            ? Flexible(
                fit: FlexFit.loose,
                child: ClipRect(child: trigger),
              )
            : trigger;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [...above, sizedTrigger, ...below],
        );
      },
    );
  }

  /// Applies [CustomDropdown.height] to the trigger, or leaves it alone.
  ///
  /// A `SizedBox` rather than a taller `contentPadding`: InputDecorator clamps
  /// itself to the height it is handed (the note in `build` relies on the same
  /// fact), while padding only grows the input area between the prefix and
  /// suffix slots and cannot shrink the trigger below what those slots need.
  Widget _sized(Widget trigger) {
    final double? h = _fieldHeight;
    if (h == null) return trigger;
    return SizedBox(height: h.sp, child: trigger);
  }

  Widget _buildTrigger(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final radius = widget.borderRadius ?? BorderRadius.circular(4.r);

    // With [alwaysShowHint] the trigger renders as if nothing were selected —
    // InputDecorator only draws `hintText` while it believes it is empty, so
    // this one flag drives all three of `isEmpty`, `hintText` and the child.
    final DropdownItem<T>? shownItem =
        widget.alwaysShowHint ? null : _selectedItem;

    // ADDED 16/9/2026 — with a fixed [height] the painted box IS that height
    // (not just the SizedBox around it): the suffix slot is pinned to the
    // height, which InputDecorator uses as the container's minimum, the
    // vertical padding goes to 0 and the value is centred. This is what lets
    // a `height: 38` dropdown and a `height: 38` CustomTextField match.
    final double? pinnedHeight =
        _fieldHeight != null && widget.showSuffixIcon ? _fieldHeight!.sp : null;

    return InputDecorator(
      key: _triggerKey,
      isFocused: false,
      textAlignVertical: pinnedHeight != null ? TextAlignVertical.center : null,
      isEmpty: shownItem == null,
      decoration: InputDecoration(
        isDense: true,
        // ADDED 21/9/2026 — the decorator itself is held to [height], not
        // just the SizedBox around it. The suffix-slot trick alone left the
        // painted box a few px short in some rows (Gender / Birthday /
        // Marital Status drew 37 / 40 / 37 px at the same `height: 40`).
        constraints: _fieldHeight == null
            ? null
            : BoxConstraints.tightFor(height: _fieldHeight!.sp),
        // 10.sp vertical (16/8/2026, was 12.sp). The trigger carries a
        // 20.sp chevron in its suffix, so its content is already taller
        // than a text field's single line — the same padding on both
        // made every dropdown stand proud of the fields beside it.
        //
        // Callers that pass [triggerPadding] are untouched: the sort
        // button sets its own, and the two role screens that set
        // 8.sp/12.sp meant those numbers.
        contentPadding: widget.triggerPadding ??
            EdgeInsets.symmetric(
              horizontal: 12.sp,
              vertical: pinnedHeight != null ? 0 : 10.sp,
            ),
        filled: true,
        fillColor: widget.enabled
            ? (widget.fillColor ?? kDropdownFillColor)
            : kDropdownFillColor,
        // ── No border rule — red only on error ──────
        // InputDecorator does not trigger errorBorder on its own
        // (no errorText), so we drive the border via enabledBorder.
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: hasError
            ? OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(color: AppColors.red, width: 1.5.sp),
              )
            : OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide.none,
              ),
        focusedBorder: hasError
            ? OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(color: AppColors.red, width: 1.5.sp),
              )
            : OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide.none,
              ),
        disabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        prefixIcon: widget.prefixIcon != null
            ? Padding(
                // FIXED 9/9/2026 — was `EdgeInsets.only(left:, right:)`, which
                // does NOT flip with the text direction. `InputDecorator` moves
                // the prefix slot to the RIGHT under RTL, but the padding stayed
                // put, so in Arabic the leading icon sat 8 from the edge instead
                // of 12 while every field beside it kept 12. Directional insets
                // resolve against `Directionality`, so LTR is byte-identical
                // (start == left) and RTL is now its mirror.
                padding: widget.prefixIconPadding ??
                    EdgeInsetsDirectional.only(start: 12.sp, end: 8.sp),
                child: widget.prefixIcon,
              )
            : null,
        prefixIconConstraints: const BoxConstraints(),
        // NO SUFFIX AT ALL when the caller opted out (16/8/2026) —
        // see [showSuffixIcon]. A zero-width child does not do it,
        // because the slot itself is what holds the right-hand space
        // open.
        suffixIcon: !widget.showSuffixIcon
            ? null
            : Padding(
                // FIXED 9/9/2026 — same direction bug as the prefix above.
                // The chevron is what a caller lines other trailing icons up
                // against (the date field in the services filter dialog is
                // pinned to this 12), and under RTL it was landing 8 from the
                // edge, so every such pairing was 4 out in Arabic only.
                padding: widget.suffixIconPadding ??
                    EdgeInsetsDirectional.only(start: 8.sp, end: 12.sp),
                child: widget.suffixIcon ??
                    AnimatedRotation(
                      turns: _isOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      // CHANGED 8/9/2026 — the chevron dims while the field
                      // is empty and takes its normal colour once something is
                      // chosen, so an unanswered dropdown reads as unanswered
                      // at a glance rather than only by its hint text.
                      //
                      // `shownItem` is the same value that drives `isEmpty`
                      // and `hintText` above, so all three agree about what
                      // "nothing selected" means — including under
                      // [alwaysShowHint], where the trigger deliberately
                      // renders as empty.
                      child: CustomSvgImage(
                        assetPath:
                            'assets/icons_assets/main_icons_assets/ic_nav_chevron_down.svg',
                        width: 20.sp,
                        height: 20.sp,
                        // CHANGED 12/9/2026 — the two colours moved to
                        // [kDropdownTrailingIconColor] so anything drawing a
                        // trailing glyph beside a dropdown can use the same
                        // rule instead of copying it.
                        color: widget.accentColor ??
                            kDropdownTrailingIconColor(
                              hasValue: shownItem != null,
                            ),
                        fit: BoxFit.contain,
                      ),
                    ),
              ),
        suffixIconConstraints: pinnedHeight != null
            ? BoxConstraints(minHeight: pinnedHeight, maxHeight: pinnedHeight)
            : const BoxConstraints(),
        hintText: shownItem == null ? (widget.hint ?? '') : null,
        // ADDED 14/10/2026 — one line only, cut with "…", for hint and value.
        hintMaxLines: 1,
        // The colour is forced last on purpose — see
        // [kDropdownHintColor]. `hintStyle` still decides size, weight
        // and family; it can no longer decide the grey.
        hintStyle: _scaled(
          (widget.hintStyle ?? StyleText.fontSize12Weight400).copyWith(
            color: widget.accentColor ?? kDropdownHintColor,
          ),
          _hintSize,
        ),
        // Suppress built-in error text — we render our own below
        errorText: null,
      ),
      child: shownItem != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (shownItem.leading != null) ...[
                  shownItem.leading!,
                  SizedBox(width: 8.sp),
                ],
                Expanded(
                  child: Text(
                    shownItem.label,
                    // Through _scaled, exactly like hintStyle: the size is
                    // forced to _valueSize so selected and unselected match,
                    // while `enforceTypeScale: false` still lets a caller that
                    // is not a form field (the sort button, the pending-result
                    // search bar) keep its own size.
                    style: _scaled(
                      widget.valueStyle ??
                          StyleText.fontSize12Weight400.copyWith(
                            color: widget.enabled
                                ? AppColors.text
                                : AppColors.text,
                          ),
                      _valueSize,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          // InputDecorator shows hintText automatically when child
          // isEmpty — but we still need a zero-height child.
          : const SizedBox.shrink(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Overlay widget — now uses CompositedTransformFollower for pixel-perfect
// positioning directly below (or above) the trigger.
// ─────────────────────────────────────────────────────────────────────────────

/// Minimum gap between the open menu and either edge of the screen.
const double _kEdgeMargin = 8;
