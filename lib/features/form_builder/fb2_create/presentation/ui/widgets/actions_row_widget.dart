/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: actions_row_widget.dart
/// Description: `ActionsRowWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

// Keep for .tr translations

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class ActionsRowWidget extends StatelessWidget {
  const ActionsRowWidget({
    super.key,
    this.showIsRequired = true,
    required this.rowIndex,
    required this.columnIndex,
    required this.pageIndex,
  });

  final bool showIsRequired;
  final int rowIndex, columnIndex, pageIndex;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
      builder: (context, state) {
        if (state is! CreateFormDataLoaded) {
          return const SizedBox.shrink();
        }

        final fieldController =
            state.pages[pageIndex].rows[rowIndex].controllers[columnIndex];

        // Locked form (has submissions): no duplicate / delete.
        final bool locked = context.read<CreateFormDataCubit>().structureLocked;

        return Row(
          children: [
            if (!locked) ...[
              _buildActionIcon(
                icon: AppAssets.copy,
                onTap: () =>
                    context.read<CreateFormDataCubit>().duplicateColumn(
                      columnIndex: columnIndex,
                      rowIndex: rowIndex,
                      pageIndex: pageIndex,
                    ),
                iconColor: AppColors.text,
              ),
              horizontalSpace(25),
              _buildActionIcon(
                icon: AppAssets.delete,
                onTap: () => context.read<CreateFormDataCubit>().deleteColumn(
                  columnIndex: columnIndex,
                  rowIndex: rowIndex,
                  pageIndex: pageIndex,
                ),
                iconColor: AppColors.red,
              ),
            ],
            if (showIsRequired)
              ..._buildRequiredSection(context, fieldController),
          ],
        );
      },
    );
  }

  /// Build action icon with tap functionality
  Widget _buildActionIcon({
    required String icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: withHaptic(onTap, HapticLevel.low),
      child: CustomSvgImage.natural(
        assetPath: icon,
        width: 20.w,
        height: 20.h,
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      ),
    );
  }

  /// Build required section with text and switch
  List<Widget> _buildRequiredSection(
    BuildContext context,
    FieldController fieldController,
  ) {
    return [
      const Spacer(),
      Text(S.of(context).fbRequired, style: StyleText.fontSize14Weight500),
      horizontalSpace(15),
      // In Arabic the switch is
      // turned 180° (mirrored), the same as DefaultSwitchButton elsewhere in
      // the app — OFF sits on the right and ON slides to the left. It is
      // still laid out LTR inside, so the mirror is the only thing that
      // changes between the two languages.
      Transform.flip(
        flipX: Localizations.localeOf(context).languageCode == 'ar',
        child: Directionality(
          textDirection: ui.TextDirection.ltr,
          child: AdvancedSwitch(
            onChanged: (value) =>
                context.read<CreateFormDataCubit>().onRequiredSwitchChanged(
                  rowIndex: rowIndex,
                  columnIndex: columnIndex,
                  value: value,
                  pageIndex: pageIndex,
                ),
            initialValue: fieldController.getIsRequired(),
            activeColor: AppColors.primary,
            width: 30.w,
            height: 18.h,
          ),
        ),
      ),
    ];
  }
}
