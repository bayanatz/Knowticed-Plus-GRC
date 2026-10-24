/// Module: messaging / home / presentation/ui/pages/home_layout_helper.dart
/// ************************* FILE INFO *************************** ///
/// File Name: home_layout_helper.dart
/// Purpose: Home layout helper — messaging Home sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025
/// Updated: 22/10/2026 - Owner: a notification's View opens its conversation.
///          The module root takes `PendingNotificationRecord` (a chat
///          partner's email, or a group id) and opens that chat over the list.
library;

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/main_helper/messaging_interface_implementation.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/pages/chat_mobile_view.dart';
import 'package:knowticed_plus/features/notification/domain/enums/messages/messages_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/routing/pending_notification_record.dart';

import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/group_chat_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/single_chat_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/media_controller.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/message_controller.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/community_controller.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/controller/groups_controller.dart';
import 'package:knowticed_plus/features/messaging/m4_messaging_home/presentation/controller/messaging_home_controller.dart';
import 'package:knowticed_plus/features/messaging/helpers/main/chat_settings_service.dart';
import 'package:knowticed_plus/features/messaging/m4_messaging_home/presentation/ui/pages/home_mobile_page.dart';
import 'package:knowticed_plus/features/messaging/m4_messaging_home/presentation/ui/pages/home_tablet_page.dart';

class HomePageHelperLayout extends StatefulWidget {
  const HomePageHelperLayout({super.key});

  @override
  State<HomePageHelperLayout> createState() => _HomePageHelperLayoutState();
}

class _HomePageHelperLayoutState extends State<HomePageHelperLayout> {
  /// The conversation a notification's View asked for (owner 22/10/2026):
  /// the chat partner's email, or a group id. Taken once — the routing
  /// remounts this root for every View.
  final PendingNotificationRecord? _notified =
      PendingNotificationRecord.take(Modules.messages);

