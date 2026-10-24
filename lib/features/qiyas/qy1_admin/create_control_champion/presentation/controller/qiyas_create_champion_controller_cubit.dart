/// ************************ FILE INFO ************************* ///
/// File Name: qiyas_create_controller_cubit.dart
/// Purpose: Defines the controller for creating Qiyas Control Champions.
/// Author: Mohamed Elrashidy
/// Created At: 18/5/2025
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/data_grc_2/features/create_policy/presentation/controller/policy_ui_handler.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/use_cases/get_evidence_submissions.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/employee_entity_details_controller.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/user_details_tasks_controller.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/qiyas_person_entity.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/controller/qiyas_home_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/data/models/qiyas_champion_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/qiyas_champion_entity.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/base_repository/qiyas_champion_repo.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/use_cases/add_qiyas_champion_officer.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/use_cases/get_critrie_documents_status_use_case.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/use_cases/read_all_qiyas_control_champion.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

class QiyasCreateChampionControllerCubit extends ControlCoreCubit
    with EmployeeEntityDetailsController {
  QiyasCreateChampionControllerCubit() : super(ControlCoreInitial()) {
    initCubit();
  }
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<QiyasChampionModel> qiyasChampionsFromFirestore = [];
  List<String> uniqueQiyasChampions = [];
  List<String> uniqueDetailsQiyasChampions = [];
  List<QiyasChampionEntity> showQiyasChampions = [];
  List<QiyasChampionEntity> qiyasChampions = <QiyasChampionEntity>[];
  List<QiyasChampionEntity> editedQiyasChampions = [];
  Map<String, List<String>> mapSelectedVisionsAndTopics = {};
  Set<QiyasChampionEntity> stateChangedQiyasChampions = {};
  PolicyUIHandler uiHandler = PolicyUIHandler();

  List<String> uniqueDetailsChampions = [];
  List<String> uniqueDetailsOwners = [];
  String errorMassage = '';
  late ReadAllQiyasControlChampionUsecase readAllQiyasChampionsUseCase;

  @override
  initCubit() async {
    await super.initCubit();
    readAllQiyasChampionsUseCase =
        ReadAllQiyasControlChampionUsecase(sl<QiyasChampionRepo>());

    await readDataFromFirestore().then((value) async {
      qiyasChampions = qiyasChampionsFromFirestore
          .map((qiyasChampion) =>
              QiyasChampionEntity.qiyasChampionFireBasetoEntity(qiyasChampion))
          .toList();
      extractUniqueQiyasChampions();
      uniqueEmployees = extractUniqueQiyasChampions();
      filteredUniqueEmployees = uniqueEmployees.toSet().toList();
      getEmployeesFromEmails(uniqueEmployees);
    });
    await fetchChampions();
    emit(OwnersDataLoaded());
    _live.watchPaths(
      [getBaseUrl(kQiyasChampionNameCollection)],
      _silentRefresh,
    );
  }

  final LiveRefresh _live = LiveRefresh();

  /// Re-reads the champions silently (no loader, filters/search kept) so the
  /// champions list and counts follow any create/edit/delete/reassign.
  Future<void> _silentRefresh() async {
    await readDataFromFirestore();
    if (isClosed) return;
    qiyasChampions = qiyasChampionsFromFirestore
        .map((qiyasChampion) =>
            QiyasChampionEntity.qiyasChampionFireBasetoEntity(qiyasChampion))
        .toList();
    uniqueEmployees = extractUniqueQiyasChampions();
    try {
      filterEmployees();
    } catch (_) {
      filteredUniqueEmployees = uniqueEmployees.toSet().toList();
    }
    getEmployeesFromEmails(uniqueEmployees);
    emit(OwnersDataLoaded());
  }

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }

  /// function name: [readDataFromFirestore]
  ///
  /// purpose: Reads data from Firestore and populates the list of Qiyas champions. This is
  ///          used to load the data when the controller is initialized or refreshed.
  Future<void> readDataFromFirestore() async {
    final data = await sl<ReadAllQiyasControlChampionUsecase>().execute();
    data.fold(
      (l) => errorMassage = l.message,
      (r) {
        // print(" get all champions data length is ${r.length}");
        qiyasChampionsFromFirestore = r;
        extractUniqueQiyasChampions();
      },
    );
    emit(VisionsDataChanged());
  }

  /// function name: [extractUniqueQiyasChampions]
  ///
  /// purpose: Extracts a list of unique Qiyas champions from the Firestore data to be used in the ui.
  ///
  /// return type: [List<String>] - A list of unique Qiyas champion names.
  List<String> extractUniqueQiyasChampions() {
    final qiyasChampionsSet = <String>{};

    for (var qiyasChampions in qiyasChampionsFromFirestore) {
      if (qiyasChampions.controlChampion.isNotEmpty) {
        final cleanedName = qiyasChampions.controlChampion.trim();
        qiyasChampionsSet.add(cleanedName);
      }
    }
    uniqueQiyasChampions = qiyasChampionsSet.toList();
    emit(OwnersDataLoaded());
    return uniqueQiyasChampions;
  }

  /// function name: [getQiyasChampions]
  ///
  /// purpose: Retrieves a list of Qiyas champions that match the criteria for control champions.
  ///
  /// return type: [Future<List<QiyasChampionEntity>>] - A list of matching Qiyas champion entities.
  Future<List<QiyasChampionEntity>> getQiyasChampions() async {
    return qiyasChampions.where((qiyasChampion) => false).toList();
  }

  /// function name: [fetchChampions]
  ///
  /// purpose: Fetches all Qiyas champions using the use case and handles any errors during the process.

  Future<void> fetchChampions() async {
    try {
      await readAllQiyasChampionsUseCase.execute();
    } catch (e) {
      debugPrint("Error fetching champions: $e");
    }
  }

  /// function name: [addQiyasChampion]
  ///
  /// purpose: Adds a new Qiyas control champion to Firestore, creating a record with the selected employees,
  ///          topics, visions, and other related data.

  Future<void> addQiyasChampion(
      {List<QiyasChampionEntity> reassignedChampions = const [],
      required Function() onSuccess}) async {
    List<String> criteriaIds = [];
    List<String> document = [];
    List<String> notes = [];
    List<DateTime> dateSubmission = [];
    debugPrint('🟡 SAVING dateSubmission: $dateSubmission');
    debugPrint('🟡 SAVING criteriaIds: $criteriaIds');
    debugPrint('🟡 SAVING document: $document');
    for (int i = 0; i < duplicationIndex; i++) {
      if (dateControllersList[i].text.isEmpty ||
          visionControllersList[i].text.isEmpty ||
          topicControllersList[i].text.isEmpty ||
          criterionControllersList[i].text.isEmpty ||
          documentControllersList[i].text.isEmpty) {
        continue;
      }
      criteriaIds.add(getCriteriaIdOfIndex(i));
      document.add(getDocumentNumberOfIndex(i));
      notes.add(notesControllersList[i].text);
      debugPrint("date controller is : ${dateControllersList[i].text}");
      dateSubmission.add(DateFormat('d MMMM y', 'ar')
          .parse(dateControllersList[i].text.trim()));
    }
    for (int i = 0; i < reassignedChampions.length; i++) {
      criteriaIds.add(reassignedChampions[i].criteriaId);
      document.add(reassignedChampions[i].documentNumber);
      notes.add(reassignedChampions[i].additionalNote);
      dateSubmission.add(reassignedChampions[i].documentSubmissionDate);
      lateUnitControllersList.add(reassignedChampions[i].lateUnit);
      lateUnitMultiplierControllersList
          .add(reassignedChampions[i].lateUnitMultiplier);

      // ToDo: handle late unit and multiplier for reassigned champions
    }

    final user = await sl<AddQiyasChampionOfficersUsecase>().execute(
      criteriaIds: criteriaIds,
      document: document,
      documentSubmissionDate: dateSubmission,
      additionalNote: notes,
      lateUnitMultiplier: lateUnitMultiplierControllersList,
      lateUnit: lateUnitControllersList,
      email: selectedPerson!.id,
    );

    if (user.isRight()) {
      onSuccess();
      initCubit();
      emit(AddNewControlDataSuccess());
    } else {
      emit(AddNewControlDataFailed(""));
    }
  }

  /// function name: [extractUniqueDetailsQiyasChampions]
  ///
  /// purpose: Extracts a list of unique details (visions, topics, criteria) for a specific Qiyas champion.
  ///
  /// parameters:
  ///            [controlChampion] String: The name of the control champion whose details are being extracted.
  ///
  /// return type: [List<String>] - A list of unique details (visions, topics, criteria) for the control champion.
  List<String> extractUniqueDetailsQiyasChampions(String controlChampion) {
    return uniqueDetailsQiyasChampions;
  }

  /// function name: [refreshData]
  ///
  /// purpose: Refreshes the data by reloading Qiyas control champions from Firestore.

  Future<void> refreshData() async {
    await readDataFromFirestore();
  }

  @override
  List<String> getSelectedChampionAllowedVisions() {
    Set<String> visionsSet = {};
    for (var qiyasChampion in qiyasChampionsFromFirestore) {
      if (qiyasChampion.controlChampion.toLowerCase().trim() ==
          personDetails!.id.toLowerCase().trim()) {
        visionsSet.add(getVisionNameByCriteriaId(qiyasChampion.criteriaId));
      }
    }
    visionsSet.remove('');
    return visionsSet.toList();
  }

  @override
  List<String> getCriterionAllowedDocuments() {
    Set<String> documentsSet = {};
    for (var qiyasChampion in qiyasChampionsFromFirestore) {
      if (qiyasChampion.controlChampion.toLowerCase().trim() ==
          personDetails!.id.toLowerCase().trim()) {
        if (selectedVision ==
                getVisionNameByCriteriaId(qiyasChampion.criteriaId) &&
            selectedTopic ==
                getTopicNameByCriteriaId(qiyasChampion.criteriaId) &&
            selectedCriterion ==
                getCriteriaNameByCriteriaId(qiyasChampion.criteriaId)) {
          documentsSet.add(getDocumentNumberById(
              qiyasChampion.criteriaId, qiyasChampion.document));
        }
      }
    }
    documentsSet.remove('');
    return documentsSet.toList();
  }

  @override
  List<String> getTopicAllowedCriteria() {
    Set<String> visionsSet = {};
    for (var qiyasChampion in qiyasChampionsFromFirestore) {
      if (qiyasChampion.controlChampion.toLowerCase().trim() ==
          personDetails!.id.toLowerCase().trim()) {
        if (selectedVision ==
                getVisionNameByCriteriaId(qiyasChampion.criteriaId) &&
            selectedTopic ==
                getTopicNameByCriteriaId(qiyasChampion.criteriaId)) {
          visionsSet.add(getCriteriaNameByCriteriaId(qiyasChampion.criteriaId));
        }
      }
    }
    visionsSet.remove('');
    return visionsSet.toList();
  }

  @override
  List<String> getVisionAllowedTopics() {
    Set<String> visionsSet = {};
    for (var qiyasChampion in qiyasChampionsFromFirestore) {
      if (qiyasChampion.controlChampion.toLowerCase().trim() ==
          personDetails!.id.toLowerCase().trim()) {
        if (selectedVision ==
            getVisionNameByCriteriaId(qiyasChampion.criteriaId)) {
          visionsSet.add(getTopicNameByCriteriaId(qiyasChampion.criteriaId));
        }
      }
    }
    visionsSet.remove('');
    return visionsSet.toList();
  }

  @override
  getEvidenceSubmissions() async {
    tasks = {};
    filteredTasks = [];

    emit(EvidenceSubmissionLoading());
    final result =
        await GetEvidenceSubmissions(repository: sl<QiyasChampionRepo>())
            .execute(
                criteriaNumber: getSelectedCriteriaNumber(),
                evidenceNumber: getSelectedEvidenceNumber(),
                championNumber: personDetails!.id);
    if (result.isRight()) {
      tasks = result.fold((_) => {}, (r) => r);
      // 🟡 ADD THIS DEBUG BLOCK
      for (var entry in tasks.entries) {
        for (var task in entry.value) {
          debugPrint('🟡 TASK DEBUG: status=${entry.key}, '
              'submissionDate=${task.submissionDate}, '
              'criteriaNumber=${task.criteriaNumber}, '
              'evidenceNumber=${task.evidenceNumber}');
        }
      }
      filteredTasks = tasks[selectedStatus] ?? [];
      filterTasks();
    }
    filteredTasks.add(EvidenceSubmissionModel(
      submissionDate: null,
      submissionStatus: EvidenceSubmissionStatus.unCompleted,
      submissionId: '',
      evidenceNumber: getSelectedEvidenceNumber(),
      criteriaNumber: getSelectedCriteriaNumber(),
      submittedBy: null,
    ));
    emit(EvidenceSubmissionLoaded());
  }

  @override
  getCriteriaDocumentsStatus() async {
    tasks = {};
    filteredTasks = [];
    List<QiyasChampionEntity> uniqueQiyasChampionEntity = [];
    for (var qiyasChampion in qiyasChampions) {
      if (qiyasChampion.criteriaId == getSelectedCriteriaNumber()) {
        uniqueQiyasChampionEntity.add(qiyasChampion);
      }
    }
    emit(EvidenceSubmissionLoading());
    final result = await GetCriterieDocumentsStatusUseCase(
            repository: sl<QiyasChampionRepo>())
        .execute(
            criteriaNumbers:
                uniqueQiyasChampionEntity.map((e) => e.criteriaId).toList(),
            evidenceNumbers:
                uniqueQiyasChampionEntity.map((e) => e.documentNumber).toList(),
            deadLines: uniqueQiyasChampionEntity
                .map((e) => e.documentSubmissionDate)
                .toList(),
            lateUnitMultiplier: uniqueQiyasChampionEntity
                .map((e) => e.lateUnitMultiplier)
                .toList(),
            lateUnit: uniqueQiyasChampionEntity.map((e) => e.lateUnit).toList(),
            championId: personDetails!.id);
    if (result.isRight()) {
      tasks = result.fold((_) => {}, (r) => r);
      // 🟡 ADD THIS DEBUG BLOCK
      for (var entry in tasks.entries) {
        for (var task in entry.value) {
          debugPrint('🟡 EVIDENCE DEBUG: status=${entry.key}, '
              'submissionDate=${task.submissionDate}, '
              'deadline field check');
        }
      }

      emit(EvidenceSubmissionLoaded());
    }
  }

  void initChampionEditControllers() {
    clearAllControllers();
    selectedPerson = personDetails;
    editedQiyasChampions = qiyasChampions.toSet().toList();
    stateChangedQiyasChampions = {};
  }

  void initChampionReassignControllers() {
    clearAllControllers();
    duplicationIndex = 0;
    visionControllersList = [];
    topicControllersList = [];
    criterionControllersList = [];
    documentControllersList = [];
    dateControllersList = [];
    notesControllersList = [];
    lateUnitControllersList = [];
    lateUnitMultiplierControllersList = [];

    selectedPerson = null;
    editedQiyasChampions = qiyasChampions.toSet().toList();
    stateChangedQiyasChampions = {};
  }

  List<String> getUserUniqueVisions() {
    Set<String> uniqueVisions = {};
    for (QiyasChampionEntity qiyasChampion in editedQiyasChampions) {
      debugPrint(
          "control champion is : ${qiyasChampion.controlChampion} and person details id is : ${personDetails!.id}");

      if (qiyasChampion.controlChampion.trim().toLowerCase() ==
              personDetails!.id.trim().toLowerCase() &&
          !stateChangedQiyasChampions.contains(qiyasChampion)) {
        uniqueVisions.add(
          getVisionNameByCriteriaId(qiyasChampion.criteriaId),
        );
      }
    }
    return uniqueVisions.toList();
  }

  List<String> getUserUniqueTopics() {
    Set<String> uniqueTopics = {};
    for (QiyasChampionEntity qiyasChampion in editedQiyasChampions) {
      debugPrint(
          "control champion is : ${qiyasChampion.controlChampion} and person details id is : ${personDetails!.id}");
      if (qiyasChampion.controlChampion.trim().toLowerCase() ==
              personDetails!.id.trim().toLowerCase() &&
          !stateChangedQiyasChampions.contains(qiyasChampion)) {
        uniqueTopics.add(
          getTopicNameByCriteriaId(qiyasChampion.criteriaId),
        );
      }
    }
    return uniqueTopics.toList();
  }

  List<String> getUserUniqueCriteria() {
    Set<String> uniqueCriteria = {};
    for (QiyasChampionEntity qiyasChampion in editedQiyasChampions) {
      if (qiyasChampion.controlChampion.trim().toLowerCase() ==
              personDetails!.id.trim().toLowerCase() &&
          !stateChangedQiyasChampions.contains(qiyasChampion)) {
        uniqueCriteria
            .add(getCriteriaNameByCriteriaId(qiyasChampion.criteriaId));
      }
    }
    return uniqueCriteria.toList();
  }

  List<String> getUserUniqueDocuments() {
    Set<String> uniqueDocuments = {};
    debugPrint("\n=== GET USER UNIQUE DOCUMENTS ===");
    debugPrint(
        "edited qiyas champions length is : ${editedQiyasChampions.length}");

    for (QiyasChampionEntity qiyasChampion in editedQiyasChampions) {
      if (qiyasChampion.controlChampion.trim().toLowerCase() !=
          personDetails!.id.trim().toLowerCase()) {
        continue;
      }
      if (stateChangedQiyasChampions.contains(qiyasChampion)) continue;

      debugPrint("\n📄 Processing Champion:");
      debugPrint("   Criteria ID: ${qiyasChampion.criteriaId}");
      debugPrint("   Document Number: ${qiyasChampion.documentNumber}");

      List<String> documents = getDocumentNames(
          criterionName: getCriteriaNameByCriteriaId(qiyasChampion.criteriaId),
          topicName: getTopicNameByCriteriaId(qiyasChampion.criteriaId),
          visionName: getVisionNameByCriteriaId(qiyasChampion.criteriaId));

      debugPrint("   Available Documents: ${documents.length}");
      debugPrint("   Documents: $documents");

      int documentIndex;
      try {
        documentIndex = int.parse(qiyasChampion.documentNumber);
        debugPrint("   Parsed Index: $documentIndex");
      } catch (e) {
        debugPrint(
            "   ❌ ERROR: Cannot parse document number: ${qiyasChampion.documentNumber}");
        continue;
      }

      if (documentIndex < 0 || documentIndex >= documents.length) {
        debugPrint(
            "   ❌ ERROR: Index $documentIndex out of bounds (0-${documents.length - 1})");
        continue;
      }

      String documentName = documents[documentIndex];
      debugPrint("   ✅ Document Name: $documentName");
      uniqueDocuments.add(documentName);
    }

    debugPrint("\n=== FINAL UNIQUE DOCUMENTS ===");
    debugPrint("unique documents are : $uniqueDocuments");
    debugPrint("==============================\n");
    return uniqueDocuments.toList();
  }

  Future<void> deleteQiyasChampionList(
      List<QiyasChampionEntity> permission) async {
    final result =
        await sl<QiyasChampionRepo>().deleteQiyasChampion(permission);
    if (result.isRight()) {}
  }

  List<QiyasChampionEntity> getSelectedUserChampionEntities() {
    List<QiyasChampionEntity> selectedUserChampions = [];
    for (var qiyasChampion in qiyasChampions) {
      if (qiyasChampion.controlChampion.toLowerCase().trim() ==
          personDetails!.id.toLowerCase().trim()) {
        if (!stateChangedQiyasChampions.contains(qiyasChampion)) {
          selectedUserChampions.add(qiyasChampion);
        }
      }
    }
    return selectedUserChampions;
  }

  void removeSelectedVision({
    bool isVision = false,
    bool isTopic = false,
    bool isCriterion = false,
    bool isDocument = false,
    required String text,
  }) {
    if (isVision) {
      for (QiyasChampionEntity qiyasChampion in qiyasChampions) {
        if (qiyasChampion.controlChampion.toLowerCase().trim() ==
                personDetails!.id.toLowerCase().trim() &&
            getVisionNameByCriteriaId(qiyasChampion.criteriaId).trim() ==
                text.trim()) {
          stateChangedQiyasChampions.add(qiyasChampion);
        }
      }
    }
    if (isTopic) {
      for (QiyasChampionEntity qiyasChampion in qiyasChampions) {
        if (qiyasChampion.controlChampion.toLowerCase().trim() ==
                personDetails!.id.toLowerCase().trim() &&
            getTopicNameByCriteriaId(qiyasChampion.criteriaId).trim() ==
                text.trim()) {
          stateChangedQiyasChampions.add(qiyasChampion);
        }
      }
    }
    if (isCriterion) {
      for (QiyasChampionEntity qiyasChampion in qiyasChampions) {
        if (qiyasChampion.controlChampion.toLowerCase().trim() ==
                personDetails!.id.toLowerCase().trim() &&
            getCriteriaNameByCriteriaId(qiyasChampion.criteriaId).trim() ==
                text.trim()) {
          stateChangedQiyasChampions.add(qiyasChampion);
        }
      }
    }
    if (isDocument) {
      for (QiyasChampionEntity qiyasChampion in qiyasChampions) {
        if (qiyasChampion.controlChampion.toLowerCase().trim() ==
                personDetails!.id.toLowerCase().trim() &&
            getDocumentNumberById(
                        qiyasChampion.criteriaId, qiyasChampion.documentNumber)
                    .trim() ==
                text.trim()) {
          stateChangedQiyasChampions.add(qiyasChampion);
        }
      }
    }
    emit(VisionsDataChanged());
  }

  Future<void> saveEdits({required Function() onSuccess}) async {
    await deleteQiyasChampionList(stateChangedQiyasChampions.toList());
    await addQiyasChampion(onSuccess: onSuccess);
  }

  Future<void> reassignChampions({required Function() onSuccess}) async {
    List<QiyasChampionEntity> reassignedChampions = getReassignedChampions();
    await sl<QiyasChampionRepo>().deleteQiyasChampion(reassignedChampions);
    await addQiyasChampion(
        reassignedChampions: reassignedChampions, onSuccess: onSuccess);
    initCubit();
  }

  List<QiyasChampionEntity> getReassignedChampions() {
    List<QiyasChampionEntity> reassignedChampions = [];
    for (QiyasChampionEntity qiyasChampion in qiyasChampions) {
      if (qiyasChampion.controlChampion.toLowerCase().trim() ==
          personDetails!.id.toLowerCase().trim()) {
        if (!stateChangedQiyasChampions.contains(qiyasChampion)) {
          reassignedChampions.add(qiyasChampion);
        }
      }
    }
    return reassignedChampions;
  }

  @override
  List<String> getVisionNames(int addControllerIndex) {
    final QiyasHomeCubit qiyasHomeCubit = sl();

    List<String> visions = qiyasHomeCubit.uniqueVisionNames;
    List<String> filteredVisions = [];
    for (String vision in visions) {
      List<String> topicNames = getTopicNames(vision, addControllerIndex);
      if (topicNames.isNotEmpty) {
        filteredVisions.add(vision);
      }
    }
    return filteredVisions;
  }

  @override
  List<String> getTopicNames(String visionName, int addControllerIndex) {
    final QiyasHomeCubit qiyasHomeCubit = sl();
    List<String> topics = qiyasHomeCubit.getTopicNamesByVisionName(visionName);
    List<String> filteredTopics = [];

    for (String topic in topics) {
      List<String> criteriaNames = getCriterionNames(
          topicName: topic,
          visionName: visionName,
          addControllerIndex: addControllerIndex);
      if (criteriaNames.isNotEmpty) filteredTopics.add(topic);
    }
    return filteredTopics;
  }

  @override
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
        List<String> documentsName = getUnSelectedDocumentNames(
            criterionName: criterion,
            topicName: topicName,
            visionName: visionName,
            addControllerIndex: addControllerIndex);
        if (documentsName.isNotEmpty) {
          filteredCriteria.add(criterion);
        }
      }
    }
    return filteredCriteria;
  }

  /// function name: [getUnSelectedDocumentNames]
  ///
  /// purpose: Retrieves the names of the unselected documents associated with a specific criterion, topic, and vision.
  ///
  /// parameters:
  ///          [criterionName] String: The name of the criterion.
  ///          [topicName] String: The name of the topic.
  ///          [visionName] String: The name of the vision.
  ///
  /// return type: [List<String>] - A list of document names that are not selected for the given criterion, topic, and vision.
  @override
  List<String> getUnSelectedDocumentNames(
      {required String criterionName,
      required String topicName,
      required String visionName,
      required int addControllerIndex}) {
    QiyasHomeCubit qiyasHomeCubit = sl();
    List<String> documents = qiyasHomeCubit.getDocumentsNames(
        criterionName: criterionName,
        topicName: topicName,
        visionName: visionName);
    List<int> selectedDocumentsIndexs =
        getSelectedCriteriaSelectedDocumentsIndexs(
            criterionName: criterionName,
            topicName: topicName,
            visionName: visionName,
            addControllerIndex: addControllerIndex);

    List<String> filteredDocuments = [];
    for (int index = 0; index < documents.length; index++) {
      {
        if (!selectedDocumentsIndexs.contains(index)) {
          filteredDocuments.add(documents[index]);
        }
      }
    }
    return filteredDocuments;
  }

  /// function name: [getnSelectedDocumentNames]
  ///
  /// purpose: Retrieves the names of the unselected documents associated with a specific criterion, topic, and vision.
  ///
  /// parameters:
  ///          [criterionName] String: The name of the criterion.
  ///          [topicName] String: The name of the topic.
  ///          [visionName] String: The name of the vision.
  ///
  /// return type: [List<String>] - A list of document names that are not selected for the given criterion, topic, and vision.
  @override
  List<String> getDocumentNames(
      {required String criterionName,
      required String topicName,
      required String visionName}) {
    QiyasHomeCubit qiyasHomeCubit = sl();
    List<String> documents = qiyasHomeCubit.getDocumentsNames(
        criterionName: criterionName,
        topicName: topicName,
        visionName: visionName);

    List<String> filteredDocuments = [];
    for (int index = 0; index < documents.length; index++) {
      {
        filteredDocuments.add(documents[index]);
      }
    }
    return filteredDocuments;
  }

  /// function name: [getSelectedCriteriaSelectedDocumentsIndexs]
  ///
  /// purpose: Retrieves the indices of selected documents for a specific criterion, topic, and vision.
  ///
  /// parameters:
  ///           [criterionName] String: The name of the criterion.
  ///           [topicName] String: The name of the topic.
  ///           [visionName] String: The name of the vision.
  List<int> getSelectedCriteriaSelectedDocumentsIndexs(
      {required String criterionName,
      required String topicName,
      required String visionName,
      required int addControllerIndex}) {
    List<int> selectedDocumentsIndexs = [];
    QiyasHomeCubit qiyasHomeCubit = sl();
    String criteriaId = qiyasHomeCubit.getCriterionNumberByCriterionName(
        criteriaName: criterionName,
        topicName: topicName,
        visionName: visionName);
    for (QiyasChampionEntity championEntity in qiyasChampions) {
      if (championEntity.criteriaId == criteriaId) {
        selectedDocumentsIndexs.add(int.parse(championEntity.documentNumber));
      }
    }
    for (int i = 0; i < visionControllersList.length; i++) {
      if (i == addControllerIndex) continue;
      if (visionControllersList[i].text.trim() == visionName &&
          topicControllersList[i].text.trim() == topicName &&
          criterionControllersList[i].text.trim() == criterionName) {
        if (documentControllersList[i].text.isEmpty) continue;

        String documentIndex = getDocumentNumberOfIndex(i);
        selectedDocumentsIndexs.add(int.parse(documentIndex));
      }
    }
    return selectedDocumentsIndexs;
  }

  /// function name: [searchByName]
  ///
  /// purpose: Filters the employees based on the search query.
  ///          This function updates the displayed employees based on the user's search input.
  ///
  /// parameters:
  ///            [query] String: The search query entered by the user.
  /// function name: [searchByName]
  ///
  /// purpose: Filters the employees based on the search query.
  ///          This function updates the displayed employees based on the user's search input.
  ///
  /// parameters:
  ///            [query] String: The search query entered by the user.
  /// function name: [searchByName]
  ///
  /// purpose: Filters the employees based on the search query.
  ///          This function updates the displayed employees based on the user's search input.
  ///
  /// parameters:
  ///            [query] String: The search query entered by the user.
  void searchByName(String query, {bool removeChampions = true}) {
    debugPrint("🔍 Searching for employees with query: '$query'");

    final employeeController = Get.find<MainCoreEmployeeController>();
    final allEmployees = employeeController.allEmployeesEntities;

    if (allEmployees == null || allEmployees.isEmpty) {
      debugPrint("⚠️ No employees found in MainCoreEmployeeController");
      showEmployees = [];
      emit(OwnerDataChanged());
      return;
    }

    debugPrint("🔍 All employees count: ${allEmployees.length}");
    debugPrint("🔍 Current champions count: ${qiyasChampions.length}");

    showEmployees = [];

    if (query.trim().isEmpty) {
      // Show ALL employees when search is empty
      for (var employee in allEmployees) {
        // Skip employees with null or empty required fields
        if (employee.email == null ||
            employee.email!.isEmpty ||
            employee.firstNameInArabic == null ||
            employee.firstNameInArabic!.isEmpty) {
          debugPrint("⚠️ Skipping employee with missing data: ${employee.id}");
          continue;
        }

        if (removeChampions) {
          bool isChampion = qiyasChampions.any((champion) {
            return champion.controlChampion.toLowerCase().trim() ==
                employee.email!.toLowerCase().trim();
          });

          if (isChampion) {
            debugPrint(
                "Employee ${employee.email} is already a champion, skipping.");
            continue;
          }
        }

        try {
          showEmployees.add(QiyasPersonEntity.fromEmployeeEntity(employee));
        } catch (e) {
          debugPrint("⚠️ Error converting employee ${employee.id}: $e");
          continue;
        }
      }
    } else {
      // Filter employees by search query
      final lowerQuery = query.toLowerCase();

      for (var employee in allEmployees) {
        // Skip employees with null or empty required fields
        if (employee.email == null ||
            employee.email!.isEmpty ||
            employee.firstNameInArabic == null ||
            employee.firstNameInArabic!.isEmpty) {
          continue;
        }

        final firstName = employee.firstNameInArabic?.toLowerCase() ?? '';
        final lastName = employee.lastNameInArabic?.toLowerCase() ?? '';
        final jobTitle = employee.titleInArabic?.toLowerCase() ?? '';

        if (removeChampions) {
          bool isChampion = qiyasChampions.any((champion) =>
              champion.controlChampion.toLowerCase().trim() ==
              employee.email!.toLowerCase().trim());

          if (isChampion) {
            continue;
          }
        }

        if (firstName.contains(lowerQuery) ||
            lastName.contains(lowerQuery) ||
            jobTitle.contains(lowerQuery)) {
          try {
            showEmployees.add(QiyasPersonEntity.fromEmployeeEntity(employee));
          } catch (e) {
            debugPrint("⚠️ Error converting employee ${employee.id}: $e");
            continue;
          }
        }
      }
    }

    debugPrint("🔍 Final showEmployees count: ${showEmployees.length}");

    emit(OwnerDataChanged());
  }
}
