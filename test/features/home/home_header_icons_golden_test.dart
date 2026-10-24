/// Module: home (test)
///
///*************************** FILE INFO ****************************///
/// File Name: home_header_icons_golden_test.dart
/// Description: 22/10/2026 — Owner: "the thickness ... equal by number and by
///              eye" — draws every Home card title glyph at the card size
///              (HomeWidgetCard.iconSize, 20) on the card colour, tinted
///              primary, so the stroke weights can be compared side by side.
///              Row 1 = the assets as shipped; row 2 = the two icons that were
///              heavier (Qiyas, Low Stock) with their OLD stroke for contrast.
///              Rows 3–4 = the same at 3× so the strokes are easy to see.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../todo/_support/todo_test_fakes.dart';

const String _dir = 'assets/icons_assets/main_icons_assets';

/// Every glyph a Home card title row draws (HomeWidgetCard.icon and the
/// three hand-built title rows), in module order.
const List<String> _icons = <String>[
  'ic_module_todo',
  'ic_module_time_tracking',
  'ic_module_support_headset', // Services
  'ic_comms_chat_double', // Messages
  'ic_module_inventory',
  'ic_data_inventory_damaged', // Low Stock
  'ic_module_roles',
  'ic_module_settings',
  'ic_module_knowledge_hub',
  'ic_module_form_builder',
  'ic_module_qiyas',
];

/// The strokes the two outliers had before 22/10/2026 (new → old).
const Map<String, List<String>> _old = <String, List<String>>{
  'ic_module_qiyas': <String>['stroke-width="1.3462"', 'stroke-width="1.8229"'],
  'ic_data_inventory_damaged': <String>[
    'stroke-width="0.6538"',
    'stroke-width="0.8854"',
  ],
};

const Color _card = Color(0xFFFFFFFF);
const Color _primary = Color(0xFFF5C400);

Widget _row(Map<String, String> svgs, double size) => Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final MapEntry<String, String> e in svgs.entries)
          Padding(
            padding: EdgeInsets.all(size / 2),
            child: SvgPicture.string(
              e.value,
              width: size,
              height: size,
              colorFilter: const ColorFilter.mode(_primary, BlendMode.srcIn),
            ),
          ),
      ],
    );

void main() {
  setUpAll(initTestStorage);

  testWidgets('home card title glyphs share one stroke weight',
      (WidgetTester tester) async {
    final Map<String, String> now = <String, String>{};
    final Map<String, String> before = <String, String>{};
    for (final String n in _icons) {
      final String s = await rootBundle.loadString('$_dir/$n.svg');
      now[n] = s;
      final List<String>? swap = _old[n];
      if (swap != null) before[n] = s.replaceAll(swap[0], swap[1]);
    }

    await tester.binding.setSurfaceSize(const Size(1400, 600));
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFEDEDED),
        body: Align(
          alignment: Alignment.topLeft,
          child: RepaintBoundary(
            key: const ValueKey<String>('icons'),
            child: ColoredBox(
              color: _card,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _row(now, 20),
                  _row(before, 20),
                  _row(now, 60),
                  _row(before, 60),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.runAsync(() => Future<void>.delayed(
          const Duration(milliseconds: 500),
        ));
    await tester.pumpAndSettle();

    await expectLater(find.byKey(const ValueKey<String>('icons')),
        matchesGoldenFile('goldens/home_header_icons.png'));
  });
}
