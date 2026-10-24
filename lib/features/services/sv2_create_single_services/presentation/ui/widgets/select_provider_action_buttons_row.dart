/// Module: services / sv2_create_single_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: select_provider_action_buttons_row.dart
/// Purpose: Select provider action buttons row.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/controller/provider_selection_cubit.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/controller/provider_selection_state.dart';

class ActionButtonsRow extends StatelessWidget {
  const ActionButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderSelectionCubit, ProviderSelectionState>(
      builder: (context, state) {
        if (state is! ProviderSelectionLoaded) return const SizedBox.shrink();

        final cubit = context.read<ProviderSelectionCubit>();
        final data = state.data;
        final isEditProvider = data.editProvider != null;

        return Row(
          textDirection: TextDirection
              .ltr, // X-73: Cancel left, action right in both languages

          children: [
            customButton(
              // ✅ "Discard" in editProvider mode, "Back" otherwise
              title: isEditProvider
                  ? S.of(context).discardTitle
                  : S.of(context).back,
              function: () {
                // ✅ Both Discard and Back just pop — no saving
                Navigator.pop(context);
              },
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.white,
              ),
              width: 150.sp,
              height: 38.sp,
              radius: 8.r,
              color: AppColors.secondaryAction,
            ),
            const Spacer(),
            customButton(
              title: isEditProvider ? S.of(context).Save : S.of(context).next,
              function: () => cubit.handleNextNavigation(),
              width: 150.sp,
              height: 38.sp,
              color: AppColors.primary,
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.textButton,
              ),
              radius: 8.r,
            ),
          ],
        );
      },
    );
  }
}
