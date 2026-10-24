/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_dashboard.dart
/// Purpose: Provides the mobile layout for the "Qiyas Dashboard", displaying various metrics
///          such as document status, department performance, and digital transformation.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This widget renders the "Qiyas Dashboard" with interactive components like pie charts,
///              bar charts, and dropdowns for filtering. It adapts to different screen sizes (portrait, pages, desktop)
///              to provide a responsive user experience for viewing performance metrics and document status.
/// ********************************************************************* ///
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/pagination_app_bar.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/presentation/controller/qiyas_dashboard_controller_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/utils/time_filter.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions_sections.dart';

import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/data_grc_2/features/dashboard_screens_departments/presentation/UI/widgets/container_filter.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/charts/custom_donut_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_card.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/ui/widgets/qiyas_custom_vision_list.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constants/dashboard_constants.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/presentation/ui/widgets/qiyas_custom_criteria_list.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/presentation/ui/widgets/qiyas_performance_bar.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/presentation/ui/widgets/qiyas_title_status_row.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/presentation/ui/pages/uploaded_document.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_app_dropdown.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';

class QiyasDashboard extends StatelessWidget {
  QiyasDashboard({super.key});
  final bool isUploadDocument =
      Get.find<MainCoreEmployeeController>().isHasPermission(
    module: Modules.qiyas,
    permission: null,
    section: QiyasPermissionsSections.uploadedDocuments,
  );
  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = !kpIsPhoneLayout(context);
    late QiyasDashboardControllerCubit controller =
        QiyasDashboardControllerCubit();

