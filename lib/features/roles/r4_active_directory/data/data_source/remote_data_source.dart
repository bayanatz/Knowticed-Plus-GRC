import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/core/network/get_base_url.dart';

import '../../../../../core/services/firebase/repository/firebase_repository.dart';

class DepartmentRemoteDataSource {
  getDepartments() async {
    return await FirebaseRepository.getCollection(
        collectionPath: getBaseUrl(ApiConstants.departmentDocumentKey));
  }
}
class MainCoreEmployeeRemoteDataSource {
  getAllEmployees() async {
    return await FirebaseRepository.getCollection(
        collectionPath: getBaseUrl(ApiConstants.employeesInfo));
  }
}