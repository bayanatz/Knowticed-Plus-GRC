/// Module: database / db1_create_database / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: create_database_flow.dart
/// Description: Declares `CreateDatabaseFlow`.
/// Author: Amr Mesbah
/// Created at: 15/8/2026
///
/// The host that owns the wizard's cubit and its nested Navigator.
///
/// WHY A NESTED NAVIGATOR
/// ----------------------
/// The three steps push and pop between themselves, but the flow as a whole
/// is one destination from the Database Builder list — closing it should
/// return one result, not unwind three routes. A nested Navigator makes
/// "back" inside the wizard mean "previous step".
///
/// THIS IS THE INNER OF TWO NAVIGATORS
/// -----------------------------------
///   DatabaseModuleEntry's   list  <->  wizard   (module pane, keeps the shell)
///   this one                details -> access -> review
///
/// `CreateDatabaseFlow.open` pushes into the OUTER one, so the wizard renders
/// inside the drawer's IndexedStack pane and the nav rail and header stay on
/// screen. Pushing to the root Navigator instead is what previously drew the
/// wizard over the whole window.
///
/// The cubit is created HERE, above that Navigator, which is what lets the
/// draft survive each step being popped. Every screen receives it explicitly
/// rather than reading it from context, so a screen cannot accidentally be
/// used outside the flow that owns its state.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_cubit.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/pages/access_management_page.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/pages/access_review_page.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/pages/create_database_page.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_session_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_directory_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/create_database_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/use_cases/create_database_use_case.dart';
import 'package:knowticed_plus/features/database/helpers/routes/database_routes.dart';

class CreateDatabaseFlow extends StatefulWidget {
  const CreateDatabaseFlow({super.key, this.draft});

  /// A PARKED DRAFT to reopen on, or null to start a new database.
  /// Tapping a draft card in the list comes here rather than to
  /// the details screen, because a draft has nothing for that screen to show:
  /// no granted access, no tables. What it has is unfinished work, and this is
  /// the screen that finishes it.
  ///
  /// The wizard behaves identically either way. The only difference is that
  /// the final write UPDATES this record instead of creating one — see
  /// `CreateDatabaseUseCase.call`.
  final DatabaseEntity? draft;

  /// Opens the wizard and resolves with the saved record, or null if the user
  /// backed out. The list screen awaits this to insert (or swap) the row
  /// without a refetch.
  static Future<DatabaseEntity?> open(
    BuildContext context, {
    DatabaseEntity? draft,
  }) {
    return Navigator.of(context).push<DatabaseEntity>(
      DatabaseRouter.route<DatabaseEntity>(
        DatabaseRoutes.create,
        builder: (_) => BlocProvider<CreateDatabaseCubit>(
          create: (BuildContext ctx) => draft == null
              ? CreateDatabaseCubit(
                  session: ctx.read<DatabaseSessionBaseRepository>(),
                  directory: ctx.read<DatabaseDirectoryBaseRepository>(),
                  repository: ctx.read<CreateDatabaseBaseRepository>(),
                  useCase: ctx.read<CreateDatabaseUseCase>(),
                )
              : CreateDatabaseCubit.resumingDraft(
                  draft: draft,
                  session: ctx.read<DatabaseSessionBaseRepository>(),
                  directory: ctx.read<DatabaseDirectoryBaseRepository>(),
                  repository: ctx.read<CreateDatabaseBaseRepository>(),
                  useCase: ctx.read<CreateDatabaseUseCase>(),
                ),
          child: CreateDatabaseFlow(draft: draft),
        ),
      ),
    );
  }

  @override
  State<CreateDatabaseFlow> createState() => _CreateDatabaseFlowState();
}

class _CreateDatabaseFlowState extends State<CreateDatabaseFlow> {
  late final CreateDatabaseCubit _cubit = context.read<CreateDatabaseCubit>();

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // The form is already filled from the row the list handed over; this
    // fetches the people that row does not carry. A no-op on a new database,
    // so it is called unconditionally rather than behind a null check that
    // would have to be kept in step with the constructor above.
    _cubit.loadDraftGrants();
  }

  /// Closes the wizard by popping the MODULE's navigator — the one
  /// `DatabaseModuleEntry` hosts — so the list comes back with the nav rail
  /// and header still in place. Optionally carries the created record.
  void _closeFlow([DatabaseEntity? created]) {
    Navigator.of(context).pop(created);
  }

  void _push(String name, Widget page) {
    _navigatorKey.currentState?.push(
      DatabaseRouter.route<void>(name, builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateDatabaseCubit>.value(
      value: _cubit,
      child: PopScope(
        // Back at the first step leaves the flow; anywhere deeper it means
        // "previous step", so the inner Navigator handles it first.
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) return;
          final NavigatorState? nav = _navigatorKey.currentState;
          if (nav != null && nav.canPop()) {
            nav.pop();
            return;
          }
          Navigator.of(context).pop(_cubit.state.createdDatabase);
        },
        child: Navigator(
          key: _navigatorKey,
          onGenerateRoute: (RouteSettings settings) {
            return DatabaseRouter.route<void>(
              DatabaseRoutes.createDetails,
              builder: (_) => CreateDatabasePage(
                // THE FLOW'S cubit, passed explicitly. Without it
                // the page fell back to constructing its own, so the one this
                // host built — and seeded from the resumed draft — was never
                // the one on screen. It went unnoticed while both were empty.
                cubit: _cubit,
                // The details card's button reads "Next" here because it is
                // the first of three steps, not a standalone form.
                isStepped: true,
                // Personal Access finishes on the details card itself, so that
                // page needs the same completion hook the Review page has.
                onCompleted: _closeFlow,
                onExit: _closeFlow,
                onNext: (CreateDatabaseCubit cubit) => _push(
                  DatabaseRoutes.createAccess,
                  AccessManagementPage(
                    cubit: cubit,
                    onExit: _closeFlow,
                    onReview: () => _push(
                      DatabaseRoutes.createReview,
                      AccessReviewPage(
                        cubit: cubit,
                        // Closing the wizard is the host's job: this pops the
                        // MODULE's navigator (the one DatabaseModuleEntry
                        // hosts), which is what returns the record to the
                        // list and leaves the rail and header untouched.
                        onCompleted: _closeFlow,
                        onExit: _closeFlow,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
