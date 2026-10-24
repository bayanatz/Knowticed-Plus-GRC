import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/controller/qiyas_home_cubit.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';

part 'vision_details_state.dart';

class VisionDetailsCubit extends Cubit<VisionDetailsState> {
  VisionDetailsCubit() : super(VisionDetailsInitial());
  var isExpanded = true;
  List<String> selectedVisionTopics = [];
  List<String> selectedTopicCriteria = [];

  var isExpandedDetailsMap = {};
  int selectedQiyasScreenIndex = 0;
  String? selectedVisionName;
  String? selectedTopicName;

  /// function name: [updateSelectedQiyasScreenIndex]
  ///
  /// purpose: Updates the index of the selected Qiyas screen and triggers a ui refresh.
  ///          This function is called when the user selects a different screen index in the Qiyas vision details.
  ///
  /// parameters:
  ///            [value] int: the new index value for the selected Qiyas screen.
  ///
  /// return type: [void]
  void updateSelectedQiyasScreenIndex(int value) {
    selectedQiyasScreenIndex = value;
    selectedTopicName = selectedVisionTopics[value];
    getCriteria();
    emit(UpdateSelectedTopic());
  }

  /// function name: [updateSelectedQiyasScreenIndex]
  ///
  /// purpose: Updates the index of the selected Qiyas screen and triggers a ui refresh.
  ///          This function is called when the user selects a different screen index in the Qiyas vision details.
  ///
  /// parameters:
  ///            [value] int: the new index value for the selected Qiyas screen.
  ///
  /// return type: [void]
  void updateSelectedCriteriaIndex(int value) {
    selectedQiyasScreenIndex = value;
    getCriteria();
    emit(UpdateSelectedTopic());
  }

  /// function name: [toggleExpanded]
  ///
  /// purpose: Toggles the expansion state of the general vision details section.
  ///          This function is used to expand or collapse the entire section.
  ///
  /// parameters: None
  ///
  /// return type: [void]
  void toggleExpanded() {
    isExpanded = !isExpanded;
    emit(VisonOverViewAppearanceState());
  }

  /// function name: [toggleExpandedDetails]
  ///
  /// purpose: Toggles the expansion state of a specific vision details section identified by the provided index.
  ///          This function is used to expand or collapse individual sections within the Qiyas document.
  ///
  /// parameters:
  ///            [index] int: the index of the section whose expansion state should be toggled.
  ///
  /// return type: [void]
  void toggleExpandedDetails(int index) {
    if (!isExpandedDetailsMap.containsKey(index)) {
      isExpandedDetailsMap[index] = false;
    }
    isExpandedDetailsMap[index] = !isExpandedDetailsMap[index]!;
    emit(VisonDetailsAppearanceState());
  }

  /// function name: [getTopics]
  ///
  /// purpose: Retrieves the topic names associated with the selected vision.
  void getTopics() {
    QiyasHomeCubit controller = sl();
    selectedVisionTopics =
        controller.getTopicNamesByVisionName(selectedVisionName!);
    // Default to the first topic if available
  }

  /// function name: [selectVision]
  ///
  /// purpose: Selects a vision by its name and retrieves the associated topics.
  void selectVision(String visionName) {
    selectedVisionName = visionName;
    getTopics();
    selectedTopicName =
        selectedVisionTopics.isNotEmpty ? selectedVisionTopics.first : null;
    getCriteria();
  }

  /// function name: [selectTopic]
  ///
  /// purpose: Selects a vision by its name and retrieves the associated topics.
  void selectTopic(String visionName, String topicName) {
    selectedVisionName = visionName;
    selectedTopicName = topicName;
    getCriteria();
  }

  /// function name: [getCriteria]
  ///
  /// purpose: Retrieves the criteria names associated with the selected vision and topic.
  void getCriteria() {
    QiyasHomeCubit controller = sl();
    selectedTopicCriteria = controller.getCriteriaNames(
        visionName: selectedVisionName!, topicName: selectedTopicName!);
    debugPrint("Selected Topic Criteria: $selectedTopicCriteria");
  }

  String getCriteriaNumber(String criteria) {
    QiyasHomeCubit controller = sl();
    return controller.getCriterionNumberByCriterionName(
        visionName: selectedVisionName!,
        topicName: selectedTopicName!,
        criteriaName: criteria);
  }

  /// function name: [getCriteriaDetails]
  ///
  /// purpose: Retrieves the details of a specific criterion based on its name.
  ///
  /// parameters:
  ///           [criteria] String: The name of the criterion for which details are to be retrieved.
  ///
  /// return type: [List<String>]

  List<String> getCriteriaDetails(String criteria) {
    QiyasHomeCubit controller = sl();
    return controller.getCriterionDetailsByCriterionName(
        visionName: selectedVisionName!,
        topicName: selectedTopicName!,
        criteriaName: criteria);
  }

  void restartVisionDetails() {
    isExpanded = false;
    selectedVisionTopics = [];
    selectedTopicCriteria = [];
    isExpandedDetailsMap = {};
    selectedQiyasScreenIndex = 0;
    selectedVisionName = null;
    selectedTopicName = null;
  }

  List<String> getDocuments() {
    debugPrint(
        "enter get documents for vision names: $selectedQiyasScreenIndex");
    QiyasHomeCubit controller = sl();
    List<String> documents = controller.getDocumentsNames(
        criterionName: selectedTopicCriteria[selectedQiyasScreenIndex],
        topicName: selectedTopicName!,
        visionName: selectedVisionName!);
    debugPrint("deocumnts: $documents");
    return documents;
  }
}
