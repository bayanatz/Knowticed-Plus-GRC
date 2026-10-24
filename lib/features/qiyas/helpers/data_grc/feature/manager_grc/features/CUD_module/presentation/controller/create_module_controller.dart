import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/CUD_module/data/modules/module_firestore.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/CUD_module/domain/usecases/create_module_usecase.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/CUD_module/domain/usecases/read_all_module_usecase.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/features/roles/r4_active_directory/presentation/controller/add_department_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/CUD_module/domain/entity/module_entity.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/CUD_module/domain/usecases/edit_module_usecase.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_pic.dart';

class CreateModuleController extends GetxController {
  TextEditingController moduleNameEnglish = TextEditingController();
  TextEditingController moduleNameArabic = TextEditingController();
  TextEditingController moduleDescriptionEnglish = TextEditingController();
  TextEditingController moduleDescriptionArabic = TextEditingController();
  TextEditingController moduleActivateDate = TextEditingController();
  TextEditingController moduleOwningDepartment = TextEditingController();
  TextEditingController moduleSearch = TextEditingController();

  String owningDepartment = '';
  String activationDate = '';
  bool isChecked = false;
  bool switchValue = true;
  bool switchAdminAccess = true;

  MainCoreDepartmentController departmentController =
      Get.put(MainCoreDepartmentController());
  MainCoreEmployeeController employeeController =
      Get.put(MainCoreEmployeeController());

  void changeSwitchValue() {
    switchValue = !switchValue;
    update();
  }

  @override
  void onInit() async {
    await employeeController.getAllNewEmployees();
    await readAllDepartments();
    await getAllEmployessHaveSameDepartment("finance", "middle management");
    showEmployees.assignAll(employeesHaveSameDepartment);
    // TODO: implement onInit
    super.onInit();
  }

  void changeSwitchAdminAccess() {
    switchAdminAccess = !switchAdminAccess;
    update();
  }

  bool isExist = false;

  var selectedEmployees = <int>[].obs;

  void toggleChecked(int index) {
    if (selectedEmployees.contains(index)) {
      selectedEmployees.remove(index);
      // toggleRowTextFields(rowIndex, false);
    } else {
      selectedEmployees.add(index);
      // toggleRowTextFields(rowIndex, true);
    }
    update();
  }

  bool isEmployeeChecked(int index) {
    return selectedEmployees.contains(index);
  }

  RxList<EmployeeEntityPro> showEmployees = <EmployeeEntityPro>[].obs;
  void searchByName(String query) {
    if (query.isEmpty || query == '') {
      showEmployees.assignAll(employeesHaveSameDepartment);
    } else {
      final filteredList = employeesHaveSameDepartment.where((employee) {
        return employee.firstName
                ?.toLowerCase()
                .contains(query.toLowerCase()) ??
            false;
      }).toList();

      showEmployees.assignAll(filteredList);
    }

    update();
  }

  Future<void> addModule() async {
    ModuleFirestore module = ModuleFirestore(
        name: [moduleNameEnglish.text.toLowerCase().trim()],
        nameArabic: [moduleNameArabic.text.toLowerCase().trim()],
        describtion: [moduleDescriptionEnglish.text.toLowerCase().trim()],
        describtionArabic: [moduleDescriptionArabic.text.toLowerCase().trim()],
        activationDate: [moduleActivateDate.text.toLowerCase().trim()],
        imageUrl: [
          policyImageURL ??
              "assets/icons_assets/main_icons_assets/ic_module.svg"
        ],
        owningDepartment: [moduleOwningDepartment.text.toLowerCase().trim()],
        timeStamp: [Timestamp.now()],
        moduleOwnerId: List.generate(
          selectedEmployees.length,
          (index) {
            return showEmployees[selectedEmployees[index]].email ?? '';
          },
        ),
        status: ['']);

    List<ModuleFirestore>? allModileFirestore;

    final allModules = await sl<ReadAllModuleUsecase>().execute();
    allModules.fold(
        (l) => debugPrint(l.message), (r) => allModileFirestore = r);

    isExist = allModileFirestore!.any(
      (e) => e.name.last == moduleNameEnglish.text,
    );

    if (isExist == true) {
      log("module already exist");
    } else {
      final user = await sl<CreateModuleUsecase>().execute(module);
      user.fold(
        (l) => debugPrint(l.message),
        (r) => debugPrint("Created Successfully"),
      );
    }

    // CudConstants.moduleEntities.add(module);
    update();
  }

