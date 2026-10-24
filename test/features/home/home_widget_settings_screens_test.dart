/// Module: test / home / h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_widget_settings_screens_test.dart
/// Purpose: D-242 on screen — the gear on Home Layout and the Adding Widget
///          page, the "[Widget name] Settings" dialog, Save validation, and the
///          widget redrawing on Save, on iPad H / iPad V / iPhone.
///          Runs the preview harness (`tool/widget_settings_preview.dart`):
///          the REAL wrappers, cards and dialog on demo data, no Firebase.
///
/// SCREENSHOTS: run with `KP_SHOTS_DIR=/some/dir flutter test <this file>` and
/// every step also writes a PNG (2x) there. Without the variable nothing is
/// written and the test only asserts.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
library;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/home_components.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/remove_component_wrapper.dart';

import '../../../tool/widget_settings_preview.dart';
import '../todo/_support/todo_test_fakes.dart';

class _Device {
  const _Device(this.name, this.size);
  final String name;
  final Size size;
}

const List<_Device> _devices = <_Device>[
  _Device('ipad_h', Size(1376, 1032)),
  _Device('ipad_v', Size(1032, 1376)),
  _Device('iphone', Size(393, 852)),
];

final String? _shotsDir = Platform.environment['KP_SHOTS_DIR'];
final GlobalKey _shotKey = GlobalKey();

Future<void> _loadAppFont() async {
  final Uint8List bytes = File(
    'assets/fonts/fonts_english/Cairo/Cairo-Regular.ttf',
  ).readAsBytesSync();
  for (final String family in <String>['Cairo', 'CairoArabic']) {
    final FontLoader loader = FontLoader(family)
      ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    await loader.load();
  }
}

Future<void> _shot(WidgetTester tester, String name) async {
  final String? dir = _shotsDir;
  if (dir == null) return;
  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(_shotKey));
  final ByteData? data = await tester.runAsync<ByteData?>(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 2);
    return image.toByteData(format: ui.ImageByteFormat.png);
  });
  Directory(dir).createSync(recursive: true);
  File('$dir/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
}

Future<void> _pump(WidgetTester tester, _Device d,
    {String locale = 'en', bool dark = false}) async {
  tester.view.physicalSize = d.size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(RepaintBoundary(
    key: _shotKey,
    child: WidgetSettingsPreviewApp(locale: locale, dark: dark),
  ));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(seconds: 1));
}

Finder _gear(HomeComponents c) =>
    find.byKey(ValueKey<String>('gear_${c.name}'));

Future<void> _openGear(WidgetTester tester, HomeComponents c) async {
  await tester.ensureVisible(_gear(c));
  await tester.tap(_gear(c));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pump();
}

