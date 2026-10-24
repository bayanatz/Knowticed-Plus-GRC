/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: dropdown_overlay.dart
/// Description: `_DropdownOverlay` widget — split out of `1-custom_dropdown.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_dropdown.dart';

// Split from 1-custom_dropdown.dart to keep every file under 700 lines.

class _DropdownOverlay<T> extends StatelessWidget {
  final LayerLink layerLink;
  final Size triggerSize;

  /// The trigger's left edge in global (screen) coordinates.
  final double triggerGlobalX;
  final double verticalOffset;
  final bool openUpward;
  final List<DropdownItem<T>> items;
  final double maxHeight;
  final double itemHeight;
  final BorderRadius borderRadius;
  final double elevation;
  final TextStyle? itemStyle;
  final bool showDivider;
  final Color? dividerColor;
  final Widget? emptyWidget;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final T? selectedValue;
  final ValueChanged<DropdownItem<T>> onSelected;
  final VoidCallback onDismiss;

  const _DropdownOverlay({
    required this.layerLink,
    required this.triggerSize,
    required this.triggerGlobalX,
    required this.verticalOffset,
    required this.openUpward,
    required this.items,
    required this.maxHeight,
    required this.itemHeight,
    required this.borderRadius,
    required this.elevation,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.onSelected,
    required this.onDismiss,
    this.itemStyle,
    this.showDivider = false,
    this.dividerColor,
    this.emptyWidget,
    this.selectedValue,
  });

  /// Width the OVERLAY needs so the longest item label shows in full (no
  /// ellipsis). Each label is measured with its own text style; the widest
  /// wins, floored at the trigger width (the menu is never narrower than the
  /// button) and capped at the available screen width (so it can't run off
  /// screen). The TRIGGER button width is NOT affected — only the menu grows.
  double _resolveMenuWidth(BuildContext context) {
    final TextStyle baseStyle = itemStyle ??
        StyleText.fontSize12Weight400; // 12 = field value (17/10/2026)
    final TextDirection dir = Directionality.of(context);

    // FIXED 2/9/2026 — the painter was measuring at scale 1.0 while the tile
    // below renders through MediaQuery's text scaler. With OS text scaling
    // turned up, every label was measured NARROWER than it draws, so the menu
    // came out too tight and the longest item ellipsised — the "Read Mes…"
    // case on the messages Sort button. Measure with the same scaler the tile
    // paints with.
    final TextScaler scaler = MediaQuery.textScalerOf(context);

    double widest = 0;
    for (final item in items) {
      final tp = TextPainter(
        text: TextSpan(text: item.label, style: baseStyle),
        textDirection: dir,
        textScaler: scaler,
        maxLines: 1,
      )..layout();

      // 12.sp horizontal padding on each side of the tile + a little slack so
      // the glyphs never touch the edge.
      double w = tp.width + (12.sp * 2) + 8.sp;
      if (item.leading != null) w += 20.sp + 8.sp; // approx leading + gap
      if (item.trailing != null) w += 20.sp + 8.sp; // approx trailing + gap
      if (w > widest) widest = w;
    }

    final double screenCap = MediaQuery.of(context).size.width - 32.sp;
    double result = widest < triggerSize.width ? triggerSize.width : widest;
    if (result > screenCap) result = screenCap;
    return result;
  }

  /// How far to slide the menu horizontally so it stays on screen.
  ///
  /// ADDED: the follower anchors the menu's LEFT edge to the trigger's LEFT
  /// edge, which is right for a full-width form field — the menu is the same
  /// width as the thing it drops from. It is wrong for a compact button whose
  /// MENU is wider than its TRIGGER: a 38pt sort icon parked at the trailing
  /// edge of a toolbar dropped a ~140pt menu straight off the side of the
  /// screen, with the labels clipped to "Newes" / "Oldest".
  ///
  /// Returns a dx that pulls the menu back inside [_kEdgeMargin] of either
  /// edge, and 0 whenever it already fits — so every existing full-width
  /// dropdown is untouched.
  double _horizontalShift(BuildContext context, double menuWidth) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double margin = _kEdgeMargin.sp;

