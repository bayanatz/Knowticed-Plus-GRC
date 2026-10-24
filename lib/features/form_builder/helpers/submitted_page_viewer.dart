/// Module: core/helper/form_builder
///
///*************************** FILE INFO ****************************///
/// File Name: submitted_page_viewer.dart
/// Description: `SubmittedPageViewer` widget, state and UI of the `SubmittedPageViewer` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder/presentation/ui/widgets/form_builder_form_language.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Keep for .tr
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder/fb7_convert_pdf/presentation/controller/pdf_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb7_convert_pdf/presentation/controller/pdf_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/address_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/attachment_digital_signature_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/attachment_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/check_box_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/date_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/description_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/drop_down_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/email_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/image_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/link_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/location_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/phone_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/radio_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/radio_text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/terms_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/time_selector_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/title_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/terms_conditions_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/page_controller_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/address_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/attachment_digital_signature_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/attachment_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/check_box_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/date_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/description_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/drop_down_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/email_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/image_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/link_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/location_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/phone_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/radio_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/radio_text_field_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/text_field_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/time_selector_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/title_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/features/form_builder/helpers/attachment_helper.dart';
import 'package:knowticed_plus/features/form_builder/form_builder_get_it.dart';
import 'package:knowticed_plus/features/form_builder/fb7_convert_pdf/presentation/utils/pdf_page_keys.dart';

class SubmittedPageViewer extends StatefulWidget {
  const SubmittedPageViewer({
    required this.model,
    required this.pages,
    required this.isReadOnly,
    this.isSubmitted = true,
    this.width,
    this.onAnyChanged,
    super.key,
  });

  /// Called after ANY answer changes, so the page can re-check whether
  /// Submit may be unlocked (form bug report #16/#22).
  final VoidCallback? onAnyChanged;

  final double? width;
  final List<PageControllerModel> pages;
  final FormEntity model;
  final bool isReadOnly;
  final bool isSubmitted;

  @override
  State<SubmittedPageViewer> createState() => _SubmittedPageViewerState();
}

