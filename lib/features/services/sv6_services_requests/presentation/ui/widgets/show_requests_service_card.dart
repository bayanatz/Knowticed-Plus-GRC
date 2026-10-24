/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: show_requests_service_card.dart
/// Purpose: One card of the "Service requests" grid with its Request
///          button. It shows the values the grid passes in; requesting runs
///          RequestServiceDialogs.run (NewRequestCubit does the work).
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/request_service_dialogs.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/reuse_text.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:shimmer/shimmer.dart';

class CustomServiceCard extends StatelessWidget {
  final String serviceName;
  final String owningDepartment;
  final String serviceProvider;
  final String jobTitle;

  /// Duration text, already formatted for the reader.
  final String durationOfServices;
  final String approval;
  final ServicesHistoryModel model;

  const CustomServiceCard({
    super.key,
    required this.serviceName,
    required this.owningDepartment,
    required this.serviceProvider,
    required this.jobTitle,
    required this.durationOfServices,
    required this.approval,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return MediaQuery.withClampedTextScaling(
      // Keeps the card's real height in sync with the grid's
      // mainAxisExtent (see ServiceCardMetrics).
      maxScaleFactor: 1.4,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 15.sp,
            right: 15.sp,
            left: 15.sp,
            bottom: 15.sp,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.sp,
                    height: 40.sp,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: (model.currentImageUrl.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: CachedNetworkImage(
                              imageUrl: model.currentImageUrl,
                              width: 40.sp,
                              height: 40.sp,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: lightMode
                                    ? AppColors.secondaryText.withValues(
                                        alpha: 0.3,
                                      )
                                    : AppColors.grey.withValues(alpha: 0.3),
                                highlightColor: AppColors.background.withValues(
                                  alpha: 0.5,
                                ),
                                child: Container(
                                  width: 40.sp,
                                  height: 40.sp,
                                  decoration: BoxDecoration(
                                    color: lightMode
                                        ? AppColors.secondaryText.withValues(
                                            alpha: 0.1,
                                          )
                                        : AppColors.grey.withValues(alpha: 0.1),
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
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      FormatHelper.capitalize(serviceName),
                      style: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.sp),
              textCorner(
                image:
                    "assets/icons_assets/main_icons_assets/ic_org_department_owner.svg",
                label: "${S.of(context).OwningDepartment}: ",
                content: owningDepartment,
                context: context,
              ),
              SizedBox(height: 5.sp),
              textCorner(
                image:
                    "assets/icons_assets/main_icons_assets/ic_user_profile.svg",
                label: "${S.of(context).serviceProvider}: ",
                content: FormatHelper.capitalize(serviceProvider),
                context: context,
              ),
              SizedBox(height: 5.sp),
              textCorner(
                image:
                    "assets/icons_assets/main_icons_assets/ic_org_briefcase.svg",
                label: "${S.of(context).jobTitle}: ",
                content: FormatHelper.capitalize(jobTitle),
                context: context,
              ),
              SizedBox(height: 5.sp),
              textCorner(
                image:
                    "assets/icons_assets/services_assets/ic_time_clock_dashed.svg",
                label: "${S.of(context).durationOfService}: ",
                content: FormatHelper.capitalize(durationOfServices),
                context: context,
              ),
              SizedBox(height: 5.sp),
              textCorner(
                image:
                    "assets/icons_assets/services_assets/ic_file_document_add.svg",
                label: "${S.of(context).approvals}: ",
                content: FormatHelper.capitalize(approval),
                context: context,
              ),
              SizedBox(height: 10.sp),
              Expanded(
                child: customButton(
                  title: FormatHelper.capitalize(S.of(context).request),
                  function: () => RequestServiceDialogs.run(context, model),
                  textStyle: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.textButton,
                  ),
                  height: 35.sp,
                  // customButton ignores `width` (ButtonSizing); exactWidth is
                  // the opt-out so the button fills the card.
                  exactWidth: double.infinity,
                  width: double.infinity,
                  radius: 8.r,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
