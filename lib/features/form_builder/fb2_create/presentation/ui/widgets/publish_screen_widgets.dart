/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: publish_screen_widgets.dart
/// Description: `PublishSummaryRow` widget, `PublishCardsRow` widget, `PublishEditPermissionRow` widget and 3 more.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';


import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/access_management.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/orientation.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/features/form_builder/helpers/edit_permission_info_hint.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';

import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/ui/widgets/home_publish_actions.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';

class PublishSummaryRow extends StatelessWidget {
  const PublishSummaryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: AppColors.card,
          radius: 15,
          child: CustomSvgImage.natural(assetPath: AppAssets.summary),
        ),
        horizontalSpace(8),
        Text(S.of(context).summary, style: StyleText.fontSize14Weight500),
      ],
    );
  }
}

class PublishCardsRow extends StatelessWidget {
  const PublishCardsRow({
    super.key,
    required this.model,
    required this.accessManagement,
  });

  final FormEntity model;
  final String accessManagement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 70.h,
          width: 160.w,
          padding: EdgeInsets.only(top: 14.h, bottom: 13.h),
          decoration: ShapeDecoration(
            color: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Center(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${S.of(context).orientation}\n',
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.secondaryBlack,
                    ),
                  ),
                  TextSpan(
                    // stored value -> localized label; see OrientationExtension
                    text: OrientationExtension.labelFor(
                      model.formHeadModel.orientation,
                    ),
                    style: StyleText.fontSize16Weight500,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const Spacer(),
        Container(
          height: 70.h,
          width: 160.w,
          padding: EdgeInsets.only(top: 14.h, bottom: 13.h),
          decoration: ShapeDecoration(
            color: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Center(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${S.of(context).accessManagement}\n',
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.secondaryBlack,
                    ),
                  ),
                  TextSpan(
                    text: AccessManagementExtension.labelFor(accessManagement),
                    style: StyleText.fontSize16Weight500,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class PublishEditPermissionRow extends StatelessWidget {
  const PublishEditPermissionRow({super.key});

  @override
  Widget build(BuildContext context) {
    // Hidden for roles without Form Permissions → Edit
    // Permission. The switch also did nothing (`onChanged: (value) {}`), so
    // a mobile publish could never grant editing; it now writes the same
    // CreateFormDataCubit.isEdit the tablet summary dialog writes.
    if (!FormBuilderAccess.canGrantEditPermission) {
      return const SizedBox.shrink();
    }
    final CreateFormDataCubit dataCubit = context.read<CreateFormDataCubit>();
    final dataState = dataCubit.state;
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              EditPermissionInfoHint(),
              horizontalSpace(10),
              Text(
                S.of(context).editPermission,
                style: StyleText.fontSize14Weight400,
              ),
              const Spacer(),
              AdvancedSwitch(
                onChanged: (value) => dataCubit.updateIsEdit(value),
                initialValue: dataState is CreateFormDataLoaded
                    ? dataState.isEdit
                    : false,
                activeColor: AppColors.primary,
                width: 30.w,
                height: 18.h,
              ),
            ],
          ),
        ),
        horizontalSpace(15),
        const Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}

class PublishDateRow extends StatefulWidget {
  const PublishDateRow({super.key});

  @override
  State<PublishDateRow> createState() => _PublishDateRowState();
}

class _PublishDateRowState extends State<PublishDateRow> {
  DateTime? _accessBegins;
  DateTime? _accessEnds;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).accessBegins,
              style: StyleText.fontSize14Weight400,
            ),
            verticalSpace(8),
            CustomDateField(
              fillColor: AppColors.card,
              value: _accessBegins,
              hint: S.of(context).chooseTheDate,
              onChanged: (value) => setState(() => _accessBegins = value),
            ),
          ],
        ),
        verticalSpace(15),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).accessEnds,
              style: StyleText.fontSize14Weight400,
            ),
            verticalSpace(8),
            CustomDateField(
              fillColor: AppColors.card,
              value: _accessEnds,
              hint: S.of(context).chooseTheDate,
              onChanged: (value) => setState(() => _accessEnds = value),
            ),
          ],
        ),
      ],
    );
  }
}

class PublishActionRow extends StatelessWidget {
  const PublishActionRow({super.key, required this.model});

  final FormEntity model;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        customButtonWithSvg(
          title: S.of(context).back,
          function: () {
            Navigator.pop(context);
          },
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.text,
          ),
          color: AppColors.darkGrey,
          image: '',
          widthImage: 0,
          heightImage: 0,
          colorBorder: AppColors.transparent,
        ),
        const Spacer(),
        customButtonWithSvg(
          title: S.of(context).send,
          // FB-HOME-04: this used to call createForm and addFormPrivacyAccess without
          // waiting, ignore both results, show success anyway, and build the
          // access list from the Restricted model even for Open Access forms
          // (so an Open Access form published from a phone reached nobody).
          // It now runs the same publish flow as the tablet, which reads the
          // departments / people picked on this screen from the cubit, waits
          // for both saves and reports a failure.
          function: () {
            HomePublishActions.publishNewForm(
              model: model,
              context: context,
              createFormDataCubit: context.read<CreateFormDataCubit>(),
              skipDialog: true,
            );
          },
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
    );
  }
}
