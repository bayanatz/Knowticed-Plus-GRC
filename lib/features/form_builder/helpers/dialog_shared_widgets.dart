/// Module: core/helper/form_builder
///
/// FILE INFO
/// File Name   : dialog_shared_widgets.dart
/// Description: `DialogSharedWidgets`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Objective   : Shared presentational pieces reused by the summary/share
///               dialogs (summary box, time fields, edit-permission switch,
///               action buttons). Extracted from the former 1,951-LOC
///               app_dialogs.dart so each dialog file stays small (§7).
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/helpers/edit_permission_info_hint.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';

/// Stateless helper widgets shared across the form-builder summary dialogs.
class DialogSharedWidgets {
  DialogSharedWidgets._();

  /// Small labelled value box used in the summary header row.
  static Widget buildSummaryBox(String label, String value, {Color? color}) {
    return Container(
      // The box was a fixed
      // 70.h tall with 0 top padding and a 2.0 line height on the label, so
      // the label was pushed up against the top edge and cut off. The box now
      // has the SAME 16.sp inset on all four sides (top/bottom = left/right)
      // and grows with its text, never shorter than the old 70.h.
      constraints: BoxConstraints(minWidth: 150.w, minHeight: 70.h),
      padding: EdgeInsets.all(16.sp),
      decoration: ShapeDecoration(
        color: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label\n',
                // The title is AppColors.text (was the
                // grey AppColors.secondaryText).
                style: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.text,
                  height: 1.6,
                ),
              ),
              TextSpan(
                text: value,
                // (vertical bug report p.11 — "not same
                // color as titles"): the value was grey under a dark label.
                // It now uses the label's colour unless a caller asks
                // otherwise.
                style: StyleText.fontSize16Weight500.copyWith(
                  color: color ?? AppColors.secondaryBlack,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Access-begins / access-ends date pickers wired to [cubit].
  static Widget buildTimeFields(
    BuildContext context,
    CreateFormDataCubit cubit,
  ) {
    return BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
      builder: (context, state) {
        if (state is! CreateFormDataLoaded) {
          return const SizedBox.shrink();
        }

        return Row(
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
        );
      },
    );
  }

  /// Edit-permission label + info hint + toggle.
  static Widget buildEditPermissionSwitch(
    BuildContext context,
    CreateFormDataCubit cubit,
  ) {
    return Row(
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
                onChanged: (value) {},
                initialValue: false,
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

  /// Discard / grant-access buttons row.
  static Widget buildActionButtons(
    BuildContext context,
    dynamic Function() onPublishClicked,
  ) {
    return Row(
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
          // Bug report #8/#29: Publish's type style; Discard is darkGrey
          // with white text.
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.text,
          ),
          color: AppColors.darkGrey,
        ),
        const Spacer(),
        customButton(
          title: S.current.grantAccess,
          function: () {
            Navigator.pop(context);
            onPublishClicked.call();
          },
          width: 150,
          height: 38,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
          color: AppColors.primary,
        ),
      ],
    );
  }
}
