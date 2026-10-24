/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: create_data_pages_list.dart
/// Description: `CreateDataPagesList` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
// Keep for .tr translations only

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/create_data_column_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/helper/extensions.dart'
    hide ContextExtension;
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/field_text_binder.dart';

class CreateDataPagesList extends StatelessWidget {
  const CreateDataPagesList({
    super.key,
    required this.state,
    required this.isReadOnly,
  });

  final CreateFormDataLoaded state;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        state.pages.length,
        (index) => _buildPage(index, context, state, isReadOnly),
      ),
    );
  }

  Widget _buildPage(
    int pageIndex,
    BuildContext context,
    CreateFormDataLoaded state,
    bool isReadOnly,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Large-screen bug report p.2: on tablets a hidden page keeps its
        // "Page N" header in place (it used to disappear from this list and
        // jump to a block above), so the order never changes.
        if (state.pages.length > 1) _buildPageHeader(pageIndex, context, state),
        if (state.pages[pageIndex].isPageExpanded)
          ..._buildPageRows(pageIndex, context, state, isReadOnly),
      ],
    );
  }

  Widget _buildPageHeader(
    int pageIndex,
    BuildContext context,
    CreateFormDataLoaded state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpace(ContextExtension(context).isTablett ? 15 : 20),
        Row(
          children: [
            Text(
              '${S.of(context).page} ${pageIndex + 1}',
              style: StyleText.fontSize16Weight500,
            ),
            if (!ContextExtension(context).isTablett) ...[
              const Spacer(),
              _buildExpandCollapseButton(pageIndex, context, state),
            ],
          ],
        ),
        verticalSpace(ContextExtension(context).isTablett ? 15 : 20),
      ],
    );
  }

  Widget _buildExpandCollapseButton(
    int pageIndex,
    BuildContext context,
    CreateFormDataLoaded state,
  ) {
    return InkWell(
      onTapDown: (_) => HapticController.low(),
      onTap: () => context.read<CreateFormDataCubit>().expandedPage(pageIndex),
      child: Text(
        state.pages[pageIndex].isPageExpanded
            ? S.of(context).hide
            : S.of(context).expand,
        style: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.blue,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.blue,
        ),
      ),
    );
  }

  List<Widget> _buildPageRows(
    int pageIndex,
    BuildContext context,
    CreateFormDataLoaded state,
    bool isReadOnly,
  ) {
    return List.generate(
      state.pages[pageIndex].rows.length,
      (indexRow) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRowContainer(pageIndex, indexRow, context, state, isReadOnly),
          verticalSpace(16),
        ],
      ),
    );
  }

  Widget _buildRowContainer(
    int pageIndex,
    int indexRow,
    BuildContext context,
    CreateFormDataLoaded state,
    bool isReadOnly,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.all(Radius.circular(8.r)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRowHeader(pageIndex, indexRow, context, state),
            if (state.pages[pageIndex].rows[indexRow].isRowExpanded)
              _buildRowBody(pageIndex, indexRow, context, state, isReadOnly),
          ],
        ),
      ),
    );
  }

  Widget _buildRowHeader(
    int pageIndex,
    int indexRow,
    BuildContext context,
    CreateFormDataLoaded state,
  ) {
    final row = state.pages[pageIndex].rows[indexRow];
    return Row(
      children: [
        Text(
          // Figma names this "First Row" / "Second Row" (node 7444-41775 and
          // siblings), not "1st Row". Arabic puts the ordinal after the noun:
          // "الصف الأول".
          S.of(context).fbRowTitle(indexRow.toWordOrdinal()),
          style: StyleText.fontSize16Weight500,
        ),
        const Spacer(),
        if (!row.isRowExpanded &&
            !context.read<CreateFormDataCubit>().structureLocked) ...[
          _buildRowActionButton(
            icon: AppAssets.copy,
            onTap: () => context.read<CreateFormDataCubit>().duplicateRow(
              indexRow: indexRow,
              pageIndex: pageIndex,
            ),
          ),
          horizontalSpace(25),
          _buildRowActionButton(
            icon: AppAssets.delete,
            onTap: () => context.read<CreateFormDataCubit>().deleteRow(
              rowIndex: indexRow,
              pageIndex: pageIndex,
            ),
          ),
          horizontalSpace(25),
        ],
        _buildExpandRowButton(pageIndex, indexRow, context, state),
      ],
    );
  }

  Widget _buildRowActionButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTapDown: hapticDown(onTap, HapticLevel.high),
      onTap: onTap,
      child: CustomSvgImage.natural(
        assetPath: icon,
        colorFilter: icon == AppAssets.delete
            ? null
            : ColorFilter.mode(AppColors.text, BlendMode.srcIn),
      ),
    );
  }

  Widget _buildExpandRowButton(
    int pageIndex,
    int indexRow,
    BuildContext context,
    CreateFormDataLoaded state,
  ) {
    final row = state.pages[pageIndex].rows[indexRow];
    return InkWell(
      onTapDown: (_) => HapticController.low(),
      onTap: () => context.read<CreateFormDataCubit>().onExpanded(
        rowIndex: indexRow,
        pageIndex: pageIndex,
      ),
      child: Transform.rotate(
        angle: row.isRowExpanded ? 3.14 : 0,
        child: CustomSvgImage.natural(
          assetPath: AppAssets.arrowDown,
          width: 20.sp,
          height: 20.sp,
          colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildRowBody(
    int pageIndex,
    int indexRow,
    BuildContext context,
    CreateFormDataLoaded state,
    bool isReadOnly,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpace(20),
        _buildNumberOfColumnsField(
          pageIndex,
          indexRow,
          context,
          state,
          isReadOnly,
        ),
        ..._buildColumnFields(pageIndex, indexRow, context, state, isReadOnly),
      ],
    );
  }

  Widget _buildNumberOfColumnsField(
    int pageIndex,
    int indexRow,
    BuildContext context,
    CreateFormDataLoaded state,
    bool isReadOnly,
  ) {
    return FieldTextBinder(
      text: state.pages[pageIndex].rows[indexRow].numOfColumn!,
      builder: (context, textController) => CustomTextField(
        height: 36,
        readOnly: isReadOnly,
        label: S.of(context).numberOfColumns,
        keyboardType: TextInputType.number,
        controller: textController,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        onChanged: (value) {
          final englishNumber = value.toEnglishNumber();

          if (englishNumber > 0 && englishNumber <= 15) {
            context.read<CreateFormDataCubit>().changeNumberOfColumn(
              value: englishNumber,
              rowIndex: indexRow,
              pageIndex: pageIndex,
            );
          }
        },
      ),
    );
  }

  List<Widget> _buildColumnFields(
    int pageIndex,
    int indexRow,
    BuildContext context,
    CreateFormDataLoaded state,
    bool isReadOnly,
  ) {
    final numColumnsText = state
        .pages[pageIndex]
        .rows[indexRow]
        .numOfColumn!
        .text
        .toEnglishNumber();

    final numColumns = numColumnsText;

    return List.generate(
      numColumns,
      (columnIndex) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpace(20),
          _buildColumnHeader(columnIndex, context),
          verticalSpace(15),
          _buildColumnContent(
            pageIndex,
            indexRow,
            columnIndex,
            context,
            state,
            isReadOnly,
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(int columnIndex, BuildContext context) {
    return Text(
      // Was "Column 1st" — both the word form AND the word ORDER were wrong.
      // Figma says "First Column" (node 7444-41775), so English leads with the
      // ordinal; Arabic keeps it after the noun ("العمود الأول").
      ' ${S.of(context).fbColumnTitle(columnIndex.toWordOrdinal())}',
      // (vertical bug report p.10 — "how the title size
      // smaller than content below"): the column heading was 14, the same
      // as the "Choose Field of …" label under it, and the thin yellow made
      // it read smaller still. It is now 16, like the row heading above it.
      style: StyleText.fontSize16Weight500.copyWith(color: AppColors.primary),
    );
  }

  Widget _buildColumnContent(
    int pageIndex,
    int rowIndex,
    int columnIndex,
    BuildContext context,
    CreateFormDataLoaded state,
    bool isReadOnly,
  ) {
    final numColumnsText = state
        .pages[pageIndex]
        .rows[rowIndex]
        .numOfColumn!
        .text
        .toEnglishNumber();
    final numColumns = numColumnsText;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldTypeDropdown(
          pageIndex,
          rowIndex,
          columnIndex,
          context,
          state,
        ),
        verticalSpace(15),
        buildColumnFieldWidget(
          state.pages[pageIndex].rows[rowIndex].controllers[columnIndex].type,
          columnIndex,
          rowIndex,
          pageIndex,
          isReadOnly,
        ),
        if (numColumns == 1 && columnIndex == 0) ...[verticalSpace(15)],
      ],
    );
  }

  Widget _buildFieldTypeDropdown(
    int pageIndex,
    int rowIndex,
    int columnIndex,
    BuildContext context,
    CreateFormDataLoaded state,
  ) {
    final controller =
        state.pages[pageIndex].rows[rowIndex].controllers[columnIndex];

    // Figma: "Choose Field of First Column" (node 7444-41775).
    final title = S
        .of(context)
        .fbChooseFieldOfColumn(columnIndex.toWordOrdinal());

    return DropDownWidget(
      onChanged: (value) =>
          context.read<CreateFormDataCubit>().changeFieldTypeValue(
            value: value,
            rowIndex: rowIndex,
            columnIndex: columnIndex,
            pageIndex: pageIndex,
          ),
      svgIconPath: controller.type.icon,
      // Per-row glyphs. They used to be baked into the DropdownMenuItem
      // children at the SVG's own intrinsic size — the "very big" menu icons
      // in the report. DropDownWidget now draws them at the same 16 it uses
      // for the trigger, so the two finally agree.
      leadingIconForValue: (value) => FieldTypeExtension.fromName(value)?.icon,
      title: title,
      hint: S.of(context).fieldTypeTextField,
      items: EnumDropdownItems.fieldType,
      currentValue: controller.type.name,
    );
  }
}
