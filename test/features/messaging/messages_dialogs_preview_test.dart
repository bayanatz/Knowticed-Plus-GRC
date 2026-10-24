/// Module: test / messaging
///
///*************************** FILE INFO ****************************///
/// File Name: messages_dialogs_preview_test.dart
/// Purpose: Opens the chat dialogs changed on 20/10/2026 (Disappearing
///          Messages, Schedule Message) and the Mentions cards in dark and
///          light, and checks the owner's rules: the round icon header,
///          Cancel / Apply at the two edges, no hover highlight on the
///          options, "Choose Time" capitalised, the app's date field, and one
///          font size for every mention name. Writes PNGs to $TT_SHOTS.
/// Author: Knowticed Plus team
/// Created at: 20/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/interface/controller/messaging_init_controller.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/interface/entity/messaging_configurations.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/widgets/dialogs/disappearing_messages_dialog.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/widgets/dialogs/schedule_message_dialog.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/widgets/member_mention_widget.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/domain/entities/member_entity.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../time_tracker/_support/time_tracker_widget_harness.dart';
import '../time_tracker/_support/tt_shots.dart';

class _FakeConfig implements MessagingConfigurations {
  @override
  bool Function() isSecondaryLanguage = () => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeInit implements MessagingInitController {
  @override
  MessagingConfigurations messagingConfigurations = _FakeConfig();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Only what the dialogs read before they open.
class _FakeCubit implements MasterChatCubit {
  @override
  int? get disappearingHoursOption => 2160;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MemberEntity _member(String name) => MemberEntity(
      memberId: name,
      primaryLanguageName: name,
      secondaryLanguageName: null,
      primaryLanguageSubInfo: null,
      secondaryLanguageSubInfo: null,
      memberPhone: null,
      memberImage: '',
      numOfUnreadMessages: 0,
      addedTime: null,
      isAdmin: false,
    );

Future<BuildContext> _pump(WidgetTester tester, {required bool dark, Widget? body}) async {
  setTtTheme(dark: dark, locale: 'en');
  tester.view.physicalSize = const Size(1366, 1024);
  tester.view.devicePixelRatio = 1;
  late BuildContext ctx;
  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(1366, 1024),
    builder: (_, __) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Material(
        color: AppColors.background,
        child: Builder(builder: (BuildContext c) {
          ctx = c;
          return body ?? const SizedBox.expand();
        }),
      ),
    ),
  ));
  await tester.pump();
  return ctx;
}

Future<void> _settle(WidgetTester tester) async {
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Cancel's left gap to the dialog equals Apply's right gap.
void _expectEdgeButtons(WidgetTester tester) {
  final Rect dialog = tester.getRect(find.byType(Dialog));
  final Rect cancel = tester.getRect(find.text('Cancel'));
  final Rect apply = tester.getRect(find.text('Apply'));
  final Rect cancelBox = tester.getRect(find.ancestor(of: find.text('Cancel'), matching: find.byType(SizedBox)).first);
  final Rect applyBox = tester.getRect(find.ancestor(of: find.text('Apply'), matching: find.byType(SizedBox)).first);
  expect(cancel.center.dy, closeTo(apply.center.dy, 0.5));
  expect((cancelBox.left - dialog.left - (dialog.right - applyBox.right)).abs(), lessThan(1.5));
}

void main() {
  setUpAll(() async {
    await initTimeTrackerTestStorage();
    await loadTtFonts();
    Get.put<MessagingInitController>(_FakeInit());
  });
  tearDown(() => setTtTheme(dark: false, locale: 'en'));

  for (final bool dark in <bool>[true, false]) {
    final String mode = dark ? 'dark' : 'light';

    testWidgets('Disappearing Messages dialog ($mode)', (WidgetTester tester) async {
      final BuildContext ctx = await _pump(tester, dark: dark);
      showDisappearingMessagesDialog(ctx, _FakeCubit());
      await _settle(tester);
      expect(find.byType(CustomDialogHeader), findsOneWidget);
      expect(find.text('90 Days'), findsOneWidget);
      // No hover / splash highlight on the options.
      expect(find.descendant(of: find.byType(Dialog), matching: find.byType(InkWell)), findsNothing);
      _expectEdgeButtons(tester);
      expect(tester.takeException(), isNull);
      await ttShot(tester, 'dialog_disappearing_$mode');
    });

    testWidgets('Schedule Message dialog ($mode)', (WidgetTester tester) async {
      final BuildContext ctx = await _pump(tester, dark: dark);
      showScheduleMessageDialog(ctx, _FakeCubit());
      await _settle(tester);
      expect(find.byType(CustomDialogHeader), findsOneWidget);
      expect(find.byType(CustomDateField), findsOneWidget);
      expect(find.text('Choose Time'), findsOneWidget);
      _expectEdgeButtons(tester);
      expect(tester.takeException(), isNull);
      await ttShot(tester, 'dialog_schedule_$mode');
    });

    testWidgets('Mentions cards ($mode)', (WidgetTester tester) async {
      await _pump(
        tester,
        dark: dark,
        body: Padding(
          padding: EdgeInsets.all(20.sp),
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(8.r)),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8.w,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (final String n in <String>['Salma Fathy', 'Youssef Ibrahim', 'Khaled Abdelrahman', 'Bayanatz Transformation'])
                      MemberMentionWidget(member: _member(n)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      final List<double?> sizes = <double?>[
        for (final String n in <String>['Salma Fathy', 'Khaled Abdelrahman', 'Bayanatz Transformation'])
          tester.widget<Text>(find.text(n)).style?.fontSize,
      ];
      expect(sizes.toSet().length, 1);
      expect(find.byType(FittedBox), findsNothing);
      expect(tester.takeException(), isNull);
      await ttShot(tester, 'mentions_$mode');
    });
  }
}
