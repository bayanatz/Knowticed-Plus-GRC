/// Module: database / db1_create_database / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: database_enum_labels.dart
/// Description: Declares the `label` extension for the Database module's enums.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// The enums used to carry their own `labelEn` / `labelAr` text in the domain
/// layer. The names now live in the .arb files (rule 14) and are read here, in
/// presentation, where the strings belong.
library;

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_sort_option.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/enums/database_access_status.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_column_type.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_comments_access.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_import_mode.dart';

extension DatabaseAccessTypeLabel on DatabaseAccessType {
  /// Function Name: [label]
  ///
  /// Purpose: The value's name in the current language, from the .arb files.
  ///
  /// Parameters: [s] the app's strings (`S.of(context)` or `S.current`).
  ///
  /// Returns: [String].
  String label(S s) => switch (this) {
        DatabaseAccessType.open => s.dbAccessTypeOpen,
        DatabaseAccessType.restricted => s.dbAccessTypeRestricted,
        DatabaseAccessType.personal => s.dbAccessTypePersonal,
      };
}

extension DatabasePermissionLevelLabel on DatabasePermissionLevel {
  /// Function Name: [label]
  ///
  /// Purpose: The value's name in the current language, from the .arb files.
  ///
  /// Parameters: [s] the app's strings (`S.of(context)` or `S.current`).
  ///
  /// Returns: [String].
  String label(S s) => switch (this) {
        DatabasePermissionLevel.fullAccess => s.dbPermissionFullAccess,
        DatabasePermissionLevel.edit => s.dbPermissionEdit,
        DatabasePermissionLevel.export => s.dbPermissionExport,
        DatabasePermissionLevel.view => s.dbPermissionView,
        DatabasePermissionLevel.custom => s.dbPermissionCustom,
      };
}

extension DatabaseSortOptionLabel on DatabaseSortOption {
  /// Function Name: [label]
  ///
  /// Purpose: The value's name in the current language, from the .arb files.
  ///
  /// Parameters: [s] the app's strings (`S.of(context)` or `S.current`).
  ///
  /// Returns: [String].
  String label(S s) => switch (this) {
        DatabaseSortOption.ascending => s.dbSortAscending,
        DatabaseSortOption.descending => s.dbSortDescending,
        DatabaseSortOption.lastUpdated => s.dbSortLastUpdated,
      };
}

extension DatabaseAccessStatusLabel on DatabaseAccessStatus {
  /// Function Name: [label]
  ///
  /// Purpose: The value's name in the current language, from the .arb files.
  ///
  /// Parameters: [s] the app's strings (`S.of(context)` or `S.current`).
  ///
  /// Returns: [String].
  String label(S s) => switch (this) {
        DatabaseAccessStatus.active => s.dbAccessStatusActive,
        DatabaseAccessStatus.scheduled => s.dbAccessStatusScheduled,
        DatabaseAccessStatus.deactivated => s.dbAccessStatusDeactivated,
        DatabaseAccessStatus.removed => s.dbAccessStatusRemoved,
      };
}

extension TableColumnTypeLabel on TableColumnType {
  /// Function Name: [label]
  ///
  /// Purpose: The value's name in the current language, from the .arb files.
  ///
  /// Parameters: [s] the app's strings (`S.of(context)` or `S.current`).
  ///
  /// Returns: [String].
  String label(S s) => switch (this) {
        TableColumnType.general => s.dbColumnTypeGeneral,
        TableColumnType.number => s.dbColumnTypeNumber,
        TableColumnType.currency => s.dbColumnTypeCurrency,
        TableColumnType.date => s.dbColumnTypeDate,
        TableColumnType.time => s.dbColumnTypeTime,
        TableColumnType.percentage => s.dbColumnTypePercentage,
      };
}

extension TableCommentsAccessLabel on TableCommentsAccess {
  /// Function Name: [label]
  ///
  /// Purpose: The value's name in the current language, from the .arb files.
  ///
  /// Parameters: [s] the app's strings (`S.of(context)` or `S.current`).
  ///
  /// Returns: [String].
  String label(S s) => switch (this) {
        TableCommentsAccess.private => s.dbCommentsAccessPrivate,
        TableCommentsAccess.shared => s.dbCommentsAccessShared,
      };

  /// Function Name: [hint]
  ///
  /// Purpose: The sentence under the Comments Access field, explaining it.
  ///
  /// Parameters: [s] the app's strings.
  ///
  /// Returns: [String].
  String hint(S s) => switch (this) {
        TableCommentsAccess.private => s.dbCommentsAccessHintPrivate,
        TableCommentsAccess.shared => s.dbCommentsAccessHintShared,
      };
}

extension TableImportModeLabel on TableImportMode {
  /// Function Name: [label]
  ///
  /// Purpose: The value's name in the current language, from the .arb files.
  ///
  /// Parameters: [s] the app's strings (`S.of(context)` or `S.current`).
  ///
  /// Returns: [String].
  String label(S s) => switch (this) {
        TableImportMode.overwrite => s.dbImportModeOverwrite,
        TableImportMode.append => s.dbImportModeAppend,
      };
}
