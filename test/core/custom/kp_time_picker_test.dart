/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: kp_time_picker_test.dart
/// Purpose: The app's time picker is the scroll wheel, never the clock face
///          (Owner, 22/10/2026), and Set Time returns the chosen time.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
library;

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_time_picker.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../../features/todo/_support/todo_test_fakes.dart';

void main() {
  setUpAll(initTestStorage);

  testWidgets('scroll wheel, no clock face; Set Time returns the time',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1032, 1376);
    tester.view.devicePixelRatio = 1;
    TimeOfDay? result;
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(1032, 1376),
      builder: (_, __) => MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            backgroundColor: const Color(0xFF2D2D2D),
            body: Center(
              child: ElevatedButton(
                onPressed: () async => result = await showKpTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 13, minute: 4)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoDatePicker), findsOneWidget);
    expect(find.byType(TimePickerDialog), findsNothing);
    if (Platform.environment['KP_GOLDEN'] == '1') {
      await expectLater(
          find.byType(Dialog), matchesGoldenFile('goldens/kp_time_picker.png'));
    }
    await tester.tap(find.text(S.current.setTime).last);
    await tester.pumpAndSettle();
    expect(result, const TimeOfDay(hour: 13, minute: 4));
  });
}
