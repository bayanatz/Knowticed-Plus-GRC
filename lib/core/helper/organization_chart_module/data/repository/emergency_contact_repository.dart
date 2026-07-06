import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/core/helper/messaging/core/generic_models/single_value_tracking_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/emergency_contacts_model/emergency_contacts_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/domain/entities/emergency_contact_entity.dart';

import 'package:demo_app/core/helper/organization_chart_module/data/data_source/remote_data_source/emergency_contact_remote_data_source.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/mobile_phone_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/repository/employees_repository.dart';

/// **************************** FILE INFO **************************** ///
/// Purpose: Repository to handle Emergency contact data operations
/// Author: Mohamed Elrashidy
/// created At: 21/11/2024

class EmergencyContactRepository {
  final EmergencyContactRemoteDataSource _remoteDataSource =
  EmergencyContactRemoteDataSource();

  Future<Either<Failure, dynamic>> addEmployeeInsuranceData({
    required EmergencyContactEntity emergencyContactData,
  }) async {
    final result = await _checkIfEmployeeExist(
        employeeId: emergencyContactData.employeeId);
    if (result.isLeft()) return result;
    return await _addEmployeeEmergencyContactData(
        emergencyContactData: emergencyContactData);
  }

  // Todo: refactor this method
  _checkIfEmployeeExist({required String employeeId}) async {
    Either<Failure, dynamic> isEmployeeExist =
    await EmployeesRepository().isEmployeeExist(employeeId: employeeId);
    if (isEmployeeExist.isLeft()) return isEmployeeExist;
    if (isEmployeeExist.getOrElse(() => false) == false) {
      return Left(FirebaseFailure('Employee not found'));
    }
    return isEmployeeExist = Right(true);
  }

  _addEmployeeEmergencyContactData(
      {required EmergencyContactEntity emergencyContactData}) async {
    Either<Failure, dynamic> result = await _getEmployeeEmergencyContactModel(
        employeeId: emergencyContactData.employeeId);
    if (result.isLeft()) return result;
    EmergencyContactsModel emergencyContactModel = result.getOrElse(() => null);
    _updateEmergencyContactModel(
        originalEmergencyContactModel: emergencyContactModel,
        newEmergencyContactData: emergencyContactData);
    return await _remoteDataSource.addEmergencyContactData(
        data: emergencyContactModel.toMap(),
        documentId: emergencyContactModel.employeeId);
  }

  _getEmployeeEmergencyContactModel({required String employeeId}) async {
    Either<Failure, dynamic> result =
    await _remoteDataSource.getEmergencyContactData(employeeId: employeeId);
    if (result.isLeft()) return result;
    Map<String, dynamic>? insuranceData = result.getOrElse(() => null);
    if (insuranceData == null) {
      return result = Right(_createTempInsuranceModel(employeeId: employeeId));
    }
    return result = Right(EmergencyContactsModel.fromMap(insuranceData));
  }

