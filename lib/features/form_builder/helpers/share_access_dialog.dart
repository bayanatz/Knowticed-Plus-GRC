/// Module: core/helper/form_builder
///
/// FILE INFO
/// File Name   : share_access_dialog.dart
/// Description: `ShareAccessDialog`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Objective   : Share-access summary dialog (person selection + edit
///               permission + access window). Extracted from app_dialogs.dart.
///               Contains NO try/catch — error handling belongs in the
///               ShareCubit, the widget only renders state (§11.2, §19).
library;

import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_check_box.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/share_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/share_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/helper/get_dialog_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/helpers/edit_permission_info_hint.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:knowticed_plus/core/custom/dialogs/default_dialog.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

/// Dialog that lets the publisher review recipients and access settings
/// before sharing a form.
class ShareAccessDialog {
  ShareAccessDialog._();

  static void show(
    BuildContext context,
    dynamic Function() onPublishClicked, {
    ShareCubit? shareCubit,
  }) {
    final effectiveShareCubit = shareCubit ?? context.read<ShareCubit>();
    final bool isTablet = !kpIsPhoneLayout(context);
    // Bug report (share, p.1): validation used to run in ShareCubit.grantAccess
    // AFTER this dialog had already closed, and it reported through
    // Get.snackbar — the "Error / Please select access begin date" toast that
    // landed on top of the logo. The dialog now validates itself and shows the
    // message under the field, the same way SummaryOpenAccessDialog does.
    bool showValidationErrors = false;

    GetDialogHelper.generalDialog(
      context: context,
      child: BlocProvider<ShareCubit>.value(
        value: effectiveShareCubit,
        child: DefaultDialog(
          width: !ContextExtension(context).isPhone ? 615.w : 320.w,
          height: !ContextExtension(context).isPhone ? 685.h : 500.h,
          customWidget: Padding(
            padding: const EdgeInsets.all(15),
            child: StatefulBuilder(
              builder: (context, setState) =>
                  BlocBuilder<ShareCubit, ShareState>(
                builder: (context, state) {
                  if (state is! ShareLoaded) {
                    return const SizedBox.shrink();
                  }

                  final cubit = context.read<ShareCubit>();
                  final bool hasTimeBegin = state.timeBegin != null;
                  final bool hasTimeEnd = state.timeEnd != null;
                  final bool hasPersons = state.newSelectedPersons.isNotEmpty;
                  final bool isValid = hasTimeBegin && hasTimeEnd && hasPersons;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 22/10/2026 — Owner: one dialog header everywhere
                          // (30 circle · 16 icon · 18/500 title) — was a 30
                          // CircleAvatar with an untinted icon, title 16/500.
                          Expanded(
                            child: CustomDialogHeader(
                                title: S.current.summary,
                                icon: AppAssets.summary),
                          ),
                          // Only roles allowed to grant it (Form Permissions →
                          // Edit Permission) see the switch. .
                          if (FormBuilderAccess.canGrantEditPermission) ...[
                            Text(
                              S.current.editPermission,
                              style: StyleText.fontSize14Weight500,
                            ),
                            horizontalSpace(10),
                            const EditPermissionInfoHint(),
                            horizontalSpace(20),
                            AdvancedSwitch(
                              onChanged: (value) {
                                cubit.updateEditPermission(value);
                              },
                              initialValue: state.isEditPermission,
                              activeColor: AppColors.primary,
                              width: 30,
                              height: 18,
                            ),
                          ],
                        ],
                      ),
                      verticalSpace(15),

                      // Date Pickers Row — top-aligned so an error line under
                      // one field does not push the other one out of line.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomDateField(
                                  label: S.current.accessBegins,
                                  fillColor: AppColors.background,
                                  value: state.timeBegin,
                                  hint: S.current.chooseTheDate,
                                  errorText:
                                      showValidationErrors && !hasTimeBegin
                                          ? S.current.pleaseSelectStartDate
                                          : null,
                                  onChanged: (value) {
                                    if (value != null) {
                                      cubit.updateTimeBegin(value);
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                          horizontalSpace(15),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomDateField(
                                  label: S.current.accessEnds,
                                  fillColor: AppColors.background,
                                  value: state.timeEnd,
                                  hint: S.current.chooseTheDate,
                                  errorText: showValidationErrors && !hasTimeEnd
                                      ? S.current.pleaseSelectEndDate
                                      : null,
                                  onChanged: (value) {
                                    if (value != null) {
                                      cubit.updateTimeEnd(value);
                                    }
                                  },
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      verticalSpace(20),

                      // Search Field
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppSearchTextField(
                            fillColor: AppColors.background,
                            controller: TextEditingController(),
                            onChanged: (value) {
                              cubit.newSelectedSearch(value);
                            },
                          )
                        ],
                      ),
                      if (showValidationErrors && !hasPersons) ...[
                        verticalSpace(6),
                        Text(
                          S.current.fbPleaseSelectAtLeastOnePerson,
                          style: StyleText.fontSize12Weight400
                              .copyWith(color: AppColors.red),
                        ),
                      ],
                      verticalSpace(15),

                      // Person List
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final persons = state.filteredNewSelectedPersons;

                            if (persons.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    S.current.fbNoPersonsFound,
                                    style: StyleText.fontSize16Weight500,
                                  ),
                                ),
                              );
                            }

                            return SingleChildScrollView(
                              key: const ValueKey('person_scroll_view'),
                              child: Column(
                                children: isTablet
                                    ? _buildTabletPersonList(context, persons)
                                    : _buildPhonePersonList(context, persons),
                              ),
                            );
                          },
                        ),
                      ),
                      verticalSpace(25),

                      // Action Buttons
                      Row(
                        textDirection: TextDirection
                            .ltr, // X-73: Cancel left, action right in both languages

                        children: [
                          customButton(
                            width: 150,
                            height: 38,
                            title: S.current.discard,
                            function: () {
                              Get.back();
                            },
                            // Bug report #29: darkGrey with white text.
                            color: AppColors.darkGrey,
                            textStyle: StyleText.fontSize16Weight500
                                .copyWith(color: AppColors.text),
                          ),
                          const Spacer(),
                          customButton(
                            width: 150,
                            height: 38,
                            textStyle: StyleText.fontSize16Weight500
                                .copyWith(color: AppColors.textButton),
                            title: S.current.send,
                            function: () {
                              if (!isValid) {
                                setState(() => showValidationErrors = true);
                                return;
                              }
                              Get.back();
                              onPublishClicked.call();
                            },
                          )
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          autoClose: false,
        ),
      ),
    );
  }

  static List<Widget> _buildTabletPersonList(
      BuildContext context, List<PersonEntity> persons) {
    final rowCount = (persons.length + 1) ~/ 2;

    return List.generate(rowCount, (index) {
      final leftIndex = index * 2;
      final rightIndex = leftIndex + 1;

      return Container(
        key: ValueKey('tablet_row_$index'),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            _personView(context, persons[leftIndex]),
            horizontalSpace(10),
            if (rightIndex < persons.length)
              _personView(context, persons[rightIndex])
            else
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
      );
    });
  }

  static List<Widget> _buildPhonePersonList(
      BuildContext context, List<PersonEntity> persons) {
    return List.generate(persons.length, (index) {
      return Container(
        key: ValueKey('phone_person_${persons[index].id}_$index'),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        child: _personView(context, persons[index]),
      );
    });
  }

  static Widget _personView(BuildContext context, PersonEntity person) {
    final cubit = context.read<ShareCubit>();
    final state = cubit.state;

    if (state is! ShareLoaded) {
      return const SizedBox.shrink();
    }

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => HapticController.low(),
        onTap: () {
          final index = state.filteredPersons.indexOf(person);
          if (index != -1) {
            cubit.togglePersonSelection(index, false);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.all(Radius.circular(6.r)),
          ),
          padding: EdgeInsetsDirectional.only(
            start: 13.sp,
            end: 7.sp,
            top: 10.sp,
            bottom: 10.sp,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // (vertical bug report p.34 — "avatar too
                    // small and use our custom avatar"): was a 30-wide
                    // CircleAvatar whose primary-yellow fill showed round a
                    // clipped glyph. Now the app's avatar recipe (the same one
                    // the Pending cards use): the person SVG clipped to a
                    // circle, 44 across, no background ring.
                    ClipOval(
                      child: CustomSvgImage(
                        assetPath:
                            "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
                        width: 44.r,
                        height: 44.r,
                        fit: BoxFit.cover,
                      ),
                    ),
                    horizontalSpace(10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FormatHelper.capitalize(person.name),
                            style: StyleText.fontSize14Weight500,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            FormatHelper.capitalize(person.departmentName),
                            overflow: TextOverflow.ellipsis,
                            style: StyleText.fontSize14Weight500
                                .copyWith(color: AppColors.secondaryBlack),
                          ),
                          Text(
                            FormatHelper.capitalize(person.title),
                            overflow: TextOverflow.ellipsis,
                            style: StyleText.fontSize14Weight500
                                .copyWith(color: AppColors.secondaryBlack),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              CustomCheckBox(isSelected: person.isSelected),
            ],
          ),
        ),
      ),
    );
  }
}
