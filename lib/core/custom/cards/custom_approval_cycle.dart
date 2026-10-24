/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: approval_cycle.dart
/// Purpose: Declares `ApprovalStep`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

// Reusable approval-cycle chain (extracted from
// services_management_module ApprovalCycleWidget / ApprovalCycleWidgetServices).
//
// - Mobile  : vertical chain — avatar + name/title, connected by a curved
//             elbow arrow (RTL aware).
// - Tablet  : horizontal chain wrapped into rows of [itemsPerRow], steps
//             separated by forward arrows.
//
// Self-contained: brings its own _CycleLinePainter so lib/core does not
// depend on feature modules.

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

/// One approver in the cycle.
class ApprovalStep {
  final String name;
  final String title;

  /// Optional custom avatar; defaults to the shared person SVG.
  final Widget? avatar;

  const ApprovalStep({required this.name, this.title = '', this.avatar});
}

/// ```dart
/// CustomApprovalCycle(
///   steps: const [
///     ApprovalStep(name: 'Ahmed Mohammed', title: 'Marketing Manager'),
///     ApprovalStep(name: 'Sara Ali', title: 'HR Specialist'),
///   ],
/// )
/// ```
class CustomApprovalCycle extends StatelessWidget {
  static const String _defaultAvatar =
      'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png';

  final List<ApprovalStep> steps;

  /// Steps per row in the tablet layout. Default 3.
  final int itemsPerRow;

  /// Force one layout regardless of screen size (null = auto by device).
  final bool? forceMobileLayout;

  /// Opt-in Figma connectors (Time Tracker owner I4, 13/10/2026): the mobile
  /// elbow arrow in [arrowColor] with a FILLED head, and [tabletArrow]
  /// (e.g. the Figma → SVG) between tablet steps instead of the chevron.
  /// Null keeps the original look for every other module.
  final Color? arrowColor;
  final Widget? tabletArrow;

  /// The size of the caller's [ApprovalStep.avatar] on the phone (ring and
  /// padding included). Null = the default 25 avatar. The phone arrows are
  /// drawn from this, so they start and end on the avatars' centres.
  final double? mobileAvatarSize;

  const CustomApprovalCycle({
    super.key,
    required this.steps,
    this.itemsPerRow = 3,
    this.forceMobileLayout,
    this.arrowColor,
    this.tabletArrow,
    this.mobileAvatarSize,
  });

  bool _isMobile(BuildContext context) =>
      forceMobileLayout ?? kpIsPhoneLayout(context);

