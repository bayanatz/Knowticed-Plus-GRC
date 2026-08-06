import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/core/services/firebase/repository/firebase_repository.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';
class SettingsRemoteDataSource{
  updateEmployeeModel({required employeeId,required NewEmployeeModelHistory employee})
  async {
    return await FirebaseRepository.setDocumentWithId(
        collection: ApiConstants.employeesProfile,
        data: employee.toMap(),
        documentId: employeeId);
  }
}
