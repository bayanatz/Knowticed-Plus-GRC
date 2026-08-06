///*********************** FILE INFO ********************///
/// Purpose: Controller for settings health insurance.
/// Attributes:
///            settingsController
/// Author: Amr Mesbah
/// Created At: 12/11/2024

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/helper/main_helper/phone_number.dart';
import 'package:grc_module/core/custom/loading.dart';
import 'package:grc_module/features/settings/se5_emergency_contact/domain/entities/emergency_contact_entity.dart';
import 'package:grc_module/features/settings/se4_health_insurance/domain/entities/request_health_insurance_entity.dart';
import 'package:grc_module/features/settings/se5_emergency_contact/presentation/controller/emergency_contact_controller.dart';
import 'package:grc_module/features/settings/se4_health_insurance/presentation/controller/employees_health_insurance_cubit.dart';
import 'package:grc_module/core/network/get_base_url.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/settings_controller.dart';

class SettingsHealthInsuranceController {
  SettingsController settingsController;

  EmergencyContactEntity? emergencyContactEntity;
  HealthInsuranceEntity? healthInsuranceEntity;

  // Text Controllers for Health Insurance
  TextEditingController insuranceName = TextEditingController();
  TextEditingController insurancePolice = TextEditingController();
  TextEditingController insurancePhone = TextEditingController();

  // Text Controllers for Emergency Contact
  TextEditingController connectionName = TextEditingController();
  TextEditingController connecntionContactRelation = TextEditingController();
  TextEditingController connecntionPhone = TextEditingController();

  // Phone Numbers
  PhoneNumber? insurancePhone2;
  PhoneNumber? connecntionPhone2;

  // Additional Fields
  String? insuranceName2;
  String? insurancePolice2;
  String? connectionName2;
  String? connectionMiddleName2;
  String? connectionLastName2;
  String? connecntionRelation2;
  String? connecntionEmail2;
  String? connecntionCountry2;
  String? connecntionProvince2;
  String? connecntionCity2;
  String? connecntionAddress2;
  String? connecntionPostalCode2;

  // Change flags
  bool changeInsuranceName = false;
  bool changeInsurancePolicy = false;
  bool changeFirstContactFirstName = false;
  bool changeFirstContactLastName = false;
  bool changeFirstContactRelationship = false;
  bool changeFirstContactEmail = false;
  bool changeFirstContactPhone = false;
  bool changeFirstContactLanguage = false;
  bool changeFirstContactCountry = false;
  bool changeFirstContactProvince = false;
  bool changeFirstContactCity = false;
  bool changeFirstContactStreet = false;

  SettingsHealthInsuranceController(this.settingsController) {
    _addListeners();
  }

  /// Add listeners to text controllers
  void _addListeners() {
    insuranceName.addListener(() => changeInsuranceName = true);
    insurancePolice.addListener(() => changeInsurancePolicy = true);
    connectionName.addListener(() => changeFirstContactFirstName = true);
    connecntionContactRelation.addListener(() => changeFirstContactRelationship = true);
    connecntionPhone.addListener(() => changeFirstContactPhone = true);
  }

  /// Get all data from employee model
  getData() {
    // print('🏥 Loading Health Insurance & Emergency Contact data...');

    if (settingsController.employee == null) {
      // print('⚠️ No employee data available');
      return;
    }

    _loadHealthInsuranceFromEmployee();
    _loadEmergencyContactFromEmployee();
    _getHealthInsuranceData();
    _getEmergencyContactData();
  }

  /// Load health insurance data from employee model
  void _loadHealthInsuranceFromEmployee() {
    if (settingsController.employee == null) return;

    // Load Insurance Name
    if (settingsController.employee!.insuranceName.isNotEmpty) {
      insuranceName.text = settingsController.employee!.insuranceName.last;
      insuranceName2 = insuranceName.text;
      // print('   Insurance Name: ${insuranceName.text}');
    }

    // Load Insurance Policy Number
    if (settingsController.employee!.insurancePolicyNumber.isNotEmpty) {
      insurancePolice.text = settingsController.employee!.insurancePolicyNumber.last;
      insurancePolice2 = insurancePolice.text;
      // print('   Policy Number: ${insurancePolice.text}');
    }

    // Reset change flags
    changeInsuranceName = false;
    changeInsurancePolicy = false;
  }

