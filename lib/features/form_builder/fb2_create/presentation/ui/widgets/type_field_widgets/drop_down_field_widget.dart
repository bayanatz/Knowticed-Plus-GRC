/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: drop_down_field_widget.dart
/// Description: `DropDownFieldWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Keep for .tr translations

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/drop_down_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/actions_row_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/field_text_binder.dart';

/// Widget for creating a dropdown field in dynamic form
class DropDownFieldWidget extends StatelessWidget {
  final int columnIndex, rowIndex, pageIndex;
  final bool isReadOnly;

  const DropDownFieldWidget({
    super.key,
    required this.columnIndex,
    required this.rowIndex,
    required this.pageIndex,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
      builder: (context, state) {
        if (state is! CreateFormDataLoaded) {
          return const SizedBox.shrink();
        }

        final DropDownFieldController controllers =
            state.pages[pageIndex].rows[rowIndex].controllers[columnIndex]
                as DropDownFieldController;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input field
            _buildTitleField(context, controllers),
            verticalSpace(15),

            // Options section header
            _buildOptionsSectionHeader(),

            // Dynamic options list
            ..._buildOptionsList(context, controllers),

            verticalSpace(8),

            // Add option button
            _buildAddOptionButton(context),
            verticalSpace(18),

            // Alignment dropdown
            _buildAlignmentDropdown(context, controllers),
            verticalSpace(15),

            // Actions row for form management
            _buildActionRow(),
          ],
        );
      },
    );
  }

  /// Builds alignment dropdown
  Widget _buildAlignmentDropdown(
    BuildContext context,
    DropDownFieldController controllers,
  ) {
    return DropDownWidget(
      onChanged: (value) {
        if (isReadOnly) return;
        context.read<CreateFormDataCubit>().changeAlignmentValue(
          pageIndex: pageIndex,
          value: value,
          rowIndex: rowIndex,
          columnIndex: columnIndex,
        );
      },
      title: S.current.fbChooseAlignment,
      hint: S.current.fbChooseAlignment,
      items: EnumDropdownItems.alignment,
      currentValue: controllers.alignment,
    );
  }

  /// Builds title input field
  Widget _buildTitleField(
    BuildContext context,
    DropDownFieldController controllers,
  ) {
    return FieldTextBinder(
      text: controllers.title!,
      builder: (context, textController) => CustomTextField(
        height: 36,
        readOnly: isReadOnly,
        label: S.current.fbAddTitle,
        onChanged: (value) {
          // Trigger live update in A4 container
          context.read<CreateFormDataCubit>().updateFieldText(
            pageIndex: pageIndex,
            rowIndex: rowIndex,
            columnIndex: columnIndex,
          );
        },
        controller: textController,
      ),
    );
  }

  /// Builds options section header
  Widget _buildOptionsSectionHeader() {
    return Text(S.current.fbAddOptions, style: StyleText.fontSize14Weight400);
  }

  /// Builds dynamic options list
  List<Widget> _buildOptionsList(
    BuildContext context,
    DropDownFieldController controllers,
  ) {
    return List.generate(
      controllers.hints.length,
      (i) => [
        i != 0 ? verticalSpace(10) : verticalSpace(8),
        FieldTextBinder(
          text: controllers.hints[i],
          builder: (context, textController) => CustomTextField(
            readOnly: isReadOnly,
            height: 36,
            hint: S.current.textHere,
            maxLines: 1,
            fillColor: AppColors.background,
            width: double.infinity,
            controller: textController,
            onChanged: (value) {
              // Trigger live update in A4 container
              context.read<CreateFormDataCubit>().updateFieldText(
                pageIndex: pageIndex,
                rowIndex: rowIndex,
                columnIndex: columnIndex,
              );
            },
            suffixIcon: (controllers.hints.length > 2)
                ? InkWell(
                    onTapDown: (_) => HapticController.high(),
                    onTap: () {
                      if (isReadOnly) return;
                      context.read<CreateFormDataCubit>().removeOption(
                        rowIndex: rowIndex,
                        columnIndex: columnIndex,
                        optionIndex: i,
                        pageIndex: pageIndex,
                      );
                    },
                    child: CustomSvgImage.natural(
                      assetPath: AppAssets.cancel,
                      // Bug report #2: was drawn at the svg's natural size.
                      width: 18.sp,
                      height: 18.sp,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    ).expand((element) => element).toList();
  }

  /// Builds add option button
  Widget _buildAddOptionButton(BuildContext context) {
    if (isReadOnly) return const SizedBox.shrink();
    return InkWell(
      onTapDown: (_) => HapticController.medium(),
      onTap: () => context.read<CreateFormDataCubit>().addOption(
        pageIndex: pageIndex,
        columnIndex: columnIndex,
        rowIndex: rowIndex,
      ),
      child: Row(
        children: [
          CustomSvgImage.natural(
            assetPath: AppAssets.addOption,
            colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
          ),
          horizontalSpace(6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${S.current.fbAddOptionOr} ',
                  style: StyleText.fontSize12Weight400,
                ),
                TextSpan(
                  text: S.current.fbAddOther,
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.secondaryBlack,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds action row for form management
  Widget _buildActionRow() {
    if (isReadOnly) return const SizedBox.shrink();
    return ActionsRowWidget(
      pageIndex: pageIndex,
      columnIndex: columnIndex,
      rowIndex: rowIndex,
    );
  }
}
