/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: group_repository.dart
/// Description: `GroupRepository`, the Firestore [GroupBaseRepository].
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Typed results; data source injected.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/domain/base_repository/group_base_repository.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/data/data_source/remote_data_source/group_data_source.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/data/models/forms_group_model.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/domain/entities/group_record.dart';
import 'package:knowticed_plus/features/form_builder/helpers/fb_failure.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The [GroupBaseRepository] backed by Firestore and Storage.
class GroupRepository implements GroupBaseRepository {
  /// The Firestore / Storage access (injected).
  final GroupDataSource groupDataSource;

  GroupRepository({required this.groupDataSource});

  @override
  Future<Either<Failure, void>> createGroup({
    required List<PersonEntity> selectedPersons,
    required String description,
    required String groupName,
    required String currentUserId,
    String? image,
  }) async {
    try {
      final String id =
          "${currentUserId}_${Timestamp.now().microsecondsSinceEpoch}";
      final String? imageUrl = image == null
          ? null
          : await groupDataSource.uploadImage(
              image: image,
              userId: currentUserId,
              groupId: id,
            );
      final FormsGroupModel formsGroupModel = FormsGroupModel(
        id: id,
        emails: selectedPersons.map((e) => e.id).toList(),
        status: selectedPersons.map((e) => "active").toList(),
        image: imageUrl == null ? [] : [imageUrl],
        name: [groupName],
        description: [description],
        timestamp: [Timestamp.now()],
      );
      await groupDataSource.saveGroup(formsGroupModel, id, currentUserId);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<GroupRecord>>> getGroups({
    required String currentUserId,
  }) async {
    try {
      final List<FormsGroupModel> groups = await groupDataSource.getGroups(
        currentUserId: currentUserId,
      );
      // FB-SHARE-01: a group is dropped only when the GROUP is deleted;
      // removed (inactive) members are left out of the record.
      return Right([
        for (final FormsGroupModel group in groups)
          if (!group.isDeleted) _toRecord(group),
      ]);
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  /// The domain view of a stored group.
  GroupRecord _toRecord(FormsGroupModel model) {
    final Set<String> inactive = {
      for (int i = 0; i < model.status.length && i < model.emails.length; i++)
        if (model.status[i] == 'inactive') model.emails[i],
    };
    return GroupRecord(
      id: model.id,
      name: model.name.isEmpty ? '' : model.name.last,
      description: model.description.isEmpty ? '' : model.description.last,
      image: model.image.isEmpty ? null : model.image.last,
      activeMemberEmails: [
        for (final String email in model.emails)
          if (!inactive.contains(email)) email,
      ],
    );
  }

  @override
  Future<Either<Failure, void>> deleteGroup({
    required String userId,
    required String groupId,
  }) async {
    try {
      await groupDataSource.deleteGroup(groupId: groupId, userId: userId);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> editGroup({
    String? groupImage,
    required String groupName,
    required String description,
    required String groupId,
    required List<String> removedPersons,
    required String currentUserId,
  }) async {
    try {
      final FormsGroupModel? group = await groupDataSource.getGroupData(
        groupId: groupId,
        currentUserId: currentUserId,
      );
      if (group == null) {
        return Left(FirebaseFailure(S.current.groupActionFailed));
      }
      if (groupName != group.name.last) group.name.add(groupName);
      if (description != group.description.last) {
        group.description.add(description);
      }
      for (int i = 0; i < group.emails.length; i++) {
        if (removedPersons.contains(group.emails[i])) {
          group.status[i] = "inactive";
        }
      }
      if (groupImage != null) {
        group.image.add(
          await groupDataSource.uploadImage(
            image: groupImage,
            userId: currentUserId,
            groupId: groupId,
          ),
        );
      }
      group.timestamp.add(Timestamp.now());
      await groupDataSource.saveGroup(group, groupId, currentUserId);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }
}
