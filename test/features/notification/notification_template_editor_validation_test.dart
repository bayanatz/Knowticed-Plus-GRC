// Owner 22/10/2026 (R-6): the Notification Control message fields show
// "This field is required." only AFTER Save — never when the page opens —
// and invalidChannel() names the channel that blocks a save.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_template_editor.dart';

Widget _host(NotificationTemplateControllers c, {required bool submitted}) =>
    ScreenUtilInit(
      designSize: const Size(1024, 768),
      builder: (_, __) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NotificationTemplateEditor(
              controllers: c,
              isEmail: true,
              enabled: true,
              module: null,
              onChanged: () {},
              submitted: submitted,
            ),
          ),
        ),
      ),
    );

void _fill(NotificationTemplateControllers c) {
  for (final TextEditingController t in c.all) {
    t.text = 'x';
  }
}

void main() {
  testWidgets('no errors when the page opens, even with empty fields',
      (WidgetTester t) async {
    final c = NotificationTemplateControllers();
    await t.pumpWidget(_host(c, submitted: false));
    expect(find.text('This field is required.'), findsNothing);
    expect(find.text('هذا الحقل مطلوب'), findsNothing);
    await t.pump(const Duration(seconds: 1));
  });

  testWidgets('after Save every empty field says it is required',
      (WidgetTester t) async {
    final c = NotificationTemplateControllers();
    await t.pumpWidget(_host(c, submitted: true));
    // Email view: Subject + Body in English and Arabic.
    expect(find.text('This field is required.'), findsNWidgets(2));
    expect(find.text('هذا الحقل مطلوب'), findsNWidgets(2));
    await t.pump(const Duration(seconds: 1));
  });

  testWidgets('a filled field shows no error after Save',
      (WidgetTester t) async {
    final c = NotificationTemplateControllers();
    _fill(c);
    c.subjectEn.text = '';
    await t.pumpWidget(_host(c, submitted: true));
    expect(find.text('This field is required.'), findsOneWidget);
    expect(find.text('هذا الحقل مطلوب'), findsNothing);
    await t.pump(const Duration(seconds: 1));
  });

  test('invalidChannel names the channel that blocks Save', () {
    final c = NotificationTemplateControllers();
    _fill(c);
    expect(c.invalidChannel(), isNull);

    c.pushBodyAr.text = '';
    expect(c.invalidChannel(), 'push');

    c.pushBodyAr.text = 'x';
    c.pushBodyEn.text = 'a' * (kPushBodyMaxLength + 1);
    expect(c.invalidChannel(), 'push');

    c.pushBodyEn.text = 'x';
    c.subjectAr.text = '   ';
    expect(c.invalidChannel(), 'email');
  });
}
