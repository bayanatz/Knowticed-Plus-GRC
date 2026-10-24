/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: attachment_digital_signature_result_widget.dart
/// Description: `AttachmentDigitalSignatureResultWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

// ignore_for_file: deprecated_member_use

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/attachment_entity.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/validation/validator.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/attachment_uploaded_widget.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/attachment_digital_signature_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/attachment_digital_signature_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';

class AttachmentDigitalSignatureResultWidget extends StatelessWidget {
  const AttachmentDigitalSignatureResultWidget({
    super.key,
    this.fieldController,
    this.reviewModel,
    this.isValidated = false,
    this.isWhiteFill = false,
    this.isReadOnly = false,
    this.isShownError = false,
    this.onSelectSignature,
    this.onRemoveSignature,
  });

  final AttachmentDigitalSignatureFieldController? fieldController;

  ///
  /// the button fell back to `Get.find<FillOutCubit>()`, which throws because
  /// FillOutCubit is provided through BlocProvider, not registered with GetX.
  /// The fill-out viewer passes these instead.
  final Future<void> Function()? onSelectSignature;
  final VoidCallback? onRemoveSignature;
  final AttachmentDigitalSignatureFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isShownError, isReadOnly;

  @override
  Widget build(BuildContext context) {
    // The title sat on the
    // far right above the button. The title now starts the row (left in
    // English, right in Arabic) with the Upload eSignature button directly
    // beside it.
    return Align(
      alignment: _getAlignment(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: _getCrossAxis(context),
        children: [
          Row(
            // min: a full-width Row would leave nothing for Align to move.
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: TextRequiredWidget(
                  isRequired: _getIsRequired(),
                  text: _getTitle(),
                ),
              ),
              horizontalSpace(10),
              _getSignatureWidget(context),
            ],
          ),
          _getErrorWidget(),
        ],
      ),
    );
  }

  /// The Choose Alignment dropdown was ignored, so this
  /// field always sat at the start of its column. Same mapping as the other
  /// fields (`String.alignment`: Left / Center / Right, Expand = Left).
  Alignment _getAlignment() {
    final String? value = reviewModel != null
        ? reviewModel!.alignment
        : fieldController?.alignment;
    return (value ?? AlignmentEnum.center.name).alignment;
  }

  /// Keeps the title / error text lined up with the aligned block.
  CrossAxisAlignment _getCrossAxis(BuildContext context) {
    final double x = _getAlignment().x;
    if (x == 0) return CrossAxisAlignment.center;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final bool left = x < 0;
    return (left != rtl) ? CrossAxisAlignment.start : CrossAxisAlignment.end;
  }

  Widget _getErrorWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpace(4),
        if (isShownError &&
            _isErrorNull(fieldController?.attachmentEntity) == null)
          Text(
            _getError() ?? '',
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
          ),
      ],
    );
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

  Widget _getSignatureWidget(BuildContext context) {
    // If signature is uploaded, show it
    if (fieldController?.attachmentEntity != null) {
      return IntrinsicWidth(
        child: AttachmentUploadedWidget(
          isReadOnly: isReadOnly,
          onCloseTap: () {
            if (isReadOnly) return;
            onRemoveSignature?.call();
          },
          attachmentEntity: fieldController!.attachmentEntity!,
        ),
      );
    }

    return customButtonWithSvg(
      title: S.of(context).fbUploadESignature,
      function: () {
        if (isReadOnly) return;
        onSelectSignature?.call();
      },
      textStyle: StyleText.fontSize14Weight500.copyWith(
        color: AppColors.textButton,
      ),
      color: AppColors.primary,
      image: AppAssets.downloadLinear,
      widthImage: 20,
      heightImage: 20,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.black,
    );
  }

  String? _isErrorNull(AttachmentEntity? file) {
    if (file == null) {
      return null;
    }
    return 'as';
  }

  String? _getError() {
    if (isValidated) {
      if (fieldController?.isRequired ?? false) {
        String? error = Validator.isEmpty(
          _isErrorNull(fieldController?.attachmentEntity),
          fieldController?.title?.text ?? '',
        );
        return error ?? '';
      }
    }
    return null;
  }
}
