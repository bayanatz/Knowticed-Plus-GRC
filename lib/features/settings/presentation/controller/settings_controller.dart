///******************** FILE INFO ****************************///
///Purpose: Controller for settings module
///Author: Mohamed Elrashidy
///created At: 10/11/2024

import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:demo_app/features/settings/data/repository/settings_repository.dart';
import '../../../employee/data/models/emplyees_model/new_employee_model.dart';
import 'package:demo_app/core/helper/employees/data/models/employee_model/employee_directory_model.dart';

import '../../utils/settings_constants.dart';
import 'health_insurance_controller.dart';
import 'personal_information_controller.dart';
import 'social_controller.dart';

class SettingsController extends GetxController {
  bool notificationEnabled = true;
  bool darkModeEnabled = false;
  final storage = GetStorage();
  SettingsRepository repository = SettingsRepository();
  int selectedContainerIndex = -1;

  // ✅ Employee data - initialized as null, not empty object
  NewEmployeeModelHistory? employee;
  EmployeeDirectoryModel? employeeDirectory;

  EmployeeController addEmployeeController = Get.find();

  // Controllers
  late PersonalInformationController personalInformationController;
  late SocialController socialController;
  late SettingsHealthInsuranceController healthInsuranceController;

  @override
  onInit() {
    super.onInit();

    // ✅ Initialize controllers BEFORE loading employee data
    socialController = SocialController(settingsController: this);
    healthInsuranceController = SettingsHealthInsuranceController(this);

    // ✅ Load employee data
    _initializeData();

    // Load notification settings
    notificationEnabled =
        storage.read(SettingsConstants.notificationEnableState) ?? true;
  }

  /// Initialize all data
  Future<void> _initializeData() async {
    await getEmployee();
    await getEmployeeDirectory();
  }

  /// Get employee data from Firebase
  Future<void> getEmployee() async {
    try {
      String? email = storage.read(SettingsConstants.emailKey);

      if (email == null || email.isEmpty) {
        // print('⚠️ No email found in storage');
        return;
      }

      // print('📥 Fetching employee data for: $email');

      employee = await addEmployeeController.getEmployee(email);

      if (employee != null) {
        // print('✅ Employee loaded: ${employee!.id}');
        // print('   - Bio: ${employee!.bio.length} entries');
        // print('   - Academic History: ${employee!.academicHistory.length} entries');
        // print('   - Skills: ${employee!.skills.length} entries');
        // print('   - Hobbies: ${employee!.hobbies.length} entries');
        // print('   - Insurance Name: ${employee!.insuranceName.length} entries');
        // print('   - Policy Number: ${employee!.insurancePolicyNumber.length} entries');

        // ✅ Initialize personal information controller after employee is loaded
        personalInformationController =
            PersonalInformationController(settingsController: this);

        // ✅ Reload social controller data
        socialController.restartController();

        // ✅ Reload health insurance data
        healthInsuranceController.getData();

        update();
      } else {
        // print('⚠️ Employee data is null');
      }
    } catch (e, stack) {
      // print('❌ Error getting employee: $e');
      // print('Stack: $stack');
    }
  }

  /// Get employee directory data
  Future<void> getEmployeeDirectory() async {
    try {
      String? email = storage.read(SettingsConstants.emailKey);

      if (email == null || email.isEmpty) {
        // print('⚠️ No email found in storage');
        return;
      }

      // print('📥 Fetching employee directory for: $email');

      employeeDirectory = await addEmployeeController.getEmployeeDirectory(email);

      if (employeeDirectory != null) {
        // print('✅ Employee directory loaded');
      } else {
        // print('⚠️ Employee directory is null');
      }

      update();
    } catch (e, stack) {
      // print('❌ Error getting employee directory: $e');
      // print('Stack: $stack');
    }
  }

  /// Refresh employee data after updates
  Future<void> refreshEmployeeData() async {
    await getEmployee();
  }

  /// Toggle notification settings
  void toggleNotification(bool value) {
    notificationEnabled = value;
    storage.write(SettingsConstants.notificationEnableState, value);
    update();
  }

  /// Toggle dark mode
  void toggleDarkMode(bool value) {
    darkModeEnabled = value;
    update();
  }

  @override
  void onClose() {
    // ✅ Dispose controllers properly
    socialController.dispose();
    super.onClose();
  }
}