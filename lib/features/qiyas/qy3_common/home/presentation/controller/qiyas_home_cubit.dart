import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/visions.dart';

import 'package:knowticed_plus/features/qiyas/helpers/constant/qiyas_table_headers.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/csv_helper.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/uploaded_data_formatter.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/utils/headers_enum.dart';

part 'qiyas_home_state.dart';

class QiyasHomeCubit extends Cubit<QiyasHomeState> {
  int maxNumberOfTopics = 0;
  QiyasHomeCubit() : super(QiyasHomeInitial());
  List<String> uniqueVisionNames = [];

  bool isEmptyVisions = true;
  int selectedQiyasScreenIndex = 0;
  bool isTabsSelected = true;
  List<Visions> visionsList = [];
  List<Visions> filteredVisionsList = [];

  TextEditingController visionName = TextEditingController();

  void getVisions(List<Visions> visions) {
    visionsList = [];
    for (var vision in visions) {
      visionsList.add(vision);
    }
    filteredVisionsList = List.from(visionsList);
    isEmptyVisions = visionsList.isEmpty;
    // print("vision list is ${visionsList.length}");

    // criteria number is written in the format "1.1.1" or "2.3.4" sort accordingly
    visionsList.sort((a, b) {
      // print("home topic numbers are ${a.topicNumber} and ${b.topicNumber}");
      //  print(a.criterionNumber);
      List<int> aParts =
          a.criterionNumber.split('.').map((e) => int.parse(e.trim())).toList();
      List<int> bParts = b.criterionNumber.split('.').map(int.parse).toList();

      for (int i = 0; i < min(aParts.length, bParts.length); i++) {
        if (aParts[i] != bParts[i]) {
          return aParts[i].compareTo(bParts[i]);
        }
      }
      return aParts.length.compareTo(bParts.length);
    });
    extractUniqueVisionNames();
    getMaxNumberOfTopics();
    emit(QiyasVisionsGet());
  }

  void filterVisions() {
    String searchText = visionName.text.toLowerCase();
    filteredVisionsList = visionsList.where((vision) {
      return vision.visionName.contains(searchText);
    }).toList();
    emit(QiyasVisionsFiltered());
  }

  /// function name: [updateSelectedQiyasScreenIndex]
  ///
  /// purpose: Updates the index of the selected Qiyas screen and triggers a ui refresh.
  ///          This function is used to change the current active screen when the user selects a different screen.
  ///
  /// parameters:
  ///            [value] int: the new index for the selected Qiyas screen.
  ///
  /// return type: [void]
  void updateSelectedQiyasScreenIndex(int value) {
    selectedQiyasScreenIndex = value;
    emit(QiyasScreenIndexUpdated());
  }

  /// function name: [isTabsSelectedState]
  ///
  /// purpose: Updates the state of whether the tabs are selected or not.
  ///          This function is used to toggle between tabs when a user interacts with the tab selection.
  ///
  /// parameters:
  ///            [value] bool: the state of whether tabs should be selected (true/false).
  ///
  /// return type: [void]
  void isTabsSelectedState(bool value) {
    isTabsSelected = value;
    emit(QiyasTabSelected());
  }

  /// function name: [extractUniqueVisionNames]
  ///
  /// purpose: Extracts unique vision names from the Firestore data to avoid duplicates.
  ///
  /// parameters: None
  ///
  /// return type: [void]
  void extractUniqueVisionNames() {
    final visionNamesSet = <String>{};

    for (var vision in visionsList) {
      if (vision.visionName.isNotEmpty) {
        final cleanedName = vision.visionName.trim();
        visionNamesSet.add(cleanedName);
      }
    }
    uniqueVisionNames = visionNamesSet.toList();
  }

  /// function name: [getTopicNamesByVisionName]
  ///
  /// purpose: Retrieves all topic names associated with a specific vision name.
  ///
  /// parameters:
  ///            [targetVisionName] String: The name of the vision to search for.
  ///
  /// return type: [List<String>]
  List<String> getTopicNamesByVisionName(String targetVisionName) {
    final topicNamesSet = <String>{};
    final cleanedTarget = targetVisionName.trim();

    for (var vision in visionsList) {
      final cleanedVisionName = vision.visionName.trim();
      if (cleanedVisionName == cleanedTarget && vision.visionName.isNotEmpty) {
        topicNamesSet.add(vision.topicName.trim());
      }
    }
    return topicNamesSet.toList();
  }

