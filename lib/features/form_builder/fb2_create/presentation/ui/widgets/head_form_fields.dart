/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: head_form_fields.dart
/// Description: `HeadFormFields` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';
import 'package:knowticed_plus/features/form_builder/helpers/text_in_language.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Keep for .tr translations and extensions
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/helper_format.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/validation/validator.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder/helpers/add_image_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/slider_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/watermark_widget.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';

/// The header fields of the form editor. Owns the text controllers (Home
/// rule 7); typing is sent to [CreateFormHeadCubit], and values the cubit
/// replaces (opening a form, "Fill demo data") are copied back in.
class HeadFormFields extends StatefulWidget {
  final CreateFormHeadLoaded state;
  final bool isReadOnly;

  const HeadFormFields({
    super.key,
    required this.state,
    required this.isReadOnly,
  });

  @override
  State<HeadFormFields> createState() => _HeadFormFieldsState();
}

class _HeadFormFieldsState extends State<HeadFormFields> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _arTitle = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _arDescription = TextEditingController();
  final TextEditingController _horizontalPadding = TextEditingController();
  final TextEditingController _verticalPadding = TextEditingController();
  int _fieldsVersion = -1;

  CreateFormHeadLoaded get state => widget.state;
  bool get isReadOnly => widget.isReadOnly;

  @override
  void initState() {
    super.initState();
    _copyFromState();
  }

  @override
  void didUpdateWidget(covariant HeadFormFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.fieldsVersion != _fieldsVersion) _copyFromState();
  }

  void _copyFromState() {
    _fieldsVersion = state.fieldsVersion;
    _title.text = state.title;
    _arTitle.text = state.arTitle;
    _description.text = state.description;
    _arDescription.text = state.arDescription;
    _horizontalPadding.text = state.horizontalPadding;
    _verticalPadding.text = state.verticalPadding;
  }

  @override
  void dispose() {
    _title.dispose();
    _arTitle.dispose();
    _description.dispose();
    _arDescription.dispose();
    _horizontalPadding.dispose();
    _verticalPadding.dispose();
    super.dispose();
  }

  CreateFormHeadCubit get _cubit => context.read<CreateFormHeadCubit>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpace(15),
        AddImageWidget(
          image: state.cover,
          onImagePicked: (file) => _cubit.setCoverImage(file),
        ),
        verticalSpace(15),
        _buildTitleFields(context),
        verticalSpace(15),
        _buildDescriptionFields(context),
        verticalSpace(15),
        _buildDropDownFields(context, state, isReadOnly),
        verticalSpace(15),
        _buildPaddingFields(context),
        verticalSpace(15),
        const WatermarkWidget(),
        verticalSpace(40),
        _buildWatermarkSliders(context, state, isReadOnly),
        verticalSpace(15),
      ],
    );
  }

  Widget _buildTitleFields(BuildContext context) {
    // The field in the app's language comes first.
    final bool arFirst = context.isArabic;
    return ContextExtension(context).isTablett
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child: _buildTitleField(arabicContent: arFirst)),
              horizontalSpace(20),
              Expanded(child: _buildTitleField(arabicContent: !arFirst)),
            ],
          )
        : Column(
            children: [
              _buildTitleField(arabicContent: arFirst),
              verticalSpace(15),
              _buildTitleField(arabicContent: !arFirst),
            ],
          );
  }

  /// One title input. [arabicContent] says which COPY the field holds (the
  /// Arabic or the English title), not the app language: each field's label
  /// and hint are in the language of its content. Do not wrap it in
  /// `Localizations.override` — that reloads `S` for the whole app.
  Widget _buildTitleField({required bool arabicContent}) {
    final ui.TextDirection direction = arabicContent
        ? ui.TextDirection.rtl
        : ui.TextDirection.ltr;
    return Directionality(
      textDirection: direction,
      child: CustomTextField(
        height: 36,
        hint: textInFormLanguage(arabicContent, (s) => s.textHere),
        readOnly: isReadOnly,
        label: textInFormLanguage(arabicContent, (s) => s.formTitle),
        controller: arabicContent ? _arTitle : _title,
        textDirection: direction,
        inputFormatters: arabicContent
            ? [InputFormattersHelper.arabicOnly()]
            : [InputFormattersHelper.englishOnly()],
        onChanged: isReadOnly
            ? null
            : (value) {
                if (arabicContent) {
                  _cubit.updateArTitle(value);
                  return;
                }
                final String capitalized = FormatHelper.capitalize(value);
                if (_title.text != capitalized) {
                  _title.value = _title.value.copyWith(
                    text: capitalized,
                    selection: TextSelection.collapsed(
                      offset: capitalized.length,
                    ),
                  );
                }
                _cubit.updateTitle(capitalized);
              },
      ),
    );
  }

  Widget _buildDescriptionFields(BuildContext context) {
    return Column(
      children: [
        // The field in the app's language comes first.
        _buildDescriptionField(arabicContent: context.isArabic),
        verticalSpace(15),
        _buildDescriptionField(arabicContent: !context.isArabic),
      ],
    );
  }

  /// One description input; see [_buildTitleField] for [arabicContent].
  Widget _buildDescriptionField({required bool arabicContent}) {
    final ui.TextDirection direction = arabicContent
        ? ui.TextDirection.rtl
        : ui.TextDirection.ltr;
    final TextEditingController controller = arabicContent
        ? _arDescription
        : _description;
    return Directionality(
      textDirection: direction,
      child: CustomTextField(
        readOnly: isReadOnly,
        minLines: 3,
        maxLines: 10,
        maxLength: 500,
        showCharCount: true,
        textDirection: direction,
        hint: textInFormLanguage(arabicContent, (s) => s.textHere),
        label: textInFormLanguage(arabicContent, (s) => s.description),
        controller: controller,
        onChanged: (value) {
          final String capitalized = FormatHelper.capitalize(value);
          if (controller.text != capitalized) {
            controller.value = controller.value.copyWith(
              text: capitalized,
              selection: TextSelection.collapsed(offset: capitalized.length),
            );
          }
          if (arabicContent) {
            _cubit.updateArDescription(capitalized);
          } else {
            _cubit.updateDescription(capitalized);
          }
        },
      ),
    );
  }

  Widget _buildDropDownFields(
    BuildContext context,
    CreateFormHeadLoaded state,
    bool isReadOnly,
  ) {
    return ContextExtension(context).isTablett
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildAccessManagementDropdown(
                  context,
                  state,
                  isReadOnly,
                ),
              ),
              horizontalSpace(20),
              Expanded(
                child: _buildOrientationDropdown(context, state, isReadOnly),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAccessManagementDropdown(context, state, isReadOnly),
              verticalSpace(15),
              _buildOrientationDropdown(context, state, isReadOnly),
            ],
          );
  }

  Widget _buildAccessManagementDropdown(
    BuildContext context,
    CreateFormHeadLoaded state,
    bool isReadOnly,
  ) {
    return DropDownWidget(
      isReadOnly: isReadOnly,
      validator: (value) =>
          _validateRequiredDropdown(value, S.of(context).accessManagement),
      onChanged: (value) {
        context.read<CreateFormHeadCubit>().updateAccessManagement(value);
      },
      title: S.of(context).accessManagement,
      hint: S.of(context).chooseAccessManagement,
      items: EnumDropdownItems.accessManagement,
      currentValue: state.accessManagement,
    );
  }

  Widget _buildOrientationDropdown(
    BuildContext context,
    CreateFormHeadLoaded state,
    bool isReadOnly,
  ) {
    return DropDownWidget(
      isReadOnly: isReadOnly,
      validator: (value) =>
          _validateRequiredDropdown(value, S.of(context).orientation),
      onChanged: (value) {
        context.read<CreateFormHeadCubit>().updateOrientation(value);
      },
      title: S.of(context).orientation,
      hint: S.of(context).chooseOrientation,
      items: EnumDropdownItems.orientation,
      currentValue: state.orientation,
    );
  }

  /// Placeholder for the two padding inputs: "Text Here", the same string
  /// the Form Title field uses (Figma MESBAH / node 7444-41775).
  String _paddingHint(BuildContext context) => S.of(context).textHere;

  Widget _paddingField(
    BuildContext context, {
    required bool horizontal,
    required String hint,
  }) {
    return CustomTextField(
      height: 36,
      readOnly: isReadOnly,
      keyboardType: TextInputType.number,
      label: horizontal
          ? S.of(context).horizontalPadding
          : S.of(context).verticalPadding,
      hint: hint,
      controller: horizontal ? _horizontalPadding : _verticalPadding,
      onChanged: (value) => horizontal
          ? _cubit.updateHorizontalPadding(value)
          : _cubit.updateVerticalPadding(value),
    );
  }

  Widget _buildPaddingFields(BuildContext context) {
    final String hint = _paddingHint(context);
    return ContextExtension(context).isTablett
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _paddingField(context, horizontal: true, hint: hint),
              ),
              horizontalSpace(20),
              Expanded(
                child: _paddingField(context, horizontal: false, hint: hint),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _paddingField(context, horizontal: true, hint: hint),
              verticalSpace(15),
              _paddingField(context, horizontal: false, hint: hint),
            ],
          );
  }

  Widget _buildWatermarkSliders(
    BuildContext context,
    CreateFormHeadLoaded state,
    bool isReadOnly,
  ) {
    final double watermarkSize = double.tryParse(state.watermarkSize) ?? 100.0;
    final double watermarkOpacity =
        double.tryParse(state.watermarkOpacity) ?? 50.0;

    return ContextExtension(context).isTablett
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SliderWidget(
                  title: S.of(context).watermarkSize,
                  currantValue: watermarkSize,
                  onChanged: isReadOnly
                      ? null
                      : (value) {
                          context
                              .read<CreateFormHeadCubit>()
                              .updateWatermarkSize(value.round().toString());
                        },
                ),
              ),
              horizontalSpace(20),
              Expanded(
                child: SliderWidget(
                  title: S.of(context).watermarkOpacity,
                  currantValue: watermarkOpacity,
                  onChanged: isReadOnly
                      ? null
                      : (value) {
                          context
                              .read<CreateFormHeadCubit>()
                              .updateWatermarkOpacity(value.round().toString());
                        },
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SliderWidget(
                title: S.of(context).watermarkSize,
                currantValue: watermarkSize,
                onChanged: isReadOnly
                    ? null
                    : (value) {
                        context.read<CreateFormHeadCubit>().updateWatermarkSize(
                          value.round().toString(),
                        );
                      },
              ),
              verticalSpace(15),
              SliderWidget(
                title: S.of(context).watermarkOpacity,
                currantValue: watermarkOpacity,
                onChanged: isReadOnly
                    ? null
                    : (value) {
                        context
                            .read<CreateFormHeadCubit>()
                            .updateWatermarkOpacity(value.round().toString());
                      },
              ),
            ],
          );
  }

  String? _validateRequiredDropdown(dynamic value, String fieldName) {
    return Validator.isEmpty(value, fieldName);
  }
}