  @override
  void initState() {
    super.initState();
    final PendingNotificationRecord? notified = _notified;
    if (notified != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _openNotified(notified));
    }
  }

  /// Opens the conversation [record] names, over the Messages list.
  ///
  /// An id with an `@` is a person (email IS the messaging user id) and goes
  /// through the same bridge as the card's Message button; anything else is a
  /// group id. A group the reader is no longer in — deleted, or they were
  /// removed — leaves them on the list, which is also where the "removed" and
  /// "group deleted" notifications point (they carry no id).
  Future<void> _openNotified(PendingNotificationRecord record) async {
    if (MessagesNotificationPage.fromKey(record.pageKey) ==
        MessagesNotificationPage.messagingHome) {
      return;
    }
    final String id = record.recordId;
    final MessagingInterfaceImplementation messaging =
        MessagingInterfaceImplementation();

    // 22/10/2026 — the page decides, not the id: group ids can contain an
    // `@` (`<creatorEmail>_<millis>`), so they were opened as a person.
    final bool isGroup = MessagesNotificationPage.fromKey(record.pageKey) ==
        MessagesNotificationPage.groupChat;
    if (!isGroup && id.contains('@')) {
      final OpenChatResult result;
      if (context.isTablett) {
        // The tablet layout renders the selected connection inline.
        result = await messaging.selectChatWithUser(userEmail: id);
      } else {
        result = await messaging.tryOpenChatWithUser(
            context: context, userEmail: id);
      }
      if (mounted) await showOpenChatFailure(context, result);
      return;
    }

    final OpenChatResult result =
        await messaging.selectChatWithGroup(groupId: id);
    if (!mounted) return;
    if (result != OpenChatResult.opened) {
      // Said out loud (owner 22/10/2026): a View that does nothing reads as a
      // bug. Deleted group / removed member land here too.
      await showOpenChatFailure(context, result);
      return;
    }
    // On tablet the GroupsCubit selection redraws the chat panel in place.
    if (context.isTablett) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatMobileView(
          masterChatCubit: Get.find<GroupChatCubit>(),
          connectionsCubit: Get.find<ConnectionsCubit>(),
          groupsCubit: Get.find<GroupsCubit>(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The messaging cubits are owned by GetX (see core/di/message_module/
    // dependency.dart), but the Home pages consume them with `context.read` /
    // `BlocBuilder`, which resolve through provider. Expose the *same*
    // instances to this subtree with BlocProvider.value — matching how
    // chat_mobile_view.dart bridges GetX and bloc.
    // NOTE: CommunityCubit is registered with Get.lazyPut, so it is only
    // "prepared" until something first resolves it — isRegistered alone would
    // report false here. Accept either state; Get.find() instantiates it.
    bool available<T>() => Get.isRegistered<T>() || Get.isPrepared<T>();

    if (!available<ConnectionsCubit>() ||
        !available<MessagingHomeCubit>() ||
        !available<CommunityCubit>() ||
        !available<GroupsCubit>() ||
        !available<MessageCubit>() ||
        !available<MediaCubit>() ||
        !available<SingleChatCubit>() ||
        !available<GroupChatCubit>()) {
      log('❌ HomePageHelper: messaging dependencies not registered. '
          'Make sure useGroupAndSingleMessaging() is called before navigating here.');
      return const SizedBox.shrink();
    }

    // Every GetX-owned cubit the Home/Connections/Groups widgets resolve with
    // context.read / BlocBuilder.
    //
    // SingleChatCubit / GroupChatCubit are included because the *tablet*
    // layout renders the chat panel inline in this subtree (tablet_body.dart)
    // and ConnectionsCubit.selectConnection reads SingleChatCubit off the
    // context. On mobile, ChatMobileView still provides its own MasterChatCubit
    // for the pushed route, which is unaffected by these.
    return MultiBlocProvider(
      providers: [
        BlocProvider<ConnectionsCubit>.value(
            value: Get.find<ConnectionsCubit>()),
        BlocProvider<MessagingHomeCubit>.value(
            value: Get.find<MessagingHomeCubit>()),
        BlocProvider<CommunityCubit>.value(value: Get.find<CommunityCubit>()),
        BlocProvider<GroupsCubit>.value(value: Get.find<GroupsCubit>()),
        BlocProvider<MessageCubit>.value(value: Get.find<MessageCubit>()),
        BlocProvider<MediaCubit>.value(value: Get.find<MediaCubit>()),
        BlocProvider<SingleChatCubit>.value(value: Get.find<SingleChatCubit>()),
        BlocProvider<GroupChatCubit>.value(value: Get.find<GroupChatCubit>()),
      ],
      // MultiBlocProvider only accepts `child`, so a Builder is what gives us
      // a context that sits *below* the providers above — reading the cubits
      // with this widget's own context would still throw.
      child: Builder(builder: (context) => _buildLayout(context)),
    );
  }

  Widget _buildLayout(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionsCubit = context.read<ConnectionsCubit>();
      final homeCubit = context.read<MessagingHomeCubit>();

      // ── Guard: currentUser must be set by useGroupAndSingleMessaging() first ──
      // Uses the cubit's own init guard so the UI page holds no try/catch (§11.2).
      if (!connectionsCubit.isCurrentUserInitialized) {
        log('❌ HomePageHelper: currentUser not set on ConnectionsCubit yet. '
            'Make sure useGroupAndSingleMessaging() is called before navigating here.');
        return;
      }

      // Pinned / muted chat icons on the chat cards (bug report #20–22).
      ChatSettingsService.watch(connectionsCubit.currentUser.userId);

      // ── Guard: categories must be set ──
      if (connectionsCubit.categories == null ||
          connectionsCubit.categories!.isEmpty) {
        log('❌ HomePageHelper: categories not set on ConnectionsCubit.');
        return;
      }

      // ── initialize() sets searchController / sortType / selectedTab ──
      // This is safe to call multiple times (idempotent).
      connectionsCubit.initialize(
        searchController: homeCubit.searchController,
        sortType: null,
        selectedTab: connectionsCubit.categories!.first,
      );

      log('✅ HomePageHelper: calling getAllAppUsersInConnectionForm()');
      connectionsCubit.getAllAppUsersInConnectionForm();
    });

    return ResponsiveHelper(
      mobileWidget: HomeMobilePage(),
      tabletWidget: Navigator(
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => HomeTabletPage(),
        ),
      ),
    );
  }
}