  /// function name: [getCriteriaNames]
  ///
  /// purpose: Retrieves all criteria names associated with a specific vision and topic.
  ///
  /// parameters:
  ///           [visionName] String: The name of the vision to search for.
  List<String> getCriteriaNames(
      {required String visionName, required String topicName}) {
    final criteriaNamesSet = <String>{};

    for (var vision in visionsList) {
      if (vision.visionName.trim() == visionName.trim() &&
          vision.topicName.trim() == topicName.trim()) {
        String cleanedCriterionName = vision.criterionName.trim();
        if (cleanedCriterionName.isNotEmpty) {
          criteriaNamesSet.add(cleanedCriterionName);
        }
      }
    }
    return criteriaNamesSet.toList();
  }

  /// function name: [getUnSelectedDocumentNames]
  ///
  /// purpose: Retrieves all document names associated with a specific criterion, topic, and vision.
  List<String> getDocumentsNames(
      {required String criterionName,
      required String topicName,
      required String visionName}) {
    final documentNamesSet = <String>{};
    for (var vision in visionsList) {
      if (vision.visionName.trim() == visionName.trim() &&
          vision.topicName.trim() == topicName.trim() &&
          vision.criterionName.trim() == criterionName.trim()) {
        String documentName = vision.documents;
        documentName.replaceAll('{', "");
        List<String> documents = documentName.split("}");
        for (var document in documents) {
          if (document.isNotEmpty) {
            documentNamesSet
                .add(document.trim().replaceAll('}', '').replaceAll('{', ''));
          }
        }
        return documentNamesSet.toList();
      }
    }

    return [];
  }

  /// function name: [getMaxNumberOfTopics]
  ///
  /// purpose: Calculates the maximum number of topics across all unique vision names.
  void getMaxNumberOfTopics() {
    maxNumberOfTopics = 0;
    for (var visionName in uniqueVisionNames) {
      final topicNames = getTopicNamesByVisionName(visionName);
      maxNumberOfTopics = max(maxNumberOfTopics, topicNames.length);
    }
  }

  /// function name: [getCriterionNamesByTopicName]
  ///
  /// purpose: Retrieves all criterion names associated with a specific topic name.
  ///
  /// parameters:
  ///            [visionName] String: The name of the topic to search for.
  ///            [topicName] String: The name of the topic to search for.
  ///
  /// return type: [List<String>]
  List<String> getTopicCriteria(
      {required String visionName, required String topicName}) {
    final criterionNamesSet = <String>{};
    for (var vision in visionsList) {
      if (vision.visionName == visionName && vision.topicName == topicName) {
        String cleanedCriterionName = vision.criterionName.trim();
        if (cleanedCriterionName.isNotEmpty) {
          criterionNamesSet.add(cleanedCriterionName);
        }
      }
    }
    return criterionNamesSet.toList();
  }

  /// function name: [getCriterionNumberByCriterionName]
  ///
  /// purpose: Retrieves the criterion number for a given criterion name.
  ///
  /// parameters:
  ///            [targetCriterionName] String: The name of the criterion to search for.
  ///
  /// return type: [String]
  String getCriterionNumberByCriterionName({
    required String visionName,
    required String topicName,
    required String criteriaName,
  }) {
    debugPrint("criteria name for number search is $criteriaName");
    for (var vision in visionsList) {
      if (visionName.trim() == vision.visionName.trim() &&
          topicName == vision.topicName.trim() &&
          criteriaName.trim() == vision.criterionName.trim()) {
        debugPrint("found Criteria Number: ${vision.criterionNumber}");
        return vision.criterionNumber.trim();
      }
    }
    return "";
  }

  /// function name: [getCriterionDetailsByCriterionName]
  ///
  /// purpose: Retrieves details (goals, requirements, etc.) for a specific criterion.
  ///
  /// parameters:
  ///            [targetCriterionName] String: The name of the criterion to search for.
  ///
  /// return type: [List<String>]
  List<String> getCriterionDetailsByCriterionName({
    required String visionName,
    required String topicName,
    required String criteriaName,
  }) {
    final criterionDetailsSet = <String>{};
    final cleanedTarget = criteriaName.trim();
    for (var vision in visionsList) {
      if (vision.topicName.isNotEmpty) {
        final cleanedCriterionName =
            vision.criterionName.trim().replaceAll(RegExp(r'\s+'), ' ');

        if (cleanedCriterionName == cleanedTarget &&
            vision.criterionName.isNotEmpty) {
          criterionDetailsSet.add(criteriaName);
          criterionDetailsSet.add(vision.goal.trim());
          criterionDetailsSet.add(UploadedDataFormatter.formatCustomText(
              vision.requirements.trim()));
          criterionDetailsSet.add(
              UploadedDataFormatter.formatCustomText(vision.documents.trim()));
          criterionDetailsSet.add(
              UploadedDataFormatter.formatCustomText(vision.orders..trim()));
          criterionDetailsSet.add(vision.scope.trim());
        }
      }
    }
    return criterionDetailsSet.toList();
  }

