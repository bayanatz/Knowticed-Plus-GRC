import 'package:demo_app/core/network/api_constants.dart';
import 'package:demo_app/core/services/firebase/repository/firebase_repository.dart';

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
