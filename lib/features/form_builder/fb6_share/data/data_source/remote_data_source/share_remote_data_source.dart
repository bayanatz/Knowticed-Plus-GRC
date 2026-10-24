/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: share_remote_data_source.dart
/// Description: `ShareRemoteDataSource`, Firestore access for a form's
///              access list. Methods throw on failure; the repository turns
///              errors into failures.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Typed return types; the grant transaction moved
///                       here from the repository.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/form_builder/helpers/constants/fb_api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/form_builder/data/models/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder/data/models/users_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';

/// Firestore access for a form's access list.
class ShareRemoteDataSource {
  ShareRemoteDataSource({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _privacy(String formId) =>
      _db.collection(getBaseUrl(FormApiConstants.formPrivacy)).doc(formId);

  /// Method Name: [getFormPrivacy]
  ///
  /// Purpose: the access list of a form.
  ///
  /// Parameters:
  /// - [formId]: the form.
  ///
  /// Returns: the access list, or null when the form has none; throws when
  /// the read fails.
  Future<FormPrivacyModel?> getFormPrivacy(String formId) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _privacy(formId)
        .get();
    final Map<String, dynamic>? data = doc.data();
    if (!doc.exists || data == null) return null;
    return FormPrivacyModel.fromMap(data);
  }

  /// Method Name: [grantAccess]
  ///
  /// Purpose: FB-SHARE-06: in ONE transaction, reads the current access
  /// list, adds [persons] (or updates the entry of someone already on it)
  /// and writes it back, so a share from another device is never lost.
  ///
  /// Parameters:
  /// - [formId]: the form.
  /// - [persons]: the people to give access to.
  /// - [timeBegin]: start of the access.
  /// - [timeEnd]: end of the access.
  /// - [isEditPermission]: whether they may edit their answer.
  ///
  /// Returns: the saved access list; throws when the transaction fails.
  Future<FormPrivacyModel> grantAccess({
    required String formId,
    required List<PersonEntity> persons,
    required DateTime timeBegin,
    required DateTime timeEnd,
    required bool isEditPermission,
  }) {
    final DocumentReference<Map<String, dynamic>> ref = _privacy(formId);
    return _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final Map<String, dynamic>? data = snapshot.data();
      final FormPrivacyModel model = data != null
          ? FormPrivacyModel.fromMap(data, id: formId)
          : FormPrivacyModel(timestamps: [], id: formId);
      final UsersModel users = model.usersModel ?? UsersModel();
      final List<String> emails = List<String>.from(users.emails ?? []);
      final int n = emails.length;
      List<T> padded<T>(List<T>? list, T filler) {
        final List<T> out = List<T>.from(list ?? <T>[]);
        while (out.length < n) {
          out.add(filler);
        }
        return out.sublist(0, n);
      }

      final List<String> status = padded<String>(users.status, 'active');
      final List<Timestamp?> begin = padded<Timestamp?>(
        users.accessBegin,
        null,
      );
      final List<Timestamp?> end = padded<Timestamp?>(users.accessEnd, null);
      final List<bool> edit = padded<bool>(users.editPermission, false);
      final List<bool> shared = padded<bool>(users.shared, false);

      for (final PersonEntity person in persons) {
        final int i = emails.indexOf(person.id);
        if (i >= 0) {
          status[i] = 'active';
          begin[i] = Timestamp.fromDate(timeBegin);
          end[i] = Timestamp.fromDate(timeEnd);
          edit[i] = isEditPermission;
          shared[i] = true;
        } else {
          emails.add(person.id);
          status.add('active');
          begin.add(Timestamp.fromDate(timeBegin));
          end.add(Timestamp.fromDate(timeEnd));
          edit.add(isEditPermission);
          shared.add(true);
        }
      }

      final FormPrivacyModel updated = FormPrivacyModel(
        id: formId,
        timestamps: [...?model.timestamps, Timestamp.now()],
        usersModel: UsersModel(
          emails: emails,
          status: status,
          accessBegin: begin,
          accessEnd: end,
          editPermission: edit,
          shared: shared,
        ),
      );
      transaction.set(ref, updated.toMap(), SetOptions(merge: true));
      return updated;
    });
  }
}