    debugPrint(
        '🟡 [QiyasDashboard] build called | isPortrait=$isPortrait | isTablet=$isTablet');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.only(
              start: isTablet ? 15.sp : 15.sp, end: 15.sp),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaginationAppBar(screensTitles: [
                  'قياس التحول الرقمي',
                  'لوحة المعلومات',
                ]),
                BlocProvider<QiyasDashboardControllerCubit>(
                  create: (_) => controller,
                  child: BlocBuilder<QiyasDashboardControllerCubit,
                      QiyasDashboardControllerState>(
                    bloc: controller,
                    buildWhen: (_, currentState) {
                      debugPrint(
                          '🟡 [QiyasDashboard] OUTER buildWhen: ${currentState.runtimeType}');
                      return currentState
                          is QiyasDashboardControllerLoadedState;
                    },
                    builder: (context, state) {
                      debugPrint(
                          '🟢 [QiyasDashboard] OUTER builder triggered | state=${state.runtimeType}');
                      return Expanded(
                        child: SingleChildScrollView(
                          child: Column(children: [
                            // ==================== PIE CHART SECTION ====================
                            BlocBuilder<QiyasDashboardControllerCubit,
                                QiyasDashboardControllerState>(
                              bloc: controller,
                              buildWhen: (_, state) {
                                debugPrint(
                                    '🟡 [PieChart] buildWhen: ${state.runtimeType}');
                                return state is QiyasDashboardPieChartUpdated;
                              },
                              builder: (context, state) {
                                debugPrint(
                                    '🟢 [PieChart] builder triggered | state=${state.runtimeType}');
                                Map<EvidenceSubmissionStatus, int> statusCount =
                                    controller.getSubmissionStatusCount();
                                debugPrint(
                                    '🟢 [PieChart] statusCount=$statusCount');

                                List<(String, Color, double)> chartData = [];
                                List<double> numberList = [];
                                List<EvidenceSubmissionStatus>
                                    evidenceRateStatus = [];
                                for (var status
                                    in EvidenceSubmissionStatus.values) {
                                  if (statusCount.containsKey(status)) {
                                    evidenceRateStatus.add(status);
                                  }
                                }

                                debugPrint(
                                    '🟢 [PieChart] evidenceRateStatus=${evidenceRateStatus.map((e) => e.value).toList()}');

                                for (var status in evidenceRateStatus) {
                                  numberList.add(
                                      statusCount[status]?.toDouble() ?? 0.0);
                                  chartData.add((
                                    status.value,
                                    status.color,
                                    statusCount[status]?.toDouble() ?? 0.0,
                                  ));
                                }

                                debugPrint(
                                    '🟢 [PieChart] numberList=$numberList');

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isTablet && isUploadDocument)
                                      customButtonWithSvg(
                                        title: "تحميل المستندات الداعمة",
                                        image:
                                            "assets/icons_assets/main_icons_assets/ic_action_download.svg",
                                        function: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return BlocProvider<
                                                QiyasDashboardControllerCubit>.value(
                                              value: controller,
                                              child: UploadedDocument(),
                                            );
                                          }));
                                        },
                                        color: AppColors.primary,
                                        colorBorder: AppColors.transparent,
                                        widthImage: 20.sp,
                                        heightImage: 20.sp,
                                        svgColor: AppColors.textButton,
                                        textStyle: StyleText.fontSize16Weight400
                                            .copyWith(
                                                color: AppColors.textButton,
                                                fontWeight: FontWeight.w400),
                                      ),
                                    if (!isTablet) SizedBox(height: 25.sp),
                                    Row(
                                      children: [
                                        if (isTablet && isUploadDocument)
                                          customButtonWithSvg(
                                            title: "تحميل المستندات الداعمة",
                                            image:
                                                "assets/icons_assets/main_icons_assets/ic_action_download.svg",
                                            function: () {
                                              debugPrint(
                                                  "🟡 [Dashboard] navigation button pressed");
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return BlocProvider<
                                                    QiyasDashboardControllerCubit>.value(
                                                  value: controller,
                                                  child: UploadedDocument(),
                                                );
                                              }));
                                            },
                                            color: AppColors.primary,
                                            colorBorder: AppColors.transparent,
                                            widthImage: 20.sp,
                                            heightImage: 20.sp,
                                            svgColor: AppColors.textButton,
                                            textStyle: StyleText
                                                .fontSize16Weight400
                                                .copyWith(
                                                    color: AppColors.textButton,
                                                    fontWeight:
                                                        FontWeight.w400),
                                          ),
                                        const Expanded(child: SizedBox()),

                                        // ========== TIME FILTER DROPDOWN ==========
                                        SizedBox(
                                          height: 38.sp,
                                          width: 130.sp,
                                          child: AppDropdown(
                                            end: 0,
                                            height: 38.sp,
                                            value: controller.timeFilter,
                                            width: double.infinity,
                                            menuWidth: 130.sp,
                                            fillColor: AppColors.card,
                                            menuItemHeight: 35.sp,
                                            textButton: 'الفتره الزمنية',
                                            isSelectedItemHasBackGround: true,
                                            items: TimeFilter.values
                                                .map((TimeFilter filter) {
                                              bool isSelected =
                                                  controller.timeFilter ==
                                                      filter;
                                              return DropdownMenuItem<
                                                  TimeFilter>(
                                                value: filter,
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 0.w),
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  color: !isSelected
                                                      ? Colors.transparent
                                                      : AppColors.primary,
                                                  child: Text(
                                                    filter.label,
                                                    style: ((isSelected)
                                                        ? StyleText
                                                            .fontSize14Weight600
                                                            .copyWith(
                                                                color: AppColors
                                                                    .textButton)
                                                        : StyleText
                                                            .fontSize14Weight500
                                                            .copyWith(
                                                                color: AppColors
                                                                    .secondaryBlack)),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              debugPrint(
                                                  '🔴 [TimeFilter] onChanged fired | value=${value?.label}');
                                              controller.timeFilter = value!;
                                              controller.updatePieChartData();
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 20.sp),

                                        // ========== DEPARTMENT MULTI-SELECT DROPDOWN ==========
                                        SizedBox(
                                          width: 190.sp,
                                          child: /* MIGRATED 17/10/2026: AppMultiSelectDropdown → CustomMultiSelectFilter (one multi-select for filters) */
                                              CustomMultiSelectFilter<String>(
                                            values: List<String>.from(controller
                                                .selectedDepartmentsFilter),
                                            items: [
                                              for (final String i in controller
                                                  .taskDepartmentNames)
                                                MultiSelectDropdownItem<String>(
                                                    value: i, label: i)
                                            ],
                                            onChanged: multiSelectToggleBridge(
                                                List<String>.from(controller
                                                    .selectedDepartmentsFilter),
                                                (String item) => ((value) {
                                                      debugPrint(
                                                          '🔴 [DepartmentFilter] onChanged fired | value=$value');
                                                      debugPrint(
                                                          '🔴 [DepartmentFilter] selectedDepartmentsFilter BEFORE: ${controller.selectedDepartmentsFilter}');
                                                      controller
                                                          .updateSelectedDepartmentsFilter(
                                                              value);
                                                      debugPrint(
                                                          '🔴 [DepartmentFilter] selectedDepartmentsFilter AFTER: ${controller.selectedDepartmentsFilter}');
                                                    })(item)),
                                            hint: "القسم",
                                            height: 38.sp,
                                            fillColor: AppColors.card,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.sp),
                                    DonutChartCard(
                                        dotIcon:
                                            "assets/icons_assets/main_icons_assets/ic_file_document_description.svg",
                                        title: 'حالة المستندات الداعمة',
                                        centerValue: numberList.isEmpty
                                            ? '0'
                                            : numberList
                                                .reduce((a, b) => a + b)
                                                .toInt()
                                                .toString(),
                                        sections: chartData
                                            .map((e) => ChartData(
                                                label: e.$1,
                                                color: e.$2,
                                                value: e.$3))
                                            .toList()),
                                  ],
                                );
                              },
                            ),

                            SizedBox(height: 10.h),

                            // ==================== BAR CHART SECTION ====================
                            BlocBuilder<QiyasDashboardControllerCubit,
                                QiyasDashboardControllerState>(
                              bloc: controller,
                              buildWhen: (_, currentState) {
                                debugPrint(
                                    '🟡 [BarChart] buildWhen: ${currentState.runtimeType}');
                                return currentState
                                    is QiyasDashboardBarChartUpdated;
                              },
                              builder: (context, state) {
                                debugPrint(
                                    '🟢 [BarChart] builder triggered | state=${state.runtimeType}');
                                Map<String, double> chartData =
                                    controller.getBarChartList();
                                debugPrint(
                                    '🟢 [BarChart] chartData=$chartData');

                                // ✅ FIX: Use controller-level evidenceRateStatus instead of local scope
                                Map<EvidenceSubmissionStatus, int> statusCount =
                                    controller.getSubmissionStatusCount();
                                List<EvidenceSubmissionStatus>
                                    barEvidenceRateStatus = [];
                                for (var status
                                    in EvidenceSubmissionStatus.values) {
                                  if (statusCount.containsKey(status)) {
                                    barEvidenceRateStatus.add(status);
                                  }
                                }

                                debugPrint(
                                    '🟢 [BarChart] barEvidenceRateStatus=${barEvidenceRateStatus.map((e) => e.value).toList()}');
                                debugPrint(
                                    '🟢 [BarChart] current submissionStatusFilter=${controller.submissionStatusFilter.value}');

                                return BarChartCard(
                                  title: "معدل مستندات",
                                  dotIcon:
                                      'assets/icons_assets/main_icons_assets/ic_chart_line_solid.svg',
                                  barColor: AppColors.primary,
                                  chartHeight: 300.h,
                                  barWidth: 30,
                                  trailing: Row(
                                    children: [
                                      SizedBox(
                                        height: 38.sp,
                                        width: 150.sp,
                                        child: AppDropdown(
                                          height: 38.sp,
                                          value:
                                              controller.submissionStatusFilter,
                                          width: double.infinity,
                                          menuWidth: 150.sp,
                                          fillColor: AppColors.background,
                                          menuItemHeight: 35.sp,
                                          textButton: 'حالة',
                                          isSelectedItemHasBackGround: true,
                                          items: barEvidenceRateStatus.map(
                                              (EvidenceSubmissionStatus
                                                  status) {
                                            bool isSelected = controller
                                                    .submissionStatusFilter ==
                                                status;
                                            return DropdownMenuItem<
                                                EvidenceSubmissionStatus>(
                                              value: status,
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.w),
                                                width: double.infinity,
                                                height: double.infinity,
                                                color: !isSelected
                                                    ? Colors.transparent
                                                    : AppColors.primary,
                                                child: Text(
                                                  status.value,
                                                  style: ((isSelected)
                                                      ? StyleText
                                                          .fontSize14Weight600
                                                          .copyWith(
                                                              color: AppColors
                                                                  .textButton)
                                                      : StyleText
                                                          .fontSize14Weight500
                                                          .copyWith(
                                                              color: AppColors
                                                                  .secondaryBlack)),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            debugPrint(
                                                '🔴 [BarChartFilter] onChanged fired | value=${value?.value}');
                                            controller.submissionStatusFilter =
                                                value!;
                                            controller.updateBarChartData();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  // BarChartCard does not reorder its input, so
                                  // the Arabic month sort that VerticalBarChart
                                  // used to apply internally is done here.
                                  bars: _barsSortedByMonth(chartData),
                                );
                              },
                            ),

                            SizedBox(height: 10.sp),

                            // ==================== DEPARTMENT PERFORMANCE SECTION ====================
                            Container(
                                padding: EdgeInsets.all(15.sp),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: AppColors.card,
                                ),
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  debugPrint(
                                      '🟢 [DeptPerformance] LayoutBuilder triggered');
                                  var deptData =
                                      controller.getEachDepartmentTasksStatus();
                                  debugPrint(
                                      '🟢 [DeptPerformance] departments count=${deptData.length}');

                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: AppColors.primary,
                                            radius: 20.r,
                                            child: Padding(
                                              padding: EdgeInsets.all(4.sp),
                                              child: SvgPicture.asset(
                                                  "assets/icons_assets/main_icons_assets/ic_dashboard_departments.svg",
                                                  height: 20.sp,
                                                  width: 20.sp,
                                                  colorFilter: ColorFilter.mode(
                                                      AppColors.textButton,
                                                      BlendMode.srcIn)),
                                            ),
                                          ),
                                          SizedBox(width: 10.sp),
                                          Text(
                                            "أداء الاقسم",
                                            style:
                                                StyleText.fontSize16Weight500,
                                          ),
                                          if (isTablet) Spacer(),
                                          if (isTablet)
                                            departmentStatusLegend(
                                                isPortrait, isTablet)
                                        ],
                                      ),
                                      if (!isTablet)
                                        Column(
                                          children: [
                                            SizedBox(height: 10.sp),
                                            SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: departmentStatusLegend(
                                                    isPortrait, isTablet)),
                                          ],
                                        ),
                                      SizedBox(height: 20.sp),
                                      for (DepartmentPerformance dept
                                          in deptData)
                                        QiyasPerformanceBar(
                                          width: double.infinity,
                                          dept: dept,
                                          value: dept.values
                                              .reduce((a, b) => a + b),
                                        ),
                                    ],
                                  );
                                })),

                            SizedBox(height: 25.sp),

                            // ==================== TABS SECTION (المناظير) ====================
                            Container(
                                padding: EdgeInsets.all(15.sp),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: AppColors.card,
                                ),
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  return Column(
                                    children: [
                                      BlocBuilder<QiyasDashboardControllerCubit,
                                              QiyasDashboardControllerState>(
                                          bloc: controller,
                                          buildWhen: (_, currentState) {
                                            debugPrint(
                                                '🟡 [Tabs] buildWhen: ${currentState.runtimeType}');
                                            return currentState
                                                is QiyasDashboardTabsSelectedState;
                                          },
                                          builder: (_, state) {
                                            debugPrint(
                                                '🟢 [Tabs] builder triggered | isTabsSelected=${controller.isTabsSelected}');
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          AppColors.primary,
                                                      radius: 20.sp,
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            4.sp),
                                                        child: SvgPicture.asset(
                                                          "assets/icons_assets/main_icons_assets/ic_chart.svg",
                                                          height: 20.sp,
                                                          width: 20.sp,
                                                          colorFilter:
                                                              ColorFilter.mode(
                                                                  AppColors
                                                                      .textButton,
                                                                  BlendMode
                                                                      .srcIn),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10.sp),
                                                    Text(
                                                      "المناظير",
                                                      style: StyleText
                                                          .fontSize16Weight500,
                                                    ),
                                                    Spacer(),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                          height: 40.sp,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: AppColors
                                                                  .background),
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          child: Row(
                                                            children: [
                                                              ContainerFiltered(
                                                                backgroundColor:
                                                                    AppColors
                                                                        .background,
                                                                horizontalPadding:
                                                                    8,
                                                                onTap: () {
                                                                  debugPrint(
                                                                      '🔴 [Tabs] المنظور tapped');
                                                                  controller
                                                                      .isTabsSelectedState(
                                                                          true);
                                                                },
                                                                isSelcted:
                                                                    controller
                                                                        .isTabsSelected,
                                                                title:
                                                                    "المنظور",
                                                              ),
                                                              SizedBox(
                                                                  width: 10.sp),
                                                              ContainerFiltered(
                                                                backgroundColor:
                                                                    AppColors
                                                                        .background,
                                                                horizontalPadding:
                                                                    8,
                                                                onTap: () {
                                                                  debugPrint(
                                                                      '🔴 [Tabs] المعيار tapped');
                                                                  controller
                                                                      .isTabsSelectedState(
                                                                          false);
                                                                },
                                                                isSelcted:
                                                                    !controller
                                                                        .isTabsSelected,
                                                                title:
                                                                    "المعيار",
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 20.sp),
                                                if (controller.isTabsSelected)
                                                  QiyasCustomVisionList(
                                                    isDashBoard: true,
                                                    isClickable: true,
                                                  ),
                                                if (!controller.isTabsSelected)
                                                  QiyasCustomCriteriaList(),
                                              ],
                                            );
                                          })
                                    ],
                                  );
                                })),
                            SizedBox(height: 10.sp),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row departmentStatusLegend(bool isPortrait, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 15.sp,
      children: [
        for (int i = 0; i < departmentStatus.length; i++)
          Row(
            children: [
              QiyasTitleStatusRow(
                dataColor: departmentStatus[i].color,
                textData: departmentStatus[i].value,
              ),
            ],
          ),
      ],
    );
  }
}

/// Arabic calendar month order, preserved from the retired VerticalBarChart
/// widget which sorted its input internally. BarChartCard renders bars in the
/// order given, so the sort is applied here instead.
const List<String> _arabicMonthOrder = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

List<ChartData> _barsSortedByMonth(Map<String, double> data) {
  final ordered = <ChartData>[];
  for (final month in _arabicMonthOrder) {
    if (data.containsKey(month)) {
      ordered.add(ChartData(label: month, value: data[month]!));
    }
  }
  // No recognised month labels → fall back to the map's own order.
  if (ordered.isEmpty) {
    return data.entries
        .map((e) => ChartData(label: e.key, value: e.value))
        .toList();
  }
  return ordered;
}
