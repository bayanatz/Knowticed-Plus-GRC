/// Module: services / sv9_admin_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_service_grid.dart
/// Purpose: Grid of service cards for filtered department view
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/layout/custom_grid_view.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/controller/admin_cubit.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/controller/admin_state.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/pages/admin_dashboard_details_page.dart';

import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/services/data/utils/request_dates.dart';

class DashboardServiceGrid extends StatelessWidget {
  final DashboardAdminState state;

  const DashboardServiceGrid({super.key, required this.state});

  int _getMaxVisible(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (size.width >= 1200 || (size.width >= 1000 && isLandscape)) return 6;
    if (size.width >= 600) return 4;
    return 4;
  }

  List<Map<String, dynamic>> _visibleServices(BuildContext context) {
    final max = _getMaxVisible(context);
    return state.showAll
        ? state.allServices
        : state.allServices.take(max).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardAdminCubit>();
    final light = Theme.of(context).brightness == Brightness.light;
    final isArabic = context.svcIsArabic;
    final isRTL = Directionality.of(context) == ui.TextDirection.rtl;

    final visible = _visibleServices(context);
    const crossAxisCount = 2;

    List<dynamic> padded = List.from(visible);
    final remainder = padded.length % crossAxisCount;
    if (remainder != 0) {
      padded.addAll(List.filled(crossAxisCount - remainder, null));
    }

    final maxVisible = _getMaxVisible(context);
    final hasMore = state.allServices.length > maxVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          itemCount: padded.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: CrossAxisCountHelperResponsive
                .getCrossAxisCountForDefaultTabletResponsive(
              context,
            ),
            crossAxisSpacing: 14.sp,
            mainAxisSpacing: 15.sp,
            mainAxisExtent: 77.sp,
          ),
          itemBuilder: (context, index) {
            final service = padded[index];
            if (service == null) return const SizedBox();

            final displayTitle =
                isArabic && (service['titleArabic'] as String).isNotEmpty
                    ? service['titleArabic'] as String
                    : service['title'] as String;

            return GestureDetector(
              onTap: () => navigateTo(
                context,
                AdminDashboardDetailsPage(
                  selectedServiceName:
                      service['titleEnglish'] ?? service['title'],
                ),
              ),
              child: Stack(
                children: [
                  _ServiceCard(
                    service: service,
                    displayTitle: displayTitle,
                    lightMode: light,
                  ),
                  Positioned(
                    top: 4.sp,
                    right: isRTL ? null : 0.sp,
                    left: isRTL ? 0.sp : null,
                    child: _StartDateBadge(
                      startDate: RequestDates.format(
                        service['startDate'] as DateTime?,
                        locale: Localizations.localeOf(context).languageCode,
                      ),
                      lightMode: light,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 3.h),
        if (hasMore)
          Center(
            child: TextButton(
              onPressed: withHaptic(cubit.toggleShowAll, HapticLevel.low),
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.showAll
                          ? S.of(context).seeLess
                          : S.of(context).seeAll,
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: AppColors.blue,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(height: 1.2, color: AppColors.blue),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final String displayTitle;
  final bool lightMode;

  const _ServiceCard({
    required this.service,
    required this.displayTitle,
    required this.lightMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 30.sp,
                height: 30.sp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryButton,
                ),
                child: Center(
                  child: CustomSvgImage.natural(
                    assetPath:
                        "assets/icons_assets/main_icons_assets/ic_comms_customer_service.svg",
                    width: 14.sp,
                    height: 14.sp,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
              SizedBox(width: 8.sp),
              Expanded(
                child: Text(
                  FormatHelper.capitalize(displayTitle),
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 7.sp),
          Row(
            children: [
              Text(
                FormatHelper.capitalize("${S.of(context).servicesDone}: "),
                style: StyleText.fontSize10Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                '${service['done']}',
                style: StyleText.fontSize12Weight600.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              const Spacer(),
              Text(
                "${S.of(context).svcPlannedHours}: ",
                style: StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                '${service['total']}',
                style: StyleText.fontSize12Weight600.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StartDateBadge extends StatelessWidget {
  final String startDate;
  final bool lightMode;

  const _StartDateBadge({required this.startDate, required this.lightMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 2.sp),
      decoration: BoxDecoration(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${S.of(context).startDate}: ",
            style: StyleText.fontSize8Weight400
                .copyWith(color: AppColors.secondaryBlack)
                .copyWith(color: AppColors.secondaryText),
          ),
          Text(
            startDate,
            style: StyleText.fontSize8Weight400
                .copyWith(color: AppColors.secondaryBlack)
                .copyWith(color: AppColors.blackButton),
          ),
        ],
      ),
    );
  }
}
