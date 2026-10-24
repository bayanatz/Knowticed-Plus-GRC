import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/org_chart/presentation/controller/org_chart_department_columns.dart';

class _N {
  _N(this.name, this.dept, [List<_N>? kids]) : children = kids ?? [];
  final String name;
  final String dept;
  final List<_N> children;
}

OrgChartDepartmentLayout<_N> _group(List<_N> roots, {List<String> order = const []}) =>
    groupOrgChartByDepartment<_N>(
      roots: roots,
      childrenOf: (n) => n.children,
      departmentOf: (n) => n.dept,
      order: order,
    );

List<String> _names(List<OrgChartEntry<_N>> e) => [for (final x in e) x.node.name];

void main() {
  test('head without department on top, one column per department', () {
    final pm = _N('pm', '', [
      _N('a1', 'admin', [_N('a2', 'admin'), _N('a3', 'admin')]),
      _N('c1', 'citizen', [_N('c2', 'citizen')]),
      _N('a4', 'admin'),
    ]);
    final layout = _group([pm], order: ['citizen', 'admin']);
    expect(_names(layout.top), ['pm']);
    expect(layout.columns.map((c) => c.key), ['citizen', 'admin']);
    expect(_names(layout.columns[1].value), ['a1', 'a2', 'a3', 'a4']);
    expect(_names(layout.columns[0].value), ['c1', 'c2']);
    expect(layout.columns[1].value.first.level, 1);
  });

  test('everyone in a department: the head still goes on top', () {
    final head = _N('head', 'admin', [_N('a1', 'admin'), _N('c1', 'citizen')]);
    final layout = _group([head]);
    expect(_names(layout.top), ['head']);
    expect(layout.columns.map((c) => c.key), ['admin', 'citizen']);
  });

  test('a cycle does not loop forever', () {
    final a = _N('a', '');
    final b = _N('b', 'x', [a]);
    a.children.add(b);
    final layout = _group([a]);
    expect(_names(layout.top), ['a']);
    expect(_names(layout.columns.single.value), ['b']);
  });
}
