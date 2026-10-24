/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: group_data_source.dart
/// Description: `GroupDataSource`, Firestore and Storage access for the
///              user's form groups. Methods throw on failure; the
///              repository turns errors into failures.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Typed return types; method docs.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/features/form_builder/helpers/constants/fb_api_constants.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/app_services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/data/models/forms_group_model.dart';

/// Firestore and Storage access for the user's form groups.
class GroupDataSource {
  GroupDataSource({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _groups(
    String currentUserId,
  ) => _db.collection(
    "${getBaseUrl(FormApiConstants.formGroups)}/$currentUserId/${FormApiConstants.groups}",
  );

  /// Method Name: [saveGroup]
  ///
  /// Purpose: writes a group (create, or edit with merge).
  ///
  /// Parameters:
  /// - [groupModel]: the group to write.
  /// - [id]: the group id.
  /// - [currentUserId]: the owner's email.
  ///
  /// Returns: [Future<void>]; throws when the write fails.
  Future<void> saveGroup(
    FormsGroupModel groupModel,
    String id,
    String currentUserId,
  ) async {
    await _groups(currentUserId)
        .doc(id)
        .set(groupModel.toMap(), SetOptions(merge: true));
  }

  /// Method Name: [getGroups]
  ///
  /// Purpose: the user's groups that are not deleted.
  ///
  /// Parameters:
  /// - [currentUserId]: the owner's email.
  ///
  /// Returns: the groups; throws when the read fails.
  Future<List<FormsGroupModel>> getGroups({
    required String currentUserId,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _groups(
      currentUserId,
    ).where(FormsGroupModel.fieldIsDeleted, isNotEqualTo: true).get();
    return snapshot.docs
        .map((doc) => FormsGroupModel.fromMap(doc.data()))
        .toList();
  }

  /// Method Name: [uploadImage]
  ///
  /// Purpose: uploads the group image to Storage.
  ///
  /// Parameters:
  /// - [image]: the local file path.
  /// - [userId]: the owner's email.
  /// - [groupId]: the group id.
  ///
  /// Returns: the download URL; throws when the upload fails.
  Future<String> uploadImage({
    required String image,
    required String userId,
    required String groupId,
  }) async {
    final String fileName = image.split('/').last.split('.').first;
    final String ext = image.split('.').last;
    final Either<FirebaseFailure, String> result =
        await FirebaseRepository.uploadFile(
          collectionName: getBaseUrl(
            "${FormApiConstants.storageBase}/$userId/$groupId",
          ),
          documentName:
              "${fileName}_${DateTime.now().millisecondsSinceEpoch}.$ext",
          filePath: image,
        );
    return result.fold(
      (FirebaseFailure failure) => throw StateError(failure.message),
      (String url) => url,
    );
  }

  /// Method Name: [deleteGroup]
  ///
  /// Purpose: marks a group as deleted (it is kept for the history).
  ///
  /// Parameters:
  /// - [userId]: the owner's email.
  /// - [groupId]: the group id.
  ///
  /// Returns: [Future<void>]; throws when the write fails.
  Future<void> deleteGroup({
    required String userId,
    required String groupId,
  }) async {
    await _groups(userId).doc(groupId).set({
      FormsGroupModel.fieldIsDeleted: true,
      FormsGroupModel.fieldTimestamp: FieldValue.arrayUnion([Timestamp.now()]),
    }, SetOptions(merge: true));
  }

  /// Method Name: [getGroupData]
  ///
  /// Purpose: one group.
  ///
  /// Parameters:
  /// - [groupId]: the group id.
  /// - [currentUserId]: the owner's email.
  ///
  /// Returns: the group, or null when it does not exist; throws when the
  /// read fails.
  Future<FormsGroupModel?> getGroupData({
    required String groupId,
    required String currentUserId,
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _groups(
      currentUserId,
    ).doc(groupId).get();
    final Map<String, dynamic>? data = doc.data();
    if (!doc.exists || data == null) return null;
    return FormsGroupModel.fromMap(data);
  }
}
