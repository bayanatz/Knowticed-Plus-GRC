/// Module: knowledge_hub / presentation / s2_view_knowledge_hub / widgets/build_search_section.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_search_section.dart
/// Description: Created to contains search bar and filter data in home screen.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Created At: 11/10/2025
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/search_with_filters.dart';

Widget filterSection(
  BuildContext context, {
  required TextEditingController searchController,
  required List<DepartmentModelPro> departments,
}) {
  return searchWithFilters(
    context,
    searchController: searchController,
    departments: departments,
    onSearchChanged: (query) {
      context.read<CreateKnowledgeCubit>().searchKnowledge(query);
    },
  );
}
