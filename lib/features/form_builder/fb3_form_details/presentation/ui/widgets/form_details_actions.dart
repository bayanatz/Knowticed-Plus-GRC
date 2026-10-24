/// Module: form_builder_module/f3_form_details
///
///*************************** FILE INFO ****************************///
/// File Name: form_details_actions.dart
/// Description: `FormDetailsActions` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 23/10/2026 - Edit / Delete / PDF go through this module
///                       (FormDetailsCubit), not HomeFormActions.
library;

import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/app_routes.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/form_builder/fb3_form_details/presentation/controller/form_details_cubit.dart';
import 'package:knowticed_plus/features/form_builder/helpers/app_dialogs.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form_builder/form_permissions.dart';

class FormDetailsActions extends StatelessWidget {
  const FormDetailsActions({super.key, required this.model});

  final FormEntity model;

  // Permission gates (form bug report #27): a role whose
  // Form Builder switches are OFF still saw every action. Each button is
  // gated in ONE place ([_can] / [_canSeeResults]) and the spacing is built
  // from the visible buttons only, so a hidden action never leaves a gap.
  // Both gates go through FormBuilderAccess, so the
  // section master toggles apply here too.
  bool _can(FormPermissions permission) => FormBuilderAccess.form(permission);

  /// Results is a hub for the Results switches; show it when ANY of its tabs
  /// is allowed.
  bool _canSeeResults() => FormBuilderAccess.canOpenResults;

