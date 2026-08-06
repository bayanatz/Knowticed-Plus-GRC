/// Module: Core · Custom · Hover Tooltip
/// Description: Warning icon that reveals a bulleted tooltip in an Overlay on
///              hover (desktop) or tap (touch, auto-hides after 2s). The popup
///              is clamped to the screen and flips below the icon when there
///              isn't room above. Mirrors for RTL.
/// Author: Knowticed Team

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/core/theme/app_colors.dart';

class HoverExample extends StatefulWidget {
  const HoverExample({required this.subtitle, super.key});
  final String subtitle;

  @override
  State<HoverExample> createState() => _HoverExampleState();
}

class _HoverExampleState extends State<HoverExample> {
  OverlayEntry? _overlayEntry;
  final iconKey = GlobalKey();

  void _showPopup(BuildContext context) {
    final renderBox = iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;
    final popupWidth = 260.sp;

    // Calculate horizontal position — clamp so it stays on screen
    double left;
    if (context.isArabic) {
      // Try to position to the right of the icon
      left = offset.dx - popupWidth + 20.w;
    } else {
      // Try to position to the left of the icon
      left = offset.dx - popupWidth / 2;
    }

    // Clamp to screen bounds with padding
    left = left.clamp(8.0, screenSize.width - popupWidth - 8.0);

    // Position above the icon; if not enough space, show below
    double top = offset.dy - 30.h;
    if (top < 8) {
      top = offset.dy + renderBox.size.height + 8;
    }

    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: left,
        top: top,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(8),
            width: popupWidth,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '• ',
                    style: TextStyle(fontSize: 18, color: AppColors.text),
                  ),
                  TextSpan(
                    text: widget.subtitle,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.text),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hidePopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hidePopup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      key: iconKey,
      onEnter: (event) => _showPopup(context),
      onExit: (event) => _hidePopup(),
      child: InkWell(
        onTap: () {
          if (_overlayEntry != null) {
            _hidePopup();
            return;
          }
          _showPopup(context);
          Future.delayed(const Duration(seconds: 2), _hidePopup);
        },
        splashColor: Colors.transparent,
        child: SvgPicture.asset(
          // Original pointed at main_icons_assets/warning.svg, which doesn't
          // exist in this project. Swap if you'd prefer a different icon.
          "assets/icons_assets/main_icons_assets/warning_exclamation_circle.svg",
          width: 15.w,
          height: 15.h,
          colorFilter: ColorFilter.mode(
            AppColors.text,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
