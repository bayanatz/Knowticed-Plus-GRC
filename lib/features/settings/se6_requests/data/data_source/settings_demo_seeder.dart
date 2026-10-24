/// Module: settings / se6_requests / data / data_source
///
///*************************** FILE INFO ****************************///
/// File Name: settings_demo_seeder.dart
/// Purpose: Declares `SettingsDemoSeeder` — the debug-only "Load / Remove
///          demo data" behind the Settings › Requests page: a few realistic
///          change requests in EVERY status (approved, pending, rejected,
///          cancelled) and a few Comments And Feedbacks submissions for the
///          signed-in employee, so no list on the Settings pages is empty
///          (Moataz, 21/10/2026: "all statuses should have 1, 2 or 3 cards").
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// CREATE-ONLY towards real data: every document it writes carries
/// `demo: true`, and [remove] deletes ONLY those. Nothing else is touched.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/settings/se6_requests/data/models/change_request_mapper.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/utils/request_collection_paths.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/data/utils/feedback_collection_paths.dart';

abstract final class SettingsDemoSeeder {
  static const String demoFlag = 'demo';

  static CollectionReference<Map<String, dynamic>> _requests(
          FirebaseFirestore db) =>
      db
          .doc(RequestCollectionPaths.rolesDoc)
          .collection(RequestCollectionPaths.requestsCollection);

  static CollectionReference<Map<String, dynamic>> _feedback(
          FirebaseFirestore db) =>
      db
          .doc(FeedbackCollectionPaths.settingsDoc)
          .collection(FeedbackCollectionPaths.feedbackCollection);

