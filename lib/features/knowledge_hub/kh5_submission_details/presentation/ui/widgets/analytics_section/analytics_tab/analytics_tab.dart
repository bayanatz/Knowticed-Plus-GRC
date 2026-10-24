/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/analytics_tab
/// ************************* FILE INFO *************************** ///
/// File Name: analytics_tab.dart
/// Description: Build analytics tab — Submission Details (S5) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_error_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/controller/analytics/analytics_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/controller/analytics/analytics_states.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/analytics_tab/departments_bar_chart.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/analytics_tab/departments_chart.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/analytics_tab/document_utilization_chart.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/analytics_tab/downloads_chart.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget buildAnalyticsTab(
  BuildContext context,
  bool lightMode,
  String knowledgeId,
) {
  return BlocBuilder<AnalyticsCubit, AnalyticsStates>(
    builder: (context, state) {
      if (state is FetchingAnalyticsErrorState) {
        khLog('Analytics failed: ${state.error}', name: 'AnalyticsTab');
        return CustomErrorState(
          title: S.of(context).errorLoadingAnalytics,
          onRetry: () =>
              context.read<AnalyticsCubit>().fetchAnalytics(knowledgeId),
        );
      }
      // Empty and Success both show the dashboard (with zeros when empty).
      if (state is FetchingAnalyticsEmptyState ||
          state is FetchingAnalyticsSuccessState) {
        return _buildAnalyticsCharts(
          context,
          lightMode: lightMode,
          success: state is FetchingAnalyticsSuccessState ? state : null,
        );
      }
      // Loading and the initial state.
      return Center(child: CircleProgressMaster());
    },
  );
}

Widget _buildAnalyticsCharts(
  BuildContext context, {
  required bool lightMode,
  required FetchingAnalyticsSuccessState? success,
}) {
  final cubit = context.read<AnalyticsCubit>();
  final topDepts = cubit.getTopDepartments(5);
  // Knowledge Hub bug report p.21 ("where all month"): a full year.
  final downloadsData = cubit.getLastNMonthsDownloads(12);
  final viewsData = cubit.getLastNMonthsViews(12);

  return SingleChildScrollView(
    physics: NeverScrollableScrollPhysics(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopCharts(
          context,
          lightMode: lightMode,
          departmentsChart: buildDepartmentsChart(
            context,
            lightMode,
            departmentData: topDepts,
            totalCount: cubit.totalActions,
            enToArDepartments: null,
          ),
          utilizationChart: buildDocumentUtilizationChart(
            context,
            lightMode,
            totalViews: success?.totalViews ?? 0,
            totalDownloads: success?.totalDownloads ?? 0,
          ),
        ),
        SizedBox(height: 15.h),
        buildDownloadsChart(
          lightMode,
          downloadsData: downloadsData,
          viewsData: viewsData,
        ),
        SizedBox(height: 15.h),
        buildDepartmentsBarChart(context, lightMode, departmentData: topDepts),
        SizedBox(height: 15.h),
      ],
    ),
  );
}

/// Departments and document utilisation: stacked on a phone, side by side
/// on wider screens.
Widget _buildTopCharts(
  BuildContext context, {
  required bool lightMode,
  required Widget departmentsChart,
  required Widget utilizationChart,
}) {
  if (ContextExtension(context).isPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        departmentsChart,
        SizedBox(height: 15.h),
        utilizationChart,
      ],
    );
  }
  return Row(
    children: [
      Expanded(child: departmentsChart),
      SizedBox(width: 15.w),
      Expanded(child: utilizationChart),
    ],
  );
}
