import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/loading.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_checklist_invited_members.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_checklists.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/checklist_item.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/comment.dart';
import 'package:demo_app/features/department/presentation/controller/add_department_controller.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/network/get_base_url.dart';
import 'package:path/path.dart';

// Name: Nour Nabil
// Date: 20/2/2025
// last Update: 23/2/2025
// Objective: Merge AttachmentController and DeadlineController into TaskDetailsController

class TaskDetailsController extends GetxController {
  BoardController get boardController => Get.find();

  // ----------statics-------------
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool loading = false;
  DateTime now = DateTime.now();
  String? fileName;
  String fileUrl = "";
  List<CardModel> filterCards = [];
  int selectedIndex = 0;
  String cardImageUrl = "";
  ImagePicker picker = ImagePicker();
  File? _image;
  String imageUrl = "";
  bool onCardMemeberSearch = false;
  List<String> currentCardMembers = [];
  List<String> images = [];
  int allMembersNum = 0;
  List<String>? cardProgressPercentageList;
  String? cardProgressPercentageValue;
  List<String>? cardColorsList;
  String? cardSelectedIncreament;
  bool onCardSearch = false;
  bool onBoardSearch = false;
  String startTimeHint = "12:00 AM";
  String endTimeHint = "12:00 AM";
  String hintStartDate = "DD/MM/YYYY";
  String hintEndDate = "DD/MM/YYYY";
  List<CardChecklistInvitedMembers> invitedMembersList = [];
  List<CardChecklistInvitedMembers> invitedMembersListWithoutFilter = [];
  String? searchInvitedMembersText;
  //------------statics end------------

  /// --------> Function <----------///
  MainCoreDepartmentController addDepartmentController = Get.find();
  MainCoreEmployeeController addEmployeeController = Get.find();

  String? invitedMembersFilterStatus;
  String? invitedMembersFilterStartDate;
  String? invitedMembersFilterEndDate;
  bool isFilterEnabled = false;

  /// Retrieves the file size of a given URL.
  Future<String> getFileSize(url) async {
    http.Response response;
    try {
      response = await http.head(Uri.parse(url));
      final int contentLength =
          int.parse(response.headers['content-length'] ?? '0');
      return formatBytes(contentLength, 1);
    } catch (e) {
      return formatBytes(0, 1);
    }
  }