  /// Load emergency contact data from employee model
  void _loadEmergencyContactFromEmployee() {
    if (settingsController.employee == null) return;

    // Load First Contact First Name
    if (settingsController.employee!.firstContactFirstName.isNotEmpty) {
      connectionName.text = settingsController.employee!.firstContactFirstName.last;
      connectionName2 = connectionName.text;
      // print('   Contact First Name: ${connectionName.text}');
    }

    // Load First Contact Last Name
    if (settingsController.employee!.firstContactLastName.isNotEmpty) {
      connectionLastName2 = settingsController.employee!.firstContactLastName.last;
      // print('   Contact Last Name: $connectionLastName2');
    }

    // Load First Contact Relationship
    if (settingsController.employee!.firstContactRelationship.isNotEmpty) {
      connecntionContactRelation.text = settingsController.employee!.firstContactRelationship.last;
      connecntionRelation2 = connecntionContactRelation.text;
      // print('   Contact Relationship: ${connecntionContactRelation.text}');
    }

    // Load First Contact Email
    if (settingsController.employee!.firstContactEmail.isNotEmpty) {
      connecntionEmail2 = settingsController.employee!.firstContactEmail.last;
      // print('   Contact Email: $connecntionEmail2');
    }

    // Load First Contact Phone
    if (settingsController.employee!.firstContactPhone.isNotEmpty) {
      connecntionPhone.text = settingsController.employee!.firstContactPhone.last;
      // print('   Contact Phone: ${connecntionPhone.text}');
    }

    // Load First Contact Country
    if (settingsController.employee!.firstContactCountry.isNotEmpty) {
      connecntionCountry2 = settingsController.employee!.firstContactCountry.last;
      // print('   Contact Country: $connecntionCountry2');
    }

    // Load First Contact Province
    if (settingsController.employee!.firstContactProvince.isNotEmpty) {
      connecntionProvince2 = settingsController.employee!.firstContactProvince.last;
      // print('   Contact Province: $connecntionProvince2');
    }

    // Load First Contact City
    if (settingsController.employee!.firstContactCity.isNotEmpty) {
      connecntionCity2 = settingsController.employee!.firstContactCity.last;
      // print('   Contact City: $connecntionCity2');
    }

    // Load First Contact Street
    if (settingsController.employee!.firstContactStreet.isNotEmpty) {
      connecntionAddress2 = settingsController.employee!.firstContactStreet.last;
      // print('   Contact Address: $connecntionAddress2');
    }

    // Reset change flags
    changeFirstContactFirstName = false;
    changeFirstContactLastName = false;
    changeFirstContactRelationship = false;
    changeFirstContactEmail = false;
    changeFirstContactPhone = false;
    changeFirstContactCountry = false;
    changeFirstContactProvince = false;
    changeFirstContactCity = false;
    changeFirstContactStreet = false;
  }

  /// Get health insurance data from entity (legacy support)
  _getHealthInsuranceData() async {
    try {
      healthInsuranceEntity = await Get.find<EmployeesHealthInsuranceCubit>()
          .loadEmployeeData(
          employeeId: settingsController.employee!.email.last);
      settingsController.update();
    } catch (e) {
      // print('⚠️ Could not load health insurance entity: $e');
    }
  }

  /// Get emergency contact data from entity (legacy support)
  _getEmergencyContactData() async {
    try {
      emergencyContactEntity = await Get.find<EmergencyContactController>()
          .getEmployeeData(
          employeeId: settingsController.employee!.email.last);
      settingsController.update();
    } catch (e) {
      // print('⚠️ Could not load emergency contact entity: $e');
    }
  }

