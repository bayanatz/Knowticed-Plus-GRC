import 'dart:developer';
import 'dart:io';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/qiyas/helpers/enums/new_control_status.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/control_owner/features/home/data/models/control_owner_firestore.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/control_owner/features/home/domain/entity/control_owner.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/data_grc_2/core/enums/policy_status.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/CUD_module/domain/entity/module_entity.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/CUD_module/domain/usecases/read_all_module_usecase.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/add_champion_officer/data/modules/champion_module.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/add_champion_officer/domain/usecases/read_all_control_champion.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/entity/control.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:path_provider/path_provider.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';

import 'package:knowticed_plus/features/qiyas/helpers/enums/module_status.dart';
import 'package:knowticed_plus/features/qiyas/helpers/enums/sorting_methods.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/firebase_helper.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/control_owner/features/home/domain/usecases/read_all_control_owner_usecase.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/add_champion_officer/domain/entity/champion_entity.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/models/control_firestore.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/models/policy_firestore.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/entity/policy.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/usecases/read_all_control_usecase.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/usecases/read_all_policy_usecase.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/CUD_module/data/modules/module_firestore.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/CUD_module/domain/usecases/edit_module_usecase.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/home/presentation/UI/widgets/control_owner_data.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_pic.dart';

class ManagerHomeController extends GetxController {
  bool isSorted = false;
  int selectedModuleDetailScreenIndex = 0;
  bool isGridView = true;

  Color selectedColor = AppColors.card;
  var moduleEntities = <ModuleEntity>[].obs;
  var policyEntities = <Policy>[].obs;
  var controlEntities = <Control>[].obs;
  var championEntities = <ChamponEntity>[].obs;
  var controlOwnerEntities = <ControlOwner>[].obs;
  List<ModuleEntity> showModules = [];
  List<ModuleEntity> activeModules = [];
  List<ModuleEntity> inactiveModules = [];
  List<ModuleEntity> removedModules = [];
  List<Policy> activePolicies = [];
  List<Policy> inactivePolicies = [];
  List<Policy> expiredPolicies = [];
  List<Policy> draftPolicies = [];
  List<Policy> showPolicies = [];
  List<Policy> allPolicies = [];
  List<Control> activeControls = [];
  List<Control> inactiveControls = [];
  List<Control> expiredControls = [];
  List<Control> draftControls = [];
  List<Control> showControls = [];
  List<Control> allControls = [];
  List<EmployeeEntityPro> showChampions = [];
  List<ControlOwnerData> showOwner = [];

  List<int> controlsLength = [];

  int selectedFilterStatusModules = 0;
  int selectedFilterStatusPolicies = 0;
  int selectedFilterStatusControls = 0;

  MainCoreEmployeeController mainCoreEmployeeController =
      Get.put(MainCoreEmployeeController());

  @override
  void onInit() {
    readDataFromFirestore().then((value) {
      moduleEntities.value = modulesFromFirestore
          .map((module) => ModuleEntity.moduleFireBasetoEntity(module))
          .toList();
      showModules = moduleEntities;
      debugPrint("--------------------");
      debugPrint('$moduleEntities');
      initializeFilterStatusModules();
      update();
    });
    readAllPoliciesFromFirestore().then((value) {
      policyEntities.value = policiesFromFirestore
          .map((policy) => Policy.policyFireBasetoEntity(policy))
          .toList();
      // showPolicies = policyEntities;
      // print("--------------------");
      // print(policyEntities.value);
      update();
    });
    readAllControlsFromFirestore().then((value) {
      controlEntities.value = controlsFromFirestore
          .map((control) => Control.controlFireBasetoEntity(control))
          .toList();
      // showControls = controlEntities;
      policyEntities.map((policy) async {
        String? id = await sl<FireBaseHelper<PolicyFirestore>>()
            .getItemId("name", policy.name.toLowerCase());
        policy.controls =
            controlEntities.where((control) => control.id == id).toList();
      }).toList();
      debugPrint('$controlEntities');

      // initializeFilterStatusControls(policyEntities[0]);
      update();
    });
    readAllControlChampionsFromFirestore().then((value) {
      championEntities.value = championsFromFirestore
          .map((champion) => ChamponEntity.championFireBasetoEntity(champion))
          .toList();

      // showControls = controlEntities;
      debugPrint('$controlEntities');
      // initializeFilterStatusControls(policyEntities[0]);
      update();
    });
    readAllControlOwnerFromFirestore().then((value) {
      controlOwnerEntities.value = controlOwnerFromFirestore
          .map((owner) => ControlOwner.controlOwnerFireBasetoEntity(owner))
          .toList();
      // showControls = controlEntities;
      debugPrint('$controlEntities');
      // initializeFilterStatusControls(policyEntities[0]);
      update();
    });

    // TODO: implement onInit
    super.onInit();
  }

