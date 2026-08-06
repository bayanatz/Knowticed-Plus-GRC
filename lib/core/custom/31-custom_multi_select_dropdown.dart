import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/custom/23-custom_check_box.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';

/// A multi-select dropdown item model
class MultiSelectDropdownItem<T> {
  final T value;
  final String label;
  final Widget? leading;
  final bool enabled;

  const MultiSelectDropdownItem({
    required this.value,
    required this.label,
    this.leading,
    this.enabled = true,
  });
}

/// Custom multi-select dropdown widget.
///
/// Mirrors [CustomDropdown] in look & behaviour, but lets the user pick
/// multiple values. Each row shows a [CustomCheckBox]. The overlay stays
/// open while selecting; tapping outside closes it.
class CustomMultiSelectDropdown<T> extends StatefulWidget {
  /// Currently selected values.
  final List<T> values;

  /// All selectable items.
  final List<MultiSelectDropdownItem<T>> items;

  /// Fires with the new full selection whenever an item is toggled.
  final ValueChanged<List<T>>? onChanged;

  final String? hint;
  final String? label;
  final String? errorText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool required;
  final Color? fillColor;
  final double? maxOverlayHeight;
  final EdgeInsetsGeometry? triggerPadding;
  final BorderRadius? borderRadius;
  final TextStyle? valueStyle;
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

  /// Builds the text shown on the trigger from the selected items.
  /// Defaults to comma-joined labels.
  final String Function(List<MultiSelectDropdownItem<T>> selected)?
      selectedTextBuilder;

  const CustomMultiSelectDropdown({
    super.key,
    required this.items,
    this.values = const [],
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
    this.maxOverlayHeight,
    this.triggerPadding,
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
    this.selectedTextBuilder,
  });

  @override
  State<CustomMultiSelectDropdown<T>> createState() =>
      _CustomMultiSelectDropdownState<T>();
}