  /// function name: [calculateWidthOfColum]
  ///
  /// purpose: Calculates the maximum width of a column based on the content of the visions.
  ///  parameters:
  ///             [header] HeadersEnum: The header for which the width is being calculated.
  ///            [context] BuildContext: The context in which the width is being calculated.
  ///
  ///  return type: [int]

  double calculateWidthOfColum(HeadersEnum header, BuildContext context) {
    double maxLength = 0;
    for (var vision in visionsList) {
      switch (header) {
        case HeadersEnum.criterionNumber:
          maxLength = max(maxLength, vision.criterionNumber.length * 1.0);
        case HeadersEnum.description:
          {}
        /*  maxLength = max(maxLength, vision.description.length * 1.0);*/
        case HeadersEnum.visionName:
          maxLength = max(maxLength, vision.visionName.length * 1.0);
        case HeadersEnum.topicName:
          maxLength = max(maxLength, vision.topicName.length * 1.0);
        case HeadersEnum.criterionName:
          maxLength = max(maxLength, vision.criterionName.length * 1.0);
        case HeadersEnum.goals:
          maxLength = max(maxLength, vision.goal.length * 1.0);
        case HeadersEnum.appRequirements:
          maxLength = max(maxLength, vision.requirements.length * 1.0);
        case HeadersEnum.evidence:
          maxLength = max(maxLength, vision.documents.length * 1.0);
        case HeadersEnum.orders:
          maxLength = max(maxLength, vision.orders.length * 1.0);
        case HeadersEnum.scope:
          maxLength = max(maxLength, vision.scope.length * 1.0);
        case HeadersEnum.topicNumber:
          maxLength = max(maxLength, vision.topicNumber.length * 1.0);
      }
    }
    if (context.isPortrait) return min((maxLength * 14.sp) / 2, 300.w);
    double result = min((maxLength * 14.sp) / 2, 400.w);
    if (result == 0) return 200.sp;
    return result; // Return the calculated width based on the maximum length
    // Default width if no match found
  }

  String getTopicNumberByVisionAndTopicName(
      String topicName, String visionName) {
    debugPrint('\n🔍 getTopicNumberByVisionAndTopicName CALLED:');
    debugPrint('   Input Vision: "$visionName"');
    debugPrint('   Input Topic: "$topicName"');

    for (var vision in visionsList) {
      if (vision.visionName.trim() == visionName.trim() &&
          vision.topicName.trim() == topicName.trim()) {
        String topicNumber = vision.topicNumber.trim();
        debugPrint('   ✅ FOUND Topic Number: "$topicNumber"');
        return topicNumber;
      }
    }

    debugPrint('   ❌ NOT FOUND - No match!');
    debugPrint('   Available visions in list:');
    for (var vision in visionsList.take(3)) {
      debugPrint(
          '      - Vision: "${vision.visionName.trim()}", Topic: "${vision.topicName.trim()}", Number: "${vision.topicNumber.trim()}"');
    }

    return ''; // Return empty if no match found
  }

  void exportFile(String fileName) {
    List<String> headers = [];

    headers.addAll(qiyasTableHeaders);
    headers.removeAt(0);
    List<List<String>> data = [];
    for (var vision in filteredVisionsList) {
      List<String> row = [];
      row.add(vision.visionName);
      row.add(vision.topicName);
      row.add(vision.criterionName);
      row.add(vision.goal);
      row.add(UploadedDataFormatter.formatCustomText(vision.requirements));
      row.add(UploadedDataFormatter.formatCustomText(vision.documents));
      row.add(UploadedDataFormatter.formatCustomText(vision.orders));
      row.add(UploadedDataFormatter.formatCustomText(vision.scope));
      data.add(row);
    }
    List<List<dynamic>> formattedData = [];
    formattedData.add(headers.reversed.toList());
    for (var row in data) {
      formattedData.add(row.reversed.toList());
    }

    if (data.isNotEmpty) {
      CSVHelper().exportToCSV(formattedData, fileName);
    }
  }

  String getVisionName(String criteriaNumber) {
    for (var vision in visionsList) {
      if (vision.criterionNumber.trim() == criteriaNumber.trim()) {
        return vision.visionName.trim();
      }
    }
    return "";
  }

  String getTopicName(String criteriaNumber) {
    for (var vision in visionsList) {
      if (vision.criterionNumber.trim() == criteriaNumber.trim()) {
        return vision.topicName.trim();
      }
    }
    return "";
  }

  String getCriteriaName(String criteriaNumber) {
    for (var vision in visionsList) {
      if (vision.criterionNumber.trim() == criteriaNumber.trim()) {
        return vision.criterionName.trim();
      }
    }
    return "";
  }
}
