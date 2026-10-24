/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/analytics_tab
/// ************************* FILE INFO *************************** ///
/// File Name: downloads_chart.dart
/// Description: Downloads chart — Submission Details (S5) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/analytics_tab/departments_bar_chart.dart'
    show kSubmissionChartHeight;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/charts/custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_card.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class DownloadsChart extends StatefulWidget {
  final bool lightMode;
  final Map<String, int> downloadsData;
  final Map<String, int> viewsData;

  const DownloadsChart({
    super.key,
    required this.lightMode,
    required this.downloadsData,
    required this.viewsData,
  });

  @override
  State<DownloadsChart> createState() => _DownloadsChartState();
}

class _DownloadsChartState extends State<DownloadsChart> {
  bool isDownloadsView = true; // true = Downloads, false = Views

  /// The Views / Downloads switch shown in the card's header.
  Widget _buildToggle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            label: S.of(context).views,
            selected: !isDownloadsView,
            onTap: () => setState(() => isDownloadsView = false),
          ),
          _buildToggleOption(
            label: S.of(context).downloads,
            selected: isDownloadsView,
            onTap: () => setState(() => isDownloadsView = true),
          ),
        ],
      ),
    );
  }

  /// One option of [_buildToggle].
  Widget _buildToggleOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.transparent,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            label,
            style: StyleText.fontSize14Weight500.copyWith(
              color: selected ? AppColors.textButton : AppColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current data based on selected view
    final currentData = isDownloadsView
        ? widget.downloadsData
        : widget.viewsData;

    final months = currentData.keys.toList();
    final values = currentData.values.map((v) => v.toDouble()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          // No fixed height on a phone.
          //
          // This box used to be 300.h, which happened to match the card's
          // content almost exactly. Once [BarChartCard] moved the
          // Views/Downloads control onto its own row (so the title stops being
          // ellipsised), the content no longer matched the box: too tall and it
          // overflowed, too short and the surplus showed as a band of empty
          // card under the month labels — a fixed height cannot be right for
          // both states of the toggle on every phone size anyway.
          //
          // Null lets the card be exactly as tall as it needs to be. Nothing
          // here needs a fixed height: the analytics tab is a scrolling column,
          // so the card just takes its own height and the page scrolls.
          //
          // And not on desktop either. the 12/9 change
          // only freed the phone, so desktop kept the 300.h and kept the exact
          // symptom described above: the content comes out around 270 and the
          // remaining ~30 painted as a band of empty card under the month
          // labels ("big padding in desktop from bottom"). [ChartCard] does
          // not stretch its child to a fixed height unless `expandChild` is
          // set, so the surplus had nowhere to go but the bottom. The
          // reasoning above was never phone-specific — it applies here too.
          height: null,
          child: BarChartCard(
            trailing: _buildToggle(context),
            key: ValueKey(isDownloadsView),
            title: isDownloadsView
                ? S.of(context).numberOfDownloads
                : S.of(context).numberOfViews,
            dotIcon: "assets/icons_assets/main_icons_assets/ic_action_cloud_download.svg",
            dotColor: AppColors.primary,
            bars: List.generate(
              months.length,
              (i) => ChartData(
                // Keys are 'yyyy-MM'; show the month in the UI language.
                label: KhLocale.formatDate(
                  context,
                  DateTime.parse('${months[i]}-01'),
                  'MMM',
                ),
                value: values[i],
              ),
            ),
            chartHeight: kSubmissionChartHeight, // KH p.26
            barWidth: 40,
            barColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

// Updated helper function
Widget buildDownloadsChart(
  bool lightMode, {
  required Map<String, int> downloadsData,
  required Map<String, int> viewsData,
}) {
  return DownloadsChart(
    lightMode: lightMode,
    downloadsData: downloadsData,
    viewsData: viewsData,
  );
}
