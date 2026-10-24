/// Module: database / db1_create_database / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: database_builder_page.dart
/// Description: Declares `DatabaseBuilderPage`.
/// Author: Amr Mesbah
/// Created at: 15/8/2026
///
/// The module's landing screen — Figma 7398:2492 (iPad H) / 7398:2628 (V).
///
///   title, a row of count chips (All / Open / Restricted / Personal /
///   Drafts / Deleted), search + filter + sort, the yellow "Create Database"
///   button, and a grid of database cards.
///
/// This is the entry point: its button opens [CreateDatabaseFlow] and awaits
/// the created record, inserting it into the list rather than refetching.
///
/// Both orientations share this file. The card grid reflows through
/// `CrossAxisCountHelper`, the same helper every other grid in the app uses.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_confirm_dialog.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_sort_button.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/layout/responsive_card_grid.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_sort_option.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/database_list_cubit.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/pages/create_database_flow.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/database_filter_dialog.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/pages/database_details_page.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/pages/edit_database_page.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_session_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_strings.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/database_enum_labels.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/database_builder_page/database_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/create_database_base_repository.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/base_repository/database_details_base_repository.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/pages/database_access_page.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/base_repository/create_table_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/notification/domain/enums/database/database_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/routing/pending_notification_record.dart';

/// The Database Builder landing screen. Provides the list cubit, so the
/// screen below reads it instead of building its own.
class DatabaseBuilderPage extends StatelessWidget {
  /// Function Name: [DatabaseBuilderPage]
  ///
  /// Purpose: The module's first screen — the list of databases.
  const DatabaseBuilderPage({super.key, this.notified});

  /// The record a notification's View asked for, or null on a normal visit.
  /// Opened once, over this list, so Back lands here (owner 22/10/2026).
  final PendingNotificationRecord? notified;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DatabaseListCubit>(
      create: (BuildContext ctx) => DatabaseListCubit(
        session: ctx.read<DatabaseSessionBaseRepository>(),
        repository: ctx.read<CreateDatabaseBaseRepository>(),
      ),
      child: _DatabaseBuilderView(notified: notified),
    );
  }
}

class _DatabaseBuilderView extends StatefulWidget {
  const _DatabaseBuilderView({this.notified});

  final PendingNotificationRecord? notified;

  @override
  State<_DatabaseBuilderView> createState() => _DatabaseBuilderPageState();
}

class _DatabaseBuilderPageState extends State<_DatabaseBuilderView> {
  late final DatabaseListCubit _cubit = context.read<DatabaseListCubit>();
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit.load();
    final PendingNotificationRecord? notified = widget.notified;
    if (notified != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _openNotified(notified),
      );
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// The self-closing warning (3 s, like the Messages one) for a View whose
  /// record cannot be opened — gone, or the reader has no access to it now.
  Future<void> _warnCannotOpen() async {
    if (!mounted) return;
    await CustomDialogManager.showMessage(
      context: context,
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_status_warning.json',
      title: context.isArabic
          ? 'تعذّر فتح قاعدة البيانات'
          : 'Could not open this database',
      closeAfter: const Duration(seconds: 3),
    );
  }

