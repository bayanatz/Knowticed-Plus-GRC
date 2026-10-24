/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: link_field_widget.dart
/// Description: `LinkFieldWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Keep for .tr translations
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/link_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/actions_row_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/field_text_binder.dart';

/// Widget for creating a link field in a dynamic form configuration
class LinkFieldWidget extends StatelessWidget {
  const LinkFieldWidget({
    super.key,
    required this.columnIndex,
    required this.rowIndex,
    required this.pageIndex,
    this.isReadOnly = false,
  });

  final int columnIndex, rowIndex, pageIndex;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
      builder: (context, state) {
        if (state is! CreateFormDataLoaded) {
          return const SizedBox.shrink();
        }

        final LinkFieldController controllers =
            state.pages[pageIndex].rows[rowIndex].controllers[columnIndex]
                as LinkFieldController;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input field
            _buildTitleField(context, controllers),
            verticalSpace(15),

            // Hint input field
            _buildHintField(context, controllers),
            verticalSpace(15),

            // Alignment dropdown
            _buildAlignmentDropdown(context, controllers),
            verticalSpace(18),

            // Actions row for form management
            _buildActionRow(),
          ],
        );
      },
    );
  }

  /// Builds title input field
  Widget _buildTitleField(
    BuildContext context,
    LinkFieldController controllers,
  ) {
    return FieldTextBinder(
      text: controllers.title!,
      builder: (context, textController) => CustomTextField(
        height: 36,
        readOnly: isReadOnly,
        label: S.current.fbAddTitle,
        controller: textController,
        onChanged: (value) {
          // Trigger live update in A4 container
          context.read<CreateFormDataCubit>().updateFieldText(
            pageIndex: pageIndex,
            rowIndex: rowIndex,
            columnIndex: columnIndex,
          );
        },
      ),
    );
  }

  /// Builds hint input field
  Widget _buildHintField(
    BuildContext context,
    LinkFieldController controllers,
  ) {
    return FieldTextBinder(
      text: controllers.hint!,
      builder: (context, textController) => CustomTextField(
        height: 36,
        label: S.current.fbAddHint,
        controller: textController,
        readOnly: isReadOnly,
        onChanged: (value) {
          // Trigger live update in A4 container
          context.read<CreateFormDataCubit>().updateFieldText(
            pageIndex: pageIndex,
            rowIndex: rowIndex,
            columnIndex: columnIndex,
          );
        },
      ),
    );
  }

  /// Builds alignment dropdown
  Widget _buildAlignmentDropdown(
    BuildContext context,
    LinkFieldController controllers,
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
