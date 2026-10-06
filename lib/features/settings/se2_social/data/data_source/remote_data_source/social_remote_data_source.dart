/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: social_remote_data_source.dart
/// Purpose: The one Firestore write behind the social settings page.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE2-N01 / N06. This call previously sat in
/// `SocialController` — a presentation-layer class — and resolved its
/// collection with `getBaseUrl('Employees_Info')`, a literal that also appears
/// (correctly, as a constant) in `EmployeeCollectionPaths.main`. Reusing that
/// constant is the §15 fix; both resolve to `Demo/{companyId}/Employees_Info`.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:grc_module/features/settings/main_controller/data/utils/employee_collection_paths.dart';

class SocialRemoteDataSource {
  SocialRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Function Name: [updateSocialFields]
  ///
  /// Purpose: Apply the changed fields to the employee's profile document.
  ///
  /// Uses `update`, not `set(merge: true)`: the document is expected to exist,
  /// and a missing one should surface as an error rather than silently create a
  /// half-populated employee record.
  Future<void> updateSocialFields({
    required String employeeId,
    required Map<String, dynamic> fields,
  }) {
    return _firestore
        .collection(EmployeeCollectionPaths.main)
        .doc(employeeId)
        .update(fields);
  }
}