  /// Update all health insurance and emergency contact information
  Future<void> updateAllInformation() async {
    try {
      // print('========================================');
      // print('🏥 Starting Health Insurance & Emergency Contact update');
      // print('========================================');

      if (settingsController.employee == null) {
        throw Exception('Employee data is null');
      }

      showLoadingIndicator();

      bool hasChanges = false;
      int currentTimestamp = DateTime.now().millisecondsSinceEpoch;

      // Update Insurance Name
      if (changeInsuranceName) {
        String newValue = insuranceName.text.trim();
        // print('✅ Updating insurance name: $newValue');
        settingsController.employee = settingsController.employee!.copyWithUpdateSynchronized(
          insuranceName: newValue,
          addTimestamp: currentTimestamp,
        );
        hasChanges = true;
        changeInsuranceName = false;
      }

      // Update Insurance Policy Number
      if (changeInsurancePolicy) {
        String newValue = insurancePolice.text.trim();
        // print('✅ Updating policy number: $newValue');
        settingsController.employee = settingsController.employee!.copyWithUpdateSynchronized(
          insurancePolicyNumber: newValue,
          addTimestamp: currentTimestamp,
        );
        hasChanges = true;
        changeInsurancePolicy = false;
      }

      // Update First Contact First Name
      if (changeFirstContactFirstName) {
        String newValue = connectionName.text.trim();
        // print('✅ Updating first contact first name: $newValue');
        settingsController.employee = settingsController.employee!.copyWithUpdateSynchronized(
          firstContactFirstName: newValue,
          addTimestamp: currentTimestamp,
        );
        hasChanges = true;
        changeFirstContactFirstName = false;
      }

      // Update First Contact Relationship
      if (changeFirstContactRelationship) {
        String newValue = connecntionContactRelation.text.trim();
        // print('✅ Updating first contact relationship: $newValue');
        settingsController.employee = settingsController.employee!.copyWithUpdateSynchronized(
          firstContactRelationship: newValue,
          addTimestamp: currentTimestamp,
        );
        hasChanges = true;
        changeFirstContactRelationship = false;
      }

      // Update First Contact Phone
      if (changeFirstContactPhone) {
        String newValue = connecntionPhone.text.trim();
        // print('✅ Updating first contact phone: $newValue');
        settingsController.employee = settingsController.employee!.copyWithUpdateSynchronized(
          firstContactPhone: newValue,
          addTimestamp: currentTimestamp,
        );
        hasChanges = true;
        changeFirstContactPhone = false;
      }

      if (hasChanges) {
        // print('💾 Saving to Firebase...');

        String? employeeId = settingsController.employee?.id;

        if (employeeId == null || employeeId.isEmpty) {
          throw Exception('Employee ID is null');
        }

        String companyId = settingsController.storage.read('company_id') ??
            settingsController.storage.read('Company_Id') ??
            settingsController.storage.read('companyId') ??
            '84763782';

        // print('   Company ID: $companyId');
        // print('   Employee ID: $employeeId');

        await FirebaseFirestore.instance

            .collection(getBaseUrl('Employees_Info'))
            .doc(employeeId)
            .update(settingsController.employee!.toMap());

        // print('✅ Successfully saved to Firebase');

        hideLoadingIndicator();

        Get.snackbar(
          'Success',
          'Health insurance information updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // print('\n🔄 Reloading employee data from Firebase...');
        await settingsController.getEmployee();
        getData();

        // print('✅ Reload complete');
        // print('========================================');
        // print('🏁 Update completed');
        // print('========================================\n');
      } else {
        // print('⚠️ No changes detected');
        hideLoadingIndicator();

        Get.snackbar(
          'Info',
          'No changes detected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }

    } catch (e, stackTrace) {
      // print('========================================');
      // print('❌ ERROR: $e');
      // print('Stack trace: $stackTrace');
      // print('========================================');

      hideLoadingIndicator();

      Get.snackbar(
        'Error',
        'Failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Dispose controllers
  void dispose() {
    insuranceName.dispose();
    insurancePolice.dispose();
    insurancePhone.dispose();
    connectionName.dispose();
    connecntionContactRelation.dispose();
    connecntionPhone.dispose();
  }
}