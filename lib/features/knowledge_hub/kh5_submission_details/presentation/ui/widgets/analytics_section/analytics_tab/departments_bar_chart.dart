/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/analytics_tab
/// ************************* FILE INFO *************************** ///
/// File Name: departments_bar_chart.dart
/// Description: Departments bar chart — Submission Details (S5) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/charts/custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_card.dart';

/// The plot height shared by the Downloads and Departments charts on the
/// Submission details Analytics tab, so the two cards match (KH p.26).
/// A raw design number: [BarChartCard] applies `.h` itself.
const double kSubmissionChartHeight = 240;

Widget buildDepartmentsBarChart(
  BuildContext context,
  bool lightMode, {
  required Map<String, int> departmentData,
}) {
  // Get department controller and check language

  // Localize department names
  final localizedDepartments = departmentData.keys.map((department) {
    return department.isEmpty
        ? S.of(context).khUnknownDepartment
        : KhLocale.department(context, department);
  }).toList();

  final values = departmentData.values.map((v) => v.toDouble()).toList();

  return Container(
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(8.r),
    ),
    // "bottom overflowed by 77 pixels" on a phone.
    //
    // Two things fought here. `chartHeight: 280.h` below is scaled TWICE —
    // [BarChartCard.chartHeight] is documented as a raw design number and the
    // card applies `.h` itself — so the plot asked for ~325 rather than 280.
    // Add the card's header, its 12 gap and 16+16 padding and the content
    // wanted ~400 inside a box pinned to 300.h (~323). The difference is the 77.
    //
    // On a phone the box is now unpinned (the card is as tall as it needs to be
    // — the analytics tab scrolls) and the raw 280 is passed through once.
    //
    // Desktop is unpinned too. 280.h of plot plus the
    // header and the card's own padding wants ~350, so pinning the box to
    // 300.h was asking the content to fit in less than it needs; the same
    // "fixed height cannot be right" argument that freed the phone applies
    // here. Unpinned, the card is exactly as tall as its content and the
    // analytics tab (a scrolling column) absorbs the difference.
    height: null,
    child: BarChartCard(
      title: S.of(context).departments,
      dotIcon: 'assets/icons_assets/knowledge_hub_assets/ic_org_department_chart.svg',
      dotColor: AppColors.primary,
      bars: List.generate(
        localizedDepartments.length,
        (i) => ChartData(label: localizedDepartments[i], value: values[i]),
      ),
      // 14/10/2026 — KH report p.26 "height of these two charts not
      // same": the Downloads chart above uses the default plot height
      // while this one asked for 280.h (scaled twice on desktop, see
      // above). Both now use the one raw design number.
      chartHeight: kSubmissionChartHeight,
      barWidth: 40,
      barColor: AppColors.primary,
    ),
  );
}