  void _updateEmergencyContactModel(
      {required EmergencyContactsModel originalEmergencyContactModel,
        required EmergencyContactEntity newEmergencyContactData}) {
    // First Emergency Contact
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.firstEmergencyContact!.firstName,
        itemValue: newEmergencyContactData.firstContactFirstName);
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.firstEmergencyContact!.middleName,
        itemValue: newEmergencyContactData.firstContactMiddleName);
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.firstEmergencyContact!.lastName,
        itemValue: newEmergencyContactData.firstContactLastName);
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.firstEmergencyContact!.relationShip,
        itemValue: newEmergencyContactData.firstContactRelationShip);
    _handleSingleValueItem(
        itemModel: originalEmergencyContactModel.firstEmergencyContact!.email,
        itemValue: newEmergencyContactData.firstContactEmail);
    _handleSingleValueItem(
        itemModel: originalEmergencyContactModel.firstEmergencyContact!.country,
        itemValue: newEmergencyContactData.firstContactCountry);
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.firstEmergencyContact!.provionce,
        itemValue: newEmergencyContactData.firstContactProvionce);
    _handleSingleValueItem(
        itemModel: originalEmergencyContactModel.firstEmergencyContact!.city,
        itemValue: newEmergencyContactData.firstContactCity);
    _handleSingleValueItem(
        itemModel: originalEmergencyContactModel.firstEmergencyContact!.street,
        itemValue: newEmergencyContactData.firstContactStreet); // NEW: Added street handling

    // Second Emergency Contact
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.secondEmergencyContact!.firstName,
        itemValue: newEmergencyContactData.secondContactFirstName);
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.secondEmergencyContact!.middleName,
        itemValue: newEmergencyContactData.secondContactMiddleName);
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.secondEmergencyContact!.lastName,
        itemValue: newEmergencyContactData.secondContactLastName);
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.secondEmergencyContact!.relationShip,
        itemValue: newEmergencyContactData.secondContactRelationShip);
    _handleSingleValueItem(
        itemModel: originalEmergencyContactModel.secondEmergencyContact!.email,
        itemValue: newEmergencyContactData.secondContactEmail);
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.secondEmergencyContact!.country,
        itemValue: newEmergencyContactData.secondContactCountry);
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.secondEmergencyContact!.provionce,
        itemValue: newEmergencyContactData.secondContactProvionce);
    _handleSingleValueItem(
        itemModel: originalEmergencyContactModel.secondEmergencyContact!.city,
        itemValue: newEmergencyContactData.secondContactCity);
    _handleSingleValueItem(
        itemModel: originalEmergencyContactModel.secondEmergencyContact!.street,
        itemValue: newEmergencyContactData.secondContactStreet); // NEW: Added street handling

    // Phone handling
    _handlePhoneItem(
        itemModel: originalEmergencyContactModel.firstEmergencyContact!.phone,
        phoneNumber: newEmergencyContactData.firstContactPhone,
        countryApp: newEmergencyContactData.firstContactCountryApp,
        countryCode: newEmergencyContactData.firstContactCountryCode);
    _handlePhoneItem(
        itemModel: originalEmergencyContactModel.secondEmergencyContact!.phone,
        phoneNumber: newEmergencyContactData.secondContactPhone,
        countryApp: newEmergencyContactData.secondContactCountryApp,
        countryCode: newEmergencyContactData.secondContactCountryCode);
  }

  _createTempInsuranceModel({required String employeeId}) {
    return EmergencyContactsModel(
      employeeId: employeeId,
      firstEmergencyContact: _getEmptyEmergencyContactModel(),
      secondEmergencyContact: _getEmptyEmergencyContactModel(),
    );
  }

  EmergencyContactModel _getEmptyEmergencyContactModel() {
    return EmergencyContactModel(
      firstName: SingleValueTrackingModel<String>(
        values: [],
        timestamps: [],
      ),
      middleName: SingleValueTrackingModel<String>(
        values: [],
        timestamps: [],
      ),
      lastName: SingleValueTrackingModel<String>(
        values: [],
        timestamps: [],
      ),
      relationShip: SingleValueTrackingModel<String>(
        values: [],
        timestamps: [],
      ),
      phone: MobilePhone(
        phones: [],
        countryCode: [],
        countryApp: [],
        timestamps: [],
      ),
      email: SingleValueTrackingModel<String>(
        values: [],
        timestamps: [],
      ),
      country: SingleValueTrackingModel<String>(
        values: [],
        timestamps: [],
      ),
      provionce: SingleValueTrackingModel<String>(
        values: [],
        timestamps: [],
      ),
      city: SingleValueTrackingModel<String>(
        values: [],
        timestamps: [],
      ),
      street: SingleValueTrackingModel<String>(
        values: [],
        timestamps: [],
      ),
      language: SingleValueTrackingModel<String>( // ADD THIS
        values: [],
        timestamps: [],
      ),
    );
  }

  void _handleSingleValueItem(
      {required SingleValueTrackingModel<String> itemModel,
        required String? itemValue}) {
    if (itemValue != null && itemValue != itemModel.values.lastOrNull) {
      itemModel.values.add(itemValue);
      itemModel.timestamps.add(Timestamp.now());
    }
  }

  _handlePhoneItem(
      {required MobilePhone itemModel,
        required String? countryApp,
        required String? phoneNumber,
        required String? countryCode}) {
    if ((phoneNumber != null && phoneNumber != itemModel.phones!.lastOrNull) ||
        (countryCode != null &&
            countryCode != itemModel.countryCode!.lastOrNull)||
        (countryApp != null && countryApp != itemModel.countryApp!.lastOrNull)) {
      itemModel.phones!.add(phoneNumber);
      itemModel.countryCode!.add(countryCode);
      itemModel.countryApp!.add(countryApp);
      itemModel.timestamps!.add(Timestamp.now());
    }
  }

  Future<Either<Failure, EmergencyContactEntity>>
  getEmployeeEmergencyContactData({required String employeeId}) async {
    Either<Failure, dynamic> data =
    await _getEmployeeEmergencyContactModel(employeeId: employeeId);
    Either<Failure, EmergencyContactEntity> result;
    if (data.isLeft()) {
      Failure? failure = data.fold((l) => l, (r) => null);
      return Left(failure!);
    }
    EmergencyContactsModel emergencyContactModel = data.getOrElse(() => null);
    return result =
        Right(EmergencyContactEntity.fromModel(emergencyContactModel));
  }
}