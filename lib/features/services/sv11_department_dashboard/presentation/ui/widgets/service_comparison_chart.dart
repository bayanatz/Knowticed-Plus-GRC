/// Module: services / sv11_department_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: service_comparison_chart.dart
/// Purpose: The monthly comparison card of the department dashboard —
///          cancelled vs rejected requests per month, with a service
///          filter. Data comes from ServiceComparisonCubit; the bars are
///          drawn by ServiceComparisonBars.
/// Author: Amr Mesbah
/// Created At: 17/01/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/services_load_error.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/controller/service_comparison_cubit.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/controller/service_comparison_state.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/ui/widgets/service_comparison_bars.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class ServiceComparisonChart extends StatelessWidget {
  final bool lightMode;

  const ServiceComparisonChart({super.key, required this.lightMode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceComparisonCubit(
        repository: context.read<CreateServicesRepository>(),
      ),
      child: _ServiceComparisonCard(lightMode: lightMode),
    );
  }
}

class _ServiceComparisonCard extends StatefulWidget {
  final bool lightMode;

  const _ServiceComparisonCard({required this.lightMode});

  @override
  State<_ServiceComparisonCard> createState() => _ServiceComparisonCardState();
}

class _ServiceComparisonCardState extends State<_ServiceComparisonCard> {
  String? _selectedServiceName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final departments = context.read<MainCoreDepartmentCubit>();
    final employees = AppControllers.employee;
    final departmentId = employees.employeeEntity?.departmentId;
    final departmentName = (departmentId == null || departmentId.isEmpty)
        ? null
        : departments.getDepartmentName(departmentId, true);
    context.read<ServiceComparisonCubit>().loadData(
          departmentController: departments,
          employeeController: employees,
          userDepartmentName: departmentName,
          selectedServiceName: _selectedServiceName,
        );
  }

  void _selectService(String value) {
    setState(() => _selectedServiceName = value);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceComparisonCubit, ServiceComparisonState>(
      builder: (context, state) {
        final data = state is ServiceComparisonLoaded
            ? state.data
            : const ServiceComparisonData();
        final isPhone = context.isPhone;
        final filter = _ServiceFilter(
          services: context.svcIsArabic
              ? data.allServicesArabic
              : data.allServicesEnglish,
          value: _selectedServiceName,
          onChanged: _selectService,
          showChevron: isPhone,
        );

        return Container(
          padding: EdgeInsetsDirectional.only(
            top: 15.sp,
            start: 15.w,
            end: 15.w,
            bottom: 10.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _Header(data: data)),
                  if (!isPhone)
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * .25,
                      child: filter,
                    ),
                ],
              ),
              if (isPhone) ...[
                SizedBox(height: 10.sp),
                // The filter is the only control on its row on a phone.
                SizedBox(width: double.infinity, child: filter),
              ],
              SizedBox(height: 20.sp),
              switch (state) {
                ServiceComparisonLoading() => SizedBox(
                    height: 300.h,
                    child: const Center(child: CircleProgressMaster()),
                  ),
                ServiceComparisonError() => ServicesLoadError(onRetry: _load),
                _ => SizedBox(
                    height: 200.h,
                    child: ServiceComparisonBars(
                      monthlyData: data.monthlyData,
                      lightMode: widget.lightMode,
                    ),
                  ),
              },
            ],
          ),
        );
      },
    );
  }
}

/// Title and the two legend keys with this year's totals.
class _Header extends StatelessWidget {
  final ServiceComparisonData data;

  const _Header({required this.data});

  int _total(String key) =>
      data.monthlyData.values.fold(0, (sum, month) => sum + (month[key] ?? 0));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 26.sp,
              height: 26.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: Center(
                child: CustomSvgImage.natural(
                  assetPath:
                      'assets/icons_assets/main_icons_assets/ic_module_support_headset.svg',
                  width: 16.sp,
                  height: 16.sp,
                  color: AppColors.textButton,
                ),
              ),
            ),
            SizedBox(width: 8.sp),
            Expanded(
              child: Text(
                S.of(context).monthlyComparison,
                style: StyleText.fontSize14Weight600.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.sp),
        Wrap(
          spacing: 12.w,
          runSpacing: 8.h,
          children: [
            _LegendKey(
              color: AppColors.orange,
              label:
                  '${S.of(context).Canceled}: ${context.svcNumber(_total(ServiceComparisonData.canceledKey))}',
            ),
            _LegendKey(
              color: AppColors.block,
              label:
                  '${S.of(context).Rejected}: ${context.svcNumber(_total(ServiceComparisonData.rejectedKey))}',
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendKey extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendKey({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.sp,
          height: 12.sp,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

/// Service filter; an empty key means every service.
class _ServiceFilter extends StatelessWidget {
  final List<String> services;
  final String? value;
  final ValueChanged<String> onChanged;
  final bool showChevron;

  const _ServiceFilter({
    required this.services,
    required this.value,
    required this.onChanged,
    required this.showChevron,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<String>(
      value: value,
      items: [
        DropdownItem<String>(value: '', label: S.of(context).all_services),
        for (final name in services)
          DropdownItem<String>(value: name, label: name),
      ],
      onChanged: onChanged,
      hint: S.of(context).select_service,
      hintStyle: StyleText.fontSize12Weight400.copyWith(
        color: AppColors.secondaryText,
      ),
      label: S.of(context).service,
      suffixIcon: showChevron
          ? CustomSvgImage(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_nav_chevron_down.svg',
              width: 20.sp,
              height: 20.sp,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                AppColors.text.withValues(alpha: 0.6),
                BlendMode.srcIn,
              ),
            )
          : null,
    );
  }
}
