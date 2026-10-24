import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/late_unit_enum.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/controller/qiyas_home_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';

import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/data_grc_2/core/constants/constants.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/CUD_module/presentation/controller/create_module_controller.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/qiyas_person_entity.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_pic.dart';

part 'control_core_state.dart';

abstract class ControlCoreCubit extends Cubit<ControlCoreState> {
  /// Public [emit] for this cubit's extension / part files and widgets
  /// ([emit] itself is protected).
  void emitState(ControlCoreState state) => emit(state);

  ControlCoreCubit(super.state);
  QiyasPersonEntity? personDetails;
  Map<String, int> visionMaxNumberOfUsage = {};
  Map<String, int> topicMaxNumberOfUsage = {};
  Map<String, int> criterionMaxNumberOfUsage = {};
  Map<String, int> documentMaxNumberOfUsage = {};

  Map<String, int> visionCurrentNumberOfUsage = {};
  Map<String, int> topicCurrentNumberOfUsage = {};
  Map<String, int> criterionCurrentNumberOfUsage = {};
  Map<String, int> documentCurrentNumberOfUsage = {};
  List<String> uniqueEmployees = [];
  List<String> filteredUniqueEmployees = [];
  List<String> selectedDepartmentsFilter = [];

  /// ******************** CREATE CONTROL VARIABLES ******************** ///
  int duplicationIndex = 1;
  QiyasPersonEntity? selectedPerson;
  TextEditingController searchController = TextEditingController();

  List<TextEditingController> visionControllersList = [TextEditingController()];
  List<TextEditingController> topicControllersList = [TextEditingController()];
  List<TextEditingController> criterionControllersList = [
    TextEditingController()
  ];
  List<LateUnitEnum> lateUnitControllersList = [LateUnitEnum.hour];
  List<int> lateUnitMultiplierControllersList = [0];
  List<TextEditingController> documentControllersList = [
    TextEditingController()
  ];
  List<TextEditingController> dateControllersList = [TextEditingController()];
  List<TextEditingController> notesControllersList = [TextEditingController()];
  List<DateTime?> _rangeDatePickerValueWithDefaultValue = [];
  DateTime? selectedDate;
  bool isShowDiscissions = false;
  List<QiyasPersonEntity> showEmployees = [];

  CreateModuleController createModuleController =
      Get.put(CreateModuleController());

  /// ************************* DETAILS PAGE VARIABLES ************************* ///

  String? selectedVision;
  String? selectedTopic;
  String? selectedCriterion;
  String? selectedDocument;
  DateTime? filterDate;
  TextEditingController filterDateTextController = TextEditingController();

  /// ********************* Users Tasks Details Variables ******************** ///

  TextEditingController tasksSearchController = TextEditingController();
  Map<EvidenceSubmissionStatus, List<EvidenceSubmissionModel>> tasks = {};
  List<EvidenceSubmissionModel> filteredTasks = [];
  EvidenceSubmissionStatus selectedStatus = EvidenceSubmissionStatus.all;
  int userTasksWidth = 60;

  /// function name: [selectDateUIHandler]
  ///
  /// purpose: Displays the date picker ui and handles the selection of the date range.
  ///          This function is used to select a specific date and update the corresponding text field.
  ///
  /// parameters:
  ///            [context] BuildContext: The build context for displaying the ui.
  ///            [calendarType] CalendarDatePicker2Type?: The type of the calendar picker.
  ///            [where] String: The location or context where the date is being selected (used for updating different fields).

  Future<void> selectDateUIHandler(BuildContext context,
      CalendarDatePicker2Type? calendarType, String where, int index) async {
    final List<DateTime?>? picked = await DatePicker().showDatePicker(context,
        _rangeDatePickerValueWithDefaultValue, DateTime.now(), calendarType,
        firstDate: DateTime.now());
    if (picked != null) {
      _rangeDatePickerValueWithDefaultValue = picked;
      selectedDate = picked[0];
      if (where == Texts.startValid) {
        dateControllersList[index].text =
            DateFormat('d MMMM y', 'ar').format(picked[0]!);
      }
    }
  }

  /// function name: [selectDate]
  ///
  /// purpose: Wrapper function for [selectDateUIHandler] that handles the ui for selecting dates.
  ///
  /// parameters:
  ///            [context] BuildContext: The build context for displaying the ui.
  ///            [calendarType] CalendarDatePicker2Type?: The type of the calendar picker.
  ///            [where] String: The location or context where the date is being selected.

