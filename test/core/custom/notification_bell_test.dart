import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/core/custom/navigation/notification_bell.dart';

import '../../features/todo/_support/todo_test_fakes.dart';

void main() {
  setUpAll(initTestStorage);

  testWidgets('bell: count inside, primary at zero', (WidgetTester tester) async {
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(400, 200),
      builder: (_, __) => MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF3A3A3A),
          body: Center(
            child: RepaintBoundary(
              key: const ValueKey<String>('bells'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final int n in <int>[0, 3, 8, 120])
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: NotificationBellIcon(count: n, size: 60),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget);
    expect(find.text('99+'), findsOneWidget);
    expect(find.text('0'), findsOneWidget); // zero is shown (owner 22/10/2026)
    await expectLater(find.byKey(const ValueKey<String>('bells')),
        matchesGoldenFile('goldens/notification_bell.png'));
  });
}