void main() {
  setUpAll(() async {
    await initTestStorage();
    await _loadAppFont();
    await initWidgetSettingsPreview(dark: false, locale: 'en');
  });

  for (final _Device d in _devices) {
    group(d.name, () {
      testWidgets('gear on every Services and To-Do card, Home Layout',
          (WidgetTester tester) async {
        await _pump(tester, d);
        for (final HomeComponents c in <HomeComponents>[
          HomeComponents.requestedService,
          HomeComponents.serviceActions,
          HomeComponents.serviceStatus,
          HomeComponents.myServices,
          HomeComponents.nearBreachedSLA,
          HomeComponents.serviceOverview,
          HomeComponents.myRequestServices,
          HomeComponents.myTodoList,
          HomeComponents.myTodoStatus,
          HomeComponents.myTodoBox,
        ]) {
          expect(_gear(c), findsOneWidget, reason: c.name);
        }
        // Owner 21/10: the gear is top-RIGHT, next to the red minus.
        for (final Element e
            in find.byType(RemoveComponentWrapper).evaluate()) {
          final Rect wrapper = tester.getRect(find.byWidget(e.widget));
          final Rect gear = tester.getRect(find.descendant(
              of: find.byWidget(e.widget),
              matching: find.byWidgetPredicate((Widget w) =>
                  w.key is ValueKey<String> &&
                  (w.key! as ValueKey<String>).value.startsWith('gear_'))));
          expect(gear.center.dx, greaterThan(wrapper.center.dx));
          expect(gear.top, closeTo(wrapper.top, 1));
        }
        // Owner 21/10: cards of the grid have EQUAL widths — and no overflow
        // (the phone used to throw "right overflowed" on the wide cards).
        final Set<int> widths = <int>{
          for (final Element e
              in find.byType(RemoveComponentWrapper).evaluate())
            (tester.getSize(find.byWidget(e.widget)).width * 10).round(),
        };
        expect(widths, hasLength(1), reason: 'ragged widths: $widths');
        expect(tester.takeException(), isNull);
        await _shot(tester, '${d.name}_1_home_layout');
        await _unmount(tester);
      });

      testWidgets('settings dialog: look, validation, redraw on Save',
          (WidgetTester tester) async {
        await _pump(tester, d);

        // The dialog: title, gear header, fields, Discard / Save.
        await _openGear(tester, HomeComponents.nearBreachedSLA);
        expect(find.text('Near Breached SLA Settings'), findsOneWidget);
        expect(find.text('Discard'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
        expect(find.text('Allowed 1–100'), findsWidgets);
        await _shot(tester, '${d.name}_2_dialog_near_breached');

        // A wrong value: Save refuses and names the field.
        final Finder warn = find.byType(CustomTextField).first;
        await tester.enterText(warn, '140');
        await tester.pump();
        await tester.tap(find.text('Save'));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Enter a number from 1 to 100.'), findsOneWidget);
        expect(find.text('Near Breached SLA Settings'), findsOneWidget,
            reason: 'the dialog stays open on a wrong value');
        await _shot(tester, '${d.name}_3_dialog_validation');

        // The keyboard open (the platform keyboard is 1/3 of the screen).
        tester.view.viewInsets = FakeViewPadding(bottom: d.size.height * 0.36);
        addTearDown(tester.view.resetViewInsets);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 400));
        await _shot(tester, '${d.name}_4_dialog_keyboard');
        tester.view.resetViewInsets();
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 400));

        // A right value: the dialog closes and the card redraws. 95 % leaves
        // only the two breached requests: 2 of 11 = 18 % (was 4 of 11 = 36 %).
        expect(find.text('36%'), findsOneWidget);
        await tester.enterText(warn, '95');
        await tester.pump();
        await tester.tap(find.text('Save'));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('Near Breached SLA Settings'), findsNothing);
        expect(find.text('18%'), findsOneWidget);
        expect(find.text('36%'), findsNothing);
        await _shot(tester, '${d.name}_5_after_save');
        await _unmount(tester);
      });

      testWidgets('My Services dialog: nothing overflows, Save stays inside',
          (WidgetTester tester) async {
        await _pump(tester, d);
        await _openGear(tester, HomeComponents.myServices);
        expect(find.text('My Services Settings'), findsOneWidget);
        expect(tester.takeException(), isNull);
        final Rect dialog = tester.getRect(find
            .ancestor(
                of: find.text('My Services Settings'),
                matching: find.byType(Dialog))
            .first);
        final Rect save = tester.getRect(find.text('Save'));
        expect(dialog.contains(save.center), isTrue);
        expect(save.right, lessThanOrEqualTo(dialog.right));
        await _shot(tester, '${d.name}_9_dialog_my_services');
        await _unmount(tester);
      });

      testWidgets('Discard keeps the card as it was',
          (WidgetTester tester) async {
        await _pump(tester, d);
        await _openGear(tester, HomeComponents.nearBreachedSLA);
        await tester.enterText(find.byType(CustomTextField).first, '95');
        await tester.pump();
        await tester.tap(find.text('Discard'));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('36%'), findsOneWidget);
        await _unmount(tester);
      });

      testWidgets(
          'Adding Widget page: same gear, settings travel with the card',
          (WidgetTester tester) async {
        await _pump(tester, d);
        await tester.tap(find.byKey(const ValueKey<String>('toggle')));
        await tester.pump(const Duration(milliseconds: 500));
        expect(_gear(HomeComponents.myTodoBox), findsOneWidget);
        await _shot(tester, '${d.name}_6_adding_widget');

        await _openGear(tester, HomeComponents.myTodoBox);
        expect(find.text('To-Do Tasks Settings'), findsOneWidget);
        await _shot(tester, '${d.name}_7_dialog_todo_tasks');
        await tester.enterText(find.byType(CustomTextField).first, '2');
        await tester.pump();
        await tester.tap(find.text('Save'));
        await tester.pump(const Duration(milliseconds: 600));
        final AppHomeCubit cubit =
            tester.element(find.byType(Scaffold).first).read<AppHomeCubit>();
        expect(
          cubit.readyToAddComponent
              .firstWhere((m) => m.component == HomeComponents.myTodoBox)
              .settings,
          <String, dynamic>{'Rows': 2},
        );
        await _unmount(tester);
      });
    });
  }

  testWidgets('Arabic and dark: dialog on the phone',
      (WidgetTester tester) async {
    await tester
        .runAsync(() => initWidgetSettingsPreview(dark: true, locale: 'ar'));
    await _pump(tester, _devices.last, locale: 'ar', dark: true);
    await _openGear(tester, HomeComponents.serviceStatus);
    // X-01: Arabic mirrors — Save (yellow) on the LEFT, Discard on the right.
    expect(tester.getCenter(find.text('حفظ')).dx,
        lessThan(tester.getCenter(find.text('إلغاء')).dx));
    await _shot(tester, 'iphone_8_dialog_ar_dark');
    expect(tester.takeException(), isNull);
    await _unmount(tester);
    await tester
        .runAsync(() => initWidgetSettingsPreview(dark: false, locale: 'en'));
  });
}