  // Formats the given number of bytes into a human-readable string representation.
  // Takes the total number of bytes and the number of decimal places to round to.
  // Returns the formatted string representation with appropriate units (B, KB, MB, GB, TB).
  String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const sizes = ["B", "KB", "MB", "GB", "TB"];
    final index = (math.log(bytes) / math.log(1024)).floor();
    return "${(bytes / math.pow(1024, index)).toStringAsFixed(decimals)} ${sizes[index]}";
  }

  /// Formats a given [Timestamp] object into a human-readable string representation.
  String formatTimestampToString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateFormat dateFormat = DateFormat("dd MMM yyyy 'at' hh : mm a");
    String formattedDate = dateFormat.format(dateTime);
    return formattedDate;
  }

  String getFileNameFromUrl(String url) {
    String decodedUrl = Uri.decodeFull(url);
    return decodedUrl
        .substring(decodedUrl.lastIndexOf('/') + 1)
        .split('?')
        .first;
  }

  void enableFilter(bool value) {
    isFilterEnabled = value;
  }

  void onApplyFilter() {
    invitedMembersList = setFilter();
    update();
  }

  void IsInvitedMemberFilterOn() {
    if (invitedMembersFilterStatus != null ||
        invitedMembersFilterStartDate != null ||
        invitedMembersFilterEndDate != null) {
      isFilterEnabled = true;
      onApplyFilter();
    } else {
      isFilterEnabled = false;
    }
  }

  void searchInvitedMembersList(String searchText) {
    searchInvitedMembersText = searchText;
    invitedMembersList = invitedMembersListWithoutFilter
        .where((e) =>
        e.memberName.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
    if (invitedMembersFilterStatus != null) {
      invitedMembersList = invitedMembersList
          .where((e) =>
      e.status.toLowerCase() ==
          invitedMembersFilterStatus!.toLowerCase())
          .toList();
    }
    if (invitedMembersFilterStartDate != null) {
      invitedMembersList = invitedMembersList.where((e) {
        if (e.startDate != null) {
          return DateFormat('dd/MM/yyyy').parse(e.startDate!).isAtSameMomentAs(
              DateFormat('dd MMM yyyy').parse(invitedMembersFilterStartDate!));
        } else {
          return false;
        }
      }).toList();
    }
    if (invitedMembersFilterEndDate != null) {
      invitedMembersList = invitedMembersList.where((e) {
        if (e.endDate != null) {
          return DateFormat('dd/MM/yyyy').parse(e.endDate!).isAtSameMomentAs(
              DateFormat('dd MMM yyyy').parse(invitedMembersFilterEndDate!));
        } else {
          return false;
        }
      }).toList();
    }
    update();
  }

  void updateInvitedMembersFilterStatus(String value) {
    invitedMembersFilterStatus = value;
    update();
  }

  void updateInvitedMembersFilterStartDate(String value) {
    invitedMembersFilterStartDate = value;
    update();
  }

  void updateInvitedMembersFilterEndDate(String value) {
    invitedMembersFilterEndDate = value;
    update();
  }

  void resetInvitedMembersFilter() {
    invitedMembersList = invitedMembersListWithoutFilter;
    invitedMembersFilterStatus = null;
    invitedMembersFilterStartDate = null;
    invitedMembersFilterEndDate = null;
  }

  bool isExceeded(String? itemEndDate, String? itemEndTime) {
    DateTime? parsedEndDateTime;
    DateTime? parsedEndDate;
    // Parse the end date string (DD/MM/YYYY) into a DateTime object

    if (itemEndDate != null) {
      parsedEndDate = DateFormat('dd/MM/yyyy').parse(itemEndDate);
    }

    // Check if endTime is provided
    if (itemEndTime != null) {
      // Parse the end time string (e.g., "09:30 AM")
      final timeFormat = DateFormat('hh:mm a'); // For parsing "09:30 AM" format
      final parsedEndTime = timeFormat.parse(itemEndTime);

      // Combine the date and time into a full DateTime object
      if (parsedEndDate != null) {
        parsedEndDateTime = DateTime(
          parsedEndDate.year,
          parsedEndDate.month,
          parsedEndDate.day,
          parsedEndTime.hour,
          parsedEndTime.minute,
        );
      }
    } else {
      // If no time is provided, just use the date
      if (parsedEndDate != null) {
        parsedEndDateTime = DateTime(parsedEndDate.year, parsedEndDate.month,
            parsedEndDate.day, 23, 59, 59); // End of the day
      }
    }

    // Current date and time

    // Check if the deadline has passed
    bool isPastDeadline =
        parsedEndDateTime != null && parsedEndDateTime.isBefore(DateTime.now());
    return isPastDeadline;
  }

  void setInvitedMembers(BoardModel boardModel) {
    invitedMembersList = [];
    invitedMembersListWithoutFilter = [];
    searchInvitedMembersText = null;
    if (boardModel.cards.isNotEmpty) {
      for (var card in boardModel.cards) {
        if (card.cardCheckLists != null && card.cardCheckLists!.isNotEmpty) {
          for (var checklist in card.cardCheckLists!) {
            if (checklist.checkListItems != null &&
                checklist.checkListItems!.isNotEmpty) {
              for (var checklistItem in checklist.checkListItems!) {
                String status = '';
                if (checklistItem.itemStatus != null &&
                    checklistItem.itemStatus!.isNotEmpty) {
                  if (checklistItem.itemStatus!.last == 'done') {
                    status = 'Done';
                  } else {
                    if ((checklistItem.itemStartDate != null &&
                        checklistItem.itemStartDate!.isNotEmpty) &&
                        (checklistItem.itemEndDate != null &&
                            checklistItem.itemEndDate!.isNotEmpty)) {
                      if (isExceeded(checklistItem.itemEndDate?.lastOrNull,
                          checklistItem.itemEndTime?.lastOrNull)) {
                        status = 'exceeded deadline';
                      } else {
                        if (compareWithCurrenDate(
                            checklistItem.itemStartDate?.lastOrNull,
                            checklistItem.itemStartTime?.lastOrNull)) {
                          status = "Not Started";
                        } else {
                          status = "In Progress";
                        }
                      }
                    } else if (checklistItem.itemStartDate != null &&
                        checklistItem.itemStartDate!.isNotEmpty) {
                      if (compareWithCurrenDate(
                          checklistItem.itemStartDate?.lastOrNull,
                          checklistItem.itemStartTime?.lastOrNull)) {
                        status = "In Progress";
                      } else {
                        status = "Not Started";
                      }
                    } else if (checklistItem.itemEndDate != null &&
                        checklistItem.itemEndDate!.isNotEmpty) {
                      if (isExceeded(checklistItem.itemEndDate?.lastOrNull,
                          checklistItem.itemEndTime?.lastOrNull)) {
                        status = 'exceeded deadline';
                      } else {
                        status = "In Progress";
                      }
                    } else {
                      status = 'Not Started';
                    }
                  }
                }
                if (checklistItem.itemMembers != null &&
                    checklistItem.itemMembers!.isNotEmpty) {
                  for (var itemMember in checklistItem.itemMembers!) {
                    invitedMembersList.add(CardChecklistInvitedMembers(
                      status: status,
                      card: card.cardName!.cardName!.last.capitalize!,
                      startDate: checklistItem.itemStartDate?.lastOrNull,
                      endDate: checklistItem.itemEndDate?.lastOrNull,
                      task: checklistItem.itemTitle!.last,
                      memberName:
                      boardController.empFullName(itemMember).capitalize!,
                      memberImage: boardController.getSingleImage(itemMember),
                    ));
                    invitedMembersListWithoutFilter
                        .add(CardChecklistInvitedMembers(
                      status: status,
                      card: card.cardName!.cardName!.last.capitalize!,
                      startDate: checklistItem.itemStartDate?.lastOrNull,
                      endDate: checklistItem.itemEndDate?.lastOrNull,
                      task: checklistItem.itemTitle!.last,
                      memberName:
                      boardController.empFullName(itemMember).capitalize!,
                      memberImage: boardController.getSingleImage(itemMember),
                    ));
                  }
                }
              }
            }
          }
        }
      }
    }

    invitedMembersList = setFilter();
  }

  bool compareWithCurrenDate(String? itemEndDate, String? itemEndTime) {
    DateTime? parsedEndDateTime;
    DateTime? parsedEndDate;
    // Parse the end date string (DD/MM/YYYY) into a DateTime object

    if (itemEndDate != null) {
      parsedEndDate = DateFormat('dd/MM/yyyy').parse(itemEndDate);
    }

    // Check if endTime is provided
    if (itemEndTime != null) {
      // Parse the end time string (e.g., "09:30 AM")
      final timeFormat = DateFormat('hh:mm a'); // For parsing "09:30 AM" format
      final parsedEndTime = timeFormat.parse(itemEndTime);

      // Combine the date and time into a full DateTime object
      if (parsedEndDate != null) {
        parsedEndDateTime = DateTime(
          parsedEndDate.year,
          parsedEndDate.month,
          parsedEndDate.day,
          parsedEndTime.hour,
          parsedEndTime.minute,
        );
      }
    } else {
      // If no time is provided, just use the date
      if (parsedEndDate != null) {
        parsedEndDateTime = DateTime(parsedEndDate.year, parsedEndDate.month,
            parsedEndDate.day, 23, 59, 59); // End of the day
      }
    }

    // Current date and time

    // Check if the deadline has passed
    bool isPastDeadline =
        parsedEndDateTime != null && parsedEndDateTime.isBefore(DateTime.now());
    return isPastDeadline;
  }

  void updatecardSelectedIncreament(increament) {
    cardSelectedIncreament = increament;
    update();
  }

  List<CardChecklistInvitedMembers> setFilter() {
    invitedMembersList = invitedMembersListWithoutFilter;
    if (searchInvitedMembersText != null) {
      invitedMembersList = invitedMembersList
          .where((e) => e.memberName
          .toLowerCase()
          .contains(searchInvitedMembersText!.toLowerCase()))
          .toList();
    }
    if (invitedMembersFilterStatus != null) {
      invitedMembersList = invitedMembersList
          .where((e) =>
      e.status.toLowerCase() ==
          invitedMembersFilterStatus!.toLowerCase())
          .toList();
    }
    if (invitedMembersFilterStartDate != null) {
      invitedMembersList = invitedMembersList.where((e) {
        if (e.startDate != null) {
          return DateFormat('dd/MM/yyyy').parse(e.startDate!).isAtSameMomentAs(
              DateFormat('dd MMM yyyy').parse(invitedMembersFilterStartDate!));
        } else {
          return false;
        }
      }).toList();
    }
    if (invitedMembersFilterEndDate != null) {
      invitedMembersList = invitedMembersList.where((e) {
        if (e.endDate != null) {
          return DateFormat('dd/MM/yyyy').parse(e.endDate!).isAtSameMomentAs(
              DateFormat('dd MMM yyyy').parse(invitedMembersFilterEndDate!));
        } else {
          return false;
        }
      }).toList();
    }
    return invitedMembersList;

    //update();
  }

  // Checks if the given text is a valid field by verifying if it contains any letter.
  bool isFieldValid(String text) {
    // Regular expression to match any letter
    RegExp regex = RegExp(r'[a-zA-Z]');

    // Check if the text contains any letter
    return regex.hasMatch(text);
  }

  /// Checks if the given [filePath] is an image file by checking if it contains any of the known image extensions.
  bool isImage(String filePath) {
    bool flag = false;
    for (String imageExtention in imageExtentions) {
      if (filePath.contains(imageExtention)) {
        return true;
      }
    }
    return flag;
  }

  // Known image extentions todo:: put it into file
  List<String> imageExtentions = [
    ".PSD",
    ".XCF",
    ".AI",
    ".CDR",
    ".tif",
    ".tiff",
    ".bmp",
    ".jpg",
    ".jpeg",
    ".gif",
    ".png",
    ".eps",
    ".raw",
    ".cr2",
    ".nef",
    ".orf",
    ".sr2"
  ];

  // Picks a file and uploads it based on the specified card name.
  FilePickerResult? pickedPdf;
  Future<void> pickAndUploadFile({
    required String boardName,
    required String department,
    required String cardName,
    required String taskID,
    required bool isBoardAsset // true for BoardAsset, false for CardAsset
  }) async {
    pickedPdf = null;
    fileName = null;
    pickedPdf = await FilePicker.platform.pickFiles(type: FileType.any,);

    if (pickedPdf != null) {
      showLoadingIndicator();
      final file = File(pickedPdf!.files.single.path!);
      String filePath = pickedPdf!.files.single.path!;
      fileName = basename(filePath);
      String extension = fileName!.split('.').last;
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Construct file name based on asset type
      String finalFileName = isBoardAsset
          ? "${boardName}_${timestamp}_$extension.$extension"
          : "${boardName}_${cardName}_${timestamp}_$extension.$extension";
      // Construct storage path
      String storagePath = isBoardAsset
          ? "Board/$department/$boardName/Boards_Image/$finalFileName"
          : "Board/$department/$boardName/BoardAssets/CardAssets/$taskID/$cardName/$finalFileName";

      if (isImage(filePath)) {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child(storagePath);
        final metadata = SettableMetadata(contentType: 'image/$extension');
        final TaskSnapshot task = await ref.putFile(file, metadata);
        fileUrl = await task.ref.getDownloadURL();
      } else {
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('Cards/$cardName/${DateTime.now()}/$fileName');
        //final metadata = SettableMetadata(contentType: 'application/pdf');
        final TaskSnapshot task = await storageRef.putFile(
          file, /*metadata*/
        );
        fileUrl = await task.ref.getDownloadURL();
      }
      hideLoadingIndicator();
    }
    update();
  }

  /// Determines the index based on the card status
  int _getStatusIndex(String status) {
    switch (status) {
      case "todo":
        return 0;
      case "doing":
        return 1;
      case "done":
        return 2;
      case "archived":
        return 3;
      default:
        return 0;
    }
  }

  // Retrieves the number of all invited members from the given [boardModel].
  void getAllMembersNum(BoardModel boardModel) {
    images = [];
    allMembersNum = 0;
    for (int i = 0; i < boardModel.boardMember!.boardMembers!.length; i++) {
      if (boardModel.boardMember!.boardMembersStatus![i] == "invited") {
        allMembersNum++;
        images.add(boardController.getSingleImage(
          boardModel.boardMember!.boardMembers![i],
        ));
      }
    }
    if (allMembersNum > 6) {
      allMembersNum = allMembersNum - 6;
    } else {
      allMembersNum = 0;
    }
  }

  // Sets the members of a board based on the given [boardModel].
  //
  // This function iterates over the board members in the [boardModel] and checks
  // if each member has a status of "invited". If a member has a status of
  // "invited", it is added to the [currentCardMembers] list.
  void setMembers(BoardModel boardModel) {
    if (boardModel.boardMember != null &&
        boardModel.boardMember!.boardMembers!.isNotEmpty) {
      currentCardMembers = [];
      for (int i = 0; i < boardModel.boardMember!.boardMembers!.length; i++) {
        if (boardModel.boardMember!.boardMembersStatus![i] == "invited") {
          currentCardMembers
              .add(boardModel.boardMember!.boardMembers![i].toString());
        }
      }
      if (currentCardMembers.isNotEmpty) {
        currentCardMembers = currentCardMembers.reversed.toList();
        currentCardMembers
            .add(Get.find<MainCoreEmployeeController>().employeeEntity!.email!);
        currentCardMembers = currentCardMembers.reversed.toList();
      }
    }
  }

  void updateColorDropDown(CardModel card) {
    cardProgressPercentageValue =
    card.progressIndicator!.progressPercentage![0];
    cardProgressPercentageList = card.progressIndicator!.progressPercentage!;
    cardColorsList = card.progressIndicator!.colors!;
    // cardProgressPercentageList!.removeAt(0);
    //update();
  }

  //  List<String>
  void updateColorList(BuildContext context, List<String> colors,
      String selectedColor, int index) {
    int length = colors.length;
    List<String> updatedColors = List.from(colors);

    if (selectedColor == "red") {
      // Case 1: Change all colors before and including the index to red
      for (int i = 0; i <= index; i++) {
        updatedColors[i] = "red";
      }
    } else if (selectedColor == "green") {
      // Case 2: Change all colors after and including the index to green
      for (int i = index; i < length; i++) {
        updatedColors[i] = "green";
      }
    } else if (selectedColor == "orange") {
      // Case 3: If changing a red index to orange, update all colors between that index and the nearest previous orange
      // If changing a green index to orange, update all colors between that index and the nearest next orange

      if (updatedColors[index] == "red") {
        for (int i = index; i < length; i++) {
          if (updatedColors[i] == "orange" ||
              updatedColors[i] == "green" ||
              updatedColors[i] == "yellow") {
            break;
          }
          updatedColors[i] = "orange";
        }
      } else if (updatedColors[index] == "green" ||
          updatedColors[index] == "yellow") {
        for (int i = index; i >= 0; i--) {
          if (updatedColors[i] == "orange" || updatedColors[i] == "red") {
            break;
          }
          updatedColors[i] = "orange";
        }
      }
    } else if (selectedColor == "yellow") {
      // Case 4: If changing a red index to yellow, update all colors between that index and the nearest previous yellow
      // If changing a green index to yellow, update all colors between that index and the nearest next yellow

      if (updatedColors[index] == "red" || updatedColors[index] == "orange") {
        for (int i = index; i < length; i++) {
          if (updatedColors[i] == "green" || updatedColors[i] == "yellow") {
            break;
          }
          updatedColors[i] = "yellow";
        }
      } else if (updatedColors[index] == "green") {
        for (int i = index; i >= 0; i--) {
          if (updatedColors[i] == "yellow" ||
              updatedColors[i] == "orange" ||
              updatedColors[i] == "red") {
            break;
          }
          updatedColors[i] = "yellow";
        }
      }
    }
    cardColorsList = updatedColors;
    Navigator.pop(context);
    // return updatedColors;
  }

  void onChnagedColorDropDown(List<String>? colorsList,
      List<String>? progressPercentageList, String? progressPercentageValue) {
    cardProgressPercentageValue = progressPercentageValue;
    cardProgressPercentageList = progressPercentageList;
    cardColorsList = colorsList;
    update();
  }

  /// --------> Function <----------///
  // Attachment Handling
  RxBool expandAttach = true.obs;
  List<String> allAttachments = <String>[].obs;

  void toggleExpandAttach() {
    expandAttach.value = !expandAttach.value;
  }

  void initializeAttachments(CardModel cardModel) {
    allAttachments.clear();
    if (cardModel.cardAttachments?.cardAttachments?.isNotEmpty == true) {
      for (int i = 0;
      i < cardModel.cardAttachments!.cardAttachments!.length;
      i++) {
        if (cardModel.cardAttachments!.cardAttachmentsStatus![i] ==
            "uploaded") {
          allAttachments.add(cardModel.cardAttachments!.cardAttachments![i]);
        }
      }
    }
  }

  void deleteAllAttachments(CardModel cardModel, String board) {
    boardController
        .updateCard(
      cardModel: cardModel,
      board: board,
      deleteAllAttachments: true,
    )
        .then((_) {
      allAttachments.clear();
    });
  }

  // A function to update the image of a card, taking the CardModel and board as required parameters.
  Future<void> updateCardImage({
    required CardModel cardModel,
    required String boardName,
    required String department,
    required String taskID,
    required String board,
  }) async {
    if (cardImageUrl != "") {
      await FirebaseStorage.instance
          .refFromURL(cardImageUrl)
          .delete()
          .then((value) {
        cardImageUrl = "";
      });
    }
    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    showLoadingIndicator();
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String extension = pickedFile.path.split('.').last;

      // File naming convention: BoardName_CardName_TimeStamp_FileExtension.ext
      String fileName =
          "${boardName}_${cardModel.cardName!.cardName!.last}_${timestamp}_$extension.$extension";

      // Folder structure: Board/Department/BoardName/BoardAssets/CardAssets/TaskID/CardName/TaskData
      String filePath =
          "Board/$department/$boardName/BoardAssets/CardAssets/$taskID/${cardModel.cardName!.cardName!.last}/$fileName";

      _image = File(pickedFile.path);
      Reference ref = FirebaseStorage.instance
          .ref()
          .child(filePath);
      final metadata = SettableMetadata(contentType: 'image/$extension');
      UploadTask uploadTask = ref.putFile(_image!, metadata);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      // cardImageUrl = await taskSnapshot.ref.getDownloadURL();
      await taskSnapshot.ref.getDownloadURL().then((value) {
        boardController.updateCard(
          cardModel: cardModel,
          board: board,
          cardImage: value,
        );
      });
    }
    hideLoadingIndicator();
    update();
  }

  Future<void> updateCard({
    required CardModel cardModel,
    required String board,
    BoardModel? boardModel,
    List<String>? invitationMember,
    String? startTime,
    String? endTime,
    String? startDate,
    String? endDate,
    String? checkList,
    CardCheckLists? currentCheckList,
    List<String>? listItemMember,
    CheckListItems? currentListItem,
    String? listItemStartDate,
    String? listItemEndDate,
    String? listItemStartTime,
    String? listItemEndTime,
    String? checkListStatus,
    String? checkListItem,
    String? checkListItemStatus,
    String? checkListItemTitle,
    String? attachment,
    String? cardName,
    String? cardDescription,
    String? cardStatus,
    bool? archiveReturn,
    String? priority,
    String? progress,
    List<String>? cardAttachments,
    bool? deleteAllAttachments,
    String? comment,
    String? cardImage,
    List<String>? progressIndicators,
    List<String>? progressColor,
  }) async {
    loading = true;
    update();

    try {
      // Update card members if invitationMember is provided
      if (invitationMember != null) {
        _updateCardMembers(cardModel, invitationMember);
      }

      // Update card dates and times
      _updateCardDatesAndTimes(
          cardModel, startDate, endDate, startTime, endTime);

      // Update checklists and checklist items
      if (checkList != null || checkListItem != null) {
        _updateCheckLists(
          cardModel,
          checkList,
          currentCheckList,
          checkListItem,
          currentListItem,
          listItemStartDate,
          listItemEndDate,
          listItemStartTime,
          listItemEndTime,
          checkListItemStatus,
          checkListItemTitle,
        );
      }

      // Update card attachments
      if (attachment != null ||
          cardAttachments != null ||
          deleteAllAttachments == true) {
        _updateCardAttachments(
            cardModel, attachment, cardAttachments, deleteAllAttachments);
      }

      // Update card details (name, description, status, etc.)
      _updateCardDetails(
        cardModel,
        cardName,
        cardDescription,
        cardStatus,
        priority,
        progress,
        comment,
        cardImage,
        progressIndicators,
        progressColor,
      );

      // Commit changes to Firestore
      await _commitChangesToFirestore(cardModel, board);

      // Send notifications based on updates
      _sendNotifications(
        cardModel,
        currentCardMembers: _getCurrentCardMembers(cardModel),
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        priority: priority,
        progress: progress,
        comment: comment,
        checkList: checkList,
        currentCheckList: currentCheckList,
        checkListItemTitle: checkListItemTitle,
        checkListItemStatus: checkListItemStatus,
        listItemMember: listItemMember,
        currentListItem: currentListItem,
        attachment: attachment,
        deleteAllAttachments: deleteAllAttachments,
      );

      // Update ui and state
      _updateUIAndState(cardModel, boardModel, cardStatus);
    } catch (e) {
      print('Error updating card: $e');
      // Handle error (e.g., show a snackbar or log the error)
    } finally {
      loading = false;
      update();
    }
  }