  bool _isArabic(BuildContext context) =>
      Localizations.maybeLocaleOf(context)?.languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();
    return _isMobile(context) ? _mobileChain(context) : _tabletChain(context);
  }

  // ── Mobile: vertical chain with curved elbow connectors ────────────────
  //
  // REWRITTEN 22/10/2026 (Moataz: "the arrow has to be centred by the avatar
  // … and the arrow down"): the elbow used fixed offsets (line 15 in, head at
  // 30 down) that only met the centres of one avatar size. Now every avatar
  // sits in a [mobileAvatarSize] square slot and the connectors are drawn
  // from that slot: the line drops from the CENTRE of the first avatar, runs
  // the full height of each row (IntrinsicHeight, so no gap whatever the
  // text height) and each arrow head lands on the CENTRE line of its avatar.
  Widget _mobileChain(BuildContext context) {
    final bool isArabic = _isArabic(context);
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final Color color =
        arrowColor ?? (isLight ? AppColors.blackButton : AppColors.whiteShadow);
    final double slot = mobileAvatarSize ?? 25.sp;
    final double top = 10.sp;
    final double reach = 25.sp; // horizontal run of each arrow
    final bool more = steps.length > 1;

    Widget avatarSlot(ApprovalStep step) => SizedBox.square(
          dimension: slot,
          child: Center(child: _avatar(step, slot)),
        );
    Widget texts(ApprovalStep step) => Padding(
          padding: EdgeInsets.only(top: 12.sp),
          child: _nameAndTitle(context, step),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final ApprovalStep step = steps[index];
        final bool last = index == steps.length - 1;
        final Widget left = index == 0
            // First step: its avatar, then the line leaving its centre.
            ? SizedBox(
                width: slot,
                child: Column(
                  children: [
                    SizedBox(height: top),
                    avatarSlot(step),
                    if (more)
                      Expanded(
                        child: CustomPaint(
                          painter: _CycleLinePainter(
                            color: color,
                            isArabic: isArabic,
                            spineX: slot / 2,
                            elbowY: null,
                            down: true,
                            filledHead: arrowColor != null,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                  ],
                ),
              )
            // Later steps: the spine continues down (unless last) and an
            // arrow turns right into this avatar's centre.
            : SizedBox(
                width: slot / 2 + reach,
                child: CustomPaint(
                  painter: _CycleLinePainter(
                    color: color,
                    isArabic: isArabic,
                    spineX: slot / 2,
                    elbowY: top + slot / 2,
                    down: !last,
                    filledHead: arrowColor != null,
                  ),
                  child: const SizedBox.expand(),
                ),
              );
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              left,
              if (index != 0)
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: top),
                    child: avatarSlot(step),
                  ),
                ),
              SizedBox(width: 8.sp),
              Align(alignment: Alignment.topLeft, child: texts(step)),
            ],
          ),
        );
      }),
    );
  }

  // ── Tablet: rows of [itemsPerRow] steps with forward arrows ───────────
  Widget _tabletChain(BuildContext context) {
    final rows = <List<int>>[];
    for (var i = 0; i < steps.length; i += itemsPerRow) {
      rows.add(List<int>.generate(
          (i + itemsPerRow).clamp(0, steps.length) - i, (j) => i + j));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(rows.length, (rowIndex) {
        return Padding(
          padding: EdgeInsets.only(
            top: rowIndex == 0 ? 0 : 10.h,
            left: rowIndex == 0 ? 0 : 30.w,
          ),
          child: Row(
            children: [
              for (final index in rows[rowIndex]) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _avatar(steps[index], 35.r),
                    SizedBox(width: 4.w),
                    _nameAndTitle(context, steps[index]),
                  ],
                ),
                if (index != steps.length - 1)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: tabletArrow ??
                        CustomSvgImage(
                          assetPath:
                              "assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg",
                          color: AppColors.secondaryText,
                        ),
                  ),
              ],
            ],
          ),
        );
      }),
    );
  }

  // ── Shared pieces ──────────────────────────────────────────────────────
  Widget _avatar(ApprovalStep step, double size) {
    return ClipOval(
      child: step.avatar ??
          CustomSvgImage(
            assetPath: _defaultAvatar,
            width: size,
            height: size,
            fit: BoxFit.scaleDown,
          ),
    );
  }

  Widget _nameAndTitle(BuildContext context, ApprovalStep step) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.name,
          style: StyleText.fontSize12Weight500.copyWith(
            color: isLight ? AppColors.blackButton : AppColors.white,
          ),
        ),
        if (step.title.isNotEmpty) ...[
          SizedBox(height: 3.sp),
          Text(
            step.title,
            style: StyleText.fontSize10Weight400.copyWith(
              color: isLight ? AppColors.secondaryText : AppColors.grey,
            ),
          ),
        ],
      ],
    );
  }
}

/// The phone connector (22/10/2026). In this box's own coordinates: a
/// vertical line at [spineX] from the top — down to the bottom when [down],
/// else to [elbowY] — and, when [elbowY] is set, an arrow from the spine to
/// the box's far edge at [elbowY]. Mirrored for Arabic.
class _CycleLinePainter extends CustomPainter {
  _CycleLinePainter({
    required this.color,
    required this.isArabic,
    required this.spineX,
    required this.elbowY,
    required this.down,
    required this.filledHead,
  });

  final Color color;
  final bool isArabic;
  final double spineX;
  final double? elbowY;
  final bool down;
  final bool filledHead;

  @override
  void paint(Canvas canvas, Size size) {
    double x(double v) => isArabic ? size.width - v : v;
    final Paint line = Paint()
      ..color = color
      ..strokeWidth = filledHead ? 2 : 2.5
      ..style = PaintingStyle.stroke;
    final double? y = elbowY;
    canvas.drawLine(Offset(x(spineX), 0),
        Offset(x(spineX), down || y == null ? size.height : y), line);
    if (y == null) return;
    const double head = 6;
    final double tip = size.width - 2;
    canvas.drawLine(Offset(x(spineX), y), Offset(x(tip - 1), y), line);
    final Path arrow = Path()
      ..moveTo(x(tip - head), y - head)
      ..lineTo(x(tip), y)
      ..lineTo(x(tip - head), y + head);
    if (filledHead) {
      arrow.close();
      canvas.drawPath(
          arrow,
          Paint()
            ..color = color
            ..style = PaintingStyle.fill);
    } else {
      canvas.drawPath(arrow, line);
    }
  }

  @override
  bool shouldRepaint(covariant _CycleLinePainter old) =>
      old.color != color ||
      old.isArabic != isArabic ||
      old.spineX != spineX ||
      old.elbowY != elbowY ||
      old.down != down ||
      old.filledHead != filledHead;
}
