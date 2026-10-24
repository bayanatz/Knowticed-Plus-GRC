/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: k_dropdown_hint_color.dart
/// Description: `_DropdownItemTile` widget, state and UI of the `T` widget — split out of `1-custom_dropdown.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_dropdown.dart';

// Split from 1-custom_dropdown.dart to keep every file under 700 lines.

/// The one placeholder colour every dropdown in the app uses.
///
/// ADDED 19/8/2026 — the hint colour used to be whatever a caller happened to
/// pass in `hintStyle`, and the three dropdowns disagreed about the default:
/// `AppColors.text.withOpacity(0.4)` here and on the range calendar, plain
/// `AppColors.secondaryText` on the date calendar. Two of those sitting on one
/// row showed two different greys.
///
/// It is NOT a parameter any more. `hintStyle` still owns size, weight and
/// family — the colour is reapplied on top of whatever the caller passes, so
/// `hintStyle: ....copyWith(color: Colors.red)` is silently ignored rather
/// than allowed to drift. Both calendar dropdowns import this rather than
/// keeping a copy, which is what let them drift in the first place.
///
/// A getter, not a `const`: `AppColors.secondaryText` resolves against the
/// active theme, so this has to be read at build time.
///
/// CHANGED 16/9/2026 — full `AppColors.secondaryText` (was 50% opacity), per
/// design review on the GRC dashboard. Still the one colour for every hint.
Color get kDropdownHintColor => AppColors.secondaryText;

// ─────────────────────────────────────────────────────────────────────────────
// Item tile with hover state
// ─────────────────────────────────────────────────────────────────────────────

class _DropdownItemTile<T> extends StatefulWidget {
  final DropdownItem<T> item;
  final bool isSelected;
  final double height;
  final TextStyle? style;
  final VoidCallback? onTap;

  const _DropdownItemTile({
    required this.item,
    required this.isSelected,
    required this.height,
    this.style,
    this.onTap,
  });

  @override
  State<_DropdownItemTile<T>> createState() => _DropdownItemTileState<T>();
}

class _DropdownItemTileState<T> extends State<_DropdownItemTile<T>> {
  final bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null;

    return MouseRegion(
      cursor:
          isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      // Owner rule 23/10/2026 ("no hovers in anything"): `_hovered` is never
      // set, so a row keeps its colour while the mouse rests on it.
      child: GestureDetector(
        // A row in a scrolling menu: LOW on the tap itself (X-117).
        onTap: widget.onTap == null
            ? null
            : withHaptic(widget.onTap!, HapticLevel.low),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: widget.height,
          padding: EdgeInsets.symmetric(horizontal: 12.sp),
          color: widget.isSelected
              ? AppColors.primary
              : (_hovered && !isDisabled)
                  ? AppColors.primary
                  : AppColors.transparent,
          child: Row(
            children: [
              if (widget.item.leading != null) ...[
                widget.item.leading!,
                SizedBox(width: 8.sp),
              ],
              Expanded(
                child: Text(
                  widget.item.label,
                  // CHANGED 17/10/2026 (Moataz): options are 12, same as the
                  // field's value; the highlighted / hovered option's text
                  // contrasts with the highlight (AppTheme.readableOn).
                  style: (widget.style ??
                          (widget.isSelected
                              ? StyleText.fontSize12Weight500
                              : StyleText.fontSize12Weight400))
                      .copyWith(
                    color: isDisabled
                        ? AppColors.text.withValues(alpha: 0.3)
                        : (widget.isSelected || _hovered)
                            ? AppTheme.readableOn(AppColors.primary)
                            : AppColors.secondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.item.trailing != null) ...[
                SizedBox(width: 8.sp),
                widget.item.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
