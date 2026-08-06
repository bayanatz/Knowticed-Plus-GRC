// PORTED into services_app under features/settings.
// Source: services_app features/employees/presentation/controller/emergency_contact_controller.dart
// Imports rewired to the equivalents that already exist in services_app.

import 'package:dartz/dartz.dart';

import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/features/settings/se5_emergency_contact/data/repository/emergency_contact_repository.dart';
import 'package:grc_module/features/settings/se5_emergency_contact/domain/entities/emergency_contact_entity.dart';

class EmergencyContactController {
  final EmergencyContactRepository _emergencyContactRepository =
      EmergencyContactRepository();

  void addEmployeesEmergencyContactData({required List<List> csvData}) {
    List<EmergencyContactEntity> emergencyContactData =
        _getEmergencyContactData(csvData: csvData);
    for (var emergencyContact in emergencyContactData) {
      _emergencyContactRepository.addEmployeeInsuranceData(
          emergencyContactData: emergencyContact);
    }
  }

  List<EmergencyContactEntity> _getEmergencyContactData(
      {required List<List> csvData}) {
    List<EmergencyContactEntity> emergencyContactData = [];
    for (int i = 1; i < csvData.length; i++) {
      emergencyContactData.add(EmergencyContactEntity(
        employeeId: csvData[i][0],
        firstContactFirstName: csvData[i][1],
        firstContactMiddleName: csvData[i][2],
        firstContactLastName: csvData[i][3],
        firstContactCountryCode: csvData[i][4].toString(),
        firstContactCountryApp: csvData[i][5].toString(),
        firstContactPhone: csvData[i][6].toString(),
        firstContactEmail: csvData[i][7],
        firstContactRelationShip: csvData[i][8],
        firstContactCountry: csvData[i][9],
        firstContactCity: csvData[i][10],
        firstContactProvionce: csvData[i][11],
        secondContactFirstName: csvData[i][12],
        secondContactMiddleName: csvData[i][13],
        secondContactLastName: csvData[i][14],
        secondContactCountryCode: csvData[i][15].toString(),
        secondContactCountryApp: csvData[i][16].toString(),
        secondContactPhone: csvData[i][17].toString(),
        secondContactEmail: csvData[i][18],
        secondContactRelationShip: csvData[i][19],
        secondContactCountry: csvData[i][20],
        secondContactCity: csvData[i][21],
        secondContactProvionce: csvData[i][22],

      ));
    }
    return emergencyContactData;
  }

  getEmployeeData({required String employeeId}) async {
    Either<Failure, EmergencyContactEntity> employeeEmergencyContactData =
     await   _emergencyContactRepository.getEmployeeEmergencyContactData(
            employeeId: employeeId);
    return employeeEmergencyContactData.fold((l) => null, (r) => r);
  }
}
