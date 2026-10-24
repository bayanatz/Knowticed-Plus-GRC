/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: drop_down_result_widget.dart
/// Description: `DropDownResultWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/validation/validator.dart';
// Was `45-custom_app_dropdown.dart` (`AppDropdown`, built on the
// `dropdown_button2` package). A form dropdown now renders through the app's
// own `CustomDropdown`, the same component every other form control on these
// screens is built from, so the preview matches the `CustomTextField` beside
// it instead of approximating it through a second implementation.
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/drop_down_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/drop_down_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_text.dart';

class DropDownResultWidget extends StatelessWidget {
  const DropDownResultWidget({
    super.key,
    this.reviewModel,
    this.fieldController,
    this.value,
    this.isReadOnly = false,
    this.isValidated = false,
    this.isExpand = false,
    this.isWhiteFill = false,
    this.onChanged,
  });
  final bool isExpand; // Not used in this widget, can be removed
  final DropDownFieldController? fieldController;
  final DropDownFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isReadOnly;
  final dynamic Function(dynamic)? onChanged;
  final String? value;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _getAlignment(),
      child: SizedBox(
        width: isExpand ? null : _calculateWidth(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextRequiredWidget(isRequired: _getIsRequired(), text: _getTitle()),
            // Was verticalSpace(8), and THIS was the misalignment — not
            // the box. Every other widget in `type_result_widgets/` puts 4
            // between the title and the input, so in a multi-column row the
            // dropdown started 4.h lower than the `CustomTextField` beside it
            // and every pixel below it inherited the offset. Matching `height`
            // and content padding could never close it: the two boxes were
            // already the same size, they just did not start at the same y.
            verticalSpace(4),
            _buildDropdown(context),
          ],
        ),
      ),
    );
  }

  /// Calculate widget width based on alignment and device type
  double _calculateWidth(BuildContext context) {
    String? alignment = fieldController != null
        ? fieldController!.alignment
        : reviewModel!.alignment;
    return alignment != AlignmentEnum.expand.name
        ? (ContextExtension(context).isTablett ? 200.w : 365.w)
        : double.infinity;
  }

  /// Build dropdown widget
  ///
  /// The `FormField` wrapper is NOT decoration — do not remove it. `AppDropdown`
  /// wrapped `DropdownButtonFormField2`, which IS a `FormField`, so a required
  /// dropdown left empty was caught by `_formKey.currentState!.validate()` in
  /// `fill_out_screen.dart`. `CustomDropdown` is a plain `StatefulWidget` that
  /// reports errors through `errorText` and joins no `Form`, so dropping it in
  /// bare would have silently removed that gate: the second validation layer,
  /// `FillOutCubit._checkCustomValidation()`, calls
  /// `FieldController.getIsValidated()`, and that returns the `default: true`
  /// branch for `FormFieldType.dropDown`. Nothing else covers this field.
  ///
  /// The trigger height moved from a wrapping `SizedBox(height: 36)` to
  /// `CustomDropdown.height`, which sizes the TRIGGER only. A `SizedBox` would
  /// have pinned the whole column and clipped the error line under it.
  Widget _buildDropdown(BuildContext context) {
    final String? current = value ?? fieldController?.currentValue;

    return FormField<String>(
      initialValue: current,
      validator: _getValidate,
      builder: (FormFieldState<String> state) {
        return CustomDropdown<String>(
          value: current,
          items: _getItems(current),
          hint: S.of(context).chooseHere,
          height: 36,
          triggerPadding: EdgeInsets.symmetric(
            vertical: 12.sp,
            horizontal: 10.sp,
          ),
          fillColor: isWhiteFill ? AppColors.white : AppColors.background,
          errorText: state.errorText,
          onChanged: (String selected) {
            // Keeps the FormField's own value in step with the controller, so
            // a later `validate()` sees what the user actually picked.
            state.didChange(selected);
            // Bug report #21: a "required" error raised by an earlier submit
            // stayed under the field after a value was picked. Re-validate so
            // it clears at once.
            if (state.hasError) state.validate();
            onChanged?.call(selected);
          },
        );
      },
    );
  }

  Alignment _getAlignment() {
    if (reviewModel == null) {
      return fieldController!.alignment!.alignment;
    }
    return reviewModel!.alignment.alignment;
  }

  bool _getIsRequired() {
    bool flag = false;
    if (reviewModel != null) {
      flag = reviewModel?.isRequired ?? false;
      return flag;
    }
    flag = fieldController?.isRequired ?? false;
    return flag;
  }

  String _getTitle() {
    if (reviewModel != null) {
      return reviewModel?.title ?? '';
    }
    return fieldController?.title?.text ?? '';
  }

  /// Options for the trigger menu.
  ///
  /// Built from `hints` here rather than from `dropDownItems()`: that helper
  /// returns Material `DropdownMenuItem<String>` and is still what the PDF and
  /// builder widgets need, while `CustomDropdown` takes `DropdownItem<String>`.
  /// Changing the helper would have rippled into those callers.
  ///
  /// [current] is folded in when it is not among the hints. `CustomDropdown`
  /// resolves the trigger label by matching `value` against `items` and falls
  /// back to the hint when nothing matches, whereas `AppDropdown` printed
  /// `textButton` verbatim. Without this, a stored answer whose option was
  /// later renamed or removed in the form definition would render as an empty
  /// "Choose Here" on the submissions screens instead of showing the answer.
  List<DropdownItem<String>> _getItems(String? current) {
    final List<String> options = reviewModel != null
        ? List<String>.from(reviewModel!.hints)
        : (fieldController?.hints ?? const <FieldText>[])
              .map((FieldText hint) => hint.text)
              .toList();

    if (current != null && current.isNotEmpty && !options.contains(current)) {
      options.add(current);
    }

    return options
        .map(
          (String option) => DropdownItem<String>(value: option, label: option),
        )
        .toList();
  }

  String? _getValidate(String? value) {
    if (!isValidated) {
      return null;
    }
    if (!(fieldController?.isRequired ?? false)) {
      return null;
    }
    return Validator.isEmpty(value, fieldController?.title?.text ?? '');
  }
}
