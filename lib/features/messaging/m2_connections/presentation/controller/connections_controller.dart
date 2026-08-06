/// Module: messaging / connections / presentation/controller/connections_controller.dart
/// ************************* FILE INFO *************************** ///
/// File Name: connections_controller.dart
/// Purpose: Connections controller — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import 'package:grc_module/core/network/message_module/routes/app_routes.dart';
import 'package:grc_module/core/network/message_module/services/error_handler.dart';
import 'package:grc_module/core/enums/message_module/message_types.dart';
import '../../../../../core/helper/message_module/interface/entity/base_messaging_interface_parameters.dart';
import '../../../../../core/helper/message_module/interface/entity/user_category.dart';
import '../../../../../core/helper/message_module/interface/entity/user_connection_interface_parameters.dart';
import '../../../m1_chat/data/repository/single_chat_repository.dart';
import '../../../m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import '../../../m1_chat/presentation/controller/main_controllers/single_chat_cubit.dart';
import '../../../m1_chat/presentation/ui/pages/chat_mobile_view.dart';
import '../../../m4_messaging_home/domain/enums/sort_enum.dart';
import '../../domain/base_repository/base_connections_repository.dart';
import '../../domain/entities/single_connection_entity.dart';
import '../../domain/usecases/create_new_connection_use_case.dart';
import '../../domain/usecases/get_all_app_users_in_connection_form.dart';

// ─────────────────────────────────────────────────────────────
// State classes
// ─────────────────────────────────────────────────────────────

abstract class ConnectionsState {}

class ConnectionsInitial extends ConnectionsState {}

class ConnectionsLoading extends ConnectionsState {}

class ConnectionsLoaded extends ConnectionsState {
  final List<SingleConnectionEntity> connections;
  final List<SingleConnectionEntity> filteredConnections;
  final SingleConnectionEntity? selectedConnection;
  final Map<String, int> categoriesUsersCount;

  ConnectionsLoaded({
    required this.connections,
    required this.filteredConnections,
    this.selectedConnection,
    required this.categoriesUsersCount,
  });

  ConnectionsLoaded copyWith({
    List<SingleConnectionEntity>? connections,
    List<SingleConnectionEntity>? filteredConnections,
    SingleConnectionEntity? selectedConnection,
    Map<String, int>? categoriesUsersCount,
    bool clearSelectedConnection = false,
  }) {
    return ConnectionsLoaded(
      connections: connections ?? this.connections,
      filteredConnections: filteredConnections ?? this.filteredConnections,
      selectedConnection: clearSelectedConnection
          ? null
          : selectedConnection ?? this.selectedConnection,
      categoriesUsersCount: categoriesUsersCount ?? this.categoriesUsersCount,
    );
  }
}

class ConnectionsError extends ConnectionsState {
  final String message;
  ConnectionsError(this.message);
}

// ─────────────────────────────────────────────────────────────
// Cubit
// ─────────────────────────────────────────────────────────────

class ConnectionsCubit extends Cubit<ConnectionsState> {
  final ConnectionsRepositoryInterface repository;

  ConnectionsCubit({required this.repository}) : super(ConnectionsInitial());

  late BaseMessagingInterfaceParameters currentUser;

  /// ✅ Guard: safely check if currentUser has been initialized
  bool get isCurrentUserInitialized {
    try {
      final _ = currentUser;
      return true;
    } catch (_) {
      return false;
    }
  }

  late Future<List<UserConnectionInterfaceParameters>> Function()
  getAllUsersDate;
  List<UserCategory>? categories;

  Map<String, int> categoriesUsersCount = {};
  SingleConnectionEntity? _selectedConnection;
  SingleConnectionEntity? get selectedConnection => _selectedConnection;
  List<SingleConnectionEntity> _connections = [];
  List<SingleConnectionEntity> get connections => _connections;
  List<SingleConnectionEntity> filteredConnections = [];

  late TextEditingController searchController;
  SortEnum? sortType;
  late UserCategory selectedTab;

  void initialize({
    required TextEditingController searchController,
    required SortEnum? sortType,
    required UserCategory selectedTab,
  }) {
    this.searchController = searchController;
    this.sortType = sortType;
    this.selectedTab = selectedTab;
  }

