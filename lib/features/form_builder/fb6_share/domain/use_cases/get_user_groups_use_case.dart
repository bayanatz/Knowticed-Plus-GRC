/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: get_user_groups_use_case.dart
/// Description: `GetUserGroupsUseCase`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/domain/entities/group_record.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/domain/entities/group_entity.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/domain/base_repository/group_base_repository.dart';

class GetUserGroupsUseCase {
  final GroupBaseRepository groupRepository;

  GetUserGroupsUseCase({required this.groupRepository});

  /// Method Name: [execute]
  ///
  /// Purpose: Gets all groups of the current user
  ///
  /// Parameters:
  ///            [currentUserId] The id of the current user
  ///            [availablePersons] All available persons to match against
  ///            [previousSelectedPersons] Previously selected persons
  ///
  /// Returns: the groups as entities, or the failure.
  Future<Either<Failure, List<GroupEntity>>> execute({
    required String currentUserId,
    List<PersonEntity>? availablePersons,
    List<PersonEntity>? previousSelectedPersons,
  }) async {
    final Either<Failure, List<GroupRecord>> result = await groupRepository
        .getGroups(currentUserId: currentUserId);
    return result.map(
      (List<GroupRecord> records) => [
        for (final GroupRecord record in records)
          _convertGroupModelToEntity(
            record,
            availablePersons ?? [],
            previousSelectedPersons ?? [],
          ),
      ],
    );
  }

  /// Method Name: [_convertGroupModelToEntity]
  ///
  /// Purpose: builds the [GroupEntity] of a saved group, with its active
  /// members matched to people.
  ///
  /// Parameters:
  /// - [record]: the saved group.
  /// - [availablePersons]: all available persons.
  /// - [previousSelectedPersons]: people who already have access.
  ///
  /// Returns: the group.
  GroupEntity _convertGroupModelToEntity(
    GroupRecord record,
    List<PersonEntity> availablePersons,
    List<PersonEntity> previousSelectedPersons,
  ) {
    final GroupEntity group = GroupEntity(
      groupId: record.id,
      groupDescription: record.description,
      groupName: record.name,
      groupImage: record.image,
      members: [],
    );
    final Set<String> membersEmails = Set.from(record.activeMemberEmails);

    // Large-screen bug report p.1 ("when I choose members they
    // duplicate"): people were matched against the employee list AND the
    // people who already have access, and the second pass checked
    // `contains(person)` — an identity check on a class without `==` — so
    // everyone in both lists was added twice. Members are kept once per id.
    final Set<String> addedIds = <String>{};

    // Match against available persons
    for (PersonEntity person in availablePersons) {
      if (membersEmails.contains(person.id) && addedIds.add(person.id)) {
        group.members.add(person);
      }
    }

    // Match against previously selected persons
    for (PersonEntity person in previousSelectedPersons) {
      if (membersEmails.contains(person.id) && addedIds.add(person.id)) {
        group.members.add(person);
      }
    }

    return group;
  }
}
