/// Module: database / db3_create_table / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: table_comments_cubit.dart
/// Description: Declares `TableCommentsCubit`.
/// Author: Amr Mesbah
/// Created at: 17/8/2026
///
/// The thread behind Figma 7398:8232 (iPad H 1024), 7398:8360 / 8437 (iPad V
/// 768) and 7398:8587 / 8311 — read, post, react, delete.
///
/// WHO THE AUTHOR IS
/// -----------------
/// The screen is handed an employee id (the same `editedBy` the rest of the
/// module passes down from the drawer) and this cubit resolves the NAME, the
/// job title and the face from `DatabaseDirectoryBaseRepository` — the app's single
/// source for the org chart, and the same one `TableAccessCubit._loadDirectory`
/// uses. It degrades to the bare id rather than throwing: a thread that cannot
/// reach the directory should still be readable and postable, just with a
/// nameless bubble, and that is strictly better than an error over comments
/// that loaded fine.
///
/// The snapshot is taken ONCE per screen, not per message. It does not change
/// while the screen is open, and a directory read per keystroke-to-send would
/// be a lookup for something already known.
///
/// OPTIMISM, AND WHERE IT STOPS
/// ----------------------------
/// Posting appends the server's copy when it lands rather than a local one
/// first: the bubble prints a timestamp, and a message that appears with no
/// date and then quietly grows one is worse than a half-second of a spinning
/// send button. Reactions ARE optimistic — the thumb has to answer the tap
/// immediately — and roll back to the server's copy either way, because that is
/// the copy that includes everyone else's thumbs.
library;

import 'package:knowticed_plus/features/database/db1_create_database/data/models/create_database_collections.dart';
import 'package:bloc/bloc.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/create_database_base_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_directory_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/base_repository/create_table_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_comment.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_comments_access.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_session_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/models/create_table_collections.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/database_notification_dispatcher.dart';

part './table_comments_state.dart';

class TableCommentsCubit extends Cubit<TableCommentsState> {
  /// [table] is the record the details screen is already holding — the thread's
  /// path, its "Comments Access" setting and its creator all come off it, so the
  /// screen never has to re-read a document it was handed.
  TableCommentsCubit({
    required DatabaseTableEntity table,
    required DatabaseSessionBaseRepository session,
    required DatabaseDirectoryBaseRepository directory,
    required CreateTableBaseRepository repository,
    required String databaseNameEn,
    required String databaseNameAr,
    required CreateDatabaseBaseRepository databaseRepository,
  })  : _repository = repository,
        _databaseRepository = databaseRepository,
        _directory = directory,
        _table = table,
        _databaseNameEn = databaseNameEn,
        _databaseNameAr = databaseNameAr,
        super(
          TableCommentsState(
            databaseId: table.databaseId,
            tableId: table.id,
            // Who is reading, and therefore who posts (DB-TABLE-02).
            currentEmployeeId: session.signedInEmployeeId ?? '',
            commentsAccess: table.commentsAccess,
            tableCreatedBy: table.createdBy,
          ),
        );

  final CreateTableBaseRepository _repository;
  final LiveRefresh _live = LiveRefresh();

  /// For the "comment added" notification (DB-TABLE-21).
  final CreateDatabaseBaseRepository _databaseRepository;
  final DatabaseTableEntity _table;
  final String _databaseNameEn;
  final String _databaseNameAr;

  /// The org directory, for the author card on a new comment (rule 1).
  final DatabaseDirectoryBaseRepository _directory;

  @override
  void emit(TableCommentsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }

  /// Function Name: [load]
  ///
  /// Purpose: Read the thread, and the author's own details alongside it.
  ///
  /// The two run TOGETHER rather than one after the other: neither needs the
  /// other's answer, and serialising them would make the screen wait for the
  /// directory before it could draw comments that had already arrived.
  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(isLoading: true, clearErrorMessage: true));
    }

    final List<Object?> results = await Future.wait<Object?>(<Future<Object?>>[
      _repository.fetchComments(
        databaseId: state.databaseId,
        tableId: state.tableId,
      ),
      _resolveAuthor(),
    ]);

    final Either<Failure, List<TableComment>> thread =
        results.first as Either<Failure, List<TableComment>>;
    final _Author? author = results.last as _Author?;
    if (silent && thread.isLeft()) return;

    emit(
      thread.fold(
        (Failure failure) => state.copyWith(
          isLoading: false,
          errorMessage: failure.errMessage,
          authorNameEn: author?.nameEn,
          authorNameAr: author?.nameAr,
          authorJobTitleEn: author?.jobTitleEn,
          authorJobTitleAr: author?.jobTitleAr,
          authorPhotoUrl: author?.photoUrl,
          authorMissing: author == null,
        ),
        (List<TableComment> comments) => state.copyWith(
          isLoading: false,
          comments: List<TableComment>.unmodifiable(comments),
          clearErrorMessage: true,
          authorNameEn: author?.nameEn,
          authorNameAr: author?.nameAr,
          authorJobTitleEn: author?.jobTitleEn,
          authorJobTitleAr: author?.jobTitleAr,
          authorPhotoUrl: author?.photoUrl,
          authorMissing: author == null,
        ),
      ),
    );

    _live.watchPaths(
      <String>[
        '${getBaseUrl(CreateDatabaseCollections.databases)}/'
            '${state.databaseId}/${CreateTableCollections.tables}/'
            '${state.tableId}/${CreateTableCollections.comments}',
      ],
      () {
        if (state.isPosting || state.isLoading) return;
        load(silent: true);
      },
    );
  }

  /// Function Name: [post]
  ///
  /// Purpose: Write one message and append the server's copy.
  ///
  /// Whitespace-only text is dropped before the write rather than rejected with
  /// a message: the user pressed send on an empty box, which is a slip, not a
  /// mistake worth a dialog.
  Future<bool> post(String text) async {
    final String body = text.trim();
    if (body.isEmpty || state.isPosting || !state.canPost) return false;

    // Never post as nobody (DB-TABLE-10): look the author up again, and stop
    // with a message if they still cannot be found.
    if (state.authorMissing) {
      final _Author? author = await _resolveAuthor();
      if (isClosed) return false;
      if (author == null) {
        emit(state.copyWith(authorMissing: true));
        return false;
      }
      emit(
        state.copyWith(
          authorMissing: false,
          authorNameEn: author.nameEn,
          authorNameAr: author.nameAr,
          authorJobTitleEn: author.jobTitleEn,
          authorJobTitleAr: author.jobTitleAr,
          authorPhotoUrl: author.photoUrl,
        ),
      );
    }

    emit(state.copyWith(isPosting: true, clearErrorMessage: true));

    final Either<Failure, TableComment> result = await _repository.addComment(
      databaseId: state.databaseId,
      comment: TableComment(
        id: '',
        tableId: state.tableId,
        authorId: state.currentEmployeeId,
        authorNameEn: state.authorNameEn,
        authorNameAr: state.authorNameAr,
        authorJobTitleEn: state.authorJobTitleEn,
        authorJobTitleAr: state.authorJobTitleAr,
        authorPhotoUrl: state.authorPhotoUrl,
        text: body,
      ),
    );

    return result.fold(
      (Failure failure) {
        emit(
          state.copyWith(isPosting: false, errorMessage: failure.errMessage),
        );
        return false;
      },
      (TableComment saved) {
        // Appended, not re-fetched. The thread is ordered oldest-first and this
        // is the newest, so the end is exactly where the next read would put
        // it — and a refetch would throw away everyone else's scroll position
        // to learn something already known.
        emit(
          state.copyWith(
            isPosting: false,
            comments: List<TableComment>.unmodifiable(<TableComment>[
              ...state.comments,
              saved,
            ]),
            clearErrorMessage: true,
          ),
        );
        // Not awaited, the same as the table events: the comment is posted
        // whether or not the notification reaches anyone (DB-TABLE-21).
        DatabaseNotificationDispatcher.commentAdded(
          repository: _databaseRepository,
          databaseId: state.databaseId,
          databaseNameEn: _databaseNameEn,
          databaseNameAr: _databaseNameAr,
          tableNameEn: _table.nameEn,
          tableNameAr: _table.nameAr,
        );
        return true;
      },
    );
  }

  /// Function Name: [react]
  ///
  /// Purpose: Toggle one thumb on one comment.
  ///
  /// TAPPING THE REACTION YOU ALREADY HAVE CLEARS IT. That is why this takes the
  /// button that was pressed rather than the reaction to apply: the caller
  /// should not have to read the current state to work out that pressing Like
  /// twice means "no reaction", and two call sites doing that arithmetic
  /// differently is exactly how a thumb ends up stuck on.
  Future<void> react(TableComment comment, TableCommentReaction pressed) async {
    // Same gate as the composer, and for the same reason: engaging with a
    // thread is what "Shared" grants and "Private" withholds, and a thumb is
    // engagement. The screen also hides the buttons — this is the backstop.
    if (!state.canPost) return;

    final TableCommentReaction? next =
        comment.reactionOf(state.currentEmployeeId) == pressed ? null : pressed;

    // Optimistic: the thumb answers the tap now, and the server's copy replaces
    // this a moment later. `_replace` keys on the comment id, so the local guess
    // is overwritten rather than duplicated.
    _replace(_withLocalReaction(comment, next));

    final Either<Failure, TableComment> result =
        await _repository.setCommentReaction(
      databaseId: state.databaseId,
      tableId: state.tableId,
      commentId: comment.id,
      employeeId: state.currentEmployeeId,
      reaction: next,
    );

    result.fold((Failure failure) {
      // Put the ORIGINAL back, not the guess. Leaving the optimistic thumb up
      // over a write that failed is the one outcome the user cannot detect.
      _replace(comment);
      emit(state.copyWith(errorMessage: failure.errMessage));
    }, _replace);
  }

  /// Function Name: [delete]
  ///
  /// Purpose: Remove one of the reader's own messages; true when it is gone.
  ///
  /// The screen only offers this on a bubble the reader wrote — see
  /// `TableComment.isMine` — and this re-checks it rather than trusting the
  /// caller, because a repository call that deletes somebody else's comment is
  /// worth one comparison.
  Future<bool> delete(TableComment comment) async {
    if (!comment.isMine(state.currentEmployeeId)) return false;

    final Either<Failure, void> result = await _repository.deleteComment(
      databaseId: state.databaseId,
      tableId: state.tableId,
      commentId: comment.id,
    );

    return result.fold(
      (Failure failure) {
        emit(state.copyWith(errorMessage: failure.errMessage));
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            comments: List<TableComment>.unmodifiable(
              state.comments.where((TableComment c) => c.id != comment.id),
            ),
            clearErrorMessage: true,
          ),
        );
        return true;
      },
    );
  }

  /// Function Name: [clearMessages]
  ///
  /// Purpose: Clear the error and success messages once the screen has shown them, so a rebuild does not show them twice.
  void clearMessages() => emit(state.copyWith(clearErrorMessage: true));

  // ── Internals ────────────────────────────────────────────────────────────

  /// Swaps one comment for a newer copy of itself, in place.
  ///
  /// In place rather than re-sorting: the thread's order is the server's
  /// `created_at` and a reaction does not change it, so moving the bubble would
  /// be a visible jump for no reason.
  void _replace(TableComment updated) {
    emit(
      state.copyWith(
        comments: List<TableComment>.unmodifiable(<TableComment>[
          for (final TableComment c in state.comments)
            c.id == updated.id ? updated : c,
        ]),
      ),
    );
  }

  /// The comment as it would look with [reaction] applied by the current user —
  /// the local guess the optimistic path draws.
  TableComment _withLocalReaction(
    TableComment comment,
    TableCommentReaction? reaction,
  ) {
    final String me = state.currentEmployeeId;

    List<String> without(List<String> ids) =>
        ids.where((String id) => id != me).toList(growable: false);

    List<String> with_(List<String> ids) =>
        List<String>.unmodifiable(<String>[...without(ids), me]);

    return comment.copyWith(
      likedBy: reaction == TableCommentReaction.like
          ? with_(comment.likedBy)
          : without(comment.likedBy),
      dislikedBy: reaction == TableCommentReaction.dislike
          ? with_(comment.dislikedBy)
          : without(comment.dislikedBy),
    );
  }

  /// The signed-in person's name, title and photo, or null when they cannot be
  /// resolved. A thread is perfectly usable without it, so the caller treats
  /// null as "leave the fields as they are".
  Future<_Author?> _resolveAuthor() async {
    final Either<Failure, DatabaseMember?> result = await _directory.findMember(
      state.currentEmployeeId,
    );
    final DatabaseMember? me = result.fold((Failure _) => null, (m) => m);
    if (me == null) {
      if (kDebugMode) {
        debugPrint(
          '🔴 [TableCommentsCubit] signed-in employee not in the directory',
        );
      }
      return null;
    }
    return _Author(
      nameEn: me.nameEn,
      nameAr: me.nameAr,
      jobTitleEn: me.jobTitleEn ?? '',
      jobTitleAr: me.jobTitleAr ?? '',
      photoUrl: me.photoUrl,
    );
  }
}

/// The four author fields copied onto every comment this screen posts. A
/// private carrier rather than a `DatabaseMember`: that entity exists to be
/// WRITTEN into a grant and carries an email and a department id a comment has
/// no business holding.
@immutable
class _Author {
  const _Author({
    required this.nameEn,
    required this.nameAr,
    required this.jobTitleEn,
    required this.jobTitleAr,
    required this.photoUrl,
  });

  final String nameEn;
  final String nameAr;
  final String jobTitleEn;
  final String jobTitleAr;
  final String? photoUrl;
}
