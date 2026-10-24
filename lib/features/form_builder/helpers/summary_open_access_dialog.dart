/// Module: core/helper/form_builder
///
/// FILE INFO
/// File Name   : summary_open_access_dialog.dart
/// Description: `SummaryOpenAccessDialog`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Objective   : Open-access publish summary dialog. Extracted from
///               app_dialogs.dart; renders CreateForm head/data cubit state.
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/orientation.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/core/helper/get_dialog_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/helpers/edit_permission_info_hint.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:knowticed_plus/core/custom/dialogs/default_dialog.dart';
import 'package:knowticed_plus/features/form_builder/helpers/dialog_shared_widgets.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

/// Publish-summary dialog used when the form is shared with open access.
class SummaryOpenAccessDialog {
  SummaryOpenAccessDialog._();

  static void show(
    BuildContext context,
    dynamic Function() onPublishClicked, {
    CreateFormHeadCubit? headCubit,
    CreateFormDataCubit? dataCubit,
  }) {
    bool showValidationErrors = false;

    final effectiveHeadCubit = headCubit ?? context.read<CreateFormHeadCubit>();
    final effectiveDataCubit = dataCubit ?? context.read<CreateFormDataCubit>();

    final MainCoreDepartmentCubit addDepartmentController =
        Get.find<MainCoreDepartmentCubit>();

    GetDialogHelper.generalDialog(
      context: context,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<CreateFormHeadCubit>.value(value: effectiveHeadCubit),
          BlocProvider<CreateFormDataCubit>.value(value: effectiveDataCubit),
        ],
        child: DefaultDialog(
          width: 600.w,
          customWidget: StatefulBuilder(
            builder: (context, setState) {
              return BlocBuilder<CreateFormHeadCubit, CreateFormHeadState>(
                builder: (context, headState) {
                  if (headState is! CreateFormHeadLoaded) {
                    return const Center(child: CircleProgressMaster());
                  }

                  return BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
                    builder: (context, dataState) {
                      if (dataState is! CreateFormDataLoaded) {
                        return const Center(child: CircleProgressMaster());
                      }

                      final dataCubit = context.read<CreateFormDataCubit>();

                      final hasDepartments =
                          dataState.departmentsShown.isNotEmpty;
                      final hasTimeBegin = dataState.timeBegin != null;
                      final hasTimeEnd = dataState.timeEnd != null;
                      final isValid =
                          hasDepartments && hasTimeBegin && hasTimeEnd;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 15 row.
                          CustomDialogHeader(
                              title: S.current.summary,
                              icon: AppAssets.summary),
                          verticalSpace(15),

                          // Summary boxes
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DialogSharedWidgets.buildSummaryBox(
                                S.current.accessManagement,
                                S.current.openAccess,
                              ),
                              const Spacer(),
                              DialogSharedWidgets.buildSummaryBox(
                                S.current.orientation,
                                OrientationExtension.labelFor(
                                    headState.orientation ?? 'Portrait'),
                              ),
                              const Spacer(),
                              DialogSharedWidgets.buildSummaryBox(
                                S.current.fbTotalPages,
                                FormDateTimeHelper.formatInt(
                                    dataState.pages.length),
                              ),
                            ],
                          ),
                          verticalSpace(15),

                          // Department dropdown and selected departments
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: DropDownWidget(
                                      fillColor: AppColors.background,
                                      title: S.current.department,
                                      hint: S.current.department,
                                      items: addDepartmentController
                                          .departmentModels
                                          .map((element) {
                                        final isArabic =
                                            Get.locale?.languageCode == 'ar';
                                        final displayName = isArabic
                                            ? element.departmentNameInArabic ??
                                                element.departmentName!
                                            : addDepartmentController
                                                .containAbbreviation(
                                                element.departmentName!
                                                    .toLowerCase(),
                                              );

                                        return DropdownMenuItem<String>(
                                          value: element.departmentID!,
                                          child: Text(
                                            displayName,
                                            style:
                                                StyleText.fontSize14Weight400,
                                          ),
                                        );
                                      }).toList(),
                                      currentValue: null,
                                      onChanged: (value) {
                                        dataCubit.onDropDownOpenAccess(value);
                                      },
                                    ),
                                  ),
                                  horizontalSpace(15),
                                  Expanded(child: Container())
                                ],
                              ),
                              verticalSpace(4),
                              if (showValidationErrors && !hasDepartments) ...[
                                Text(
                                  S.current.pleaseSelectAtLeastOneDepartment,
                                  style: StyleText.fontSize12Weight400
                                      .copyWith(color: AppColors.red),
                                ),
                                verticalSpace(8),
                              ],
                              Wrap(
                                spacing: 8,
                                runSpacing: 10,
                                children: List.generate(
                                  dataState.departmentsShown.length,
                                  (index) {
                                    final isArabic =
                                        Get.locale?.languageCode == 'ar';
                                    final department =
                                        dataState.departmentsShown[index];
                                    final displayName = isArabic
                                        ? department.nameAr
                                        : department.name;

                                    return Container(
                                      height: 28.h,
                                      decoration: ShapeDecoration(
                                        color: AppColors.background,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Text(
                                                FormatHelper.capitalize(
                                                    displayName),
                                                style: StyleText
                                                    .fontSize14Weight600,
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                AlignmentDirectional.topEnd,
                                            child: InkWell(
                                              onTapDown: (_) =>
                                                  HapticController.high(),
                                              onTap: () {
                                                dataCubit
                                                    .onCancelDepartmentOpenAccess(
                                                        index);
                                              },
                                              child: Padding(
                                                padding:
                                                    EdgeInsetsDirectional.only(
                                                  top: 8.h,
                                                  end: 5.w,
                                                ),
                                                child: CustomSvgImage.natural(
                                                  assetPath: AppAssets.cancel,
                                                  height: 12.h,
                                                  width: 12.w,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          verticalSpace(18),

                          // Time fields — top-aligned (bug p.39): with an
                          // error line under only one field the default
                          // center alignment pushed the two out of line.
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // LABEL VIA `label:`, NOT A HAND-ROLLED
                                    // `Text` ABOVE THE FIELD (19/8/2026).
                                    //
                                    // "Department" is drawn by CustomDropdown's
                                    // own label slot — StyleText.fontSize14-
                                    // Weight500 at 14.sp, then a 6.sp gap. The
                                    // two date titles were a plain `Text` in
                                    // StyleText.fontSize14Weight600 followed by
                                    // verticalSpace(8), so they sat at a
                                    // different weight and a different distance
                                    // from their box than the dropdown above.
                                    // CustomDateField.label renders the
                                    // identical label + 6.sp spacer, so handing
                                    // it the string keeps all three titles in
                                    // step by construction — no style constant
                                    // to keep in sync here.
                                    CustomDateField(
                                      label: S.current.accessBegins,
                                      fillColor: AppColors.background,
                                      value: dataState.timeBegin,
                                      hint: S.current.chooseTheDate,
                                      errorText:
                                          showValidationErrors && !hasTimeBegin
                                              ? S.current.pleaseSelectStartDate
                                              : null,
                                      onChanged: (value) {
                                        if (value != null) {
                                          dataCubit.updateTimeBegin(value);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              horizontalSpace(15),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // See the note on 'Access Begins' above.
                                    CustomDateField(
                                      label: S.current.accessEnds,
                                      fillColor: AppColors.background,
                                      value: dataState.timeEnd,
                                      hint: S.current.chooseTheDate,
                                      errorText:
                                          showValidationErrors && !hasTimeEnd
                                              ? S.current.pleaseSelectEndDate
                                              : null,
                                      onChanged: (value) {
                                        if (value != null) {
                                          dataCubit.updateTimeEnd(value);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          verticalSpace(25),

                          // Edit permission switch — only for roles allowed
                          // to grant it (Form Permissions → Edit Permission).
                          if (FormBuilderAccess.canGrantEditPermission)
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const EditPermissionInfoHint(),
                                      horizontalSpace(10),
                                      Text(
                                        S.current.editPermission,
                                        style: StyleText.fontSize14Weight600,
                                      ),
                                      const Spacer(),
                                      AdvancedSwitch(
                                        onChanged: (value) {
                                          dataCubit.updateIsEdit(value);
                                        },
                                        initialValue: dataState.isEdit,
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
                            ),
                          verticalSpace(25),

                          // Action buttons
                          Row(
                            textDirection: TextDirection
                                .ltr, // X-73: Cancel left, action right in both languages

                            children: [
                              customButton(
                                title: S.current.discard,
                                function: () {
                                  Navigator.pop(context);
                                },
                                width: 150,
                                height: 38,
                                // Bug report #8/#29: same type style as
                                // Publish; Discard darkGrey + white text.
                                textStyle: StyleText.fontSize16Weight500
                                    .copyWith(color: AppColors.text),
                                color: AppColors.darkGrey,
                              ),
                              const Spacer(),
                              customButton(
                                title: S.current.grantAccess,
                                function: () {
                                  if (isValid) {
                                    Navigator.pop(context);
                                    onPublishClicked();
                                  } else {
                                    setState(() {
                                      showValidationErrors = true;
                                    });
                                  }
                                },
                                width: 150,
                                height: 38,
                                textStyle: StyleText.fontSize16Weight500
                                    .copyWith(color: AppColors.textButton),
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          verticalSpace(5),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
          autoClose: false,
        ),
      ),
    );
  }
}
