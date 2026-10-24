/// Module: services / sv5_service_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: employees_tab_widget.dart
/// Purpose: Employees tab widget — declares EmployeesTabWidget.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/employee_service_stats.dart';
import 'package:shimmer/shimmer.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/controller/details_services_cubit.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/controller/details_services_state.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/widgets/employee_stats_card.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class EmployeesTabWidget extends StatelessWidget {
  final TextEditingController searchController;
  final ServicesHistoryModel createServicesModel;

  const EmployeesTabWidget({
    required this.searchController,
    required this.createServicesModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = DetailsServicesCubit.get(context);
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return BlocBuilder<DetailsServicesCubit, DetailsServicesState>(
      builder: (context, state) {
        final allEmployees = cubit.allEmployees;

        // SVC-HOME-08: shimmer only while loading; an empty team after the
        // load finished shows the empty state instead of spinning forever.
        if (state is DetailsServicesLoading || !cubit.hasLoaded) {
          return _buildLoadingShimmer(context, isMobile, lightMode);
        }
        if (allEmployees.isEmpty) {
          return _buildEmptyState(context, isMobile, lightMode);
        }
        final List<Map<String, dynamic>> rawStats = allEmployees
            .map(
              (emp) => calculateStatsForEmployee(
                emp,
                cubit.filteredItems,
                pick: context.svcPick,
                departmentName: context.svcDepartmentName,
                parentDuration: createServicesModel.currentDurationOfServices,
                parentDurationUnit:
                    createServicesModel.currentSelectedDurationUnit,
              ),
            )
            .toList();

        // SVC-HOME-18: search, department filter and sort come from the
        // cubit (they used to be applied to the request list instead).
        final statsList = cubit.filterEmployeeStats(
          _sortEmployeeStats(rawStats),
        );

        if (statsList.isEmpty) {
          return _buildEmptyState(context, isMobile, lightMode);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(statsList.length, (index) {
            final providerStats = statsList[index];

            return Padding(
              padding: EdgeInsets.only(bottom: 15.sp),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 15.sp,
                  horizontal: 10.sp,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: index == 0 &&
                          (int.tryParse(
                                    providerStats["done"]?.toString() ?? '0',
                                  ) ??
                                  0) >
                              0
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  children: [
                    if (index < 3 &&
                        (int.tryParse(
                                  providerStats["done"]?.toString() ?? '0',
                                ) ??
                                0) >
                            0)
                      ...[],
                    EmployeeStatsCard(
                      providerStats: providerStats,
                      compact: isMobile,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  List<Map<String, dynamic>> _sortEmployeeStats(
    List<Map<String, dynamic>> stats,
  ) {
    final sortedStats = List<Map<String, dynamic>>.from(stats);

    sortedStats.sort((a, b) {
      final doneA = (a['done'] as int?) ?? 0;
      final doneB = (b['done'] as int?) ?? 0;

      if (doneA != doneB) {
        return doneB.compareTo(doneA);
      }

      final hoursA = (a['hours'] as double?) ?? 0.0;
      final hoursB = (b['hours'] as double?) ?? 0.0;

      if (hoursA != hoursB) {
        return hoursB.compareTo(hoursA);
      }

      final nameA = (a['name'] as String?) ?? '';
      final nameB = (b['name'] as String?) ?? '';

      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });

    return sortedStats;
  }

  Widget _buildLoadingShimmer(
    BuildContext context,
    bool isMobile,
    bool lightMode,
  ) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 15.sp),
          child: Container(
            height: isMobile ? 120.sp : 80.sp,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Shimmer.fromColors(
              baseColor: lightMode
                  ? AppColors.secondaryText.withValues(alpha: 0.3)
                  : AppColors.grey.withValues(alpha: 0.3),
              highlightColor: AppColors.background.withValues(alpha: 0.5),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: lightMode
                      ? AppColors.secondaryText.withValues(alpha: 0.1)
                      : AppColors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isMobile, bool lightMode) {
    return Container(
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          CustomSvgImage.natural(
            assetPath:
                "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
            width: 60.sp,
            height: 60.sp,
            color: AppColors.secondaryText,
          ),
          SizedBox(height: 10.sp),
          Text(
            S.of(context).svcNoEmployeesMatch,
            style: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
