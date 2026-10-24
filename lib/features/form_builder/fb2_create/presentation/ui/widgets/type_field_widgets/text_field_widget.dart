/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: text_field_widget.dart
/// Description: `TextFieldWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Keep for .tr translations and locale
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/actions_row_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/helper/extensions.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/field_text_binder.dart';

class TextFieldWidget extends StatelessWidget {
  final int columnIndex;
  final int rowIndex;
  final int pageIndex;
  final bool isReadOnly;

  const TextFieldWidget({
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

        // Get the number of columns for this row
        final numColumnsText = state
            .pages[pageIndex]
            .rows[rowIndex]
            .numOfColumn!
            .text
            .toEnglishNumber();
        final numColumns = numColumnsText;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitleField(context, state),
            verticalSpace(15),
            _buildHintField(context, state),
            // Only show alignment dropdown when there's exactly 1 column
            if (numColumns == 1) ...[
              verticalSpace(15),
              _buildAlignmentDropdown(context, state),
            ],

            verticalSpace(18),
            _buildActionsRow(),
          ],
        );
      },
    );
  }

  // Updated Title field with capitalization AND live preview
  Widget _buildTitleField(BuildContext context, CreateFormDataLoaded state) {
    final TextFieldController controllers =
        state.pages[pageIndex].rows[rowIndex].controllers[columnIndex]
            as TextFieldController;

    return FieldTextBinder(
      text: controllers.title!,
      builder: (context, textController) => CustomTextField(
        height: 36,
        label: S.current.fbAddTitle,
        readOnly: isReadOnly,
        onChanged: (value) {
          // Apply capitalization
          final cursorPosition = textController.selection.base.offset;
          final capitalizedText = FormatHelper.capitalize(value);

          textController.value = TextEditingValue(
            text: capitalizedText,
            selection: TextSelection.collapsed(
              offset: cursorPosition.clamp(0, capitalizedText.length),
            ),
          );

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

  // Updated Hint field with capitalization AND live preview
  Widget _buildHintField(BuildContext context, CreateFormDataLoaded state) {
    final TextFieldController controllers =
        state.pages[pageIndex].rows[rowIndex].controllers[columnIndex]
            as TextFieldController;

    return FieldTextBinder(
      text: controllers.hint!,
      builder: (context, textController) => CustomTextField(
        height: 36,
        label: S.current.fbAddHint,
        readOnly: isReadOnly,
        onChanged: (value) {
          // Apply capitalization
          final cursorPosition = textController.selection.base.offset;
          final capitalizedText = FormatHelper.capitalize(value);

          textController.value = TextEditingValue(
            text: capitalizedText,
            selection: TextSelection.collapsed(
              offset: cursorPosition.clamp(0, capitalizedText.length),
            ),
          );

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

  // Alignment dropdown method
  Widget _buildAlignmentDropdown(
    BuildContext context,
    CreateFormDataLoaded state,
  ) {
    final TextFieldController controllers =
        state.pages[pageIndex].rows[rowIndex].controllers[columnIndex]
            as TextFieldController;

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
