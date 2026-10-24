/// Module: core/helper/form_builder
///
/// FILE INFO
/// File Name   : summary_restricted_access_dialog.dart
/// Description: `SummaryRestrictedAccessDialog`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Objective   : Restricted-access publish summary dialog (per-person grant).
///               Extracted from app_dialogs.dart.
library;

import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/orientation.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/department_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/core/helper/get_dialog_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_app_dropdown.dart';
import 'package:knowticed_plus/features/form_builder/helpers/person_state_view.dart';
import 'package:knowticed_plus/core/custom/dialogs/default_dialog.dart';
import 'package:knowticed_plus/features/form_builder/helpers/dialog_shared_widgets.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';

/// Publish-summary dialog used when the form is shared with restricted access.
class SummaryRestrictedAccessDialog {
  SummaryRestrictedAccessDialog._();

  static void show(
    BuildContext context,
    dynamic Function() onPublishClicked, {
    CreateFormHeadCubit? headCubit,
    CreateFormDataCubit? dataCubit,
  }) {
    TextEditingController searchController = TextEditingController();

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
          customWidget: Padding(
            padding: const EdgeInsets.all(15),
            child: BlocBuilder<CreateFormHeadCubit, CreateFormHeadState>(
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

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 15 row.
                        CustomDialogHeader(
                          title: S.current.summary,
                          icon: AppAssets.summary,
                        ),
                        verticalSpace(15),

                        // Summary boxes
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DialogSharedWidgets.buildSummaryBox(
                              S.current.accessManagement,
                              S.current.restrictedAccess,
                            ),
                            const Spacer(),
                            DialogSharedWidgets.buildSummaryBox(
                              S.current.orientation,
                              OrientationExtension.labelFor(
                                headState.orientation ?? 'Portrait',
                              ),
                            ),
                            const Spacer(),
                            DialogSharedWidgets.buildSummaryBox(
                              S.current.fbTotalPages,
                              FormDateTimeHelper.formatInt(
                                dataState.pages.length,
                              ),
                            ),
                          ],
                        ),
                        verticalSpace(20),

                        // Time fields
                        DialogSharedWidgets.buildTimeFields(context, dataCubit),
                        verticalSpace(20),

                        // Edit permission
                        DialogSharedWidgets.buildEditPermissionSwitch(
                          context,
                          dataCubit,
                        ),
                        verticalSpace(20),

                        // Search and department filter
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppSearchTextField(
                              fillColor: AppColors.background,
                              controller: searchController,
                              onChanged: (value) {
                                dataCubit.search(value);
                              },
                            ),
                            horizontalSpace(15),
                            // Bug p.32: 37.h here vs the search field's
                            // 38.sp — two different scales, so the boxes never
                            // matched. Same unit and value as AppSearchTextField.
                            SizedBox(
                              width: 155.w,
                              height: 38.sp,
                              child: AppDropdown(
                                borderRadius: 8
                                    .r, // form bug report #8/#35: 8.r dropdowns
                                fillColor: AppColors.background,
                                value: dataState.currentPersonDepartment,
                                width: double.infinity,
                                textButton:
                                    dataState.currentPersonDepartment == null
                                    ? S.current.chooseHere
                                    : addDepartmentController.getDepartmentName(
                                        dataState.currentPersonDepartment!,
                                        null,
                                      ),
                                items: addDepartmentController.departmentModels
                                    .map(
                                      (element) => DepartmentEntity(
                                        name: addDepartmentController
                                            .containAbbreviation(
                                              element.departmentName!
                                                  .toLowerCase(),
                                            ),
                                        nameAr: element.departmentNameInArabic!,
                                        id: element.departmentID!,
                                      ),
                                    )
                                    .toList()
                                    .toDropdownMenuItemList(),
                                onChanged: (value) {
                                  dataCubit.selectPresonDepartment(value);
                                },
                              ),
                            ),
                          ],
                        ),
                        verticalSpace(15),
                        verticalSpace(15),

                        // Employee grid
                        SizedBox(
                          height: 155.h,
                          child: Builder(
                            builder: (context) {
                              if (dataState.shownPersonList.isEmpty) {
                                return Center(
                                  child: Text(
                                    S.current.noEmployeesFound,
                                    style: StyleText.fontSize16Weight500,
                                  ),
                                );
                              }

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          ContextExtension(context).isPhone
                                          ? 1
                                          : 2,
                                      mainAxisExtent: 72.sp,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                    ),
                                itemCount: dataState.shownPersonList.length,
                                itemBuilder: (_, index) {
                                  return FormPersonStateView(
                                    color: AppColors.background,
                                    person: dataState.shownPersonList[index],
                                    onTap: () => dataCubit.selectPerson(
                                      dataState.shownPersonList[index],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 15.h),

                        // Action buttons
                        DialogSharedWidgets.buildActionButtons(
                          context,
                          onPublishClicked,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          autoClose: false,
        ),
      ),
    );
  }
}
