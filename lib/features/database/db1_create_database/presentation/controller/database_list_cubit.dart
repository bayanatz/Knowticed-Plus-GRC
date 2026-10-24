/// Module: database / db1_create_database / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: database_list_cubit.dart
/// Description: Declares `DatabaseListCubit`.
/// Author: Amr Mesbah
/// Created at: 15/8/2026
///
/// Backs the Database Builder landing screen (Figma 7398:2492 / 2628) — the
/// list, its count chips and its search box.
///
/// Separate from `CreateDatabaseCubit` on purpose: that one is a wizard whose
/// whole life is one unsaved draft, this one is a read model of saved
/// records. Merging them would keep a half-filled draft alive for as long as
/// the list is on screen.
library;

import 'package:knowticed_plus/features/database/db1_create_database/data/models/create_database_collections.dart';
import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/create_database_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_sort_option.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_status.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_session_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/use_cases/database_access_rule.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_page.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/database_list_state.dart';

export 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/database_list_state.dart';

class DatabaseListCubit extends Cubit<DatabaseListState> {
  DatabaseListCubit({
    required DatabaseSessionBaseRepository session,
    required CreateDatabaseBaseRepository repository,
    DatabaseAccessRule rule = const DatabaseAccessRule(),
  })  : _repository = repository,
        _session = session,
        _rule = rule,
        super(const DatabaseListState());

  final CreateDatabaseBaseRepository _repository;
  final DatabaseSessionBaseRepository _session;
  final DatabaseAccessRule _rule;
  final LiveRefresh _live = LiveRefresh();

  /// Where the next page of the current tab starts; null when there is none.
  DatabasePageCursor? _next;

  /// Bumped by every [load]. A page that arrives after a newer load started
  /// belongs to a tab or filter the user has already left, so it is dropped
  /// instead of replacing the list (DB-CREATE-13).
  int _generation = 0;

  static const int _pageSize = 30;

  /// Function Name: [accessFor]
  ///
  /// Purpose: What the signed-in employee may do with [database] today —
  /// which cards are listed and which menu actions a card offers.
  ///
  /// Parameters: [database] a record from the list.
  ///
  /// Returns: [DatabaseAccess].
  DatabaseAccess accessFor(DatabaseEntity database) => _rule.resolve(
        database,
        viewerId: _session.signedInEmployeeId,
        today: DateTime.now(),
      );

