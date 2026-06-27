import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:demo_app/core/helper/todo_new_module/core_widgets/main_widget/custom_drop_down.dart';
import 'package:demo_app/core/helper/todo_new_module/core_widgets/grc/drop_down.dart';
import '../../../../../../../../../knowledge_hub_module/core/custom_buttons.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import '../../../../../../core/custom_widgets/SideFrameMaster.dart';
import 'package:demo_app/core/helper/todo_new_module/external/tasks_module/category/presentation/screens/to_do_list/details_screen/hr_module/HR_dashBoard_widget.dart';

import 'hr_employee.dart';

class ResponsiveHelper {
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1000;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= mobileMaxWidth;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > mobileMaxWidth &&
          MediaQuery.of(context).size.width <= tabletMaxWidth;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > tabletMaxWidth;
}

class HrDashboard extends StatefulWidget {
  const HrDashboard({super.key});

  @override
  State<HrDashboard> createState() => _HrDashboardState();
}

class _HrDashboardState extends State<HrDashboard> {
  String? _selectedLocation;
  String? _selectedDepartment;
  String? _selectedAttendanceRequests;
  String? _selectedAttendanceStatus;
  bool _isEmploymentMonthly = true;

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      body: SideFrameMaster(
        titleText: "Human Resources",
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP BUTTONS AND DROPDOWNS
              _buildTopSection(isMobile, isTablet),
              SizedBox(height: 15.h),

              // OVERALL SECTION
              _buildOverallSection(isMobile, isTablet),
              SizedBox(height: 15.h),

              // GENDER & MARITAL STATUS PIE CHARTS
              _buildPieChartsRow(
                isMobile: isMobile,
                isTablet: isTablet,
                charts: [
                  CustomPieChartWithLabelsWidget(
                    title: 'Gender',
                    iconAsset: 'assets/hrAsset/Mask group.svg',
                    totalValue: '9K',
                    totalLabel: 'Total',
                    data: [
                      ChartDataItem(
                        label: 'Male',
                        color: const Color(0xFFFFDE59),
                        value: 513,
                      ),
                      ChartDataItem(
                        label: 'Female',
                        color: const Color(0xFF6B6B6B),
                        value: 513,
                      ),
                    ],
                    valueLabels: const ['513', '513'],
                    lightMode: false,
                    height: isMobile ? 220.h : 250.h,
                  ),
                  CustomPieChartWithLabelsWidget(
                    title: 'Marital Status',
                    iconAsset: 'assets/hrAsset/Mask group.svg',
                    totalValue: '9K',
                    totalLabel: 'Total',
                    data: [
                      ChartDataItem(
                        label: 'Single',
                        color: const Color(0xFFFFDE59),
                        value: 513,
                      ),
                      ChartDataItem(
                        label: 'Married',
                        color: const Color(0xFF6B6B6B),
                        value: 513,
                      ),
                      ChartDataItem(
                        label: 'Divorced',
                        color: const Color(0xFFD9D9D9),
                        value: 513,
                      ),
                      ChartDataItem(
                        label: 'Widowed',
                        color: const Color(0xFF4A4A4A),
                        value: 513,
                      ),
                    ],
                    valueLabels: const ['513', '513', '513', '513'],
                    lightMode: false,
                    height: isMobile ? 220.h : 250.h,
                  ),
                ],
              ),
              SizedBox(height: 15.h),

              // AGE & EXPERIENCE STATS
              _buildMinAvgMaxRow(isMobile, isTablet),
              SizedBox(height: 30.h),

              // BAR CHARTS
              CustomVerticalBarChartWidget(
                title: 'Employees Per Location',
                iconAsset: 'assets/hrAsset/g19.svg',
                labels: const ['Office', 'Office-2'],
                values: const [220, 410],
                height: isMobile ? 300 : 500,
                lightMode: false,
                showValuesOnBars: true,
              ),
              SizedBox(height: 15.h),

              CustomVerticalBarChartWidget(
                title: 'Nationalities',
                iconAsset: 'assets/hrAsset/Group.svg',
                labels: const [
                  'Egypt',
                  'Egypt',
                  'Egypt',
                  'Egypt',
                  'Egypt',
                  'Egypt'
                ],
                values: const [220, 410, 366, 282, 49, 79],
                height: isMobile ? 300 : 500,
                lightMode: false,
                showValuesOnBars: true,
              ),
              SizedBox(height: 15.h),

              CustomVerticalBarChartWidget(
                title: 'Department Employees',
                iconAsset: 'assets/hrAsset/Transmission.svg',
                labels: const ['Marketing', 'HR', 'HR', 'HR', 'HR', 'HR'],
                values: const [220, 410, 366, 282, 49, 79],
                height: isMobile ? 300 : 500,
                lightMode: false,
                showValuesOnBars: true,
              ),
              SizedBox(height: 25.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: isMobile ? 120.w : 100.w,
                    child: CustomDropdownFormField(
                      dropdownColor: AppColors.card,
                      selectedValue: _selectedAttendanceRequests,
                      items: const [
                        {'key': 'all', 'value': 'All Requests'},
                        {'key': 'pending', 'value': 'Pending'},
                        {'key': 'approved', 'value': 'Approved'},
                        {'key': 'rejected', 'value': 'Rejected'},
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedAttendanceRequests = value;
                        });
                      },
                      widthIcon: 12,
                      heightIcon: 12,
                      hint: Text(
                        'Requests',
                        style: (isMobile
                            ? AppTextStyles.font12BlackCairoRegular
                            : AppTextStyles.font14BlackCairoRegular)
                            .copyWith(
                          color: AppColors.text,
                        ),
                      ),
                      height: 36,
                    ),
                  ),
                  SizedBox(width: isMobile ? 8.w : 12.w),
                  SizedBox(
                    width: isMobile ? 120.w : 100.w,
                    child: CustomDropdownFormField(
                      dropdownColor: AppColors.card,
                      selectedValue: _selectedAttendanceStatus,
                      items: const [
                        {'key': 'all', 'value': 'All Status'},
                        {'key': 'present', 'value': 'Present'},
                        {'key': 'absent', 'value': 'Absent'},
                        {'key': 'late', 'value': 'Late'},
                        {'key': 'leave', 'value': 'On Leave'},
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedAttendanceStatus = value;
                        });
                      },
                      widthIcon: 12,
                      heightIcon: 12,
                      hint: Text(
                        'Status',
                        style: (isMobile
                            ? AppTextStyles.font12BlackCairoRegular
                            : AppTextStyles.font14BlackCairoRegular)
                            .copyWith(
                          color: AppColors.text,
                        ),
                      ),
                      height: 36,
                    ),
                  ),
                ],
              ),
              CustomVerticalBarChartWidget(
                title: 'Attendance Tracking',
                iconAsset: 'assets/hrAsset/hrattendanceTracking.svg',
                labels: const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                values: const [220, 410, 366, 282, 49, 79],
                height: isMobile ? 300 : 500,
                lightMode: false,
                showValuesOnBars: true,
                headerWidget:null
              ),
              SizedBox(height: 15.h),

              CustomVerticalBarChartWidget(
                title: 'Employment Statistics',
                iconAsset: 'assets/hrAsset/Mask group.svg',
                labels: const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                values: const [220, 410, 366, 282, 49, 79],
                height: isMobile ? 300 : 500,
                lightMode: false,
                showValuesOnBars: true,
                headerWidget: _buildEmploymentHeader(isMobile, isTablet),
              ),
              SizedBox(height: 15.h),

              // WORKFORCE & STATUS PIE CHARTS
              _buildPieChartsRow(
                isMobile: isMobile,
                isTablet: isTablet,
                charts: [
                  CustomPieChartWithLabelsWidget(
                    title: 'Workforce',
                    iconAsset: 'assets/hrAsset/Mask group.svg',
                    totalValue: '9K',
                    totalLabel: 'Total',
                    data: [
                      ChartDataItem(
                        label: 'Employee',
                        color: const Color(0xFFFFD452),
                        value: 513,
                      ),
                      ChartDataItem(
                        label: 'Interns',
                        color: const Color(0xFF6B6B6B),
                        value: 513,
                      ),
                      ChartDataItem(
                        label: 'Contractors',
                        color: const Color(0xFFD9D9D9),
                        value: 513,
                      ),
                    ],
                    valueLabels: const ['513', '513', '513'],
                    lightMode: false,
                    height: isMobile ? 220.h : 250.h,
                  ),
                  CustomPieChartWithLabelsWidget(
                    title: 'Status',
                    iconAsset: 'assets/hrAsset/Mask group.svg',
                    totalValue: '9K',
                    totalLabel: 'Total',
                    data: [
                      ChartDataItem(
                        label: 'Remote',
                        color: const Color(0xFFFFD452),
                        value: 513,
                      ),
                      ChartDataItem(
                        label: 'On Site',
                        color: const Color(0xFF6B6B6B),
                        value: 513,
                      ),
                    ],
                    valueLabels: const ['513', '513'],
                    lightMode: false,
                    height: isMobile ? 220.h : 250.h,
                  ),
                ],
              ),
              SizedBox(height: 15.h),

              // ACTIVE/INACTIVE & FULL/PART TIME
              _buildPieChartsRow(
                isMobile: isMobile,
                isTablet: isTablet,
                charts: [
                  CustomPieChartWithLabelsWidget(
                    title: 'Status',
                    iconAsset: 'assets/hrAsset/Mask group.svg',
                    totalValue: '9K',
                    totalLabel: 'Total',
                    data: [
                      ChartDataItem(
                        label: 'Active',
                        color: const Color(0xFFFFD452),
                        value: 513,
                      ),
                      ChartDataItem(
                        label: 'Inactive',
                        color: const Color(0xFF6B6B6B),
                        value: 513,
                      ),
                    ],
                    valueLabels: const ['513', '513'],
                    lightMode: false,
                    height: isMobile ? 220.h : 250.h,
                  ),
                  CustomPieChartWithLabelsWidget(
                    title: 'Status',
                    iconAsset: 'assets/hrAsset/Mask group.svg',
                    totalValue: '9K',
                    totalLabel: 'Total',
                    data: [
                      ChartDataItem(
                        label: 'Full Time',
                        color: const Color(0xFFFFD452),
                        value: 513,
                      ),
                      ChartDataItem(
                        label: 'Part Time',
                        color: const Color(0xFF6B6B6B),
                        value: 513,
                      ),
                    ],
                    valueLabels: const ['513', '513'],
                    lightMode: false,
                    height: isMobile ? 220.h : 250.h,
                  ),
                ],
              ),
              SizedBox(height: 15.h),

              CustomVerticalBarChartWidget(
                title: 'Job Grade',
                iconAsset: 'assets/hrAsset/Mask group.svg',
                labels: const [
                  'Interns',
                  'Juniors',
                  'Mid',
                  'Senoirs',
                  'Lead',
                  'Managers',
                  'Exceutive'
                ],
                values: const [220, 410, 366, 282, 49, 79, 79],
                height: isMobile ? 300 : 500,
                lightMode: false,
                showValuesOnBars: true,
              ),
              SizedBox(height: 15.h),

              CustomVerticalBarChartWidget(
                title: 'Absence',
                iconAsset: 'assets/hrAsset/Mask group.svg',
                labels: const [
                  'Marketing',
                  'Marketing',
                  'Marketing',
                  'Marketing'
                ],
                values: const [220, 410, 366, 282],
                height: isMobile ? 300 : 500,
                lightMode: false,
                showValuesOnBars: true,
              ),
              SizedBox(height: 15.h),

              CustomVerticalBarChartWidget(
                title: 'Average Salary by Department',
                iconAsset: 'assets/hrAsset/Mask group.svg',
                labels: const [
                  'Marketing',
                  'Marketing',
                  'Marketing',
                  'Marketing',
                  'Marketing'
                ],
                values: const [220, 410, 366, 282, 49],
                height: isMobile ? 300 : 500,
                lightMode: false,
                showValuesOnBars: true,
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  // TOP SECTION - BUTTONS AND DROPDOWNS
  Widget _buildTopSection(bool isMobile, bool isTablet) {
    if (isMobile) {
      return Column(
        children: [
          // First Row: Employees and Departments buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              customButtonWithImage(
                title: 'Employees',
                function: () {},
                textStyle: AppTextStyles.font14BlackCairoMedium.copyWith(
                  color: AppColors.textButton,
                ),
                width: 135.w,
                height: 38.h,
                space: 6.w,
                radius: 8.r,
                color: AppColors.primary,
                image: 'assets/hrAsset/hrEmployeeButton.svg',
                widthImage: 20.sp,
                heightImage: 18.sp,
                colorBorder: Colors.transparent,
                svgColor: AppColors.textButton,
              ),
              customButtonWithImage(
                title: 'Departments',
                function: () {},
                textStyle: AppTextStyles.font14BlackCairoMedium.copyWith(
                  color: AppColors.textButton,
                ),
                width: 135.w,
                height: 38.h,
                space: 4.w,
                radius: 8.r,
                color: AppColors.primary,
                image: 'assets/hrAsset/hrDepartments.svg',
                widthImage: 20.sp,
                heightImage: 18.sp,
                colorBorder: Colors.transparent,
                svgColor: AppColors.textButton,
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Second Row: Requests button (centered)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              customButtonWithImage(
                title: 'Requests',
                function: () {},
                textStyle: AppTextStyles.font14BlackCairoMedium.copyWith(
                  color: AppColors.textButton,
                ),
                width: 135.w,
                height: 38.h,
                space: 8.w,
                radius: 8.r,
                color: AppColors.primary,
                image: 'assets/hrAsset/hrRequestsButton.svg',
                widthImage: 20.sp,
                heightImage: 18.sp,
                colorBorder: Colors.transparent,
                svgColor: AppColors.textButton,
              ),
            ],
          ),
          SizedBox(height: 15.h),

          // Third Row: Location and Department dropdowns
          Row(
            children: [
              Expanded(
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.card,
                  selectedValue: _selectedLocation,
                  items: const [
                    {'key': 'all', 'value': 'All Locations'},
                    {'key': 'office1', 'value': 'Office 1'},
                    {'key': 'office2', 'value': 'Office 2'},
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedLocation = value;
                    });
                  },
                  widthIcon: 12,
                  heightIcon: 12,
                  hint: Text(
                    'Location',
                    style: AppTextStyles.font14BlackCairoRegular.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  height: 40,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.card,
                  selectedValue: _selectedDepartment,
                  items: const [
                    {'key': 'all', 'value': 'All Departments'},
                    {'key': 'hr', 'value': 'HR'},
                    {'key': 'marketing', 'value': 'Marketing'},
                    {'key': 'it', 'value': 'IT'},
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartment = value;
                    });
                  },
                  widthIcon: 12,
                  heightIcon: 12,
                  hint: Text(
                    'Department',
                    style: AppTextStyles.font14BlackCairoRegular.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  height: 40,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Tablet & Desktop
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            customButtonWithImage(
              title: 'Employees',
              function: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_){
                  return HrEmployeeScreen();
                }));
              },
              textStyle: (isTablet
                  ? AppTextStyles.font14BlackCairoMedium
                  : AppTextStyles.font16BlackMediumCairo)
                  .copyWith(
                color: AppColors.textButton,
              ),
              width: 150.w,
              height: 38.h,
              space: 8.w,
              radius: 8.r,
              color: AppColors.primary,
              image: 'assets/hrAsset/hrEmployeeButton.svg',
              widthImage: isTablet ? 20.sp : 24.sp,
              heightImage: isTablet ? 18.sp : 22.sp,
              colorBorder: Colors.transparent,
              svgColor: AppColors.textButton,
            ),
            SizedBox(width: 15.w),
            customButtonWithImage(
              title: 'Departments',
              function: () {},
              textStyle: (isTablet
                  ? AppTextStyles.font14BlackCairoMedium
                  : AppTextStyles.font16BlackMediumCairo)
                  .copyWith(
                color: AppColors.textButton,
              ),
              width: 150.w,
              height: 38.h,
              space: 4.w,
              radius: 8.r,
              color: AppColors.primary,
              image: 'assets/hrAsset/hrDepartments.svg',
              widthImage: isTablet ? 20.sp : 24.sp,
              heightImage: isTablet ? 18.sp : 22.sp,
              colorBorder: Colors.transparent,
              svgColor: AppColors.textButton,
            ),
            SizedBox(width: 15.w),
            customButtonWithImage(
              title: 'Requests',
              function: () {},
              textStyle: (isTablet
                  ? AppTextStyles.font14BlackCairoMedium
                  : AppTextStyles.font16BlackMediumCairo)
                  .copyWith(
                color: AppColors.textButton,
              ),
              width: 150.w,
              height: 38.h,
              space: 8.w,
              radius: 8.r,
              color: AppColors.primary,
              image: 'assets/hrAsset/hrRequestsButton.svg',
              widthImage: isTablet ? 20.sp : 24.sp,
              heightImage: isTablet ? 18.sp : 22.sp,
              colorBorder: Colors.transparent,
              svgColor: AppColors.textButton,
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: isTablet ? 180.w : 200.w,
              child: CustomDropdownFormField(
                dropdownColor: AppColors.card,
                selectedValue: _selectedLocation,
                items: const [
                  {'key': 'all', 'value': 'All Locations'},
                  {'key': 'office1', 'value': 'Office 1'},
                  {'key': 'office2', 'value': 'Office 2'},
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value;
                  });
                },
                widthIcon: 12,
                heightIcon: 12,
                hint: Text(
                  'Location',
                  style: AppTextStyles.font14BlackCairoRegular.copyWith(
                    color: AppColors.text,
                  ),
                ),
                height: 40,
              ),
            ),
            SizedBox(width: 12.w),
            SizedBox(
              width: isTablet ? 180.w : 200.w,
              child: CustomDropdownFormField(
                dropdownColor: AppColors.card,
                selectedValue: _selectedDepartment,
                items: const [
                  {'key': 'all', 'value': 'All Departments'},
                  {'key': 'hr', 'value': 'HR'},
                  {'key': 'marketing', 'value': 'Marketing'},
                  {'key': 'it', 'value': 'IT'},
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDepartment = value;
                  });
                },
                widthIcon: 12,
                heightIcon: 12,
                hint: Text(
                  'Department',
                  style: AppTextStyles.font14BlackCairoRegular.copyWith(
                    color: AppColors.text,
                  ),
                ),
                height: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // OVERALL SECTION
  Widget _buildOverallSection(bool isMobile, bool isTablet) {
    if (isMobile) {
      return Container(
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall',
              style: AppTextStyles.font20BlackCairoMedium.copyWith(
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),

            // Row 1: Total Employee & New Joiners
            Row(
              children: [
                Expanded(
                  child: _buildStatCardContent(
                    icon: 'assets/hrAsset/hrTotalemployee.svg',
                    label: 'Total Employee',
                    value: '11',
                    labelColor: AppColors.text,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatCardContent(
                    icon: 'assets/hrAsset/hrNewJoiners.svg',
                    label: 'New Joiners',
                    value: '11',
                    labelColor: Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Row 2: Upcoming Leave & Departments
            Row(
              children: [
                Expanded(
                  child: _buildStatCardContent(
                    icon: 'assets/hrAsset/hrUpcommingLeave.svg',
                    label: 'Upcoming Leave',
                    value: '11',
                    labelColor: Colors.red,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatCardContent(
                    icon: 'assets/hrAsset/hrDepartments.svg',
                    label: 'Departments',
                    value: '11',
                    labelColor: Colors.yellow,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Row 3: Attendance Compliance (full width)
            _buildStatCardContent(
              icon: 'assets/hrAsset/hrDepartments.svg',
              label: 'Attendance Compliance',
              value: '11',
              labelColor: Colors.yellow,
            ),
          ],
        ),
      );
    }

    // Tablet & Desktop
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall',
            style: AppTextStyles.font22BlackCairoSemiBold.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCardContent(
                  icon: 'assets/hrAsset/hrTotalemployee.svg',
                  label: 'Total Employee',
                  value: '11',
                  labelColor: AppColors.text,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCardContent(
                  icon: 'assets/hrAsset/hrNewJoiners.svg',
                  label: 'New Joiners',
                  value: '11',
                  labelColor: Colors.red,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCardContent(
                  icon: 'assets/hrAsset/hrUpcommingLeave.svg',
                  label: 'Upcoming Leave',
                  value: '11',
                  labelColor: Colors.red,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCardContent(
                  icon: 'assets/hrAsset/hrDepartments.svg',
                  label: 'Departments',
                  value: '11',
                  labelColor: Colors.yellow,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCardContent(
                  icon: 'assets/hrAsset/hrDepartments.svg',
                  label: 'Attendance Compliance',
                  value: '11',
                  labelColor: Colors.yellow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // PIE CHARTS ROW
  Widget _buildPieChartsRow({
    required bool isMobile,
    required bool isTablet,
    required List<Widget> charts,
  }) {
    if (isMobile) {
      return Column(
        children: charts.map((chart) {
          return Padding(
            padding: EdgeInsets.only(bottom: 15.h),
            child: chart,
          );
        }).toList(),
      );
    }

    return Row(
      children: charts.asMap().entries.map((entry) {
        final index = entry.key;
        return Expanded(
          child: Padding(
            padding:
            EdgeInsets.only(right: index < charts.length - 1 ? 15.w : 0),
            child: entry.value,
          ),
        );
      }).toList(),
    );
  }

  // MIN/AVG/MAX ROW
  Widget _buildMinAvgMaxRow(bool isMobile, bool isTablet) {
    final cards = [
      _buildMinAvgMaxCard(
        icon: 'assets/hrAsset/Mask group.svg',
        title: 'Age',
        minimum: '22',
        average: '31',
        maximum: '58',
      ),
      _buildMinAvgMaxCard(
        icon: 'assets/hrAsset/Mask group.svg',
        title: 'Experience In The Organization',
        minimum: '22',
        average: '31',
        maximum: '58',
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          cards[0],
          SizedBox(height: 15.h),
          cards[1],
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        SizedBox(width: 15.w),
        Expanded(child: cards[1]),
      ],
    );
  }


// ATTENDANCE HEADER
  Widget _buildAttendanceHeader(bool isMobile, bool isTablet) {
    // Always show in row format for all screen sizes
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: isMobile ? 120.w : 100.w,
          child:
          CustomDropdownFormField(
            dropdownColor: AppColors.background,
            selectedValue: _selectedAttendanceRequests,
            items: const [
              {'key': 'all', 'value': 'All Requests'},
              {'key': 'pending', 'value': 'Pending'},
              {'key': 'approved', 'value': 'Approved'},
              {'key': 'rejected', 'value': 'Rejected'},
            ],
            onChanged: (value) {
              setState(() {
                _selectedAttendanceRequests = value;
              });
            },
            widthIcon: 12,
            heightIcon: 12,
            hint: Text(
              'Requests',
              style: (isMobile
                  ? AppTextStyles.font12BlackCairoRegular
                  : AppTextStyles.font14BlackCairoRegular).copyWith(
                color: AppColors.text,
              ),
            ),
            height: 36,
          ),
        ),
        SizedBox(width: isMobile ? 8.w : 12.w),
        SizedBox(
          width: isMobile ? 120.w : 100.w,
          child: CustomDropdownFormField(
            dropdownColor: AppColors.background,
            selectedValue: _selectedAttendanceStatus,
            items: const [
              {'key': 'all', 'value': 'All Status'},
              {'key': 'present', 'value': 'Present'},
              {'key': 'absent', 'value': 'Absent'},
              {'key': 'late', 'value': 'Late'},
              {'key': 'leave', 'value': 'On Leave'},
            ],
            onChanged: (value) {
              setState(() {
                _selectedAttendanceStatus = value;
              });
            },
            widthIcon: 12,
            heightIcon: 12,
            hint: Text(
              'Status',
              style: (isMobile
                  ? AppTextStyles.font12BlackCairoRegular
                  : AppTextStyles.font14BlackCairoRegular).copyWith(
                color: AppColors.text,
              ),
            ),
            height: 36,
          ),
        ),
      ],
    );
  }

  // EMPLOYMENT HEADER
  Widget _buildEmploymentHeader(bool isMobile, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 36.h,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isEmploymentMonthly = true;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12.w : 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: _isEmploymentMonthly
                        ? AppColors.secondaryPrimary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'Hiring',
                    style: (isMobile
                        ? AppTextStyles.font12BlackCairoRegular
                        : AppTextStyles.font14BlackCairoRegular)
                        .copyWith(
                      color: _isEmploymentMonthly
                          ? AppColors.textButton
                          : AppColors.text,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isEmploymentMonthly = false;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12.w : 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: !_isEmploymentMonthly
                        ? AppColors.secondaryPrimary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'Turnover',
                    style: (isMobile
                        ? AppTextStyles.font12BlackCairoRegular
                        : AppTextStyles.font14BlackCairoRegular)
                        .copyWith(
                      color: !_isEmploymentMonthly
                          ? AppColors.textButton
                          : AppColors.text,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STAT CARD CONTENT
  Widget _buildStatCardContent({
    required String icon,
    required String label,
    required String value,
    Color? labelColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.sp,
          height: 40.sp,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: SvgPicture.asset(
              icon,
              width: 40.sp,
              height: 40.sp,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.font14BlackSemiBoldCairo.copyWith(
                  color: labelColor ?? AppColors.text,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              Text(
                value,
                style: AppTextStyles.font20BlackSemiBoldCairo.copyWith(
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMinAvgMaxCard({
    required String icon,
    required String title,
    required String minimum,
    required String average,
    required String maximum,
  }) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
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
                  child: SvgPicture.asset(
                    icon,
                    width: 16.sp,
                    height: 16.sp,
                    color: AppColors.textButton,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.font14BlackSemiBoldCairo.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatColumn('Minimum', minimum),
              _buildStatColumn('Average', average),
              _buildStatColumn('Maximum', maximum),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.font12BlackCairoRegular.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AppTextStyles.font20BlackSemiBoldCairo.copyWith(
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}