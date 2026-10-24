/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: card_preview_actions.dart
/// Description: `CardPreviewActions` widget, the actions under the tablet
///              preview.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/ui/widgets/home_form_actions.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/pages/preview_screen.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/form_editor_actions.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Preview / Publish / Save For Later / Save / Restore under the tablet
/// preview. The logic is shared with the phone editor (FormEditorActions).
class CardPreviewActions extends StatelessWidget {
  const CardPreviewActions({
    super.key,
    required this.formModel,
    required this.dataState,
    required this.headState,
  });

  final FormEntity? formModel;
  final CreateFormDataLoaded dataState;
  final CreateFormHeadLoaded headState;

  @override
  Widget build(BuildContext context) {
    // Each button
    // used to size itself from its own label, so "Save For Later" came out
    // wider than "Preview" above it and their edges did not line up. Every
    // button in this block now shares the width of the longest label (never
    // narrower than the standard 135), in whichever language is active.
    final double sharedWidth = _sharedButtonWidth(context, [
      S.of(context).preview,
      S.of(context).publish,
      S.of(context).saveForLater,
      S.of(context).discardChange,
      S.of(context).save,
    ]);

    // This Restore button was gated by the CONVERT TO PDF
    // switch. It is Restore Form's, and a role without it gets no actions on a
    // deleted form at all (it falls to the published-form actions otherwise).
    if (formModel != null && formModel!.status == FormStatus.deleted) {
      return _buildRestoreAction(context);
    }
    if (formModel == null || formModel!.status == FormStatus.drafts) {
      return _buildNewFormActions(context, sharedWidth);
    }
    return _buildEditActions(context, sharedWidth);
  }

  /// Restore, for a deleted form.
  Widget _buildRestoreAction(BuildContext context) {
    if (!FormBuilderAccess.canRestoreForm) return const SizedBox.shrink();
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: customButtonWithSvg(
        title: S.of(context).restore,
        function: () => HomeFormActions.restore(context, formModel!),
        textStyle: StyleText.fontSize16Weight500.copyWith(
          color: AppColors.blackButton,
        ),
        color: AppColors.primary,
        image: '',
        widthImage: 0,
        heightImage: 0,
        colorBorder: AppColors.transparent,
      ),
    );
  }

  /// Preview / Publish / Save For Later, for a new form or a draft.
  Widget _buildNewFormActions(BuildContext context, double sharedWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            customButtonWithSvg(
              title: S.of(context).preview,
              fixedWidth: sharedWidth,
              function: () => _openPreview(context),
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.textButton,
              ),
              color: AppColors.primary,
              image: '',
              widthImage: 0,
              heightImage: 0,
              colorBorder: AppColors.transparent,
            ),
            customButtonWithSvg(
              title: S.of(context).publish,
              fixedWidth: sharedWidth,
              function: () => FormEditorActions.publish(context),
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.textButton,
              ),
              color: AppColors.primary,
              image: '',
              widthImage: 0,
              heightImage: 0,
              colorBorder: AppColors.transparent,
            ),
          ],
        ),
        // 10.sp under Preview — the same gap as Back / Save For Later on
        // the Preview page (large-screen bug report p.6).
        SizedBox(height: 10.sp),
        customButtonWithSvg(
          title: S.of(context).saveForLater,
          fixedWidth: sharedWidth,

          function: () => FormEditorActions.saveForLater(context),
          // Bug report p.31/p.34: secondary actions are darkGrey + white
          // text — the same pair as Back and the dialogs' Discard.
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.text,
          ),
          color: AppColors.darkGrey,
          image: '',
          widthImage: 0,
          heightImage: 0,
          colorBorder: AppColors.transparent,
        ),
      ],
    );
  }

  /// Preview / Discard / Save, for a published form being edited.
  Widget _buildEditActions(BuildContext context, double sharedWidth) {
    return Row(
      textDirection: TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          spacing: 10.sp,
          children: [
            customButtonWithSvg(
              title: S.of(context).preview,
              fixedWidth: sharedWidth,
              function: () => _openPreview(context),
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.blackButton,
              ),
              color: AppColors.primary,
              image: '',
              widthImage: 0,
              heightImage: 0,
              colorBorder: AppColors.transparent,
            ),
            customButtonWithSvg(
              title: S.of(context).discardChange,
              fixedWidth: sharedWidth,
              function: () => context.pop(),
              // Bug report p.4/p.35: darkGrey + white text, like Back.
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.text,
              ),
              color: AppColors.darkGrey,
              image: '',
              widthImage: 0,
              heightImage: 0,
              colorBorder: AppColors.transparent,
            ),
          ],
        ),
        customButtonWithSvg(
          title: S.of(context).save,
          fixedWidth: sharedWidth,
          function: () =>
              FormEditorActions.publish(context, editing: formModel),
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.blackButton,
          ),
          color: AppColors.primary,
          image: '',
          widthImage: 0,
          heightImage: 0,
          colorBorder: AppColors.transparent,
        ),
      ],
    );
  }

  /// Width that fits the widest of [titles] at the action-button text style,
  /// plus the standard horizontal padding; never below the default 135.
  double _sharedButtonWidth(BuildContext context, List<String> titles) {
    double widest = 0;
    for (final String title in titles) {
      final TextPainter painter = TextPainter(
        text: TextSpan(text: title, style: StyleText.fontSize16Weight500),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      if (painter.width > widest) widest = painter.width;
    }
    final double needed = widest + 2 * 12.sp + 2;
    return needed > 135.sp ? needed : 135.sp;
  }

  /// Opens the Preview screen with every page expanded.
  void _openPreview(BuildContext context) {
    context.read<CreateFormDataCubit>().expandAllPages();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return const PreviewScreen();
        },
      ),
    );
  }
}
