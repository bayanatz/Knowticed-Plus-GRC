/// Module: services / sv10_services_provider / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: provider_service_card.dart
/// Purpose: One request in the provider's grid: service, request date,
///          requester, department, job title, duration and status. Moved out
///          of the page part file (Provider rule 14).
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/request_dates.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/reuse_text.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/controller/employee_services_cubit.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/ui/widgets/services_table_widget.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Class Name: [ProviderServiceCard]
///
/// Purpose: The grid card of one request.
class ProviderServiceCard extends StatelessWidget {
  const ProviderServiceCard({required this.service, super.key});

  final ServicesHistoryModel service;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    // SVC-PROV-19: both breached-SLA spellings are one status with one colour.
    final status = EmployeeServicesCubit.statusOf(service);
    final light = Theme.of(context).brightness == Brightness.light;

    Widget row(String icon, String label, String content) => Padding(
          padding: EdgeInsets.only(top: 11.sp),
          child: textCorner(
            image: icon,
            label: '$label: ',
            content: content,
            context: context,
          ),
        );

    return Container(
      width: 313.sp,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.all(15.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50.sp,
                height: 50.sp,
                decoration: BoxDecoration(
                  color:
                      light ? AppColors.secondaryButton : AppColors.background,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Center(
                  child: CustomSvgImage.natural(
                    assetPath:
                        'assets/icons_assets/main_icons_assets/ic_module_support_headset.svg',
                    width: 24.sp,
                    height: 24.sp,
                    fit: BoxFit.scaleDown,
                    color: AppColors.blackButton,
                    semanticsLabel: s.service,
                  ),
                ),
              ),
              SizedBox(width: 8.sp),
              Expanded(
                child: Text(
                  FormatHelper.capitalize(
                    context.svcPick(
                      service.currentServiceNameEnglish,
                      service.currentServiceNameArabic,
                    ),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.sp),
          // SVC-PROV-08: the date the request was made.
          row(
            'assets/icons_assets/main_icons_assets/ic_time_calendar.svg',
            s.requestDate,
            RequestDates.format(
              RequestDates.createdAt(service),
              locale: Localizations.localeOf(context).languageCode,
            ),
          ),
          row(
            'assets/icons_assets/main_icons_assets/ic_user_profile.svg',
            s.serviceRequester,
            context.svcPick(
              '${service.currentFirstNameRequester} ${service.currentLastNameRequester}',
              '${service.currentFirstNameRequesterArabic} ${service.currentLastNameRequesterArabic}',
            ),
          ),
          row(
            'assets/icons_assets/main_icons_assets/ic_org_briefcase.svg',
            s.department,
            context.svcDepartmentName(service.currentDepartmentRequester),
          ),
          row(
            'assets/icons_assets/main_icons_assets/ic_org_briefcase.svg',
            s.jobTitle,
            context.svcPick(
              service.currentJobTitleRequester,
              service.currentJobTitleRequesterArabic,
            ),
          ),
          row(
            'assets/icons_assets/services_assets/ic_time_clock_dashed.svg',
            s.durationOfService,
            context.svcDuration(
              service.currentDurationOfServices,
              service.currentSelectedDurationUnit,
            ),
          ),
          SizedBox(height: 11.sp),
          Row(
            children: [
              CustomSvgImage.natural(
                assetPath:
                    'assets/icons_assets/main_icons_assets/ic_status.svg',
                width: 12.sp,
                height: 12.sp,
                fit: BoxFit.fill,
                semanticsLabel: s.Status,
              ),
              SizedBox(width: 8.sp),
              Text(
                FormatHelper.capitalize('${s.Status}: '),
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(width: 4.sp),
              Text(
                FormatHelper.capitalize(context.svcStatus(status)),
                style: StyleText.fontSize14Weight400.copyWith(
                  color: ServicesTableWidget.statusColor(status),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
