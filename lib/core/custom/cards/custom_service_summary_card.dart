/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: service_summary_card.dart
/// Description: Declares `CustomServiceCard`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

// Figma node 6550:9782 — small service summary card (325x100).
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// Compact card: leading icon box + title + info rows + footer date.
///
/// ```dart
/// CustomServiceCard(
///   title: 'Market Research Service',
///   icon: Icon(Icons.headset_mic_outlined),
///   infoRows: const [
///     CardInfo(label: 'Done Services:', value: '120'),
///     CardInfo(label: 'Total Hours:', value: '40'),
///   ],
///   footerLabel: 'Start Date:',
///   footerValue: '28 Dec 2023',
/// )
/// ```
class CustomServiceCard extends StatelessWidget {
  final String title;
  final Widget? icon;
  final List<CardInfo> infoRows;
  final String? footerLabel;
  final String? footerValue;
  final VoidCallback? onTap;
  final double? width;

  const CustomServiceCard({
    super.key,
    required this.title,
    this.icon,
    this.infoRows = const [],
    this.footerLabel,
    this.footerValue,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: withHaptic(onTap, HapticLevel.low),
      borderRadius: CardStyles.radius(),
      child: Container(
        width: width ?? 325.w,
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: CardStyles.radius(),
          boxShadow: CardStyles.shadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading icon box (80x80, light grey, radius 4).
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Center(
                child: SizedBox(
                  width: 40.r,
                  height: 40.r,
                  child: FittedBox(
                    child: icon ?? CardSvg.icon(CardSvg.services),
                  ),
                ),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 3.h),
                  Text(
                    title,
                    style: CardStyles.title(14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  for (final info in infoRows)
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: CardInfoRow(info: info, fontSize: 12),
                    ),
                  if (footerLabel != null || footerValue != null)
                    Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: Text.rich(
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
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
