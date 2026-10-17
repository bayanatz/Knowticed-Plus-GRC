/// Module: roles/r1_role_management
///
///*************************** FILE INFO ****************************///
/// File Name: role_repository_methods.dart
/// Description: Methods of `RoleRepository` — split out of `role_repository.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../role_repository.dart';

// Split from role_repository.dart to keep every file under 700 lines.

extension RoleRepositoryMethods on RoleRepository {
  Future<Either<FirebaseFailure, Map<String, Map<String, bool>>>>
      validatePermissionsAgainstAdmin({
    required Map<String, Map<String, bool>> requestedPermissions,
    required String companyId,
  }) async {
    try {
      DocumentSnapshot demoPermDoc = await firestore
          .collection(FirebaseCollections.demoPermissions)
          .doc(companyId)
          .get();

      if (!demoPermDoc.exists) {
        // SECURITY (default-deny): this used to `return Right(requestedPermissions)`
        // — a missing admin-permission document granted every permission the
        // caller asked for. Failing closed here surfaces the misconfiguration
        // instead of silently persisting elevated permissions.
        return Left(
          FirebaseFailure(
            'Permission template for this company is unavailable, so the role '
            'cannot be validated. No changes were saved.',
          ),
        );
      }

      Map<String, dynamic> demoPermissions =
          demoPermDoc.data() as Map<String, dynamic>;

      // 9/10/2026 — the capping loop moved, unchanged, into the pure
      // [capToCompanyCeiling] so role creation's
      // Subscription_Permission_Admin document can be unit-tested.
      return Right(
        RoleRepository.capToCompanyCeiling(
          requestedPermissions: requestedPermissions,
          demoPermissions: demoPermissions,
        ),
      );
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
}
