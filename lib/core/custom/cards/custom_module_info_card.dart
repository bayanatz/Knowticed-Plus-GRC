/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: module_info_card.dart
/// Description: Declares `ModuleInfoCard`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

// Figma node 6550:8690 — module info card (324x110) with compliance chip,
// plus the removable owner avatar chip and the AR/ENG language toggle
// from the same frame.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/cards/custom_card_styles.dart';

import 'package:grc_module/core/theme/app_animations.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

/// Module info card: leading icon box + title + info rows + yellow
/// compliance-score chip (bottom start) + last-update footer (bottom end)
/// + optional three-dot menu (top end).
///
/// ```dart
/// ModuleInfoCard(
///   title: 'Data Management',
///   infoRows: const [
///     CardInfo(label: 'Owner :', value: 'Amro Handousa'),
///     CardInfo(label: 'Creation Date:', value: '28 May 2020'),
///   ],
///   complianceScore: '-',
///   footerLabel: 'Last Update:',
///   footerValue: '28 May 2020',
///   onMenuTap: () {},
/// )
/// ```
class ModuleInfoCard extends StatelessWidget {
  final String title;
  final Widget? icon;

  /// Optional picture for the leading box -- an uploaded policy/module image.
  ///
  /// ADDED 14/9/2026. The box only ever rendered `icon ?? the default glyph`,
  /// and no caller passed `icon`, so an image a user had uploaded had nowhere
  /// to go and every card showed the same placeholder. When this is set the
  /// picture FILLS the 64x64 tile (BoxFit.cover) rather than being letterboxed
  /// into the 36x36 glyph slot -- a photo is a picture, not a glyph. Null,
  /// blank, still loading, or failed to load all fall back to [icon], and then
  /// to the default glyph, so nothing regresses for callers passing neither.
  final String? imageUrl;
  final List<CardInfo> infoRows;

  /// Value shown inside the yellow chip ("Compliance Score: [value]").
  /// Hidden when null.
  final String? complianceScore;
  final String complianceLabel;
  final String? footerLabel;
  final String? footerValue;
  final VoidCallback? onMenuTap;

  /// Optional key on the "..." button itself.
  ///
  /// A popup menu has to be positioned against the widget that opened it, and
  /// the only way to measure that widget from outside this card is to hold a
  /// key on it. Purely additive — leave it null and nothing changes.
  final Key? menuButtonKey;

  final VoidCallback? onTap;
  final double? width;

  const ModuleInfoCard({
    super.key,
    required this.title,
    this.icon,
    this.imageUrl,
    this.infoRows = const [],
    this.complianceScore,
    this.complianceLabel = 'Compliance Score:',
    this.footerLabel,
    this.footerValue,
    this.onMenuTap,
    this.menuButtonKey,
    this.onTap,
    this.width,
  });

  /// The uploaded picture filling the leading tile, or the glyph fallback.
  Widget _buildLeading() {
    final String url = imageUrl?.trim() ?? '';
    if (url.isEmpty) return _glyphLeading();
    return Image.network(
      url,
      width: 64.r,
      height: 64.r,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _glyphLeading(),
      loadingBuilder: (_, Widget child, ImageChunkEvent? progress) =>
          progress == null ? child : _glyphLeading(),
    );
  }

  Widget _glyphLeading() {
    return Center(
      child: SizedBox(
        width: 36.r,
        height: 36.r,
        child: FittedBox(child: icon ?? CardSvg.icon(CardSvg.services)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        InkWell(
          onTap: withHaptic(onTap, HapticLevel.low),
          borderRadius: CardStyles.radius(4),
          child: Container(
            width: width ?? 324.w,
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: CardStyles.radius(4),
              boxShadow: CardStyles.shadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leading box (64x64, light grey, radius 4): the
                    // uploaded image when there is one, the glyph otherwise.
                    Container(
                      width: 64.r,
                      height: 64.r,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: _buildLeading(),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: CardStyles.title(14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          for (final info in infoRows)
                            Padding(
                              padding: EdgeInsets.only(bottom: 3.h),
                              child: CardInfoRow(info: info, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (complianceScore != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '$complianceLabel $complianceScore',
                          style: CardStyles.title(12),
                        ),
                      ),
                    const Spacer(),
                    if (footerLabel != null || footerValue != null)
                      Text.rich(
                        TextSpan(
                          text: '${footerLabel ?? ''} ',
                          style: CardStyles.label(10),
                          children: [
                            TextSpan(
                              text: footerValue ?? '',
                              style: CardStyles.value(10),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (onMenuTap != null)
          // PositionedDirectional, not Positioned: `right` is a physical edge,
          // so the three-dot button stayed pinned to the screen's right in
          // Arabic while the rest of the card mirrored. `end` resolves to the
          // trailing edge — right in EN, left in AR. The other two overlays in
          // this Stack already use it.
          // D-03 diagonal cut, 10 / 10 (17/10/2026): the icon box (inside its
          // 2 tap padding) sits 10 from the top and from the side.
          PositionedDirectional(
            end: CardStyles.cornerInset - 2.r,
            top: CardStyles.cornerInset - 2.r,
            child: InkWell(
              key: menuButtonKey,
              onTap: withHaptic(onMenuTap, HapticLevel.low),
              borderRadius: CardStyles.radius(4),
              child: Padding(
                padding: EdgeInsets.all(2.r),
                child: Icon(
                  Icons.more_horiz,
                  size: 18.r,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
