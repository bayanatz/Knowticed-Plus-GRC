/// Module: test / messaging
///
///*************************** FILE INFO ****************************///
/// File Name: messages_cards_preview_test.dart
/// Purpose: Renders the Messages pieces changed on 20/10/2026 (group card,
///          group picture, member avatars with "+N", the ⋮ edge gap) in dark
///          and light, and checks the owner's rules: the group name is never
///          cut, the unread badge uses the secondary brand colour, and the
///          avatar row shows at most four faces then "+N". Writes PNGs to
///          $TT_SHOTS when set.
/// Author: Knowticed Plus team
/// Created at: 20/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/core/custom/cards/stacked_avatars.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/messaging/helpers/constants/messaging_assets.dart';
import 'package:knowticed_plus/features/messaging/helpers/main/chat_state_icons.dart';
import 'package:knowticed_plus/features/messaging/helpers/enums/message_types.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/domain/entities/group_entity.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/domain/entities/member_entity.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/ui/widgets/group_avatar.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/ui/widgets/groups_tile.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:get/get.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/interface/controller/messaging_init_controller.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/interface/entity/messaging_configurations.dart';

import '../time_tracker/_support/time_tracker_widget_harness.dart';
import '../time_tracker/_support/tt_shots.dart';

/// The cards read the language setting through the messaging set-up object
/// (which needs Firebase in the app) — a stand-in with English only.
class _FakeConfig implements MessagingConfigurations {
  @override
  bool Function() isSecondaryLanguage = () => false;

  @override
  bool seenAndUnseen = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeInit implements MessagingInitController {
  @override
  MessagingConfigurations messagingConfigurations = _FakeConfig();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MemberEntity _member(int i) => MemberEntity(
      memberId: 'm$i',
      primaryLanguageName: 'Member $i',
      secondaryLanguageName: null,
      primaryLanguageSubInfo: null,
      secondaryLanguageSubInfo: null,
      memberPhone: null,
      memberImage: '',
      numOfUnreadMessages: 0,
      addedTime: null,
      isAdmin: false,
    );

GroupEntity _group(String name,
        {int unread = 0, int members = 6, bool pinned = false}) =>
    GroupEntity(
      groupId: name,
      createdBy: 'me',
      imageUri: '',
      isPublic: false,
      primaryLanguageName: name,
      groupDescription: '',
      isOnlyAdminsCanSend: false,
      isDisappearingMessages: false,
      isUnMuted: true,
      isSeen: false,
      otherSideId: name,
      messageType: MessageTypes.text,
      messageContent: 'Pool photographers are confirmed for the opening day.',
      lastMessageTime: Timestamp.fromDate(DateTime(2026, 10, 16, 9)),
      myNumUnreadMessage: unread,
      isLastMessageSenderIsCurrentUser: false,
      hasMention: false,
      senderPrimaryLanguageName: 'Salma Fathy',
      senderSecondaryLanguageName: null,
      members: <MemberEntity>[for (int i = 0; i < members; i++) _member(i)],
      groupImage: null,
      createdAt: Timestamp.fromDate(DateTime(2026, 10, 1)),
      hasPinnedMessage: pinned,
    );

Widget _page() => Builder(
      builder: (BuildContext context) => ColoredBox(
        color: AppColors.background,
        child: Padding(
          padding: EdgeInsets.all(20.sp),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 270.sp,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 10.sp,
                  children: <Widget>[
                    GroupsTile(
                        groupEntity: _group('Digital Egypt Forum Media Desk',
                            unread: 2, pinned: true)),
                    GroupsTile(
                        groupEntity:
                            _group('Data Governance And Quality Council')),
                  ],
                ),
              ),
              SizedBox(width: 20.sp),
              Expanded(
                // The tablet group header's picture · name · avatars · ⋮
                // with the same paddings as `message_tablet_appbar.dart`.
                child: Container(
                  key: const ValueKey<String>('headerPreview'),
                  padding: EdgeInsetsDirectional.only(
                      start: 10.sp, top: 10.sp, bottom: 10.sp),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(8.sp)),
                  ),
                  child: Row(
                    children: <Widget>[
                      GroupAvatar(imageUrl: null, size: 45.sp, radius: 8.r),
                      SizedBox(width: 16.sp),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Digital Egypt Forum Media Desk',
                                style: StyleText.fontSize14Weight500),
                            SizedBox(height: 4.sp),
                            StackedAvatars(
                              key: const ValueKey<String>('memberAvatars'),
                              height: 24.sp,
                              avatarColor: AppColors.background,
                              avatarTextColor: AppColors.text,
                              ringColor: AppColors.card,
                              width: 24.sp * 0.6 * 4 + 24.sp,
                              fontSize: 10.sp,
                              // No member photos → the app's avatar.
                              images: List<String>.filled(6,
                                  'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        key: const ValueKey<String>('menuBox'),
                        width: 65.sp - 14,
                        height: 36.sp,
                        child: Center(
                            child: CustomSvgImage.natural(
                                assetPath: AppAssets.more,
                                color: AppColors.text)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

Future<void> _pump(WidgetTester tester, {required bool dark}) async {
  setTtTheme(dark: dark, locale: 'en');
  tester.view.physicalSize = const Size(1366, 420);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(1366, 420),
    builder: (_, __) => MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Material(child: _page()),
    ),
  ));
  await tester.pump();
}

void main() {
  setUpAll(() async {
    await initTimeTrackerTestStorage();
    await loadTtFonts();
    // "+N" asks Google Fonts for Roboto Bold (no download in tests) — Cairo
    // Bold stands in so the preview shows the figures.
    final FontLoader roboto = FontLoader('Roboto_700')
      ..addFont(
          rootBundle.load('assets/fonts/fonts_english/Cairo/Cairo-Bold.ttf'));
    await roboto.load();
    Get.put<MessagingInitController>(_FakeInit());
  });
  tearDown(() => setTtTheme(dark: false, locale: 'en'));

  for (final bool dark in <bool>[true, false]) {
    testWidgets('Messages cards (${dark ? 'dark' : 'light'})',
        (WidgetTester tester) async {
      await _pump(tester, dark: dark);
      // The full group name is shown (no "…").
      final Text name = tester
          .widget<Text>(find.text('Digital Egypt Forum Media Desk').first);
      expect(name.overflow, isNot(TextOverflow.ellipsis));
      expect(name.maxLines, isNull);
      // Unread badge: the branding primary (owner 21/10/2026).
      final CircleAvatar badge = tester.widget<CircleAvatar>(
          find.byKey(const ValueKey<String>('groupUnreadBadge')));
      expect(badge.backgroundColor, AppColors.primary);
      // Six members → four faces + "+2".
      expect(
          find.descendant(
              of: find.byKey(const ValueKey<String>('memberAvatars')),
              matching: find.text('+2')),
          findsOneWidget);
      // No group photo → the people icon.
      // The tiles draw their own round avatar now (22/10/2026); only the
      // sample GroupAvatar below the tiles is left.
      expect(find.byType(GroupAvatar), findsOneWidget);
      expect(tester.takeException(), isNull);
      // Unread number and pin in one row.
      final Rect badgeRect = tester
          .getRect(find.byKey(const ValueKey<String>('groupUnreadBadge')));
      final Rect pinRect = tester.getRect(find.byType(ChatStateIcons).first);
      expect((badgeRect.center.dy - pinRect.center.dy).abs(), lessThan(4));
      // The pin / mute icons come first, the badge after them.
      expect(badgeRect.left, greaterThan(pinRect.right - 0.5));
      await ttShot(tester, 'messages_cards_${dark ? 'dark' : 'light'}');
    });
  }
}
