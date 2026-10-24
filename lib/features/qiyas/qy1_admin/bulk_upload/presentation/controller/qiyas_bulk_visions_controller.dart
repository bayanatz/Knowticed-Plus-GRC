/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_bulk_visions_controller.dart
/// Purpose: Manages state and logic for Qiyas bulk vision upload feature.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This controller handles CSV parsing, validation, and Firestore
///              integration for bulk uploading Qiyas vision data. It provides
///              methods for reading existing data, extracting related fields
///              (vision, topics, criteria), managing form states, and
///              performing insertions to the backend.
/// ********************************************************************* ///
library;

import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/core/modules/text_header_data.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/visions.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/presentation/controller/qiyas_vision_bulk_data_handler.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/controller/qiyas_home_cubit.dart';

import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/core/enums/csv_status.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/core/modules/text_form_field_data.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/core/modules/text_form_field_error.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/qiyas_order_of_vision_columns.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/uploaded_data_formatter.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/data/models/vision_firestore.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/domain/use_cases/create_vision_usecase.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/domain/use_cases/read_all_vision_usecase.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/api_constant.dart';

class QiyasBulkVisionsController extends GetxController {
  TextEditingController visionName = TextEditingController();
  TextEditingController topicName = TextEditingController();
  TextEditingController topicNumber = TextEditingController();
  TextEditingController criterionName = TextEditingController();
  TextEditingController criterionNumber = TextEditingController();
  TextEditingController goal = TextEditingController();
  TextEditingController requirements = TextEditingController();
  TextEditingController documents = TextEditingController();
  TextEditingController orders = TextEditingController();
  TextEditingController scope = TextEditingController();
  QiyasVisionBulkDataHandler dataHandler = QiyasVisionBulkDataHandler();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<List<dynamic>> fileData = [];
  List<TextFormFieldError> errors = [];
  late List<List<TextFormFieldData>> textFormFieldData;
  String? filePath;
  late List<TextHeaderData> textHeaderData;
  RxInt errorIndexNavigation = 0.obs;
  List<List<dynamic>> visionData = [];
  String errorMassage = '';
  List<VisionModel> visionsFromFirestore = [];
  var vision = <Visions>[].obs;
  List<Visions> showVisions = [];
  List<String> uniqueVisionNames = [];
  bool theTextFormFielsHasError = false;
  Color borderColor = AppColors.grey;
  ScrollController scrollController = ScrollController();
  var selectedRows = <int>[].obs;

  /// function name: [onInit]
  ///
  /// purpose: Initializes the controller by fetching data from Firestore, processing it,
  ///          and preparing the vision list for display.
  ///
  /// parameters: None
  ///
  /// return type: [void]
  @override
  void onInit() {
    readDataFromFirestore();
    super.onInit();
  }

  final LiveRefresh _live = LiveRefresh();

  @override
  void onClose() {
    _live.dispose();
    super.onClose();
  }

