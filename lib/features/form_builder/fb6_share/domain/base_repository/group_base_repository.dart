/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: group_base_repository.dart
/// Description: `GroupBaseRepository`, the contract for the user's form
///              groups. Cubits and use cases depend on it, not on the
///              Firestore implementation.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Typed return types; method docs.
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/domain/entities/group_record.dart';

/// The contract for the user's form groups.
abstract class GroupBaseRepository {
  /// Method Name: [createGroup]
  ///
  /// Purpose: saves a new group (and uploads its image).
  ///
  /// Parameters:
  /// - [selectedPersons]: the members.
  /// - [description]: the group description.
  /// - [groupName]: the group name.
  /// - [currentUserId]: the owner's email.
  /// - [image]: the local image path, or null.
  ///
  /// Returns: [Right] when saved, or the failure.
  Future<Either<Failure, void>> createGroup({
    required List<PersonEntity> selectedPersons,
    required String description,
    required String groupName,
    required String currentUserId,
    String? image,
  });

  /// Method Name: [getGroups]
  ///
  /// Purpose: the user's groups that are not deleted.
  ///
  /// Parameters:
  /// - [currentUserId]: the owner's email.
  ///
  /// Returns: the groups, or the failure.
  Future<Either<Failure, List<GroupRecord>>> getGroups({
    required String currentUserId,
  });

  /// Method Name: [deleteGroup]
  ///
  /// Purpose: deletes a group.
  ///
  /// Parameters:
  /// - [userId]: the owner's email.
  /// - [groupId]: the group id.
  ///
  /// Returns: [Right] when deleted, or the failure.
  Future<Either<Failure, void>> deleteGroup({
    required String userId,
    required String groupId,
  });

  /// Method Name: [editGroup]
  ///
  /// Purpose: saves the name, description, image and removed members of a
  /// group.
  ///
  /// Parameters:
  /// - [groupImage]: the new local image path, or null to keep it.
  /// - [groupName]: the name.
  /// - [description]: the description.
  /// - [groupId]: the group id.
  /// - [removedPersons]: emails of the members removed.
  /// - [currentUserId]: the owner's email.
  ///
  /// Returns: [Right] when saved, or the failure.
  Future<Either<Failure, void>> editGroup({
    String? groupImage,
    required String groupName,
    required String description,
    required String groupId,
    required List<String> removedPersons,
    required String currentUserId,
  });
}
