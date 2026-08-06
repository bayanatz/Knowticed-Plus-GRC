// PORTED into services_app under features/settings.
// Source: services_app features/employees/data/data_source/remote_data_source/emergency_contact_remote_data_source.dart
// Imports rewired to the equivalents that already exist in services_app.

import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/core/services/firebase/repository/firebase_repository.dart';

class EmergencyContactRemoteDataSource {
  getEmergencyContactData({required String employeeId}) async {
    return await FirebaseRepository.getDocumentWithId(
        collection: ApiConstants.emergencyContacts, documentId: employeeId);
  }

  addEmergencyContactData(
      {required Map<String, dynamic> data, required String documentId}) async {
    return await FirebaseRepository.setDocumentWithId(
        collection: ApiConstants.emergencyContacts,
        data: data,
        documentId: documentId);
  }
}
