///******************* FILE INFO *******************///
/// File Name: org_chart_department_columns.dart
/// Purpose: Splits the org-chart reporting tree into a top row (the head /
///          people with no department) and one column per department, for
///          the "All" tab.
/// Author: Moataz Handousa
/// Created at: 18/10/2026 (owner: "in All, divide the people by department,
///             each department its own column")
library;

/// One person placed in the chart, with its depth in the reporting tree
/// (0 = a root) so the card keeps its leader colouring.
class OrgChartEntry<T> {
  const OrgChartEntry(this.node, this.level);
  final T node;
  final int level;
}

/// The "All" tab layout: [top] sits centred above the [columns].
class OrgChartDepartmentLayout<T> {
  const OrgChartDepartmentLayout({required this.top, required this.columns});
  final List<OrgChartEntry<T>> top;

  /// Department name -> its people, in reporting (depth-first) order.
  final List<MapEntry<String, List<OrgChartEntry<T>>>> columns;
}

/// Walks [roots] depth-first (reporting order) and groups everyone by
/// [departmentOf] ('' = no department).
///
/// - No department -> top row.
/// - If nobody is without a department, the heads (roots that manage
///   someone) go to the top row instead, so the chart always has a top.
/// - Columns follow [order] (the tab order) first, then first appearance.
/// - [isVisible] false skips a node (and nothing else: its reports still
///   show, so no one disappears because a manager's record is incomplete).
OrgChartDepartmentLayout<T> groupOrgChartByDepartment<T>({
  required Iterable<T> roots,
  required List<T> Function(T node) childrenOf,
  required String Function(T node) departmentOf,
  bool Function(T node)? isVisible,
  List<String> order = const [],
}) {
  final List<OrgChartEntry<T>> flat = [];
  final Set<T> seen = {};

  void walk(T node, int level) {
    if (!seen.add(node)) return; // guard against a cycle
    if (isVisible == null || isVisible(node)) {
      flat.add(OrgChartEntry<T>(node, level));
    }
    for (final T child in childrenOf(node)) {
      walk(child, level + 1);
    }
  }

  for (final T root in roots) {
    walk(root, 0);
  }

  final List<OrgChartEntry<T>> top = [];
  final Map<String, List<OrgChartEntry<T>>> byDepartment = {};

  final bool anyWithoutDepartment =
      flat.any((e) => departmentOf(e.node).trim().isEmpty);

  for (final OrgChartEntry<T> entry in flat) {
    final String department = departmentOf(entry.node).trim();
    final bool isHead = entry.level == 0 && childrenOf(entry.node).isNotEmpty;
    if (department.isEmpty || (!anyWithoutDepartment && isHead)) {
      top.add(entry);
    } else {
      byDepartment.putIfAbsent(department, () => []).add(entry);
    }
  }

  final List<String> names = [
    for (final String name in order)
      if (byDepartment.containsKey(name)) name,
    for (final String name in byDepartment.keys)
      if (!order.contains(name)) name,
  ];

  return OrgChartDepartmentLayout<T>(
    top: top,
    columns: [for (final String n in names) MapEntry(n, byDepartment[n]!)],
  );
}