  /// Joins [items] with [gap] between them (no leading/trailing gap).
  List<Widget> _spaced(List<Widget> items, double gap) {
    final out = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      if (i > 0) out.add(horizontalSpace(gap));
      out.add(items[i]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileIcons = !ContextExtension(context).isTablett;
    final bool canFill = _can(FormPermissions.fillOutForm);
    final bool canResults = _canSeeResults();
    final bool canPdf = _can(FormPermissions.convertToPdf);
    final bool canShare = _can(FormPermissions.share);
    final bool canEdit = _can(FormPermissions.editForm);
    final bool canDelete = _can(FormPermissions.deleteForm);

    final Widget? fill = canFill ? _buildFillOutButton(context) : null;
    final Widget? results = canResults ? _buildResultsButton(context) : null;
    final Widget? pdf = canPdf ? _buildConvertToPdfButton(context) : null;
    final List<Widget> manage = [
      if (canShare) _buildShareButton(isMobileIcons, context),
      if (canEdit) _buildEditButton(isMobileIcons, context),
      if (canDelete) _buildDeleteButton(isMobileIcons, context),
    ];

    if (ContextExtension(context).isPhone) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (fill != null || results != null)
            Row(
              children: [
                if (fill != null) fill,
                const Spacer(),
                if (results != null) results,
              ],
            ),
          if ((fill != null || results != null) &&
              (pdf != null || manage.isNotEmpty))
            verticalSpace(15),
          if (pdf != null || manage.isNotEmpty)
            Row(
              children: [
                if (pdf != null) pdf,
                const Spacer(),
                ..._spaced(manage, 10),
              ],
            ),
        ],
      );
    }

    final List<Widget> topRight = [
      if (results != null) results,
      if (pdf != null) pdf,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (fill != null || topRight.isNotEmpty)
          Row(
            children: [
              if (fill != null) fill,
              const Spacer(),
              ..._spaced(topRight, 15),
            ],
          ),
        if ((fill != null || topRight.isNotEmpty) && manage.isNotEmpty)
          verticalSpace(15),
        if (manage.isNotEmpty)
          Row(children: [const Spacer(), ..._spaced(manage, 10)]),
      ],
    );
  }

  Widget _buildFillOutButton(BuildContext context) {
    return customButtonWithSvg(
      title: S.of(context).fillOutForm,
      function: () {
        context.FormNavigateTo(
          Routes.submissionsScreen,
          arguments: (model: model, isFillMode: true),
        );
      },
      textStyle: StyleText.fontSize16Weight500.copyWith(
        color: AppColors.textButton,
      ),
      color: AppColors.primary,
      image: AppAssets.fillOut,
      widthImage: 20,
      heightImage: 20,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.black,
    );
  }

  Widget _buildResultsButton(BuildContext context) {
    return customButtonWithSvg(
      title: S.of(context).result,
      function: () {
        // FB-FILL-05: the Results page initializes its cubit itself.
        context.FormNavigateTo(Routes.resultScreen, arguments: model);
      },
      textStyle: StyleText.fontSize16Weight500.copyWith(
        color: AppColors.textButton,
      ),
      color: AppColors.primary,
      image: AppAssets.results,
      widthImage: 20,
      heightImage: 20,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.textButton,
    );
  }

  Widget _buildShareButton(bool isMobile, BuildContext context) {
    if (isMobile) {
      return customButtonWithSvg(
        title: '',
        // The share page selects the form itself.
        function: () =>
            context.FormNavigateTo(Routes.shareScreen, arguments: model),
        textStyle: StyleText.fontSize16Weight500,
        color: AppColors.primary,
        image: AppAssets.share,
        widthImage: 19,
        heightImage: 19,
        colorBorder: AppColors.transparent,
        svgColor: AppColors.textButton,
      );
    }

    return customButtonWithSvg(
      title: S.of(context).share,
      function: () =>
          context.FormNavigateTo(Routes.shareScreen, arguments: model),
      textStyle: StyleText.fontSize16Weight500.copyWith(
        color: AppColors.textButton,
      ),
      color: AppColors.primary,
      image: AppAssets.share,
      widthImage: 20,
      heightImage: 20,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.textButton,
    );
  }

  Widget _buildConvertToPdfButton(BuildContext context) {
    return customButtonWithSvg(
      title: S.of(context).convertToPdf,
      function: () {
        context.FormNavigateTo(Routes.convertPdf, arguments: model);
      },
      textStyle: StyleText.fontSize16Weight500.copyWith(
        color: AppColors.textButton,
      ),
      color: AppColors.primary,
      image: '',
      widthImage: 0,
      heightImage: 0,
      colorBorder: AppColors.transparent,
    );
  }

  Widget _buildEditButton(bool isMobile, BuildContext context) {
    if (isMobile) {
      return customButtonWithSvg(
        title: '',
        function: () {
          context.FormNavigateTo(Routes.create, arguments: model);
        },
        textStyle: StyleText.fontSize16Weight500,
        color: AppColors.primary,
        image: AppAssets.edit,
        widthImage: 19,
        heightImage: 19,
        colorBorder: AppColors.transparent,
        svgColor: AppColors.textButton,
      );
    }

    return customButtonWithSvg(
      title: S.of(context).edit,
      function: () {
        context.FormNavigateTo(Routes.create, arguments: model);
      },
      textStyle: StyleText.fontSize16Weight500.copyWith(
        color: AppColors.blackButton,
      ),
      color: AppColors.primary,
      image: AppAssets.edit,
      widthImage: 20,
      heightImage: 20,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.black,
    );
  }

  Widget _buildDeleteButton(bool isMobile, BuildContext context) {
    if (isMobile) {
      return customButtonWithSvg(
        title: '',
        function: () {
          _delete(context);
        },
        textStyle: StyleText.fontSize14Weight500,
        color: AppColors.red,
        image: AppAssets.delete,
        widthImage: 19,
        heightImage: 19,
        colorBorder: AppColors.transparent,
        svgColor: AppColors.white,
      );
    }

    return customButtonWithSvg(
      title: S.of(context).delete,
      function: () {
        _delete(context);
      },
      textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
      color: AppColors.red,
      image: AppAssets.delete,
      widthImage: 20,
      heightImage: 20,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.white,
    );
  }

  /// Confirm → delete (through [FormDetailsCubit]) → success.
  void _delete(BuildContext context) {
    if (!FormBuilderAccess.canDeleteForm) return;
    final FormDetailsCubit cubit = context.read<FormDetailsCubit>();
    AppDialogs.deleteForm(context, cubit.deleteForm);
  }
}
