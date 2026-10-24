/// Module: form_builder_module/f5_submissions
///
///*************************** FILE INFO ****************************///
/// File Name: response_data_source.dart
/// Description: `ResponseDataSource`, Firestore access for form responses
///              and the "User Responses" index. Methods throw on failure;
///              the repository turns errors into failures.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/form_builder/helpers/constants/fb_api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/data/models/response_model.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/data/models/user_responses_model.dart';

/// Firestore access for form responses.
class ResponseDataSource {
  ResponseDataSource({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _responses(
    String formId,
  ) => _db.collection(
    getBaseUrl(
      '${FormApiConstants.formResponses}/$formId/${FormApiConstants.responses}',
    ),
  );

  CollectionReference<Map<String, dynamic>> get _index =>
      _db.collection(FormApiConstants.userResponses);

  /// Method Name: [saveResponseWithIndex]
  ///
  /// Purpose: saves the response and adds the form to the filler's
  /// "User Responses" index in ONE transaction (FB-FILL-02). Either both
  /// writes land or neither does, and concurrent submissions no longer
  /// overwrite each other's index entries. The form id is kept once in the
  /// index (old duplicate entries are removed) and its timestamp is kept at
  /// the same position, so `Form_Ids` and `Submission_Timestamp` stay aligned.
  ///
  /// Parameters:
  /// - [responseModel]: the response to save.
  /// - [formId]: the form being answered.
  ///
  /// Returns: [Future<void>]; throws when the transaction fails.
  Future<void> saveResponseWithIndex(
    ResponseModel responseModel,
    String formId,
  ) async {
    final DocumentReference<Map<String, dynamic>> responseRef = _responses(
      formId,
    ).doc(responseModel.submittedBy);
    final DocumentReference<Map<String, dynamic>> indexRef = _index.doc(
      responseModel.submittedBy,
    );
    final Timestamp submittedAt = responseModel.timestamps.last;

    await _db.runTransaction((transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> indexSnap = await transaction
          .get(indexRef);
      final Map<String, dynamic>? data = indexSnap.data();
      final List<String> formIds = List<String>.from(
        data?[UserResponsesModel.formIdsField] ?? const <String>[],
      );
      final List<Timestamp> timestamps = List<Timestamp>.from(
        data?[UserResponsesModel.submissionTimestampField] ??
            const <Timestamp>[],
      );
      // Keep both lists the same length, then drop old entries for this form.
      final int length = formIds.length < timestamps.length
          ? formIds.length
          : timestamps.length;
      final List<String> keptIds = [];
      final List<Timestamp> keptTimes = [];
      for (int i = 0; i < length; i++) {
        if (formIds[i] == formId) continue;
        keptIds.add(formIds[i]);
        keptTimes.add(timestamps[i]);
      }
      keptIds.add(formId);
      keptTimes.add(submittedAt);

      transaction.set(
        responseRef,
        responseModel.toMap(),
        SetOptions(merge: true),
      );
      transaction.set(
        indexRef,
        UserResponsesModel(
          email: responseModel.submittedBy,
          formIds: keptIds,
          submissionTimestamp: keptTimes,
        ).toMap(),
        SetOptions(merge: true),
      );
    });
  }

  /// Method Name: [getFormResponses]
  ///
  /// Purpose: every response document of a form.
  ///
  /// Parameters:
  /// - [formId]: the form.
  ///
  /// Returns: the responses; throws on a read error.
  Future<List<ResponseModel>> getFormResponses(String formId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _responses(
      formId,
    ).get();
    return snapshot.docs
        .map((doc) => ResponseModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Method Name: [getUserResponse]
  ///
  /// Purpose: one person's response document.
  ///
  /// Parameters:
  /// - [formId]: the form.
  /// - [email]: the person.
  ///
  /// Returns: the response, or null when there is none; throws on a read
  /// error.
  Future<ResponseModel?> getUserResponse({
    required String formId,
    required String email,
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _responses(formId)
        .doc(email)
        .get();
    final Map<String, dynamic>? data = doc.data();
    if (!doc.exists || data == null) return null;
    return ResponseModel.fromMap(data, doc.id);
  }

  /// Method Name: [setResponse]
  ///
  /// Purpose: writes one response document (used to record reminders).
  ///
  /// Parameters:
  /// - [responseModel]: the response; its [ResponseModel.id] is the email.
  /// - [formId]: the form.
  ///
  /// Returns: [Future<void>]; throws on a write error.
  Future<void> setResponse(ResponseModel responseModel, String formId) async {
    await _responses(formId)
        .doc(responseModel.id ?? responseModel.submittedBy)
        .set(responseModel.toMap());
  }

  /// Method Name: [getUserSubmissions]
  ///
  /// Purpose: the person's "User Responses" index.
  ///
  /// Parameters:
  /// - [email]: the person.
  ///
  /// Returns: the index, or null when there is none; throws on a read error.
  Future<UserResponsesModel?> getUserSubmissions(String email) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _index
        .doc(email)
        .get();
    final Map<String, dynamic>? data = doc.data();
    if (!doc.exists || data == null) return null;
    return UserResponsesModel.fromMap(data);
  }
}
