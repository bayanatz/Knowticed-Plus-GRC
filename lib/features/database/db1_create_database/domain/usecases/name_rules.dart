/// Module: database / db1_create_database / domain / usecases
///
///*************************** FILE INFO ****************************///
/// File Name: name_rules.dart
/// Description: Declares `NameRules` and `NamePairErrors`.
/// Author: Amr Mesbah
/// Created at: 24/10/2026
///
/// The one set of rules for a bilingual name — a database's titles and a
/// table's names: both required, both at least
/// `CreateDatabaseLimits.titleMinLength` long, and not already taken. The
/// create wizard, the Edit Database screen and the table card all use this,
/// so the three cannot disagree.
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/create_database_limits.dart';

/// The error under each name field, or null when that field is fine.
class NamePairErrors {
  /// Function Name: [NamePairErrors]
  ///
  /// Purpose: The two field errors of one validation.
  const NamePairErrors({this.enError, this.arError});

  final String? enError;
  final String? arError;

  /// True when both names passed.
  bool get isValid => enError == null && arError == null;
}

/// Validation and the duplicate check for a bilingual name.
abstract final class NameRules {
  /// Function Name: [validate]
  ///
  /// Purpose: The local checks — required, and not too short. Free, so it
  /// runs before any network call. The messages are passed in because the
  /// domain layer has no locale.
  ///
  /// Parameters: [nameEn], [nameAr] the names as typed; the three messages.
  ///
  /// Returns: [NamePairErrors].
  static NamePairErrors validate({
    required String nameEn,
    required String nameAr,
    required String requiredEnMessage,
    required String requiredArMessage,
    required String tooShortMessage,
  }) =>
      NamePairErrors(
        enError: _error(nameEn.trim(), requiredEnMessage, tooShortMessage),
        arError: _error(nameAr.trim(), requiredArMessage, tooShortMessage),
      );

  /// Function Name: [changed]
  ///
  /// Purpose: Whether the names differ from the saved ones, ignoring case and
  /// spaces. A create has nothing saved, so it always counts as changed.
  ///
  /// Parameters: [nameEn], [nameAr] the new names; [previousEn],
  /// [previousAr] the saved ones, or null on a create.
  ///
  /// Returns: [bool].
  static bool changed({
    required String nameEn,
    required String nameAr,
    String? previousEn,
    String? previousAr,
  }) =>
      previousEn == null ||
      previousAr == null ||
      _key(nameEn) != _key(previousEn) ||
      _key(nameAr) != _key(previousAr);

  /// Function Name: [ensureFree]
  ///
  /// Purpose: Ask [exists] whether the names are taken, and turn the answer
  /// into one result: a failed lookup stays its [Failure], a taken name
  /// becomes a [ValidationError] with [duplicateMessage].
  ///
  /// Parameters: [exists] the repository's duplicate query;
  /// [duplicateMessage] the message for a taken name.
  ///
  /// Returns: [Future<Either<Failure, void>>] Right when the names are free.
  static Future<Either<Failure, void>> ensureFree({
    required Future<Either<Failure, bool>> Function() exists,
    required String duplicateMessage,
  }) async {
    final Either<Failure, bool> taken = await exists();
    return taken.fold(
      (Failure failure) => Left<Failure, void>(failure),
      (bool isTaken) => isTaken
          ? Left<Failure, void>(ValidationError(duplicateMessage))
          : const Right<Failure, void>(null),
    );
  }

  static String? _error(String value, String required, String tooShort) {
    if (value.isEmpty) return required;
    if (value.length < CreateDatabaseLimits.titleMinLength) return tooShort;
    return null;
  }

  static String _key(String value) => value.trim().toLowerCase();
}
