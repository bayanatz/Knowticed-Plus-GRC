import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/packed_wrap.dart';

void main() {
  test('packRows tops a row up with the widest card that still fits', () {
    // 4 cells of 100, gap 0: a Wrap would give [3][4][2,2]-style gaps.
    final List<List<int>> rows =
        RenderPackedWrap.packRows(<double>[300, 400, 200, 100], 400, 0);
    expect(rows, <List<int>>[
      <int>[0, 3], // 300 + 100 fills the row
      <int>[1], // 400 alone
      <int>[2], // 200 last, nothing left to add
    ]);
  });

  test('packRows counts the gap', () {
    final List<List<int>> rows =
        RenderPackedWrap.packRows(<double>[190, 190, 190], 400, 16);
    expect(rows, <List<int>>[
      <int>[0, 1],
      <int>[2],
    ]);
  });

  testWidgets('no row ends short while a later card would fit', (tester) async {
    Widget box(double w) => SizedBox(width: w, height: 50);
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 400,
          child: PackedWrap(
            spacing: 0,
            runSpacing: 10,
            children: <Widget>[box(300), box(400), box(200), box(100)],
          ),
        ),
      ),
    ));
    // 300 and 100 share row one; 400 and 200 follow.
    final Rect fourth = tester.getRect(find.byType(SizedBox).at(4));
    expect(fourth.left, 300);
    expect(fourth.top, 0);
    expect(tester.getSize(find.byType(PackedWrap)).height, 50 * 3 + 10 * 2);
  });

  testWidgets('RTL starts rows at the right edge', (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.rtl,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 400,
          child: PackedWrap(
            children: <Widget>[
              SizedBox(width: 300, height: 50),
              SizedBox(width: 100, height: 50),
            ],
          ),
        ),
      ),
    ));
    expect(tester.getRect(find.byType(SizedBox).at(1)).right, 400);
    expect(tester.getRect(find.byType(SizedBox).at(2)).left, 0);
  });
}
