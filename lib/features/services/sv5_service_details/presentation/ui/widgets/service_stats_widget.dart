/// Module: services / sv5_service_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: service_stats_widget.dart
/// Purpose: Service stats widget — declares ServiceStatsWidget.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/widgets/services_dialog.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/data/models/service_stats_model.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/widgets/info_text.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ServiceStatsWidget extends StatelessWidget {
  final ServiceStatsModel stats;

  const ServiceStatsWidget({required this.stats, super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final isTablet = ContextExtension(context).isTablet;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return isMobile
        ? _buildMobileLayout(context, lightMode)
        : _buildTabletLayout(context, lightMode, isTablet);
  }

  Widget _buildMobileLayout(BuildContext context, bool lightMode) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(10.sp),
              child: Column(
                children: [
                  // Services mobile QA p.11: Approved removed from the service
                  // stats (as on tablet), Pending moved into its slot in this
                  // column and Breached SLA added to the right column.
                  OurServicesDialog(
                    color: AppColors.lightGreen,
                    title: S.of(context).Done,
                    image:
                        "assets/icons_assets/services_assets/ic_status_done.svg",
                    number: "${stats.done}",
                  ),
                  SizedBox(height: 15.sp),
                  OurServicesDialog(
                    color: AppColors.secondaryPrimary,
                    title: S.of(context).Inprogress,
                    image:
                        "assets/icons_assets/main_icons_assets/ic_status_work_in_progress.svg",
                    number: "${stats.inprogress}",
                  ),
                  SizedBox(height: 15.sp),
                  OurServicesDialog(
                    color: AppColors.orange,
                    title: S.of(context).Pending,
                    image:
                        "assets/icons_assets/main_icons_assets/ic_status_pending.svg",
                    number: "${stats.pending}",
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(10.sp),
              child: Column(
                children: [
                  OurServicesDialog(
                    color: AppColors.red,
                    title: S.of(context).Rejected,
                    image:
                        "assets/icons_assets/main_icons_assets/ic_status_rejected_circle.svg",
                    number: "${stats.rejected}",
                  ),
                  SizedBox(height: 15.sp),
                  OurServicesDialog(
                    color: AppColors.red,
                    title: S.of(context).Canceled,
                    image:
                        "assets/icons_assets/main_icons_assets/ic_action_close_circle_bold.svg",
                    number: "${stats.cancel}",
                  ),
                  SizedBox(height: 15.sp),
                  OurServicesDialog(
                    color: AppColors.red,
                    title: S.of(context).BreachedSLA,
                    image:
                        "assets/icons_assets/main_icons_assets/ic_status_sla_breached.svg",
                    number: "${stats.branchsla}",
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    bool lightMode,
    bool isTablet,
  ) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(15.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OurServicesDialog(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  color: AppColors.green,
                  title: S.of(context).Done,
                  image:
                      "assets/icons_assets/services_assets/ic_status_done.svg",
                  number: "${stats.done}",
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15.sp),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OurServicesDialog(
                        color: AppColors.lightGreen,
                        title: S.of(context).approved,
                        image:
                            "assets/icons_assets/main_icons_assets/ic_status_approved_circle.svg",
                        number: "${stats.approved}",
                      ),
                      SizedBox(height: 13.sp),
                      OurServicesDialog(
                        color: AppColors.secondaryPrimary,
                        title: S.of(context).Inprogress,
                        image:
                            "assets/icons_assets/main_icons_assets/ic_status_work_in_progress.svg",
                        number: "${stats.inprogress}",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: !isTabletLandscape(context) ? 10.sp : 65.sp),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15.sp),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OurServicesDialog(
                        color: AppColors.orange,
                        title: S.of(context).Pending,
                        image:
                            "assets/icons_assets/main_icons_assets/ic_status_pending.svg",
                        number: "${stats.pending}",
                      ),
                      SizedBox(height: 13.sp),
                      OurServicesDialog(
                        color: AppColors.red,
                        title: S.of(context).Rejected,
                        image:
                            "assets/icons_assets/main_icons_assets/ic_status_rejected_circle.svg",
                        number: "${stats.rejected}",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: !isTabletLandscape(context) ? 10.sp : 65.sp),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15.sp),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OurServicesDialog(
                        color: AppColors.red,
                        title: S.of(context).Canceled,
                        image:
                            "assets/icons_assets/main_icons_assets/ic_action_close_circle_bold.svg",
                        number: "${stats.cancel}",
                      ),
                      SizedBox(height: 13.sp),
                      OurServicesDialog(
                        color: AppColors.red,
                        title: S.of(context).BreachedSLA,
                        image:
                            "assets/icons_assets/main_icons_assets/ic_status_sla_breached.svg",
                        number: "${stats.branchsla}",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
