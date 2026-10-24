/// Module: database / db1_create_database / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: database_list_state.dart
/// Description: Declares `DatabaseListState` and `DatabaseListFilter`.
/// Author: Amr Mesbah
/// Created at: 15/8/2026
///
/// The read model behind the Database Builder list: the loaded records, the
/// active chip, search, filter and sort, and the server counts. Its own file
/// so `database_list_cubit.dart` stays under the 800-line limit.
library;

import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_sort_option.dart';

/// The count-chip filters, in the order the Figma lays them out.
enum DatabaseListFilter { all, open, restricted, personal, drafts, deleted }

@immutable
class DatabaseListState {
  const DatabaseListState({
    this.databases = const <DatabaseEntity>[],
    this.filter = DatabaseListFilter.all,
    this.searchQuery = '',
    this.accessFilter,
    this.sortOption,
    this.isLoading = false,
    this.errorMessage,
    this.counts = const <DatabaseListFilter, int>{},
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<DatabaseEntity> databases;
  final DatabaseListFilter filter;
  final String searchQuery;

  /// Access type chosen in the Filter dialog, or null for "not filtered".
  ///
  /// Deliberately a separate field from [filter] rather than folded into the
  /// chip enum: the chips are the view the user is standing in, the dialog is
  /// a refinement applied on top of it. Folding them together would make
  /// picking "Open Access" in the dialog silently move the chip selection.
  final DatabaseAccessType? accessFilter;

  /// Ordering picked on the Sort button, or null for "not sorted".
  ///
  /// NULLABLE on purpose rather than defaulting to one of the three options:
  /// `CustomSortButton` treats tapping the selected row again as a deselect
  /// and hands back null, and that null is the only way back to the order the
  /// repository returned. It is also what un-tints the button, so a list that
  /// looks unsorted actually is.
  final DatabaseSortOption? sortOption;

  final bool isLoading;
  final String? errorMessage;

  /// Each tab's count, from the server (DB-CREATE-08).
  final Map<DatabaseListFilter, int> counts;

  /// More pages of the current tab are waiting.
  final bool hasMore;
  final bool isLoadingMore;

  /// True while the dialog is narrowing the list — the Filter button is
  /// tinted from this so an active filter is never invisible.
  bool get hasAccessFilter => accessFilter != null;

  /// Key form used by `StatusChipFilter`, which selects by String rather than
  /// by index — storing the enum and deriving the key keeps the cubit free of
  /// the widget's addressing scheme.
  String get filterKey => filter.name;

  /// Records surviving the active chip, the search box AND the Filter dialog,
  /// in the order the Sort button asked for.
  ///
  /// Runs over the whole tab, not just the pages scrolled into view
  /// (DB-CREATE-12): the Filter dialog's access type is part of the server
  /// query, and while a search or a sort is active the cubit reads every
  /// remaining page of the tab. The access check below stays as a backstop
  /// for cards added locally by `insert` and `replace`.
  ///
  /// Takes [isArabic] rather than reading a locale itself because this is the
  /// domain-facing read model and it has no BuildContext — and because A → Z
  /// has to mean the title the user is actually looking at. Sorting on
  /// `titleEn` while the cards render `titleAr` would produce an order that is
  /// correct and completely unreadable.
  ///
  /// Sorting happens AFTER filtering, over the rows that survived — and not at
  /// all when nothing is selected, so the default view keeps the repository's
  /// own order.
  List<DatabaseEntity> visible({required bool isArabic}) {
    final String query = searchQuery.trim().toLowerCase();

    final List<DatabaseEntity> matches = databases.where((DatabaseEntity d) {
      if (!_matchesFilter(d)) return false;
      if (accessFilter != null && d.accessType != accessFilter) return false;
      if (query.isEmpty) return true;
      return d.titleEn.toLowerCase().contains(query) ||
          d.titleAr.contains(query);
    }).toList();

    final DatabaseSortOption? option = sortOption;
    if (option == null) return List<DatabaseEntity>.unmodifiable(matches);

    matches.sort((DatabaseEntity a, DatabaseEntity b) {
      switch (option) {
        case DatabaseSortOption.ascending:
          return _compareTitles(a, b, isArabic);
        case DatabaseSortOption.descending:
          return _compareTitles(b, a, isArabic);
        case DatabaseSortOption.lastUpdated:
          return _compareRecency(a, b, isArabic);
      }
    });

    return List<DatabaseEntity>.unmodifiable(matches);
  }

  /// A → Z on the title the current locale renders.
  ///
  /// Case-insensitive, so "apple" and "Apple" land next to each other instead
  /// of in two separate alphabets — `compareTo` on raw strings puts every
  /// capital ahead of every lowercase letter, which reads as broken.
  /// `toLowerCase()` is a no-op on Arabic, so the same path serves both.
  int _compareTitles(DatabaseEntity a, DatabaseEntity b, bool isArabic) {
    final int byTitle = a
        .localizedTitle(isArabic: isArabic)
        .toLowerCase()
        .compareTo(b.localizedTitle(isArabic: isArabic).toLowerCase());

    // Two records with the same title would otherwise sort unstably between
    // rebuilds. Falling back to the id makes the order fixed.
    return byTitle != 0 ? byTitle : a.id.compareTo(b.id);
  }

  /// Most recently touched first — `updatedAt` when the record has been
  /// edited, its creation date when it has not.
  ///
  /// A record with NEITHER date sorts last rather than first: null is missing
  /// information, and putting unknown-age rows at the top of a "most recent"
  /// list would push the actual recent ones out of sight.
  int _compareRecency(DatabaseEntity a, DatabaseEntity b, bool isArabic) {
    final DateTime? left = a.updatedAt ?? a.createdAt;
    final DateTime? right = b.updatedAt ?? b.createdAt;

    if (left == null && right == null) return _compareTitles(a, b, isArabic);
    if (left == null) return 1;
    if (right == null) return -1;

    final int byDate = right.compareTo(left);
    return byDate != 0 ? byDate : _compareTitles(a, b, isArabic);
  }

  bool _matchesFilter(DatabaseEntity d) {
    // DELETED RECORDS ARE INVISIBLE EVERYWHERE ELSE, All included. Since the
    // card menu became a soft delete they are still in
    // `databases`, so without this guard a deleted database would sit in the
    // middle of the working list looking exactly like a live one — and All
    // would be the chip where "Delete" appeared to do nothing at all.
    if (d.isDeleted) return filter == DatabaseListFilter.deleted;

    switch (filter) {
      case DatabaseListFilter.all:
        return true;
      // The access-type chips show FINISHED databases only. A draft has an
      // access type like anything else, but it has granted nobody anything
      // yet — listing it under "Restricted" next to real ones would make the
      // chip a lie. It is reachable under All and under Drafts.
      case DatabaseListFilter.open:
        return !d.isDraft && d.accessType == DatabaseAccessType.open;
      case DatabaseListFilter.restricted:
        return !d.isDraft && d.accessType == DatabaseAccessType.restricted;
      case DatabaseListFilter.personal:
        return !d.isDraft && d.accessType == DatabaseAccessType.personal;
      case DatabaseListFilter.drafts:
        return d.isDraft;
      // Handled by the guard above — a live record never belongs here.
      case DatabaseListFilter.deleted:
        return false;
    }
  }

  /// Count for one chip, for the WHOLE tab, not just the pages loaded so far
  /// (DB-CREATE-08).
  ///
  /// It counts the records the viewer created, plus the shared records whose
  /// grant dates include today — the same records the cards show.
  int countFor(DatabaseListFilter which) => counts[which] ?? 0;

  /// Function Name: [copyWith]
  ///
  /// Purpose: Return a copy with the given fields replaced.
  ///
  /// Returns: [DatabaseListState] the new state.
  DatabaseListState copyWith({
    List<DatabaseEntity>? databases,
    DatabaseListFilter? filter,
    String? searchQuery,
    DatabaseAccessType? accessFilter,
    DatabaseSortOption? sortOption,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,

    /// `accessFilter: null` cannot mean "clear it" — null is also "leave it
    /// alone" for every other nullable field here — so Reset needs its own
    /// flag, the same shape [clearErrorMessage] already uses.
    bool clearAccessFilter = false,

    /// Same reason: deselecting the sort option hands back null, and null on
    /// its own would read as "no change".
    bool clearSortOption = false,
    Map<DatabaseListFilter, int>? counts,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return DatabaseListState(
      databases: databases ?? this.databases,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      accessFilter:
          clearAccessFilter ? null : (accessFilter ?? this.accessFilter),
      sortOption: clearSortOption ? null : (sortOption ?? this.sortOption),
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      counts: counts ?? this.counts,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
