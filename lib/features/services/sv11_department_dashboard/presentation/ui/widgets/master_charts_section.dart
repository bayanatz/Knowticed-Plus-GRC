/// Module: services / sv11_department_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: master_charts_section.dart
/// Purpose: All chart widgets for DashBoard Master (admin + employee modes)
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/ui/widgets/bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/controller/dashboard_master_cubit.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/controller/dashboard_master_state.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/ui/widgets/canceled_and_rejected_chart.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/charts/dynamic_number_of_services.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/ui/widgets/first_section_pie_chart_with_labels.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/ui/widgets/service_comparison_chart.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/charts/vertical_bar_chart_widget.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/charts/horizontal_bar_chart_widget.dart';

import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/ui/widgets/department_vertical_bar_chart.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_donut_chart_card.dart';

class MasterChartsSection extends StatelessWidget {
  final DashboardMasterState state;
  final DashboardMasterCubit cubit;
  final bool isAdmin;
  final String? adminSelectedDepartment;
  final bool isArabic;

  const MasterChartsSection({
    super.key,
    required this.state,
    required this.cubit,
    required this.isAdmin,
    required this.adminSelectedDepartment,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Column(
      children: [
        // ── Pie charts (Dept + Status) ────────────────────────────────────
        DepartmentPieChartsSection(
          departmentCounts: state.departmentCounts,
          statusCounts: state.statusCounts,
          enToArDepartments: state.enToArDepartments,
          isLoadingDepartments: state.isLoadingDepartments,
          isLoadingStatus: state.isLoadingFirst,
          departmentText: S.of(context).department,
          statusOfServicesText: S.of(context).StatusOfServices,
          doneText: S.of(context).Done,
          approvedText: S.of(context).Approved,
          pendingText: S.of(context).Pending,
          inprogressText: S.of(context).Inprogress,
          breachedSLAText: S.of(context).BreachedSLA,
          rejectedText: S.of(context).Rejected,
          canceledText: S.of(context).Canceled,
          loadingWidget: const CircleProgressMaster(),
          pieChartBuilder: (headerImage, title, total, numberList, data) =>
              DonutChartCard(
            title: title,
            dotIcon: headerImage,
            centerValue: total,
            sections: [
              for (int i = 0; i < data.length; i++)
                ChartData(
                  label: data[i].$1,
                  // Segment value = the raw count (numberList) when
                  // available, otherwise fall back to the percentage.
                  value: i < numberList.length
                      ? (double.tryParse(numberList[i]) ?? data[i].$3)
                      : data[i].$3,
                  color: data[i].$2,
                ),
            ],
          ),
          loadingBackgroundColor: AppColors.card,
          departmentColors: state.departmentColors,
          statusColors: {
            'done': AppColors.chartGreen,
            'approved': AppColors.green,
            'pending': AppColors.orange,
            'inprogress': AppColors.chartYellow,
            'branchsla': AppColors.red,
            'rejected': AppColors.chartCrimson,
            'cancel': AppColors.chartDarkRed,
          },
        ),

        SizedBox(height: 15.sp),

        // ── Department bar chart ──────────────────────────────────────────
        // Renamed (bug report p26): the donut above is also titled
        // "Department", so the two cards read as duplicates.
        DepartmentVerticalBarChart(
          title: S.of(context).requestsByDepartment,
          iconAsset: isAdmin
              ? 'assets/icons_assets/main_icons_assets/ic_org_briefcase.svg'
              : 'assets/icons_assets/main_icons_assets/ic_org_briefcase.svg',
          departmentCounts: state.departmentCounts,
          departmentColors: state.departmentColors,
          enToArDepartments: state.enToArDepartments,
          lightMode: lightMode,
          showGrid: true,
          height: isAdmin ? 320 : 300,
        ),

        SizedBox(height: 15.sp),

        // ── Services offered ──────────────────────────────────────────────
        _buildServicesOfferedChart(context, lightMode),

        SizedBox(height: 15.sp),

        // ── Number of services / total hours ──────────────────────────────
        _buildNumberOfServicesChart(context, lightMode),

        SizedBox(height: 15.sp),

        // ── Rejected / Canceled ───────────────────────────────────────────
        _buildRejectedCanceledChart(context, lightMode),

        if (!isAdmin) ...[
          SizedBox(height: 20.sp),
          // ── Monthly comparison (employee mode only) ────────────────────
          ServiceComparisonChart(lightMode: lightMode),
        ],
      ],
    );
  }

  Widget _buildServicesOfferedChart(BuildContext context, bool lightMode) {
    if (state.isLoadingServicesName) {
      return _loadingContainer(lightMode);
    }

    final orientation = ChartOrientation.vertical;
    final labels = isArabic ? state.serviceNamesArabic : state.serviceNames;
    final values = state.serviceUsageCounts.values.toList();

    if (orientation == ChartOrientation.horizontal) {
      return CustomHorizontalBarChartWidget(
        height: 300,
        title: S.of(context).servicesOffered,
        iconAsset:
            'assets/icons_assets/main_icons_assets/ic_module_support_headset.svg',
        labels: labels,
        values: values,
        barHeight: 15,
        lightMode: lightMode,
        backgroundColor: AppColors.card,
      );
    }

    return CustomVerticalBarChartWidget(
      title: S.of(context).servicesOffered,
      iconAsset:
          'assets/icons_assets/main_icons_assets/ic_module_support_headset.svg',
      labels: labels,
      values: values,
      barWidth: 20,
      lightMode: lightMode,
      height: 300,
      backgroundColor: AppColors.card,
      barColor: AppColors.primary,
      showGrid: true,
      groupsSpace: 30,
    );
  }

  Widget _buildNumberOfServicesChart(BuildContext context, bool lightMode) {
    if (state.isLoading) {
      return _loadingContainer(lightMode);
    }

    return DynamicNumberOfServicesChart(
      monthCounts: state.monthCounts,
      monthHours: state.monthHours,
      isLoading: state.isLoading,
      buildBarGroups: buildBarGroups,
      onFetchServiceCounts: () => cubit.toggleChartMode(showCount: true),
      onFetchDurationHours: () => cubit.toggleChartMode(showCount: false),
      numberOfServicesText: S.of(context).numberOfServices,
      noOfServiceText: S.of(context).NoOfService,
      totalHoursText: S.of(context).svcPlannedHours,
      loadingWidget: const CircleProgressMaster(),
      primaryColor: AppColors.primary,
      buttonTextColor: AppColors.textButton,
      lightMode: lightMode,
      orientation: ChartOrientation.vertical,
      isHours: state.isHoursMode, // ✅ NEW: Pass toggle state from cubit
    );
  }

  Widget _buildRejectedCanceledChart(BuildContext context, bool lightMode) {
    if (state.isLoadingRejectedCanceled) {
      return _loadingContainer(lightMode);
    }

    return DynamicRejectedCanceledChart(
      monthRejected: state.monthRejected,
      monthCanceled: state.monthCanceled,
      isLoading: state.isLoadingRejectedCanceled,
      buildBarGroups: buildBarGroups,
      // Both series are computed on load; switching needs no reload.
      onFetchRejectedCounts: () {},
      onFetchCanceledCounts: () {},
      titleText: S.of(context).serviceStatus,
      rejectedText: S.of(context).Rejected,
      canceledText: S.of(context).Canceled,
      loadingWidget: const CircleProgressMaster(),
      primaryColor: AppColors.primary,
      buttonTextColor: AppColors.textButton,
      lightMode: lightMode,
      orientation: ChartOrientation.vertical,
    );
  }

  Widget _loadingContainer(bool lightMode) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Center(child: CircleProgressMaster()),
      );
}
