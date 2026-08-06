import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import 'package:grc_module/core/network/message_module/routes/app_routes.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/main_controllers/group_chat_cubit.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/ui/pages/chat_mobile_view.dart';
import 'package:grc_module/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import 'package:grc_module/features/messaging/m3_groups/presentation/controller/groups_controller.dart';
import 'package:grc_module/features/messaging/m4_messaging_home/presentation/controller/messaging_home_controller.dart';

import 'package:grc_module/core/network/message_module/services/error_handler.dart';
import 'package:grc_module/core/di/message_module/dependency.dart';
import '../../../../../features/messaging/m1_chat/data/repository/group_chat_repository.dart';
import '../../../../../features/messaging/m2_connections/domain/entities/single_connection_entity.dart';
import '../../../../../features/messaging/m3_groups/domain/entities/group_entity.dart';
import '../entity/base_messaging_interface_parameters.dart';
import '../entity/group_chat_interface_parameters.dart';
import '../entity/messaging_configurations.dart';
import '../entity/single_chat_interface_parameters.dart';
import '../entity/user_category.dart';
import '../entity/user_connection_interface_parameters.dart';
import '../../main_helper/messaging_interface.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

class MessagingInitController implements MessagingInterface {
  MessagingInitController({required MessagingConfigurations configurations}) {
    messagingConfigurations = configurations;
    Dependency().init();
  }