  Future<void> selectDate(BuildContext context,
      CalendarDatePicker2Type? calendarType, String where, int index) async {
    selectDateUIHandler(context, calendarType, where, index);
  }

  /// function name: [duplicateTextFields]
  ///
  /// purpose: Duplicates the text fields for vision, topic, criterion, and date to allow for
  ///          multiple entries during the creation of a Qiyas control champion.

  void duplicateTextFields() {
    visionControllersList.add(TextEditingController());
    topicControllersList.add(TextEditingController());
    criterionControllersList.add(TextEditingController());
    dateControllersList.add(TextEditingController());
    documentControllersList.add(TextEditingController());
    notesControllersList.add(TextEditingController());
    lateUnitControllersList.add(LateUnitEnum.day);
    lateUnitMultiplierControllersList.add(6);
    duplicationIndex++;
    debugPrint("Duplicated text fields: $duplicationIndex");
    emit(VisionsDataChanged());
  }

  void removeDuplicatedFields(int index) {
    if (duplicationIndex <= 1) return; // Don't remove the last one
    visionControllersList.removeAt(index);
    topicControllersList.removeAt(index);
    criterionControllersList.removeAt(index);
    documentControllersList.removeAt(index);
    dateControllersList.removeAt(index);
    notesControllersList.removeAt(index);
    lateUnitControllersList.removeAt(index);
    lateUnitMultiplierControllersList.removeAt(index);
    duplicationIndex--;
    debugPrint(
        "🔴 Removed duplicated fields at index $index, remaining: $duplicationIndex");
    emit(VisionsDataChanged());
  }

  void clearAllControllers() {
    duplicationIndex = 1;
    topicControllersList = [TextEditingController()];
    visionControllersList = [TextEditingController()];
    criterionControllersList = [TextEditingController()];
    documentControllersList = [TextEditingController()];
    dateControllersList = [TextEditingController()];
    notesControllersList = [TextEditingController()];
    lateUnitControllersList = [LateUnitEnum.day];
    lateUnitMultiplierControllersList = [6];
    selectedPerson?.isSelected = false;
    selectedPerson = null;
    debugPrint("Duplicated text fields: $duplicationIndex");
    emit(VisionsDataChanged());
    emit(OwnerDataChanged());
  }

  void clearCriteriationControllerIndex(int index) {
    criterionControllersList[index].clear();
  }

  void clearVisionControllerIndex(int index) {
    visionControllersList[index].clear();
  }

  void clearDocumentControllerIndex(int index) {
    documentControllersList[index].clear();
  }

  void clearDateControllerIndex(int index) {
    dateControllersList[index].clear();
  }

  void clearTopicControllerIndex(int index) {
    topicControllersList[index].clear();
  }

  List<String> getVisionNames(int addControllerIndex) {
    final QiyasHomeCubit qiyasHomeCubit = sl();

    List<String> visions = qiyasHomeCubit.uniqueVisionNames;
    List<String> filteredVisions = [];
    for (String vision in visions) {
      if (visionMaxNumberOfUsage[vision] !=
          visionCurrentNumberOfUsage[vision]) {
        filteredVisions.add(vision);
      }
    }
    return filteredVisions;
  }

  List<String> getTopicNames(String visionName, int addControllerIndex) {
    final QiyasHomeCubit qiyasHomeCubit = sl();
    List<String> topics = qiyasHomeCubit.getTopicNamesByVisionName(visionName);
    List<String> filteredTopics = [];

    for (String topic in topics) {
      filteredTopics.add(topic);
    }
    return filteredTopics;
  }

  List<String> getCriterionNames(
      {required String topicName,
      required String visionName,
      required int addControllerIndex}) {
    final QiyasHomeCubit qiyasHomeCubit = sl();
    List<String> criteria = qiyasHomeCubit.getCriteriaNames(
        topicName: topicName, visionName: visionName);
    List<String> filteredCriteria = [];
    for (String criterion in criteria) {
      {
        filteredCriteria.add(criterion);
      }
    }
    return filteredCriteria;
  }

  List<String> getUnSelectedDocumentNames(
      {required String criterionName,
      required String topicName,
      required String visionName,
      required int addControllerIndex});
  List<String> getDocumentNames(
      {required String criterionName,
      required String topicName,
      required String visionName});

