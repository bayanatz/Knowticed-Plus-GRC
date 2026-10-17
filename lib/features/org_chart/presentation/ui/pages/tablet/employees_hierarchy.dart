///******************* FILE INFO *******************///
/// File Name: employees_hierarchy.dart
/// Purpose: Contains the ui for the employees hierarchy page using dfs algorithm to draw the hierarchy
/// Author: Mohamed Elrashidy
/// Created at: 25/12/2024
/// Updated: 18/10/2026 (owner, final) - "All" tab: the head on top, then one
///          column per department (stacked on the phone); cards sized to
///          their content; the page title comes from the shared frame.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/custom/navigation/custom_filter_app.dart';
import 'package:grc_module/core/helper/format_title.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/org_chart/domain/entities/organization_hierarchy_node.dart';
import 'package:grc_module/features/org_chart/presentation/controller/employees_hierarchy_drawer.dart';
import 'package:grc_module/features/org_chart/presentation/controller/org_chart_department_columns.dart';

import 'package:grc_module/core/custom/feedback/circle_progress.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/theme/app_colors.dart';

import 'package:grc_module/features/org_chart/presentation/controller/employee_controller.dart';
import 'package:grc_module/features/org_chart/presentation/controller/main_core_department_controller.dart';
import 'package:grc_module/features/org_chart/presentation/ui/widgets/employee_card.dart';
import 'package:grc_module/core/extensions/context_extensions.dart';

class TabletEmployeesHierarchy extends StatefulWidget {
  const TabletEmployeesHierarchy({super.key, this.showTitle = true});

  /// False when the page title is drawn by the shared frame
  /// (`SideFrameMasterServices`, the tablet screen) — the same title every
  /// module page (Form Builder, Knowledge Hub) uses.
  final bool showTitle;

  @override
  State<TabletEmployeesHierarchy> createState() =>
      _TabletEmployeesHierarchyState();
}

class _TabletEmployeesHierarchyState extends State<TabletEmployeesHierarchy> {
  OrgChartEmployeeController addEmployeeController =
      Get.isRegistered<OrgChartEmployeeController>()
          ? Get.find<OrgChartEmployeeController>()
          : Get.put(OrgChartEmployeeController());

  /// Gap between cards, columns and rows.
  double get _gap => 10.r;

  /// Guarded lookup — may not be registered yet when this widget builds.
  AddDepartmentController get _departments =>
      Get.isRegistered<AddDepartmentController>()
          ? Get.find<AddDepartmentController>()
          : Get.put(AddDepartmentController());

  bool get _isArabic => Get.locale?.languageCode == 'ar';
  String get _allLabel => _isArabic ? 'الكل' : 'All';

