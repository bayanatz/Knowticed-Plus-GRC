/// Module: database / db1_create_database / domain / usecases
///
///*************************** FILE INFO ****************************///
/// File Name: database_grant_editor.dart
/// Description: Declares `DatabaseGrantEditor`.
/// Author: Amr Mesbah
/// Created at: 24/10/2026
///
/// Every change the access screens make to a list of grants, as plain Dart
/// over entities. The create wizard (`CreateDatabaseCubit`) and the access
/// editor (`EditDatabaseAccessCubit`) both call these, so the two screens
/// cannot drift apart. Each method takes the current grants and returns the
/// new list; nothing here holds state.
library;

import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_department.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';

/// The grant operations shared by the create wizard and the access editor.
abstract final class DatabaseGrantEditor {
  // ── Finding grants ──────────────────────────────────────────────────────

  /// Function Name: [grantFor]
  ///
  /// Purpose: The grant [scope] names — the individual grant when [scope] is
  /// null, otherwise that department's grant.
  ///
  /// Parameters: [grants] the current grants; [scope] a department id or null.
  ///
  /// Returns: [DatabaseAccessGrant?] null when there is none yet.
  static DatabaseAccessGrant? grantFor(
    List<DatabaseAccessGrant> grants,
    String? scope,
  ) {
    for (final DatabaseAccessGrant g in grants) {
      if (scope == null ? !g.isDepartmentScoped : g.departmentId == scope) {
        return g;
      }
    }
    return null;
  }

  /// Function Name: [grantForMember]
  ///
  /// Purpose: The one-person grant holding exactly [member], as the access
  /// editor's Restricted screen keeps one grant per person.
  ///
  /// Parameters: [grants] the current grants; [member] the person.
  ///
  /// Returns: [DatabaseAccessGrant?] null while they are not picked.
  static DatabaseAccessGrant? grantForMember(
    List<DatabaseAccessGrant> grants,
    DatabaseMember member,
  ) {
    for (final DatabaseAccessGrant g in grants) {
      if (!g.isDepartmentScoped && g.members.contains(member)) return g;
    }
    return null;
  }

  /// Function Name: [emptyGrantFor]
  ///
  /// Purpose: A new grant for [departmentId] with nobody on it yet, carrying
  /// the department's names when it is in [departments].
  ///
  /// Parameters: [departmentId] null for the individual grant;
  /// [departments] the directory's departments.
  ///
  /// Returns: [DatabaseAccessGrant].
  static DatabaseAccessGrant emptyGrantFor(
    String? departmentId,
    List<DatabaseDepartment> departments,
  ) {
    if (departmentId == null) {
      return const DatabaseAccessGrant(members: <DatabaseMember>[]);
    }
    DatabaseDepartment? match;
    for (final DatabaseDepartment d in departments) {
      if (d.id == departmentId) {
        match = d;
        break;
      }
    }
    return DatabaseAccessGrant(
      departmentId: departmentId,
      departmentNameEn: match?.nameEn,
      departmentNameAr: match?.nameAr,
      members: const <DatabaseMember>[],
    );
  }

  // ── Grouped grants (create wizard, Open access) ──────────────────────────

  /// Function Name: [toggleMember]
  ///
  /// Purpose: Add [member] to the grant [scope] names, or remove them when
  /// they are already on it. The grant is created on the first pick.
  ///
  /// Parameters: [grants] the current grants; [scope] a department id, or
  /// null for the individual grant; [member] the person tapped;
  /// [departments] for naming a new department grant.
  ///
  /// Returns: [List<DatabaseAccessGrant>] the new grants.
  static List<DatabaseAccessGrant> toggleMember(
    List<DatabaseAccessGrant> grants, {
    required String? scope,
    required DatabaseMember member,
    required List<DatabaseDepartment> departments,
  }) {
    final DatabaseAccessGrant existing =
        grantFor(grants, scope) ?? emptyGrantFor(scope, departments);
    final List<DatabaseMember> members = List<DatabaseMember>.from(
      existing.members,
    );
    if (!members.remove(member)) members.add(member);
    return replace(
      grants,
      existing,
      existing.copyWith(members: members),
      dropIfEmpty: true,
    );
  }

  /// Function Name: [toggleAll]
  ///
  /// Purpose: Put every person in [visible] on the grant [scope] names, or
  /// take them all off when they are already all on it.
  ///
  /// Parameters: as [toggleMember], with [visible] the people on screen.
  ///
  /// Returns: [List<DatabaseAccessGrant>] the new grants.
  static List<DatabaseAccessGrant> toggleAll(
    List<DatabaseAccessGrant> grants, {
    required String? scope,
    required List<DatabaseMember> visible,
    required List<DatabaseDepartment> departments,
  }) {
    if (visible.isEmpty) return grants;
    final DatabaseAccessGrant existing =
        grantFor(grants, scope) ?? emptyGrantFor(scope, departments);
    final bool allIn = visible.every(
      (DatabaseMember m) => existing.members.contains(m),
    );
    final List<DatabaseMember> members = List<DatabaseMember>.from(
      existing.members,
    );
    if (allIn) {
      members.removeWhere(visible.contains);
    } else {
      for (final DatabaseMember m in visible) {
        if (!members.contains(m)) members.add(m);
      }
    }
    return replace(
      grants,
      existing,
      existing.copyWith(members: members),
      dropIfEmpty: true,
    );
  }

