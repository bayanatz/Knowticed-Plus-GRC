/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/analytics_tab
/// ************************* FILE INFO *************************** ///
/// File Name: document_utilization_chart.dart
/// Description: Document utilization chart — Submission Details (S5) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_card.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/charts/custom_donut_chart_card.dart';

Widget buildDocumentUtilizationChart(
  BuildContext context,
  bool lightMode, {
  required int totalViews,
  required int totalDownloads,
}) {
  final total = totalViews + totalDownloads;

  // Prepare data for DonutChartCard.
  //
  // Counts, not percentages. The legend here showed
  // "Views 33 / Downloads 66" beside a centre total of 6, because
  // [DonutChartCard] prints `ChartData.value` as the legend amount and this
  // passed the percentage. The ring is identical either way (it divides each
  // value by their sum), so only the legend changes. See the fuller note in
  // departments_chart.dart.
  final chartData = [
    ChartData(
      label: S.of(context).views,
      value: totalViews.toDouble(),
      color: AppColors.chartYellow,
    ),
    ChartData(
      label: S.of(context).downloads,
      value: totalDownloads.toDouble(),
      color: AppColors.colorGrey,
    ),
  ];

  // Prepare value labels (counts)
  [totalViews.toString(), totalDownloads.toString()];

  return DonutChartCard(
    title: S.of(context).document_utilization,
    dotIcon: "assets/icons_assets/main_icons_assets/ic_status.svg",
    // KH vertical report p.16: Arabic-Indic digits in Arabic, like the legend.
    centerValue: KhLocale.digits(context, total),
    centerLabel: S.of(context).total,
    sections: chartData,
  );
}
