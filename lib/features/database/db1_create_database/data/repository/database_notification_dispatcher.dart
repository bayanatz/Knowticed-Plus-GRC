/// Module: database / db1_create_database / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: database_notification_dispatcher.dart
/// Description: Turns a completed database write into the notifications it owes.
/// Author: Amr Mesbah
/// Created at: 17/8/2026
///
/// The database side of the notification wiring. `DatabaseNotificationService`
/// (in the notification feature) knows how to SEND each of the thirteen §1.7
/// events and takes nothing but plain strings; this class knows WHO to send
/// them to and WHICH ones a given save earned, and it is the only thing that
/// speaks both languages.
///
/// ─── WHY IT IS HERE AND NOT IN THE NOTIFICATION FEATURE ──────────────
/// It reads `DatabaseAccessGrant`, `DatabaseMember` and db1's repository. A
/// feature raises its OWN notifications, so the dependency runs
/// database → notification and never back; putting this logic beside the
/// sender would make the notification feature import three database entities
/// and a repository, and every future database entity after them.
///
/// ─── WHY IT IS IN db1 ────────────────────────────────────────────────
/// db2 and db3 already import db1's entities, constants and repository; db1
/// imports neither of them. Recipients always come from a DATABASE's grants —
/// including for table events — so this needs db1's `fetchGrants` and nothing
/// of db2's or db3's. Table names arrive as strings for the same reason: taking
/// a `DatabaseTableEntity` would point db1 at db3.
///
/// ─── NAMES ARRIVE IN BOTH LANGUAGES ──────────────────────────────────
/// Every name parameter is a `…En` / `…Ar` pair and is passed on as BOTH, each
/// side falling back to the other when empty. The English text gets the English
/// names and the Arabic text the Arabic ones, and each reader sees their own
/// language — never the actor's (DB-CREATE-06).
///
/// ─── NOTHING RETHROWS, NOTHING IS SILENT ─────────────────────────────
/// A notification is a side effect of a write that has ALREADY succeeded. If
/// FCM is unreachable or a template read times out, the user's database still
/// exists and the screen must still say so. Nothing here rethrows, and callers
/// are expected to `await` these only to keep the call ordered — never to learn
/// whether the write worked.
///
/// But a failure is never mistaken for "nobody to tell" (DB-CREATE-07): when the
/// recipients cannot be read, [databaseRecipients] returns the failure, and the
/// event logs that it was NOT sent.
///
/// ─── FIRE-AND-FORGET IS THE CALLER'S CHOICE ──────────────────────────
/// These are `Future<void>`. A cubit that awaits one holds its success state
/// back until the sends finish, which on a nine-person grant is nine template
/// reads plus nine pushes. Cubits therefore call these WITHOUT awaiting, after
/// emitting success — see `CreateDatabaseCubit._write`.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/create_database_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/database_notification_service.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/generated/intl/messages_all.dart';

/// Who is doing the thing, in the language it will be announced in.
///
/// Resolved once per dispatch rather than per recipient: a save that notifies
/// nine people has one actor, and `getEmployeeNameEnglishArabic` walks the
/// directory map on every call.
class DatabaseNotificationActor {
  const DatabaseNotificationActor({required this.email, required this.name});

  final String email;

  /// In both languages: each reader sees their own (DB-CREATE-06).
  final LocalizedName name;
}

abstract final class DatabaseNotificationDispatcher {
  const DatabaseNotificationDispatcher._();

  /// How many `columnAdded` notifications one save may send.
  ///
  /// The spec's body names the column ("A new column, {{columnName}}, has
  /// been..."), so there is no plural form to fall back on — a save that added
  /// twenty columns would be twenty notifications per recipient. Past this
  /// count the individual ones are dropped and `tableStructureUpdated` carries
  /// the news instead, which is what it is for.
  static const int maxColumnNotifications = 5;

  /// More than one person affected by one access save makes it a BULK update in
  /// the spec's sense (§1.7 row 10) — the actor gets the summary receipt on top
  /// of the individual notifications the affected people get.
  static const int bulkThreshold = 2;

  // ═══════════════════════════════════════════════════════════
  // Actor / recipients
  // ═══════════════════════════════════════════════════════════

