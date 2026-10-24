/// Module: services / sv9_admin_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_status_cards.dart
/// Purpose: Service status count cards (Done, Inprogress, Pending, etc.)
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/widgets/services_dialog.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

class DashboardStatusCards extends StatelessWidget {
  final Map<String, int> statusCounts;
  final bool isMobile;
  final bool lightMode;

  const DashboardStatusCards({
    super.key,
    required this.statusCounts,
    required this.isMobile,
    required this.lightMode,
  });

  @override
  Widget build(BuildContext context) {
    return isMobile ? _buildMobile(context) : _buildDesktop(context);
  }

  Widget _buildMobile(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            _cardContainer(
              width: 168.sp,
              children: [
                OurServicesDialog(
                  color: AppColors.green,
                  title: S.of(context).Done,
                  image:
                      "assets/icons_assets/services_assets/ic_status_done.svg",
                  number: "${statusCounts['done'] ?? 0}",
                ),
                SizedBox(height: 10.sp),
                OurServicesDialog(
                  color: AppColors.secondaryPrimary,
                  title: S.of(context).Inprogress,
                  image:
                      "assets/icons_assets/main_icons_assets/ic_status_work_in_progress.svg",
                  number: "${statusCounts['inprogress'] ?? 0}",
                ),
                SizedBox(height: 10.sp),
                OurServicesDialog(
                  color: AppColors.orange,
                  title: S.of(context).Pending,
                  image:
                      "assets/icons_assets/main_icons_assets/ic_status_pending.svg",
                  number: "${statusCounts['pending'] ?? 0}",
                ),
              ],
            ),
          ],
        ),
        SizedBox(width: 9.sp),
        Column(
          children: [
            _cardContainer(
              width: 168.sp,
              children: [
                OurServicesDialog(
                  color: AppColors.red,
                  title: S.of(context).Rejected,
                  image:
                      "assets/icons_assets/main_icons_assets/ic_status_rejected_circle.svg",
                  number: "${statusCounts['rejected'] ?? 0}",
                ),
                SizedBox(height: 10.sp),
                OurServicesDialog(
                  color: AppColors.red,
                  title: S.of(context).BreachedSLA,
                  image:
                      "assets/icons_assets/main_icons_assets/ic_status_sla_breached.svg",
                  number: "${statusCounts['branchsla'] ?? 0}",
                ),
                SizedBox(height: 10.sp),
                OurServicesDialog(
                  color: AppColors.red,
                  title: S.of(context).Canceled,
                  image:
                      "assets/icons_assets/main_icons_assets/ic_action_close_circle_bold.svg",
                  number: "${statusCounts['cancel'] ?? 0}",
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _cardContainer(
            children: [
              OurServicesDialog(
                color: AppColors.green,
                title: S.of(context).Done,
                image: "assets/icons_assets/services_assets/ic_status_done.svg",
                number: "${statusCounts['done'] ?? 0}",
              ),
              SizedBox(height: 15.sp),
              OurServicesDialog(
                color: AppColors.secondaryPrimary,
                title: S.of(context).Inprogress,
                image:
                    "assets/icons_assets/main_icons_assets/ic_status_work_in_progress.svg",
                number: "${statusCounts['inprogress'] ?? 0}",
              ),
            ],
          ),
        ),
        SizedBox(width: 29.sp),
        Expanded(
          child: _cardContainer(
            children: [
              OurServicesDialog(
                color: AppColors.orange,
                title: S.of(context).Pending,
                image:
                    "assets/icons_assets/main_icons_assets/ic_status_pending.svg",
                number: "${statusCounts['pending'] ?? 0}",
              ),
              SizedBox(height: 15.sp),
              OurServicesDialog(
                color: AppColors.red,
                title: S.of(context).Rejected,
                image:
                    "assets/icons_assets/main_icons_assets/ic_status_rejected_circle.svg",
                number: "${statusCounts['rejected'] ?? 0}",
              ),
            ],
          ),
        ),
        SizedBox(width: 29.sp),
        Expanded(
          child: _cardContainer(
            children: [
              OurServicesDialog(
                color: AppColors.red,
                title: S.of(context).Canceled,
                image:
                    "assets/icons_assets/main_icons_assets/ic_action_close_circle_bold.svg",
                number: "${statusCounts['cancel'] ?? 0}",
              ),
              SizedBox(height: 15.sp),
              OurServicesDialog(
                color: AppColors.red,
                title: S.of(context).BreachedSLA,
                image:
                    "assets/icons_assets/main_icons_assets/ic_status_sla_breached.svg",
                number: "${statusCounts['branchsla'] ?? 0}",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cardContainer({double? width, required List<Widget> children}) {
    Widget card = Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          right: 20.sp,
          left: 10.sp,
          top: 10.sp,
          bottom: 10.sp,
        ),
        child: Column(children: children),
      ),
    );
    return card;
  }
}