  /// Writes the demo requests and feedback for [employeeId]. Returns how
  /// many documents were written.
  static Future<int> load({
    required String employeeId,
    required String employeeEmail,
    required String employeeName,
    FirebaseFirestore? firestore,
  }) async {
    final FirebaseFirestore db = firestore ?? FirebaseFirestore.instance;
    final WriteBatch batch = db.batch();
    final DateTime now = DateTime.now();
    int count = 0;

    Map<String, dynamic> request({
      required String section,
      required String status,
      required int daysAgo,
      required String note,
      required List<FieldChange> changes,
      String decisionReason = '',
    }) {
      final DateTime at = now.subtract(Duration(days: daysAgo, hours: 3));
      return <String, dynamic>{
        ChangeRequestMapper.keyChanges:
            changes.map((FieldChange c) => c.toMap()).toList(),
        ChangeRequestMapper.keySection: section,
        ChangeRequestMapper.keyRequestDate: Timestamp.fromDate(at),
        ChangeRequestMapper.keyRequestDateFormatted:
            '${at.year}-${at.month.toString().padLeft(2, '0')}-${at.day.toString().padLeft(2, '0')} '
                '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}:00',
        ChangeRequestMapper.keyRequestNote: note,
        ChangeRequestMapper.keyStatus: status,
        ChangeRequestMapper.keyDecisionReason: decisionReason,
        ChangeRequestMapper.keyEmployeeId: employeeId,
        ChangeRequestMapper.keyEmployeeEmail: employeeEmail,
        ChangeRequestMapper.keyEmployeeName: employeeName,
        ChangeRequestMapper.keyCreatedAt: Timestamp.fromDate(at),
        ChangeRequestMapper.keyUpdatedAt: Timestamp.fromDate(at),
        ChangeRequestMapper.keyNumberOfChanges: changes.length,
        demoFlag: true,
      };
    }

    final List<Map<String, dynamic>> requests = <Map<String, dynamic>>[
      request(
        section: 'Personal Information',
        status: 'approved',
        daysAgo: 21,
        note: 'My work mobile number changed after the department move.',
        changes: const <FieldChange>[
          FieldChange(
              fieldName: 'phone',
              oldValue: '1001234567',
              newValue: '1501503767'),
        ],
      ),
      request(
        section: 'Personal Information',
        status: 'approved',
        daysAgo: 14,
        note: 'I relocated to the New Administrative Capital in September.',
        changes: const <FieldChange>[
          FieldChange(
              fieldName: 'city',
              oldValue: 'Cairo',
              newValue: 'New Administrative Capital'),
          FieldChange(
              fieldName: 'street',
              oldValue: 'Makram Ebeid St. 41',
              newValue: 'Madinaty, B12'),
        ],
      ),
      request(
        section: 'Health Insurance',
        status: 'pending',
        daysAgo: 3,
        note: 'Please update the policy number after the annual renewal.',
        changes: const <FieldChange>[
          FieldChange(
              fieldName: 'insurancePolicyNumber',
              oldValue: 'HP-2026-1001',
              newValue: 'HP-2027-1001'),
        ],
      ),
      request(
        section: 'Company Information',
        status: 'rejected',
        daysAgo: 9,
        note: 'The tax number on file has a typo in the last digit.',
        decisionReason:
            'The tax number matches the registration certificate. Please attach the updated certificate if it changed.',
        changes: const <FieldChange>[
          FieldChange(
              fieldName: 'taxNumber',
              oldValue: '12365488925',
              newValue: '12365488926'),
        ],
      ),
      request(
        section: 'Personal Information',
        status: 'cancelled',
        daysAgo: 6,
        note: 'Marital status update.',
        decisionReason: 'Submitted by mistake; the status has not changed.',
        changes: const <FieldChange>[
          FieldChange(
              fieldName: 'marital_status',
              oldValue: 'Married',
              newValue: 'Single'),
        ],
      ),
    ];
    for (final Map<String, dynamic> data in requests) {
      batch.set(_requests(db).doc(), data);
      count++;
    }

    Map<String, dynamic> feedback({
      required String type,
      required String body,
      required String status,
      required String priority,
      required int daysAgo,
    }) {
      final DateTime at = now.subtract(Duration(days: daysAgo, hours: 5));
      return <String, dynamic>{
        'type': type,
        'body': body,
        'employeeId': employeeId,
        'employeeName': employeeName,
        'employeeEmail': employeeEmail,
        'status': status,
        'priority': priority,
        'createdAt': Timestamp.fromDate(at),
        'attachments': const <Map<String, dynamic>>[],
        'attachment': null,
        'details': null,
        demoFlag: true,
      };
    }

    final List<Map<String, dynamic>> feedbacks = <Map<String, dynamic>>[
      feedback(
        type: 'bug',
        body:
            'On the iPad in portrait, the Requests list cards overflow on the right and the date is cut.',
        status: 'fixed',
        priority: 'high',
        daysAgo: 12,
      ),
      feedback(
        type: 'comment',
        body:
            'The Request Details page would be easier to read if the requested date sat inside the section.',
        status: 'open',
        priority: 'medium',
        daysAgo: 5,
      ),
      feedback(
        type: 'feature_request',
        body:
            'Add a reminder button on pending requests so the reviewer is notified again after a week.',
        status: 'closed',
        priority: 'low',
        daysAgo: 30,
      ),
    ];
    for (final Map<String, dynamic> data in feedbacks) {
      batch.set(_feedback(db).doc(), data);
      count++;
    }

    await batch.commit();
    return count;
  }

  /// Deletes ONLY the documents [load] wrote (`demo: true`) for [employeeId].
  static Future<int> remove({
    required String employeeId,
    FirebaseFirestore? firestore,
  }) async {
    final FirebaseFirestore db = firestore ?? FirebaseFirestore.instance;
    int count = 0;
    for (final CollectionReference<Map<String, dynamic>> col
        in <CollectionReference<Map<String, dynamic>>>[
      _requests(db),
      _feedback(db),
    ]) {
      final QuerySnapshot<Map<String, dynamic>> snap = await col
          .where(demoFlag, isEqualTo: true)
          .where('employeeId', isEqualTo: employeeId)
          .get();
      final WriteBatch batch = db.batch();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snap.docs) {
        batch.delete(doc.reference);
        count++;
      }
      await batch.commit();
    }
    return count;
  }
}
