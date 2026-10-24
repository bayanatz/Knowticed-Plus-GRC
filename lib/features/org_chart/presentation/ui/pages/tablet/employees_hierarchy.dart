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
import 'package:knowticed_plus/core/custom/navigation/custom_filter_app.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/org_chart/domain/entities/organization_hierarchy_node.dart';
import 'package:knowticed_plus/features/org_chart/presentation/controller/employees_hierarchy_drawer.dart';
import 'package:knowticed_plus/features/org_chart/presentation/controller/org_chart_department_columns.dart';

import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/features/org_chart/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/features/org_chart/presentation/controller/main_core_department_controller.dart';
import 'package:knowticed_plus/features/org_chart/presentation/ui/widgets/employee_card.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

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

  /// Phone: width of the page the boxes are laid out in (set by _chartArea),
  /// and the width of one box — three and a half across, so the next column peeks in and shows the page scrolls sideways.
  double _pageWidth = 0;
  double get _boxWidth => (_pageWidth - 2.5 * _gap) / 3.5;

  /// Side padding around a column of cards. None on the phone: the card is
  /// already the full page width, so any extra made the row wider than the
  /// screen and the first card was cut off at the edge (Moataz 23/10/2026,
  /// department filter).
  double get _sidePad => kpIsPhoneLayout(context) ? 0 : _gap / 2;

  /// Guarded lookup — may not be registered yet when this widget builds.
  AddDepartmentController get _departments =>
      Get.isRegistered<AddDepartmentController>()
          ? Get.find<AddDepartmentController>()
          : Get.put(AddDepartmentController());

  bool get _isArabic => Get.locale?.languageCode == 'ar';

  /// The "All" chip's key is the canonical 'All' (see departmentChipItems), but
  /// the controller stores the LOCALISED label ('الكل') — so in Arabic the
  /// selected key never matched the chip and "All" could not be selected
  /// (Moataz 23/10/2026). Either spelling means "All".
  bool _isAllValue(String? value) =>
      value == null || value == 'All' || value == 'الكل';

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
    // 22/10/2026 (Moataz, phone: the title started right of the counters):
    // on the phone the page already pads 4% at the sides, so the title adds
    // none — it starts on the same line as the "All" counter.
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: 10.h, horizontal: isPhone ? 0 : 15),
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
  String _departmentLabel(String name) => FormatHelper.capitalize(
      _isArabic ? (kDepartmentEnToAr[name] ?? name) : name);

  Widget _chips() {
    return GetBuilder<OrgChartEmployeeController>(
      builder: (controller) {
        final Map<String, int> departmentCounts = {};
        int totalCount = 0;

        for (var employee in controller.allEmployees ?? []) {
          totalCount++;
          final String deptId = employee.departmentId.isNotEmpty
              ? employee.departmentId.last
              : '';
          if (deptId.isNotEmpty) {
            final String deptName = controller.getDepartment(deptId);
            if (deptName.isNotEmpty) {
              departmentCounts[deptName] =
                  (departmentCounts[deptName] ?? 0) + 1;
            }
          }
        }

        return StatusChipFilter(
          selectedKey: _isAllValue(controller.selectedDepartment)
              ? 'All'
              : controller.selectedDepartment!,
          onSelected: (selectedLabel) {
            String? deptId;
            if (!_isAllValue(selectedLabel)) {
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
                _isAllValue(selectedLabel) ? 'All' : deptId);
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
        final bool isAll = _isAllValue(controller.selectedDepartment);

        Widget buildChart() => isAll
            ? _allTab(roots, isPhone)
            : isPhone
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final OrganizationHierarchyNode node in roots)
                        _phoneTree(node, 0),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final OrganizationHierarchyNode node in roots)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: _sidePad),
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
          if (isPhone) {
            _pageWidth = viewport;
            // Boxes in a grid, scrolling up and down; the chart is exactly
            // the page wide so every row of boxes fits.
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(bottom: 20.sp),
                child: SizedBox(
                  width: viewport,
                  child: buildChart(),
                ),
              ),
            );
          }
          return SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: viewport),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20.sp),
                    child: buildChart(),
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

    // Phone: boxes, in the iPad / Mac structure (Moataz 23/10/2026): the head
    // on top, then the departments side by side (scrolling sideways) and,
    // inside each department, its people one under the other.
    if (isPhone && _pageWidth > 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topCards.isNotEmpty) Center(child: topCards.first),
          if (topCards.isNotEmpty) SizedBox(height: 20.sp),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            // No rubber-band bounce on the sideways scroll (Moataz 23/10/2026:
            // "it just bounces").
            physics: const ClampingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < layout.columns.length; i++) ...[
                  if (i > 0) SizedBox(width: _gap),
                  SizedBox(
                    width: _boxWidth,
                    child: Column(
                      children: [
                        // Two lines tall for every department, so every
                        // column's boxes start on one line.
                        SizedBox(
                          height: 40.sp,
                          child: Center(
                            child: Text(
                              _departmentLabel(layout.columns[i].key),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: StyleText.fontSize14Weight600
                                  .copyWith(color: AppColors.text),
                            ),
                          ),
                        ),
                        SizedBox(height: _gap),
                        for (final OrgChartEntry<OrganizationHierarchyNode> e
                            in layout.columns[i].value) ...[
                          _card(e.node, e.level),
                          SizedBox(height: _gap),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

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
      for (final MapEntry<String,
              List<OrgChartEntry<OrganizationHierarchyNode>>> column
          in layout.columns)
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

  /// Every column is the SAME fixed card width (18/10/2026, Moataz: "equal
  /// width, not too big" — a long job title scrolls inside its card instead
  /// of widening the whole column).
  Widget _equalWidth(List<Widget> children) {
    return Builder(
      builder: (BuildContext context) => SizedBox(
        width: EmployeeCard.cardWidth(context),
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
      ),
    );
  }

  Widget _card(OrganizationHierarchyNode node, int level) {
    final double opacity = level * addEmployeeController.getOpacityStep();
    // RESTORED 18/10/2026 (Moataz: "the colours between the hierarchy are now
    // the same"). One colour per level, as the original org chart had it:
    //   head      → primary (yellow)
    //   leaders   → dark grey, lighter at each level down (both themes; dark
    //               mode used to fade the top leaders to almost nothing)
    //   employees → white (50% white in dark mode) with dark text — the
    //               16/10 merge had turned them into the plain card colour,
    //               which is why every card looked the same.
    final Color leaderCardColor =
        AppColors.darkGrey.withValues(alpha: (1 - opacity).clamp(0.35, 1.0));
    final Color leaderTextColor =
        Color.alphaBlend(leaderCardColor, AppColors.background)
                    .computeLuminance() >
                0.4
            ? AppColors.black
            : AppColors.white;
    final bool isLeader = node.children.isNotEmpty;
    final Color memberCardColor = AppTheme.isDark
        ? const Color(0xFFFFFFFF).withValues(alpha: .5)
        : const Color(0xFFFFFFFF);

    return EmployeeCard(
      boxWidth: kpIsPhoneLayout(context) && _pageWidth > 0 ? _boxWidth : null,
      isLeader: isLeader,
      textColor: level == 0
          ? AppColors.textButton
          : isLeader
              ? leaderTextColor
              : const Color(0xFF000000),
      cardColor: level == 0
          ? AppColors.primary
          : isLeader
              ? leaderCardColor
              : memberCardColor,
      employee: node.employee,
    );
  }

  /// Phone department tab: the head's box, the people who report to them as a
  /// grid of boxes, then each manager's own branch below.
  Widget _phoneTree(OrganizationHierarchyNode node, int level) {
    if (!_isVisible(node)) return const SizedBox.shrink();

    final List<OrganizationHierarchyNode> leaders =
        node.children.where((c) => c.children.isNotEmpty).toList();
    final List<OrganizationHierarchyNode> members = node.children
        .where((c) => c.children.isEmpty && _isVisible(c))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _card(node, level),
        if (members.isNotEmpty) ...[
          SizedBox(height: _gap),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: _gap,
            runSpacing: _gap,
            children: [for (final m in members) _card(m, level + 1)],
          ),
        ],
        for (final OrganizationHierarchyNode leader in leaders) ...[
          SizedBox(height: _gap * 2),
          _phoneTree(leader, level + 1),
        ],
      ],
    );
  }

  /// Department tab: the reporting tree, as before. Managers side by side,
  /// the people with no reports stacked in one equal-width column.
  Widget _tree(OrganizationHierarchyNode node, int level) {
    if (!_isVisible(node)) return const SizedBox.shrink();

    final List<OrganizationHierarchyNode> leaders =
        node.children.where((c) => c.children.isNotEmpty).toList();
    final List<OrganizationHierarchyNode> members = node.children
        .where((c) => c.children.isEmpty && _isVisible(c))
        .toList();

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
                    padding: EdgeInsets.symmetric(horizontal: _sidePad),
                    child: _tree(leader, level + 1),
                  ),
                if (members.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: _sidePad),
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
