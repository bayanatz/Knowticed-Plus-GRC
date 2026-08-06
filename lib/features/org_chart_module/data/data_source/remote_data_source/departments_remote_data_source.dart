import 'package:dartz/dartz.dart';
import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/core/services/firebase/repository/firebase_repository.dart';
///********************** FILE INFO ********************///
/// Class Name: DepartmentsRemoteDataSource
/// Purpose: A class to handle database for departments
/// Author: Mohamed Elrashidy
/// created At: 5/11/2024
class DepartmentsRemoteDataSource {
  Future<Either<FirebaseFailure, dynamic>> getDepartments() async {
    return await FirebaseRepository.getDocumentWithId(
        collection: ApiConstants.departments,
        documentId: ApiConstants.departmentDocumentKey);
  }
}
