/// Module: services / sv11_department_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: department_vertical_bar_chart.dart
/// Purpose: Requests per department as a vertical bar chart, with department
///          names in the reader's language.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/charts/vertical_bar_chart_widget.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

class DepartmentVerticalBarChart extends StatelessWidget {
  final String title;
  final String? iconAsset;
  final Map<String, int> departmentCounts;
  final Map<String, Color> departmentColors;
  final Map<String, String> enToArDepartments;
  final Widget? headerWidget;
  final double? maxY;
  final double? height;
  final double? width;
  final double? barWidth;
  final Color? iconBackgroundColor;
  final Color? backgroundColor;
  final double groupsSpace;
  final bool showGrid;
  final bool lightMode;

  const DepartmentVerticalBarChart({
    super.key,
    required this.title,
    required this.departmentCounts,
    required this.departmentColors,
    required this.enToArDepartments,
    this.iconAsset,
    this.headerWidget,
    this.maxY,
    this.height,
    this.width,
    this.barWidth,
    this.iconBackgroundColor,
    this.backgroundColor,
    this.groupsSpace = 15,
    this.showGrid = true,
    required this.lightMode,
  });

  /// The reader's name of a department stored as an id or a name.
  String _getDepartmentLabel(BuildContext context, String key, bool isArabic) {
    final name = context.svcDepartmentName(key);
    if (name != key) return name;
    return isArabic ? enToArDepartments[key] ?? key : key;
  }

  /// ✅ Prepare labels + values from departmentCounts dynamically
  /// ✅ Filter out departments with zero values
  Map<String, dynamic> _prepareData(BuildContext context, bool isArabic) {
    // ✅ Filter out departments with zero values
    final entries = departmentCounts.entries.where((e) => e.value > 0).toList();

    List<String> labels = entries
        .map((e) => _getDepartmentLabel(context, e.key, isArabic))
        .toList();

    List<double> values = entries.map((e) => e.value.toDouble()).toList();

    List<Color> colors = entries
        .map((e) => departmentColors[e.key] ?? AppColors.primary)
        .toList();

    // ✅ Reverse for Arabic RTL display
    if (isArabic) {
      labels = labels.reversed.toList();
      values = values.reversed.toList();
      colors = colors.reversed.toList();
    }

    return {'labels': labels, 'values': values, 'colors': colors};
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.svcIsArabic;
    final data = _prepareData(context, isArabic);
    final labels = data['labels'] as List<String>;
    final values = data['values'] as List<double>;

    return CustomVerticalBarChartWidget(
      title: title,
      iconAsset: iconAsset,
      labels: labels,
      values: values,
      headerWidget: headerWidget,
      maxY: maxY,
      height: height,
      width: width,
      barWidth: barWidth,
      barColor: AppColors.primary,
      iconBackgroundColor: iconBackgroundColor,
      backgroundColor: backgroundColor,
      groupsSpace: groupsSpace,
      showGrid: showGrid,
      lightMode: lightMode,
      showAllMonths: false,
    );
  }
}