class _CustomMultiSelectDropdownState<T>
    extends State<CustomMultiSelectDropdown<T>>
    with SingleTickerProviderStateMixin {
  final _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final _triggerKey = GlobalKey();

  // Local copy of selection so the overlay can rebuild instantly.
  late List<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<T>.from(widget.values);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant CustomMultiSelectDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep local selection in sync if the parent pushes new values.
    if (!_listEquals(oldWidget.values, widget.values)) {
      _selected = List<T>.from(widget.values);
      // didUpdateWidget runs during the build phase, so rebuilding the overlay
      // synchronously here throws "markNeedsBuild() called during build".
      // Defer it to the next frame instead.
      if (_overlayEntry != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _overlayEntry?.markNeedsBuild();
        });
      }
    }
  }

  bool _listEquals(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (final e in a) {
      if (!b.contains(e)) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _closeOverlay();
    _animController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;
    _isOpen ? _closeOverlay() : _openOverlay();
  }

  void _toggleItem(MultiSelectDropdownItem<T> item) {
    setState(() {
      if (_selected.contains(item.value)) {
        _selected.remove(item.value);
      } else {
        _selected.add(item.value);
      }
    });
    _overlayEntry?.markNeedsBuild();
    widget.onChanged?.call(List<T>.from(_selected));
  }

  void _openOverlay() {
    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final triggerSize = renderBox.size;
    final verticalOffset = widget.overlayOffset ?? 2.h;

    final globalOffset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - globalOffset.dy - triggerSize.height;
    final spaceAbove = globalOffset.dy;
    final openUpward = spaceBelow < 150.h && spaceAbove > spaceBelow;

    _overlayEntry = OverlayEntry(
      builder: (_) => _MultiSelectOverlay<T>(
        layerLink: _layerLink,
        triggerSize: triggerSize,
        verticalOffset: verticalOffset,
        openUpward: openUpward,
        items: widget.items,
        maxHeight: widget.maxOverlayHeight ?? 240.h,
        itemHeight: widget.itemHeight ?? 44.h,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8.r),
        elevation: widget.overlayElevation,
        itemStyle: widget.itemStyle,
        showDivider: widget.showDivider,
        dividerColor: widget.dividerColor,
        emptyWidget: widget.emptyWidget,
        fadeAnimation: _fadeAnimation,
        scaleAnimation: _scaleAnimation,
        selectedValues: _selected,
        onToggle: _toggleItem,
        onDismiss: _closeOverlay,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animController.forward(from: 0);
    setState(() => _isOpen = true);
    widget.onOpen?.call();
  }

  void _closeOverlay() {
    if (_overlayEntry == null) return;
    _animController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
    if (mounted) setState(() => _isOpen = false);
    widget.onClose?.call();
  }

  List<MultiSelectDropdownItem<T>> get _selectedItems =>
      widget.items.where((e) => _selected.contains(e.value)).toList();

  String get _selectedText {
    final selected = _selectedItems;
    if (selected.isEmpty) return '';
    if (widget.selectedTextBuilder != null) {
      return widget.selectedTextBuilder!(selected);
    }
    return selected.map((e) => e.label).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final radius = widget.borderRadius ?? BorderRadius.circular(8.r);
    final isEmpty = _selectedItems.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ──────────────────────────────────────────
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label,
              style: widget.labelStyle ??
                  StyleText.fontSize14Weight500.copyWith(
                    color: hasError
                        ? AppColors.red
                        : widget.enabled
                            ? AppColors.text
                            : AppColors.text.withOpacity(0.4),
                  ),
              children: widget.required
                  ? [
                      TextSpan(
                        text: ' *',
                        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
                      )
                    ]
                  : [],
            ),
          ),
          SizedBox(height: 6.h),
        ],

        // ── Trigger ────────────────────────────────────────
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: _toggleDropdown,
            child: InputDecorator(
              key: _triggerKey,
              isFocused: false,
              isEmpty: isEmpty,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: widget.triggerPadding ??
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                filled: true,
                fillColor: widget.enabled
                    ? (widget.fillColor ?? AppColors.card)
                    : AppColors.card.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide.none,
                ),
                enabledBorder: hasError
                    ? OutlineInputBorder(
                        borderRadius: radius,
                        borderSide:
                            BorderSide(color: AppColors.red, width: 1.5.w),
                      )
                    : OutlineInputBorder(
                        borderRadius: radius,
                        borderSide: BorderSide.none,
                      ),
                focusedBorder: hasError
                    ? OutlineInputBorder(
                        borderRadius: radius,
                        borderSide:
                            BorderSide(color: AppColors.red, width: 1.5.w),
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
                        padding: EdgeInsets.only(left: 12.w, right: 8.w),
                        child: widget.prefixIcon,
                      )
                    : null,
                prefixIconConstraints: const BoxConstraints(),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(left: 8.w, right: 12.w),
                  child: widget.suffixIcon ??
                      AnimatedRotation(
                        turns: _isOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: CustomSvgImage(
   assetPath: 'assets/icons_assets/main_icons_assets/chevron_down.svg',
   width: 20.sp,
   height: 20.sp,
   fit: BoxFit.contain,
   colorFilter: ColorFilter.mode(
                            hasError
                                ? AppColors.red
                                : widget.enabled
                                    ? AppColors.text.withOpacity(0.6)
                                    : AppColors.text.withOpacity(0.3),
                            BlendMode.srcIn,
                          ),
 ),
                      ),
                ),
                suffixIconConstraints: const BoxConstraints(),
                hintText: isEmpty ? (widget.hint ?? '') : null,
                hintStyle: widget.hintStyle ??
                    StyleText.fontSize14Weight400.copyWith(
                      color: AppColors.text.withOpacity(0.4),
                    ),
                errorText: null,
              ),
              child: !isEmpty
                  ? Text(
                      _selectedText,
                      style: widget.valueStyle ??
                          StyleText.fontSize14Weight400.copyWith(
                            color: widget.enabled
                                ? AppColors.text
                                : AppColors.text.withOpacity(0.4),
                          ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),

        // ── Error / Helper ─────────────────────────────────
        if (hasError) ...[
          SizedBox(height: 4.h),
          Text(
            widget.errorText!,
            style: widget.errorStyle ??
                StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
          ),
        ] else if (widget.helperText != null) ...[
          SizedBox(height: 4.h),
          Text(
            widget.helperText!,
            style: widget.helperStyle ??
                StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.text.withOpacity(0.5)),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Overlay
// ─────────────────────────────────────────────────────────────────────────────

class _MultiSelectOverlay<T> extends StatelessWidget {
  final LayerLink layerLink;
  final Size triggerSize;
  final double verticalOffset;
  final bool openUpward;
  final List<MultiSelectDropdownItem<T>> items;
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
  final List<T> selectedValues;
  final ValueChanged<MultiSelectDropdownItem<T>> onToggle;
  final VoidCallback onDismiss;

  const _MultiSelectOverlay({
    required this.layerLink,
    required this.triggerSize,
    required this.verticalOffset,
    required this.openUpward,
    required this.items,
    required this.maxHeight,
    required this.itemHeight,
    required this.borderRadius,
    required this.elevation,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.selectedValues,
    required this.onToggle,
    required this.onDismiss,
    this.itemStyle,
    this.showDivider = false,
    this.dividerColor,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
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

          CompositedTransformFollower(
            link: layerLink,
            showWhenUnlinked: false,
            targetAnchor:
                openUpward ? Alignment.topLeft : Alignment.bottomLeft,
            followerAnchor:
                openUpward ? Alignment.bottomLeft : Alignment.topLeft,
            offset: Offset(
              0,
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
                      minWidth: triggerSize.width,
                      maxWidth: triggerSize.width,
                    ),
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: items.isEmpty
                          ? SizedBox(
                              height: itemHeight,
                              child: emptyWidget ??
                                  Center(
                                    child: Text(
                                      'No options',
                                      style: StyleText.fontSize13Weight400.copyWith(
                                        color: AppColors.text.withOpacity(0.4),
                                      ),
                                    ),
                                  ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: items.length,
                              separatorBuilder: (_, __) => showDivider
                                  ? Divider(
                                      height: 1.h,
                                      thickness: 1.h,
                                      color: dividerColor ??
                                          AppColors.text.withOpacity(0.08),
                                    )
                                  : const SizedBox.shrink(),
                              itemBuilder: (_, i) {
                                final item = items[i];
                                final isSelected =
                                    selectedValues.contains(item.value);
                                return _MultiSelectItemTile<T>(
                                  item: item,
                                  isSelected: isSelected,
                                  height: itemHeight,
                                  style: itemStyle,
                                  onTap: item.enabled
                                      ? () => onToggle(item)
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Item tile with checkbox + hover state
// ─────────────────────────────────────────────────────────────────────────────

class _MultiSelectItemTile<T> extends StatefulWidget {
  final MultiSelectDropdownItem<T> item;
  final bool isSelected;
  final double height;
  final TextStyle? style;
  final VoidCallback? onTap;

  const _MultiSelectItemTile({
    required this.item,
    required this.isSelected,
    required this.height,
    this.style,
    this.onTap,
  });

  @override
  State<_MultiSelectItemTile<T>> createState() =>
      _MultiSelectItemTileState<T>();
}

class _MultiSelectItemTileState<T> extends State<_MultiSelectItemTile<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null;

    return MouseRegion(
      cursor:
          isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: widget.height,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          // Selection is indicated by the checkbox only — no primary
          // background tint for selected items.
          color: _hovered && !isDisabled
              ? AppColors.primary
              : AppColors.transparent,
          child: Row(
            children: [
              CustomCheckBox(
                isSelected: widget.isSelected,
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              if (widget.item.leading != null) ...[
                widget.item.leading!,
                SizedBox(width: 8.w),
              ],
              Expanded(
                child: Text(
                  widget.item.label,
                  style: (widget.style ??
                          (widget.isSelected
                              ? StyleText.fontSize14Weight500
                              : StyleText.fontSize14Weight400))
                      .copyWith(
                    color: isDisabled
                        ? AppColors.text.withOpacity(0.3)
                        : _hovered
                            ? AppColors.textButton
                            : AppColors.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