  /// Function Name: [removeEverywhere]
  ///
  /// Purpose: Take [member] off every grant — the red minus on the Review
  /// screens. A grant left with nobody on it is dropped.
  ///
  /// Parameters: [grants] the current grants; [member] the person.
  ///
  /// Returns: [List<DatabaseAccessGrant>] the new grants.
  static List<DatabaseAccessGrant> removeEverywhere(
    List<DatabaseAccessGrant> grants,
    DatabaseMember member,
  ) {
    final List<DatabaseAccessGrant> next = <DatabaseAccessGrant>[];
    for (final DatabaseAccessGrant grant in grants) {
      if (!grant.members.contains(member)) {
        next.add(grant);
        continue;
      }
      final List<DatabaseMember> members = List<DatabaseMember>.from(
        grant.members,
      )..remove(member);
      if (members.isNotEmpty) next.add(grant.copyWith(members: members));
    }
    return next;
  }

  /// Function Name: [mutate]
  ///
  /// Purpose: Apply [change] to the grants [departmentId] names — every grant
  /// when it is null — creating the grant when there is none yet. The rule
  /// fields can be filled before anyone is picked, so the change must not be
  /// dropped.
  ///
  /// Parameters: [grants]; [departmentId] the tab or null; [change] the edit;
  /// [departments] for naming a new department grant.
  ///
  /// Returns: [List<DatabaseAccessGrant>] the new grants.
  static List<DatabaseAccessGrant> mutate(
    List<DatabaseAccessGrant> grants, {
    required String? departmentId,
    required DatabaseAccessGrant Function(DatabaseAccessGrant grant) change,
    required List<DatabaseDepartment> departments,
  }) {
    bool matched = false;
    final List<DatabaseAccessGrant> next = grants.map((DatabaseAccessGrant g) {
      if (departmentId != null && g.departmentId != departmentId) return g;
      matched = true;
      return change(g);
    }).toList(growable: false);
    if (matched) return next;
    return <DatabaseAccessGrant>[
      ...next,
      change(emptyGrantFor(departmentId, departments)),
    ];
  }

  /// Function Name: [replace]
  ///
  /// Purpose: Swap grant [from] for [to], appending [to] when [from] was not
  /// in the list. With [dropIfEmpty], a grant with no people AND no rule is
  /// dropped; one that still holds a rule is kept, so unticking the last
  /// person does not clear the fields the user filled.
  ///
  /// Parameters: [grants]; [from] the grant being replaced; [to] its new
  /// version; [dropIfEmpty] whether an empty grant goes.
  ///
  /// Returns: [List<DatabaseAccessGrant>] the new grants.
  static List<DatabaseAccessGrant> replace(
    List<DatabaseAccessGrant> grants,
    DatabaseAccessGrant from,
    DatabaseAccessGrant to, {
    bool dropIfEmpty = false,
  }) {
    final bool keep = !dropIfEmpty || to.members.isNotEmpty || to.hasRule;
    final List<DatabaseAccessGrant> next = <DatabaseAccessGrant>[];
    bool replaced = false;
    for (final DatabaseAccessGrant g in grants) {
      if (identical(g, from) || g.departmentId == from.departmentId) {
        replaced = true;
        if (keep) next.add(to);
      } else {
        next.add(g);
      }
    }
    if (!replaced && keep) next.add(to);
    return next;
  }

  // ── One grant per person (access editor, Restricted access) ─────────────

  /// Function Name: [toggleIndividual]
  ///
  /// Purpose: Add a one-person grant for [member], or drop theirs.
  ///
  /// Parameters: [grants] the current grants; [member] the person tapped.
  ///
  /// Returns: [List<DatabaseAccessGrant>] the new grants.
  static List<DatabaseAccessGrant> toggleIndividual(
    List<DatabaseAccessGrant> grants,
    DatabaseMember member,
  ) {
    final DatabaseAccessGrant? existing = grantForMember(grants, member);
    if (existing != null) {
      return grants
          .where((DatabaseAccessGrant g) => !identical(g, existing))
          .toList(growable: false);
    }
    return <DatabaseAccessGrant>[
      ...grants,
      DatabaseAccessGrant(members: <DatabaseMember>[member]),
    ];
  }

  /// Function Name: [setMemberRule]
  ///
  /// Purpose: Change one person's own level or window. Nothing changes while
  /// they are not picked, so a stray tap cannot create a grant.
  ///
  /// Parameters: [grants]; [member] the person; [permission], [startDate],
  /// [endDate] the fields to change, null to keep.
  ///
  /// Returns: [List<DatabaseAccessGrant>] the new grants.
  static List<DatabaseAccessGrant> setMemberRule(
    List<DatabaseAccessGrant> grants,
    DatabaseMember member, {
    DatabasePermissionLevel? permission,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final DatabaseAccessGrant? existing = grantForMember(grants, member);
    if (existing == null) return grants;
    final DatabaseAccessGrant updated = existing.copyWith(
      permission: permission,
      startDate: startDate,
      endDate: endDate,
    );
    return grants
        .map((DatabaseAccessGrant g) => identical(g, existing) ? updated : g)
        .toList(growable: false);
  }
}
