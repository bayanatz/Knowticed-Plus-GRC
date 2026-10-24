/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: result_remote_data_source.dart
/// Description: `ResultRemoteDataSource`, reads a form's access record for
///              the Results page. Responses are read through the one
///              response store (`ResponseRepo`), not here.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/form_builder/helpers/constants/fb_api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/form_builder/data/models/form_privacy_model.dart';

/// Reads a form's access record.
class ResultRemoteDataSource {
  ResultRemoteDataSource({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Method Name: [getFormPrivacy]
  ///
  /// Purpose: the form's access record.
  ///
  /// Parameters:
  /// - [formId]: the form.
  ///
  /// Returns: the record, or null when it does not exist; throws on a read
  /// error.
  Future<FormPrivacyModel?> getFormPrivacy(String formId) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _db
        .collection(getBaseUrl(FormApiConstants.formPrivacy))
        .doc(formId)
        .get();
    final Map<String, dynamic>? data = doc.data();
    if (!doc.exists || data == null) return null;
    return FormPrivacyModel.fromMap(data, id: doc.id);
  }
}