  /// function name: [toggleChecked]
  ///
  /// purpose: Toggles the selection state of a row by adding or removing it from the `selectedRows` list.
  ///          This function is used to update the selection status when a row is checked or unchecked.
  ///
  /// parameters:
  ///            [rowIndex] int: The index of the row that is being toggled.
  void toggleChecked(int rowIndex) {
    if (selectedPerson != null) {
      selectedPerson!.isSelected = false;
    }
    if (selectedPerson == showEmployees[rowIndex]) {
      selectedPerson = null;
    } else {
      selectedPerson = showEmployees[rowIndex];
      selectedPerson!.isSelected = true;
    }
    emit(OwnerDataChanged());
  }

  Future<void> initCubit() async {
    await createModuleController.readAllDepartments();
    showEmployees = [];
    for (var employee
        in Get.find<MainCoreEmployeeController>().allEmployeesEntities!) {
      showEmployees.add(QiyasPersonEntity.fromEmployeeEntity(employee));
    }
    selectedPerson?.isSelected = false;
    selectedPerson = null;
  }

  List<String> getSelectedChampionAllowedVisions();
  List<String> getVisionAllowedTopics();
  List<String> getTopicAllowedCriteria();
  List<String> getCriterionAllowedDocuments();

  void selectVision(String? visionName) {
    selectedVision = visionName;
    selectedTopic = null;
    selectedCriterion = null;
    selectedDocument = null;
    debugPrint("select vision is $selectedVision");
    if (visionName != null) emit(SectionViewUpdated());
  }

  void selectTopic(String? topicName) {
    selectedTopic = topicName;
    selectedCriterion = null;
    selectedDocument = null;
    if (topicName != null) emit(SectionViewUpdated());
  }

  void selectCriterion(String? criterionName) {
    selectedCriterion = criterionName;
    selectedDocument = null;
    if (criterionName != null) {
      getCriteriaDocumentsStatus();
    } else {
      emit(SectionViewUpdated());
    }
  }

  void selectDocument(String? documentName) {
    selectedDocument = documentName;
    emit(SectionViewUpdated());
    if (documentName != null) getEvidenceSubmissions();
  }

  void filterEmployees() {
    String searchText = searchController.text.toLowerCase();
    debugPrint("enter filter");
    filteredUniqueEmployees = uniqueEmployees.where((email) {
      QiyasPersonEntity employee = showEmployees
          .firstWhere((e) => e.id.toLowerCase() == email.toLowerCase());

      bool isAccepted = true;
      isAccepted &= employee.arabicName.toLowerCase().contains(searchText);

      isAccepted &=
          (selectedDepartmentsFilter.contains(employee.departmentName) ||
              selectedDepartmentsFilter.isEmpty);

      return isAccepted;
    }).toList();
    emit(OwnersDataLoaded());
  }

  void clearHomeFilters() {
    searchController.clear();
    selectedDepartmentsFilter = [];
    filterEmployees();
  }

  void selectDepartmentFilter(String selectedFilter) {
    if (selectedDepartmentsFilter.contains(selectedFilter)) {
      selectedDepartmentsFilter.remove(selectedFilter);
    } else {
      selectedDepartmentsFilter.add(selectedFilter);
    }
    emit(OwnersDataLoaded());
  }

  List<String> uniqueVisionNames() {
    List<String> uniqueVisionNames = sl<QiyasHomeCubit>().uniqueVisionNames;
    return uniqueVisionNames;
  }

  /// function name: [getCriteriaIdOfIndex]
  ///
  /// purpose: Returns the criteria ID for a given vision index.
  ///
  /// parameters:
  ///           [visionIndex] int: The index of the vision for which the criteria ID is being retrieved.
  ///
  /// return type: [String]:  Returns the criteria ID as a string.
  String getCriteriaIdOfIndex(int visionIndex) {
    QiyasHomeCubit qiyasHomeCubit = sl();
    for (var vision in qiyasHomeCubit.visionsList) {
      if (vision.visionName.trim() ==
              visionControllersList[visionIndex].text.trim() &&
          vision.topicName.trim() ==
              topicControllersList[visionIndex].text.trim() &&
          vision.criterionName.trim() ==
              criterionControllersList[visionIndex].text.trim()) {
        return vision.criterionNumber.trim();
      }
    }
    return "";
  }

