// Shared shell + helpers for the chart widgets (Figma CHARTS section).
// Same style language as the card widgets: AppColors theme + screenutil.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/core/custom/16-custom_card_styles.dart';

/// SVG icon assets used by the chart widgets.
/// All paths point to existing, pubspec-declared assets in assets/icons_assets.
abstract class ChartSvg {
  static const String products = 'assets/icons_assets/home_assets/inventory_products_box.svg';
  static const String orders = 'assets/icons_assets/home_assets/service_requests_document.svg';
  static const String warehouse = 'assets/icons_assets/roles_assets/inventory_warehouse.svg';
  static const String lowStock = 'assets/icons_assets/home_assets/inventory_damaged_box.svg';
  static const String supplier = 'assets/icons_assets/services_assets/building_office.svg';
  static const String request = 'assets/icons_assets/settings_assets/requests_edit_document.svg';
  static const String present = 'assets/icons_assets/main_icons_assets/check_circle_green.svg';
  static const String absent = 'assets/icons_assets/main_icons_assets/prohibited_circle.svg';
  static const String late = 'assets/icons_assets/main_icons_assets/clock_circle.svg';
  static const String vacation = 'assets/icons_assets/home_assets/todo_scheduled_calendar.svg';
  static const String excused = 'assets/icons_assets/settings_assets/request_change_document.svg';
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
                  child: CustomSvgImage(
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

/// Whether a bar chart renders vertically ([BarChartCard], 26) or
/// horizontally ([HorizontalBarChartCard], 28).
///
/// Moved here from the removed
/// home/h1_home_page/presentation/ui/services_management_module/dashboard_view_data/, so the chart
/// cards and the enum that selects between them live together in core.
enum ChartOrientation {
  horizontal,
  vertical;

  /// Convert enum to string for Firestore storage
  String toFirestore() => name;

  /// Create enum from Firestore string
  static ChartOrientation fromFirestore(String value) {
    switch (value.toLowerCase()) {
      case 'horizontal':
        return ChartOrientation.horizontal;
      case 'vertical':
        return ChartOrientation.vertical;
      default:
        return ChartOrientation.vertical; // Default fallback
    }
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
