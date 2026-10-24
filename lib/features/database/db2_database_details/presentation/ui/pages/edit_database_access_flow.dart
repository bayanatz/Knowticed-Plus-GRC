/// Module: database / db2_database_details / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: edit_database_access_flow.dart
/// Description: Declares `EditDatabaseAccessFlow`.
/// Author: Amr Mesbah
/// Created at: 16/8/2026
///
/// The host that owns the access editor's cubit and its nested Navigator —
/// the same arrangement as db1's `CreateDatabaseFlow`, and for the same
/// reasons.
///
/// WHY A NESTED NAVIGATOR FOR TWO SCREENS
/// --------------------------------------
/// The Open Access path is two steps — pick departments and people
/// (7398:9476), then review permissions per department (7398:18356) — and
/// "back" from the review has to mean "previous step", not "abandon the edit".
/// The whole editor is ONE destination from the Access screen and resolves
/// with one result, so unwinding two routes into the caller would be wrong.
///
/// The cubit is created HERE, above that Navigator, which is what lets the
/// draft survive the review screen being popped. Both screens receive it
/// explicitly rather than reading it from context, so neither can be used
/// outside the flow that owns its state.
///
/// The Restricted and Personal paths are a single screen and never push, which
/// costs this arrangement nothing.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_cubit.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/controller/edit_database_access_cubit.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/pages/edit_access_review_page.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/pages/edit_database_access_page.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_session_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_directory_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/create_database_base_repository.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/base_repository/database_details_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/use_cases/create_database_use_case.dart';
import 'package:knowticed_plus/features/database/helpers/routes/database_routes.dart';

class EditDatabaseAccessFlow extends StatefulWidget {
  const EditDatabaseAccessFlow({
    super.key,
    required this.database,
    required this.records,
    required this.accessVersion,
  });

  final DatabaseEntity database;

  /// The grants as the Access screen read them. Passed in rather than re-read
  /// so both screens edit ONE snapshot — two reads a second apart can already
  /// disagree, and the one that loses would silently revoke somebody.
  final List<DatabaseAccessGrantRecord> records;

  /// The access version [records] were read at (DB-DETAILS-04).
  final int accessVersion;

  /// Opens the editor and resolves with the refreshed record, or null when the
  /// user backed out without saving.
  static Future<DatabaseEntity?> open(
    BuildContext context, {
    required DatabaseEntity database,
    required List<DatabaseAccessGrantRecord> records,
    required int accessVersion,
  }) {
    return Navigator.of(context).push<DatabaseEntity>(
      DatabaseRouter.route<DatabaseEntity>(
        DatabaseRoutes.editAccess,
        builder: (_) => BlocProvider<EditDatabaseAccessCubit>(
          create: (BuildContext ctx) => EditDatabaseAccessCubit(
            database: database,
            records: records,
            expectedAccessVersion: accessVersion,
            session: ctx.read<DatabaseSessionBaseRepository>(),
            directory: ctx.read<DatabaseDirectoryBaseRepository>(),
            repository: ctx.read<DatabaseDetailsBaseRepository>(),
            createRepository: ctx.read<CreateDatabaseBaseRepository>(),
            useCase: ctx.read<CreateDatabaseUseCase>(),
          ),
          child: EditDatabaseAccessFlow(
            database: database,
            records: records,
            accessVersion: accessVersion,
          ),
        ),
      ),
    );
  }

  @override
  State<EditDatabaseAccessFlow> createState() => _EditDatabaseAccessFlowState();
}

class _EditDatabaseAccessFlowState extends State<EditDatabaseAccessFlow> {
  late final EditDatabaseAccessCubit _cubit =
      context.read<EditDatabaseAccessCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.seed();
  }

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// Closes the editor by popping the route the Access screen pushed —
  /// deliberately `Navigator.of(context)`, the OUTER navigator, not the inner
  /// one this widget hosts.
  void _closeFlow([DatabaseEntity? saved]) {
    Navigator.of(context).pop(saved);
  }

  void _openReview() {
    _navigatorKey.currentState?.push(
      DatabaseRouter.route<void>(
        DatabaseRoutes.editAccessReview,
        builder: (_) => EditAccessReviewPage(
          cubit: _cubit,
          onCompleted: _closeFlow,
          onExit: _closeFlow,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateDatabaseCubit>.value(
      // Provided under the SUPERTYPE because every widget this flow reuses
      // from db1 — `AccessRuleFields`, the member grid's callbacks — is
      // written against `CreateDatabaseCubit`. The instance is the editing
      // subclass; nothing downstream needs to know that.
      value: _cubit,
      child: PopScope(
        // Back on the first screen leaves the editor; on the review screen it
        // means "previous step", so the inner Navigator gets first refusal.
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) return;
          final NavigatorState? nav = _navigatorKey.currentState;
          if (nav != null && nav.canPop()) {
            nav.pop();
            return;
          }
          _closeFlow(_cubit.savedDatabase);
        },
        child: Navigator(
          key: _navigatorKey,
          onGenerateRoute: (RouteSettings settings) {
            return DatabaseRouter.route<void>(
              DatabaseRoutes.editAccessPeople,
              builder: (_) => EditDatabaseAccessPage(
                cubit: _cubit,
                onReview: _openReview,
                onCompleted: _closeFlow,
                onExit: _closeFlow,
              ),
            );
          },
        ),
      ),
    );
  }
}
