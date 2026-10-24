/// Module: database
///
///*************************** FILE INFO ****************************///
/// File Name: database_entry.dart
/// Purpose: The Database module's single entry point (K-26). The drawer, the
///          nav bar and `Modules.widget` open the module through this file,
///          so the page behind it can move without touching shared code.
/// Author: Knowticed Plus team
/// Created at: 16/10/2026
///
/// 17/10/2026: also hands the app root the Database module's repositories
/// ([databaseProviders]) — Amr's 16 Oct update reads them with
/// `context.read` from every Database page, cubit and wizard step, so they
/// sit above every navigator (tablet pane, phone tab, wizard).
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/create_database_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/database_directory_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/database_session_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/create_database_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_directory_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_session_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/use_cases/create_database_use_case.dart';
import 'package:knowticed_plus/features/database/db2_database_details/data/repository/database_details_repository.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/base_repository/database_details_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/repository/create_table_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/base_repository/create_table_base_repository.dart';

export 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/pages/database_builder_page.dart'
    show DatabaseBuilderPage;
// Owner 21/10/2026: the shell mounts DatabaseModuleEntry (nested Navigator) so database / table pages keep the rail and top bar.
export 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/pages/database_module_entry.dart'
    show DatabaseModuleEntry;

/// The Database module's repositories, registered once at the app root.
List<RepositoryProvider<Object>> databaseProviders() =>
    <RepositoryProvider<Object>>[
      // Who is signed in, for every record the module stamps (DB-CREATE-02).
      RepositoryProvider<DatabaseSessionBaseRepository>(
        create: (_) => const DatabaseSessionRepository(),
      ),
      // The org directory for the access screens (rule 1).
      RepositoryProvider<DatabaseDirectoryBaseRepository>(
        create: (_) => const DatabaseDirectoryRepository(),
      ),
      RepositoryProvider<CreateDatabaseBaseRepository>(
        create: (_) => CreateDatabaseRepository(),
      ),
      RepositoryProvider<CreateDatabaseUseCase>(
        create: (BuildContext ctx) =>
            CreateDatabaseUseCase(ctx.read<CreateDatabaseBaseRepository>()),
      ),
      RepositoryProvider<DatabaseDetailsBaseRepository>(
        create: (_) => DatabaseDetailsRepository(),
      ),
      RepositoryProvider<CreateTableBaseRepository>(
        create: (_) => CreateTableRepository(),
      ),
    ];
