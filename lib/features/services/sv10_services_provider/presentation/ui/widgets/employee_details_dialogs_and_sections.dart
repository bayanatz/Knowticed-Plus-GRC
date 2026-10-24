/// Module: services / sv10_services_provider / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: employee_details_dialogs_and_sections.dart
/// Purpose: The dialogs and sections of the provider's request page: the
///          change-status confirmation and success dialogs, the requester
///          details and the approval cycle. Presentational only — everything
///          they need is passed in.
/// Author: Knowticed Team
/// Created At: 02/07/2026
/// Revision History:
///   - 18/10/2026: SVC-PROV-21 — the success text matches the new status.
///   - 22/10/2026 (Amr Mesbah): standard header; shared widgets come from
///     presentation/widgets (Provider rule 3).
library;

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/approvals.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/responsive_text.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

/// Confirmation dialog shown before committing a status change. Returns
/// true if the user tapped "yes".
Future<bool> showChangeStatusConfirmationDialog(BuildContext context) async {
  final lightMode = Theme.of(context).brightness == Brightness.light;
  final res = await showAppDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: lightMode ? AppColors.white : AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: SizedBox(
          width: 411.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                ServicesLottie.editDocument,
                width: 70.sp,
                height: 70.sp,
                fit: BoxFit.scaleDown,
                repeat: true,
                animate: true,
              ),
              SizedBox(height: 20.sp),
              Text(
                S.of(context).changingStatus,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                S.of(context).Areyousureyouwanttochangethisstatus,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 20.sp),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customButton(
                    title: FormatHelper.capitalize(S.of(context).no),
                    function: () => Navigator.pop(context, false),
                    textStyle: StyleText.fontSize15Weight400.copyWith(
                      color: AppColors.onSecondaryAction,
                    ),
                    width: 118.sp,
                    height: 38.sp,
                    radius: 4.r,
                    color: AppColors.secondaryAction,
                  ),
                  SizedBox(width: 15.sp),
                  customButton(
                    title: FormatHelper.capitalize(S.of(context).yes),
                    function: () => Navigator.pop(context, true),
                    textStyle: StyleText.fontSize15Weight400.copyWith(
                      color: AppColors.textButton,
                    ),
                    width: 118.sp,
                    height: 38.sp,
                    radius: 4.r,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return res == true;
}

/// Success dialog shown after a status change completes.
///
/// SVC-PROV-21: [newStatus] picks the message — "in progress" no longer says
/// the request was completed.
Future<void> showChangeStatusSuccessDialog(
  BuildContext context, {
  required String newStatus,
}) {
  final message = newStatus.toLowerCase().trim() == 'done'
      ? S.of(context).YouSuccessfullyCompletedThisRequest
      : S.of(context).svcRequestMovedToInProgress;
  final lightMode = Theme.of(context).brightness == Brightness.light;
  return showAppDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: lightMode ? AppColors.white : AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: SizedBox(
          width: 405.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                ServicesLottie.approved,
                width: 70.sp,
                height: 70.sp,
                fit: BoxFit.scaleDown,
              ),
              SizedBox(height: 20.sp),
              Text(
                S.of(context).changingStatus,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                message,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Requester-details block (name / department / job title), laid out
/// vertically on mobile and in two columns on tablet/desktop.
Widget buildRequesterDetailsSection({
  required BuildContext context,
  required bool lightMode,
  required bool isTabletLandscape,
  required String? firstNameRequester,
  required String? lastNameRequester,
  required String? jobTitleRequester,
  required String departmentName,
}) {
  final isMobile = ContextExtension(context).isPhone;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        S.of(context).RequesterDetails,
        style: StyleText.fontSize16Weight500.copyWith(
          color: AppColors.blackButton,
        ),
      ),
      SizedBox(height: 20.h),
      if (isMobile) ...[
        CustomRowDetailsMaster(
          data:
              "${FormatHelper.capitalize(firstNameRequester ?? '-')} ${FormatHelper.capitalize(lastNameRequester ?? '-')}",
          image: "assets/icons_assets/main_icons_assets/ic_user_profile.svg",
          title: "${S.of(context).Requestedby}: ",
        ),
        SizedBox(height: 10.sp),
        CustomRowDetailsMaster(
          data: departmentName,
          image: "assets/icons_assets/main_icons_assets/ic_org_briefcase.svg",
          title: "${S.of(context).Department}: ",
        ),
        SizedBox(height: 10.sp),
        CustomRowDetailsMaster(
          data: FormatHelper.capitalize(jobTitleRequester ?? '-'),
          image: "assets/icons_assets/main_icons_assets/ic_org_briefcase.svg",
          title: "${S.of(context).jobTitle}: ",
        ),
      ] else ...[
        // ⚠️ FIXED 31/8/2026 — this Row is why the details page would not
        // render.
        //
        // The spacer between the two columns was sized from the SCREEN:
        //
        //     SizedBox(width: !isTabletLandscape
        //         ? MediaQuery.sizeOf(context).width * .14
        //         : MediaQuery.sizeOf(context).width * .27)
        //
        // but this Row is not laid out against the screen. It sits inside the
        // details content area, which is narrower by the app's side nav
        // (~110px), the frame's padding and the module's nested Navigator. On
        // a 1650px window that asked for a rigid 445px gap AND two columns
        // sized to their own text, inside a box with materially less room —
        // so the Row overflowed its constraints and took the section's layout
        // down with it. Commenting this section out "fixed" the page because
        // it removed the overflowing Row, not because the content was wrong.
        //
        // The columns are now Expanded and the gap is a fixed, small value, so
        // the row divides whatever width it is ACTUALLY given. Nothing here
        // measures the screen any more, which also makes it correct at every
        // window size and inside any container.
        //
        // [isTabletLandscape] is left on the signature — callers pass it — but
        // is deliberately no longer used for spacing.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomRowDetailsMaster(
                    data:
                        "${FormatHelper.capitalize(firstNameRequester ?? '-')} ${FormatHelper.capitalize(lastNameRequester ?? '-')}",
                    image:
                        "assets/icons_assets/main_icons_assets/ic_user_profile.svg",
                    title: "${S.of(context).Requestedby}: ",
                  ),
                  SizedBox(height: 5.sp),
                  CustomRowDetailsMaster(
                    data: departmentName,
                    image:
                        "assets/icons_assets/main_icons_assets/ic_org_briefcase.svg",
                    title: "${S.of(context).Department}: ",
                  ),
                ],
              ),
            ),
            SizedBox(width: 24.sp),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomRowDetailsMaster(
                    data: FormatHelper.capitalize(jobTitleRequester ?? '-'),
                    image:
                        "assets/icons_assets/main_icons_assets/ic_org_briefcase.svg",
                    title: "${S.of(context).jobTitle}: ",
                  ),
                  SizedBox(height: 27.sp),
                ],
              ),
            ),
          ],
        ),
      ],
    ],
  );
}

Widget buildApprovalCycleHeaderSection({
  required BuildContext context,
  required bool lightMode,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Text(
        "${S.of(context).approvalCycle}: ",
        style: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.blackButton,
        ),
      ),
    ],
  );
}

Widget buildApprovalCycleContentSection({
  required BuildContext context,
  required bool isMobile,
  required List<ServiceEmployeeModel> displayCycle,
}) {
  return isMobile
      ? buildApprovalCycleMyRequest(context, false, [], displayCycle)
      : approvalCycleViewLogic(context, displayCycle);
}
