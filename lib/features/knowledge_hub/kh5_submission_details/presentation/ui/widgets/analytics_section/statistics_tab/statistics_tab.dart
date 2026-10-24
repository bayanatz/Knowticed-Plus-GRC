/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/statistics_tab
/// ************************* FILE INFO *************************** ///
/// File Name: statistics_tab.dart
/// Description: Build statistics tab — Submission Details (S5) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/controller/analytics/analytics_states.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/ui/widgets/submitted_documents_grid/submissions_table.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/statistics_tab/statistics_item.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_error_state.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/document_utilization_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/controller/analytics/analytics_cubit.dart';

Widget buildStatisticsTab(
  BuildContext context, {
  required bool lightMode,
  required TextEditingController searchStatisticsController,
}) {
  final isMobile = ContextExtension(context).isPhone;

  return BlocBuilder<AnalyticsCubit, AnalyticsStates>(
    builder: (context, state) {
      final cubit = context.read<AnalyticsCubit>();
      if (state is FetchingAnalyticsLoadingState) {
        return Center(child: CircleProgressMaster());
      }
      if (state is FetchingAnalyticsErrorState) {
        return CustomErrorState(title: S.of(context).errorLoadingAnalytics);
      }
      // Empty and Success both show the rows. `filteredActions`: the Filter
      // dialog and the search field narrow this list.
      if (isMobile) {
        return _buildStatisticsList(
          context,
          actions: cubit.filteredActions,
          usersCache: cubit.usersCache,
          lightMode: lightMode,
        );
      }
      // For desktop/tablet: always the table (it handles an empty list).
      return statisticsTable(
        context,
        lightMode: lightMode,
        actions: cubit.filteredActions,
        searchStatisticsController: searchStatisticsController,
        usersCache: cubit.usersCache,
      );
    },
  );
}

/// Phone layout: one card per action, or the app's empty state.
Widget _buildStatisticsList(
  BuildContext context, {
  required List<DocumentUtilizationModel> actions,
  required Map<String, EmployeeData> usersCache,
  required bool lightMode,
}) {
  if (actions.isEmpty) {
    // The app's one empty state; the padding drops it clear of the tab row.
    return const CustomEmptyState(verticalPadding: 48);
  }
  return SingleChildScrollView(
    child: Column(
      children: actions.map((action) {
        final EmployeeData? userData = usersCache[action.currentEmployeeId];
        if (userData == null) {
          khLog(
            '⚠️ Missing user data for userId: ${action.currentEmployeeId}',
            name: 'StatisticsTab',
          );
        }
        return buildStatisticsItem(
          context,
          lightMode: lightMode,
          isMobile: true,
          action: action,
          userData: userData,
        );
      }).toList(),
    ),
  );
}