// Helper Methods

  void _updateCardMembers(CardModel cardModel, List<String> invitationMember) {
    List<String> lastInvitedCardMembers = [];
    List<String> lastCardMembers = [];
    List<String> removedCardMembers = [];
    List<String> newCardMembers = [];

    for (int i = 0; i < cardModel.cardMembers!.cardMembersStatus!.length; i++) {
      if (cardModel.cardMembers!.cardMembersStatus![i] == "invited") {
        lastInvitedCardMembers.add(cardModel.cardMembers!.cardMembers![i]);
      } else if (cardModel.cardMembers!.cardMembersStatus![i] == "uninvited") {
        lastCardMembers.add(cardModel.cardMembers!.cardMembers![i]);
      }
    }

    for (int i = 0; i < cardModel.cardMembers!.cardMembers!.length; i++) {
      if (!invitationMember.contains(cardModel.cardMembers!.cardMembers![i])) {
        int removedIndex = cardModel.cardMembers!.cardMembers!
            .indexOf(cardModel.cardMembers!.cardMembers![i]);
        cardModel.cardMembers!.cardMembersStatus![removedIndex] = "uninvited";
        removedCardMembers
            .add(cardModel.cardMembers!.cardMembers![removedIndex]);
      }
    }

    for (int i = 0; i < invitationMember.length; i++) {
      if (!cardModel.cardMembers!.cardMembers!.contains(invitationMember[i])) {
        cardModel.cardMembers!.cardMembers!.add(invitationMember[i]);
        cardModel.cardMembers!.cardMembersStatus!.add("invited");
        newCardMembers.add(invitationMember[i]);
      } else {
        cardModel.cardMembers!.cardMembersStatus![cardModel
            .cardMembers!.cardMembers!
            .indexOf(invitationMember[i])] = "invited";
        newCardMembers.add(invitationMember[i]);
      }
    }
  }

  void _updateCardDatesAndTimes(
      CardModel cardModel,
      String? startDate,
      String? endDate,
      String? startTime,
      String? endTime,
      ) {
    if (startDate != null) {
      cardModel.startDate!.startDate!.add(startDate);
      cardModel.startDate!.timestamp!.add(Timestamp.now());
    }
    if (endDate != null) {
      cardModel.endDate!.endDate!.add(endDate);
      cardModel.endDate!.timestamp!.add(Timestamp.now());
    }
    if (startTime != null) {
      cardModel.startTime!.startTime!.add(startTime);
      cardModel.startTime!.timestamp!.add(Timestamp.now());
    }
    if (endTime != null) {
      cardModel.endTime!.endTime!.add(endTime);
      cardModel.endTime!.timestamp!.add(Timestamp.now());
    }
  }

  void _updateCheckLists(
      CardModel cardModel,
      String? checkList,
      CardCheckLists? currentCheckList,
      String? checkListItem,
      CheckListItems? currentListItem,
      String? listItemStartDate,
      String? listItemEndDate,
      String? listItemStartTime,
      String? listItemEndTime,
      String? checkListItemStatus,
      String? checkListItemTitle,
      ) {
    if (checkList != null && currentCheckList != null) {
      cardModel
          .cardCheckLists![cardModel.cardCheckLists!.indexOf(currentCheckList)]
          .checkListTitle!
          .add(checkList);
      cardModel
          .cardCheckLists![cardModel.cardCheckLists!.indexOf(currentCheckList)]
          .timestamp!
          .add(Timestamp.now());
    }

    if (checkListItem != null &&
        currentCheckList != null &&
        currentListItem != null) {
      cardModel
          .cardCheckLists![cardModel.cardCheckLists!.indexOf(currentCheckList)]
          .checkListItems!
          .add(
        CheckListItems(
          itemTitle: [checkListItem],
          itemStatus: ["todo"],
          timestamp: [Timestamp.now()],
        ),
      );
    }

    if (checkListItemStatus != null &&
        checkListItemTitle != null &&
        currentCheckList != null) {
      cardModel
          .cardCheckLists![cardModel.cardCheckLists!.indexOf(currentCheckList)]
          .checkListItems!
          .where((element) => element.itemTitle!.last == checkListItemTitle)
          .first
          .itemStatus!
          .add(checkListItemStatus);
    }
  }

  void _updateCardAttachments(
      CardModel cardModel,
      String? attachment,
      List<String>? cardAttachments,
      bool? deleteAllAttachments,
      ) {
    if (attachment != null) {
      cardModel.cardAttachments!.cardAttachments!.add(fileUrl);
      cardModel.cardAttachments!.cardAttachmentsStatus!.add("uploaded");
      cardModel.cardAttachments!.timestamp!.add(Timestamp.now());
    }

    if (cardAttachments != null) {
      cardModel.cardAttachments!.timestamp!.add(Timestamp.now());
      for (int i = 0;
      i < cardModel.cardAttachments!.cardAttachments!.length;
      i++) {
        if (!cardAttachments
            .contains(cardModel.cardAttachments!.cardAttachments![i])) {
          cardModel.cardAttachments!.cardAttachmentsStatus![i] = "deleted";
        }
      }
    }

    if (deleteAllAttachments == true) {
      cardModel.cardAttachments!.timestamp!.add(Timestamp.now());
      for (int i = 0;
      i < cardModel.cardAttachments!.cardAttachments!.length;
      i++) {
        cardModel.cardAttachments!.cardAttachmentsStatus![i] = "deleted";
      }
    }
  }

  void _updateCardDetails(
      CardModel cardModel,
      String? cardName,
      String? cardDescription,
      String? cardStatus,
      String? priority,
      String? progress,
      String? comment,
      String? cardImage,
      List<String>? progressIndicators,
      List<String>? progressColor,
      ) {
    if (cardName != null) {
      cardModel.cardName!.cardName!.add(cardName);
      cardModel.cardName!.timestamp!.add(Timestamp.now());
    }
    if (cardDescription != null) {
      cardModel.cardDescription!.cardDescription!.add(cardDescription);
      cardModel.cardDescription!.timestamp!.add(Timestamp.now());
    }
    if (cardStatus != null) {
      cardModel.cardStatus!.cardStatus!.add(cardStatus);
      cardModel.cardStatus!.timestamp!.add(Timestamp.now());
    }
    if (priority != null) {
      cardModel.cardPriority!.cardPriority!.add(priority);
      cardModel.cardPriority!.timestamp!.add(Timestamp.now());
    }
    if (progress != null) {
      cardModel.cardProgress!.cardProgress!.add(progress);
      cardModel.cardProgress!.timestamp!.add(Timestamp.now());
    }
    if (progressIndicators != null && progressColor != null) {
      cardModel.progressIndicator!.progressPercentage = progressIndicators;
      cardModel.progressIndicator!.colors = progressColor;
    }
    if (comment != null) {
      cardModel.comments!.add(
        Comments(
          commentCreator: [
            Get.find<MainCoreEmployeeController>().employeeEntity!.email!
          ],
          comment: [comment],
          timestamp: [Timestamp.now()],
        ),
      );
    }
    if (cardImage != null) {
      cardModel.cardImage!.cardImage!.add(cardImage);
      cardModel.cardImage!.timestamp!.add(Timestamp.now());
    }
  }

  Future<void> _commitChangesToFirestore(
      CardModel cardModel, String board) async {
    final CollectionReference cardCollection =
    db.collection(getBaseUrl('Cards'));
    WriteBatch batch = db.batch();

    batch.set(
      cardCollection
          .doc(board.capitalize)
          .collection(getBaseUrl("Cards"))
          .doc(cardModel.cardId),
      cardModel.toMap(),
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  void _sendNotifications(
      CardModel cardModel, {
        required List<String> currentCardMembers,
        String? startDate,
        String? endDate,
        String? startTime,
        String? endTime,
        String? priority,
        String? progress,
        String? comment,
        String? checkList,
        CardCheckLists? currentCheckList,
        String? checkListItemTitle,
        String? checkListItemStatus,
        List<String>? listItemMember,
        CheckListItems? currentListItem,
        String? attachment,
        bool? deleteAllAttachments,
      }) {
    // Notification logic here (similar to the original code)
    // Extract this into a separate helper function if it becomes too large.
  }

// Updates the filter cards based on the given list of cards and a status.
  updatefilterCards(List<CardModel> cards, String status) {
    filterCards = [];
    for (var element in cards) {
      if (element.cardStatus!.cardStatus!.last == status) {
        filterCards.add(element);
      }
    }
    update();
  }

  void _updateUIAndState(
      CardModel cardModel, BoardModel? boardModel, String? cardStatus) {
    if (cardStatus != null) {
      switch (cardStatus) {
        case "todo":
          updatefilterCards(boardModel!.cards, "todo");
          selectedIndex = 0;
          break;
        case "doing":
          updatefilterCards(boardModel!.cards, "doing");
          selectedIndex = 1;
          break;
        case "done":
          updatefilterCards(boardModel!.cards, "done");
          selectedIndex = 2;
          break;
        case "archived":
          updatefilterCards(boardModel!.cards, "archived");
          selectedIndex = 3;
          break;
        case "deleted":
          updatefilterCards(boardModel!.cards, "deleted");
          selectedIndex = 4;
          break;
      }
    }
    update();
    boardController.getAllBoards();
  }

  List<String> _getCurrentCardMembers(CardModel cardModel) {
    List<String> currentCardMembers = [];
    for (int i = 0; i < cardModel.cardMembers!.cardMembers!.length; i++) {
      if (cardModel.cardMembers!.cardMembersStatus![i] == "invited") {
        currentCardMembers.add(cardModel.cardMembers!.cardMembers![i]);
      }
    }
    return currentCardMembers;
  }

  // Deadline Handling
  RxBool expandDates = false.obs;

  void toggleExpandDates() {
    expandDates.value = !expandDates.value;
  }

  void initializeDates(CardModel cardModel) {
    hintStartDate = DateFormat("dd/MM/yyyy").format(
      DateTime.parse(cardModel.startDate!.startDate!.last.toString()),
    );
    hintEndDate = DateFormat("dd/MM/yyyy").format(
      DateTime.parse(cardModel.endDate!.endDate!.last.toString()),
    );
    startTimeHint = cardModel.startTime!.startTime!.last.toString();
    endTimeHint = cardModel.endTime!.endTime!.last.toString();
  }
}