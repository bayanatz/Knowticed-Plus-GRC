/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: social_base_repository.dart
/// Purpose: Domain contract for persisting the social section of a profile.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE2-N01. `SocialController.updateAllSocialInformation`
/// called `FirebaseFirestore.instance…update(...)` directly from presentation.

import 'package:dartz/dartz.dart';

import 'package:grc_module/core/network/failure_model.dart';

abstract class SocialBaseRepository {
  /// Function Name: [updateSocialFields]
  ///
  /// Purpose: Merge the given fields into the employee's profile document.
  ///
  /// Parameters:
  /// - [employeeId]: Firestore document id.
  /// - [fields]: only the changed top-level keys, as produced by
  ///   `BuildSocialUpdate`. Never empty — the caller short-circuits on an empty
  ///   change set rather than issuing a no-op write.
  ///
  /// Returns: [Future<Either<Failure, void>>].
  Future<Either<Failure, void>> updateSocialFields({
    required String employeeId,
    required Map<String, dynamic> fields,
  });
}
