/// Module: services / sv5_service_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: build_services_card.dart
/// Purpose: Build services card — declares _getBorderColor,
///          buildServiceCardFromMap.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';

Color _getBorderColor(String state) {
  switch (state.toLowerCase()) {
    case 'pending':
      return AppColors.orange; // orange
    case 'done':
      return AppColors.lightGreen; // Or any other color for "done"
    case 'approved':
      return AppColors.lightGreen; // green
    case 'rejected':
    case 'cancel':
      return AppColors.block; // red
    case 'inprogress':
      return AppColors.secondaryPrimary; // yellow
    case 'breached sla':
      return AppColors.block; // dark red
    default:
      return AppColors.lightGrey; // normal
  }
}

Map<String, dynamic> getStatusStyle(
  String status,
  bool lightMode,
  BuildContext context,
) {
  final labelMap = {
    "approved": S.of(context).sm_approved,
    "pending": S.of(context).status_pending,
    "rejected": S.of(context).status_rejected,
    "done": S.of(context).status_done,
    "cancel": S.of(context).status_cancel,
    "inprogress": S.of(context).status_inprogress,
    "breached sla": S.of(context).sm_breachedSla,
  };

  return {
    "label": labelMap[status.toLowerCase()] ?? (S.of(context).sm_unknown),
    "color": _getBorderColor(status),
  };
}

Widget buildServiceCardFromMap(
  Map<String, dynamic> item,
  BuildContext context,
) {
  final model = item["model"] as ServicesHistoryModel;
  final lightMode = Theme.of(context).brightness == Brightness.light;
  final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

  // The reader's version of each bilingual field (services text helpers).
  final pickedName = context.svcPick(
    model.currentServiceNameEnglish,
    model.currentServiceNameArabic,
  );
  final String serviceName = pickedName.isNotEmpty ? pickedName : "-";

  final pickedRequester = context.svcPick(
    "${model.currentFirstNameRequester} ${model.currentLastNameRequester}",
    "${model.currentFirstNameRequesterArabic} "
        "${model.currentLastNameRequesterArabic}",
  );
  final requestor = pickedRequester.isNotEmpty ? pickedRequester : "-";

  // ✅ Get request date
  final requestDate = DateFormat(
    'dd MMM yyyy',
    Localizations.localeOf(context).languageCode,
  ).format(model.currentDurationOfServicesTimestamp.toDate());

  final pickedProvider = context.svcPick(
    item["provider"]?.toString(),
    item["providerAr"]?.toString(),
  );
  final provider =
      pickedProvider.isNotEmpty ? pickedProvider : S.of(context).notAvailable;

  final status = item["status"]?.toString().toLowerCase() ?? "-";
  final statusInfo = getStatusStyle(status, lightMode, context);
  final translatedStatus = statusInfo["label"];
  final statusColor = statusInfo["color"];

  // Debug prints

  return Stack(
    children: [
      Container(
        margin: EdgeInsets.only(bottom: 14.sp),
        padding: EdgeInsets.all(14.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Row: Service Name
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 30.sp,
                  height: 30.sp,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  // Services mobile QA p.34: the service tile showed a person
                  // icon; it is the default service image (headset), as on
                  // every other services card.
                  child: CustomSvgImage.natural(
                    assetPath:
                        "assets/icons_assets/main_icons_assets/ic_module_support_headset.svg",
                    width: 16.sp,
                    height: 16.sp,
                    fit: BoxFit.scaleDown,
                    color: AppColors.secondaryText,
                    semanticsLabel: 'Icon',
                  ),
                ),
                SizedBox(width: 5.sp),
                Expanded(
                  child: Text(
                    serviceName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.blackButton,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.sp),

            /// Row: Requester
            Row(
              children: [
                CustomSvgImage.natural(
                  assetPath:
                      "assets/icons_assets/main_icons_assets/ic_user_profile.svg",
                  fit: BoxFit.scaleDown,
                  color: lightMode
                      ? AppColors.secondaryText
                      : AppColors.whiteShadow,
                ),
                SizedBox(width: 6.sp),
                Text(
                  "${S.of(context).serviceRequester}: ",
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(width: 2.sp),
                ClipOval(
                  child: CustomSvgImage.natural(
                    assetPath:
                        "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
                    fit: BoxFit.scaleDown,
                    width: 25.sp,
                    height: 25.sp,
                  ),
                ),
                SizedBox(width: 4.sp),
                Expanded(
                  child: Text(
                    FormatHelper.capitalize(requestor),
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.blackButton,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 6.sp),

            /// Row: Requested Date
            Row(
              children: [
                CustomSvgImage.natural(
                  assetPath:
                      "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
                  fit: BoxFit.scaleDown,
                  color: lightMode
                      ? AppColors.secondaryText
                      : AppColors.whiteShadow,
                ),
                SizedBox(width: 6.w),
                Text(
                  "${S.of(context).RequestedDate}: ",
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                Text(
                  requestDate,
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
              ],
            ),

            SizedBox(height: 6.sp),

            /// Row: Service Provider
            Row(
              children: [
                CustomSvgImage.natural(
                  assetPath:
                      "assets/icons_assets/main_icons_assets/ic_user_profile.svg",
                  fit: BoxFit.scaleDown,
                  color: lightMode
                      ? AppColors.secondaryText
                      : AppColors.whiteShadow,
                ),
                SizedBox(width: 6.w),
                Text(
                  "${S.of(context).serviceProvider}: ",
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(width: 2.w),
                ClipOval(
                  child: CustomSvgImage.natural(
                    assetPath:
                        "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
                    fit: BoxFit.scaleDown,
                    width: 25.sp,
                    height: 25.sp,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    FormatHelper.capitalize(provider),
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.blackButton,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Positioned(
        top: 7.sp,
        right: isRtl ? null : 7.sp,
        left: isRtl ? 7.sp : null,
        child: Row(
          children: [
            CustomSvgImage.natural(
              assetPath: "assets/icons_assets/main_icons_assets/ic_status.svg",
              fit: BoxFit.scaleDown,
              color:
                  lightMode ? AppColors.secondaryText : AppColors.whiteShadow,
            ),
            SizedBox(width: 2.w),
            Text(
              "${S.of(context).status}: ",
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            Text(
              translatedStatus,
              style: StyleText.fontSize12Weight500
                  .copyWith(color: AppColors.secondaryBlack)
                  .copyWith(color: statusColor),
            ),
          ],
        ),
      ),
    ],
  );
}