  List<DepartmentModelPro> departments = [];
  List<String> englishDepartmentsText = [];
  List<String> arabicDepartmentsText = [];
  String idDepartment = '';
  Future<void> readAllDepartments() async {
    departments = await departmentController.getAllDepartments();
    englishDepartmentsText =
        departments.map((e) => e.departmentName ?? '').toList();
    arabicDepartmentsText =
        departments.map((e) => e.departmentNameInArabic ?? '').toList();
  }

  List<EmployeeEntityPro> employeesHaveSameDepartment = [];
  EmployeeEntityPro managerEmployee = EmployeeEntityPro();

  Future<void> getAllEmployessHaveSameDepartment(
      String departmentName, String role) async {
    idDepartment = departmentController.getDepartmentId(departmentName);
    final all = await employeeController.getAllNewEmployees();
    employeesHaveSameDepartment = (all ?? const <EmployeeEntityPro>[])
        .where((element) => element.departmentId == idDepartment)
        .toList();
    // FIXED 18/10/2026 (A1): `.first` threw "Bad state: No element" on app
    // start when nobody in the department had the role (e.g. a company whose
    // owner has no department, or roles stored with different casing).
    final String wanted = role.trim().toLowerCase();
    final int index = employeesHaveSameDepartment.indexWhere(
        (element) => (element.role ?? '').trim().toLowerCase() == wanted);
    if (index < 0) return;
    managerEmployee = employeesHaveSameDepartment[index];
    selectedEmployees.add(index);
  }

  String getDepartmentName(String departmentId) {
    return departmentController.getDepartmentName(
        departmentId, Get.locale.toString().contains('en'));
  }

  String getDepartmentNameInArabic(String departmentId) {
    return departmentController.getDepartmentName(
        departmentId, Get.locale.toString().contains('ar'));
  }

  Future<void> editModule(ModuleFirestore moduleFirestore) async {
    ModuleFirestore module = ModuleFirestore(
      name: (moduleFirestore.name..add(moduleNameEnglish.text)),
      nameArabic: (moduleFirestore.nameArabic..add(moduleNameArabic.text)),
      describtion: (moduleFirestore.describtion
        ..add(moduleDescriptionEnglish.text)),
      describtionArabic: (moduleFirestore.describtionArabic
        ..add(moduleDescriptionArabic.text)),
      activationDate: (moduleFirestore.activationDate
        ..add(moduleActivateDate.text)),
      imageUrl: (moduleFirestore.imageUrl..add(policyImageURL ?? '')),
      owningDepartment: (moduleFirestore.owningDepartment
        ..add(moduleOwningDepartment.text)),
      timeStamp: (moduleFirestore.timeStamp..add(Timestamp.now())),
      status: (moduleFirestore.status..add(moduleFirestore.status.last)),
      moduleOwnerId: (moduleFirestore.status
        ..add(moduleFirestore.moduleOwnerId.last)),
    );

    final user = await sl<EditModuleUsecase>().execute(module);
    user.fold(
      (l) => debugPrint(l.message),
      (r) => debugPrint("Editing Successfully"),
    );
    // CudConstants.moduleEntities.add(module);
    update();
  }

