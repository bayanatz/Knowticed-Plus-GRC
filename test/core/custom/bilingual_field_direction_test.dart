// Owner 22/10/2026: in an Arabic screen an English field (Latin label) lays
// out left-to-right — label on the left; in an English screen an Arabic
// field lays out right-to-left — label on the right.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';

Widget _host(TextDirection screen, Widget child) => ScreenUtilInit(
      designSize: const Size(1024, 768),
      builder: (_, __) => MaterialApp(
        home: Directionality(
          textDirection: screen,
          child: Scaffold(body: SizedBox(width: 600, child: child)),
        ),
      ),
    );

void main() {
  testWidgets('English field in an Arabic screen: label on the left',
      (WidgetTester t) async {
    await t.pumpWidget(_host(
      TextDirection.rtl,
      const CustomTextField(label: 'Title', textDirection: TextDirection.ltr),
    ));
    final Offset label = t.getTopLeft(find.text('Title', findRichText: true));
    expect(label.dx, lessThan(100));
    await t.pump(const Duration(seconds: 1));
  });

  testWidgets('Arabic field in an English screen: label on the right',
      (WidgetTester t) async {
    await t.pumpWidget(_host(
      TextDirection.ltr,
      const CustomTextField(label: 'عنوان', textDirection: TextDirection.rtl),
    ));
    final Offset label = t.getTopRight(find.text('عنوان', findRichText: true));
    expect(label.dx, greaterThan(500));
    await t.pump(const Duration(seconds: 1));
  });
}
