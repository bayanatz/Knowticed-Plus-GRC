/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: title_field_sections.dart
/// Description: `TitleTextFormattingSection` widget, `TitleColorSection` widget, `TitleTextSizeSection` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_color_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
// Keep for .tr translations and locale
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/helper/arabic_number_format.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/title_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/field_text_binder.dart';

class TitleTextFormattingSection extends StatelessWidget {
  final int columnIndex;
  final int rowIndex;
  final int pageIndex;
  final bool isReadOnly;
  final CreateFormDataLoaded state;

  const TitleTextFormattingSection({
    super.key,
    required this.columnIndex,
    required this.rowIndex,
    required this.pageIndex,
    required this.isReadOnly,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final TitleFieldController controllers =
        state.pages[pageIndex].rows[rowIndex].controllers[columnIndex]
            as TitleFieldController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.current.fbTextFormattingStyles,
          style: StyleText.fontSize14Weight400,
        ),
        verticalSpace(8),
        _buildStyleRow(controllers, context),
      ],
    );
  }

  Widget _buildStyleRow(
    TitleFieldController controllers,
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStyleButton(
          asset: AppAssets.bold,
          isActive: controllers.isBold!,
          onTap: () => context.read<CreateFormDataCubit>().changeTitleStyle(
            pageIndex: pageIndex,
            columnIndex: columnIndex,
            rowIndex: rowIndex,
            style: 'bold',
          ),
        ),
        horizontalSpace(16),
        _buildStyleButton(
          asset: AppAssets.italic,
          isActive: controllers.isItalic!,
          onTap: () => context.read<CreateFormDataCubit>().changeTitleStyle(
            pageIndex: pageIndex,
            columnIndex: columnIndex,
            rowIndex: rowIndex,
            style: 'italic',
          ),
        ),
        horizontalSpace(16),
        _buildStyleButton(
          asset: AppAssets.underLine,
          isActive: controllers.isUnderLine!,
          onTap: () => context.read<CreateFormDataCubit>().changeTitleStyle(
            pageIndex: pageIndex,
            columnIndex: columnIndex,
            rowIndex: rowIndex,
            style: 'underLine',
          ),
        ),
      ],
    );
  }

  Widget _buildStyleButton({
    required String asset,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTapDown: isReadOnly ? null : (_) => HapticController.low(),
      onTap: isReadOnly ? null : onTap,
      child: Container(
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              )
            : null,
        child: CustomSvgImage.natural(
          assetPath: asset,
          width: 15.w,
          height: 15.h,
          colorFilter: ColorFilter.mode(
            isActive ? AppColors.black : AppColors.text,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class TitleColorSection extends StatelessWidget {
  final int columnIndex;
  final int rowIndex;
  final int pageIndex;
  final bool isReadOnly;
  final CreateFormDataLoaded state;

  const TitleColorSection({
    super.key,
    required this.columnIndex,
    required this.rowIndex,
    required this.pageIndex,
    required this.isReadOnly,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final TitleFieldController controllers =
        state.pages[pageIndex].rows[rowIndex].controllers[columnIndex]
            as TitleFieldController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.of(context).fbColor, style: StyleText.fontSize14Weight400),
        verticalSpace(8),
        _buildColorPickerButton(context, controllers),
      ],
    );
  }

  Widget _buildColorPickerButton(
    BuildContext context,
    TitleFieldController controllers,
  ) {
    return InkWell(
      onTapDown: (_) => HapticController.low(),
      onTap: () async {
        if (isReadOnly) return;

        // Was a
        // flutter_colorpicker AlertDialog with a hard-coded English "Cancel".
        // It now opens the same flex_color_picker dialog as Settings ›
        // Branding & Theme, whose Discard / Save are localized.
        final Color? pickedColor = await CustomColorPickerField.pickColor(
          context,
          initial: controllers.titleColor,
          title: S.of(context).fbPickColor,
        );

        // Bug report #5: the colour was written onto the controller with no
        // state change, so nothing repainted. Go through the cubit so the
        // swatch and the A4 preview both rebuild.
        if (pickedColor != null && context.mounted) {
          context.read<CreateFormDataCubit>().setTitleColor(
            pageIndex: pageIndex,
            rowIndex: rowIndex,
            columnIndex: columnIndex,
            color: pickedColor,
          );
        }
      },
      child: Container(
        width: 77.w,
        height: 38.h,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.h),
          child: Row(
            children: [
              CustomSvgImage.natural(
                assetPath: AppAssets.colorIcon,
                colorFilter: ColorFilter.mode(
                  controllers.titleColor!,
                  BlendMode.srcIn,
                ),
              ),
              const Spacer(),
              CustomSvgImage.natural(
                assetPath: AppAssets.arrowDownBold,
                colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
              ),
              horizontalSpace(4),
            ],
          ),
        ),
      ),
    );
  }
}

class TitleTextSizeSection extends StatelessWidget {
  final int columnIndex;
  final int rowIndex;
  final int pageIndex;
  final bool isReadOnly;
  final CreateFormDataLoaded state;

  const TitleTextSizeSection({
    super.key,
    required this.columnIndex,
    required this.rowIndex,
    required this.pageIndex,
    required this.isReadOnly,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final TitleFieldController controllers =
        state.pages[pageIndex].rows[rowIndex].controllers[columnIndex]
            as TitleFieldController;

    return SizedBox(
      // Bug report #5: 80.w clipped two-digit sizes ("19" read as "1").
      width: 110.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.current.fbTextSize, style: StyleText.fontSize14Weight400),
          verticalSpace(8),
          _buildTextSizeControl(controllers, context),
        ],
      ),
    );
  }

  Widget _buildTextSizeControl(
    TitleFieldController controllers,
    BuildContext context,
  ) {
    return Container(
      width: 110.w,
      height: 38.h,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSizeButton(
            asset: AppAssets.minus,
            onTap: () => context.read<CreateFormDataCubit>().setTitleTextSize(
              pageIndex: pageIndex,
              columnIndex: columnIndex,
              rowIndex: rowIndex,
              isAdd: false,
            ),
          ),
          _buildSizeInput(controllers, context),
          _buildSizeButton(
            asset: AppAssets.add,
            onTap: () => context.read<CreateFormDataCubit>().setTitleTextSize(
              pageIndex: pageIndex,
              columnIndex: columnIndex,
              rowIndex: rowIndex,
              isAdd: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeButton({
    required String asset,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(4),
          right: Radius.circular(4),
        ),
        onTapDown: isReadOnly ? null : (_) => HapticController.low(),
        onTap: isReadOnly ? null : onTap,
        child: SizedBox(
          width: 24,
          height: 38.h,
          child: Center(
            child: CustomSvgImage.natural(
              assetPath: asset,
              width: 12.w,
              height: 12.h,
              colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSizeInput(
    TitleFieldController controllers,
    BuildContext context,
  ) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        child: FieldTextBinder(
          text: controllers.textSize!,
          builder: (context, textController) => CustomTextField(
            controller: textController,
            readOnly: isReadOnly,
            inputFormatters: [if (context.isArabic) ArabicNumberFormatter()],
            onChanged: (p0) {},
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            valueStyle: StyleText.fontSize12Weight400,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 2.w,
              vertical: 6.h,
            ),
          ),
        ),
      ),
    );
  }
}
