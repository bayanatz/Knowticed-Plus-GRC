// // date: 25/Mar/2024
// // by: Abdullah Ibrahim
// // App Version : Version 2
// // lastUpdate:
// // Objectives: Task's Controller(Add, get, Reschedule, Cancel and Edit Tasks).
//
// import 'dart:io';
// import 'dart:math' as math;
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:demo_app/core/helper/task_management_module/core/components/success_dialog.dart';
// import 'package:demo_app/core/helper/task_management_module/core/constant/date_time_in_arabic.dart';
// import 'package:demo_app/core/helper/task_management_module/core/constant/loading.dart';
// import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
// import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_checklist_invited_members.dart';
// import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_checklists.dart';
// import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
// import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/checklist_item.dart';
// import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/comment.dart';
// import 'package:demo_app/features/main_core/features/department/presentation/controller/add_department_controller.dart';
// import 'package:demo_app/features/main_core/features/employee/presentation/controller/add_employee_controller.dart';
// import 'package:demo_app/features/main_core/features/employee/domain/entities/employee_entity.dart';
// import 'package:demo_app/features/main_core/features/notification/presentation/controller/notification_controller.dart';
// import 'package:demo_app/features/main_core/core/theme/app_colors.dart';
// import 'package:path/path.dart';
//
// // EmployeeModel? employee = EmployeeModel();
// // EmployeeDirectoryModel? employeeDirectory;
//
// class TaskController extends GetxController with StateMixin {
//   // FirebaseFirestore instance for interacting with Firestore.
//
//   /// Retrieves the file size of a given URL.
//   Future<String> getFileSize(url) async {
//     http.Response response;
//     try {
//       response = await http.head(Uri.parse(url));
//       final int contentLength =
//           int.parse(response.headers['content-length'] ?? '0');
//       return formatBytes(contentLength, 1);
//     } catch (e) {
//       return formatBytes(0, 1);
//     }
//   }
//
//   // Formats the given number of bytes into a human-readable string representation.
//   // Takes the total number of bytes and the number of decimal places to round to.
//   // Returns the formatted string representation with appropriate units (B, KB, MB, GB, TB).
//   String formatBytes(int bytes, int decimals) {
//     if (bytes <= 0) return "0 B";
//     const sizes = ["B", "KB", "MB", "GB", "TB"];
//     final index = (math.log(bytes) / math.log(1024)).floor();
//     return "${(bytes / math.pow(1024, index)).toStringAsFixed(decimals)} ${sizes[index]}";
//   }
//
//   /// Formats a given [Timestamp] object into a human-readable string representation.
//   String formatTimestampToString(Timestamp timestamp) {
//     DateTime dateTime = timestamp.toDate();
//     DateFormat dateFormat = DateFormat("dd MMM yyyy 'at' hh : mm a");
//     String formattedDate = dateFormat.format(dateTime);
//     return formattedDate;
//   }
//
//   FirebaseFirestore db = FirebaseFirestore.instance;
//   bool loading = false;
//   DateTime now = DateTime.now();
//   AddDepartmentController addDepartmentController = Get.find();
//   AddEmployeeController addEmployeeController = Get.find();
//   AppNotificationController appNotificationController =
//       Get.put(AppNotificationController());
//
//   // Retrieves the list of departments asynchronously,
//   // updates the local 'departments' variable with the fetched data,
//   // sets 'loading' to false, and triggers a ui update.
//   List<String> allDepartments = [];
//   Future<void> getDepartments() async {
//     await addDepartmentController.getAllDepartments();
//     loading = false;
//     update();
//   }
//
//   String CurrentUserArabicName() {
//     return Get.find<AddEmployeeController>().getEmployeeNameEnglishArabic(
//         Get.find<AddEmployeeController>().employeeEntity!.email!, false);
//   }
//
//   /////////////////////////// Added New Section ///////////////////////////////////////////
//   /// list for displaying the members images
//   List<String>? checkListImages = [
//     "assets/png_assets/profile1.png",
//     "assets/png_assets/profile1.png",
//     "assets/png_assets/profile1.png",
//     "assets/png_assets/profile1.png",
//     "assets/png_assets/profile1.png",
//     "assets/png_assets/profile1.png",
//     "assets/png_assets/profile1.png",
//     "assets/png_assets/profile1.png",
//   ];
//   String? memberName = "Bassem Mohamed";
//   String? startDate = "12/05/2023";
//   String? endDate = "10/09/2024";
//   String? startTime = "09:00 AM";
//   String? endTime = "01:14 PM";
//
//   // A function to retrieve an employee using the provided email address asynchronously.
//   Future<void> getEmployee() async {
//     await addEmployeeController.getNewEmployee("a100");
//     update();
//   }
//
//   // A function that fetches all employees,
//   // updates the list, and filters only the active ones.
//   Future<void> getAllEmployees() async {
//     await addEmployeeController.getAllNewEmployees();
//     update();
//   }
//
//   ImagePicker picker = ImagePicker();
//   File? _image;
//   String imageUrl = "";
//
//   List<BoardModel> allBoards = [];
//   List<BoardModel> boards = [];
//   String selectedDepartment =
//       Get.locale.toString().contains('en') ? 'All' : 'الكل';
//
//   /// Retrieves all boards from the database and populates the `allBoards` and `boards` lists.
//   Future<void> getAllBoards() async {
//     loading = true;
//     allBoards = [];
//     boards = [];
//
//     final CollectionReference boardCollection = db.collection('/Boards');
//     final CollectionReference cardCollection = db.collection('/Cards');
//
//     boardCollection.get().then((QuerySnapshot querySnapshot) {
//       for (var doc in querySnapshot.docs) {
//         BoardModel boardModel =
//             BoardModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
//         cardCollection
//             .doc(GetUtils.capitalize(boardModel.boardName!.boardgName!.last)!)
//             .collection("Cards")
//             .get()
//             .then((QuerySnapshot querySnapshot) {
//           for (var doc in querySnapshot.docs) {
//             boardModel.cards.add(
//                 CardModel.fromMap(doc.data() as Map<String, dynamic>, doc.id));
//           }
//         });
//
//         //boardModel.boardName!.boardgName!.
//         //allBoards.add(BoardModel.fromMap(doc1.data() as Map<String, dynamic>, doc1.id));
//         if (boardModel.boardCreator ==
//                 Get.find<AddEmployeeController>().employeeEntity!.email! &&
//             boardModel.status == "active") {
//           allBoards.add(boardModel);
//           boards.add(boardModel);
//         } else {
//           for (int i = 0;
//               i < boardModel.boardMember!.boardMembers!.length;
//               i++) {
//             if (boardModel.boardMember!.boardMembersStatus![i] == "invited" &&
//                 boardModel.status == "active") {
//               if (boardModel.boardMember!.boardMembers![i] ==
//                   Get.find<AddEmployeeController>().employeeEntity!.email!) {
//                 allBoards.add(boardModel);
//                 boards.add(boardModel);
//               }
//             }
//           }
//         }
//         update();
//       }
//       update();
//     });
//     loading = false;
//     update();
//   }
//
//   // Filters the list of board models based on the provided department.
//   List<BoardModel> filterBoards(String department) {
//     if (department == 'all' || department == 'الكل') {
//       return allBoards;
//     }
//     return allBoards
//         .where((element) =>
//             element.boardDeparment!.boardgDepartment!.last ==
//             department.toLowerCase())
//         .toList();
//   }
//
//   /// Updates the board with the given [boardModel] and [boardId] by modifying the invitation members.
//   Future updateBoard({
//     required BoardModel boardModel,
//     required String boardId,
//     List<String>? invitationMember,
//   }) async {
//     loading = true;
//     update();
//     showLoadingIndicator();
//     final CollectionReference boardCollection = db.collection('/Boards');
//     WriteBatch batch = db.batch();
//     List<String> lastBoardMembers = [];
//     List<String> lastInvitedBoardMembers = [];
//     List<String> removedBoardMembers = [];
//     List<String> newBoardMembers = [];
//     //List<String> finalRemovedBoardMembers = [];
//
//     if (invitationMember != null /* && invitationMember.isNotEmpty*/) {
//       for (int i = 0;
//           i < boardModel.boardMember!.boardMembersStatus!.length;
//           i++) {
//         if (boardModel.boardMember!.boardMembersStatus![i] == "uninvited") {
//           lastBoardMembers.add(boardModel.boardMember!.boardMembers![i]);
//         }
//       }
//       for (int i = 0;
//           i < boardModel.boardMember!.boardMembersStatus!.length;
//           i++) {
//         if (boardModel.boardMember!.boardMembersStatus![i] == "invited") {
//           lastInvitedBoardMembers.add(boardModel.boardMember!.boardMembers![i]);
//         }
//       }
//
//       boardModel.boardMember!.timestamp!.add(Timestamp.now());
//       // Find Removed Members And Update Status
//       for (int i = 0; i < boardModel.boardMember!.boardMembers!.length; i++) {
//         if (!invitationMember
//             .contains(boardModel.boardMember!.boardMembers![i])) {
//           int removedIndex = boardModel.boardMember!.boardMembers!
//               .indexOf(boardModel.boardMember!.boardMembers![i]);
//           boardModel.boardMember!.boardMembersStatus![removedIndex] =
//               "uninvited";
//           removedBoardMembers
//               .add(boardModel.boardMember!.boardMembers![removedIndex]);
//         }
//       }
//       // Find New Members And Add Thier Status
//       for (int i = 0; i < invitationMember.length; i++) {
//         if (!boardModel.boardMember!.boardMembers!
//             .contains(invitationMember[i])) {
//           boardModel.boardMember!.boardMembers!.add(invitationMember[i]);
//           boardModel.boardMember!.boardMembersStatus!.add("invited");
//           newBoardMembers.add(invitationMember[i]);
//         } else {
//           boardModel.boardMember!.boardMembersStatus![boardModel
//               .boardMember!.boardMembers!
//               .indexOf(invitationMember[i])] = "invited";
//           newBoardMembers.add(invitationMember[i]);
//           //boardModel.boardMember!.boardMembersStatus![i] = "invited";
//         }
//       }
//     }
//
//     batch.set(
//       boardCollection.doc(boardId),
//       boardModel.toMap(),
//       SetOptions(merge: true),
//     );
//
//     await batch.commit().then((value) {
//       update();
//       if (invitationMember != null && newBoardMembers.isNotEmpty) {
//         List<String> toMembers = [];
//         for (var element in newBoardMembers) {
//           if (!lastInvitedBoardMembers.contains(element)) {
//             toMembers.add(element);
//             // appNotificationController.sendNotification(
//             //   "${element}topic",
//             //    "Invitation",
//             //    "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has "
//             //    "invited you to board: ${boardModel.boardName!.boardgName!.last}"
//             //    " on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",element);
//           }
//         }
//         appNotificationController.sendNotificationToMultiple(
//           type: 'board',
//           topics: toMembers,
//           title: "Invitation",
//           arabicTitle: 'دعوة',
//           body:
//               "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has invited you to board: ${boardModel.boardName!.boardgName!.last} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//           arabicBody:
//               "${CurrentUserArabicName()} ${'قام بدعوتك إلي لوحة:'} ${boardModel.boardName!.boardgName!.last} ${'في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//         );
//       }
//       if (removedBoardMembers.isNotEmpty) {
//         List<String> toMembers = [];
//
//         for (String element in removedBoardMembers) {
//           if (!lastBoardMembers.contains(element)) {
//             toMembers.add(element);
//           }
//         }
//         appNotificationController.sendNotificationToMultiple(
//           type: 'board',
//           topics: toMembers,
//           title: boardModel.boardName!.boardgName!.last,
//           arabicTitle: boardModel.boardName!.boardgName!.last,
//           body:
//               "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has removed you from board: ${boardModel.boardName!.boardgName!.last} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//           arabicBody:
//               "${CurrentUserArabicName()} ${'قام بإزالتك من لوحة:'} ${boardModel.boardName!.boardgName!.last} ${'في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//         );
//       }
//       setMembers(boardModel);
//       getAllMembersNum(boardModel);
//       getAllBoards();
//     });
//     loading = false;
//     // Update the controller state.
//     hideLoadingIndicator();
//     update();
//   }
//   /////////////////////////////New Invited Members///////////////////////////////////
//
//   void setInvitedMembers(BoardModel boardModel) {
//     invitedMembersList = [];
//     invitedMembersListWithoutFilter = [];
//     searchInvitedMembersText = null;
//     if (boardModel.cards.isNotEmpty) {
//       for (var card in boardModel.cards) {
//         if (card.cardCheckLists != null && card.cardCheckLists!.isNotEmpty) {
//           for (var checklist in card.cardCheckLists!) {
//             if (checklist.checkListItems != null &&
//                 checklist.checkListItems!.isNotEmpty) {
//               for (var checklistItem in checklist.checkListItems!) {
//                 String status = '';
//                 if (checklistItem.itemStatus != null &&
//                     checklistItem.itemStatus!.isNotEmpty) {
//                   if (checklistItem.itemStatus!.last == 'done') {
//                     status = 'Done';
//                   } else {
//                     if ((checklistItem.itemStartDate != null &&
//                             checklistItem.itemStartDate!.isNotEmpty) &&
//                         (checklistItem.itemEndDate != null &&
//                             checklistItem.itemEndDate!.isNotEmpty)) {
//                       if (isExceeded(checklistItem.itemEndDate?.lastOrNull,
//                           checklistItem.itemEndTime?.lastOrNull)) {
//                         status = 'exceeded deadline';
//                       } else {
//                         if (compareWithCurrenDate(
//                             checklistItem.itemStartDate?.lastOrNull,
//                             checklistItem.itemStartTime?.lastOrNull)) {
//                           status = "Not Started";
//                         } else {
//                           status = "In Progress";
//                         }
//                       }
//                     } else if (checklistItem.itemStartDate != null &&
//                         checklistItem.itemStartDate!.isNotEmpty) {
//                       if (compareWithCurrenDate(
//                           checklistItem.itemStartDate?.lastOrNull,
//                           checklistItem.itemStartTime?.lastOrNull)) {
//                         status = "In Progress";
//                       } else {
//                         status = "Not Started";
//                       }
//                     } else if (checklistItem.itemEndDate != null &&
//                         checklistItem.itemEndDate!.isNotEmpty) {
//                       if (isExceeded(checklistItem.itemEndDate?.lastOrNull,
//                           checklistItem.itemEndTime?.lastOrNull)) {
//                         status = 'exceeded deadline';
//                       } else {
//                         status = "In Progress";
//                       }
//                     } else {
//                       status = 'Not Started';
//                     }
//                   }
//                 }
//                 if (checklistItem.itemMembers != null &&
//                     checklistItem.itemMembers!.isNotEmpty) {
//                   for (var itemMember in checklistItem.itemMembers!) {
//                     invitedMembersList.add(CardChecklistInvitedMembers(
//                       status: status,
//                       card: card.cardName!.cardName!.last.capitalize!,
//                       startDate: checklistItem.itemStartDate?.lastOrNull,
//                       endDate: checklistItem.itemEndDate?.lastOrNull,
//                       task: checklistItem.itemTitle!.last,
//                       memberName: empFullName(itemMember).capitalize!,
//                       memberImage: getSingleImage(itemMember),
//                     ));
//                     invitedMembersListWithoutFilter
//                         .add(CardChecklistInvitedMembers(
//                       status: status,
//                       card: card.cardName!.cardName!.last.capitalize!,
//                       startDate: checklistItem.itemStartDate?.lastOrNull,
//                       endDate: checklistItem.itemEndDate?.lastOrNull,
//                       task: checklistItem.itemTitle!.last,
//                       memberName: empFullName(itemMember).capitalize!,
//                       memberImage: getSingleImage(itemMember),
//                     ));
//                   }
//                 }
//               }
//             }
//           }
//         }
//       }
//     }
//
//     invitedMembersList = setFilter();
//   }
//
//   bool isExceeded(String? itemEndDate, String? itemEndTime) {
//     DateTime? parsedEndDateTime;
//     DateTime? parsedEndDate;
//     // Parse the end date string (DD/MM/YYYY) into a DateTime object
//
//     if (itemEndDate != null) {
//       parsedEndDate = DateFormat('dd/MM/yyyy').parse(itemEndDate);
//     }
//
//     // Check if endTime is provided
//     if (itemEndTime != null) {
//       // Parse the end time string (e.g., "09:30 AM")
//       final timeFormat = DateFormat('hh:mm a'); // For parsing "09:30 AM" format
//       final parsedEndTime = timeFormat.parse(itemEndTime);
//
//       // Combine the date and time into a full DateTime object
//       if (parsedEndDate != null) {
//         parsedEndDateTime = DateTime(
//           parsedEndDate.year,
//           parsedEndDate.month,
//           parsedEndDate.day,
//           parsedEndTime.hour,
//           parsedEndTime.minute,
//         );
//       }
//     } else {
//       // If no time is provided, just use the date
//       if (parsedEndDate != null) {
//         parsedEndDateTime = DateTime(parsedEndDate.year, parsedEndDate.month,
//             parsedEndDate.day, 23, 59, 59); // End of the day
//       }
//     }
//
//     // Current date and time
//
//     // Check if the deadline has passed
//     bool isPastDeadline =
//         parsedEndDateTime != null && parsedEndDateTime.isBefore(DateTime.now());
//     return isPastDeadline;
//   }
//
//   bool compareWithCurrenDate(String? itemEndDate, String? itemEndTime) {
//     DateTime? parsedEndDateTime;
//     DateTime? parsedEndDate;
//     // Parse the end date string (DD/MM/YYYY) into a DateTime object
//
//     if (itemEndDate != null) {
//       parsedEndDate = DateFormat('dd/MM/yyyy').parse(itemEndDate);
//     }
//
//     // Check if endTime is provided
//     if (itemEndTime != null) {
//       // Parse the end time string (e.g., "09:30 AM")
//       final timeFormat = DateFormat('hh:mm a'); // For parsing "09:30 AM" format
//       final parsedEndTime = timeFormat.parse(itemEndTime);
//
//       // Combine the date and time into a full DateTime object
//       if (parsedEndDate != null) {
//         parsedEndDateTime = DateTime(
//           parsedEndDate.year,
//           parsedEndDate.month,
//           parsedEndDate.day,
//           parsedEndTime.hour,
//           parsedEndTime.minute,
//         );
//       }
//     } else {
//       // If no time is provided, just use the date
//       if (parsedEndDate != null) {
//         parsedEndDateTime = DateTime(parsedEndDate.year, parsedEndDate.month,
//             parsedEndDate.day, 23, 59, 59); // End of the day
//       }
//     }
//
//     // Current date and time
//
//     // Check if the deadline has passed
//     bool isPastDeadline =
//         parsedEndDateTime != null && parsedEndDateTime.isBefore(DateTime.now());
//     return isPastDeadline;
//   }
//
//   List<CardChecklistInvitedMembers> invitedMembersList = [];
//   List<CardChecklistInvitedMembers> invitedMembersListWithoutFilter = [];
//
//   String? searchInvitedMembersText;
//
//   void searchInvitedMembersList(String searchText) {
//     searchInvitedMembersText = searchText;
//     invitedMembersList = invitedMembersListWithoutFilter
//         .where((e) =>
//             e.memberName.toLowerCase().contains(searchText.toLowerCase()))
//         .toList();
//     if (invitedMembersFilterStatus != null) {
//       invitedMembersList = invitedMembersList
//           .where((e) =>
//               e.status.toLowerCase() ==
//               invitedMembersFilterStatus!.toLowerCase())
//           .toList();
//     }
//     if (invitedMembersFilterStartDate != null) {
//       invitedMembersList = invitedMembersList.where((e) {
//         if (e.startDate != null) {
//           return DateFormat('dd/MM/yyyy').parse(e.startDate!).isAtSameMomentAs(
//               DateFormat('dd MMM yyyy').parse(invitedMembersFilterStartDate!));
//         } else {
//           return false;
//         }
//       }).toList();
//     }
//     if (invitedMembersFilterEndDate != null) {
//       invitedMembersList = invitedMembersList.where((e) {
//         if (e.endDate != null) {
//           return DateFormat('dd/MM/yyyy').parse(e.endDate!).isAtSameMomentAs(
//               DateFormat('dd MMM yyyy').parse(invitedMembersFilterEndDate!));
//         } else {
//           return false;
//         }
//       }).toList();
//     }
//     update();
//   }
//
//   String? invitedMembersFilterStatus;
//   String? invitedMembersFilterStartDate;
//   String? invitedMembersFilterEndDate;
//   bool isFilterEnabled = false;
//
//   String getFileNameFromUrl(String url) {
//     String decodedUrl = Uri.decodeFull(url);
//     return decodedUrl
//         .substring(decodedUrl.lastIndexOf('/') + 1)
//         .split('?')
//         .first;
//   }
//
//   void enableFilter(bool value) {
//     isFilterEnabled = value;
//   }
//
//   void IsInvitedMemberFilterOn() {
//     if (invitedMembersFilterStatus != null ||
//         invitedMembersFilterStartDate != null ||
//         invitedMembersFilterEndDate != null) {
//       isFilterEnabled = true;
//       onApplyFilter();
//     } else {
//       isFilterEnabled = false;
//     }
//   }
//
//   void updateInvitedMembersFilterStatus(String value) {
//     invitedMembersFilterStatus = value;
//     update();
//   }
//
//   void updateInvitedMembersFilterStartDate(String value) {
//     invitedMembersFilterStartDate = value;
//     update();
//   }
//
//   void updateInvitedMembersFilterEndDate(String value) {
//     invitedMembersFilterEndDate = value;
//     update();
//   }
//
//   void resetInvitedMembersFilter() {
//     invitedMembersList = invitedMembersListWithoutFilter;
//     invitedMembersFilterStatus = null;
//     invitedMembersFilterStartDate = null;
//     invitedMembersFilterEndDate = null;
//   }
//
//   List<CardChecklistInvitedMembers> setFilter() {
//     invitedMembersList = invitedMembersListWithoutFilter;
//     if (searchInvitedMembersText != null) {
//       invitedMembersList = invitedMembersList
//           .where((e) => e.memberName
//               .toLowerCase()
//               .contains(searchInvitedMembersText!.toLowerCase()))
//           .toList();
//     }
//     if (invitedMembersFilterStatus != null) {
//       invitedMembersList = invitedMembersList
//           .where((e) =>
//               e.status.toLowerCase() ==
//               invitedMembersFilterStatus!.toLowerCase())
//           .toList();
//     }
//     if (invitedMembersFilterStartDate != null) {
//       invitedMembersList = invitedMembersList.where((e) {
//         if (e.startDate != null) {
//           return DateFormat('dd/MM/yyyy').parse(e.startDate!).isAtSameMomentAs(
//               DateFormat('dd MMM yyyy').parse(invitedMembersFilterStartDate!));
//         } else {
//           return false;
//         }
//       }).toList();
//     }
//     if (invitedMembersFilterEndDate != null) {
//       invitedMembersList = invitedMembersList.where((e) {
//         if (e.endDate != null) {
//           return DateFormat('dd/MM/yyyy').parse(e.endDate!).isAtSameMomentAs(
//               DateFormat('dd MMM yyyy').parse(invitedMembersFilterEndDate!));
//         } else {
//           return false;
//         }
//       }).toList();
//     }
//     return invitedMembersList;
//
//     //update();
//   }
//
//   void onApplyFilter() {
//     invitedMembersList = setFilter();
//     update();
//   }
//
//   List<String> currentCardMembers = [];
//
//   /// Sets the members of a board based on the given [boardModel].
//   ///
//   /// This function iterates over the board members in the [boardModel] and checks
//   /// if each member has a status of "invited". If a member has a status of
//   /// "invited", it is added to the [currentCardMembers] list.
//   void setMembers(BoardModel boardModel) {
//     if (boardModel.boardMember != null &&
//         boardModel.boardMember!.boardMembers!.isNotEmpty) {
//       currentCardMembers = [];
//       for (int i = 0; i < boardModel.boardMember!.boardMembers!.length; i++) {
//         if (boardModel.boardMember!.boardMembersStatus![i] == "invited") {
//           currentCardMembers
//               .add(boardModel.boardMember!.boardMembers![i].toString());
//         }
//       }
//       if (currentCardMembers.isNotEmpty) {
//         currentCardMembers = currentCardMembers.reversed.toList();
//         currentCardMembers
//             .add(Get.find<AddEmployeeController>().employeeEntity!.email!);
//         currentCardMembers = currentCardMembers.reversed.toList();
//       }
//     }
//   }
//
//   List<String> images = [];
//   int allMembersNum = 0;
//
//   // Retrieves the number of all invited members from the given [boardModel].
//   void getAllMembersNum(BoardModel boardModel) {
//     images = [];
//     allMembersNum = 0;
//     for (int i = 0; i < boardModel.boardMember!.boardMembers!.length; i++) {
//       if (boardModel.boardMember!.boardMembersStatus![i] == "invited") {
//         allMembersNum++;
//         images.add(getSingleImage(
//           boardModel.boardMember!.boardMembers![i],
//         ));
//       }
//     }
//     if (allMembersNum > 6) {
//       allMembersNum = allMembersNum - 6;
//     } else {
//       allMembersNum = 0;
//     }
//   }
//
//   /// Copies an existing card with the given [name], [cardModel], and [currentBoardName] to the database.
//   Future copyCard({
//     required String name,
//     required CardModel cardModel,
//     required String currentBoardName,
//     required context,
//   }) async {
//     loading = true;
//     update();
//     showLoadingIndicator();
//     String currentTime =
//         DateFormat("yyyy.MMMM.dd 'at' hh:mm aaa").format(DateTime.now());
//     currentTime = currentTime + math.Random().nextInt(100).toString();
//     if (name.isEmpty || !isFieldValid(name)) {
//       hideLoadingIndicator();
//       showDialog(
//         context: context,
//         builder: (context) {
//           return const SuccessDialog(
//             title: "Failure",
//             subtitle: "Please Fill All The Fields",
//             lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
//           );
//         },
//       );
//     } else {
//       // Check if the card name already exists in the database.
//       final CollectionReference cardsNames = db.collection('/Cards_Names');
//       await cardsNames
//           .doc(currentBoardName)
//           .get()
//           .then((DocumentSnapshot doc) async {
//         if (doc.exists) {
//           Map<String, dynamic> mapData = doc.data() as Map<String, dynamic>;
//           List<dynamic> listData = mapData['Cards_Names'];
//
//           if (listData.contains(name.toLowerCase().trimRight())) {
//             hideLoadingIndicator();
//             showDialog(
//               context: context,
//               builder: (context) {
//                 return const SuccessDialog(
//                   title: "Failure",
//                   subtitle: "This card name is already exist",
//                   lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
//                 );
//               },
//             );
//           } else {
//             CardModel copyCard =
//                 CardModel.fromMap(cardModel.toMap(), currentTime);
//             copyCard.cardName!.cardName = [name.toLowerCase().trimRight()];
//             copyCard.cardName!.timestamp = [Timestamp.now()];
//             // Create the card in the database.
//             final CollectionReference cardsCollection = db.collection('/Cards');
//             await cardsCollection
//                 .doc(currentBoardName)
//                 .collection("Cards")
//                 .doc(currentTime)
//                 .set(copyCard.toMap())
//                 .then((value) async {
//               // Add the card name to the database.
//               await cardsNames.doc(currentBoardName).set(
//                 {
//                   "Cards_Names":
//                       FieldValue.arrayUnion([name.toLowerCase().trimRight()]),
//                 },
//                 SetOptions(merge: true),
//               );
//               copyCard.cardId = currentTime;
//               BoardModel? board;
//               board = allBoards.firstWhere((element) =>
//                   element.boardName!.boardgName!.last ==
//                   currentBoardName.toLowerCase());
//               board.cards.add(copyCard);
//               updatefilterCards(
//                   board.cards, copyCard.cardStatus!.cardStatus!.last);
//               switch (copyCard.cardStatus!.cardStatus!.last) {
//                 case "todo":
//                   selectedIndex = 0;
//                   break;
//                 case "doing":
//                   selectedIndex = 1;
//                   break;
//                 case "done":
//                   selectedIndex = 2;
//                   break;
//                 case "archived":
//                   selectedIndex = 3;
//                   break;
//               }
//               update();
//               getAllBoards();
//               Navigator.pop(context);
//               hideLoadingIndicator();
//
//               showDialog(
//                 context: context,
//                 builder: (context) {
//                   return const SuccessDialog(
//                     title: "Successful",
//                     subtitle: "Card Added Successfully",
//                     lottieAsset: "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
//                   );
//                 },
//               );
//               //    systemLogsController.systemLogsAction(SystemActions.copyCard);
//               List<String> toMembers = [];
//               for (int i = 0;
//                   i < copyCard.cardMembers!.cardMembers!.length;
//                   i++) {
//                 if (copyCard.cardMembers!.cardMembersStatus![i] == "invited") {
//                   toMembers.add(copyCard.cardMembers!.cardMembers![i]);
//                   //appNotificationController.sendNotification("${copyCard.cardMembers!.cardMembers![i]}topic", "New Card Added", "${empFullName(copyCard.cardCreator!.cardCreator!.last).capitalize} has invited you to card: ${copyCard.cardName!.cardName!.last} in board: ${board.boardName!.boardgName!.last} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",copyCard.cardMembers!.cardMembers![i]);
//                 }
//               }
//               appNotificationController.sendNotificationToMultiple(
//                 type: 'card',
//                 topics: toMembers,
//                 title: "Invitation",
//                 arabicTitle: 'دعوة',
//                 body:
//                     "${empFullName(copyCard.cardCreator!.cardCreator!.last).capitalize} has invited you to card: ${copyCard.cardName!.cardName!.last} in board: ${board.boardName!.boardgName!.last} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//                 arabicBody:
//                     "${'لقد دعاك'} ${CurrentUserArabicName()} ${'إلي البطاقة:'} ${copyCard.cardName!.cardName!.last} ${'في لوحة:'} ${board.boardName!.boardgName!.last} ${'في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//               );
//               print('Card Is Added');
//             });
//           }
//         }
//       });
//     }
//     update();
//     loading = false;
//     //hideLoadingIndicator();
//   }
//
//   // Updates a card with various properties like card name, description, status, attachments, comments, etc.
//   Future updateCard({
//     required CardModel cardModel,
//     required String board,
//     BoardModel? boardModel,
//     List<String>? invitationMember,
//     String? startTime,
//     String? endTime,
//     String? startDate,
//     String? endDate,
//     String? checkList,
//     CardCheckLists? currentCheckList,
//     List<String>? listItemMember,
//     CheckListItems? currentListItem,
//     String? listItemStartDate,
//     String? listItemEndDate,
//     String? listItemStartTime,
//     String? listItemEndTime,
//     String? checkListStatus,
//     String? checkListItem,
//     String? checkListItemStatus,
//     String? checkListItemTitle,
//     String? attachment,
//     String? cardName,
//     String? cardDescription,
//     String? cardStatus,
//     bool? archiveReturn,
//     String? priority,
//     String? progress,
//     List<String>? cardAttachments,
//     bool? deleteAllAttachments,
//     String? comment,
//     String? cardImage,
//     List<String>? progressIndicators,
//     List<String>? progressColor,
//   }) async {
//     loading = true;
//     update();
//     // showLoadingIndicator();
//     List<String> currentCardMembers = [];
//     for (int i = 0; i < cardModel.cardMembers!.cardMembers!.length; i++) {
//       if (cardModel.cardMembers!.cardMembersStatus![i] == "invited") {
//         currentCardMembers.add(cardModel.cardMembers!.cardMembers![i]);
//       }
//     }
//
//     bool deadlineAdded = false;
//     if (startDate != null &&
//         endDate != null &&
//         startTime != null &&
//         endTime != null) {
//       deadlineAdded = true;
//     }
//     final CollectionReference cardCollection = db.collection('/Cards');
//
//     WriteBatch batch = db.batch();
//     List<String> lastInvitedCardMembers = [];
//     List<String> lastCardMembers = [];
//     List<String> removedCardMembers = [];
//     List<String> newCardMembers = [];
//
//     if (invitationMember != null /*&& invitationMember.isNotEmpty*/) {
//       for (int i = 0;
//           i < cardModel.cardMembers!.cardMembersStatus!.length;
//           i++) {
//         if (cardModel.cardMembers!.cardMembersStatus![i] == "invited") {
//           lastInvitedCardMembers.add(cardModel.cardMembers!.cardMembers![i]);
//         }
//       }
//       for (int i = 0;
//           i < cardModel.cardMembers!.cardMembersStatus!.length;
//           i++) {
//         if (cardModel.cardMembers!.cardMembersStatus![i] == "uninvited") {
//           lastCardMembers.add(cardModel.cardMembers!.cardMembers![i]);
//         }
//       }
//
//       cardModel.cardMembers!.timestamp!.add(Timestamp.now());
//       // Find Removed Members And Update Status
//       for (int i = 0; i < cardModel.cardMembers!.cardMembers!.length; i++) {
//         if (!invitationMember
//             .contains(cardModel.cardMembers!.cardMembers![i])) {
//           int removedIndex = cardModel.cardMembers!.cardMembers!
//               .indexOf(cardModel.cardMembers!.cardMembers![i]);
//           cardModel.cardMembers!.cardMembersStatus![removedIndex] = "uninvited";
//           removedCardMembers
//               .add(cardModel.cardMembers!.cardMembers![removedIndex]);
//         }
//       }
//
//       // Find New Members And Add Thier Status
//       for (int i = 0; i < invitationMember.length; i++) {
//         if (!cardModel.cardMembers!.cardMembers!
//             .contains(invitationMember[i])) {
//           cardModel.cardMembers!.cardMembers!.add(invitationMember[i]);
//           cardModel.cardMembers!.cardMembersStatus!.add("invited");
//           newCardMembers.add(invitationMember[i]);
//         } else {
//           cardModel.cardMembers!.cardMembersStatus![cardModel
//               .cardMembers!.cardMembers!
//               .indexOf(invitationMember[i])] = "invited";
//           newCardMembers.add(invitationMember[i]);
//           // cardModel.cardMembers!.cardMembersStatus![i] = "invited";
//         }
//       }
//     }
//
//     if (startDate != null) {
//       cardModel.startDate!.startDate!.add(startDate);
//       cardModel.startDate!.timestamp!.add(Timestamp.now());
//     }
//
//     if (endDate != null) {
//       cardModel.endDate!.endDate!.add(endDate);
//       cardModel.endDate!.timestamp!.add(Timestamp.now());
//     }
//
//     if (startTime != null) {
//       cardModel.startTime!.startTime!.add(startTime);
//       cardModel.startTime!.timestamp!.add(Timestamp.now());
//     }
//
//     if (endTime != null) {
//       cardModel.endTime!.endTime!.add(endTime);
//       cardModel.endTime!.timestamp!.add(Timestamp.now());
//     }
//     if (checkList != null) {
//       if (cardModel.cardCheckLists != null &&
//           cardModel.cardCheckLists!.isNotEmpty &&
//           currentCheckList != null) {
//         cardModel
//             .cardCheckLists![
//                 cardModel.cardCheckLists!.indexOf(currentCheckList)]
//             .checkListTitle!
//             .add(checkList);
//         cardModel
//             .cardCheckLists![
//                 cardModel.cardCheckLists!.indexOf(currentCheckList)]
//             .timestamp!
//             .add(Timestamp.now());
//       } else {
//         if (cardModel.cardCheckLists != null &&
//             cardModel.cardCheckLists!.isNotEmpty) {
//           cardModel.cardCheckLists!.add(CardCheckLists(
//             checkListTitle: [checkList],
//             checkListStatus: ["todo"],
//             timestamp: [Timestamp.now()],
//           ));
//         } else {
//           cardModel.cardCheckLists = [
//             CardCheckLists(
//               checkListTitle: [checkList],
//               checkListStatus: ["todo"],
//               timestamp: [Timestamp.now()],
//             )
//           ];
//         }
//       }
//
//       // cardModel.cardCheckLists!.checkListTitle!.add(checkList);
//       // cardModel.cardCheckLists![0].checkListStatus!.add("todo");
//       // cardModel.cardCheckLists![0].timestamp!.add(Timestamp.now());
//     }
//     // if (checkListItem != null) {
//     //   cardModel.cardCheckLists!.checkListItems!.add(CheckListItems(
//     //     itemTitle: [checkListItem],
//     //     itemStatus: ["todo"],
//     //     timestamp: [Timestamp.now()],
//     //   ));
//     // }
//     if (checkListItem != null && currentCheckList != null) {
//       if (cardModel
//                   .cardCheckLists![
//                       cardModel.cardCheckLists!.indexOf(currentCheckList)]
//                   .checkListItems !=
//               null &&
//           cardModel
//               .cardCheckLists![
//                   cardModel.cardCheckLists!.indexOf(currentCheckList)]
//               .checkListItems!
//               .isNotEmpty) {
//         cardModel
//             .cardCheckLists![
//                 cardModel.cardCheckLists!.indexOf(currentCheckList)]
//             .checkListItems!
//             .add(CheckListItems(
//           itemTitle: [checkListItem],
//           itemMembers: null,
//           itemStartDate: null,
//           itemEndDate: null,
//           itemStartTime: null,
//           itemEndTime: null,
//           itemStatus: ["todo"],
//           timestamp: [Timestamp.now()],
//         ));
//       } else {
//         cardModel
//             .cardCheckLists![
//                 cardModel.cardCheckLists!.indexOf(currentCheckList)]
//             .checkListItems = [
//           CheckListItems(
//             itemTitle: [checkListItem],
//             itemMembers: null,
//             itemStartDate: null,
//             itemEndDate: null,
//             itemStartTime: null,
//             itemEndTime: null,
//             itemStatus: ["todo"],
//             timestamp: [Timestamp.now()],
//           )
//         ];
//       }
//     }
//
//     List<String>? previousListItemMember;
//
//     if (listItemMember != null &&
//         currentCheckList != null &&
//         currentListItem != null) {
//       int cardCheckListIndex =
//           cardModel.cardCheckLists!.indexOf(currentCheckList);
//       int cardCheckListItemsIndex = cardModel
//           .cardCheckLists![cardCheckListIndex].checkListItems!
//           .indexOf(currentListItem);
//
//       previousListItemMember = cardModel.cardCheckLists![cardCheckListIndex]
//           .checkListItems![cardCheckListItemsIndex].itemMembers;
//
//       cardModel
//           .cardCheckLists![cardCheckListIndex]
//           .checkListItems![cardCheckListItemsIndex]
//           .itemMembers = listItemMember;
//     }
//
//     if (currentCheckList != null &&
//         currentListItem != null &&
//         (listItemStartDate != null ||
//             listItemEndDate != null ||
//             listItemStartTime != null ||
//             listItemEndTime != null)) {
//       int cardCheckListIndex =
//           cardModel.cardCheckLists!.indexOf(currentCheckList);
//       int cardCheckListItemsIndex = cardModel
//           .cardCheckLists![cardCheckListIndex].checkListItems!
//           .indexOf(currentListItem);
//
//       if (listItemStartDate != null) {
//         cardModel
//             .cardCheckLists![cardCheckListIndex]
//             .checkListItems![cardCheckListItemsIndex]
//             .itemStartDate = [listItemStartDate];
//       }
//       if (listItemEndDate != null) {
//         cardModel
//             .cardCheckLists![cardCheckListIndex]
//             .checkListItems![cardCheckListItemsIndex]
//             .itemEndDate = [listItemEndDate];
//       }
//       if (listItemStartTime != null) {
//         cardModel
//             .cardCheckLists![cardCheckListIndex]
//             .checkListItems![cardCheckListItemsIndex]
//             .itemStartTime = [listItemStartTime];
//       }
//       if (listItemEndTime != null) {
//         cardModel
//             .cardCheckLists![cardCheckListIndex]
//             .checkListItems![cardCheckListItemsIndex]
//             .itemEndTime = [listItemEndTime];
//       }
//     }
//
//     if (currentCheckList != null &&
//         checkListItemStatus != null &&
//         checkListItemTitle != null) {
//       int cardCheckListIndex =
//           cardModel.cardCheckLists!.indexOf(currentCheckList);
//
//       cardModel.cardCheckLists![cardCheckListIndex].checkListItems!
//           .where((element) => element.itemTitle!.last == checkListItemTitle)
//           .first
//           .itemStatus!
//           .add(checkListItemStatus);
//
//       cardModel.cardCheckLists![cardCheckListIndex].checkListItems!
//           .where((element) => element.itemTitle!.last == checkListItemTitle)
//           .first
//           .timestamp!
//           .add(Timestamp.now());
//     }
//
//     if (currentCheckList != null && checkListStatus != null) {
//       int cardCheckListIndex =
//           cardModel.cardCheckLists!.indexOf(currentCheckList);
//
//       print(checkListStatus);
//       print("delete check list");
//       print(cardModel.cardCheckLists![cardCheckListIndex].checkListTitle!.last);
//       cardModel.cardCheckLists![cardCheckListIndex].checkListStatus!
//           .add(checkListStatus);
//       cardModel.cardCheckLists![cardCheckListIndex].timestamp!
//           .add(Timestamp.now());
//
//       //  cardModel.cardCheckLists![0].checkListTitle!.clear();
//       // cardModel.cardCheckLists![0].checkListStatus!.clear();
//       // cardModel.cardCheckLists![0].checkListItems!.clear();
//       // cardModel.cardCheckLists![0].timestamp!.clear();
//     }
//
//     if (attachment != null) {
//       cardModel.cardAttachments!.cardAttachments!.add(fileUrl);
//       cardModel.cardAttachments!.cardAttachmentsStatus!.add("uploaded");
//       cardModel.cardAttachments!.timestamp!.add(Timestamp.now());
//     }
//
//     if (cardName != null) {
//       cardModel.cardName!.cardName!.add(cardName);
//       cardModel.cardName!.timestamp!.add(Timestamp.now());
//     }
//
//     if (cardDescription != null) {
//       cardModel.cardDescription!.cardDescription!.add(cardDescription);
//       cardModel.cardDescription!.timestamp!.add(Timestamp.now());
//     }
//
//     if (cardAttachments != null) {
//       cardModel.cardAttachments!.timestamp!.add(Timestamp.now());
//       // Find Removed attachments And Update Status
//       for (int i = 0;
//           i < cardModel.cardAttachments!.cardAttachments!.length;
//           i++) {
//         if (!cardAttachments
//             .contains(cardModel.cardAttachments!.cardAttachments![i])) {
//           cardModel.cardAttachments!.cardAttachmentsStatus![i] = "deleted";
//         }
//       }
//     }
//     if (deleteAllAttachments != null && deleteAllAttachments) {
//       cardModel.cardAttachments!.timestamp!.add(Timestamp.now());
//       // Find Removed attachments And Update Status
//       for (int i = 0;
//           i < cardModel.cardAttachments!.cardAttachments!.length;
//           i++) {
//         cardModel.cardAttachments!.cardAttachmentsStatus![i] = "deleted";
//       }
//     }
//     if (comment != null) {
//       cardModel.comments!.add(Comments(
//         commentCreator: [
//           Get.find<AddEmployeeController>().employeeEntity!.email!
//         ],
//         comment: [comment],
//         timestamp: [Timestamp.now()],
//       ));
//     }
//
//     if (cardImage != null) {
//       cardModel.cardImage!.cardImage!.add(cardImage);
//       cardModel.cardImage!.timestamp!.add(Timestamp.now());
//     }
//     if (cardStatus != null) {
//       print("${cardStatus}stattttttttttttttttttttttttus");
//       cardModel.cardStatus!.cardStatus!.add(cardStatus);
//       cardModel.cardStatus!.timestamp!.add(Timestamp.now());
//     }
//     if (priority != null) {
//       cardModel.cardPriority!.cardPriority!.add(priority);
//       cardModel.cardPriority!.timestamp!.add(Timestamp.now());
//     }
//     if (progress != null) {
//       cardModel.cardProgress!.cardProgress!.add(progress);
//       cardModel.cardProgress!.timestamp!.add(Timestamp.now());
//     }
//     if (progressIndicators != null && progressColor != null) {
//       cardModel.progressIndicator!.progressPercentage = progressIndicators;
//       cardModel.progressIndicator!.colors = progressColor;
//     }
//
//     cardModel.lastUpdate!.lastUpdate!.add(Timestamp.now());
//
//     batch.set(
//       cardCollection
//           .doc(board.capitalize)
//           .collection("Cards")
//           .doc(cardModel.cardId),
//       cardModel.toMap(),
//       SetOptions(merge: true),
//     );
//
//     await batch.commit().then((value) {
//       //filterCards.add(cardModel);
//       //boardModel!.cards.add(cardModel);
//       if (cardStatus != null) {
//         switch (cardStatus) {
//           case "todo":
//             {
//               updatefilterCards(boardModel!.cards, "todo");
//               selectedIndex = 0;
//             }
//             break;
//           case "doing":
//             {
//               updatefilterCards(boardModel!.cards, "doing");
//               selectedIndex = 1;
//             }
//             break;
//           case "done":
//             {
//               updatefilterCards(boardModel!.cards, "done");
//               selectedIndex = 2;
//             }
//             break;
//           case "archived":
//             {
//               updatefilterCards(boardModel!.cards, "archived");
//               selectedIndex = 3;
//             }
//             break;
//           case "deleted":
//             {
//               updatefilterCards(boardModel!.cards, "deleted");
//               selectedIndex = 4;
//               // boardModel!.cards.removeWhere((element) =>  element.cardId == cardModel.cardId);
//               // filterCards.removeWhere((element) =>  element.cardId == cardModel.cardId);
//             }
//             break;
//         }
//         //   systemLogsController.systemLogsAction(SystemActions.updateCardStatus);
//         /* for( int i = 0; i < cardModel.cardMembers!.cardMembers!.length; i++){
//                 if(cardModel.cardMembers!.cardMembersStatus![i] == "invited"){
//                   appNotificationController.sendNotification("${cardModel.cardMembers!.cardMembers![i]}topic", cardModel.cardName!.cardName!.last, "${empFullName(cardModel.cardCreator!.cardCreator!.last)} has updated status of card: ${cardModel.cardName!.cardName!.last} to ${cardModel.cardStatus!.cardStatus!.last} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",);
//                 }
//               }
//               */
//         appNotificationController.sendNotificationToMultiple(
//           type: 'card',
//           topics: currentCardMembers,
//           title: cardModel.cardName!.cardName!.last,
//           arabicTitle: cardModel.cardName!.cardName!.last,
//           body:
//               "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has updated status of the card to ${cardModel.cardStatus!.cardStatus!.last} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//           arabicBody:
//               "${'قام'} ${CurrentUserArabicName()} ${'بتحديث حالة البطاقة إلى'} ${cardModel.cardStatus!.cardStatus!.last.capitalize!.tr} ${'في'} ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//         );
//         //  currentCardMembers.forEach((element) {
//         //       appNotificationController.sendNotification("${element}topic", cardModel.cardName!.cardName!.last, "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has updated status of card: ${cardModel.cardName!.cardName!.last} to ${cardModel.cardStatus!.cardStatus!.last} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",element);
//         //   });
//       }
//       if (cardAttachments != null || attachment != null) {
//         if (cardModel.cardAttachments!.cardAttachments!.isNotEmpty) {
//           allAttachments = [];
//           for (int i = 0;
//               i < cardModel.cardAttachments!.cardAttachments!.length;
//               i++) {
//             if (cardModel.cardAttachments!.cardAttachmentsStatus![i] ==
//                 "uploaded") {
//               allAttachments
//                   .add(cardModel.cardAttachments!.cardAttachments![i]);
//             }
//           }
//         }
//         if (attachment != null && attachment == "attached") {
//           appNotificationController.sendNotificationToMultiple(
//             type: 'card',
//             topics: currentCardMembers,
//             title: cardModel.cardName!.cardName!.last,
//             arabicTitle: cardModel.cardName!.cardName!.last,
//             body:
//                 "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has added an attachment to the card on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//             arabicBody:
//                 "${'قام'} ${CurrentUserArabicName()} ${'بإضافة مرفق إلي البطاقة في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", "ar").format(DateTime.now())}",
//           );
//           //  currentCardMembers.forEach((element) {
//           //   appNotificationController.sendNotification("${element}topic", cardModel.cardName!.cardName!.last, "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has added an attachment to card: ${cardModel.cardName!.cardName!.last} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",element);
//           // });
//         } else {
//           appNotificationController.sendNotificationToMultiple(
//             type: 'card',
//             topics: currentCardMembers,
//             title: cardModel.cardName!.cardName!.last,
//             arabicTitle: cardModel.cardName!.cardName!.last,
//             body:
//                 "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has deleted an attachment from the card on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//             arabicBody:
//                 "${'قام'} ${CurrentUserArabicName()} ${'بحذف مرفق من البطاقة في'}  ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//           );
//         }
//       }
//
//       if (startDate != null) {
//         hintStartDate = DateFormat("dd/MM/yyyy")
//             .format(DateTime.parse(startDate.toString()));
//         if (!deadlineAdded) {
//           appNotificationController.sendNotificationToMultiple(
//             type: 'card',
//             topics: currentCardMembers,
//             title: cardModel.cardName!.cardName!.last,
//             arabicTitle: cardModel.cardName!.cardName!.last,
//             body:
//                 "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has updated start date of the card  to $hintStartDate on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//             arabicBody:
//                 "${'قام'} ${CurrentUserArabicName()} ${'بتحديث تاريخ بدء البطاقة إلي'}  ${DateFormat("yyyy/MM/dd", 'ar').format(DateTime.parse(hintStartDate))} ${'في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//           );
//         }
//       }
//       if (endDate != null) {
//         hintEndDate =
//             DateFormat("dd/MM/yyyy").format(DateTime.parse(endDate.toString()));
//         if (deadlineAdded == false) {
//           appNotificationController.sendNotificationToMultiple(
//             type: 'card',
//             topics: currentCardMembers,
//             title: cardModel.cardName!.cardName!.last,
//             arabicTitle: cardModel.cardName!.cardName!.last,
//             body:
//                 "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has updated end date of the card to $hintEndDate on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//             arabicBody:
//                 "${'قام'} ${CurrentUserArabicName()} ${'بتحديث تاريخ نهاية البطاقة إلي'} ${DateFormat("yyyy/MM/dd", 'ar').format(DateTime.parse(hintEndDate))} ${'في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//           );
//         }
//       }
//       if (startTime != null) {
//         startTimeHint = startTime
//             .toString(); /*DateFormat("hh:mm a").format(
//         DateTime.parse(startTime.toString()));*/
//         if (deadlineAdded == false) {
//           appNotificationController.sendNotificationToMultiple(
//             type: 'card',
//             topics: currentCardMembers,
//             title: cardModel.cardName!.cardName!.last,
//             arabicTitle: cardModel.cardName!.cardName!.last,
//             body:
//                 "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has updated start time of the card to $startTimeHint on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//             arabicBody:
//                 "${'قام'} ${CurrentUserArabicName()} ${'بتحديث وقت بدء البطاقة إلي'}${convertTimeToArabic(startTimeHint)} ${'في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//           );
//         }
//       }
//       if (endTime != null) {
//         endTimeHint = endTime
//             .toString(); /* DateFormat("hh:mm a").format(
//         DateTime.parse(endTime.toString()));*/
//         if (deadlineAdded == false) {
//           appNotificationController.sendNotificationToMultiple(
//             type: 'card',
//             topics: currentCardMembers,
//             title: cardModel.cardName!.cardName!.last,
//             arabicTitle: cardModel.cardName!.cardName!.last,
//             body:
//                 "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has updated end time of the card to $endTimeHint on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//             arabicBody:
//                 "${'قام'} ${CurrentUserArabicName()} ${'بتحديث وقت نهاية البطاقة إلي'}  ${convertTimeToArabic(endTimeHint)} ${'في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//           );
//         }
//       }
//
//       if (deadlineAdded) {
//         appNotificationController.sendNotificationToMultiple(
//           type: 'card',
//           topics: currentCardMembers,
//           title: cardModel.cardName!.cardName!.last,
//           arabicTitle: cardModel.cardName!.cardName!.last,
//           body:
//               "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has added deadline to the card on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//           arabicBody:
//               "${'قام'} ${CurrentUserArabicName()} ${'بإضافة الموعد النهائي للبطاقة في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//         );
//       }
//       if (priority != null) {
//         appNotificationController.sendNotificationToMultiple(
//           type: 'card',
//           topics: currentCardMembers,
//           title: cardModel.cardName!.cardName!.last,
//           arabicTitle: cardModel.cardName!.cardName!.last,
//           body:
//               "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has updated the card priority to $priority on ${DateFormat("yyyy.MMMM.dd 'at' hh:mm aaa").format(DateTime.now())}",
//           arabicBody:
//               "${'قام'} ${CurrentUserArabicName()} ${'بتحديث أولوية البطاقة إلي:'} ${priority.capitalize} ${'في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//         );
//       }
//       if (progress != null) {
//         appNotificationController.sendNotificationToMultiple(
//           type: 'card',
//           topics: currentCardMembers,
//           title: cardModel.cardName!.cardName!.last,
//           arabicTitle: cardModel.cardName!.cardName!.last,
//           body:
//               "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has updated the card progress to $progress% on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//           arabicBody:
//               "${'قام'} ${CurrentUserArabicName()} ${'بتحديث تقدم البطاقة إلي'} ${convertNumberToArabic(progress)}% ${'في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//         );
//       }
//       if (comment != null) {
//         appNotificationController.sendNotificationToMultiple(
//           type: 'card',
//           topics: currentCardMembers,
//           title: cardModel.cardName!.cardName!.last,
//           arabicTitle: cardModel.cardName!.cardName!.last,
//           body:
//               "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} commented on card: ${cardModel.cardName!.cardName!.last} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//           arabicBody:
//               "${'علق'} ${CurrentUserArabicName()} ${'على البطاقة في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//         );
//       }
//       if (checkList != null) {
//         if (currentCheckList != null) {
//           appNotificationController.sendNotificationToMultiple(
//             type: 'card',
//             topics: currentCardMembers,
//             title: cardModel.cardName!.cardName!.last,
//             arabicTitle: cardModel.cardName!.cardName!.last,
//             body:
//                 "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has updated the checklist: ${currentCheckList.checkListTitle?.last ?? ''} in the card: ${cardModel.cardName!.cardName!.last.capitalize} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//             arabicBody:
//                 "${'قام'} ${CurrentUserArabicName()} ${'بتعديل القائمة المرجعية: ${currentCheckList.checkListTitle?.last ?? ''} في البطاقة: ${cardModel.cardName!.cardName!.last.capitalize} في '} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//           );
//         } else {
//           appNotificationController.sendNotificationToMultiple(
//             type: 'card',
//             topics: currentCardMembers,
//             title: cardModel.cardName!.cardName!.last,
//             arabicTitle: cardModel.cardName!.cardName!.last,
//             body:
//                 "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has added checklist to the card: ${cardModel.cardName!.cardName!.last.capitalize} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//             arabicBody:
//                 "${'قام'} ${CurrentUserArabicName()} ${'بإضافة قائمة مرجعية للبطاقة: ${cardModel.cardName!.cardName!.last.capitalize} في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//           );
//         }
//       }
//
//       ////////////////////////////////////
//       if (currentCheckList != null &&
//           currentListItem != null &&
//           (listItemStartDate != null ||
//               listItemEndDate != null ||
//               listItemStartTime != null ||
//               listItemEndTime != null)) {
//         // if (listItemStartDate != null) {
//
//         appNotificationController.sendNotificationToMultiple(
//           type: 'card',
//           topics: currentCardMembers,
//           title: cardModel.cardName!.cardName!.last,
//           arabicTitle: cardModel.cardName!.cardName!.last,
//           body:
//               "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has updated the checklist: ${currentCheckList.checkListTitle?.last ?? ''} in the card: ${cardModel.cardName!.cardName!.last.capitalize} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//           arabicBody:
//               "${'قام'} ${CurrentUserArabicName()} ${'بتعديل القائمة المرجعية: ${currentCheckList.checkListTitle?.last ?? ''} في البطاقة: ${cardModel.cardName!.cardName!.last.capitalize} في '} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//         );
//
//         // }
//         // if (listItemEndDate != null) {
//
//         // }
//         // if (listItemStartTime != null) {
//
//         // }
//         // if (listItemEndTime != null) {
//
//         // }
//       }
//
//       if (currentCheckList != null &&
//           checkListItemStatus != null &&
//           checkListItemTitle != null) {
//         appNotificationController.sendNotificationToMultiple(
//           type: 'card',
//           topics: currentCardMembers,
//           title: cardModel.cardName!.cardName!.last,
//           arabicTitle: cardModel.cardName!.cardName!.last,
//           body:
//               "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has updated the checklist item: $checkListItemTitle in the checklist: ${currentCheckList.checkListTitle?.last ?? ''} in the card: ${cardModel.cardName!.cardName!.last.capitalize} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//           arabicBody:
//               "${'قام'} ${CurrentUserArabicName()} ${'بتعديل عنصر: $checkListItemTitle في القائمة المرجعية: ${currentCheckList.checkListTitle?.last ?? ''} في البطاقة: ${cardModel.cardName!.cardName!.last.capitalize} في '} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//         );
//       }
//       if (currentCheckList != null &&
//           checkListStatus != null &&
//           checkListStatus == "deleted") {
//         appNotificationController.sendNotificationToMultiple(
//           type: 'card',
//           topics: currentCardMembers,
//           title: cardModel.cardName!.cardName!.last,
//           arabicTitle: cardModel.cardName!.cardName!.last,
//           body:
//               "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has deleted the checklist: ${currentCheckList.checkListTitle?.last ?? ''} from the card: ${cardModel.cardName!.cardName!.last.capitalize} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//           arabicBody:
//               "${'قام'} ${CurrentUserArabicName()} ${'بحذف القائمة المرجعية: ${currentCheckList.checkListTitle?.last ?? ''} من البطاقة: ${cardModel.cardName!.cardName!.last.capitalize} في '} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//         );
//       }
//
//       if (listItemMember != null &&
//           currentCheckList != null &&
//           currentListItem != null) {
//         if (previousListItemMember != null &&
//             previousListItemMember.isNotEmpty) {
//           List<String> toMembers = [];
//           List<String> otherMembers = [];
//           for (var element in previousListItemMember) {
//             if (!listItemMember.contains(element)) {
//               toMembers.add(element);
//             }
//           }
//           otherMembers = cardModel.cardMembers!.cardMembers!
//               .where((element) => !toMembers.contains(element))
//               .toList();
//
//           appNotificationController.sendNotificationToMultiple(
//             type: 'card',
//             topics: otherMembers,
//             title: cardModel.cardName!.cardName!.last,
//             arabicTitle: cardModel.cardName!.cardName!.last,
//             body:
//                 "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has updated the checklist ${currentCheckList.checkListTitle?.last ?? ''} in the card: ${cardModel.cardName!.cardName!.last.capitalize} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//             arabicBody:
//                 "${'قام'} ${CurrentUserArabicName()} ${'بتعديل القائمة المرجعية: ${currentCheckList.checkListTitle?.last ?? ''} في البطاقة: ${cardModel.cardName!.cardName!.last.capitalize} في '} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//           );
//
//           appNotificationController.sendNotificationToMultiple(
//             type: 'card',
//             topics: toMembers,
//             title: cardModel.cardName!.cardName!.last,
//             arabicTitle: cardModel.cardName!.cardName!.last,
//             body:
//                 "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has assigned you to the checklist ${currentCheckList.checkListTitle?.last ?? ''} in the card: ${cardModel.cardName!.cardName!.last.capitalize} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//             arabicBody:
//                 "${'قام'} ${CurrentUserArabicName()} ${'بتعيينك في القائمة المرجعية: ${currentCheckList.checkListTitle?.last ?? ''} في البطاقة: ${cardModel.cardName!.cardName!.last.capitalize} في '} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//           );
//         }
//       }
//
//       if (invitationMember != null && newCardMembers.isNotEmpty) {
//         List<String> toMembers = [];
//         for (var element in newCardMembers) {
//           if (!lastInvitedCardMembers.contains(element)) {
//             toMembers.add(element);
//             //  appNotificationController.sendNotification("${element}topic", "Invitation", "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has invited you to card: ${cardModel.cardName!.cardName!.last} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",element);
//           }
//         }
//         appNotificationController.sendNotificationToMultiple(
//           type: 'card',
//           topics: toMembers,
//           title: "Invitation",
//           arabicTitle: 'دعوة',
//           body:
//               "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has invited you to card: ${cardModel.cardName!.cardName!.last} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//           arabicBody:
//               "${'لقد دعاك'} ${CurrentUserArabicName()} ${'إلي البطاقة:'} ${cardModel.cardName!.cardName!.last} ${'في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//         );
//       }
//       if (removedCardMembers.isNotEmpty) {
//         List<String> toMembers = [];
//
//         for (String element in removedCardMembers) {
//           if (!lastCardMembers.contains(element)) {
//             toMembers.add(element);
//             // appNotificationController.sendNotification("${element}topic", "Invitation", "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has removed you from card: ${cardModel.cardName!.cardName!.last} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",element);
//           }
//         }
//         appNotificationController.sendNotificationToMultiple(
//           type: 'card',
//           topics: toMembers,
//           title: cardModel.cardName!.cardName!.last,
//           arabicTitle: cardModel.cardName!.cardName!.last,
//           body:
//               "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has removed you from the card on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//           arabicBody:
//               "${'قام'} ${CurrentUserArabicName()} ${'بإزالتك من البطاقة في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//         );
//       }
//       if (deleteAllAttachments != null && deleteAllAttachments) {
//         appNotificationController.sendNotificationToMultiple(
//           type: 'card',
//           topics: currentCardMembers,
//           title: cardModel.cardName!.cardName!.last,
//           arabicTitle: cardModel.cardName!.cardName!.last,
//           body:
//               "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has deleted all attachments from the card on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//           arabicBody:
//               "${'قام'} ${CurrentUserArabicName()} ${'بحذف جميع المرفقات من البطاقة في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//         );
//       }
//       if (checkListStatus != null && checkListStatus == "deleted") {
//         appNotificationController.sendNotificationToMultiple(
//           type: 'card',
//           topics: currentCardMembers,
//           title: cardModel.cardName!.cardName!.last,
//           arabicTitle: cardModel.cardName!.cardName!.last,
//           body:
//               "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has deleted checklist from the card on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
//           arabicBody:
//               "${'قام'} ${CurrentUserArabicName()} ${'بحذف قائمة مرجعية من البطاقة في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
//         );
//       }
//       update();
//       getAllBoards();
//       if (checkListItem == null &&
//           checkListItemTitle == null &&
//           checkListStatus == null &&
//           cardAttachments == null &&
//           comment == null &&
//           cardImage == null &&
//           archiveReturn != true &&
//           priority == null &&
//           progress == null &&
//           startDate == null &&
//           endDate == null &&
//           startTime == null &&
//           // progressColor == null &&
//           // progressIndicators == null &&
//           endTime == null) //Get.back();
//         //  systemLogsController.systemLogsAction(SystemActions.updateCardDetails);
//         fileName = null;
//       fileUrl = "";
//     });
//     update();
//     loading = false;
//     //hideLoadingIndicator();
//   }
//
//   List<String> allAttachments = [];
//
//   String startTimeHint = "12:00 AM";
//   String endTimeHint = "12:00 AM";
//   String hintStartDate = "DD/MM/YYYY";
//   String hintEndDate = "DD/MM/YYYY";
//
//   // Asynchronously retrieves employees for each department and populates the departmentsEmployees map with the respective employees based on department matching.
//   Map<String, List<EmployeeEntity>> departmentsEmployees = {};
//   Future<void> getDepartmentEmployees() async {
//     for (var department in allDepartments) {
//       List<EmployeeEntity> employees = [];
//       for (var element in addEmployeeController.allEmployeesEntities!) {
//         if (element.departmentId! == department) {
//           employees.add(element);
//         }
//       }
//       departmentsEmployees[department.toLowerCase().trimRight()] = employees;
//     }
//   }
//
//   String cardImageUrl = "";
//   // A function to update the image of a card, taking the CardModel and board as required parameters.
//   Future<void> updateCardImage({
//     required CardModel cardModel,
//     required String board,
//   }) async {
//     if (cardImageUrl != "") {
//       await FirebaseStorage.instance
//           .refFromURL(cardImageUrl)
//           .delete()
//           .then((value) {
//         cardImageUrl = "";
//       });
//     }
//     XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     showLoadingIndicator();
//     if (pickedFile != null) {
//       _image = File(pickedFile.path);
//       Reference ref = FirebaseStorage.instance
//           .ref()
//           .child('/card_images/${DateTime.now()}.jpeg');
//       final metadata = SettableMetadata(contentType: 'image/jpeg');
//       UploadTask uploadTask = ref.putFile(_image!, metadata);
//       TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
//       // cardImageUrl = await taskSnapshot.ref.getDownloadURL();
//       await taskSnapshot.ref.getDownloadURL().then((value) {
//         updateCard(
//           cardModel: cardModel,
//           board: board,
//           cardImage: value,
//         );
//       });
//     }
//     hideLoadingIndicator();
//     update();
//   }
//
//   /// Returns the image URL or asset path for a single employee based on their email.
//   String getSingleImage(String email) {
//     return addEmployeeController.getEmployeePhoto(email);
//   }
//
//   // Returns the full name of an employee based on the provided email.
//   String empFullName(String email, {bool thirdName = false}) {
//     return addEmployeeController.getEmployeeName(email);
//   }
//
//   List<String>? cardProgressPercentageList;
//   String? cardProgressPercentageValue;
//   List<String>? cardColorsList;
//
//   String? cardSelectedIncreament;
//
//   void updatecardSelectedIncreament(increament) {
//     cardSelectedIncreament = increament;
//     update();
//   }
//
//   void onChnagedColorDropDown(List<String>? colorsList,
//       List<String>? progressPercentageList, String? progressPercentageValue) {
//     cardProgressPercentageValue = progressPercentageValue;
//     cardProgressPercentageList = progressPercentageList;
//     cardColorsList = colorsList;
//     update();
//   }
//
//   void updateColorDropDown(CardModel card) {
//     cardProgressPercentageValue =
//         card.progressIndicator!.progressPercentage![0];
//     cardProgressPercentageList = card.progressIndicator!.progressPercentage!;
//     cardColorsList = card.progressIndicator!.colors!;
//     // cardProgressPercentageList!.removeAt(0);
//     //update();
//   }
//
//   Color getProgressColor(String value) {
//     if (value == "red") {
//       return AppColors.delete;
//     } else if (value == "orange") {
//       return AppColors.warning;
//     } else if (value == "yellow") {
//       return AppColors.signOut;
//     } else {
//       return AppColors.unBlock;
//     }
//   }
//
//   String? fileName;
//   String fileUrl = "";
//
//   // Picks a file and uploads it based on the specified card name.
//   FilePickerResult? pickedPdf;
//   Future<void> pickAndUploadFile(String cardName) async {
//     pickedPdf = null;
//     fileName = null;
//     pickedPdf = await FilePicker.platform.pickFiles(
//       type: FileType.any,
//     );
//     if (pickedPdf != null) {
//       showLoadingIndicator();
//       final file = File(pickedPdf!.files.single.path!);
//       String filePath = pickedPdf!.files.single.path!;
//       fileName = basename(filePath);
//
//       if (isImage(filePath)) {
//         Reference ref = FirebaseStorage.instance
//             .ref()
//             .child('Cards/$cardName/${DateTime.now()}/$fileName.png');
//         final metadata = SettableMetadata(contentType: 'image/jpeg');
//         final TaskSnapshot task = await ref.putFile(file, metadata);
//         fileUrl = await task.ref.getDownloadURL();
//       } else {
//         final Reference storageRef = FirebaseStorage.instance
//             .ref()
//             .child('Cards/$cardName/${DateTime.now()}/$fileName');
//         //final metadata = SettableMetadata(contentType: 'application/pdf');
//         final TaskSnapshot task = await storageRef.putFile(
//           file, /*metadata*/
//         );
//         fileUrl = await task.ref.getDownloadURL();
//       }
//       hideLoadingIndicator();
//     }
//     update();
//   }
//
//   /// Checks if the given [filePath] is an image file by checking if it contains any of the known image extensions.
//   bool isImage(String filePath) {
//     bool flag = false;
//     for (String imageExtention in imageExtentions) {
//       if (filePath.contains(imageExtention)) {
//         return true;
//       }
//     }
//     return flag;
//   }
//
//   // Known image extentions
//   List<String> imageExtentions = [
//     ".PSD",
//     ".XCF",
//     ".AI",
//     ".CDR",
//     ".tif",
//     ".tiff",
//     ".bmp",
//     ".jpg",
//     ".jpeg",
//     ".gif",
//     ".png",
//     ".eps",
//     ".raw",
//     ".cr2",
//     ".nef",
//     ".orf",
//     ".sr2"
//   ];
//
//   // Returns the abbreviation of a given string.
//   List<String> abbreviation = [
//     "it",
//     "hr",
//     'ui ux',
//     'log',
//     'qa',
//     'pr',
//     'dev',
//     'ceo'
//   ];
//   // Returns the abbreviation in uppercase if it exists in the list, otherwise returns the original abbreviation.
//   String containAbbreviation(String abbrev) {
//     print(abbrev);
//     if (abbreviation.contains(abbrev)) {
//       return abbrev.toUpperCase();
//     } else {
//       return abbrev.capitalize!;
//     }
//   }
//
//   bool onBoardSearch = false;
//   bool onCardSearch = false;
//   bool onCardMemeberSearch = false;
//
// // Checks if the given text is a valid field by verifying if it contains any letter.
//   bool isFieldValid(String text) {
//     // Regular expression to match any letter
//     RegExp regex = RegExp(r'[a-zA-Z]');
//
//     // Check if the text contains any letter
//     return regex.hasMatch(text);
//   }
//
//   List<CardModel> filterCards = [];
//   int selectedIndex = 0;
//
// // Updates the filter cards based on the given list of cards and a status.
//   updatefilterCards(List<CardModel> cards, String status) {
//     filterCards = [];
//     for (var element in cards) {
//       if (element.cardStatus!.cardStatus!.last == status) {
//         filterCards.add(element);
//       }
//     }
//     update();
//   }
//
//   @override
//   void onInit() {
//     getDepartments();
//     getEmployee();
//     getAllEmployees().then((value) {
//       getAllBoards();
//       //getDepartmentEmployees();
//       update();
//     });
//     super.onInit();
//   }
// }