  Future<List<Policy>> getPoliciesByModuleID(ModuleEntity module) async {
    String? id = await sl<FireBaseHelper<ModuleFirestore>>()
        .getItemId("name", module.name.toLowerCase());
    return policyEntities.where((policy) => policy.id == id).toList();
  }

  Future<List<Control>> getControlsByPolicyID(Policy policy) async {
    String? id = await sl<FireBaseHelper<PolicyFirestore>>()
        .getItemId("name", policy.name.toLowerCase());
    List<Control> controls =
        controlEntities.where((control) => control.id == id).toList();
    return controls;
  }

  List<ModuleFirestore> modulesFromFirestore = [];
  List<PolicyFirestore> policiesFromFirestore = [];
  List<ControlFirestore> controlsFromFirestore = [];
  List<ChampionFirestore> championsFromFirestore = [];
  List<ControlOwnerFirestore> controlOwnerFromFirestore = [];
  String errorMassage = '';

  Future<void> readDataFromFirestore() async {
    final data = await sl<ReadAllModuleUsecase>().execute();
    data.fold((l) => errorMassage = l.message, (r) => modulesFromFirestore = r);
  }

  Future<void> readAllPoliciesFromFirestore() async {
    final data = await sl<ReadAllPolicyUsecase>().execute();
    data.fold(
        (l) => errorMassage = l.message, (r) => policiesFromFirestore = r);
  }

  Future<void> readAllControlsFromFirestore() async {
    final data = await sl<ReadAllControlUsecase>().execute();
    data.fold(
        (l) => errorMassage = l.message, (r) => controlsFromFirestore = r);
  }

  Future<void> readAllControlChampionsFromFirestore() async {
    final data = await sl<ReadAllControlChampionUsecase>().execute();
    data.fold(
        (l) => errorMassage = l.message, (r) => championsFromFirestore = r);
  }

  Future<void> readAllControlOwnerFromFirestore() async {
    final data = await sl<ReadAllControlOwnerUsecase>().execute();
    data.fold(
        (l) => errorMassage = l.message, (r) => controlOwnerFromFirestore = r);
  }

  Future<List<EmployeeEntityPro>> getChampionEmployees(
      ModuleEntity module) async {
    String? id = await sl<FireBaseHelper<ModuleFirestore>>()
        .getItemId("name", module.name.toLowerCase());
    List<EmployeeEntityPro> employees = [];

    for (var champion in championEntities) {
      if (id != champion.moduleId) continue;

      final employee = mainCoreEmployeeController
          .getLocaleEmployee(champion.controlChampion.toLowerCase());

      if (employee != null) {
        employees.add(employee);
      } else {
        // Log or handle the case where employee is not found
        debugPrint(
            'Warning: Employee not found for champion: ${champion.controlChampion}');
      }
    }

    return employees;
  }

  Future<List<ControlOwnerData>> getControlOwnerEmployees(
      ModuleEntity module) async {
    String? id = await sl<FireBaseHelper<ModuleFirestore>>()
        .getItemId("name", module.name.toLowerCase());
    List<ControlOwnerData> employees = [];

    for (var owner in controlOwnerFromFirestore) {
      if (id != owner.moduleId.last) continue;

      final employee = mainCoreEmployeeController
          .getLocaleEmployee(owner.controlOwner.last.toLowerCase());

      if (employee != null) {
        List<String> policies = owner.policies;
        List<String> controls = owner.controls;
        ControlOwnerData employeeData = ControlOwnerData(
            employee: employee,
            policies: policies,
            controls: controls,
            policyControlMap: mapControlsToPolicies(policies, controls.last));

        employees.add(employeeData);
      } else {
        // Log or handle the case where employee is not found
        debugPrint(
            'Warning: Employee not found for control owner: ${owner.controlOwner.last}');
      }
    }

    return employees;
  }

  Map<String, List<String>> mapControlsToPolicies(
      List<String> policies, String controls) {
    Map<String, List<String>> policyControlMap = {};

    // Extracting control groups by splitting using ';'
    List<String> controlGroups = controls
        .split(";")
        .map((group) =>
            group.trim().replaceAll("'", "")) // Remove single quotes and trim
        .toList();

    // Assign each control group to the corresponding policy
    for (int i = 0; i < policies.length; i++) {
      if (i < controlGroups.length) {
        // Split controls inside the group by ',' and trim spaces
        List<String> controlsList =
            controlGroups[i].split(",").map((c) => c.trim()).toList();

        policyControlMap[policies[i]] = controlsList;
      }
    }

    return policyControlMap;
  }