    double dx = 0;

    // CHANGED 17/10/2026 (Moataz, Messages sort): a menu wider than its
    // trigger lines up with the trigger's OUTER edge — right edges together
    // when the button sits on the right of the screen, left edges together on
    // the left — so it drops straight under the button and never pokes past
    // the page margin.
    if (menuWidth > triggerSize.width &&
        triggerGlobalX + triggerSize.width / 2 > screenWidth / 2) {
      dx = triggerSize.width - menuWidth;
    }

    // Past the trailing edge? Pull it back by exactly the overflow.
    final double rightOverflow =
        (triggerGlobalX + dx + menuWidth) - (screenWidth - margin);
    if (rightOverflow > 0) dx -= rightOverflow;

    // That pull (or an RTL trigger already near the leading edge) can push the
    // menu off the OTHER side on a narrow screen. Clamp there too.
    final double leftEdge = triggerGlobalX + dx;
    if (leftEdge < margin) dx += margin - leftEdge;

    return dx;
  }

  @override
  Widget build(BuildContext context) {
    final double menuWidth = _resolveMenuWidth(context);
    final double horizontalShift = _horizontalShift(context, menuWidth);
    return SizedBox.expand(
      child: Stack(
        children: [
          // Full-screen dismiss layer
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onDismiss,
            ),
          ),

          // ── CompositedTransformFollower keeps the overlay
          //    anchored directly to the trigger at all times ──
          CompositedTransformFollower(
            link: layerLink,
            showWhenUnlinked: false,
            // When opening downward: anchor top-left of trigger → offset by
            // triggerHeight + gap so overlay top sits right below trigger.
            // When opening upward: anchor top-left of trigger → offset is
            // negative so overlay bottom sits right above trigger.
            targetAnchor: openUpward ? Alignment.topLeft : Alignment.bottomLeft,
            followerAnchor:
                openUpward ? Alignment.bottomLeft : Alignment.topLeft,
            offset: Offset(
              horizontalShift,
              openUpward ? -verticalOffset : verticalOffset,
            ),
            child: FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                alignment:
                    openUpward ? Alignment.bottomCenter : Alignment.topCenter,
                child: Material(
                  elevation: elevation,
                  borderRadius: borderRadius,
                  color: AppColors.card,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maxHeight,
                      // Grow the menu to fit the widest item (see
                      // [_resolveMenuWidth]); never narrower than the trigger.
                      minWidth: menuWidth,
                      maxWidth: menuWidth,
                    ),
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: items.isEmpty
                          ? SizedBox(
                              height: itemHeight,
                              child: emptyWidget ??
                                  Center(
                                    child: Text(
                                      S.of(context).noOptions,
                                      style: StyleText.fontSize13Weight400
                                          .copyWith(
                                        color: AppColors.text.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                    ),
                                  ),
                            )
                          // No desktop scrollbar in the menu (form-builder
                          // bug report #9/#30/#37); scrolling still works.
                          : ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(scrollbars: false),
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: items.length,
                                separatorBuilder: (_, __) => showDivider
                                    ? Divider(
                                        height: 1.sp,
                                        thickness: 1.sp,
                                        color: dividerColor ??
                                            AppColors.text
                                                .withValues(alpha: 0.08),
                                      )
                                    : const SizedBox.shrink(),
                                itemBuilder: (_, i) {
                                  final item = items[i];
                                  final isSelected =
                                      item.value == selectedValue;
                                  return _DropdownItemTile<T>(
                                    item: item,
                                    isSelected: isSelected,
                                    height: itemHeight,
                                    style: itemStyle,
                                    onTap: item.enabled
                                        ? () => onSelected(item)
                                        : null,
                                  );
                                },
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