  @override
  initState() {
    super.initState();

    // The department filter chips are built from `controller.getDepartment(id)`,
    // which reads AddDepartmentController's id -> name maps. Nothing on the
    // tablet path was ever populating those maps (only the mobile screen and
    // the unused FilterSelector called getDepartments()), so every lookup
    // returned "" and only the "All" chip rendered. Load them here.
    _loadDepartments();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      addEmployeeController.filterEmployeesByDepartmentId("All");
    });
  }

  Future<void> _loadDepartments() async {
    await _departments.getDepartments();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isPhone = kpIsPhoneLayout(context);

    return LayoutBuilder(builder: (context, constraints) {
      final bool bounded = constraints.hasBoundedHeight;
      final Widget chart = _chartArea(context, isPhone);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (widget.showTitle) _title(context, isPhone),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _chips(),
          ),
          SizedBox(height: 20.sp),
          if (bounded) Expanded(child: chart) else chart,
        ],
      );
    });
  }

  /// Same metrics as the shared frame's title (`SideFrameMasterServices`):
  /// 24 / w600 on the phone, 15 from the side, 15 + 10 from the top.
  Widget _title(BuildContext context, bool isPhone) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15),
      child: Padding(
        padding: EdgeInsets.only(top: 15.sp),
        child: Text(
          S.of(context).organizationChart,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: (isPhone
                  ? StyleText.fontSize24Weight600
                  : StyleText.fontSize28Weight600)
              .copyWith(color: AppColors.text),
        ),
      ),
    );
  }

  String _departmentIdOf(OrganizationHierarchyNode node) =>
      node.employee.departmentId.isNotEmpty
          ? node.employee.departmentId.last
          : '';

  String _departmentNameOf(OrganizationHierarchyNode node) {
    final String id = _departmentIdOf(node);
    return id.isEmpty ? '' : addEmployeeController.getDepartment(id);
  }

  /// The label the tabs show for a department name.
  String _departmentLabel(String name) =>
      FormatHelper.capitalize(_isArabic ? (kDepartmentEnToAr[name] ?? name) : name);

  Widget _chips() {
    return GetBuilder<OrgChartEmployeeController>(
      builder: (controller) {
        final Map<String, int> departmentCounts = {};
        int totalCount = 0;

        for (var employee in controller.allEmployees ?? []) {
          totalCount++;
          final String deptId =
              employee.departmentId.isNotEmpty ? employee.departmentId.last : '';
          if (deptId.isNotEmpty) {
            final String deptName = controller.getDepartment(deptId);
            if (deptName.isNotEmpty) {
              departmentCounts[deptName] = (departmentCounts[deptName] ?? 0) + 1;
            }
          }
        }

        return StatusChipFilter(
          selectedKey: controller.selectedDepartment ?? _allLabel,
          onSelected: (selectedLabel) {
            String? deptId;
            if (selectedLabel != _allLabel) {
              for (var employee in controller.allEmployees ?? []) {
                if (employee.departmentId.isNotEmpty) {
                  final String testDeptId = employee.departmentId.last;
                  if (controller.getDepartment(testDeptId) == selectedLabel) {
                    deptId = testDeptId;
                    break;
                  }
                }
              }
            }
            addEmployeeController.filterEmployeesByDepartmentId(
                selectedLabel == _allLabel ? 'All' : deptId);
            setState(() {});
          },
          items: departmentChipItems(
            totalCount: totalCount,
            departmentCounts: departmentCounts,
            isArabic: _isArabic,
          ),
        );
      },
    );
  }

  /// Department names in the tabs' order.
  List<String> _tabOrder() {
    final List<String> order = [];
    for (var employee in addEmployeeController.allEmployees ?? []) {
      if (employee.departmentId.isEmpty) continue;
      final String name =
          addEmployeeController.getDepartment(employee.departmentId.last);
      if (name.isNotEmpty && !order.contains(name)) order.add(name);
    }
    return order;
  }

  Widget _chartArea(BuildContext context, bool isPhone) {
    return GetBuilder<OrgChartEmployeeController>(
      init: addEmployeeController,
      builder: (controller) {
        if (controller.organizationHierarchyNodesRoots.isEmpty) {
          return Center(child: CircleProgressMaster());
        }
        final List<OrganizationHierarchyNode> roots =
            controller.organizationHierarchyNodesRoots.values.toList();
        final bool isAll = controller.selectedDepartment == null ||
            controller.selectedDepartment == _allLabel;

        final Widget chart = isAll
            ? _allTab(roots, isPhone)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final OrganizationHierarchyNode node in roots)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: _gap / 2),
                      child: _tree(node, 0),
                    ),
                ],
              );

        // Scrolls both ways when the chart is wider / taller than the page;
        // centred while it fits.
        return LayoutBuilder(builder: (context, constraints) {
          final double viewport = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          return SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: viewport),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20.sp),
                    child: chart,
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  bool _isVisible(OrganizationHierarchyNode node) =>
      !(node.employee.firstName.isEmpty && node.employee.lastName.isEmpty) &&
      (node.employee.id ?? '').isNotEmpty &&
      node.employee.email.isNotEmpty;

  /// "All" tab: the head(s) on top, then one column per department side by
  /// side (stacked on the phone). Each column: a small heading, then its
  /// people in reporting order, all as wide as the widest card.
  Widget _allTab(List<OrganizationHierarchyNode> roots, bool isPhone) {
    final OrgChartDepartmentLayout<OrganizationHierarchyNode> layout =
        groupOrgChartByDepartment<OrganizationHierarchyNode>(
      roots: roots,
      childrenOf: (n) => n.children,
      departmentOf: _departmentNameOf,
      isVisible: _isVisible,
      order: _tabOrder(),
    );

    final List<Widget> topCards = [
      for (final OrgChartEntry<OrganizationHierarchyNode> e in layout.top)
        _card(e.node, e.level),
    ];

    final Widget top = isPhone
        ? _equalWidth(topCards)
        : Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < topCards.length; i++) ...[
                if (i > 0) SizedBox(width: _gap),
                topCards[i],
              ],
            ],
          );

    final List<Widget> columns = [
      for (final MapEntry<String, List<OrgChartEntry<OrganizationHierarchyNode>>>
          column in layout.columns)
        _departmentColumn(column.key, column.value),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (topCards.isNotEmpty) top,
        if (topCards.isNotEmpty && columns.isNotEmpty) SizedBox(height: 20.sp),
        if (isPhone)
          for (int i = 0; i < columns.length; i++) ...[
            if (i > 0) SizedBox(height: 20.sp),
            columns[i],
          ]
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < columns.length; i++) ...[
                if (i > 0) SizedBox(width: 20.sp),
                columns[i],
              ],
            ],
          ),
      ],
    );
  }

  Widget _departmentColumn(
      String name, List<OrgChartEntry<OrganizationHierarchyNode>> entries) {
    return _equalWidth([
      Text(
        _departmentLabel(name),
        textAlign: TextAlign.center,
        maxLines: 1,
        softWrap: false,
        style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
      ),
      for (final OrgChartEntry<OrganizationHierarchyNode> e in entries)
        _card(e.node, e.level),
    ]);
  }

  /// Every child as wide as the widest one (cards sized to content).
  Widget _equalWidth(List<Widget> children) {
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: _gap),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _card(OrganizationHierarchyNode node, int level) {
    final double opacity = level * addEmployeeController.getOpacityStep();
    // FIXED 16/10/2026 (merge check): each deeper leader card gets a lighter
    // grey; its text colour follows the card's real colour (grey blended
    // over the page), whatever theme flag is set.
    final Color leaderCardColor = AppColors.darkGrey.withValues(
        alpha: AppTheme.isDark ? (1 - (1 - opacity)) : (1 - opacity));
    final Color leaderTextColor =
        Color.alphaBlend(leaderCardColor, AppColors.background)
                    .computeLuminance() >
                0.4
            ? AppColors.black
            : AppColors.white;
    final bool isLeader = node.children.isNotEmpty;

    return EmployeeCard(
      isLeader: isLeader,
      textColor: level == 0
          ? AppColors.textButton
          : isLeader
              ? leaderTextColor
              : AppColors.text,
      cardColor: level == 0
          ? AppColors.primary
          : isLeader
              ? leaderCardColor
              : AppColors.card,
      employee: node.employee,
    );
  }

  /// Department tab: the reporting tree, as before. Managers side by side,
  /// the people with no reports stacked in one equal-width column.
  Widget _tree(OrganizationHierarchyNode node, int level) {
    if (!_isVisible(node)) return const SizedBox.shrink();

    final List<OrganizationHierarchyNode> leaders =
        node.children.where((c) => c.children.isNotEmpty).toList();
    final List<OrganizationHierarchyNode> members =
        node.children.where((c) => c.children.isEmpty && _isVisible(c)).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _card(node, level),
        if (node.children.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: _gap),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final OrganizationHierarchyNode leader in leaders)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: _gap / 2),
                    child: _tree(leader, level + 1),
                  ),
                if (members.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: _gap / 2),
                    child: _equalWidth([
                      for (final OrganizationHierarchyNode m in members)
                        _card(m, level + 1),
                    ]),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
