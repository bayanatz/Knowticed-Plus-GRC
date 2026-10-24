/// Module: services / sv2_create_single_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: search_header.dart
/// Purpose: Search header — declares SearchHeader.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/controller/provider_selection_cubit.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/controller/provider_selection_state.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController controller;

  const SearchHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderSelectionCubit, ProviderSelectionState>(
      builder: (context, state) {
        return Row(
          children: [
            AppSearchTextField(
              fillColor: AppColors.background,
              controller: controller,
              onChanged: (value) {
                context.read<ProviderSelectionCubit>().updateSearch(value);
              },
            ),
          ],
        );
      },
    );
  }
}
