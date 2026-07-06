import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/repository/health_insurance_repository.dart';
import 'package:demo_app/core/helper/organization_chart_module/domain/entities/request_health_insurance_entity.dart';

class HealthInsuranceController extends GetxController {
  final HealthInsuranceRepository _healthInsuranceRepository =
      HealthInsuranceRepository();

  addEmployeesInsuranceFromCsvData(
      {required List<List<dynamic>> csvData}) async {
    List<HealthInsuranceEntity> insuranceData =
        _getEmployeesHealthInsuranceData(csvData: csvData);
    for (int i = 0; i < insuranceData.length; i++) {
      _healthInsuranceRepository.addEmployeeInsuranceData(
          insuranceData: insuranceData[i]);
    }
  }

  List<HealthInsuranceEntity> _getEmployeesHealthInsuranceData(
      {required List<List<dynamic>> csvData}) {
    List<HealthInsuranceEntity> insuranceData = [];
    for (int i = 1; i < csvData.length; i++) {
      insuranceData.add(HealthInsuranceEntity(
        employeeId: csvData[i][0].toString(),
        providerCountryCode: csvData[i][1].toString(),
        providerCountryApp: csvData[i][2].toString(),
        providerNumber: csvData[i][3].toString(),
        policyNumber: csvData[i][4].toString(),
        providerName: csvData[i][5].toString(),
        postalCode: csvData[i][6].toString(),
      ));
    }
    return insuranceData;
  }

  Future<HealthInsuranceEntity?> getEmployeeData(
      {required String employeeId}) async {
    Either<Failure, HealthInsuranceEntity> employeeInsuranceData =
        await _healthInsuranceRepository.getEmployeeInsuranceData(
            employeeId: employeeId);

    return employeeInsuranceData.fold((l) => null, (r) => r);
  }
}