  /// Opens what a notification's View points at (owner 22/10/2026).
  ///
  /// [record]'s id is `<databaseId>` or `<databaseId>/<tableId>` (see
  /// `DatabaseNotificationService.recordId`); its page key says which screen:
  ///   DatabaseBuilderPage  → that database's details ("a database was created")
  ///   DatabaseDetailsPage  → that database's details (table news)
  ///   DatabaseAccessPage   → its access list — the table's when the id names
  ///                          one (a table-level grant), else the database's
  ///   TableAccessPage      → that table's access list
  ///
  /// A database that cannot be read, or that the reader may no longer view
  /// (access revoked or expired), leaves them on this list — the list is the
  /// honest answer to "what can I open now". A table that is gone falls back
  /// to its database's details.
  Future<void> _openNotified(PendingNotificationRecord record) async {
    // "Database created" (DatabaseBuilderPage) carries the new database's id
    // now, and View opens it — the same as table news (owner 22/10/2026). An
    // unknown page key does the same: the id is what matters.
    final DatabaseNotificationPage page =
        DatabaseNotificationPage.fromKey(record.pageKey) ??
            DatabaseNotificationPage.databaseDetailsPage;

    final List<String> ids = record.recordId.split('/');
    final String databaseId = ids.first.trim();
    final String tableId = ids.length > 1 ? ids[1].trim() : '';
    if (databaseId.isEmpty) return;

    final DatabaseDetailsBaseRepository details =
        context.read<DatabaseDetailsBaseRepository>();
    final CreateTableBaseRepository tables =
        context.read<CreateTableBaseRepository>();

    final DatabaseEntity? database = (await details.fetchDatabase(databaseId))
        .fold((_) => null, (DatabaseEntity d) => d);
    if (!mounted) return;
    if (database == null || !_cubit.accessFor(database).canView) {
      await _warnCannotOpen();
      return;
    }

    final bool wantsAccess =
        page == DatabaseNotificationPage.databaseAccessPage ||
            page == DatabaseNotificationPage.tableAccessPage;
    if (!wantsAccess || database.isDraft) {
      await _onCardPressed(database);
      return;
    }

    DatabaseTableEntity? table;
    if (tableId.isNotEmpty) {
      table = (await tables.fetchTables(databaseId)).fold((_) => null,
          (List<DatabaseTableEntity> all) {
        for (final DatabaseTableEntity t in all) {
          if (t.id == tableId) return t;
        }
        return null;
      });
      if (!mounted) return;
      if (table == null) {
        await _onCardPressed(database);
        return;
      }
    } else if (page == DatabaseNotificationPage.tableAccessPage) {
      // A table page with no table named (an older notification) — the
      // database's details list its tables.
      await _onCardPressed(database);
      return;
    }

    final DatabaseEntity? saved = await DatabaseAccessPage.open(
      context,
      database: database,
      table: table,
    );
    if (saved != null && mounted) _cubit.replace(saved);
  }

  /// Opens the wizard and brings the list back in step with the server.
  ///
  /// TWO steps, not one. The insert is optimistic — the flow hands back the
  /// saved record, so the new card appears the instant the wizard closes with
  /// no spinner over a list the user was just looking at.
  ///
  /// The reload is the one that has to be right. The hand-back only survives
  /// the wizard closing through `onCompleted`; it is null whenever the flow
  /// ends any other way — Save For Later after the write, a back gesture, the
  /// success dialog dismissed by tapping the barrier, or a rebuild that
  /// disposed the route. In every one of those the record IS in Firestore and
  /// the list would have carried on showing "No databases yet" until the
  /// module was rebuilt. One collection read on a screen the user only
  /// reaches by finishing a wizard is a fair price for the list never lying.
  Future<void> _onCreatePressed() async {
    final DatabaseEntity? created = await CreateDatabaseFlow.open(context);

    if (created != null) _cubit.insert(created);

    // `load()` replaces the whole list, so the optimistic row above cannot end
    // up duplicated by this.
    await _cubit.load();
  }

  /// Opens the Filter card and applies what comes back.
  ///
  /// A dismissed dialog resolves to null and is ignored; only Apply reaches
  /// the cubit, so tapping outside cannot silently change the list.
  Future<void> _onFilterPressed() async {
    final DatabaseFilterResult? result = await DatabaseFilterDialog.show(
      context,
      initialAccessType: _cubit.state.accessFilter,
    );

    if (result != null) _cubit.accessFilterChanged(result.accessType);
  }

  /// "Delete" on a card's "..." menu: confirm, delete, and only report the
  /// failure — the success is visible, the card has moved to Deleted.
  ///
  /// A soft delete. Nothing leaves Firestore: the record's status
  /// changes, so the card drops out of whichever chip the user is standing in
  /// and appears under Deleted with the count to match. [_onRestorePressed] is
  /// the way back, and the access grants are untouched throughout — which is
  /// what makes the way back mean anything.
  Future<void> _onDeletePressed(DatabaseEntity database) async {
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);
    final String title = FormatHelper.capitalize(
      database.localizedTitle(isArabic: context.isArabic),
    );