  /// The signed-in user, or the system sentinel when nobody is.
  ///
  /// GetX in a data-layer file is the same escape hatch `calendar_data_service`
  /// documents: `Constant.emailUser` and the employee directory are only
  /// reachable through the controller today. Every public method below takes an
  /// `actor` override, so nothing here is untestable — pass one and this is
  /// never called.
  static DatabaseNotificationActor resolveActor() {
    final String email = (Constant.emailUser ?? '').trim();
    if (email.isEmpty) {
      return const DatabaseNotificationActor(
        email: DatabaseNotificationService.systemSender,
        name: (en: '', ar: ''),
      );
    }

    // Both spellings: the English text names the actor in English and the
    // Arabic text in Arabic, whatever language the actor is using.
    String en = '';
    String ar = '';
    try {
      if (Get.isRegistered<MainCoreEmployeeController>()) {
        final MainCoreEmployeeController directory =
            Get.find<MainCoreEmployeeController>();
        en = directory.getEmployeeNameEnglishArabic(email, true).trim();
        ar = directory.getEmployeeNameEnglishArabic(email, false).trim();
      }
    } catch (error) {
      // The notification still goes out, naming the actor by email.
      if (kDebugMode) {
        debugPrint(
          '🔴 [DatabaseNotificationDispatcher] actor name lookup failed: $error',
        );
      }
    }
    return DatabaseNotificationActor(
      email: email,
      name: _pair(en.isEmpty ? email : en, ar.isEmpty ? email : ar),
    );
  }

  /// Emails on [grants], deduped, minus [exclude].
  ///
  /// A member with no stored email is skipped rather than sent to: the grant
  /// carries the email as a snapshot and older rows may not have one.
  /// `AppNotificationSender` refuses an empty receiver anyway, so this only
  /// keeps the counts honest.
  static Set<String> recipientsOf(
    Iterable<DatabaseAccessGrant> grants, {
    String? exclude,
  }) {
    final String? excluded = exclude?.trim().toLowerCase();
    final Set<String> emails = <String>{};

    for (final DatabaseAccessGrant grant in grants) {
      for (final DatabaseMember member in grant.members) {
        final String email = (member.email ?? '').trim();
        if (email.isEmpty) continue;
        if (email.toLowerCase() == excluded) continue;
        emails.add(email);
      }
    }
    return emails;
  }

  /// Everyone holding a grant on [databaseId] right now, minus the actor.
  ///
  /// Used by the TABLE events, which have no grant list of their own to read: a
  /// table's structural news is relevant to whoever can see the database it
  /// sits in.
  ///
  /// Function Name: [databaseRecipients]
  ///
  /// Parameters: [databaseId]; [actorEmail] is left out of the result;
  /// [repository] reads the grants — the caller's injected repository.
  ///
  /// Returns: [Either<Failure, Set<String>>] — a FAILED read is a [Failure],
  /// not an empty set, so the caller can tell "the grants could not be read"
  /// from "nobody holds a grant" (DB-CREATE-07).
  static Future<Either<Failure, Set<String>>> databaseRecipients(
    String databaseId, {
    required String actorEmail,
    required CreateDatabaseBaseRepository repository,
  }) async {
    if (databaseId.isEmpty) {
      return const Right<Failure, Set<String>>(<String>{});
    }
    try {
      final Either<Failure, List<DatabaseAccessGrant>> result =
          await repository.fetchGrants(databaseId);
      return result.map(
        (List<DatabaseAccessGrant> grants) =>
            recipientsOf(grants, exclude: actorEmail),
      );
    } catch (error) {
      return Left<Failure, Set<String>>(FeatureFailure(error.toString()));
    }
  }

  /// The recipients of a table event, or null when they could not be read —
  /// in which case the failure is logged and the event is not sent.
  static Future<Set<String>?> _tableEventRecipients(
    String databaseId, {
    required String actorEmail,
    required String event,
    required CreateDatabaseBaseRepository repository,
  }) async {
    final Either<Failure, Set<String>> result = await databaseRecipients(
      databaseId,
      actorEmail: actorEmail,
      repository: repository,
    );
    return result.fold((Failure failure) {
      // No ids or emails in the log (rule 12): the event and the reason.
      if (kDebugMode) {
        debugPrint(
          '🔴 [DatabaseNotificationDispatcher] $event NOT sent: '
          'the access grants could not be read (${failure.errMessage})',
        );
      }
      return null;
    }, (Set<String> recipients) => recipients);
  }

