/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/analytics_tab
/// ************************* FILE INFO *************************** ///
/// File Name: departments_chart.dart
/// Description: Departments chart — Submission Details (S5) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_card.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/charts/custom_donut_chart_card.dart';

Widget buildDepartmentsChart(
  BuildContext context,
  bool lightMode, {
  required Map<String, int> departmentData,
  required int totalCount,
  Map<String, String>?
  enToArDepartments, // Can keep for backwards compatibility but won't use
}) {
  // Get department controller and check language

  // Dynamic color assignment based on available departments
  final defaultColors = AppColors.chartPalette;

  // Assign colors dynamically to departments
  int colorIndex = 0;
  final departmentColors = <String, Color>{};
  for (var key in departmentData.keys) {
    departmentColors[key] = defaultColors[colorIndex % defaultColors.length];
    colorIndex++;
  }

  // Helper function to localize department name
  String getLocalizedDepartmentName(String departmentName) =>
      departmentName.isEmpty
      ? S.of(context).khUnknownDepartment
      : KhLocale.department(context, departmentName);

  // Prepare data for DonutChartCard.
  //
  // The legend printed PERCENTAGES where the counts belong.
  // A card reading "Total 6" listed "Marketing 83 / Information Technology 16",
  // because `value` was set to `_getPercentage(...)` and [DonutChartCard]
  // prints `s.value` as the legend amount. The ring was right either way: it
  // derives each segment from `s.value / total`, which is the same proportion
  // whether the values are counts or percentages of those counts.
  //
  // So the RAW COUNT goes in: the ring is unchanged and the legend now agrees
  // with the centre total. The local `_getPercentage` helper went with it —
  // the ring still prints a percentage on each segment, but the card works
  // that out itself from the values it is given.
  final chartData = departmentData.entries.map((e) {
    final color = departmentColors[e.key] ?? AppColors.colorGreyDark;
    final displayLabel = getLocalizedDepartmentName(
      e.key,
    ); // Use localized name

    return ChartData(
      label: displayLabel,
      value: e.value.toDouble(),
      color: color,
    );
  }).toList();

  // Prepare value labels (counts)
  departmentData.entries.map((e) => e.value.toString()).toList();

  return DonutChartCard(
    title: S.of(context).department,
    dotIcon: "assets/icons_assets/main_icons_assets/ic_org_briefcase.svg",
    // KH vertical report p.16: Arabic-Indic digits in Arabic, like the legend.
    centerValue: KhLocale.digits(context, totalCount),
    centerLabel: S.of(context).total,
    sections: chartData,
  );
}