class _SubmittedPageViewerState extends State<SubmittedPageViewer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PdfCubit, PdfState>(
      builder: (context, pdfState) {
        if (pdfState is! PdfLoaded) {
          // If PdfCubit is not loaded yet, initialize it now
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              preparePdfPages(context, widget.pages.length);
            }
          });
          return const Center(child: CircleProgressMaster.inline());
        }

        // Safety check: the page count must match pages length
        if (pdfState.isExpanded.length != widget.pages.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              preparePdfPages(context, widget.pages.length);
            }
          });
          return const Center(child: CircleProgressMaster.inline());
        }

        //
        // an English form stays English — direction, pickers, AM/PM — even
        // when the app runs in Arabic, and vice versa.
        final bool formIsArabic =
            FormLanguageDetect.detectFromEntity(widget.model) ??
            context.isArabic;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (
              int pageIndex = 0;
              pageIndex < widget.pages.length;
              pageIndex++
            ) ...[
              if (widget.pages.length != 1) ...[
                verticalSpace(10),
                Text(
                  '${S.of(context).page} ${pageIndex + 1}',
                  style: StyleText.fontSize14Weight500,
                ),
                verticalSpace(10),
              ],
              Container(
                width: widget.width,
                constraints: BoxConstraints(minHeight: 323.h),
                decoration: ShapeDecoration(
                  color: AppColors.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: RepaintBoundary(
                  key: context.read<PdfPageKeys>().keyAt(pageIndex),
                  child: FormLanguageScope(
                    isArabic: formIsArabic,
                    child: Stack(
                      children: [
                        _buildWatermark(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                widget.model.formHeadModel.horizontalPadding ??
                                16,
                            vertical:
                                widget.model.formHeadModel.verticalPadding ??
                                16,
                          ),
                          child: Column(
                            children: [_buildPageRows(pageIndex, context)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// The form's watermark behind the page.
  Widget _buildWatermark() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      top: 0,
      child: Transform.scale(
        scale: (widget.model.formHeadModel.watermarkSize! / 100),
        child: Opacity(
          opacity: (widget.model.formHeadModel.watermarkOpacity! / 100),
          child: widget.model.formHeadModel.watermark == null
              ? null
              : Image.network(widget.model.formHeadModel.watermark!),
        ),
      ),
    );
  }

  Widget _buildPageRows(int pageIndex, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (
          int indexRow = 0;
          indexRow < widget.pages[pageIndex].rows.length;
          indexRow++
        ) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildRowWidgets(pageIndex, indexRow),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildRowWidgets(int pageIndex, int rowIndex) {
    final rowControllers = widget.pages[pageIndex].rows[rowIndex].controllers;

    return List.generate(
      rowControllers.length,
      (index) => [
        if (index != 0) horizontalSpace(15),
        Expanded(
          child: _buildWidget(
            rowControllers[index].type,
            rowControllers[index],
            rowControllers.length > 1,
          ),
        ),
      ],
    ).expand((element) => element).toList();
  }

  Widget _buildWidget(
    FormFieldType type,
    FieldController controller,
    bool isExpand,
  ) {
    final widgetMap = {
      FormFieldType.dropDown: () => DropDownResultWidget(
        fieldController: controller as DropDownFieldController,
        isValidated: true,
        value: controller.currentValue,
        isExpand: isExpand,
        isReadOnly: true,
        onChanged: _isOnChange()
            ? (value) {
                controller.currentValue = value;
                setState(() {});
                widget.onAnyChanged?.call();
              }
            : null,
      ),
      FormFieldType.image: () {
        final ImageFieldController imageController =
            controller as ImageFieldController;
        return ImagePreviewWidget(
          fieldController: imageController,
          isValidated: true,
          isShownError: widget.isSubmitted,
          isReadOnly: widget.isReadOnly,
          // Bug report p.16: open the device's images and show the pick.
          onPickImage: _isOnChange()
              ? (int index) async {
                  final File? file = await FormBuilderCubits.mediaPicker
                      .pickImageFile();
                  if (file == null) return;
                  while (imageController.images.length <= index) {
                    imageController.images.add(null);
                  }
                  while (imageController.imagesLink.length <= index) {
                    imageController.imagesLink.add(null);
                  }
                  imageController.images[index] = file;
                  imageController.imagesLink[index] = file.path;
                  if (mounted) setState(() {});
                  widget.onAnyChanged?.call();
                }
              : null,
        );
      },
      FormFieldType.textField: () => TextFieldResultWidget(
        fieldController: controller as TextFieldController,
        isValidated: true,
        isExpand: isExpand,
        isReadOnly: widget.isReadOnly,
        onChanged: _isOnChange()
            ? (value) {
                controller.answer = value;
                widget.onAnyChanged?.call();
              }
            : null,
      ),
      FormFieldType.email: () => EmailResultWidget(
        fieldController: controller as EmailFieldController,
        isValidated: true,
        isExpand: isExpand,
        isReadOnly: widget.isReadOnly,
        onChanged: _isOnChange()
            ? (value) {
                controller.answer = value;
                widget.onAnyChanged?.call();
              }
            : null,
      ),
      FormFieldType.phone: () => PhoneResultWidget(
        fieldController: controller as PhoneFieldController,
        isValidated: true,
        isExpand: isExpand,
        isReadOnly: widget.isReadOnly,
        onSelectCountry: _isOnChange()
            ? (value) {
                controller.currentCountry = value.countryCode;
                setState(() {});
                widget.onAnyChanged?.call();
              }
            : null,
        onChangePhone: _isOnChange()
            ? (value) {
                controller.phoneAnswer = value;
                widget.onAnyChanged?.call();
              }
            : null,
      ),
      FormFieldType.radio: () => RadioResultWidget(
        fieldController: controller as RadioFieldController,
        isValidated: true,
        // Bug report p.11 / p.20 / p.61: was `true`, so "… Required" showed
        // before the user had pressed Submit (and on the read-only details
        // page). Same gate every other field here uses.
        isShownError: widget.isSubmitted,
        isReadOnly: widget.isReadOnly,
        onTapRadio: _isOnChange()
            ? (String value) {
                controller.selectedRadio = value;
                setState(() {});
                widget.onAnyChanged?.call();
              }
            : null,
      ),
      FormFieldType.checkBox: () => CheckBoxResultWidget(
        fieldController: controller as CheckBoxFieldController,
        isValidated: true,
        isShownError: widget.isSubmitted,
        isReadOnly: widget.isReadOnly,
        onChanged: widget.onAnyChanged,
      ),
      FormFieldType.termsAndCondition: () => TermsAndConditionsPreviewWidget(
        fieldController: controller as TermsConditionsFieldController,
        isReadOnly: widget.isReadOnly,
      ),
      FormFieldType.description: () => DescriptionResultWidget(
        fieldController: controller as DescriptionFieldController,
        isValidated: true,
        isExpand: isExpand,
        isReadOnly: widget.isReadOnly,
      ),
      FormFieldType.link: () => LinkResultWidget(
        fieldController: controller as LinkFieldController,
        isValidated: true,
        isExpand: isExpand,
        isReadOnly: widget.isReadOnly,
        onChanged: _isOnChange()
            ? (value) {
                controller.answer = value;
                widget.onAnyChanged?.call();
              }
            : null,
      ),
      FormFieldType.title: () => TitleResultWidget(
        fieldController: controller as TitleFieldController,
        isValidated: true,
      ),
      FormFieldType.dateSelector: () => DatePreviewWidget(
        fieldController: controller as DateFieldController,
        isValidated: true,
        // Bug report p.11: no "Date Required" before Submit is pressed.
        isShownError: widget.isSubmitted,
        isExpand: isExpand,
        isReadOnly: widget.isReadOnly,
        onDateChanged: (value) {
          controller.answerDate = value;
          // Bug report #21: repaint now so the date (and its error) update
          // immediately.
          setState(() {});
          widget.onAnyChanged?.call();
        },
      ),
      FormFieldType.address: () => AddressPreviewWidget(
        fieldController: controller as AddressFieldController,
        isValidated: true,
        isReadOnly: widget.isReadOnly,
        onChanged: _isOnChange()
            ? (value, index) {
                if (controller.answers == null || controller.answers!.isEmpty) {
                  controller.answers = List.generate(
                    controller.hints!.length,
                    (index) => '',
                  );
                }
                controller.answers![index] = value;
                widget.onAnyChanged?.call();
              }
            : null,
      ),
      FormFieldType.timeSelector: () => TimeSelectorPreviewWidget(
        fieldController: controller as TimeSelectorFieldController,
        isValidated: true,
        isReadOnly: widget.isReadOnly,
        onTapZone: _isOnChange()
            ? () {
                if (controller.amOrPM == "AM") {
                  controller.amOrPM = 'PM';
                  setState(() {});
                  return;
                }
                controller.amOrPM = 'AM';
                setState(() {});
                widget.onAnyChanged?.call();
              }
            : null,
        onTapTime: _isOnChange()
            ? (value) {
                String formattedTime = FormDateTimeHelper.formatTime(
                  FormDateTimeHelper.formatTimeOfDayToDateTime(value, null),
                );
                controller.time = formattedTime.split(" ")[0];
                controller.amOrPM = formattedTime.split(" ")[1];

                setState(() {});
              }
            : null,
      ),
      // A picked file did not show until another field
      // (e.g. a dropdown) rebuilt the page, and the remove (minus) did
      // nothing. The widget fell back to FillOutCubit, which is not loaded on
      // this page, so neither action redrew anything. Wired like the
      // eSignature below: change the controller, setState, report the change.
      FormFieldType.attachment: () => AttachmentPreviewWidget(
        fieldController: controller as AttachmentFieldController,
        isValidated: true,
        isShownError: widget.isSubmitted,
        isReadOnly: widget.isReadOnly,
        onSelectAttachment: _isOnChange()
            ? () async {
                final File? file = await FormBuilderCubits.mediaPicker
                    .pickAnyFileAsFile();
                if (file == null) {
                  return; // cancelled — keep the current file
                }
                (controller).attachmentEntity = attachmentEntityFromFile(file);
                if (mounted) setState(() {});
                widget.onAnyChanged?.call();
              }
            : null,
        onRemoveAttachment: _isOnChange()
            ? () {
                (controller).attachmentEntity = null;
                setState(() {});
                widget.onAnyChanged?.call();
              }
            : null,
      ),
      FormFieldType.digitalSignature: () =>
          AttachmentDigitalSignatureResultWidget(
            fieldController:
                controller as AttachmentDigitalSignatureFieldController,
            isValidated: true,
            isShownError: widget.isSubmitted,
            isReadOnly: widget.isReadOnly,
            // Bug report p.14: "Upload eSignature" did nothing.
            onSelectSignature: _isOnChange()
                ? () async {
                    final File? file = await FormBuilderCubits.mediaPicker
                        .pickImageFile();
                    if (file == null) return;
                    (controller).attachmentEntity = attachmentEntityFromFile(
                      file,
                    );
                    if (mounted) setState(() {});
                    widget.onAnyChanged?.call();
                  }
                : null,
            onRemoveSignature: _isOnChange()
                ? () {
                    (controller).attachmentEntity = null;
                    setState(() {});
                    widget.onAnyChanged?.call();
                  }
                : null,
          ),
      FormFieldType.location: () => LocationResultWidget(
        fieldController: controller as LocationFieldController,
        isValidated: true,
        isReadOnly: widget.isReadOnly,
      ),
      FormFieldType.radioTextField: () => RadioTextFieldResultWidget(
        fieldController: controller as RadioTextFieldController,
        isValidated: true,
        isShownError: widget.isSubmitted,
        isReadOnly: widget.isReadOnly,
        onTapRadio: _isOnChange()
            ? (String value) {
                controller.selectedRadio = value;
                setState(() {});
                widget.onAnyChanged?.call();
              }
            : null,
      ),
    };

    return widgetMap[type]!();
  }

  bool _isOnChange() {
    return widget.model.status != FormStatus.submissions ||
        (widget.model.status == FormStatus.submissions && !widget.isReadOnly);
  }
}
