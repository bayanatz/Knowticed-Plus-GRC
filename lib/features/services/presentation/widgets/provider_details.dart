/// Module: services / presentation / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: provider_details.dart
/// Purpose: The provider block of a request (name, e-mail, job title, phone,
///          duration and whether approval is needed) in its phone, tablet
///          and desktop layouts.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/responsive_text.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';

Widget buildProviderDetailsSectionMaster({
  Function()? onTap,
  bool table = false,
  required BuildContext context,
  required String duration,
  required String durationUnit,
  required List approvalCycle,
  required ServiceEmployeeModel model,
  required String state,
}) {
  final isMobile = ContextExtension(context).isPhone;
  final ServiceEmployeeModel provider = model;
  final providerName = context.svcPick(
    "${provider.firstName ?? '-'} ${provider.lastName ?? '-'}",
    "${provider.firstNameInArabic ?? '-'} ${provider.lastNameInArabic ?? '-'}",
  );
  final durationText = context.svcDuration(duration, durationUnit);

  // Only allow edit if state is pending or approved
  final canEdit =
      state.toLowerCase() == 'pending' || state.toLowerCase() == 'approved';

  // Reusable avatar + name row (no edit, no gesture)
  final avatarAndName = Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ClipOval(
        child: CustomSvgImage.natural(
          assetPath: (provider.gender ?? 'male') == 'male'
              ? "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png"
              : "assets/icons_assets/main_icons_assets/ic_user_avatar_female.png",
          width: 25.sp,
          height: 25.sp,
          fit: BoxFit.scaleDown,
        ),
      ),
      SizedBox(width: 5.sp),
      Text(
        FormatHelper.capitalize(providerName),
        style: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.blackButton,
        ),
      ),
    ],
  );

  // Single builder for the provider row — used in all 3 layout branches
  Widget buildProviderRow() {
    if (!table) {
      return CustomRowDetailsMaster(
        data: FormatHelper.capitalize(providerName),
        image: "assets/icons_assets/main_icons_assets/ic_user_profile.svg",
        title: FormatHelper.capitalize("${S.of(context).serviceProvider}: "),
        imagePerson: (provider.gender ?? 'male') == 'male'
            ? "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png"
            : "assets/icons_assets/main_icons_assets/ic_user_avatar_female.png",
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomSvgImage.natural(
          assetPath:
              "assets/icons_assets/main_icons_assets/ic_user_profile.svg",
          width: 20.sp,
          height: 20.sp,
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.secondaryText
              : AppColors.whiteShadow,
        ),
        SizedBox(width: 8.w),
        Text(
          FormatHelper.capitalize("${S.of(context).serviceProvider}: "),
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        // If canEdit → wrap with GestureDetector + show edit icon
        // If !canEdit → show only avatar + name
        canEdit
            ? GestureDetector(
                onTapDown: hapticDown(onTap, HapticLevel.medium),
                onTap: onTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 6.sp,
                    horizontal: 6.sp,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      avatarAndName,
                      SizedBox(width: 15.sp),
                      CustomSvgImage.natural(
                        assetPath:
                            "assets/icons_assets/main_icons_assets/ic_action_edit.svg",
                        width: 16.sp,
                        height: 16.sp,
                        fit: BoxFit.scaleDown,
                      ),
                    ],
                  ),
                ),
              )
            : avatarAndName,
      ],
    );
  }

  // ==================== LEFT COLUMN ====================

  final leftColumn = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildProviderRow(),
      SizedBox(height: 6.sp),
      CustomRowDetailsMaster(
        data: FormatHelper.capitalize(provider.email ?? '-'),
        image: "assets/icons_assets/main_icons_assets/ic_comms_email.svg",
        title: FormatHelper.capitalize("${S.of(context).email}: "),
      ),
      SizedBox(height: 12.sp),
      CustomRowDetailsMaster(
        data: durationText,
        image: "assets/icons_assets/services_assets/ic_time_clock_dashed.svg",
        title: FormatHelper.capitalize("${S.of(context).durationOfService}: "),
      ),
    ],
  );

  // ==================== RIGHT COLUMN ====================

  final rightColumn = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      isMobile ? const SizedBox() : SizedBox(height: 8.sp),
      CustomRowDetailsMaster(
        data: FormatHelper.capitalize(
          context.svcPick(provider.title, provider.titleInArabic),
        ),
        image: "assets/icons_assets/main_icons_assets/ic_org_briefcase.svg",
        title: FormatHelper.capitalize("${S.of(context).jobTitle}: "),
      ),
      SizedBox(height: 11.sp),
      CustomRowDetailsMaster(
        data: FormatHelper.capitalize(
          provider.mobilePhone?.phone?.toString().replaceAll(
                    RegExp(r'[\[\]]'),
                    '',
                  ) ??
              '-',
        ),
        image:
            "assets/icons_assets/main_icons_assets/ic_comms_phone_rounded.svg",
        title: FormatHelper.capitalize("${S.of(context).phone}: "),
      ),
      SizedBox(height: 12.sp),
      CustomRowDetailsMaster(
        data: FormatHelper.capitalize(
          approvalCycle.isEmpty
              ? (S.of(context).sm_doesnTNeedApproval)
              : (S.of(context).sm_needApproval),
        ),
        image: "assets/icons_assets/services_assets/ic_file_document_add.svg",
        title: FormatHelper.capitalize("${S.of(context).approvals}: "),
      ),
    ],
  );

  // ==================== MOBILE LAYOUT ====================

  if (isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leftColumn,
        SizedBox(height: 10.sp),
        rightColumn,
      ],
    );
  }

  // ==================== TABLET LAYOUT (600 - 900) ====================

  final isTabletCheck =
      !kpIsPhoneLayout(context) && MediaQuery.sizeOf(context).width < 900;

  if (isTabletCheck) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildProviderRow(),
              SizedBox(height: 6.sp),
              CustomRowDetailsMaster(
                data: FormatHelper.capitalize(provider.email ?? '-'),
                image:
                    "assets/icons_assets/main_icons_assets/ic_comms_email.svg",
                title: FormatHelper.capitalize("${S.of(context).email}: "),
              ),
              SizedBox(height: 12.sp),
              CustomRowDetailsMaster(
                data: durationText,
                image:
                    "assets/icons_assets/services_assets/ic_time_clock_dashed.svg",
                title: FormatHelper.capitalize(
                  "${S.of(context).durationOfService}: ",
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomRowDetailsMaster(
                data: FormatHelper.capitalize(
                  context.svcPick(provider.title, provider.titleInArabic),
                ),
                image:
                    "assets/icons_assets/main_icons_assets/ic_org_briefcase.svg",
                title: FormatHelper.capitalize("${S.of(context).jobTitle}: "),
              ),
              SizedBox(height: 11.sp),
              CustomRowDetailsMaster(
                data: FormatHelper.capitalize(
                  provider.mobilePhone?.phone ?? '-',
                ),
                image:
                    "assets/icons_assets/main_icons_assets/ic_comms_phone_rounded.svg",
                title: FormatHelper.capitalize("${S.of(context).phone}: "),
              ),
              SizedBox(height: 12.sp),
              CustomRowDetailsMaster(
                data: FormatHelper.capitalize(
                  approvalCycle.isEmpty
                      ? (S.of(context).sm_doesnTNeedApproval)
                      : (S.of(context).sm_needApproval),
                ),
                image:
                    "assets/icons_assets/services_assets/ic_file_document_add.svg",
                title: FormatHelper.capitalize("${S.of(context).approvals}: "),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== DESKTOP/LARGE TABLET LAYOUT ====================

  return Column(
    children: [
      Row(
        children: [
          Expanded(child: buildProviderRow()),
          Expanded(
            child: CustomRowDetailsMaster(
              data: FormatHelper.capitalize(provider.email ?? '-'),
              image: "assets/icons_assets/main_icons_assets/ic_comms_email.svg",
              title: FormatHelper.capitalize("${S.of(context).email}: "),
            ),
          ),
          Expanded(
            child: CustomRowDetailsMaster(
              data: FormatHelper.capitalize(
                approvalCycle.isEmpty
                    ? (S.of(context).sm_doesnTNeedApproval)
                    : (S.of(context).sm_needApproval),
              ),
              image:
                  "assets/icons_assets/services_assets/ic_file_document_add.svg",
              title: FormatHelper.capitalize("${S.of(context).approvals}: "),
            ),
          ),
        ],
      ),
      SizedBox(height: 10.sp),
      Row(
        children: [
          Expanded(
            child: CustomRowDetailsMaster(
              data: FormatHelper.capitalize(
                context.svcPick(provider.title, provider.titleInArabic),
              ),
              image:
                  "assets/icons_assets/main_icons_assets/ic_org_briefcase.svg",
              title: FormatHelper.capitalize("${S.of(context).jobTitle}: "),
            ),
          ),
          Expanded(
            child: CustomRowDetailsMaster(
              data: FormatHelper.capitalize(
                "+${provider.mobilePhone?.countryCode?.toString().replaceAll(RegExp(r'[\[\]]'), '') ?? ''} ${provider.mobilePhone?.phone?.toString().replaceAll(RegExp(r'[\[\]]'), '') ?? '-'}",
              ),
              image:
                  "assets/icons_assets/main_icons_assets/ic_comms_phone_rounded.svg",
              title: FormatHelper.capitalize("${S.of(context).phone}: "),
            ),
          ),
          Expanded(
            child: CustomRowDetailsMaster(
              data: durationText,
              image:
                  "assets/icons_assets/services_assets/ic_time_clock_dashed.svg",
              title: FormatHelper.capitalize(
                "${S.of(context).durationOfService}: ",
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
