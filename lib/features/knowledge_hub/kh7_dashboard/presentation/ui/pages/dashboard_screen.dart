/// Module: knowledge_hub/kh7_dashboard/presentation/ui/pages
/// ************************* FILE INFO *************************** ///
/// File Name: dashboard_screen.dart
/// Description: Knowledge Hub dashboard screen.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/charts/custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_donut_chart_card.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/features/knowledge_hub/helpers/format_helper.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/domain/use_cases/dashboard_statistics.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/presentation/controller/dashboard_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/presentation/controller/dashboard_states.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/presentation/ui/widgets/dashboard_monthly_chart.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/presentation/ui/widgets/department_filter.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/presentation/ui/widgets/knowledge_hub_resources.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/presentation/ui/widgets/monthly_comparison_knowledge_chart.dart';

const String _emptyAnimation =
    'assets/lottie_assets/main_lottie_assets/lot_empty_state.json';

class DashboardScreenKnow extends StatefulWidget {
  const DashboardScreenKnow({super.key});

  @override
  State<DashboardScreenKnow> createState() => _DashboardScreenKnowState();
}

class _DashboardScreenKnowState extends State<DashboardScreenKnow> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().fetchDashboardData();
  }

  Color _departmentColor(String departmentId) {
    final List<Color> colors = [
      AppColors.greyDark,
      AppColors.primary,
      AppColors.secondaryPrimary,
      AppColors.secondaryBlack,
      AppColors.navyBlue,
    ];
    return colors[departmentId.hashCode.abs() % colors.length];
  }

  String _departmentName(
    BuildContext context,
    DashboardLoaded state,
    String id,
  ) => KhLocale.pick(
    context,
    en: FormatHelper.capitalize(state.departmentNamesEn[id] ?? id),
    ar: state.departmentNamesAr[id] ?? '',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: SideFrameMasterServices(
          titleText: S.of(context).knowledge_hub,
          secondTitle: S.of(context).dashboard,
          onFirstTap: () => Navigator.pop(context),
          child: BlocBuilder<DashboardCubit, DashboardStates>(
            builder: (context, state) {
              if (state is DashboardError) return _error(context, state);
              if (state is DashboardEmpty) {
                return SideFrameBoundedBody(
                  child: Center(
                    child: CustomEmptyState(
                      lottiePath: _emptyAnimation,
                      verticalPadding: 0,
                    ),
                  ),
                );
              }
              if (state is DashboardLoaded) return _loaded(context, state);
              return SideFrameBoundedBody(
                child: Center(child: CircleProgressMaster()),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _error(BuildContext context, DashboardError state) {
    return SideFrameBoundedBody(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.red),
            SizedBox(height: 16.h),
            Text(
              S.of(context).errorLoadingDashboard,
              style: StyleText.fontSize18Weight500,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            customButton(
              title: S.of(context).retry,
              function: () =>
                  context.read<DashboardCubit>().fetchDashboardData(),
              wrapContent: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _loaded(BuildContext context, DashboardLoaded state) {
    final DashboardFigures f = state.figures;
    final bool isMobile = ContextExtension(context).isPhone;
    final int departmentTotal = f.departmentCounts.values.fold<int>(
      0,
      (sum, c) => sum + c,
    );

    final Widget departmentCard = DonutChartCard(
      title: S.of(context).departments,
      dotIcon: 'assets/icons_assets/main_icons_assets/ic_org_briefcase.svg',
      centerValue: KhLocale.digits(context, departmentTotal),
      centerLabel: S.of(context).total,
      sections: f.departmentCounts.entries
          .map(
            (e) => ChartData(
              label: _departmentName(context, state, e.key),
              value: e.value.toDouble(),
              color: _departmentColor(e.key),
            ),
          )
          .toList(),
      chartSize: 130,
    );

    final Widget utilizationCard = DonutChartCard(
      title: S.of(context).documentUtilization,
      dotIcon: 'assets/icons_assets/main_icons_assets/ic_status.svg',
      centerValue: KhLocale.digits(context, f.totalViews + f.totalDownloads),
      centerLabel: S.of(context).total,
      sections: [
        ChartData(
          label: S.of(context).views,
          value: f.totalViews.toDouble(),
          color: AppColors.greyDark,
        ),
        ChartData(
          label: S.of(context).downloads,
          value: f.totalDownloads.toDouble(),
          color: AppColors.secondaryPrimary,
        ),
      ],
      chartSize: 130,
    );

    return SideFrameScrollableBody(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          DashboardDepartmentFilter(
            departmentNamesEn: state.departmentNamesEn,
            departmentNamesAr: state.departmentNamesAr,
            selectedDepartmentIds: state.selectedDepartmentIds,
            onChanged: context.read<DashboardCubit>().selectDepartments,
          ),
          // KH-DASH-09: records that could not be read are not in the
          // figures — say so, as the hub list does.
          if (state.unreadableRecords > 0) _unreadableNotice(context, state),
          SizedBox(height: 15.h),
          _statusCards(context, isMobile, f.statusCounts),
          SizedBox(height: 15.h),
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                departmentCard,
                SizedBox(height: 20.h),
                utilizationCard,
              ],
            )
          else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: departmentCard),
                  SizedBox(width: 15.w),
                  Expanded(child: utilizationCard),
                ],
              ),
            ),
          SizedBox(height: 15.h),
          // KH-DASH-08: each tab's title says what its numbers are.
          _documentsChart(context, f),
          SizedBox(height: 15.h),
          _usageChart(context, f),
          SizedBox(height: 15.h),
          KnowledgeHubResources(extensionData: f.extensionCounts),
          SizedBox(height: 15.h),
          MonthlyComparisonKnowledgeChart(
            data: f.departmentComparison,
            departmentNamesEn: state.departmentNamesEn,
            departmentNamesAr: state.departmentNamesAr,
          ),
          SizedBox(height: 15.h),
        ],
      ),
    );
  }

  /// KH-DASH-09: how many records were left out of the figures.
  Widget _unreadableNotice(BuildContext context, DashboardLoaded state) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 8.sp),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          '${S.of(context).khUnreadableRecords} ${KhLocale.digits(context, state.unreadableRecords)}',
          style: StyleText.fontSize12Weight500.copyWith(
            color: AppColors.orange,
          ),
        ),
      ),
    );
  }

  /// Monthly uploaded / published / removed documents (KH-DASH-08).
  Widget _documentsChart(BuildContext context, DashboardFigures f) {
    return DashboardMonthlyChart(
      series: [
        DashboardChartSeries(
          tabLabel: S.of(context).khUploaded,
          title: S.of(context).uploadedDocuments,
          icon: 'assets/icons_assets/knowledge_hub_assets/ic_module_knowledge_upload.svg',
          data: f.monthlyUploaded,
        ),
        DashboardChartSeries(
          tabLabel: S.of(context).published,
          title: S.of(context).khPublishedDocuments,
          icon: 'assets/icons_assets/knowledge_hub_assets/ic_module_knowledge_upload.svg',
          data: f.monthlyPublished,
        ),
        DashboardChartSeries(
          tabLabel: S.of(context).removed,
          title: S.of(context).khRemovedDocuments,
          icon: 'assets/icons_assets/knowledge_hub_assets/ic_module_knowledge_upload.svg',
          data: f.monthlyRemoved,
        ),
      ],
    );
  }

  /// Monthly views and downloads.
  Widget _usageChart(BuildContext context, DashboardFigures f) {
    return DashboardMonthlyChart(
      initialIndex: 1,
      series: [
        DashboardChartSeries(
          tabLabel: S.of(context).views,
          title: S.of(context).numberOfViews,
          icon: 'assets/icons_assets/knowledge_hub_assets/ic_action_view.svg',
          data: f.monthlyViews,
        ),
        DashboardChartSeries(
          tabLabel: S.of(context).download,
          title: S.of(context).numberOfDownloads,
          icon: 'assets/icons_assets/main_icons_assets/ic_action_cloud_download.svg',
          data: f.monthlyDownloads,
        ),
      ],
    );
  }

  Widget _statusCards(
    BuildContext context,
    bool isMobile,
    Map<String, int> counts,
  ) {
    Widget row(String title, String status, String icon) => _statusRow(
      title: title,
      value: KhLocale.digits(context, counts[status] ?? 0),
      icon: icon,
    );

    final Widget approved = row(
      S.of(context).approved,
      DashboardStatus.approved,
      'assets/icons_assets/main_icons_assets/ic_status_approved_circle.svg',
    );
    final Widget pending = row(
      S.of(context).pending,
      DashboardStatus.pending,
      'assets/icons_assets/main_icons_assets/ic_status_pending_mixed.svg',
    );
    final Widget rejected = row(
      S.of(context).rejected,
      DashboardStatus.rejected,
      'assets/icons_assets/main_icons_assets/ic_status_rejected_circle.svg',
    );
    final Widget removed = row(
      S.of(context).removed,
      DashboardStatus.removed,
      'assets/icons_assets/main_icons_assets/ic_status_document_removed.svg',
    );

    Widget card(List<Widget> rows) => Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.all(10.sp),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) SizedBox(height: 14.h),
            rows[i],
          ],
        ],
      ),
    );

    if (isMobile) return card([approved, pending, rejected, removed]);
    return Row(
      children: [
        Expanded(child: card([approved, pending])),
        SizedBox(width: 15.w),
        Expanded(child: card([rejected, removed])),
      ],
    );
  }

  Widget _statusRow({
    required String title,
    required String value,
    required String icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CustomSvgImage(
              assetPath: icon,
              height: 35.h,
              width: 35.w,
              fit: BoxFit.fill,
            ),
            SizedBox(width: 5.w),
            Text(
              title,
              style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: StyleText.fontSize22Weight600.copyWith(color: AppColors.text),
        ),
      ],
    );
  }
}
