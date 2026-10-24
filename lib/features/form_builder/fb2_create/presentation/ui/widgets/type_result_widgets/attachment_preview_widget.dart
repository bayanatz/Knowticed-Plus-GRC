/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: attachment_preview_widget.dart
/// Description: `AttachmentPreviewWidget` widget.
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
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/attachment_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/attachment_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';

class AttachmentPreviewWidget extends StatelessWidget {
  const AttachmentPreviewWidget({
    super.key,
    this.fieldController,
    this.reviewModel,
    this.isValidated = false,
    this.isWhiteFill = false,
    this.isReadOnly = false,
    this.isShownError = false,
    this.onSelectAttachment,
    this.onRemoveAttachment,
  });

  final AttachmentFieldController? fieldController;

  /// "attachment does not appear until a dropdown item is
  /// picked, and the remove (minus) does nothing" on the Submissions page.
  ///
  /// This widget was hard-wired to FillOutCubit for picking, removing AND
  /// rebuilding. On the Submissions page the form lives in that page's own
  /// state instead, and FillOutCubit is not loaded there: the pick wrote the
  /// file onto the controller but FillOutCubit skipped its emit (its state is
  /// not FillOutLoaded), so nothing redrew until an unrelated change (the
  /// dropdown) rebuilt the page; remove cleared the file the same silent way.
  ///
  /// Same fix as AttachmentDigitalSignatureResultWidget (12/10/2026): the
  /// host page passes these and rebuilds itself. Without them the widget falls
  /// back to FillOutCubit, which is what the Fill Out page provides.
  final Future<void> Function()? onSelectAttachment;
  final VoidCallback? onRemoveAttachment;
  final AttachmentFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isShownError, isReadOnly;

  @override
  Widget build(BuildContext context) {
    // No BlocBuilder of its own: whichever page hosts this field rebuilds it
    // (Fill Out through its BlocConsumer, Submissions through setState).
    return Align(
      alignment: _getAlignment(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: _getCrossAxis(context),
        children: [
          // Title BESIDE the button, same layout as the
          // eSignature field (title starts the row, button right after it).
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
              _getAttachmentWidget(context),
            ],
          ),

          // Error message
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

  Widget _getAttachmentWidget(BuildContext context) {
    // Check if attachment exists
    if (fieldController?.attachmentEntity != null) {
      // Use IntrinsicWidth to fit content naturally
      return IntrinsicWidth(
        child: AttachmentUploadedWidget(
          isReadOnly: isReadOnly,
          onCloseTap: () {
            if (isReadOnly) return;
            onRemoveAttachment?.call();
          },
          attachmentEntity: fieldController!.attachmentEntity!,
        ),
      );
    }

    return customButtonWithSvg(
      title: S.of(context).uploadAttachment,
      function: () async {
        if (isReadOnly) return;
        if (onSelectAttachment != null) {
          await onSelectAttachment!();
        }
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
