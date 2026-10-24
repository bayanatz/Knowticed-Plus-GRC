/// Module: services / presentation / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: responsive_text.dart
/// Purpose: The provider block of a service's details (owning department,
///          provider, e-mail, job title, phone, duration) in its phone,
///          tablet and desktop layouts, and the labelled detail row it is
///          built from.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

/// The text of one phone field, without list brackets.
String _extractPhoneData(dynamic phoneData, String fieldName) {
  if (phoneData == null) {
    return '';
  }

  String result = '';

  if (phoneData is String) {
    // Remove brackets from string like "[965]" -> "965"
    result = phoneData.replaceAll(RegExp(r'[\[\]]'), '').trim();
  } else if (phoneData is List && phoneData.isNotEmpty) {
    // Extract first element from list
    result = phoneData[0].toString();
  } else {
    result = phoneData.toString();
  }

  return result;
}

/// "+<country code> <phone>", or '-'.
String _formatPhoneNumber(Map<String, dynamic>? mobilePhone) {
  if (mobilePhone == null) {
    return '-';
  }

  final countryCode = _extractPhoneData(
    mobilePhone['countryCode'],
    'countryCode',
  );
  final phone = _extractPhoneData(mobilePhone['phone'], 'phone');

  if (countryCode.isNotEmpty && phone.isNotEmpty) {
    final formatted = "+$countryCode $phone";
    return FormatHelper.capitalize(formatted);
  }

  return '-';
}

/// Layout breakpoints for the request-details info block.
abstract class DetailsBreakpoints {
  /// Below this: stacked (mobile).
  static const double twoColumn = 600;

  /// At/above this: 3 items per row (desktop). Between the two: 2 per row.
  static const double threeColumn = 1200;
}

