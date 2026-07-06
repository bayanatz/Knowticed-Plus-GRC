// Figma: "Overall" stats row — tiles with icon + label + count.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';

/// One stat tile entry. [icon] can be any widget (SVG, Icon...).
class StatItem {
  final String label;
  final String value;
  final Widget? icon;
  final VoidCallback? onTap;

  const StatItem({
    required this.label,
    required this.value,
    this.icon,
    this.onTap,
  });
}

/// "Overall" card: a responsive row of stat tiles
/// (Products 11 | Orders 11 | Warehouses 11 | ...).
class OverallStatsCard extends StatelessWidget {
  final String title;
  final List<StatItem> items;
  final double? width;

  const OverallStatsCard({
    super.key,
    this.title = 'Overall',
    required this.items,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      // Figma: card padding 16, radius 8, white bg + 2% shadow.
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
        boxShadow: CardStyles.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: CardStyles.title(16)),
          SizedBox(height: 12.h),
          LayoutBuilder(
            builder: (context, constraints) {
              // ~140w per tile, min 2 per row (mobile) max items.length.
              final perRow =
                  (constraints.maxWidth / 140.w).floor().clamp(2, items.length);
              final tileWidth =
                  (constraints.maxWidth - (perRow - 1) * 8.w) / perRow;
              return Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  for (final item in items)
                    SizedBox(width: tileWidth, child: _StatTile(item: item)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final StatItem item;

  const _StatTile({required this.item});

  @override
  Widget build(BuildContext context) {
    // Figma "Overall" tile: large line icon + [label above, count below],
    // no background box.
    return InkWell(
      onTap: item.onTap,
      borderRadius: CardStyles.radius(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: Row(
          children: [
            if (item.icon != null) ...[
              SizedBox(
                width: 40.r,
                height: 40.r,
                child: FittedBox(child: item.icon),
              ),
              SizedBox(width: 8.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    style: CardStyles.value(14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(item.value, style: CardStyles.title(16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
