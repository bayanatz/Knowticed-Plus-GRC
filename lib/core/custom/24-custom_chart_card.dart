// Shared shell + helpers for the chart widgets (Figma CHARTS section).
// Same style language as the card widgets: AppColors theme + screenutil.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/custom/32-custom_svg.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';

/// SVG icon assets used by the chart widgets.
/// All paths point to existing, pubspec-declared assets in assets/icons_assets.
abstract class ChartSvg {
  static const String _inventory = 'assets/icons_assets/inventory_assets';
  static const String _hr = 'assets/icons_assets/todo_new_assets';

  static const String products = '$_inventory/product.svg';
  static const String orders = '$_inventory/order.svg';
  static const String warehouse = '$_inventory/warehouses.svg';
  static const String lowStock = '$_inventory/low_stocks.svg';
  static const String supplier = '$_inventory/suppliers.svg';
  static const String request = '$_inventory/requests.svg';
  static const String present = '$_hr/hrPresent.svg';
  static const String absent = '$_hr/hrabcent.svg';
  static const String late = '$_hr/hrLate.svg';
  static const String vacation = '$_hr/hrVacation.svg';
  static const String excused = '$_hr/hrExcuseLeave.svg';
}

/// White rounded container with the standard chart header:
/// [yellow dot] Title ........................ [trailing controls]
class ChartCard extends StatelessWidget {
  final String title;
  final Color? dotColor;
  final Widget? trailing;
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final String? dotIcon; // ← add this

  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.dotColor,
    this.trailing,
    this.width,
    this.height,
    this.padding,
    this.dotIcon, // ← add this
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      // Figma: card padding 16.
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
        boxShadow: CardStyles.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Header marker: a tinted SVG icon when [dotIcon] is given,
              // otherwise the standard small colored dot.
              if (dotIcon != null)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle
                  ),
                  child: CustomSvg(
                    assetPath: dotIcon!,
                    width: 20.r,
                    height: 20.r,
                    color: AppColors.textButton,
                  ),
                )
              else
                Container(
                  width: 10.r,
                  height: 10.r,
                  decoration: BoxDecoration(
                    color: dotColor ?? AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  title,
                  style: CardStyles.title(14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

/// One data entry for charts: label + value + color.
class ChartData {
  final String label;
  final double value;
  final Color? color;

  const ChartData({required this.label, required this.value, this.color});
}

/// Legend row item: [colored dot] Name ..... Amount
class ChartLegendRow extends StatelessWidget {
  final String name;
  final String? amount;
  final Color color;
  final double fontSize;

  const ChartLegendRow({
    super.key,
    required this.name,
    required this.color,
    this.amount,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Container(
            width: 10.r,
            height: 10.r,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              name,
              style: CardStyles.label(fontSize),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (amount != null)
            Text(amount!, style: CardStyles.value(fontSize)),
        ],
      ),
    );
  }
}

/// Compact horizontal legend (dot + name) used above grouped charts.
class ChartLegendInline extends StatelessWidget {
  final List<ChartData> items;
  final double fontSize;

  const ChartLegendInline({super.key, required this.items, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 4.h,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8.r,
                height: 8.r,
                decoration: BoxDecoration(
                    color: item.color ?? AppColors.primary,
                    shape: BoxShape.circle),
              ),
              SizedBox(width: 4.w),
              Text(item.label, style: CardStyles.label(fontSize)),
            ],
          ),
      ],
    );
  }
}

/// Small yellow pill tab (e.g. "Consumables") used in chart headers.
class ChartTabPill extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color? color;

  const ChartTabPill({super.key, required this.text, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: color ?? AppColors.primary,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          text,
          style: CardStyles.title(11).copyWith(color: AppColors.textButton),
        ),
      ),
    );
  }
}