Widget buildProviderServiceDetailsServices({
  required BuildContext context,
  required String owningDepartment,
  required String durationUnit,
  required Map<String, dynamic> provider,
  required ServicesHistoryModel requestModel,
}) {
  final isMobile = ContextExtension(context).isPhone;
  !kpIsPhoneLayout(context) &&
      MediaQuery.of(context).orientation == Orientation.landscape;

  final leftColumn = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomRowDetailsMaster(
        data: FormatHelper.capitalize(
          context.svcPick(
            "${provider['firstName'] ?? '-'} ${provider['lastName'] ?? '-'}",
            "${provider['firstNameInArabic'] ?? '-'} ${provider['lastNameInArabic'] ?? '-'}",
          ),
        ),
        image: "assets/icons_assets/main_icons_assets/ic_user_profile.svg",
        title: FormatHelper.capitalize("${S.of(context).serviceProvider}: "),
        imagePerson: (provider['gender'] ?? 'male') == "male"
            ? "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png"
            : "assets/icons_assets/main_icons_assets/ic_user_avatar_female.png",
      ),
      SizedBox(height: 6.sp),
      CustomRowDetailsMaster(
        data: FormatHelper.capitalize(provider['email'] ?? '-'),
        image: "assets/icons_assets/main_icons_assets/ic_comms_email.svg",
        title: FormatHelper.capitalize("${S.of(context).email}: "),
      ),
      SizedBox(height: 12.sp),
      CustomRowDetailsMaster(
        data:
            "${FormatHelper.capitalize(requestModel.currentDurationOfServices)} $durationUnit",
        image: "assets/icons_assets/services_assets/ic_time_clock_dashed.svg",
        title: FormatHelper.capitalize("${S.of(context).durationOfService}: "),
      ),
    ],
  );

  final rightColumn = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      isMobile ? SizedBox() : SizedBox(height: 8.sp),

      CustomRowDetailsMaster(
        data: FormatHelper.capitalize(
          context.svcPick(
            provider['title'] ?? '-',
            provider['titleInArabic'] ?? '-',
          ),
        ),
        image: "assets/icons_assets/main_icons_assets/ic_org_briefcase.svg",
        title: FormatHelper.capitalize("${S.of(context).jobTitle}: "),
      ),
      SizedBox(height: 11.sp),

      // Mobile/Tablet phone display
      CustomRowDetailsMaster(
        data: _formatPhoneNumber(provider['mobilePhone']),
        image:
            "assets/icons_assets/main_icons_assets/ic_comms_phone_rounded.svg",
        title: FormatHelper.capitalize("${S.of(context).phone}: "),
      ),

      SizedBox(height: 12.sp),
      CustomRowDetailsMaster(
        data: FormatHelper.capitalize(
          requestModel.currentApprovalCycle.isEmpty
              ? (S.of(context).sm_doesnTNeedApproval)
              : (S.of(context).sm_needApproval),
        ),
        image: "assets/icons_assets/services_assets/ic_file_document_add.svg",
        title: FormatHelper.capitalize("${S.of(context).approvals}: "),
      ),
    ],
  );

  if (isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leftColumn,
        SizedBox(height: 10.sp),
        rightColumn,
      ],
    );
  } else {
    // 2 items per row until there's genuinely room for 3.
    // Each CustomRowDetailsMaster needs ~380px to show an email or a job
    // title without truncating, so 3-across only pays off past ~1200.
    final width = MediaQuery.sizeOf(context).width;
    var isTablet = width >= 600 && width < DetailsBreakpoints.threeColumn;

    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomRowDetailsMaster(
                  data: FormatHelper.capitalize(
                    context.svcPick(
                      "${provider['firstName'] ?? '-'} ${provider['lastName'] ?? '-'}",
                      "${provider['firstNameInArabic'] ?? '-'} ${provider['lastNameInArabic'] ?? '-'}",
                    ),
                  ),
                  image:
                      "assets/icons_assets/main_icons_assets/ic_user_profile.svg",
                  title: FormatHelper.capitalize(
                    "${S.of(context).serviceProvider}: ",
                  ),
                  imagePerson: (provider['gender'] ?? 'male') == "male"
                      ? "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png"
                      : "assets/icons_assets/main_icons_assets/ic_user_avatar_female.png",
                ),
                SizedBox(height: 6.sp),
                CustomRowDetailsMaster(
                  data: FormatHelper.capitalize(provider['email'] ?? '-'),
                  image:
                      "assets/icons_assets/main_icons_assets/ic_comms_email.svg",
                  title: FormatHelper.capitalize("${S.of(context).email}: "),
                ),
                SizedBox(height: 12.sp),
                CustomRowDetailsMaster(
                  data:
                      "${FormatHelper.capitalize(requestModel.currentDurationOfServices)} $durationUnit",
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
                    context.svcPick(
                      provider['title'] ?? '-',
                      provider['titleInArabic'] ?? '-',
                    ),
                  ),
                  image:
                      "assets/icons_assets/main_icons_assets/ic_org_briefcase.svg",
                  title: FormatHelper.capitalize("${S.of(context).jobTitle}: "),
                ),
                SizedBox(height: 11.sp),

                // Tablet phone display
                CustomRowDetailsMaster(
                  data: _formatPhoneNumber(provider['mobilePhone']),
                  image:
                      "assets/icons_assets/main_icons_assets/ic_comms_phone_rounded.svg",
                  title: FormatHelper.capitalize("${S.of(context).phone}: "),
                ),

                SizedBox(height: 12.sp),
                CustomRowDetailsMaster(
                  data: FormatHelper.capitalize(
                    requestModel.currentApprovalCycle.isEmpty
                        ? (S.of(context).sm_doesnTNeedApproval)
                        : (S.of(context).sm_needApproval),
                  ),
                  image:
                      "assets/icons_assets/services_assets/ic_file_document_add.svg",
                  title: FormatHelper.capitalize(
                    "${S.of(context).approvals}: ",
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomRowDetailsMaster(
                  data: FormatHelper.capitalize(
                    context.svcPick(
                      "${provider['firstName'] ?? '-'} ${provider['lastName'] ?? '-'}",
                      "${provider['firstNameInArabic'] ?? '-'} ${provider['lastNameInArabic'] ?? '-'}",
                    ),
                  ),
                  image:
                      "assets/icons_assets/main_icons_assets/ic_user_profile.svg",
                  title: FormatHelper.capitalize(
                    "${S.of(context).serviceProvider}: ",
                  ),
                  imagePerson: (provider['gender'] ?? 'male') == "male"
                      ? "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png"
                      : "assets/icons_assets/main_icons_assets/ic_user_avatar_female.png",
                ),
              ),
              Expanded(
                child: CustomRowDetailsMaster(
                  data: FormatHelper.capitalize(provider['email'] ?? '-'),
                  image:
                      "assets/icons_assets/main_icons_assets/ic_comms_email.svg",
                  title: FormatHelper.capitalize("${S.of(context).email}: "),
                ),
              ),
              Expanded(
                child: CustomRowDetailsMaster(
                  data: FormatHelper.capitalize(
                    requestModel.currentApprovalCycle.isEmpty
                        ? (S.of(context).sm_doesnTNeedApproval)
                        : (S.of(context).sm_needApproval),
                  ),
                  image:
                      "assets/icons_assets/services_assets/ic_file_document_add.svg",
                  title: FormatHelper.capitalize(
                    "${S.of(context).approvals}: ",
                  ),
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
                    context.svcPick(
                      provider['title'] ?? '-',
                      provider['titleInArabic'] ?? '-',
                    ),
                  ),
                  image:
                      "assets/icons_assets/main_icons_assets/ic_org_briefcase.svg",
                  title: FormatHelper.capitalize("${S.of(context).jobTitle}: "),
                ),
              ),
              Expanded(
                // Desktop phone display
                child: CustomRowDetailsMaster(
                  data: _formatPhoneNumber(provider['mobilePhone']),
                  image:
                      "assets/icons_assets/main_icons_assets/ic_comms_phone_rounded.svg",
                  title: FormatHelper.capitalize("${S.of(context).phone}: "),
                ),
              ),
              Expanded(
                child: CustomRowDetailsMaster(
                  data:
                      "${FormatHelper.capitalize(requestModel.currentDurationOfServices)} $durationUnit",
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
  }
}

