///******************* FILE INFO *******************///
/// File Name: employees_hierarchy.dart
/// Purpose: Contains the ui for the employees hierarchy page using dfs algorithm to draw the hierarchy
/// Author: Mohamed Elrashidy
/// Created at: 25/12/2024
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/helper/employees/core_widgets/services_management/custom_filter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/src/services/haptic_feedback.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/main_helper/haptic_controller.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import 'package:demo_app/core/helper/employees/domain/entities/organization_hierarchy_node.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employees_hierarchy_drawer.dart';
import 'package:lottie/lottie.dart';

import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/custom/circle_progress.dart';
import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/core/helper/employees/core_widgets/grc/custom_button_with_image.dart';
// REMOVED_MODULE: import '../../../../../../external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/widgets/add_depratment_dialog.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/widgets/employee_card.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/widgets/employees_hierarchy_filter_by_department.dart';

class TabletEmployeesHierarchy extends StatefulWidget {
  TabletEmployeesHierarchy({super.key});

  @override
  State<TabletEmployeesHierarchy> createState() =>
      _TabletEmployeesHierarchyState();
}

class _TabletEmployeesHierarchyState extends State<TabletEmployeesHierarchy> {
  EmployeeController addEmployeeController = Get.find();
  TextEditingController searchEmployee = TextEditingController();
  List<OrganizationHierarchyNode> filteredNodes = [];
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<EmployeeController>().filterEmployeesByDepartmentId("All");
    });
  }

  @override
  void dispose() {
    searchEmployee.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _searchEmployees(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredNodes = [];
      } else {
        filteredNodes = [];
        String lowerQuery = query.toLowerCase();

        for (var node in addEmployeeController.organizationHierarchyNodesRoots.values) {
          _searchInNode(node, lowerQuery);
        }
      }
    });
  }

  void _searchInNode(OrganizationHierarchyNode node, String query) {
    String firstName = node.employee.firstName.isNotEmpty
        ? node.employee.firstName.last.toLowerCase()
        : '';
    String lastName = node.employee.lastName.isNotEmpty
        ? node.employee.lastName.last.toLowerCase()
        : '';
    String fullName = '$firstName $lastName';

    if (fullName.contains(query) ||
        firstName.contains(query) ||
        lastName.contains(query)) {
      filteredNodes.add(node);
    }

    for (var child in node.children) {
      _searchInNode(child, query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final HapticController hapticController = Get.put(HapticController());
    var isMobile = context.isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.width > 600;
    final bool isArabic = Directionality.of(context) == TextDirection.rtl;

    return isMobile ? Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.sp, vertical: isMobile ? 0 : 0.sp),
      child: Column(
        children: [
          isMobile ? SizedBox(height: 0) : SizedBox(height: 20.h),

          Row(
            children: [
              Text(
                S.of(context).organizationChart,
                style: StyleText.fontSize22Weight700.copyWith(
                    color: AppColors.text
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 30.h : 30.h),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GetBuilder<EmployeeController>(
                  builder: (controller) {
                    bool isArabic = Get.locale?.languageCode == 'ar';
                    String allLabel = isArabic ? 'الكل' : 'All';

                    Map<String, int> departmentCounts = {};
                    int totalCount = 0;

                    if (controller.allEmployees != null) {
                      for (var employee in controller.allEmployees!) {
                        totalCount++;
                        String deptId = employee.departmentId.isNotEmpty
                            ? employee.departmentId.last
                            : '';

                        if (deptId.isNotEmpty) {
                          String deptName = controller.getDepartment(deptId);
                          if (deptName.isNotEmpty) {
                            departmentCounts[deptName] = (departmentCounts[deptName] ?? 0) + 1;
                          }
                        }
                      }
                    }

                    return DepartmentFilterChips(
                      selectedKey: controller.selectedDepartment ?? allLabel,
                      onSelected: (selectedLabel) {
                        String? deptId;
                        if (selectedLabel != allLabel) {
                          for (var employee in controller.allEmployees ?? []) {
                            if (employee.departmentId.isNotEmpty) {
                              String testDeptId = employee.departmentId.last;
                              String testDeptName = controller.getDepartment(testDeptId);
                              if (testDeptName == selectedLabel) {
                                deptId = testDeptId;
                                break;
                              }
                            }
                          }
                        }

                        addEmployeeController.filterEmployeesByDepartmentId(
                            selectedLabel == allLabel ? 'All' : deptId
                        );

                        searchEmployee.clear();
                        filteredNodes = [];

                        setState(() {});
                      },
                      totalCount: totalCount,
                      departmentCounts: departmentCounts,
                      userDepartment: '',
                      isArabic: isArabic,
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 15.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              customButtonWithImageMas(
                title: isMobile ? "" : S.of(context).department,
                function: () async {
                  hapticController.triggerHapticFeedback(
                      vibration: VibrateType.mediumImpact,
                      hapticFeedback: HapticFeedback.mediumImpact
                  );

                  await Get.dialog(
                    AddDepartmentDialogNew(),
                    barrierDismissible: true,
                  );

                  setState(() {
                    addEmployeeController.filterEmployeesByDepartmentId("All");
                  });
                },
                textStyle: StyleText.fontSize15Weight400.copyWith(
                  color: AppColors.textButton,
                ),
                height: 38.sp,
                width: isMobile ? 38.sp : 150.sp,
                space: isMobile ? 0.sp : 8.sp,
                radius: 8.r,
                color: AppColors.primary,
                image: "assets/employee_assets/new_department.svg",
                widthImage: 23,
                heightImage: 23,
                svgColor: AppColors.textButton,
                colorBorder: Colors.transparent,
              ),
            ],
          ),

          SizedBox(height: 15.h),

          Expanded(
            child: GetBuilder<EmployeeController>(
              init: addEmployeeController,
              builder: (controller) {
                if (addEmployeeController.organizationHierarchyNodesRoots.isEmpty) {
                  return Center(
                    child: CircleProgressMaster(),
                  );
                } else {
                  var nodesToDisplay = filteredNodes.isNotEmpty
                      ? filteredNodes
                      : addEmployeeController.organizationHierarchyNodesRoots.values;

                  if (searchEmployee.text.isNotEmpty && filteredNodes.isEmpty) {
                    return Center(
                      child: Text(
                        "No employees found",
                        style: AppTextStyles.font22BlackCairoSemiBold,
                      ),
                    );
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_horizontalScrollController.hasClients && isArabic) {
                      _horizontalScrollController.jumpTo(0);
                    }
                  });

                  return SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var node in nodesToDisplay)
                            buildOrganizationHierarchyGraph(node, 0)
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    ) :

    Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: isMobile ? 0 : 15.sp),
      child: Column(
        children: [
          isMobile ? SizedBox(height: 0) : SizedBox(height: 20.h),

          Row(
            children: [
              Text(
                S.of(context).organizationChart,
                style: StyleText.fontSize22Weight700.copyWith(
                    color: AppColors.text
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 30.h : 30.h),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GetBuilder<EmployeeController>(
                  builder: (controller) {
                    bool isArabic = Get.locale?.languageCode == 'ar';
                    String allLabel = isArabic ? 'الكل' : 'All';

                    Map<String, int> departmentCounts = {};
                    int totalCount = 0;

                    if (controller.allEmployees != null) {
                      for (var employee in controller.allEmployees!) {
                        totalCount++;
                        String deptId = employee.departmentId.isNotEmpty
                            ? employee.departmentId.last
                            : '';

                        if (deptId.isNotEmpty) {
                          String deptName = controller.getDepartment(deptId);
                          if (deptName.isNotEmpty) {
                            departmentCounts[deptName] = (departmentCounts[deptName] ?? 0) + 1;
                          }
                        }
                      }
                    }

                    return DepartmentFilterChips(
                      selectedKey: controller.selectedDepartment ?? allLabel,
                      onSelected: (selectedLabel) {
                        String? deptId;
                        if (selectedLabel != allLabel) {
                          for (var employee in controller.allEmployees ?? []) {
                            if (employee.departmentId.isNotEmpty) {
                              String testDeptId = employee.departmentId.last;
                              String testDeptName = controller.getDepartment(testDeptId);
                              if (testDeptName == selectedLabel) {
                                deptId = testDeptId;
                                break;
                              }
                            }
                          }
                        }

                        addEmployeeController.filterEmployeesByDepartmentId(
                            selectedLabel == allLabel ? 'All' : deptId
                        );

                        searchEmployee.clear();
                        filteredNodes = [];

                        setState(() {});
                      },
                      totalCount: totalCount,
                      departmentCounts: departmentCounts,
                      userDepartment: '',
                      isArabic: isArabic,
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 15.h),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     customButtonWithImage(
          //       title: isMobile ? "" : S.of(context).department,
          //       function: () async {
          //         await Get.dialog(
          //           AddDepartmentDialogNew(),
          //           barrierDismissible: true,
          //         );
          //
          //         setState(() {
          //           addEmployeeController.filterEmployeesByDepartmentId("All");
          //         });
          //       },
          //       textStyle: StyleText.fontSize15Weight400.copyWith(
          //         color: AppColors.textButton,
          //       ),
          //       height: 38.h,
          //       width: isMobile ? 38.w : 135.w,
          //       space: isMobile ? 0 : 8,
          //       radius: 8.r,
          //       color: AppColors.primary,
          //       image: "assets/employee_assets/new_department.svg",
          //       widthImage: 23,
          //       heightImage: 23,
          //       svgColor: AppColors.textButton,
          //       colorBorder: Colors.transparent,
          //     ),
          //   ],
          // ),

          GetBuilder<EmployeeController>(
            init: addEmployeeController,
            builder: (controller) {
              if (addEmployeeController.organizationHierarchyNodesRoots.isEmpty) {
                return Column(
                  children: [
                    SizedBox(height: isPortrait ? 300.h : 190.h),
                    CircleProgressMaster(),
                  ],
                );
              } else {
                var nodesToDisplay = filteredNodes.isNotEmpty
                    ? filteredNodes
                    : addEmployeeController.organizationHierarchyNodesRoots.values;

                if (searchEmployee.text.isNotEmpty && filteredNodes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 100.h),
                      child: Text(
                        "No employees found",
                        style: AppTextStyles.font22BlackCairoSemiBold,
                      ),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_horizontalScrollController.hasClients && isArabic) {
                    _horizontalScrollController.jumpTo(0);
                  }
                });

                return SizedBox(
                  height: isTablet ? null : 598.h,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var node in nodesToDisplay)
                          buildOrganizationHierarchyGraph(node, 0)
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildOrganizationHierarchyGraph(
      OrganizationHierarchyNode node, int level) {
    var isMobile = context.isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    double opacityStep = addEmployeeController.getOpacityStep();
    double opacity = (level) * opacityStep;
    bool isLeader = node.children.isNotEmpty;

    // Skip rendering if employee data is invalid
    if (node.employee.firstName.isEmpty && node.employee.lastName.isEmpty) {
      return SizedBox.shrink();
    }

    if (node.employee.id!.isEmpty) {
      return SizedBox.shrink();
    }

    if (node.employee.email.isEmpty) {
      return SizedBox.shrink();
    }

    return isMobile
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 10.h),
        EmployeeCard(
          textColor: (level == 0)
              ? AppColors.textButton
              : isLeader
              ? AppColors.white
              : AppColors.black,
          isLeader: isLeader,
          cardColor: (level == 0)
              ? AppColors.primary
              : isLeader
              ? (AppTheme.isDark ? AppColors.darkGrey : AppColors.darkGrey)
              .withOpacity(AppTheme.isDark
              ? (1 - (1 - opacity))
              : (1 - opacity))
              : lightMode
              ? Colors.white
              : Colors.white.withOpacity(.5),
          employee: node.employee,
        ),
        if (node.children.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < node.children.length; i++)
                  if (node.children[i].children.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(right: 4.w),
                      child: buildOrganizationHierarchyGraph(
                          node.children[i], level + 1),
                    ),

                Column(
                  children: [
                    for (int i = 0; i < node.children.length; i++)
                      if (node.children[i].children.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 0.w, vertical: 4.h),
                          child: buildOrganizationHierarchyGraph(
                              node.children[i], level + 1),
                        )
                  ],
                )
              ],
            ),
          ),
      ],
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ✅ FIX: Only add top spacing for root level
        if (level == 0) SizedBox(height: 10.h),

        EmployeeCard(
          textColor: (level == 0)
              ? AppColors.textButton
              : isLeader
              ? AppColors.white
              : AppColors.black,
          isLeader: isLeader,
          cardColor: (level == 0)
              ? AppColors.primary
              : isLeader
              ? (AppTheme.isDark ? AppColors.darkGrey : AppColors.darkGrey)
              .withOpacity(AppTheme.isDark
              ? (1 - (1 - opacity))
              : (1 - opacity))
              : lightMode
              ? Colors.white
              : Colors.white.withOpacity(.5),
          employee: node.employee,
        ),

        if (node.children.isNotEmpty)
          Padding(
            // ✅ FIX: Consistent vertical spacing
            padding: EdgeInsets.only(top: 10.h,right: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Leaders (nodes with children)
                ...node.children
                    .where((c) => c.children.isNotEmpty)
                    .map((child) => Padding(
                  // ✅ FIX: Equal horizontal spacing for leaders
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: buildOrganizationHierarchyGraph(child, level + 1),
                )),

                // Regular employees (nodes without children)
                if (node.children.any((c) => c.children.isEmpty))
                  Column(
                    children: node.children
                        .where((c) => c.children.isEmpty)
                        .map((child) => Padding(
                      // ✅ FIX: Equal spacing - horizontal and vertical
                      padding: EdgeInsets.only(
                        // left: 50.w,
                        // right: .w,
                        bottom: 10.h,
                      ),
                      child: buildOrganizationHierarchyGraph(child, level + 1),
                    ))
                        .toList()
                      ..removeLast() // Remove bottom padding from last item
                      ..add(
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.w),
                          child: buildOrganizationHierarchyGraph(
                            node.children.lastWhere((c) => c.children.isEmpty),
                            level + 1,
                          ),
                        ),
                      ),
                  )
              ],
            ),
          ),
      ],
    );
  }
}