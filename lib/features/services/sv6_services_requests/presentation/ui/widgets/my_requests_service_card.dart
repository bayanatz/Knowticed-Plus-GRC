/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: my_requests_service_card.dart
/// Purpose: One card of the "My requests" grid. It only shows the values the
///          page passes in; it reads nothing itself.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/helpers/services_status_chips.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/reuse_text.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/service_card_metrics.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:shimmer/shimmer.dart';

class CustomServiceCardMyRequest extends StatelessWidget {
  const CustomServiceCardMyRequest({
    required this.title,
    required this.jobTitle,
    required this.status,
    required this.dateRequest,
    required this.lastUpdate,
    required this.pointOfContact,
    required this.owningDepartment,
    required this.duration,
    this.imageUrl = '',
    super.key,
  });

  final String title;
  final String dateRequest;
  final String pointOfContact;
  final String jobTitle;

  /// Canonical request status (RequestStatus).
  final String status;
  final String lastUpdate;
  final String owningDepartment;

  /// Duration text, already formatted for the reader.
  final String duration;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      // Keeps the card's real height in sync with the grid's mainAxisExtent
      // (see ServiceCardMetrics.myRequestCardExtent).
      maxScaleFactor: ServiceCardMetrics.maxTextScale,
      child: Container(
        width: 321.sp,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            right: 15.sp,
            left: 15.sp,
            top: 15.sp,
            bottom: 15.sp,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service image and name
              Row(
                children: [
                  Container(
                    width: 40.sp,
                    height: 40.sp,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: (imageUrl.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 40.sp,
                              height: 40.sp,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: AppColors.secondaryText.withValues(
                                  alpha: .3,
                                ),
                                highlightColor: AppColors.background.withValues(
                                  alpha: .5,
                                ),
                                child: Container(
                                  width: 40.sp,
                                  height: 40.sp,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryText.withValues(
                                      alpha: .5,
                                    ),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                return CustomSvgImage.natural(
                                  assetPath:
                                      'assets/icons_assets/services_assets/ic_time_clock_dashed.svg',
                                  width: 20.sp,
                                  height: 20.sp,
                                  color: AppColors.secondaryText,
                                  fit: BoxFit.scaleDown,
                                );
                              },
                            ),
                          )
                        : CustomSvgImage.natural(
                            assetPath:
                                "assets/icons_assets/main_icons_assets/ic_module_support_headset.svg",
                            width: 20.sp,
                            height: 20.sp,
                            color: AppColors.secondaryText,
                            fit: BoxFit.scaleDown,
                          ),
                  ),
                  SizedBox(width: 8.sp),
                  Expanded(
                    child: Text(
                      FormatHelper.capitalize(title),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.sp),

              // Requested Date
              textCorner(
                image:
                    "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
                label: "${S.of(context).requestedDate}: ",
                content: dateRequest,
                context: context,
              ),
              SizedBox(height: 11.sp),

              // Owning department
              textCorner(
                image:
                    "assets/icons_assets/main_icons_assets/ic_org_department_owner.svg",
                label: "${S.of(context).OwningDepartment}: ",
                content: owningDepartment,
                context: context,
              ),

              SizedBox(height: 11.sp),

              // Service Provider (Point of Contact)
              textCorner(
                image:
                    "assets/icons_assets/main_icons_assets/ic_user_profile.svg",
                label: "${S.of(context).serviceProvider}: ",
                content: pointOfContact,
                context: context,
              ),
              SizedBox(height: 11.sp),

              // Job Title
              textCorner(
                image:
                    "assets/icons_assets/main_icons_assets/ic_org_briefcase.svg",
                label: "${S.of(context).jobTitle}: ",
                content: jobTitle,
                context: context,
              ),
              SizedBox(height: 11.sp),

              // Duration
              textCorner(
                image:
                    "assets/icons_assets/services_assets/ic_time_clock_dashed.svg",
                label: "${S.of(context).durationOfService}: ",
                content: duration,
                context: context,
              ),

              SizedBox(height: 11.sp),

              // Status
              Row(
                children: [
                  CustomSvgImage.natural(
                    assetPath:
                        "assets/icons_assets/main_icons_assets/ic_status.svg",
                    width: 11.sp,
                    height: 11.sp,
                    fit: BoxFit.fill,
                  ),
                  SizedBox(width: 8.sp),
                  Text(
                    FormatHelper.capitalize("${S.of(context).status}: "),
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    FormatHelper.capitalize(context.svcStatus(status)),
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: servicesStatusColor(status),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 11.sp),

              // Last Update
              textCorner(
                image:
                    "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
                label: "${S.of(context).lastUpdate}: ",
                content: lastUpdate,
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