  @override
  void emit(DatabaseListState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [load]
  ///
  /// Purpose: Read the databases the signed-in employee may see — created by
  /// them, or granted to them with dates that include today (DB-CREATE-01).
  ///
  /// Returns: [Future<void>]; the result arrives as a new state.
  Future<void> load() async {
    final int generation = ++_generation;
    final String? viewerId = _session.signedInEmployeeId;
    if (viewerId == null) {
      // Nobody signed in can be allowed to see anything.
      emit(
        state.copyWith(
          isLoading: false,
          databases: const <DatabaseEntity>[],
          counts: const <DatabaseListFilter, int>{},
          hasMore: false,
        ),
      );
      return;
    }
    _next = null;
    emit(
      state.copyWith(
        isLoading: true,
        clearErrorMessage: true,
        databases: const <DatabaseEntity>[],
        hasMore: false,
      ),
    );

    final Future<void> counting = refreshCounts();
    final DatabaseListQuery? query = _queryFor(
      state.filter,
      state.accessFilter,
    );
    if (query == null) {
      // The chip and the Filter dialog ask for two different access types,
      // so nothing can match and there is nothing to read.
      emit(state.copyWith(isLoading: false, hasMore: false));
      await counting;
      return;
    }
    final Either<Failure, DatabasePage> result = await _repository
        .listDatabasesPage(viewerId: viewerId, query: query, limit: _pageSize);
    if (generation != _generation) return;
    _emitPage(result, append: false);
    await _readWholeTabIfNarrowed(generation);
    await counting;
    _live.watchPaths(<String>[
      getBaseUrl(CreateDatabaseCollections.databases),
    ], _silentReload);
  }

  /// Re-reads the current tab without the spinner or clearing the grid, so
  /// changes made on other screens (or devices) show up in place.
  Future<void> _silentReload() async {
    final String? viewerId = _session.signedInEmployeeId;
    if (viewerId == null || isClosed) return;
    if (state.isLoading || state.isLoadingMore) return;
    final DatabaseListQuery? query = _queryFor(
      state.filter,
      state.accessFilter,
    );
    if (query == null) return;
    final Future<void> counting = refreshCounts();
    final Either<Failure, DatabasePage> result =
        await _repository.listDatabasesPage(
      viewerId: viewerId,
      query: query,
      limit: math.max(_pageSize, state.databases.length),
    );
    if (result.isRight()) _emitPage(result, append: false);
    await counting;
  }

  /// Function Name: [loadMore]
  ///
  /// Purpose: The next page of the current tab, when the grid nears its end.
  /// A no-op while a page is loading or when there is none left.
  ///
  /// Returns: [Future<void>]; the rows are appended to the state.
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore) return;
    final int generation = _generation;
    if (!await _readNextPage(generation)) return;
    await _readWholeTabIfNarrowed(generation);
  }

  /// Reads the page after [_next] and appends it. Returns false when there was
  /// no page left, the read failed, or a newer [load] replaced the list while
  /// it was in flight (DB-CREATE-13).
  Future<bool> _readNextPage(int generation) async {
    final String? viewerId = _session.signedInEmployeeId;
    final DatabasePageCursor? after = _next;
    final DatabaseListQuery? query = _queryFor(
      state.filter,
      state.accessFilter,
    );
    if (viewerId == null || after == null || query == null) return false;

    emit(state.copyWith(isLoadingMore: true));
    final Either<Failure, DatabasePage> result =
        await _repository.listDatabasesPage(
      viewerId: viewerId,
      query: query,
      after: after,
      limit: _pageSize,
    );
    if (generation != _generation) return false;
    _emitPage(result, append: true);
    return result.isRight();
  }

  /// True while the search box or the Sort button needs every record of the
  /// tab, not just the pages scrolled into view (DB-CREATE-12).
  bool get _needsWholeTab =>
      state.searchQuery.trim().isNotEmpty || state.sortOption != null;

  /// Reads the rest of the tab, still [_pageSize] at a time, while a search
  /// or a sort is active (DB-CREATE-12). Stops when the tab is complete, a
  /// read fails, the search and sort are cleared, or a newer [load] starts.
  Future<void> _readWholeTabIfNarrowed(int generation) async {
    while (_needsWholeTab && generation == _generation) {
      if (!await _readNextPage(generation)) return;
    }
  }

  /// Function Name: [refreshCounts]
  ///
  /// Purpose: Re-count every tab (DB-CREATE-08). Called on load and after
  /// anything that moves a record between tabs. A failed count keeps the
  /// previous number; the list itself reports read failures.
  ///
  /// Each count has two parts. The viewer's own records are counted on the
  /// server. Records shared with the viewer are read and checked with
  /// [accessFor], because a server count cannot compare a grant's dates — so
  /// a grant that has ended or not started yet is not counted, and every
  /// count matches the cards the tab shows.
  ///
  /// Returns: [Future<void>].
  Future<void> refreshCounts() async {
    final String? viewerId = _session.signedInEmployeeId;
    if (viewerId == null) return;

    final Map<DatabaseListFilter, Future<Either<Failure, int>>> own =
        <DatabaseListFilter, Future<Either<Failure, int>>>{
      for (final DatabaseListFilter f in DatabaseListFilter.values)
        if (f != DatabaseListFilter.all)
          f: _repository.countDatabases(
            viewerId: viewerId,
            query: _ownQuery(_tabQuery(f)),
          ),
    };
    // The All chip is live records plus the viewer's own drafts, counted as
    // two parts so other people's drafts are not included.
    final Future<Either<Failure, int>> ownLive = _repository.countDatabases(
      viewerId: viewerId,
      query: const DatabaseListQuery(
        statuses: <DatabaseStatus>[DatabaseStatus.active],
        creatorOnly: true,
      ),
    );
    final Future<Either<Failure, List<DatabaseEntity>>> shared =
        _repository.listGrantedDatabases(
      viewerId: viewerId,
      statuses: const <DatabaseStatus>[
        DatabaseStatus.active,
        DatabaseStatus.deleted,
      ],
    );

    // Shared records the viewer may see today; null when the read failed, in
    // which case every tab keeps its previous number.
    final List<DatabaseEntity>? visibleShared = (await shared).fold(
      (Failure failure) {
        _logCountFailure(DatabaseListFilter.all, failure);
        return null;
      },
      (List<DatabaseEntity> items) => items
          .where((DatabaseEntity d) => accessFor(d).canView)
          .toList(growable: false),
    );
    if (visibleShared == null) return;

    final Map<DatabaseListFilter, int> counts = Map<DatabaseListFilter, int>.of(
      state.counts,
    );
    for (final MapEntry<DatabaseListFilter, Future<Either<Failure, int>>> e
        in own.entries) {
      (await e.value).fold(
        (Failure failure) => _logCountFailure(e.key, failure),
        (int n) {
          counts[e.key] = n + _countMatching(visibleShared, _tabQuery(e.key));
        },
      );
    }
    (await ownLive).fold(
      (Failure failure) => _logCountFailure(DatabaseListFilter.all, failure),
      (int n) {
        counts[DatabaseListFilter.all] = n +
            _countMatching(
              visibleShared,
              const DatabaseListQuery(
                statuses: <DatabaseStatus>[DatabaseStatus.active],
              ),
            ) +
            (counts[DatabaseListFilter.drafts] ?? 0);
      },
    );
    if (isClosed) return;
    emit(state.copyWith(counts: counts));
  }

  /// [query] limited to the viewer's own records.
  static DatabaseListQuery _ownQuery(DatabaseListQuery query) =>
      DatabaseListQuery(
        statuses: query.statuses,
        accessType: query.accessType,
        creatorOnly: true,
      );

  /// How many of the shared [records] belong to the tab [query] describes.
  /// A creator-only tab never holds shared records.
  static int _countMatching(
    List<DatabaseEntity> records,
    DatabaseListQuery query,
  ) {
    if (query.creatorOnly) return 0;
    final DatabaseAccessType? type = query.accessType;
    return records
        .where(
          (DatabaseEntity d) =>
              query.statuses.contains(d.status) &&
              (type == null || d.accessType == type),
        )
        .length;
  }

  /// A failed count keeps the chip's previous number; the failure is logged
  /// so it does not vanish without a trace.
  void _logCountFailure(DatabaseListFilter tab, Failure failure) {
    if (kDebugMode) {
      debugPrint(
        '🔴 [DatabaseListCubit] ${tab.name} count failed: '
        '${failure.errMessage}',
      );
    }
  }

  void _emitPage(Either<Failure, DatabasePage> result, {required bool append}) {
    if (isClosed) return;
    result.fold(
      (Failure failure) => emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: failure.errMessage,
        ),
      ),
      (DatabasePage page) {
        _next = page.next;
        // The query found everyone named in a grant; this drops grants that
        // have not started or have ended (DB-CREATE-01).
        final List<DatabaseEntity> visible = page.items
            .where((DatabaseEntity d) => accessFor(d).canView)
            .toList(growable: false);
        emit(
          state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            hasMore: page.hasMore,
            databases: append
                ? <DatabaseEntity>[...state.databases, ...visible]
                : visible,
          ),
        );
      },
    );
  }

  /// The server query for [filter] narrowed by the Filter dialog's
  /// [accessFilter] (DB-CREATE-12), or null when the two ask for different
  /// access types and nothing can match.
  static DatabaseListQuery? _queryFor(
    DatabaseListFilter filter,
    DatabaseAccessType? accessFilter,
  ) {
    final DatabaseListQuery tab = _tabQuery(filter);
    if (accessFilter == null) return tab;
    final DatabaseAccessType? tabType = tab.accessType;
    if (tabType != null) return tabType == accessFilter ? tab : null;
    return DatabaseListQuery(
      statuses: tab.statuses,
      accessType: accessFilter,
      creatorOnly: tab.creatorOnly,
    );
  }

  /// The server query behind each tab (DB-CREATE-08). Personal databases and
  /// drafts belong to their creator, so those tabs read only the viewer's own.
  static DatabaseListQuery _tabQuery(DatabaseListFilter filter) {
    switch (filter) {
      case DatabaseListFilter.all:
        return const DatabaseListQuery(
          statuses: <DatabaseStatus>[
            DatabaseStatus.active,
            DatabaseStatus.draft,
          ],
        );
      case DatabaseListFilter.open:
        return const DatabaseListQuery(
          statuses: <DatabaseStatus>[DatabaseStatus.active],
          accessType: DatabaseAccessType.open,
        );
      case DatabaseListFilter.restricted:
        return const DatabaseListQuery(
          statuses: <DatabaseStatus>[DatabaseStatus.active],
          accessType: DatabaseAccessType.restricted,
        );
      case DatabaseListFilter.personal:
        return const DatabaseListQuery(
          statuses: <DatabaseStatus>[DatabaseStatus.active],
          accessType: DatabaseAccessType.personal,
          creatorOnly: true,
        );
      case DatabaseListFilter.drafts:
        return const DatabaseListQuery(
          statuses: <DatabaseStatus>[DatabaseStatus.draft],
          creatorOnly: true,
        );
      case DatabaseListFilter.deleted:
        return const DatabaseListQuery(
          statuses: <DatabaseStatus>[DatabaseStatus.deleted],
        );
    }
  }

  /// Adds a freshly created record to the top of the list.
  ///
  /// The flow already returned the saved entity, so re-reading the whole
  /// collection to discover one new row would be a wasted query — and would
  /// briefly show a spinner over a list the user was just looking at.
  void insert(DatabaseEntity database) {
    emit(
      state.copyWith(databases: <DatabaseEntity>[database, ...state.databases]),
    );
    refreshCounts();
  }

  /// Swaps a card for the edited version of itself.
  ///
  /// For the details screen (db2), which can rename a record,
  /// change its access type and change its member count — all three of which
  /// this list draws. Matched by id and left alone when the id is not here, so
  /// a record filtered out of the current chip does not get appended by an
  /// edit made somewhere else.
  ///
  /// Optimistic for the same reason `insert` is: the caller only has an edited
  /// record because the write already succeeded.
  void replace(DatabaseEntity database) => emit(
        state.copyWith(
          databases: state.databases
              .map((DatabaseEntity d) => d.id == database.id ? database : d)
              .toList(growable: false),
        ),
      );

  /// Marks a card whose record was ALREADY deleted elsewhere.
  ///
  /// Distinct from [delete], which performs the write. The details screen owns
  /// its own confirm-and-delete — the status is already `deleted` on the server
  /// by the time it returns — so calling `delete` here would fire a second
  /// write, and that one would stamp `previous_status: deleted` and make the
  /// record unrestorable.
  ///
  /// The row is kept, not dropped: deleting is a status change, and dropping
  /// it would hide the record from the Deleted chip until the next full load,
  /// which is exactly where the user goes looking for it.
  void markDeletedLocally(String id) => emit(
        state.copyWith(
          databases: state.databases
              .map(
                (DatabaseEntity d) => d.id == id
                    ? d.copyWith(
                        status: DatabaseStatus.deleted,
                        previousStatus: d.status,
                        deletedAt: DateTime.now(),
                      )
                    : d,
              )
              .toList(growable: false),
        ),
      );

  /// [key] is `DatabaseListFilter.name` — what `StatusChipFilter` hands back.
  /// An unrecognised key is ignored rather than defaulting to `all`, so a
  /// typo cannot silently widen what the user is looking at.
  void filterChanged(String key) {
    for (final DatabaseListFilter f in DatabaseListFilter.values) {
      if (f.name == key) {
        if (f == state.filter) return;
        emit(state.copyWith(filter: f));
        // Each tab is its own server query now (DB-CREATE-08).
        load();
        return;
      }
    }
  }

  /// Function Name: [searchChanged]
  ///
  /// Purpose: Store the search text; the visible list is filtered from it.
  /// The rest of the tab is read first so the search covers every record,
  /// not just the pages loaded so far (DB-CREATE-12).
  void searchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
    _readWholeTabWhenIdle();
  }

  /// Starts reading the rest of the tab unless a read is already running —
  /// [load] and [loadMore] continue on their own once their page lands.
  void _readWholeTabWhenIdle() {
    if (state.isLoading || state.isLoadingMore) return;
    _readWholeTabIfNarrowed(_generation);
  }

  /// Applies the Filter dialog's choice. A null [type] is the dialog's Reset,
  /// so it clears the filter rather than being ignored as "no change".
  ///
  /// The access type is part of the server query (DB-CREATE-12), so the tab
  /// is read again from the first page.
  void accessFilterChanged(DatabaseAccessType? type) {
    if (type == state.accessFilter) return;
    emit(
      type == null
          ? state.copyWith(clearAccessFilter: true)
          : state.copyWith(accessFilter: type),
    );
    load();
  }

  /// Applies the Sort button's choice.
  ///
  /// A null [option] is `CustomSortButton` deselecting — the user tapped the
  /// row that was already selected — so it clears the ordering and puts the
  /// list back in the repository's order rather than being ignored.
  ///
  /// Only the ordering changes here. The chip, the search box and the Filter
  /// dialog are untouched, so sorting narrows nothing. The rest of the tab is
  /// read first so the order covers every record, not just the pages loaded
  /// so far (DB-CREATE-12).
  void sortChanged(DatabaseSortOption? option) {
    emit(
      option == null
          ? state.copyWith(clearSortOption: true)
          : state.copyWith(sortOption: option),
    );
    _readWholeTabWhenIdle();
  }

  /// Moves [database] into the Deleted chip, returning false when the write
  /// failed so the page can raise the error dialog.
  ///
  /// A soft delete. The row is not dropped — its status changes, which
  /// is what makes it disappear from the chip the user is standing in and
  /// appear under Deleted with the count to match, both from one emit.
  ///
  /// The local edit lands only AFTER the repository confirms. An optimistic
  /// version would be a lie the user cannot see through: the card would move
  /// to Deleted, the record would still be live in Firestore, and the next
  /// load would put it back with no explanation. `insert` can be optimistic
  /// because the write has already succeeded by the time it is called; this
  /// cannot.
  ///
  /// `previousStatus` is the status the record is standing in RIGHT NOW, which
  /// is what Restore reads back — delete a draft and Restore returns it to
  /// Drafts, not to the finished list.
  Future<bool> delete(DatabaseEntity database) async {
    if (!accessFor(database).canManage) return false;
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    final Either<Failure, void> result = await _repository.deleteDatabase(
      database.id,
      previousStatus: database.status,
    );

    return result.fold(
      (Failure failure) {
        emit(
          state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isLoading: false,
            databases: state.databases
                .map(
                  (DatabaseEntity d) => d.id == database.id
                      ? d.copyWith(
                          status: DatabaseStatus.deleted,
                          previousStatus: database.status,
                          // Local stand-in for the server timestamp. Nothing draws
                          // it, and the next load replaces it with the real one.
                          deletedAt: DateTime.now(),
                        )
                      : d,
                )
                .toList(growable: false),
          ),
        );
        // The record moved between tabs (DB-CREATE-08).
        refreshCounts();
        return true;
      },
    );
  }

  /// Puts a soft-deleted record back where it came from — "Restore" on the
  /// card's "..." menu. Returns false on failure so the page
  /// can raise the dialog.
  ///
  /// The target comes from `DatabaseEntity.restoreTarget`, not from a constant:
  /// a database that was a draft when it was deleted goes back to Drafts. Both
  /// deletion markers are cleared locally through `clearDeletionMarkers` so the
  /// in-memory row matches the document, where they were removed outright.
  ///
  /// A record that is not actually deleted is refused before any write. It can
  /// only happen through a stale card — the Restore row is not drawn on a live
  /// one — and restoring a live database would rewrite its status for nothing.
  Future<bool> restore(DatabaseEntity database) async {
    if (!database.isDeleted || !accessFor(database).canManage) return false;

    final DatabaseStatus target = database.restoreTarget;

    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    final Either<Failure, void> result = await _repository.restoreDatabase(
      database.id,
      status: target,
    );

    return result.fold(
      (Failure failure) {
        emit(
          state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isLoading: false,
            databases: state.databases
                .map(
                  (DatabaseEntity d) => d.id == database.id
                      ? d.copyWith(status: target, clearDeletionMarkers: true)
                      : d,
                )
                .toList(growable: false),
          ),
        );
        // The record moved between tabs (DB-CREATE-08).
        refreshCounts();
        return true;
      },
    );
  }

  /// Function Name: [clearMessages]
  ///
  /// Purpose: Clear the error and success messages once the screen has shown them, so a rebuild does not show them twice.
  void clearMessages() => emit(state.copyWith(clearErrorMessage: true));

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }
}