  void initializeTextEditingControllerEditingMode(ModuleEntity module) {
    moduleNameEnglish.text = module.name;
    moduleNameArabic.text = module.nameArabic;
    moduleDescriptionEnglish.text = module.describtion;
    moduleDescriptionArabic.text = module.describtionArabic;
    moduleActivateDate.text = module.activationDate;
    moduleOwningDepartment.text = module.department;
    policyImageURL = module.imageUrl;
    update();
  }

  /// Clears the text fields and resets the policy image URL.
  ///
  /// This method clears all the text controllers associated with module
  /// creation, including the English and Arabic names, descriptions,
  /// activation date, and owning department. Additionally, it resets the
  /// policy image URL to null.

  void clearTextEditingController() {
    moduleNameEnglish.clear();
    moduleNameArabic.clear();
    moduleDescriptionEnglish.clear();
    moduleDescriptionArabic.clear();
    moduleActivateDate.clear();
    moduleOwningDepartment.clear();
    policyImageURL = null;
  }

  //  Future<void> selectDate(BuildContext context,
  //     CalendarDatePicker2Type? calendarType, String where) async {
  //   uiHandler.selectDateUIHandler(context, calendarType, where, this);
  //   update();
  // }
  String? policyImageURL;

  /// function name: [uploadPolicyImage]
  ///
  /// purpose: Uploads a policy image by opening the device's gallery.
  ///
  /// return type: [Future<void>]
  Future<void> uploadPolicyImage() async {
    ImagePicker imagePicker = ImagePicker();

    var image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      policyImageURL = image.path;
    }

    update();
  }

  DateTime? selectedDate;
  List<DateTime?> _rangeDatePickerValueWithDefaultValue = [];

  /// function name: [selectDateUIHandler]
  ///
  /// purpose:Shows a date picker dialog to the user.
  /// parameters:
  ///            [context] BuildContext: used to show the dialog.
  ///            [calendarType] parameter specifies the type of date picker dialog to show.
  ///                           If it is null, it will show a single date picker dialog.
  ///            [where] String: where to update the text controllers:
  ///                                  If it is 'startValid', it will update the [validationStartDate].
  ///                                  If it is 'endValid', it will update the [validationEndDate].
  ///                                  If it is 'filterPolicyDetails', it will update the [filterLastEditPolicyDetails].
  ///            [controller] CreatePolicyController: The controller to get the selected date and update the text controllers.
  ///
  /// return type: [Future<void>]
  Future<void> selectDateUIHandler(
      BuildContext context,
      CalendarDatePicker2Type? calendarType,
      CreateModuleController controller) async {
    final List<DateTime?>? picked = await DatePicker().showDatePicker(context,
        _rangeDatePickerValueWithDefaultValue, DateTime.now(), calendarType);
    // change the selected the  with the picked date
    // ignore: unrelated_type_equality_checks
    if (picked != null) {
      _rangeDatePickerValueWithDefaultValue = picked;
      selectedDate = picked[
          0]; // get the first element in the array which is the selected date
      controller.moduleActivateDate.text =
          "${picked[0]!.day} ${DateFormat.MMM().format(picked[0]!)} ${picked[0]!.year}";
    }
  }

  /// function name: [selectDate]
  ///
  /// purpose:Shows a date picker dialog to the user.
  /// parameters:
  ///            [context] BuildContext: used to show the dialog.
  ///            [calendarType] parameter specifies the type of date picker dialog to show.
  ///                           If it is null, it will show a single date picker dialog.
  ///            [where] String: where to update the text controllers:
  ///                                  If it is 'startValid', it will update the [validationStartDate].
  ///                                  If it is 'endValid', it will update the [validationEndDate].
  ///                                  If it is 'filterPolicyDetails', it will update the [filterLastEditPolicyDetails].
  ///            [controller] CreatePolicyController: The controller to get the selected date and update the text controllers.
  ///
  /// return type: [Future<void>]
  Future<void> selectDate(
      BuildContext context, CalendarDatePicker2Type? calendarType) async {
    selectDateUIHandler(context, calendarType, this);
  }
}