class CustomRowDetailsMaster extends StatelessWidget {
  const CustomRowDetailsMaster({
    super.key,
    required this.image,
    required this.title,
    required this.data,
    this.imagePerson,
    this.unit,
  });

  final String image;
  final String title;
  final String data;
  final String? imagePerson;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomSvgImage.natural(
          assetPath: image,
          width: 17.sp,
          height: 17.sp,
          fit: BoxFit.fill,
        ),
        SizedBox(width: 4.sp),
        // The label keeps its intrinsic width where possible but yields
        // before the row overflows.
        Flexible(
          flex: 0,
          child: Text(
            FormatHelper.capitalize(title),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: isMobile
                ? StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.secondaryText,
                  )
                : StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
          ),
        ),
        if (imagePerson != null)
          Row(
            children: [
              ClipOval(
                child: CustomSvgImage.natural(
                  assetPath: imagePerson!,
                  fit: BoxFit.cover,
                  width: 28.w,
                  height: 28.h,
                ),
              ),
              SizedBox(width: 5.w),
            ],
          ),
        // The value takes the remaining width and ellipsises instead of
        // overflowing — emails and job titles are unbounded in length.
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  FormatHelper.capitalize(data),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: isMobile
                      ? StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.blackButton,
                        )
                      : StyleText.fontSize14Weight400.copyWith(
                          color: AppColors.blackButton,
                        ),
                ),
              ),
              if (unit != null && unit!.isNotEmpty) ...[
                SizedBox(width: 2.w),
                Text(
                  FormatHelper.capitalize(unit!),
                  style: isMobile
                      ? StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.blackButton,
                        )
                      : StyleText.fontSize14Weight400.copyWith(
                          color: AppColors.blackButton,
                        ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
