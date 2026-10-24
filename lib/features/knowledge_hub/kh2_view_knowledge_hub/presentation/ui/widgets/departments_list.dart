/// Module: knowledge_hub / presentation / s2_view_knowledge_hub / widgets/departments_list.dart
/// ************************* FILE INFO *************************** ///
/// File Name: departments_list.dart
/// Description: Contains the Departments view in Home Page.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Created At: 11/10/2025
library;

import 'package:knowticed_plus/core/custom/feedback/custom_error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/controller/create_knowledge_state.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/departments_list_view.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';

Widget buildDepartmentsList({
  required int selectedIndex,
  required void Function()? onPressed,
}) {
  return BlocBuilder<CreateKnowledgeCubit, CreateKnowledgeState>(
    buildWhen: (previous, current) =>
        current is FetchingDepartmentLoadingState ||
        current is FetchingDepartmentErrorState ||
        current is FetchingDepartmentSuccessState,
    builder: (context, state) {
      return switch (state) {
        FetchingDepartmentLoadingState() => _buildLoadingIndicator(),
        FetchingDepartmentErrorState() => _buildErrorWidget(
          context,
          error: state.error,
          onPressed: onPressed,
        ),
        FetchingDepartmentSuccessState() => _buildDepartmentsListView(
          context,
          departments: state.departmentList,
          selectedIndex: selectedIndex,
        ),
        _ => const Center(child: SizedBox.shrink()),
      };
    },
  );
}

Widget _buildLoadingIndicator() {
  return const SizedBox.shrink();
}

Widget _buildErrorWidget(
  BuildContext context, {
  required String error,
  required void Function()? onPressed,
}) {
  // A translated message with Retry; the technical error goes to the log.
  khLog('Loading departments failed: $error', name: 'DepartmentsList');
  return CustomErrorState(
    title: S.of(context).failedToLoadDepartments,
    onRetry: onPressed == null ? null : () => onPressed(),
  );
}

Widget _buildDepartmentsListView(
  BuildContext context, {
  required List<DepartmentModelPro> departments,
  required int selectedIndex,
}) {
  khLog('Departments fetched successfully');
  return departmentsListView(
    context,
    selectedIndex: selectedIndex,
    cubit: context.read<CreateKnowledgeCubit>(),
    departmentNames: departments,
  );
}