  // ═══════════════════════════════════════════════════════════
  // db1 — the create wizard
  // ═══════════════════════════════════════════════════════════

  /// Function Name: [databaseCreated]
  ///
  /// Purpose: Announce a finished database and each window it opened.
  ///
  /// TWO KINDS OF NOTIFICATION, DELIBERATELY. `databaseCreated` is the news
  /// ("X created HR Database"), broadcast to everyone on it; `accessGranted` is
  /// each person's own window ("you have Edit until 30 Sep"), which cannot be
  /// broadcast because every value in it differs per grant.
  ///
  /// Call this ONLY for a finished write. A record parked by "Save For Later"
  /// has granted nobody anything yet — notifying its members would announce a
  /// database that appears in no list but Drafts.
  static Future<void> databaseCreated({
    String databaseId = '',
    required String databaseNameEn,
    required String databaseNameAr,
    required List<DatabaseAccessGrant> grants,
    DatabaseNotificationActor? actor,
  }) async {
    await _ensureBothLanguages();
    final DatabaseNotificationActor who = actor ?? resolveActor();

    final Set<String> recipients = recipientsOf(grants, exclude: who.email);
    if (recipients.isEmpty) return;

    final LocalizedName databaseName = _pair(databaseNameEn, databaseNameAr);
    final LocalizedName scope = DatabaseNotificationService.allTables;

    await DatabaseNotificationService.databaseCreated(
      databaseId: databaseId,
      actorEmail: who.email,
      actorName: who.name,
      databaseName: databaseName,
      recipients: recipients,
    );

    await _announceGrants(
      databaseId: databaseId,
      grants: grants,
      databaseName: databaseName,
      tableName: scope,
      who: who,
    );

    if (recipients.length >= bulkThreshold) {
      await DatabaseNotificationService.bulkAccessUpdate(
        databaseId: databaseId,
        actorEmail: who.email,
        actorName: who.name,
        databaseName: databaseName,
        tableName: scope,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // db2 / db3 — access edits
  // ═══════════════════════════════════════════════════════════

  /// Function Name: [accessSaved]
  ///
  /// Purpose: Work out what changed for whom, and tell each of them.
  ///
  /// [before] is the grants as they were LOADED, [after] the grants just
  /// written. The diff is by `employeeId` (`DatabaseMember`'s identity), so a
  /// person moved between two grants in one save is an UPDATE, not a revoke
  /// followed by a grant — which is what a naive per-grant comparison would
  /// report, and would tell them twice.
  ///
  /// Three outcomes per person:
  ///   • in [after] only            → accessGranted
  ///   • in both, rule differs      → accessUpdated
  ///   • in [before] only           → accessRevoked
  ///
  /// A person in both whose rule is IDENTICAL gets nothing. Every access save
  /// rewrites the whole subcollection, so without that check re-saving one
  /// person's dates would notify all nine.
  ///
  /// [tableNameEn] / [tableNameAr] are null for a database-level save and the
  /// table's names for a table-level one; they decide both what the bodies say
  /// and whether [viewableFieldsChanged] can mean anything.
  static Future<void> accessSaved({
    String databaseId = '',
    String tableId = '',
    required String databaseNameEn,
    required String databaseNameAr,
    String? tableNameEn,
    String? tableNameAr,
    required List<DatabaseAccessGrant> before,
    required List<DatabaseAccessGrant> after,
    bool viewableFieldsChanged = false,
    DatabaseNotificationActor? actor,
  }) async {
    await _ensureBothLanguages();
    final DatabaseNotificationActor who = actor ?? resolveActor();

    final LocalizedName databaseName = _pair(databaseNameEn, databaseNameAr);

    final bool isTableLevel = (tableNameEn?.isNotEmpty ?? false) ||
        (tableNameAr?.isNotEmpty ?? false);
    final LocalizedName? tableName =
        isTableLevel ? _pair(tableNameEn ?? '', tableNameAr ?? '') : null;
    final LocalizedName scope =
        tableName ?? DatabaseNotificationService.allTables;

    final Map<String, _MemberGrant> was = _byEmployee(before);
    final Map<String, _MemberGrant> now = _byEmployee(after);

    int affected = 0;

    for (final MapEntry<String, _MemberGrant> entry in now.entries) {
      final _MemberGrant current = entry.value;
      final String email = (current.member.email ?? '').trim();
      if (email.isEmpty) continue;
      if (email.toLowerCase() == who.email.toLowerCase()) continue;

      final _MemberGrant? previous = was[entry.key];

      if (previous == null) {
        affected++;
        await DatabaseNotificationService.accessGranted(
          databaseId: databaseId,
          tableId: tableId,
          actorEmail: who.email,
          recipientEmail: email,
          databaseName: databaseName,
          tableName: scope,
          permissionLabel: _permissionLabel(current.grant),
          startDate: current.grant.startDate,
          endDate: current.grant.endDate,
        );
        continue;
      }

      if (_ruleChanged(previous.grant, current.grant)) {
        affected++;
        await DatabaseNotificationService.accessUpdated(
          databaseId: databaseId,
          tableId: tableId,
          actorEmail: who.email,
          recipientEmail: email,
          databaseName: databaseName,
          tableName: scope,
        );
      }
    }

    for (final MapEntry<String, _MemberGrant> entry in was.entries) {
      if (now.containsKey(entry.key)) continue;

      final String email = (entry.value.member.email ?? '').trim();
      if (email.isEmpty) continue;
      if (email.toLowerCase() == who.email.toLowerCase()) continue;

      affected++;
      await DatabaseNotificationService.accessRevoked(
        databaseId: databaseId,
        tableId: tableId,
        actorEmail: who.email,
        actorName: who.name,
        recipientEmail: email,
        databaseName: databaseName,
        tableName: scope,
      );
    }

    // Field visibility is a TABLE-level notion: `viewableFields` holds column
    // ids, and a database grant has no columns to name. A database-level save
    // that somehow flagged this is ignored rather than sent with a scope its
    // own body cannot describe.
    if (viewableFieldsChanged && tableName != null) {
      final Set<String> remaining = recipientsOf(after, exclude: who.email);
      if (remaining.isNotEmpty) {
        await DatabaseNotificationService.viewableFieldsUpdated(
          databaseId: databaseId,
          tableId: tableId,
          actorEmail: who.email,
          tableName: tableName,
          recipients: remaining,
        );
      }
    }

    if (affected >= bulkThreshold) {
      await DatabaseNotificationService.bulkAccessUpdate(
        databaseId: databaseId,
        tableId: tableId,
        actorEmail: who.email,
        actorName: who.name,
        databaseName: databaseName,
        tableName: scope,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // db3 — tables
  // ═══════════════════════════════════════════════════════════

  /// Function Name: [tableCreated]
  ///
  /// Purpose: Tell the database's members a table was added.
  static Future<void> tableCreated({
    required String databaseId,
    required String databaseNameEn,
    required String databaseNameAr,
    required String tableNameEn,
    required String tableNameAr,
    required CreateDatabaseBaseRepository repository,
    DatabaseNotificationActor? actor,
  }) async {
    final DatabaseNotificationActor who = actor ?? resolveActor();

    final Set<String>? recipients = await _tableEventRecipients(
      databaseId,
      actorEmail: who.email,
      event: 'tableCreated',
      repository: repository,
    );
    if (recipients == null || recipients.isEmpty) return;

    await DatabaseNotificationService.tableCreated(
      databaseId: databaseId,
      actorEmail: who.email,
      actorName: who.name,
      databaseName: _pair(databaseNameEn, databaseNameAr),
      tableName: _pair(tableNameEn, tableNameAr),
      recipients: recipients,
    );
  }

  /// Function Name: [tableSaved]
  ///
  /// Purpose: The edit-card counterpart — up to three different pieces of news
  /// out of one save.
  ///
  /// The three are independent and any combination can fire:
  ///   [detailsChanged]   the name, description or comments-access moved
  ///                                                      → tableUpdated
  ///   [addedColumnNames] new columns, named               → columnAdded ×N
  ///   [structureChanged] columns removed, reordered or
  ///                      retyped, or more than
  ///                      [maxColumnNotifications] added   → tableStructureUpdated
  ///
  /// A save that changed only the comments-access dropdown counts as
  /// [detailsChanged]: that event's body says "the table name, description, or
  /// associated metadata", which is what the setting is.
  static Future<void> tableSaved({
    required String databaseId,
    required String databaseNameEn,
    required String databaseNameAr,
    required String tableNameEn,
    required String tableNameAr,
    bool detailsChanged = false,
    bool structureChanged = false,
    List<String> addedColumnNames = const <String>[],
    required CreateDatabaseBaseRepository repository,
    DatabaseNotificationActor? actor,
  }) async {
    if (!detailsChanged && !structureChanged && addedColumnNames.isEmpty) {
      return;
    }

    final DatabaseNotificationActor who = actor ?? resolveActor();

    final Set<String>? recipients = await _tableEventRecipients(
      databaseId,
      actorEmail: who.email,
      event: 'tableSaved',
      repository: repository,
    );
    if (recipients == null || recipients.isEmpty) return;

    final LocalizedName tableName = _pair(tableNameEn, tableNameAr);

    if (detailsChanged) {
      await DatabaseNotificationService.tableUpdated(
        databaseId: databaseId,
        actorEmail: who.email,
        actorName: who.name,
        tableName: tableName,
        recipients: recipients,
      );
    }

    final bool tooManyColumns =
        addedColumnNames.length > maxColumnNotifications;

    if (!tooManyColumns) {
      for (final String column in addedColumnNames) {
        final String name = column.trim();
        if (name.isEmpty) continue;
        await DatabaseNotificationService.columnAdded(
          databaseId: databaseId,
          actorEmail: who.email,
          columnName: name,
          tableName: tableName,
          recipients: recipients,
        );
      }
    }

    if (structureChanged || tooManyColumns) {
      await DatabaseNotificationService.tableStructureUpdated(
        databaseId: databaseId,
        actorEmail: who.email,
        tableName: tableName,
        recipients: recipients,
      );
    }
  }

  /// Function Name: [commentAdded]
  ///
  /// Purpose: Tell the table's people a comment was posted on it (DB-TABLE-21,
  /// spec §1.7 row 9). Sent to the same people as [tableSaved] — everyone
  /// holding a grant on the database — minus the poster.
  ///
  /// Parameters: [databaseId]; the database and table names in both
  /// languages; [actor] overrides the signed-in user.
  ///
  /// Returns: [Future<void>]; a failed recipients read is logged, not thrown.
  static Future<void> commentAdded({
    required String databaseId,
    required String databaseNameEn,
    required String databaseNameAr,
    required String tableNameEn,
    required String tableNameAr,
    required CreateDatabaseBaseRepository repository,
    DatabaseNotificationActor? actor,
  }) async {
    final DatabaseNotificationActor who = actor ?? resolveActor();

    final Set<String>? recipients = await _tableEventRecipients(
      databaseId,
      actorEmail: who.email,
      event: 'commentAdded',
      repository: repository,
    );
    if (recipients == null || recipients.isEmpty) return;

    await DatabaseNotificationService.commentAdded(
      actorEmail: who.email,
      actorName: who.name,
      databaseName: _pair(databaseNameEn, databaseNameAr),
      tableName: _pair(tableNameEn, tableNameAr),
      recipients: recipients,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Internals
  // ═══════════════════════════════════════════════════════════

  /// One `accessGranted` per member per grant.
  static Future<void> _announceGrants({
    required String databaseId,
    required List<DatabaseAccessGrant> grants,
    required LocalizedName databaseName,
    required LocalizedName tableName,
    required DatabaseNotificationActor who,
  }) async {
    for (final DatabaseAccessGrant grant in grants) {
      for (final DatabaseMember member in grant.members) {
        final String email = (member.email ?? '').trim();
        if (email.isEmpty) continue;
        if (email.toLowerCase() == who.email.toLowerCase()) continue;

        await DatabaseNotificationService.accessGranted(
          databaseId: databaseId,
          actorEmail: who.email,
          recipientEmail: email,
          databaseName: databaseName,
          tableName: tableName,
          permissionLabel: _permissionLabel(grant),
          startDate: grant.startDate,
          endDate: grant.endDate,
        );
      }
    }
  }

  /// Flattens grants into one entry per person.
  ///
  /// LAST GRANT WINS for someone who appears on two. That is not a state the
  /// screens can produce — db2 dedupes a department's members against the
  /// individually-picked ones — but a document written by an older build could
  /// hold it, and picking one is the only way to send that person one
  /// notification instead of two that contradict each other.
  static Map<String, _MemberGrant> _byEmployee(
    Iterable<DatabaseAccessGrant> grants,
  ) {
    final Map<String, _MemberGrant> byId = <String, _MemberGrant>{};
    for (final DatabaseAccessGrant grant in grants) {
      for (final DatabaseMember member in grant.members) {
        if (member.employeeId.isEmpty) continue;
        byId[member.employeeId] = _MemberGrant(member: member, grant: grant);
      }
    }
    return byId;
  }

  /// True when anything the person would care about differs.
  ///
  /// Dates are compared by DAY: a grant read back from Firestore carries the
  /// time it was stored with while the picker returns midnight, so a timestamp
  /// comparison would report a change on every save.
  /// `DatabaseAccessGrant.dateOnly` is the same notion of "a day" the entity's
  /// own validation uses.
  ///
  /// `viewableFields` is compared as a SET — reordering the columns a person may
  /// see is not a change to what they may see.
  static bool _ruleChanged(
    DatabaseAccessGrant before,
    DatabaseAccessGrant after,
  ) {
    if (before.permission != after.permission) return true;
    if (!_sameDay(before.startDate, after.startDate)) return true;
    if (!_sameDay(before.endDate, after.endDate)) return true;

    final Set<String> wasFields = before.viewableFields.toSet();
    final Set<String> nowFields = after.viewableFields.toSet();
    if (wasFields.length != nowFields.length) return true;
    return !wasFields.containsAll(nowFields);
  }

  static bool _sameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return a == null && b == null;
    return DatabaseAccessGrant.dateOnly(a) == DatabaseAccessGrant.dateOnly(b);
  }

  /// The permission level as the recipient's language spells it.
  ///
  /// An unset level renders as an em dash rather than "null": a complete grant
  /// always has one (`DatabaseAccessGrant.isComplete` gates every save), so this
  /// only surfaces on a legacy document.
  /// The permission level's name in BOTH languages, from the .arb files
  /// (rule 14). `Intl.withLocale` reads each language's translation regardless
  /// of the one the actor is using; [_ensureBothLanguages] loads them first.
  static LocalizedName _permissionLabel(DatabaseAccessGrant grant) {
    final DatabasePermissionLevel? level = grant.permission;
    if (level == null) return (en: '—', ar: '—');
    String inLocale(String locale) =>
        Intl.withLocale(locale, () => _permissionName(level));
    return (en: inLocale('en'), ar: inLocale('ar'));
  }

  static String _permissionName(DatabasePermissionLevel level) =>
      switch (level) {
        DatabasePermissionLevel.fullAccess => S.current.dbPermissionFullAccess,
        DatabasePermissionLevel.edit => S.current.dbPermissionEdit,
        DatabasePermissionLevel.export => S.current.dbPermissionExport,
        DatabasePermissionLevel.view => S.current.dbPermissionView,
        DatabasePermissionLevel.custom => S.current.dbPermissionCustom,
      };

  static bool _languagesLoaded = false;

  /// Loads the English and Arabic messages once, so [_permissionLabel] can
  /// read both whichever the app is showing.
  static Future<void> _ensureBothLanguages() async {
    if (_languagesLoaded) return;
    await initializeMessages('en');
    await initializeMessages('ar');
    _languagesLoaded = true;
  }

  /// A name in both languages, each falling back to the other when empty.
  static LocalizedName _pair(String en, String ar) =>
      (en: en.isNotEmpty ? en : ar, ar: ar.isNotEmpty ? ar : en);
}

/// A person paired with the grant they are on, so the diff can report both who
/// changed and what their new rule is without walking the grants twice.
class _MemberGrant {
  const _MemberGrant({required this.member, required this.grant});

  final DatabaseMember member;
  final DatabaseAccessGrant grant;
}