  /// function name: [extractUniqueVisionNames]
  ///
  /// purpose: Extracts unique vision names from the Firestore data to avoid duplicates.
  ///
  /// parameters: None
  ///
  /// return type: [void]
  /// Todo: to be removed
  void extractUniqueVisionNames() {
    final visionNamesSet = <String>{};

    for (var vision in visionsFromFirestore) {
      if (vision.visionName.isNotEmpty) {
        final cleanedName = vision.visionName.last.trim();
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
    final cleanedTarget =
        targetVisionName.trim().replaceAll(RegExp(r'\s+'), ' ');

    for (var vision in visionsFromFirestore) {
      if (vision.visionName.isNotEmpty) {
        final cleanedVisionName =
            vision.visionName.last.trim().replaceAll(RegExp(r'\s+'), ' ');

        if (cleanedVisionName == cleanedTarget && vision.topicName.isNotEmpty) {
          topicNamesSet.add(vision.topicName.last.trim()); // ممكن كمان ننضف هنا
        }
      }
    }
    return topicNamesSet.toList();
  }

  /// function name: [getCriterionNamesByTopicName]
  ///
  /// purpose: Retrieves all criterion names associated with a specific topic name.
  ///
  /// parameters:
  ///            [targetTopicName] String: The name of the topic to search for.
  ///
  /// return type: [List<String>]
  List<String> getCriterionNamesByTopicName(String targetTopicName) {
    final criterionNamesSet = <String>{};
    final cleanedTarget =
        targetTopicName.trim().replaceAll(RegExp(r'\s+'), ' ');
    for (var vision in visionsFromFirestore) {
      if (vision.topicName.isNotEmpty) {
        final cleanedVisionName =
            vision.topicName.last.trim().replaceAll(RegExp(r'\s+'), ' ');

        if (cleanedVisionName == cleanedTarget &&
            vision.criterionName.isNotEmpty) {
          criterionNamesSet.add(vision.criterionName.last.trim());
        }
      }
    }
    return criterionNamesSet.toList();
  }

  List<String> getDocumentsNamByCriterionName(String targetCriterionName) {
    final documentNamesSet = <String>{};
    final cleanedTarget =
        targetCriterionName.trim().replaceAll(RegExp(r'\s+'), ' ');
    for (var vision in visionsFromFirestore) {
      if (vision.criterionName.isNotEmpty) {
        final cleanedVisionName =
            vision.criterionName.last.trim().replaceAll(RegExp(r'\s+'), ' ');

        if (cleanedVisionName == cleanedTarget &&
            vision.evidenceDocuments.isNotEmpty) {
          String documentName = vision.evidenceDocuments.last.trim();
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
    }
    return [];
  }

  /// function name: [getSpecificCriterionNamesByTopicName]
  ///
  /// purpose: Retrieves a specific criterion name for a given topic name.
  ///
  /// parameters:
  ///            [targetTopicName] String: The name of the topic to search for.
  ///
  /// return type: [String]
  String getSpecificCriterionNamesByTopicName(String targetTopicName) {
    String criterionNamesSet = "";
    final cleanedTarget =
        targetTopicName.trim().replaceAll(RegExp(r'\s+'), ' ');

    for (var vision in visionsFromFirestore) {
      if (vision.topicName.isNotEmpty) {
        final cleanedVisionName =
            vision.topicName.last.trim().replaceAll(RegExp(r'\s+'), ' ');

        if (cleanedVisionName == cleanedTarget &&
            vision.criterionName.isNotEmpty) {
          criterionNamesSet = vision.criterionName.last.trim();
        }
      }
    }
    return criterionNamesSet;
  }

  /// function name: [getCriterionDetailsByCriterionName]
  ///
  /// purpose: Retrieves details (goals, requirements, etc.) for a specific criterion.
  ///
  /// parameters:
  ///            [targetCriterionName] String: The name of the criterion to search for.
  ///
  /// return type: [List<String>]
  List<String> getCriterionDetailsByCriterionName(String targetCriterionName) {
    final criterionDetailsSet = <String>{};
    final cleanedTarget =
        targetCriterionName.trim().replaceAll(RegExp(r'\s+'), ' ');

    for (var vision in visionsFromFirestore) {
      if (vision.topicName.isNotEmpty) {
        final cleanedCriterionName =
            vision.criterionName.last.trim().replaceAll(RegExp(r'\s+'), ' ');

        if (cleanedCriterionName == cleanedTarget &&
            vision.criterionName.isNotEmpty) {
          criterionDetailsSet.add(targetCriterionName);
          criterionDetailsSet.add(vision.goals.last.trim());
          criterionDetailsSet.add(UploadedDataFormatter.formatCustomText(
              vision.appRequirements.last.trim()));
          criterionDetailsSet.add(UploadedDataFormatter.formatCustomText(
              vision.evidenceDocuments.last.trim()));
          criterionDetailsSet.add(UploadedDataFormatter.formatCustomText(
              vision.ordersDecisionsAndCirculars.last.trim()));
          criterionDetailsSet.add(vision.scope.last.trim());
        }
      }
    }
    return criterionDetailsSet.toList();
  }

  /// function name: [getCriterionNumberByCriterionName]
  ///
  /// purpose: Retrieves the criterion number for a given criterion name.
  ///
  /// parameters:
  ///            [targetCriterionName] String: The name of the criterion to search for.
  ///
  /// return type: [String]
  String getCriterionNumberByCriterionName(String targetCriterionName) {
    String criterionNumberSet = '';
    final cleanedTarget =
        targetCriterionName.trim().replaceAll(RegExp(r'\s+'), ' ');

    for (var vision in visionsFromFirestore) {
      if (vision.topicName.isNotEmpty) {
        final cleanedCriterionName =
            vision.criterionName.last.trim().replaceAll(RegExp(r'\s+'), ' ');

        if (cleanedCriterionName == cleanedTarget &&
            vision.criterionName.isNotEmpty) {
          criterionNumberSet = vision.criterionNumber.last.trim();
        }
      }
    }
    return criterionNumberSet;
  }

  /// function name: [getVisions]
  ///
  /// purpose: Filters and returns visions that match the specified vision name.
  ///
  /// parameters:
  ///            None
  ///
  /// return type: [Future<List<Visions>>]
  Future<List<Visions>> getVisions() async {
    return vision
        .where((vision) => vision.visionName == visionName.text)
        .toList();
  }

  /// function name: [readDataFromFirestore]
  ///
  /// purpose: Fetches vision data from Firestore and processes it for use in the app.
  ///
  /// parameters: None
  ///
  /// return type: [Future<void>]
//   Future<void> readDataFromFirestore() async {
//     final data = await sl<ReadAllVisionUsecase>().execute();
//     data.fold(
//       (l) => errorMassage = l.message,
//       (r) {
//         visionsFromFirestore = r;
//         vision.value = visionsFromFirestore
//             .map((vision) => Visions.visionFireBasetoEntity(vision))
//             .toList();
//         vision.value
//             .sort((a, b) => a.criterionNumber!.compareTo(b.criterionNumber!));
//         extractUniqueVisionNames();
//         showVisions = vision.value;
//      //   print("show visionsList length: ${showVisions.length}");
// /*      Get.find<QiyasHomeController>().isEmptyVisions =
//           visionsData.isEmpty; // Update the home controller's state*/
//
//        // print("database visionsList length: ${vision.value.length}");
//         update();
//         List<Visions> newVisions = vision.value
//             .where((vision) => vision.visionName.isNotEmpty)
//             .toList();
//         newVisions.removeLast();
//         sl<QiyasHomeCubit>().getVisions(newVisions);
//       },
//     );
//   }

  Future<void> readDataFromFirestore() async {
    try {
      debugPrint('🔭 [Visions] readDataFromFirestore() START');
      final data = await sl<ReadAllVisionUsecase>().execute();
      if (isClosed) return;
      data.fold(
        (l) {
          errorMassage = l.message;
          debugPrint(
              '🔭 [Visions] execute() returned Left (error): ${l.message}');
        },
        (r) {
          debugPrint(
              '🔭 [Visions] execute() returned Right with ${r.length} items');
          visionsFromFirestore = r;
          // Sorted before it goes into the Rx list (its `value` getter is
          // protected); showVisions shares the same list, as before.
          final List<Visions> loadedVisions = visionsFromFirestore
              .map((vision) => Visions.visionFireBasetoEntity(vision))
              .toList()
            ..sort((a, b) => (a.criterionNumber).compareTo(b.criterionNumber));
          vision.value = loadedVisions;
          extractUniqueVisionNames();
          showVisions = loadedVisions;
          update();
          // Keep the Visions list/home screen live after any add/edit/delete.
          _live.watchPaths(
            [getBaseUrl(ApiConstant.kVisionNameCollection)],
            readDataFromFirestore,
          );

          // Filter visions with valid names
          List<Visions> newVisions = loadedVisions
              .where((vision) => vision.visionName.isNotEmpty)
              .toList();

          debugPrint(
              '🔭 [Visions] newVisions count (after filter): ${newVisions.length}');

          // Feed data to QiyasHomeCubit
          if (sl.isRegistered<QiyasHomeCubit>()) {
            final cubit = sl<QiyasHomeCubit>();
            if (!cubit.isClosed) {
              // removeLast() strips the trailing blank/header row in the CSV data
              final List<Visions> visionsToPass = newVisions.isNotEmpty
                  ? (List.from(newVisions)..removeLast())
                  : [];
              debugPrint(
                  '🔭 [Visions] calling getVisions() with ${visionsToPass.length} items');
              cubit.getVisions(visionsToPass);
            } else {
              debugPrint(
                  '⚠️ [Visions] QiyasHomeCubit is closed, skipping getVisions');
            }
          } else {
            debugPrint('⚠️ [Visions] QiyasHomeCubit not registered in sl');
          }
        },
      );
    } catch (e, stack) {
      debugPrint('🔴 [Visions] readDataFromFirestore() EXCEPTION: $e');
      debugPrint('🔴 [Visions] Stack: $stack');
    }
  }

  /// function name: [pickFile]
  ///
  /// purpose: Opens a file picker to select a CSV file, parses it, and stores the data.
  ///
  /// parameters: None
  ///
  /// return type: [Future<void>]
  //  Future<void> pickFile() async {
  //    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
  //    if (result == null) return;
  // //   print(result.files.first.name);
  //    filePath = result.files.first.path!;
  //
  //    final input = File(filePath!).openRead();
  //    final fields = await input
  //        .transform(utf8.decoder)
  //        .transform(const CsvToListConverter())
  //        .toList();
  //    fields.reversed;
  //    visionData = fields.map((innerList) => List.from(innerList)).toList();
  //
  //    textHeaderData = List.generate(
  //        fields[0].length,
  //        (index) => TextHeaderData(
  //            columnName: fields[0][index].toString(), focusNode: FocusNode()));
  //
  //    fields.removeAt(0);
  //
  //    textFormFieldData = List.generate(
  //        fields.length,
  //        (i) => List.generate(
  //            fields[i].length,
  //            (j) => TextFormFieldData(
  //                focusNode: FocusNode(),
  //                border: Colors.transparent,
  //                textFormFieldControllers:
  //                    TextEditingController(text: fields[i][j].toString()),
  //                fieldKeys: GlobalKey<FormFieldState>())));
  //  }

  /// Fixed pickFile method with proper UTF-8 encoding handling
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) return;

    filePath = result.files.first.path!;

    try {
      // ✅ Read the file as bytes first
      final file = File(filePath!);
      final bytes = await file.readAsBytes();

      // ✅ Decode with allowMalformed to handle encoding issues
      final String csvString = utf8.decode(bytes, allowMalformed: true);

      // ✅ Parse the CSV string
      final fields = Csv(autoDetect: false).decode(csvString);

      // ✅ Validate that we have data
      if (fields.isEmpty) {
        Get.snackbar(
          'Error',
          'The CSV file is empty',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // ✅ Validate that we have headers
      if (fields[0].isEmpty) {
        Get.snackbar(
          'Error',
          'The CSV file has no headers',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      visionData = fields.map((innerList) => List.from(innerList)).toList();

      textHeaderData = List.generate(
          fields[0].length,
          (index) => TextHeaderData(
              columnName: fields[0][index].toString(), focusNode: FocusNode()));

      fields.removeAt(0);

      textFormFieldData = List.generate(
          fields.length,
          (i) => List.generate(
              fields[i].length,
              (j) => TextFormFieldData(
                  focusNode: FocusNode(),
                  border: Colors.transparent,
                  textFormFieldControllers:
                      TextEditingController(text: fields[i][j].toString()),
                  fieldKeys: GlobalKey<FormFieldState>())));

      debugPrint('✅ CSV file loaded successfully: ${fields.length} rows');
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing CSV: $e');
      debugPrint('Stack trace: $stackTrace');

      Get.snackbar(
        'Error',
        'Failed to parse CSV file. Please ensure it is properly formatted.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    }
  }

  /// function name: [clearData]
  ///
  /// purpose: Clears all the vision data and updates the ui.
  ///          This method interacts with the data handler to reset the data.
  ///
  /// parameters: None
  ///
  /// return type: [void]
  void clearData() {
    //  dataHandler.clearVisionData(this);
    update();
  }

  /// function name: [validateAllControls]
  ///
  /// purpose: Validates all the controls in the form by checking if the form is valid.
  ///          It uses the `formKey` to validate the form state.
  ///
  /// parameters: None
  ///
  /// return type: [bool]
  ///             - Returns true if the form is valid, otherwise false.
  bool validateAllControls() {
    return formKey.currentState?.validate() ?? false;
  }

  /// function name: [validateInvalidColumnHeaders]
  ///
  /// purpose: Validates the column headers in the CSV file to ensure they match the required order.
  ///          If a header is invalid, it adds an error to the list of errors with the corresponding column details.
  ///
  /// parameters:
  ///            - [fields] List`<List<dynamic>`>: The CSV data to validate.
  ///            - [csvStatus] CsvStatus: The current status of the CSV (used to manage error states).
  ///
  /// return type: [void]
  void validateInvalidColumnHeaders(
      List<List<dynamic>> fields, CsvStatus csvStatus) {
    String text;
    List<String> orderOfColumns = [];
    orderOfColumns = orderOfVisionColumns;
    for (int i = 0; i < orderOfColumns.length - 1; i++) {
      text = fields[0][i]?.toString().trim() ?? "";
      if (orderOfColumns[i] != text) {
        TextFormFieldError error = TextFormFieldError(
          focusNode: textHeaderData[i].focusNode,
          rowIndex: 0,
          columnIndex: i,
        );
        textHeaderData[i].hasErrorIcon = true;
        textHeaderData[i].errorTitle = "Warning Invalid Column Title";
        textHeaderData[i].errorSubTitle =
            "There appears to be an issue with your title entry due to an incorrect or missing header";
        errors.add(error);
      }
    }
  }

  /// function name: [addVisionBulkUpload]
  ///
  /// purpose: Handles the bulk upload of vision data from the CSV file. This method takes the parsed CSV
  ///          data, converts it into Firestore-compatible format, and uploads it to the Firestore database.
  ///
  /// parameters:
  ///            - [fields] List`<List<dynamic>`>: The CSV data to be uploaded.
  ///
  /// return type: [Future<void>]
  ///             - Uploads data to Firestore and handles success/error messages.
  Future<void> addVisionBulkUpload(List<List<dynamic>> fields) async {
    final user = await sl<CreateVisionUsecase>().execute(fields);
    user.fold(
      (l) => debugPrint("l.message"),
      (r) => debugPrint("Created Successfully"),
    );
    update();
  }
}