    // showConfirmDialog pops before invoking onConfirm, so this flag is set
    // while the await above is still suspended and is readable here. Cancel
    // and a barrier tap both leave it false.
    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: strings.deleteConfirmTitle,
      subtitle: strings.deleteConfirmSubtitle(title),
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );

    if (!confirmed || !mounted) return;

    final bool deleted = await _cubit.delete(database);
    if (deleted || !mounted) return;

    await showErrorDialog(
      context: context,
      title: strings.deleteFailedTitle,
      subtitle: _cubit.state.errorMessage ?? strings.deleteFailed,
      closeLabel: strings.close,
    );
    _cubit.clearMessages();
  }

  /// "Restore" on a deleted card's "..." menu.
  ///
  /// Same shape as delete — confirm, write, report only the failure — because
  /// it is the same kind of action in the other direction, and a success
  /// dialog on top of a card that visibly moved would be one tap of noise.
  ///
  /// The confirmation names WHERE the record is going, and it asks
  /// `restoreTarget` — the same value the cubit writes — so the sentence and
  /// the write cannot drift: a database that was a draft when it was deleted
  /// goes back to Drafts, not into the finished list.
  Future<void> _onRestorePressed(DatabaseEntity database) async {
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);
    final String title = database.localizedTitle(isArabic: context.isArabic);

    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: strings.restoreConfirmTitle,
      subtitle: strings.restoreConfirmSubtitle(
        title,
        asDraft: database.restoreTarget.isDraft,
      ),
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );

    if (!confirmed || !mounted) return;

    final bool restored = await _cubit.restore(database);
    if (restored || !mounted) return;

    await showErrorDialog(
      context: context,
      title: strings.restoreFailedTitle,
      subtitle: _cubit.state.errorMessage ?? strings.restoreFailed,
      closeLabel: strings.close,
    );
    _cubit.clearMessages();
  }

  /// "Edit" on a card's "..." menu.
  ///
  /// This used to raise a "not available yet" dialog
  /// because the wizard has no edit mode — `CreateDatabaseFlow` always starts
  /// on a blank draft, so opening it here would have written a SECOND record
  /// with the same title. db2's `EditDatabasePage` is the real editor: it
  /// opens on the record, updates in place, and excludes the record from its
  /// own duplicate-title check.
  ///
  /// It goes straight to the editing card rather than through the details
  /// screen, because the menu row says "Edit" — a menu item that opened a
  /// different screen with an Edit button on it would be one tap of
  /// misdirection.
  Future<void> _onEditPressed(DatabaseEntity database) async {
    if (!_cubit.accessFor(database).canEdit) return;
    final DatabaseEntity? saved = await EditDatabasePage.open(
      context,
      database: database,
    );

    if (saved == null || !mounted) return;
    _cubit.replace(saved);
  }

  /// Reopens the wizard on a parked draft so the user can finish it.
  ///
  /// The flow resolves with the SAVED record and the write behind it was an
  /// update — same document, same id — so this swaps the row rather than
  /// inserting one. Finishing a draft turns its status active, which is what
  /// moves the card out of the Drafts chip and into its access type.
  ///
  /// The reload afterwards is the same belt-and-braces `_onCreatePressed`
  /// uses: the hand-back only survives the wizard closing through
  /// `onCompleted` and is null on a back gesture, a "Save For Later", or a
  /// success dialog dismissed by its barrier — and in every one of those the
  /// write has still happened.
  Future<void> _onDraftPressed(DatabaseEntity draft) async {
    final DatabaseEntity? saved = await CreateDatabaseFlow.open(
      context,
      draft: draft,
    );

    if (!mounted) return;
    if (saved != null) _cubit.replace(saved);
    await _cubit.load();
  }

  /// Tapping a card opens the details screen — the Figma's
  /// "INSIDE DATABASE PAGE" section.
  ///
  /// The outcome decides what happens to the card rather than a blanket
  /// reload: a deleted record is marked, an edited one is swapped. Both are
  /// already true on the server by the time this returns, so neither is an
  /// optimistic guess.
  Future<void> _onCardPressed(DatabaseEntity database) async {
    // A DELETED record OPENS, READ-ONLY. This used to return
    // early, which made every card under the Deleted chip a dead tap: the
    // record is still there in full — its tables, its grants, its dates — and
    // "what was in this before I deleted it?" is the whole reason someone
    // stands in that chip. Refusing to open it answered a reasonable question
    // with nothing at all.
    //
    // What does NOT come with it is the ability to act on it. `readOnly` drops
    // Edit and Delete from the details screen: editing a deleted record would
    // save changes into a row nobody can see, and Delete has nothing left to
    // do. Restore stays where it already is — the card's "..." menu — because
    // that is the one action that makes sense here and it is one tap away.
    //
    // A DRAFT REOPENS THE WIZARD, not the details screen.
    //
    // The details screen is built around a FINISHED database: granted access,
    // a table list, an access editor. A draft has none of that — it is
    // unfinished work, and the only useful thing to do with it is finish it.
    // Sending it to the details screen made tapping a draft a dead end showing
    // an empty access table, with no way back into the flow that produced it.
    if (database.isDraft) {
      await _onDraftPressed(database);
      return;
    }

    if (!context.mounted) return;
    final DatabaseDetailsOutcome? outcome = await DatabaseDetailsPage.open(
      context,
      database: database,
      // Below Edit level the details screen is for looking only (DB-CREATE-01).
      readOnly: database.isDeleted || !_cubit.accessFor(database).canEdit,
    );

    if (outcome == null || !mounted) return;

    if (outcome.deleted) {
      // Was `removeLocally`. The details screen's Delete is the same soft
      // delete as the menu's, so the record is still there — dropping the row
      // would hide it from the Deleted chip until the next full load, which is
      // exactly where the user goes looking for it.
      _cubit.markDeletedLocally(outcome.database.id);
      _cubit.refreshCounts();
      return;
    }
    _cubit.replace(outcome.database);
  }

  @override
  Widget build(BuildContext context) {
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);
    final bool isArabic = context.isArabic;

    return BlocBuilder<DatabaseListCubit, DatabaseListState>(
      bloc: _cubit,
      builder: (BuildContext context, DatabaseListState state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 15.h),
                  Text(
                    strings.databaseBuilder,
                    style: StyleText.fontSize24Weight600.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 15.h),

                  // The shared chip row (custom 8). Its key is the enum's
                  // `name`, so the cubit stores a DatabaseListFilter and never
                  // has to know about chip indices.
                  StatusChipFilter(
                    items: _chips(state, strings),
                    selectedKey: state.filterKey,
                    onSelected: _cubit.filterChanged,
                  ),
                  SizedBox(height: 15.h),

                  _Toolbar(
                    searchController: _search,
                    onSearchChanged: _cubit.searchChanged,
                    onCreate: _onCreatePressed,
                    onFilter: _onFilterPressed,
                    isFilterActive: state.hasAccessFilter,
                    sortOption: state.sortOption,
                    onSortChanged: _cubit.sortChanged,
                    isArabic: isArabic,
                    strings: strings,
                  ),
                  SizedBox(height: 15.h),

                  Expanded(
                    child: state.isLoading
                        ? const CircleProgressMaster()
                        : _grid(state, strings, isArabic),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Maps the filter enum onto the shared chip model. Labels come from the
  /// module's string table, counts from the cubit — so the widget stays
  /// generic and this page owns the wording.
  List<StatusChipItem> _chips(
    DatabaseListState state,
    CreateDatabaseStrings strings,
  ) {
    String labelFor(DatabaseListFilter f) {
      switch (f) {
        case DatabaseListFilter.all:
          return strings.all;
        case DatabaseListFilter.open:
          return strings.open;
        case DatabaseListFilter.restricted:
          return strings.restricted;
        case DatabaseListFilter.personal:
          return strings.personal;
        case DatabaseListFilter.drafts:
          return strings.drafts;
        case DatabaseListFilter.deleted:
          return strings.deleted;
      }
    }

    return DatabaseListFilter.values
        .map(
          (DatabaseListFilter f) => StatusChipItem(
            key: f.name,
            label: labelFor(f),
            count: state.countFor(f),
          ),
        )
        .toList(growable: false);
  }

  Widget _grid(
    DatabaseListState state,
    CreateDatabaseStrings strings,
    bool isArabic,
  ) {
    // A FAILED read and an EMPTY collection are different things and must not
    // look the same. `load()` stores its failure in state and nothing rendered
    // it, so a denied Firestore read — or any network error — showed "No
    // databases yet": the screen said the collection was empty when it had
    // simply never been read. That is the one message a user cannot argue
    // with, and it is exactly what a freshly created record disappearing looks
    // like.
    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.red,
              ),
            ),
            SizedBox(height: 12.h),
            customButton(
              title: strings.retry,
              function: () => _cubit.load(),
              wrapContent: true,
              color: AppColors.primary,
              textColor: AppColors.textButton,
            ),
          ],
        ),
      );
    }

    final List<DatabaseEntity> items = state.visible(isArabic: isArabic);

    // The shared animation for every chip, Deleted included. The
    // chip the user is standing in is on screen right above this, so it
    // already says which kind of nothing this is — which is what the two
    // sentences here were spending words on.
    //
    // NOT used for the failure branch above: a denied read is not an empty
    // list, and this is the screen where confusing the two is worst.
    if (items.isEmpty) {
      // Nothing matches YET is not the same as nothing matches (DB-CREATE-15).
      // While a search or sort is still reading the rest of the tab, or more
      // pages are waiting, the answer is not known — show the loader, and
      // keep reading when no scroll can trigger the next page. The empty
      // state appears only once the whole tab has been read.
      if (state.isLoadingMore || state.hasMore) {
        if (!state.isLoadingMore) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _cubit.loadMore(),
          );
        }
        return const CircleProgressMaster();
      }
      return const CustomEmptyState();
    }

    // The thumbnail is the tallest thing in the card, so it drives the row
    // height: 80 on the phone frame (card 343 x 100), 60 on tablet.
    final double cardHeight = ResponsiveCardHeight.forListCard(
      context,
      titleSize: 14,
      subtitleSize: 11,
      captionSize: 11,
      gap: 5,
      verticalPadding: 20,
      thumbnailHeight: context.isPhone ? 80 : 60,
    );

    // Pages of 30 (DB-CREATE-08): the next one loads as the grid nears its
    // end, with a spinner under the last row while it does.
    final Widget grid = GridView.builder(
      padding: EdgeInsets.only(bottom: 20.h),
      itemCount: items.length,
      gridDelegate: ResponsiveCardHeight.delegate(
        crossAxisCount: CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
          context,
        ),
        cardHeight: cardHeight,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemBuilder: (BuildContext context, int index) {
        final DatabaseEntity database = items[index];
        final DatabaseAccess access = _cubit.accessFor(database);
        return DatabaseCard(
          database: database,
          strings: strings,
          isArabic: isArabic,
          canEdit: access.canEdit,
          canManage: access.canManage,
          onTap: () => _onCardPressed(database),
          onEdit: () => _onEditPressed(database),
          onDelete: () => _onDeletePressed(database),
          onRestore: () => _onRestorePressed(database),
        );
      },
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (state.hasMore && notification.metrics.extentAfter < 300.h) {
          _cubit.loadMore();
        }
        return false;
      },
      child: Stack(
        children: <Widget>[
          grid,
          if (state.isLoadingMore)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(child: CircleProgressMaster.inline()),
            ),
        ],
      ),
    );
  }
}

