/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: radio_field_widget.dart
/// Description: `RadioFieldWidget` widget.
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
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/radio_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/actions_row_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/field_text_binder.dart';

class RadioFieldWidget extends StatelessWidget {
  final int columnIndex;
  final int rowIndex;
  final int pageIndex;
  final bool isReadOnly;

  const RadioFieldWidget({
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

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleField(context, state),
            verticalSpace(15),
            _buildOptionsSection(context, state),
            verticalSpace(15),
            _buildAlignmentDropdown(context, state),
            verticalSpace(15),
            _buildArrangementDropdown(context, state),
            verticalSpace(18),
            _buildActionsRow(),
          ],
        );
      },
    );
  }

  // Alignment dropdown method
  Widget _buildAlignmentDropdown(
    BuildContext context,
    CreateFormDataLoaded state,
  ) {
    final RadioFieldController controllers =
        state.pages[pageIndex].rows[rowIndex].controllers[columnIndex]
            as RadioFieldController;

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

  // Arrangement dropdown method
  Widget _buildArrangementDropdown(
    BuildContext context,
    CreateFormDataLoaded state,
  ) {
    final RadioFieldController controllers =
        state.pages[pageIndex].rows[rowIndex].controllers[columnIndex]
            as RadioFieldController;

    return DropDownWidget(
      onChanged: (value) {
        if (isReadOnly) return;
        context.read<CreateFormDataCubit>().changeArrangementValue(
          pageIndex: pageIndex,
          value: value,
          rowIndex: rowIndex,
          columnIndex: columnIndex,
        );
      },
      title: S.current.fbChooseArrangement,
      hint: S.current.fbChooseArrangement,
      items: EnumDropdownItems.arrangement,
      currentValue: controllers.arrangement,
    );
  }

  // Title field method
  Widget _buildTitleField(BuildContext context, CreateFormDataLoaded state) {
    final RadioFieldController controllers =
        state.pages[pageIndex].rows[rowIndex].controllers[columnIndex]
            as RadioFieldController;

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

  // Options section method
  Widget _buildOptionsSection(
    BuildContext context,
    CreateFormDataLoaded state,
  ) {
    final RadioFieldController controllers =
        state.pages[pageIndex].rows[rowIndex].controllers[columnIndex]
            as RadioFieldController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.current.fbAddOptions, style: StyleText.fontSize14Weight400),
        // Generate option fields dynamically
        ...List.generate(
          controllers.hints.length,
          (i) => _buildOptionField(context, state, i),
        ),
        verticalSpace(8),
        _buildAddOptionButton(context),
      ],
    );
  }

  // Individual option field method
  Widget _buildOptionField(
    BuildContext context,
    CreateFormDataLoaded state,
    int i,
  ) {
    final RadioFieldController controllers =
        state.pages[pageIndex].rows[rowIndex].controllers[columnIndex]
            as RadioFieldController;

    return Column(
      children: [
        i != 0 ? verticalSpace(10) : verticalSpace(8),
        SizedBox(
          child: FieldTextBinder(
            text: controllers.hints[i],
            builder: (context, textController) => CustomTextField(
              readOnly: isReadOnly,
              height: 36,
              hint: S.current.textHere,
              maxLines: 1,
              onChanged: (value) {
                // Trigger live update in A4 container
                context.read<CreateFormDataCubit>().updateFieldText(
                  pageIndex: pageIndex,
                  rowIndex: rowIndex,
                  columnIndex: columnIndex,
                );
              },
              fillColor: AppColors.background,
              width: double.infinity,
              controller: textController,
              prefixIcon: Container(
                width: 15.w,
                height: 15.h,
                margin: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderGrey, width: 2),
                  color: AppColors.background,
                ),
              ),
              suffixIcon: (controllers.hints.length > 2 && !isReadOnly)
                  ? _buildRemoveOptionIcon(context, i)
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  // Remove option icon method
  Widget _buildRemoveOptionIcon(BuildContext context, int i) {
    return InkWell(
      onTapDown: (_) => HapticController.high(),
      onTap: () => context.read<CreateFormDataCubit>().removeOption(
        rowIndex: rowIndex,
        columnIndex: columnIndex,
        optionIndex: i,
        pageIndex: pageIndex,
      ),
      child: CustomSvgImage.natural(
        assetPath: AppAssets.cancel,
        // Bug report #2: was drawn at the svg's natural size.
        width: 18.sp,
        height: 18.sp,
      ),
    );
  }

  // Add option button method
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
          _buildAddOptionText(),
        ],
      ),
    );
  }

  // Add option text method
  Widget _buildAddOptionText() {
    return RichText(
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
    );
  }

  // Actions row method
  Widget _buildActionsRow() {
    if (isReadOnly) return const SizedBox.shrink();
    return ActionsRowWidget(
      pageIndex: pageIndex,
      columnIndex: columnIndex,
      rowIndex: rowIndex,
    );
  }
}
