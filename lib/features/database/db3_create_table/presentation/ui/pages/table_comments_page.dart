/// Module: database / db3_create_table / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: table_comments_page.dart
/// Description: Declares `TableCommentsPage`.
/// Author: Amr Mesbah
/// Created at: 17/8/2026
///
/// "Comments" — Figma 7398:8232 (iPad H 1024, the thread), 7398:8311 / 8587
/// (the reply and reacted states), 7398:8360 / 8437 / 8484 (the 768 twins).
///
/// Reached from the yellow Comments button on the Table Name Details card, and
/// from nowhere else: the breadcrumb is four crumbs deep
/// ("Database > Database Details > Table Name Details > Comments") and every one
/// of them is a screen this was pushed from.
///
/// ONE CARD, TWO PARTS
/// -------------------
/// The Figma draws the whole screen as a single white card with the thread
/// scrolling inside it and the composer pinned to its bottom edge. That pinning
/// is the reason the list is not simply part of the page scroll: a composer that
/// slid away as the conversation grew would leave the user scrolling to the
/// bottom to reply.
///
/// WHY THE HEIGHT IS HANDLED TWICE
/// -------------------------------
/// `SideFrameMasterServices` hands its child a BOUNDED height on a tablet
/// (`Expanded(child: child!)`) and an UNBOUNDED one on a phone, where the shell
/// itself is a scroll view. A pinned composer needs a bound, so the phone branch
/// supplies one from the viewport instead. Same fork
/// `CreateDatabaseMetrics.pageScroll` documents, resolved the other way round —
/// this page cannot be part of an outer scroll.
///
/// Updated: 22/10/2026 - Moataz: "Settings → Requests, Inquiries And Comments
/// is the perfect model — apply it everywhere … fix the database". The card
/// now holds the shared `UniversalCommentSection` (the Settings box) over
/// this table's own thread through [_TableCommentSource]: the same cubit,
/// collection, permission (`canPost`) and delete as before. The table thread
/// has no edit and no files, so the box shows neither; reactions are not
/// drawn by the shared box.
library;

import 'package:knowticed_plus/core/custom/inputs/custom_comment_widget.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/base_repository/create_table_base_repository.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/create_database_base_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_comment.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/table_comments/table_comments_cubit.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_session_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_directory_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/create_table_strings.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/widgets/database_details_strings.dart';
import 'package:knowticed_plus/features/database/helpers/routes/database_routes.dart';

class TableCommentsPage extends StatefulWidget {
  const TableCommentsPage({
    super.key,
    required this.database,
    required this.table,
  });

  /// The parent, carried for its NAME only — the second crumb. The thread's
  /// path comes off [table], which knows its own `databaseId`.
  final DatabaseEntity database;

  final DatabaseTableEntity table;

  static Future<void> open(
    BuildContext context, {
    required DatabaseEntity database,
    required DatabaseTableEntity table,
  }) {
    return Navigator.of(context).push<void>(
      DatabaseRouter.route<void>(
        DatabaseRoutes.tableComments,
        builder: (_) => BlocProvider<TableCommentsCubit>(
          create: (BuildContext ctx) => TableCommentsCubit(
            table: table,
            session: ctx.read<DatabaseSessionBaseRepository>(),
            directory: ctx.read<DatabaseDirectoryBaseRepository>(),
            repository: ctx.read<CreateTableBaseRepository>(),
            databaseNameEn: database.titleEn,
            databaseNameAr: database.titleAr,
            databaseRepository: ctx.read<CreateDatabaseBaseRepository>(),
          ),
          child: TableCommentsPage(database: database, table: table),
        ),
      ),
    );
  }

  @override
  State<TableCommentsPage> createState() => _TableCommentsPageState();
}

class _TableCommentsPageState extends State<TableCommentsPage> {
  late final TableCommentsCubit _cubit = context.read<TableCommentsCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final bool isArabic = context.isArabic;

