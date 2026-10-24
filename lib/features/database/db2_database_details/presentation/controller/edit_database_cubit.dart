/// Module: database / db2_database_details / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: edit_database_cubit.dart
/// Description: Declares `EditDatabaseCubit`.
/// Author: Amr Mesbah
/// Created at: 16/8/2026
///
/// "Editing Database Name" — Figma 7398:6461 (iPad V) / 7398:16968 (iPad H).
///
/// The same card as the create screen (cover, bilingual title, bilingual
/// description) with two differences that go all the way down:
///
///   * it starts FULL, seeded from the record, so [isDirty] is "different from
///     what was loaded" rather than "not empty"
///   * it UPDATES, so the duplicate-title check has to ignore the record being
///     edited — see `DatabaseDetailsBaseRepository.titleExists`
///
/// There is no access dropdown here: the Figma puts access on its own screen
/// ("Editing Database Access"), and editing it means rewriting the grants,
/// which is a different write with a different confirmation.
library;

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/features/database/db1_create_database/domain/usecases/name_rules.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/base_repository/database_details_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_session_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/use_cases/database_access_rule.dart';

part './edit_database_state.dart';

class EditDatabaseCubit extends Cubit<EditDatabaseState> {
  EditDatabaseCubit({
    required DatabaseEntity database,
    required DatabaseSessionBaseRepository session,
    required DatabaseDetailsBaseRepository repository,
    DatabaseAccessRule rule = const DatabaseAccessRule(),
  })  : _repository = repository,
        _original = database,
        _session = session,
        _rule = rule,
        super(EditDatabaseState.from(database));

  final DatabaseDetailsBaseRepository _repository;

  /// The record as it was opened, for the access check before saving.
  final DatabaseEntity _original;
  final DatabaseSessionBaseRepository _session;
  final DatabaseAccessRule _rule;

  @override
  void emit(EditDatabaseState state) {
    if (isClosed) return;
    super.emit(state);
  }

  // ── Fields ───────────────────────────────────────────────────────────────

  /// Function Name: [titleEnChanged]
  ///
  /// Purpose: Store the English title as typed and clear its error.
  void titleEnChanged(String value) =>
      emit(state.copyWith(titleEn: value, clearTitleEnError: true));

  /// Function Name: [titleArChanged]
  ///
  /// Purpose: Store the Arabic title as typed and clear its error.
  void titleArChanged(String value) =>
      emit(state.copyWith(titleAr: value, clearTitleArError: true));

  /// Function Name: [descriptionEnChanged]
  ///
  /// Purpose: Store the English description as typed.
  void descriptionEnChanged(String value) =>
      emit(state.copyWith(descriptionEn: value));

  /// Function Name: [descriptionArChanged]
  ///
  /// Purpose: Store the Arabic description as typed.
  void descriptionArChanged(String value) =>
      emit(state.copyWith(descriptionAr: value));

  /// Function Name: [coverImagePicked]
  ///
  /// Purpose: Store the cover image the user picked.
  void coverImagePicked(File file) => emit(state.copyWith(coverImage: file));

  /// Function Name: [clearMessages]
  ///
  /// Purpose: Clear the error and success messages once the screen has shown them, so a rebuild does not show them twice.
  void clearMessages() => emit(state.copyWith(clearErrorMessage: true));

  /// Puts every field back to the record as loaded — "Discard Changes".
  ///
  /// Resets rather than pops, because the page also has to push the same
  /// values back into its `TextEditingController`s; a cubit that only popped
  /// would leave the boxes showing the edits it had just thrown away.
  void discard() => emit(EditDatabaseState.from(state.original));

  // ── Save ─────────────────────────────────────────────────────────────────

  /// Function Name: [save]
  ///
  /// Purpose: Validate, check the title is free, and write.
  ///
  /// The localized copy is passed in because a cubit has no BuildContext and
  /// the domain layer must not acquire one — the same arrangement db1 uses.
  ///
  /// ORDER MATTERS. Local validation first (free, no network), then the
  /// duplicate query, then the write. Running the duplicate check on an empty
  /// title would spend a Firestore read to be told that "" is available.
  Future<void> save({
    required String requiredEnMessage,
    required String requiredArMessage,
    required String tooShortMessage,
    required String duplicateMessage,
  }) async {
    // The page only offers Edit at Edit level; this stops any other caller
    // (DB-DETAILS-01).
    final bool allowed = !_original.isDeleted &&
        _rule
            .resolve(
              _original,
              viewerId: _session.signedInEmployeeId,
              today: DateTime.now(),
            )
            .canEdit;
    if (!allowed) return;

    final String titleEn = state.titleEn.trim();
    final String titleAr = state.titleAr.trim();

    final NamePairErrors errors = NameRules.validate(
      nameEn: titleEn,
      nameAr: titleAr,
      requiredEnMessage: requiredEnMessage,
      requiredArMessage: requiredArMessage,
      tooShortMessage: tooShortMessage,
    );
    final String? enError = errors.enError;
    final String? arError = errors.arError;

    if (enError != null || arError != null) {
      emit(
        state.copyWith(
          submitted: true,
          status: EditDatabaseStatus.initial,
          titleEnError: enError,
          titleArError: arError,
          clearTitleEnError: enError == null,
          clearTitleArError: arError == null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        submitted: true,
        status: EditDatabaseStatus.submitting,
        clearErrorMessage: true,
        clearTitleEnError: true,
        clearTitleArError: true,
      ),
    );

    // Only worth asking when a title actually changed.
    if (NameRules.changed(
      nameEn: titleEn,
      nameAr: titleAr,
      previousEn: state.original.titleEn,
      previousAr: state.original.titleAr,
    )) {
      final Either<Failure, void> free = await NameRules.ensureFree(
        exists: () => _repository.titleExists(
          titleEn: titleEn,
          titleAr: titleAr,
          excludeId: state.original.id,
        ),
        duplicateMessage: duplicateMessage,
      );
      final Failure? taken = free.fold((Failure f) => f, (_) => null);
      if (taken != null) {
        emit(
          state.copyWith(
            status: EditDatabaseStatus.failure,
            errorMessage: taken.errMessage,
          ),
        );
        return;
      }
    }

    final DatabaseEntity edited = state.original.copyWith(
      titleEn: titleEn,
      titleAr: titleAr,
      descriptionEn: state.descriptionEn.trim(),
      descriptionAr: state.descriptionAr.trim(),
    );

    final Either<Failure, DatabaseEntity> result = await _repository
        .updateDatabase(edited, coverImagePath: state.coverImage?.path);

    emit(
      result.fold(
        (Failure failure) => state.copyWith(
          status: EditDatabaseStatus.failure,
          // Another save took the title at the same moment (DB-CREATE-11).
          errorMessage: failure is ConflictFailure
              ? duplicateMessage
              : failure.errMessage,
        ),
        // Seeded from what came BACK, not from what was sent: the server
        // resolved `updated_at` and the cover URL, and the next Discard has to
        // go back to the saved state rather than to the pre-save one.
        (DatabaseEntity saved) => EditDatabaseState.from(saved)
            .copyWith(status: EditDatabaseStatus.success, savedDatabase: saved),
      ),
    );
  }
}
