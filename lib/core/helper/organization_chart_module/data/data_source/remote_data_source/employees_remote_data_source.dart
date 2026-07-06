import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/api_constants.dart';
import 'package:demo_app/features/onboarding/authentication/data/models/demo_user_account_overview.dart';

import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/core/services/firebase/repository/firebase_repository.dart';

///********************** FILE INFO ********************///
/// Class Name: EmployeesRemoteDataSource
/// Purpose: A class to handle database for employees
/// Author: Mohamed Elrashidy
/// created At: 5/11/2024
class EmployeesRemoteDataSource {
  Future<Either<FirebaseFailure, dynamic>> getAllEmployees() async {
    return await FirebaseRepository.getCollection(
        collectionPath: ApiConstants.employeesProfile);
  }

  Future<Either<FirebaseFailure, dynamic>> getAllEmployeesDirectory() async {
    return await FirebaseRepository.getCollection(
        collectionPath: ApiConstants.employeesDirectory);
  }

  getEmployee({required String employeeId}) async {
    return await FirebaseRepository.getDocumentWithId(
        collection: ApiConstants.employeesProfile, documentId: employeeId);
  }

  activateAccountOverview(String email, bool isDemoActivation) {
    Map<String, dynamic> data = {
      DemoUserAccountOverview.isActivatedField: true
    };
    if (isDemoActivation) {
      data[DemoUserAccountOverview.demoActivatedField] = Timestamp.now();
    }
    return FirebaseRepository.setDocumentWithId(
        collection: ApiConstants.demoUsersAccounts,
        documentId: email,
        data: data);
  }
}
