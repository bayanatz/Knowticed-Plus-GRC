/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: share_repository.dart
/// Description: `ShareRepository`, the Firestore [ShareBaseRepository].
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Typed results; data source injected.
/// Updated: 23/10/2026 - Returns the shared emails, not the data model.
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/features/form_builder/helpers/fb_failure.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder/data/models/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/data/data_source/remote_data_source/share_remote_data_source.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/domain/base_repository/share_base_repository.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The [ShareBaseRepository] backed by Firestore.
class ShareRepository implements ShareBaseRepository {
  /// The Firestore access (injected).
  final ShareRemoteDataSource shareRemoteDataSource;

  ShareRepository({required this.shareRemoteDataSource});

  @override
  Future<Either<Failure, List<String>>> getSharedEmails(String formId) async {
    try {
      final FormPrivacyModel? model = await shareRemoteDataSource
          .getFormPrivacy(formId);
      return Right(_emailsOf(model));
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<String>>> grantAccess({
    required String formId,
    required List<PersonEntity> persons,
    required DateTime timeBegin,
    required DateTime timeEnd,
    required bool isEditPermission,
  }) async {
    // The end date must be after the start date.
    if (!timeEnd.isAfter(timeBegin)) {
      return Left(ValidationError(S.current.endDateBeforeStartDate));
    }
    try {
      final FormPrivacyModel saved = await shareRemoteDataSource.grantAccess(
        formId: formId,
        persons: persons,
        timeBegin: timeBegin,
        timeEnd: timeEnd,
        isEditPermission: isEditPermission,
      );
      return Right(_emailsOf(saved));
    } catch (e, stackTrace) {
      fbFailure(e, stackTrace);
      return Left(FirebaseFailure(S.current.shareFailed));
    }
  }

  /// The emails on [model]'s access list (empty when there is none).
  List<String> _emailsOf(FormPrivacyModel? model) =>
      List<String>.of(model?.usersModel?.emails ?? const <String>[]);
}
