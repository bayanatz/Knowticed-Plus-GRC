/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: home_remote_data_source.dart
/// Description: `HomeRemoteDataSource`, Firestore reads for the home screen.
///              Methods throw on failure; the repository turns errors into
///              failures.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Typed return types; errors are thrown, not hidden.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/form_builder/helpers/constants/fb_api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/data/models/response_model.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/data/models/user_responses_model.dart';

/// Firestore reads for the Form Builder home screen.
class HomeRemoteDataSource {
  HomeRemoteDataSource({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _index =>
      _db.collection(FormApiConstants.userResponses);

  /// Method Name: [getUserResponses]
  ///
  /// Purpose: the person's "User Responses" index.
  ///
  /// Parameters:
  /// - [email]: the person.
  ///
  /// Returns: the index, or null when there is none; throws on a read error.
  Future<UserResponsesModel?> getUserResponses(String email) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _index.doc(email).get();
    final Map<String, dynamic>? data = doc.data();
    if (!doc.exists || data == null) return null;
    return UserResponsesModel.fromMap(data);
  }

  /// Method Name: [getFormResponse]
  ///
  /// Purpose: one person's response document.
  ///
  /// Parameters:
  /// - [formId]: the form.
  /// - [email]: the person.
  ///
  /// Returns: the response, or null when there is none; throws on a read
  /// error.
  Future<ResponseModel?> getFormResponse({
    required String formId,
    required String email,
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _db
        .collection(
          getBaseUrl(
            '${FormApiConstants.formResponses}/$formId/${FormApiConstants.responses}',
          ),
        )
        .doc(email)
        .get();
    final Map<String, dynamic>? data = doc.data();
    if (!doc.exists || data == null) return null;
    return ResponseModel.fromMap(data, email);
  }

  /// Method Name: [getFormNumberOfUsage]
  ///
  /// Purpose: how many indexes contain the form (people who submitted it).
  ///
  /// Parameters:
  /// - [formId]: the form.
  ///
  /// Returns: the count; throws on a read error.
  Future<int> getFormNumberOfUsage(String formId) async {
    final AggregateQuerySnapshot result = await _index
        .where(UserResponsesModel.formIdsField, arrayContains: formId)
        .count()
        .get();
    return result.count ?? 0;
  }
}