  // ─────────────────────────────────────────────────────────
  // getAllAppUsersInConnectionForm
  // ─────────────────────────────────────────────────────────
  Future<void> getAllAppUsersInConnectionForm() async {
    _connections = [];
    filteredConnections = [];

    log('🔄 getAllAppUsersInConnectionForm: starting stream...');

    GetAllAppUsersInConnectionFormUseCase(connectionRepository: repository)
        .execute(
      currentUserId: currentUser.userId,
      getAllUsers: getAllUsersDate,
      categories: categories!,
    )
        .listen((event) {
      log("📡 stream at connections at controller level is called");

      if (event.isRight()) {
        _connections = event.getOrElse(() => []);
        log("✅ Total connections loaded: ${_connections.length}");

        for (var c in _connections) {
          log(
              "  → name: ${c.primaryLanguageName} | messageType: ${c.messageType} | isNone: ${c.messageType == MessageTypes.none}");
        }

        _getCategoriesUsersCount();
        filteredSingleConnections();
        _updateSelectedConnection();

        log(
            "✅ filteredConnections after filter: ${filteredConnections.length}");

        emit(ConnectionsLoaded(
          connections: _connections,
          filteredConnections: filteredConnections,
          selectedConnection: _selectedConnection,
          categoriesUsersCount: categoriesUsersCount,
        ));
      } else {
        log('❌ error: ${event.leftMap((l) => l.errMessage)}');
        emit(ConnectionsError(
            event.fold((l) => l.errMessage, (r) => 'Unknown error')));
      }
    }, onError: (Object error, StackTrace stackTrace) {
      // Error handling moved out of the domain use case (§11.2): the stream
      // now surfaces failures here so the cubit can emit an error state.
      log('❌ stream error in getAllAppUsersInConnectionForm: $error');
      emit(ConnectionsError(error.toString()));
    });

    log('📤 getAllAppUsersInConnectionForm: listener attached');
  }

  // ─────────────────────────────────────────────────────────
  // createNewConnection
  // ─────────────────────────────────────────────────────────
  Future<Either<Failure, void>> createNewConnection({
    required BaseMessagingInterfaceParameters currentUser,
    required BaseMessagingInterfaceParameters newConnectionUser,
  }) async {
    log('🔗 creating new connection');
    return await CreateNewConnectionUseCase(connectionRepository: repository)
        .createNewConnection(
      currentUser: currentUser,
      newConnectionUser: newConnectionUser,
    );
  }

  // ─────────────────────────────────────────────────────────
  // filteredSingleConnections
  // ─────────────────────────────────────────────────────────
  void filteredSingleConnections() {
    log(
        '🔍 filteredSingleConnections: searchText="${searchController.text}"');
    filteredConnections = [];

    if (searchController.text.isEmpty) {
      noSearchFilteredData();
    } else {
      searchFilteredData();
    }

    sortConnections();

    log("🔍 filteredSingleConnections result: ${filteredConnections.length}");

    if (state is ConnectionsLoaded) {
      emit((state as ConnectionsLoaded).copyWith(
        filteredConnections: filteredConnections,
      ));
    }
  }

  // ─────────────────────────────────────────────────────────
  // searchFilteredData
  // ─────────────────────────────────────────────────────────
  void searchFilteredData() {
    log("🔎 searchFilteredData: _connections.length=${_connections.length}");
    for (SingleConnectionEntity connection in _connections) {
      bool isSelected = false;

      isSelected |= connection.primaryLanguageName
          .toLowerCase()
          .contains(searchController.text.toLowerCase());

      if (connection.secondaryLanguageName != null)
        isSelected |= connection.secondaryLanguageName!
            .toLowerCase()
            .contains(searchController.text.toLowerCase());

      if (connection.primaryLanguageSubInfo != null)
        isSelected |= connection.primaryLanguageSubInfo!
            .toLowerCase()
            .contains(searchController.text.toLowerCase());

      if (connection.secondaryLanguageSubInfo != null)
        isSelected |= connection.secondaryLanguageSubInfo!
            .toLowerCase()
            .contains(searchController.text.toLowerCase());

      if (selectedTab.categoryId != categories![0].categoryId) {
        isSelected &=
            connection.userCategory?.categoryId == selectedTab.categoryId;
      }

      if (isSelected) {
        filteredConnections.add(connection);
      }
    }
    log("🔎 searchFilteredData result: ${filteredConnections.length}");
  }