  late MessagingConfigurations messagingConfigurations;

  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // createNewConnection
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> createNewConnection({
    required BaseMessagingInterfaceParameters currentUser,
    required BaseMessagingInterfaceParameters newConnectionUser,
  }) async {
    return await Get.find<ConnectionsCubit>().createNewConnection(
      currentUser: currentUser,
      newConnectionUser: newConnectionUser,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // showSpecificGroupChat
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Future<void> showSpecificGroupChat({
    required String groupId,
    required BuildContext context,
  }) async {
    print("entered showSpecificGroupChat");
    final groupsCubit = Get.find<GroupsCubit>();

    if (groupsCubit.allGroups.any((element) => element.groupId == groupId)) {
      GroupEntity group = groupsCubit.allGroups
          .firstWhere((element) => element.groupId == groupId);

      groupsCubit.selectGroup(group);

      final chatController = GroupChatCubit(
        chatRepository: GroupChatRepository(),
        groupsCubit: Get.find<GroupsCubit>(),
      );

      await chatController.startChat(
        otherSideData: group,
        currentUserData: groupsCubit.currentUser,
      );

      chatController.messageFocusNode.unfocus();
      chatController.getFirstUnreadIndex();

      if (ContextExtension(context).isTablett) {
        // Tablet: panel updates in place via state
      } else {
        // Pure Bloc: push ChatMobileView with the active cubits (§3).
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatMobileView(
              masterChatCubit: chatController,
              connectionsCubit: Get.find<ConnectionsCubit>(),
              groupsCubit: Get.find<GroupsCubit>(),
            ),
          ),
        );
      }
    } else {
      print("Group with id $groupId not found");
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // showSpecificSingleChat
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Future<void> showSpecificSingleChat({
    required String otherUserId,
    required BuildContext context,
  }) async {
    print("entered showSpecificSingleChat");
    final connectionsCubit = Get.find<ConnectionsCubit>();

    // ✅ FIX: If connections are empty, wait for them to load first
    if (connectionsCubit.connections.isEmpty) {
      print("⚠️ Connections empty — triggering getAllAppUsersInConnectionForm and waiting...");
      await connectionsCubit.getAllAppUsersInConnectionForm();

      // Wait briefly for the stream to deliver first batch
      int retries = 0;
      while (connectionsCubit.connections.isEmpty && retries < 20) {
        await Future.delayed(const Duration(milliseconds: 200));
        retries++;
        print("⏳ Waiting for connections... attempt $retries");
      }

      if (connectionsCubit.connections.isEmpty) {
        print("❌ Connections still empty after waiting — aborting");
        return;
      }
    }

    if (connectionsCubit.filteredConnections
        .any((element) => element.userId == otherUserId)) {
      SingleConnectionEntity connection = connectionsCubit.filteredConnections
          .firstWhere((element) => element.userId == otherUserId);

      await connectionsCubit.selectConnection(connection, context);
    } else {
      print("_connections: ${connectionsCubit.connections.length}");

      // ✅ FIX: Check if user exists before firstWhere
      final hasConnection = connectionsCubit.connections
          .any((element) => element.userId == otherUserId);

      if (!hasConnection) {
        print("❌ User $otherUserId not found in connections list — cannot open chat");
        return;
      }

      try {
        SingleConnectionEntity connection =
        connectionsCubit.connections.firstWhere((element) {
          print('element.userId: ${element.userId}, otherUserId: $otherUserId');
          return element.userId == otherUserId;
        });

        BaseMessagingInterfaceParameters selectedConnection =
        connection.toBaseMessagingInterface();

        await connectionsCubit.createNewConnection(
          currentUser: connectionsCubit.currentUser,
          newConnectionUser: selectedConnection,
        );

        await connectionsCubit.selectConnection(connection, context);
      } catch (e) {
        print('Error finding connection: $e');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // useGroupAndSingleMessaging  ← MAIN FIX IS HERE
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void useGroupAndSingleMessaging({
    required GroupChatInterfaceParameters groupChatParameters,
    required Future<List<UserConnectionInterfaceParameters>> Function()
    getAllUsersDate,
    required UserCategory defaultCategory,
    required BuildContext context,
  }) {
    setContext(context);

    // Insert default "All" category at position 0 only once
    if (!groupChatParameters.categories!
        .any((c) => c.categoryId == defaultCategory.categoryId)) {
      groupChatParameters.categories!.insert(0, defaultCategory);
    }

    // Resolved from GetX, not from `context`. These cubits are owned by
    // Dependency().init() (GetX), and this method is called from the login
    // flow — whose BuildContext has no messaging providers above it, so
    // context.read<>() threw ProviderNotFoundException here.
    final messagingHomeCubit = Get.find<MessagingHomeCubit>();
    final connectionsCubit = Get.find<ConnectionsCubit>();
    final groupsCubit = Get.find<GroupsCubit>();

    // ── MessagingHomeCubit ──────────────────────────────────────────────────
    messagingHomeCubit.categories = groupChatParameters.categories;
    messagingHomeCubit.initialize(initialTab: defaultCategory);

    // ── GroupsCubit ─────────────────────────────────────────────────────────
    groupsCubit.currentUser = groupChatParameters;
    groupsCubit.getAllUsersDate = getAllUsersDate;
    groupsCubit.getGroups();

    // ── ConnectionsCubit ────────────────────────────────────────────────────
    connectionsCubit.currentUser = groupChatParameters;
    connectionsCubit.getAllUsersDate = getAllUsersDate;
    connectionsCubit.categories = groupChatParameters.categories!;

    // ✅ FIX: initialize() MUST be called here so selectedTab / searchController
    //         are set before HomePageHelper calls getAllAppUsersInConnectionForm()
    connectionsCubit.initialize(
      searchController: messagingHomeCubit.searchController,
      sortType: null,
      selectedTab: defaultCategory,
    );

    print('✅ MessagingInitController.useGroupAndSingleMessaging: '
        'ConnectionsCubit initialized with user=${groupChatParameters.userId}, '
        'categories=${groupChatParameters.categories!.length}');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Stubs
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void updateMyInfoWithConnections({
    required BaseMessagingInterfaceParameters userParameters,
  }) {
    throw UnimplementedError();
  }

  @override
  void useSingleMessagingOnly({
    required SingleChatInterfaceParameters singleChatParameters,
  }) {
    throw UnimplementedError();
  }

  @override
  bool isConnected({
    required BaseMessagingInterfaceParameters currentUser,
    required BaseMessagingInterfaceParameters otherUser,
  }) {
    throw UnimplementedError();
  }

  @override
  bool isThereAnyUnreadMessages({required String currentUserId}) {
    throw UnimplementedError();
  }

  @override
  void blockConnection({required String otherUserId}) {
    throw UnimplementedError();
  }

  @override
  void deleteConnection({required String otherUserId}) {
    throw UnimplementedError();
  }

  @override
  List<GroupEntity> getUserGroups() {
    if (_context == null) {
      throw StateError(
          'Context not set. Call useGroupAndSingleMessaging() first.');
    }
    return _context!.read<GroupsCubit>().allGroups;
  }
}