/// Search + Filter + Sort + the yellow Create button (Figma 7398:2492).
///
/// Every control here is a shared widget rather than something shaped locally:
/// `CustomFilterIcon` and `CustomSortButton` already carry the app's outlined
/// pill styling and their own SVGs, and `customButtonWithSvg` routes the
/// primary button through `ButtonSizing` so it matches every other button in
/// the app.
class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.searchController,
    required this.onSearchChanged,
    required this.onCreate,
    required this.onFilter,
    required this.isFilterActive,
    required this.sortOption,
    required this.onSortChanged,
    required this.isArabic,
    required this.strings,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onCreate;
  final VoidCallback onFilter;

  /// Whether the Filter dialog is currently narrowing the list.
  final bool isFilterActive;

  /// The ordering currently applied, or null for none — which is also what
  /// decides whether the Sort button is tinted.
  final DatabaseSortOption? sortOption;

  final ValueChanged<DatabaseSortOption?> onSortChanged;

  final bool isArabic;

  final CreateDatabaseStrings strings;

  @override
  Widget build(BuildContext context) {
    // PHONE (Figma 7398:12797): the toolbar is search + icon buttons + the
    // yellow create icon in a 375 frame, and none of them carry a label.
    // Keeping the tablet row here would put four labelled controls in 345pt
    // and leave the search box about 60pt wide.
    final bool isPhone = context.isPhone;

    return Row(
      children: <Widget>[
        // AppSearchTextField's root IS an Expanded, so it goes straight into
        // the Row — wrapping it in another one throws
        // "Competing ParentDataWidgets".
        AppSearchTextField(
          controller: searchController,
          hintText: strings.search,
          fillColor: AppColors.card,
          onChanged: onSearchChanged,
        ),
        SizedBox(width: ButtonSizing.toolbarGap(context)),

        // Filter opens the Filter card (Figma frame 1597883942). While a
        // filter is applied the button carries the brand fill: the dialog
        // closes over the grid, so without this the only evidence that the
        // list is being narrowed is cards being absent — which reads as data
        // loss, not as a filter.
        CustomFilterIcon(
          title: strings.filter,
          color: isFilterActive ? AppColors.primary : AppColors.card,
          svgColor:
              isFilterActive ? AppColors.textButton : AppColors.secondaryText,
          // 22/10/2026 — Owner: dead textStyle removed — CustomFilterIcon draws its
          // label from ToolbarStyle (14 medium) since 18/10.
          onTap: onFilter,
        ),
        SizedBox(width: ButtonSizing.toolbarGap(context)),

        // SORT — the Figma's popover next to Filter.
        //
        // `CustomSortButton` rather than `CustomSortIcon`: the icon variant is
        // a bare button with an onTap, so making it work would have meant
        // hand-rolling the popover, its selected-row highlight and the
        // brand-fill-when-active state that Filter already has. The sort
        // button IS that popover, and it tints its own container from `value`
        // — which is why nothing here has to compute a colour.
        //
        // Deselecting is part of the widget's contract: tapping the selected
        // row hands back null, and `sortChanged` reads that as "back to the
        // repository's order".
        //
        // ICON-ONLY ON PHONE (`showTitle: false`), the same shape the
        // messaging module uses in portrait — a 38pt square, so the phone
        // toolbar keeps three same-sized controls beside the search box rather
        // than losing Sort altogether. The wider overlay offset on phone
        // clears the taller tap target.
        CustomSortButton<DatabaseSortOption>(
          value: sortOption,
          items: DatabaseSortOption.values,
          labelBuilder: (DatabaseSortOption option) => option.label(S.current),
          onChanged: onSortChanged,
          title: strings.sort,
          showTitle: !isPhone,
          // Wider than Filter's 100.sp so the label sits comfortably clear of
          // the icon. The width is FIXED regardless of what is selected — the
          // trigger always reads "Sort" — so the toolbar does not reflow when
          // the user picks an option.
          width: isPhone ? ButtonSizing.iconButtonSize : 100.sp,
          // Same source of truth as the Filter button beside it, rather than a
          // literal that happens to match today.
          height: ButtonSizing.height,
          yOffset: isPhone ? 50 : 16,
        ),
        SizedBox(width: ButtonSizing.toolbarGap(context)),

        customButtonWithSvg(
          // An empty title is `customButtonWithSvg`'s own icon-only mode — a
          // 38.sp square — which is exactly the phone frame's yellow create
          // button. Passing '' rather than shaping a square button here keeps
          // the sizing decision inside ButtonSizing.
          title: isPhone ? '' : strings.createDatabase,
          function: onCreate,
          color: AppColors.primary,
          colorBorder: AppColors.transparent,
          image: AppAssets.databaseCreate,
          widthImage: isPhone ? 24.r : 18.r,
          heightImage: isPhone ? 24.r : 18.r,
          // The icon is tinted to the button's computed label colour rather
          // than left at its own fill, so it stays legible if the company's
          // brand primary is dark. See AppTheme.contrastColor().
          svgColor: AppColors.textButton,
          // 22/10/2026 — Owner: toolbar text is 14 in every module (was 16).
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.textButton,
          ),
        ),
      ],
    );
  }
}
