/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: image_field_widget.dart
/// Description: `ImageFieldWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Keep for .tr translations
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/image_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/actions_row_widget.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/field_text_binder.dart';

/// Widget for creating an image field in a dynamic form
class ImageFieldWidget extends StatelessWidget {
  const ImageFieldWidget({
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

        final ImageFieldController controllers =
            state.pages[pageIndex].rows[rowIndex].controllers[columnIndex]
                as ImageFieldController;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input field
            _buildTitleField(context, controllers),
            verticalSpace(15),

            // Limitation input field
            _buildLimitationField(context, controllers),
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
    ImageFieldController controllers,
  ) {
    return FieldTextBinder(
      text: controllers.title!,
      builder: (context, textController) => CustomTextField(
        height: 36,
        readOnly: isReadOnly,
        label: S.current.fbAddTitle,
        onChanged: (p0) {
          // State updates automatically through text controller
        },
        controller: textController,
      ),
    );
  }

  /// Builds limitation input field
  Widget _buildLimitationField(
    BuildContext context,
    ImageFieldController controllers,
  ) {
    return FieldTextBinder(
      text: controllers.limitation!,
      builder: (context, textController) => CustomTextField(
        height: 36,
        readOnly: isReadOnly,
        label: S.current.fbLimitation,
        keyboardType: TextInputType.number,
        controller: textController,
        onChanged: (value) {
          controllers.insertImagesList(value);
          // State updates automatically through text controller
        },
      ),
    );
  }

  /// Builds action row for form management
  Widget _buildActionRow() {
    if (isReadOnly) {
      return const SizedBox.shrink();
    }
    return ActionsRowWidget(
      pageIndex: pageIndex,
      columnIndex: columnIndex,
      rowIndex: rowIndex,
    );
  }
}
