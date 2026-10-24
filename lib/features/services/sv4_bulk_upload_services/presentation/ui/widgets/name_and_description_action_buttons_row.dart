/// Module: services / sv4_bulk_upload_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: name_and_description_action_buttons_row.dart
/// Purpose: Name and description action buttons row.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/controller/create_service_cubit.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/controller/create_service_state.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback onDiscard;

  const ActionButtonsRow({required this.onDiscard, super.key});

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return BlocBuilder<CreateServiceCubit, CreateServiceState>(
      buildWhen: (previous, current) => current is CreateServiceLoaded,
      builder: (context, state) {
        final isValid =
            state is CreateServiceLoaded && state.formData.isFormValid;

        return Row(
          textDirection: TextDirection
              .ltr, // X-73: Cancel left, action right in both languages

          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Discard Button
            customButton(
              title: S.of(context).discard,
              function: onDiscard,
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.onSecondaryAction,
              ),
              width: 150.sp,
              height: 38.sp,
              radius: 8.r,
              color: AppColors.secondaryAction,
            ),

            // Next Button
            customButton(
              title: S.of(context).next,
              function: () => context.read<CreateServiceCubit>().submitForm(),
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: isValid ? AppColors.textButton : AppColors.text,
              ),
              width: 150.sp,
              height: 38.sp,
              radius: 8.r,
              color: isValid
                  ? AppColors.primary
                  : (lightMode ? AppColors.grey : AppColors.mediumGrey),
            ),
          ],
        );
      },
    );
  }
}