  /// function name: [getDocumentNumberOfIndex]
  ///
  /// purpose: Returns the document number for a given vision index.
  ///
  /// parameters:
  ///           [visionIndex] int: The index of the vision for which the criteria ID is being retrieved.
  ///
  /// return type: [String]:  Returns the document number as a string.
  String getDocumentNumberOfIndex(int visionIndex) {
    return getDocumentNames(
            criterionName: criterionControllersList[visionIndex].text.trim(),
            topicName: topicControllersList[visionIndex].text.trim(),
            visionName: visionControllersList[visionIndex].text.trim())
        .indexOf(
          documentControllersList[visionIndex].text.trim(),
        )
        .toString();
  }

  /// function name: [getTopicNameByCriteriaId]
  ///
  /// purpose: Retrieves the topic name based on the given criteria ID.
  ///
  /// parameters:
  ///         [criteriaId] String: The ID of the criteria to search for.
  ///
  /// return type: [String]: Returns the topic name if found, otherwise an empty string.
  String getVisionNameByCriteriaId(String criteriaId) {
    QiyasHomeCubit qiyasHomeCubit = sl();
    for (var vision in qiyasHomeCubit.visionsList) {
      if (vision.criterionNumber.trim() == criteriaId.trim()) {
        return vision.visionName.trim();
      }
    }
    return "";
  }

  /// function name: [getTopicNameByCriteriaId]
  ///
  /// purpose: Retrieves the topic name based on the given criteria ID.
  ///
  /// parameters:
  ///          [criteriaId] String: The ID of the criteria to search for.
  ///
  /// return type: [String]: Returns the topic name if found, otherwise an empty string.
  String getTopicNameByCriteriaId(String criteriaId) {
    QiyasHomeCubit qiyasHomeCubit = sl();
    for (var vision in qiyasHomeCubit.visionsList) {
      if (vision.criterionNumber.trim() == criteriaId.trim()) {
        return vision.topicName.trim();
      }
    }
    return "";
  }

  /// function name: [getCriteriaNameByCriteriaId]
  ///
  /// purpose: Retrieves the name of the criterion based on its ID.
  ///
  /// parameters:
  ///           [criteriaId] String: The ID of the criterion to search for.
  ///
  /// return type: [String]: Returns the name of the criterion if found, otherwise an empty string.
  String getCriteriaNameByCriteriaId(String criteriaId) {
    QiyasHomeCubit qiyasHomeCubit = sl();
    for (var vision in qiyasHomeCubit.visionsList) {
      if (vision.criterionNumber.trim() == criteriaId.trim()) {
        return vision.criterionName.trim();
      }
    }
    return "";
  }

  String getDocumentNumberById(String criteriaId, String document) {
    QiyasHomeCubit qiyasHomeCubit = sl();
    for (var vision in qiyasHomeCubit.visionsList) {
      if (vision.criterionNumber.trim() == criteriaId.trim()) {
        return getDocumentNames(
            criterionName: vision.criterionName.trim(),
            topicName: vision.topicName.trim(),
            visionName: vision.visionName.trim())[int.parse(document)];
      }
    }
    return "";
  }

  void toggleDiscussionsVisibility(bool isShowDiscussionSection) {
    isShowDiscissions = isShowDiscussionSection;
    emit(SectionViewUpdated());
  }

  String getSelectedCriteriaNumber() {
    if (selectedCriterion == null) return "";
    QiyasHomeCubit qiyasHomeCubit = sl();
    for (var vision in qiyasHomeCubit.visionsList) {
      if (vision.criterionName.trim().toLowerCase() ==
          selectedCriterion!.trim().toLowerCase()) {
        debugPrint("selected criterion is ${vision.criterionNumber.trim()}");
        return vision.criterionNumber.trim().toLowerCase();
      }
    }
    return "";
  }

  String getSelectedEvidenceNumber() {
    if (selectedDocument == null) return "";
    QiyasHomeCubit qiyasHomeCubit = sl();
    for (var vision in qiyasHomeCubit.visionsList) {
      if (vision.criterionName.trim().toLowerCase() ==
          selectedCriterion!.trim().toLowerCase()) {
        String number = getDocumentNames(
                criterionName: vision.criterionName.trim(),
                topicName: vision.topicName.trim(),
                visionName: vision.visionName.trim())
            .indexOf(selectedDocument!)
            .toString();
        debugPrint("selected document is $number");
        return number;
      }
    }
    return "";
  }

  /// function name: [getEvidenceSubmissions]
  ///
  /// purpose: Retrieves the evidence submissions for the currently selected criterion and document.
  Future<void> getEvidenceSubmissions();
  Future<void> getCriteriaDocumentsStatus();
}