    final String databaseTitle = FormatHelper.capitalize(
      widget.database.localizedTitle(isArabic: isArabic),
    );
    final String tableName = FormatHelper.capitalize(
      widget.table.localizedName(isArabic: isArabic),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: strings.database,
        secondTitle:
            DatabaseDetailsStrings.of(context).detailsCrumb(databaseTitle),
        thirdTitle: strings.tableDetailsCrumb(tableName),
        fourthTitle: strings.comments,
        // Every crumb but the last leaves this screen. They pop rather than
        // pushing a fresh copy of the screen they name: those screens are still
        // underneath this one, with their scroll position and their state.
        onFirstTap: () => Navigator.of(context).pop(),
        onSecondTap: () => Navigator.of(context).pop(),
        onThirdTap: () => Navigator.of(context).pop(),
        child: BlocBuilder<TableCommentsCubit, TableCommentsState>(
          bloc: _cubit,
          // Rebuilt for the author / permission only — the thread itself
          // streams into the box through the source.
          buildWhen: (TableCommentsState was, TableCommentsState now) =>
              was.currentEmployeeId != now.currentEmployeeId ||
              was.canPost != now.canPost,
          builder: (BuildContext context, TableCommentsState state) =>
              _box(context, state),
        ),
      ),
    );
  }

  /// The shared comments box. The page's shell hands a bounded height on a
  /// tablet and an unbounded one on a phone (it scrolls), so the phone gets
  /// 72% of the screen, as the old card did.
  Widget _box(BuildContext context, TableCommentsState state) {
    Widget box(double height) => UniversalCommentSection(
          currentUserId: state.currentEmployeeId,
          source: _TableCommentSource(_cubit, isArabic: context.isArabic),
          isExpandable: false,
          collapsedHeight: height,
          fixedHeight: height,
        );
    if (context.isPhone) {
      return box(MediaQuery.sizeOf(context).height * 0.72);
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) => box(
        c.maxHeight.isFinite
            ? c.maxHeight
            : MediaQuery.sizeOf(context).height * 0.72,
      ),
    );
  }
}

/// The table thread, as the shared box reads it.
class _TableCommentSource extends CommentSource {
  const _TableCommentSource(this.cubit, {required this.isArabic});

  final TableCommentsCubit cubit;
  final bool isArabic;

  @override
  String get identity => 'database_table|${cubit.state.tableId}|$isArabic';

  @override
  bool get canWrite => cubit.state.canPost;

  @override
  bool get supportsFiles => false;

  @override
  bool get supportsEdit => false;

  List<CommentEntry> _entries(TableCommentsState s) => <CommentEntry>[
        for (final TableComment c in s.comments)
          CommentEntry(
            id: c.id,
            text: c.text,
            commenterEmail: c.authorId,
            date: c.createdAt,
            name: c.localizedAuthorName(isArabic: isArabic),
            subtitle: c.localizedAuthorJobTitle(isArabic: isArabic),
            photo: c.authorPhotoUrl ?? '',
            canModify:
                c.authorId.isNotEmpty && c.authorId == s.currentEmployeeId,
            handle: c,
          ),
      ];

  @override
  Stream<List<CommentEntry>> watch() async* {
    if (!cubit.state.isLoading) yield _entries(cubit.state);
    await for (final TableCommentsState s in cubit.stream) {
      if (!s.isLoading) yield _entries(s);
    }
  }

  @override
  Future<void> add({
    required String currentUserId,
    String? text,
    String? fileUrl,
    String? fileName,
    String? fileSize,
  }) async {
    if (text == null || text.trim().isEmpty) return;
    final bool posted = await cubit.post(text);
    if (!posted) {
      final String message = cubit.state.errorMessage ?? '';
      cubit.clearMessages();
      // The box shows this in its error snackbar and keeps the text.
      throw Exception(message);
    }
  }

  @override
  Future<void> edit(CommentEntry comment, String text) async {}

  @override
  Future<bool> delete(CommentEntry comment) =>
      cubit.delete(comment.handle! as TableComment);
}