  // ─────────────────────────────────────────────────────────
  // noSearchFilteredData
  // ─────────────────────────────────────────────────────────
  void noSearchFilteredData() {
    log(
        "📋 noSearchFilteredData: _connections.length=${_connections.length}");
    filteredConnections = [];

    for (SingleConnectionEntity connection in _connections) {
      bool isSelected = true;

      // ⚠️ Comment out the line below to also show connections with no messages yet:
      isSelected &= connection.messageType != MessageTypes.none;

      log(
          "  📌 ${connection.primaryLanguageName} | messageType: ${connection.messageType} | passes filter: $isSelected");

      if (selectedTab.categoryId != categories![0].categoryId) {
        isSelected &=
            connection.userCategory?.categoryId == selectedTab.categoryId;
      }

      if (isSelected) {
        log("  ✅ added: ${connection.primaryLanguageName}");
        filteredConnections.add(connection);
      }
    }

    log("📋 noSearchFilteredData result: ${filteredConnections.length}");
  }

  // ─────────────────────────────────────────────────────────
  // selectSingleConnection
  // ─────────────────────────────────────────────────────────
  void selectSingleConnection(SingleConnectionEntity connection) {
    _selectedConnection = connection;

    if (state is ConnectionsLoaded) {
      emit((state as ConnectionsLoaded).copyWith(
        selectedConnection: connection,
      ));
    }
  }

  void _updateSelectedConnection() {
    if (_selectedConnection == null) return;
    try {
      for (var connection in _connections) {
        if (connection.connectionId == _selectedConnection?.connectionId) {
          _selectedConnection = connection;
          break;
        }
      }
    } catch (e) {
      log('⚠️ _updateSelectedConnection error: $e');
    }
  }

  void _getCategoriesUsersCount() {
    if (categories == null) {
      log('⚠️ _getCategoriesUsersCount: categories is null, skipping');
      return;
    }

    categoriesUsersCount = {};
    for (var category in categories!) {
      categoriesUsersCount[category.categoryId] = 0;
    }

    for (var connection in _connections) {
      if (connection.userCategory != null &&
          connection.messageType != MessageTypes.none) {
        categoriesUsersCount[categories![0].categoryId] =
            (categoriesUsersCount[categories![0].categoryId] ?? 0) + 1;
        categoriesUsersCount[connection.userCategory!.categoryId] =
            (categoriesUsersCount[connection.userCategory!.categoryId] ?? 0) +
                1;
      }
    }

    log("📊 categoriesUsersCount: $categoriesUsersCount");
  }

  List<SingleConnectionEntity> getAllConnections() {
    log("📦 getAllConnections: ${_connections.length}");
    return _connections;
  }

  void sortConnections() {
    if (sortType == null) {
      log("⏭️ sortConnections: sortType is null, skipping");
      return;
    }
    switch (sortType!) {
      case SortEnum.ReadMessages:
        filteredConnections.sort(
                (a, b) => b.myNumUnreadMessage.compareTo(a.myNumUnreadMessage));
        break;
      case SortEnum.UnRead:
        filteredConnections.sort(
                (a, b) => a.myNumUnreadMessage.compareTo(b.myNumUnreadMessage));
        break;
    }
  }

  Future<void> selectConnection(
      SingleConnectionEntity connection, BuildContext context) async {
    log("🚀 selectConnection: ${connection.primaryLanguageName}");
    selectSingleConnection(connection);

    final singleChatCubit = context.read<SingleChatCubit>();

    await singleChatCubit.startChat(
      otherSideData: _selectedConnection!,
      currentUserData: currentUser,
    );

    singleChatCubit.getFirstUnreadIndex();

    if (MediaQuery.of(context).size.width >= 600) {
      log("📱 selectConnection: tablet mode, staying on same page");
    } else {
      log("📱 selectConnection: mobile mode, navigating to chat...");

      // ── Pure Bloc: push ChatMobileView with the active cubits (§3) ──
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatMobileView(
            masterChatCubit: singleChatCubit,
            connectionsCubit: this,
          ),
        ),
      );
    }
  }
}