  // Future<void> deleteDataFromFirestore(ModuleFirestore module) async {
  //   final data = await sl<DeleteModuleUsecase>().execute(module);
  //   data.fold((l) => errorMassage = l.message, (r) => print("Deleted Successfully"));
  // }

  void initializeFilterStatusModules() {
    activeModules = moduleEntities
        .where(
            (module) => module.status.last == ModuleStatus.active.displayName)
        .toList();
    inactiveModules = moduleEntities
        .where(
            (module) => module.status.last == ModuleStatus.inactive.displayName)
        .toList();
    removedModules = moduleEntities
        .where(
            (module) => module.status.last == ModuleStatus.removed.displayName)
        .toList();
    update();
  }

  void initializeFilterStatusPolicies(ModuleEntity module) async {
    List<Policy> policies = await getPoliciesByModuleID(module);

    selectedFilterStatusPolicies = 0;
    allPolicies = policies;
    showPolicies = policies;

    activePolicies = policies
        .where((module) => module.status == PolicyStatus.active.displayName)
        .toList();
    inactivePolicies = policies
        .where(
            (policy) => policy.status == PolicyStatus.deactivated.displayName)
        .toList();
    expiredPolicies = policies
        .where((policy) => policy.status == PolicyStatus.expired.displayName)
        .toList();
    draftPolicies = policies
        .where((policy) => policy.status == PolicyStatus.draft.displayName)
        .toList();
    update();
  }

  void initializeFilterStatusControls(Policy policy) async {
    List<Control> controls = await getControlsByPolicyID(policy);

    selectedFilterStatusControls = 0;
    showControls = controls;
    allControls = controls;
    activeControls = controls
        .where((control) =>
            control.controlStatus == NewControlStatus.active.displayName)
        .toList();
    inactiveControls = controls
        .where((control) =>
            control.controlStatus == NewControlStatus.inactive.displayName)
        .toList();
    expiredControls = controls
        .where((control) =>
            control.controlStatus == NewControlStatus.expired.displayName)
        .toList();
    draftControls = controls
        .where((control) =>
            control.controlStatus == NewControlStatus.draft.displayName)
        .toList();
    update();
  }

  Future<void> changeModuleStatus(
      String status, ModuleEntity moduleEntity) async {
    ModuleFirestore? newModule;
    modulesFromFirestore.firstWhere((module) {
      if (module.name.last == moduleEntity.name) {
        moduleEntity.status.add(status);
        newModule = module.editModuleFirestore(moduleEntity);
        return true;
      }
      return false;
    });
    if (newModule != null) {
      final user = await sl<EditModuleUsecase>().execute(newModule!);
      user.fold(
        (l) => debugPrint(l.message),
        (r) => debugPrint("Editing Successfully"),
      );

      moduleEntities.value = modulesFromFirestore
          .map((module) => ModuleEntity.moduleFireBasetoEntity(module))
          .toList();
      initializeFilterStatusModules();
      update();
    }
  }

  Future<void> restoreModule(ModuleEntity moduleEntity) async {
    ModuleFirestore? newModule;
    modulesFromFirestore.firstWhere((module) {
      if (module.name.last == moduleEntity.name && module.status.length >= 2) {
        moduleEntity.status.add(module.status[module.status.length - 2]);
        newModule = module.editModuleFirestore(moduleEntity);
        return true;
      }
      return false;
    });
    if (newModule != null) {
      final user = await sl<EditModuleUsecase>().execute(newModule!);
      user.fold(
        (l) => debugPrint(l.message),
        (r) => debugPrint("Editing Successfully"),
      );

      moduleEntities.value = modulesFromFirestore
          .map((module) => ModuleEntity.moduleFireBasetoEntity(module))
          .toList();
      initializeFilterStatusModules();
      update();
    }
  }

  void changeSelectedFilterStatusModules(int index) {
    selectedFilterStatusModules = index;
    update();
  }

  void changeSelectedFilterStatusPolicies(int index) {
    selectedFilterStatusPolicies = index;
    update();
  }

  void changeSelectedFilterStatusControls(int index) {
    selectedFilterStatusControls = index;
    update();
  }

  void updatIsGridView(bool value) {
    isGridView = value;
    update();
  }

  void updateSelectedModuleDetailScreenIndex(int value) {
    selectedModuleDetailScreenIndex = value;
    update();
  }

  void updateSortState() {
    isSorted = !isSorted;
    update();
  }

  DateTime? selectedDate;
  List<DateTime?> _rangeDatePickerValueWithDefaultValue = [];

  /// Shows a date picker dialog with the given [calendarType] and updates the [_rangeDatePickerValueWithDefaultValue] with the selected date.
  /// If [where] is 'filterCreation' it will update the [filterCreationDate] with the selected dates.
  ///
  Future<void> selectDate(BuildContext context,
      CalendarDatePicker2Type? calendarType, String where) async {
    final List<DateTime?>? picked = await DatePicker().showDatePicker(context,
        _rangeDatePickerValueWithDefaultValue, DateTime.now(), calendarType);
    // change the selected the  with the picked date
    // ignore: unrelated_type_equality_checks
    if (picked != null) {
      _rangeDatePickerValueWithDefaultValue = picked;
      selectedDate = picked[
          0]; // get the first element in the array which is the selected date

      if (where == 'filterCreation') {
        filterCreationDate.text =
            "${'From'.tr} ${picked[0]!.day} ${DateFormat.MMM().format(picked[0]!)} ${picked[0]!.year} ${'To'.tr} ${picked.last!.day} ${DateFormat.MMM().format(picked.last!)} ${picked.last!.year}";
      }
      update();
    }
  }

  String homeTextSearch = '';

/*************  ✨ Codeium Command ⭐  *************/
  /// Updates the [statusHomeFilter] with the given [value] and triggers an update to refresh the ui.
  ///
  /// This function is used to filter the policies in the home page based on their status.
  /// Updates the [statusHomeFilter] with the given [value] and triggers an update to refresh the ui.
  ///
  /// This function is used to filter the policies in the home page based on their status.
  String? statusHomeFilter;
  void statusHomeFilterState(String? value) {
    statusHomeFilter = value;
    update();
  }

  TextEditingController noOfControlsFilter = TextEditingController();

  TextEditingController filterCreationDate = TextEditingController();
  TextEditingController wieghtsFilter = TextEditingController();

  bool isFilterEnabled = false;

  /// Resets all the filter fields and disables the filter flag.
  ///
  /// This function clears all the filter fields and sets the [isFilterEnabled] flag to false.
  /// After performing these operations, it updates the ui to reflect the changes.
  void resetFilter() {
    noOfControlsFilter.clear();
    filterCreationDate.clear();
    wieghtsFilter.clear();
    statusHomeFilter = null;
    isFilterEnabled = false;
    update();
  }

  /// Enables or disables the filter based on whether any of the filter fields have values.
  ///
  /// Checks if any of the filter fields have values. If any of the filter fields have values,
  /// the filter is enabled. Otherwise, the filter is disabled. After making this check,
  /// the ui is updated to reflect the changes.
  void applyFilter() {
    noOfControlsFilter.text != '' ||
            filterCreationDate.text != '' ||
            wieghtsFilter.text != '' ||
            statusHomeFilter != null
        ? isFilterEnabled = true
        : isFilterEnabled = false;
    update();
  }

  String sortIndexSelection = '';

  void sortItems(List<ModuleEntity> items, SortingMethods sortType) {
    switch (sortType) {
      case SortingMethods.ascending:
        items.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortingMethods.descending:
        items.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortingMethods.creationDate:
        items.sort((a, b) => a.creationDate.compareTo(b.creationDate));
        break;
      case SortingMethods.lastUpdate:
        items.sort((a, b) => a.latUpdate.compareTo(b.latUpdate));
        break;
    }
  }

  List<ModuleEntity> searchModules(String query) {
    if (query == '') {
      return moduleEntities;
    }
    return moduleEntities.where((product) {
      final nameLower = product.name.toLowerCase();
      final queryLower = query.toLowerCase();

      return nameLower.contains(queryLower);
    }).toList();
  }

  Future<void> exportToCSV(List<String> headers, List<Policy> policies) async {
    List<List<String>> csvData = [
      headers, // header
      ...List.generate(policies.length, (index) {
        final policy = policies[index];
        return [
          (index + 1).toString(),
          policy.name,
          policy.describtion,
          policy.weight.toString(),
          policy.status,
          policy.creationDate.toString(),
          policy.controls.length.toString(),
          policy.lastEditDate.toString(),
        ];
      })
    ];

    String csv = Csv(autoDetect: false).encode(csvData);

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/Policies_Export.csv";
    log(path);

    final file = File(path);
    await file.writeAsString(csv);

    debugPrint('CSV exported to: $path');
  }
}
