import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_appbar.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/success_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/loading.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_department.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_description.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_image.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_members.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_name.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_tasks.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/messaging_channels.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_attachments.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_checklists.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_creator.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_description.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_image.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_members.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_name.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_priority.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_progress.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_progress_color.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_status.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/checklist_item.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/comment.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/end_date.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/end_time.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/last_update.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/start_date.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/start_time.dart';
import 'package:demo_app/features/department/presentation/controller/add_department_controller.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/network/get_base_url.dart';
import 'package:demo_app/core/theme/app_colors.dart';

// Name: Nour Nabil
// date: 22/2
// last Update: 22/2
// Objective: create new controller for Board screen
class BoardController extends GetxController {
  /// on-Init
  @override
   void onInit() {
    // ✅ FIXED: Use async initialization with proper error handling
    _initializeController();
    super.onInit();
  }


  Future<void> _initializeController() async {
    try {
      // print("🔵 BoardController: Starting initialization...");

      // Step 1: Get departments (doesn't need employee data)
      await getDepartments();
      // print("✓ Departments loaded");

      // Step 2: Get current employee (this should work if MainCoreEmployeeController is initialized)
      await getEmployee();
      // print("✓ Current employee loaded");

      // Step 3: Get all employees (now safe because employee is initialized)
      await getAllEmployees();
      // print("✓ All employees loaded");

      // Step 4: Load boards
      await getAllBoards();
      // print("✓ All boards loaded");

      // print("🟢 BoardController: Initialization complete");
      update();
    } catch (e, stackTrace) {
      // print("🔴 BoardController initialization error: $e");
      // print("Stack trace: $stackTrace");
      loading = false;
      update();
    }
  }

  // ----------statics-------------
  FirebaseFirestore db = FirebaseFirestore.instance;
  TaskDetailsController get taskDetailsController => Get.find();
  bool loading = false;
  DateTime now = DateTime.now();
  String? fileName;
  String fileUrl = "";
  List<CardModel> filterCards = [];
  int selectedIndex = 0;
  List<BoardModel> allBoards = [];
  List<BoardModel> boards = [];
  bool onBoardSearch = false;
  bool onCardSearch = false;
  bool onSearchEmployee = false;
  ImagePicker picker = ImagePicker();
  File? _image;
  String imageUrl = "";
  String? cardProgressPercentageValue;
  List<String>? cardProgressPercentageList;
  List<String>? cardColorsList;
  String? cardSelectedIncreament;
  List<String> allDepartments = [];
  String selectedDepartment =
  Get.locale.toString().contains('en') ? 'All' : 'الكل';
  // Returns the abbreviation of a given string.
  List<String> abbreviation = [
    "it",
    "hr",
    'ui ux',
    'log',
    'qa',
    'pr',
    'dev',
    'ceo'
  ];

  //------------statics end------------

  /// --------> Function <----------///
  // Returns the abbreviation in uppercase if it exists in the list, otherwise returns the original abbreviation.
  String containAbbreviation(String abbrev) {
    // print(abbrev);
    if (abbreviation.contains(abbrev)) {
      return abbrev.toUpperCase();
    } else {
      return abbrev.capitalize!;
    }
  }

  MainCoreDepartmentController addDepartmentController = Get.find();
  MainCoreEmployeeController addEmployeeController = Get.find();

  // A function that fetches all employees,
  // updates the list, and filters only the active ones.
  Future<void> getAllEmployees() async {
    try {
      final mainController = Get.find<MainCoreEmployeeController>();

      // Only proceed if employeeEntity is initialized
      if (mainController.employeeEntity != null) {
        await addEmployeeController.getAllNewEmployees();
        // print("✓ BoardController: All employees loaded");
      } else {
        // print("⚠️ BoardController: Skipping getAllNewEmployees - employeeEntity not initialized");
      }

      update();
    } catch (e) {
      // print("❌ BoardController.getAllEmployees error: $e");
    }
  }


  // A function to retrieve an employee using the provided email address asynchronously.
  Future<void> getEmployee() async {
    try {
      // Wait for MainCoreEmployeeController to have employeeEntity
      final mainController = Get.find<MainCoreEmployeeController>();

      // Check if employeeEntity is available
      if (mainController.employeeEntity?.email == null) {
        // print("⚠️ BoardController: employeeEntity not yet available, waiting...");
        // Give it a moment to initialize
        await Future.delayed(Duration(milliseconds: 500));
      }

      if (mainController.employeeEntity?.email != null) {
        await addEmployeeController.getNewEmployee(mainController.employeeEntity!.email!);
        // print("✓ BoardController: Employee loaded successfully");
      } else {
        // print("⚠️ BoardController: Could not load employee - employeeEntity still null");
      }

      update();
    } catch (e) {
      // print("❌ BoardController.getEmployee error: $e");
    }
  }

  Future<void> getDepartments() async {
    await addDepartmentController.getAllDepartments();
    loading = false;
    update();
  }

  Color getProgressColor(String value) {
    if (value == "red") {
      return AppColors.delete;
    } else if (value == "orange") {
      return AppColors.warning;
    } else if (value == "yellow") {
      return AppColors.signOut;
    } else {
      return AppColors.unBlock;
    }
  }

  //copy card
  Future<void> copyCard({
    required String name,
    required CardModel cardModel,
    required String currentBoardName,
    required BuildContext context,
  }) async {
    if (name.isEmpty || !isFieldValid(name)) {
      _showFailureDialog(context, "Please Fill All The Fields");
      return;
    }

    loading = true;
    update();
    showLoadingIndicator();

    String currentTime = _generateUniqueTimestamp();

    try {
      // Reference to the card names collection
      final CollectionReference cardsNamesRef =
      db.collection(getBaseUrl('Cards_Names'));
      final DocumentSnapshot cardNamesDoc =
      await cardsNamesRef.doc(currentBoardName).get();

      if (cardNamesDoc.exists) {
        List<dynamic> existingCardNames =
            (cardNamesDoc.data() as Map<String, dynamic>)['Cards_Names'] ?? [];

        if (existingCardNames.contains(name.toLowerCase().trimRight())) {
          hideLoadingIndicator();
          _showFailureDialog(context, "This card name already exists");
          return;
        }
      }

      // Create a copy of the card with a new timestamp
      CardModel newCard = _createCopiedCard(cardModel, name, currentTime);

      // Reference to the cards collection
      final CollectionReference cardsRef = db.collection(getBaseUrl('Cards'));

      // Store the new card in Firestore
      await cardsRef
          .doc(currentBoardName)
          .collection(getBaseUrl('Cards'))
          .doc(currentTime)
          .set(newCard.toMap());

      // Add the new card name to the database
      await cardsNamesRef.doc(currentBoardName).set(
        {
          "Cards_Names": FieldValue.arrayUnion([name.toLowerCase().trimRight()])
        },
        SetOptions(merge: true),
      );

      // Update local board state
      _updateBoardState(newCard, currentBoardName);

      // Notify members
      _notifyCardMembers(newCard, currentBoardName);

      hideLoadingIndicator();
      _showSuccessDialog(context, "Card Added Successfully");
    } catch (e) {
      hideLoadingIndicator();
      _showFailureDialog(context, "Error: ${e.toString()}");
    } finally {
      loading = false;
      update();
    }
  }

  /// Generates a unique timestamp string
  String _generateUniqueTimestamp() {
    return DateFormat("yyyy.MMMM.dd 'at' hh:mm aaa").format(DateTime.now()) +
        math.Random().nextInt(100).toString();
  }

  /// Creates a copied card with the updated name and timestamp
  CardModel _createCopiedCard(
      CardModel originalCard, String newName, String newId) {
    CardModel copiedCard = CardModel.fromMap(originalCard.toMap(), newId);
    copiedCard.cardName!.cardName = [newName.toLowerCase().trimRight()];
    copiedCard.cardName!.timestamp = [Timestamp.now()];
    copiedCard.cardId = newId;
    return copiedCard;
  }

  /// Updates the board state after adding a new card
  void _updateBoardState(CardModel newCard, String currentBoardName) {
    BoardModel? board = allBoards.firstWhereOrNull(
          (element) =>
      element.boardName!.boardgName!.last == currentBoardName.toLowerCase(),
    );

    if (board != null) {
      board.cards.add(newCard);
      updatefilterCards(board.cards, newCard.cardStatus!.cardStatus!.last);

      // Set selected index based on card status
      selectedIndex = _getStatusIndex(newCard.cardStatus!.cardStatus!.last);

      update();
      getAllBoards();
    }
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

  /// Notifies card members about the new card
  void _notifyCardMembers(CardModel newCard, String boardName) {
    List<String> toMembers = newCard.cardMembers!.cardMembers!
        .asMap()
        .entries
        .where((entry) =>
    newCard.cardMembers!.cardMembersStatus![entry.key] == "invited")
        .map((entry) => entry.value)
        .toList();

    if (toMembers.isNotEmpty) {
      appNotificationController.sendNotificationToMultiple(
        type: 'card',
        topics: toMembers,
        title: "Invitation",
        arabicTitle: 'دعوة',
        body:
        "${empFullName(newCard.cardCreator!.cardCreator!.last).capitalize} has invited you to card: ${newCard.cardName!.cardName!.last} in board: $boardName on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
        arabicBody:
        "${'لقد دعاك'} ${CurrentUserArabicName()} ${'إلي البطاقة:'} ${newCard.cardName!.cardName!.last} ${'في لوحة:'} $boardName ${'في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
      );
    }
  }

  String CurrentUserArabicName() {
    return Get.find<MainCoreEmployeeController>().getEmployeeNameEnglishArabic(
        Get.find<MainCoreEmployeeController>().employeeEntity!.email!, false);
  }

  /// Shows a success dialog
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return SuccessDialog(
          title: "Successful",
          subtitle: message,
          lottieAsset: "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
        );
      },
    );
  }

  /// Shows a failure dialog
  void _showFailureDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return SuccessDialog(
          title: "Failure",
          subtitle: message,
          lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
        );
      },
    );
  }

  // end of copy card
  Future<void> createCard({
    required String name,
    required String description,
    required String currentBoardName,
    required BuildContext context,
  }) async {
    loading = true;
    update();
    showLoadingIndicator();

    try {
      // Validate input fields
      if (name.isEmpty || description.isEmpty) {
        _showErrorDialog(context, "Please Fill All The Fields");
        return;
      }

      // Check if the card name already exists in the database
      if (await _isCardNameExists(currentBoardName, name)) {
        _showErrorDialog(context, "This Card Name Already Exists");
        return;
      }

      // Create the card model
      final cardModel = _createCardModel(name, description);

      // Save the card to Firestore
      await _saveCardToFirestore(cardModel, currentBoardName, context);

      // Show success dialog
      _showSuccessDialog(context, "Card Added Successfully");

      // Send notifications to board members
      _sendNotificationsToBoardMembers(currentBoardName, name);

      // print('Card Is Added');
    } catch (e) {
      // print('Error creating card: $e');
      _showErrorDialog(context, "Failed to Create Card");
    } finally {
      loading = false;
      update();
      hideLoadingIndicator();
    }
  }

// Helper Methods

  bool _validateInput(String name, String description) {
    return name.isNotEmpty && description.isNotEmpty;
  }

  Future<bool> _isCardNameExists(
      String currentBoardName, String cardName) async {
    final CollectionReference cardsNames =
    db.collection(getBaseUrl('Cards_Names'));
    final DocumentSnapshot doc = await cardsNames.doc(currentBoardName).get();

    if (doc.exists) {
      Map<String, dynamic> mapData = doc.data() as Map<String, dynamic>;
      List<dynamic> listData = mapData['Cards_Names'];
      return listData.contains(cardName.toLowerCase().trimRight());
    }
    return false;
  }

  CardModel _createCardModel(String name, String description) {
    final String currentTime =
        DateFormat("yyyy.MMMM.dd 'at' hh:mm aaa").format(DateTime.now()) +
            math.Random().nextInt(100).toString();

    return CardModel(
      cardName: CardName(
        cardName: [name.toLowerCase()],
        timestamp: [Timestamp.now()],
      ),
      cardDescription: CardDescription(
        cardDescription: [description.toLowerCase()],
        timestamp: [Timestamp.now()],
      ),
      cardCreator: CardCreator(
        cardCreator: [Get.find<MainCoreEmployeeController>().employeeEntity!.email!],
        timestamp: [Timestamp.now()],
      ),
      cardStatus: CardStatus(
        cardStatus: ["todo"],
        timestamp: [Timestamp.now()],
      ),
      startDate: StartDate(
        startDate: [],
        timestamp: [],
      ),
      endDate: EndDate(
        endDate: [],
        timestamp: [],
      ),
      startTime: StartTime(
        startTime: [],
        timestamp: [],
      ),
      endTime: EndTime(
        endTime: [],
        timestamp: [],
      ),
      cardImage: CardImage(
        cardImage: [
          imageUrl.isEmpty
              ? "https://firebasestorage.googleapis.com/v0/b/knowticed-v2-scheme.appspot.com/o/card_images%2FtaskImage.png?alt=media&token=dab2b50a-7483-4db1-8869-c8ffd7ff9162"
              : imageUrl
        ],
        timestamp: [Timestamp.now()],
      ),
      cardMembers: CardMember(
        cardMembers: [],
        cardMembersStatus: [],
        timestamp: [],
      ),
      comments: [],
      cardAttachments: CardAttachments(
        cardAttachments: [],
        cardAttachmentsStatus: [],
        timestamp: [],
      ),
      cardCheckLists: [],
      cardPriority: CardPriority(
        cardPriority: [],
        timestamp: [],
      ),
      cardProgress: CardProgress(
        cardProgress: [],
        timestamp: [],
      ),
      lastUpdate: LastUpdate(
        lastUpdate: [],
      ),
      progressIndicator: CardProgressIndicator(
        progressPercentage: [
          "5",
          "10",
          "15",
          "20",
          "25",
          "30",
          "35",
          "40",
          "45",
          "50",
          "55",
          "60",
          "65",
          "70",
          "75",
          "80",
          "85",
          "90",
          "95",
          "100"
        ],
        colors: [
          "red",
          "red",
          "red",
          "red",
          "red",
          "orange",
          "orange",
          "orange",
          "orange",
          "orange",
          "yellow",
          "yellow",
          "yellow",
          "yellow",
          "yellow",
          "green",
          "green",
          "green",
          "green",
          "green"
        ],
      ),
    );
  }

  Future<void> _saveCardToFirestore(
      CardModel cardModel,
      String currentBoardName,
      BuildContext context,
      ) async {
    final CollectionReference cardsCollection =
    db.collection(getBaseUrl('Cards'));
    final CollectionReference cardsNames =
    db.collection(getBaseUrl('Cards_Names'));

    final String currentTime =
        DateFormat("yyyy.MMMM.dd 'at' hh:mm aaa").format(DateTime.now()) +
            math.Random().nextInt(100).toString();

    // Save the card to Firestore
    await cardsCollection
        .doc(currentBoardName)
        .collection(getBaseUrl('Cards'))
        .doc(currentTime)
        .set(cardModel.toMap());

    // Add the card name to the database
    await cardsNames.doc(currentBoardName).set(
      {
        "Cards_Names":
        FieldValue.arrayUnion([cardModel.cardName!.cardName!.last]),
      },
      SetOptions(merge: true),
    );

    // Update the board model
    final BoardModel board = allBoards.firstWhere(
          (element) =>
      element.boardName!.boardgName!.last == currentBoardName.toLowerCase(),
    );

    board.cards.add(cardModel);
    updatefilterCards(board.cards, "todo");
    selectedIndex = 0;
    update();

    getAllBoards();
    Navigator.pop(context);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return SuccessDialog(
          title: "Failure",
          subtitle: message,
          lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
        );
      },
    );
  }

  // Checks if the given text is a valid field by verifying if it contains any letter.
  bool isFieldValid(String text) {
    // Regular expression to match any letter
    RegExp regex = RegExp(r'[a-zA-Z]');

    // Check if the text contains any letter
    return regex.hasMatch(text);
  }

  void _sendNotificationsToBoardMembers(
      String currentBoardName, String cardName) {
    final BoardModel currentBoardModel = boards.firstWhere(
          (element) =>
      element.boardName!.boardgName!.last == currentBoardName.toLowerCase(),
    );

    final List<String> toMembers = [];
    for (int i = 0;
    i < currentBoardModel.boardMember!.boardMembers!.length;
    i++) {
      if (currentBoardModel.boardMember!.boardMembersStatus![i] == "invited") {
        toMembers.add(currentBoardModel.boardMember!.boardMembers![i]);
      }
    }

    appNotificationController.sendNotificationToMultiple(
      type: 'board',
      topics: toMembers,
      title: currentBoardName.capitalize!,
      arabicTitle: currentBoardName.capitalize!,
      body:
      "${empFullName(Get.find<MainCoreEmployeeController>().employeeEntity!.email!).capitalize} has added a new card to the board on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
      arabicBody:
      "${CurrentUserArabicName()} ${'قام بإضافة بطاقة جديدة إلي اللوحة في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
    );
  }

  // Filters the list of board models based on the provided department.
  List<BoardModel> filterBoards(String department) {
    if (department == 'all' || department == 'الكل') {
      return allBoards;
    }
    return allBoards
        .where((element) =>
    element.boardDeparment!.boardgDepartment!.last ==
        department.toLowerCase())
        .toList();
  }

  // Returns the image URL or asset path for a single employee based on their email.
  String getSingleImage(String email) {
    return addEmployeeController.getEmployeePhoto(email);
  }

// Returns the full name of an employee based on the provided email.
  String empFullName(String email, {bool thirdName = false}) {
    return addEmployeeController.getEmployeeName(email);
  }

  Future<void> uploadImage(String path) async {
    if (imageUrl != "") {
      await FirebaseStorage.instance
          .refFromURL(imageUrl)
          .delete()
          .then((value) {
        imageUrl = "";
      });
    }
    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    showLoadingIndicator();
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      Reference ref =
      FirebaseStorage.instance.ref().child('/$path/${DateTime.now()}.jpeg');
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      UploadTask uploadTask = ref.putFile(_image!, metadata);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      imageUrl = await taskSnapshot.ref.getDownloadURL();
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
      // print('Error updating card: $e');
      // Handle error (e.g., show a snackbar or log the error)
    } finally {
      loading = false;
      update();
    }
  }

  void onChnagedColorDropDown(List<String>? colorsList,
      List<String>? progressPercentageList, String? progressPercentageValue) {
    cardProgressPercentageValue = progressPercentageValue;
    cardProgressPercentageList = progressPercentageList;
    cardColorsList = colorsList;
    update();
  }

  void updateColorDropDown(CardModel card) {
    cardProgressPercentageValue =
    card.progressIndicator!.progressPercentage![0];
    cardProgressPercentageList = card.progressIndicator!.progressPercentage!;
    cardColorsList = card.progressIndicator!.colors!;
    // cardProgressPercentageList!.removeAt(0);
    //update();
  }

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
          .collection(getBaseUrl('Cards'))
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
    getAllBoards();
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

  Future<void> addMemberToBoard({
    required String boardId,
    required String memberEmail,
    required String memberStatus, // e.g., "pending", "approved"
    required BuildContext context,
  }) async {
    try {
      final DocumentReference boardDoc =
      db.collection(getBaseUrl('Boards')).doc(boardId); // Targeting board document

      await boardDoc.set({
        "Board_Members": FieldValue.arrayUnion([memberEmail]),
        "Board_Member_Status": FieldValue.arrayUnion([memberStatus]),
        "Timestamp": FieldValue.arrayUnion([Timestamp.now()])
      }, SetOptions(merge: true));

      showDialog(
        context: context,
        builder: (context) {
          return const SuccessDialog(
            title: "Success",
            subtitle: "Member added successfully!",
            lottieAsset: "assets/images/success.json",
          );
        },
      );

      // print("Member added successfully.");
    } catch (e) {
      // print("Error adding member: $e");
      showDialog(
        context: context,
        builder: (context) {
          return const SuccessDialog(
            title: "Failure",
            subtitle: "Failed to add member.",
            lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
          );
        },
      );
    }
  }

  // SystemLogsController systemLogsController = Get.put(SystemLogsController());
  // A function to create a Task with various details and store it in the database.
  Future createBoard({
    String? name,
    String? description,
    String? department,
    List<String>? members,
    String? messaginChannel,
    required BuildContext context,
  }) async {
    // Update the controller state.
    loading = true;
    update();
    String currentTime =
    DateFormat("yyyy.MMMM.dd 'at' hh:mm aaa").format(DateTime.now());
    currentTime = currentTime + math.Random().nextInt(100).toString();


    List<Timestamp> timestamps = List.generate(members!.length, (index) => Timestamp.now());
    List<String> memberStatuses = List.filled(members.length, 'invited'); // Assign 'invited' to all members

    BoardModel boardModel = BoardModel(
      boardName: BoardName(
          boardgName: [name!.toLowerCase()], timestamp: [Timestamp.now()]),
      boardDescription: BoardDescription(
          boardDescription: [description!.toLowerCase()],
          timestamp: [Timestamp.now()]),
      boardDeparment: BoardDepartment(
          boardgDepartment: [department!.toLowerCase()],
          timestamp: [Timestamp.now()]),
      messagingChannels: MessagingChannels(
          messagingChannels: [messaginChannel!.toLowerCase()],
          timestamp: [Timestamp.now()]),
      boardImage: BoardImage(
        boardImage: [
          imageUrl == ""
              ? "https://firebasestorage.googleapis.com/v0/b/knowticed-v2-scheme.appspot.com/o/board_images%2Fboard.jpg?alt=media&token=4de35821-c40e-47be-b382-fe5549b8385f"
              : imageUrl
        ],
        timestamp: [Timestamp.now()],
      ),

      boardCreator: Get.find<MainCoreEmployeeController>().employeeEntity?.email,
      boardMember: BoardMember(
        boardMembers: members, // Dynamic members list
        boardMembersStatus: memberStatuses, // Assign statuses dynamically
        timestamp: timestamps, // Assign timestamps dynamically
      ),
      boardTasks: BoardTasks(boardTasks: [], timestamp: []),
      status: "active",
      boardId: currentTime,
    );

    if (name.isEmpty ||
        description.isEmpty ||
        department.isEmpty ||
        messaginChannel.isEmpty) {
      // print("error Name exist");
      showDialog(
        context: context,
        builder: (context) {
          return const SuccessDialog(
            title: "Failure",
            subtitle: "Please Fill All The Fields",
            lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
          );
        },
      );
    } else {
      // Check if the board name already exists in the database.
      final CollectionReference boardsNames =
      db.collection(getBaseUrl('Boards_Names'));
      await boardsNames
          .doc("Boards_Names")
          .get()
          .then((DocumentSnapshot doc) async {
        if (doc.exists) {
          Map<String, dynamic> mapData = doc.data() as Map<String, dynamic>;
          List<dynamic> listData = mapData['Boards_Names'];
          if (listData.contains(name.toLowerCase().trimRight())) {
            showDialog(
              context: context,
              builder: (context) {
                return const SuccessDialog(
                  title: "Failure",
                  subtitle: "This Board Name Already Exist",
                  lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
                );
              },
            );
          } else {
            // Create the board in the database.
            final CollectionReference boardCollection =
            db.collection(getBaseUrl('Boards'));
            await boardCollection
                .doc(currentTime)
                .set(boardModel.toMap())
                .then((value) async {
              allBoards.add(boardModel);
              imageUrl = "";

              // Add the board name to the database.
              await boardsNames.doc("Boards_Names").update({
                "Boards_Names":
                FieldValue.arrayUnion([name.toLowerCase().trimRight()])
              });
              Navigator.pop(context);
              // print('Board Is Added');
            });
          }
        } else {
          // Create the board in the database.
          final CollectionReference boardCollection =
          db.collection(getBaseUrl('Boards'));
          await boardCollection
              .doc(currentTime)
              .set(boardModel.toMap())
              .then((value) async {
            allBoards.add(boardModel);
            imageUrl = "";

            // Add the board name to the database.
            await boardsNames.doc("Boards_Names").set({
              "Boards_Names":
              FieldValue.arrayUnion([name.toLowerCase().trimRight()])
            });
            Navigator.pop(context);
          });
        }
      });
    }
    //  systemLogsController.systemLogsAction(SystemActions.createBoard);
    loading = false;
    getAllBoards();
    update();
  }

  // Updates the board with the given [boardModel] and [boardId] by modifying the invitation members.
  Future updateBoard({
    required BoardModel boardModel,
    required String boardId,
    List<String>? invitationMember,
  }) async {
    loading = true;
    update();
    showLoadingIndicator();
    final CollectionReference boardCollection =
    db.collection(getBaseUrl('Boards'));
    WriteBatch batch = db.batch();
    List<String> lastBoardMembers = [];
    List<String> lastInvitedBoardMembers = [];
    List<String> removedBoardMembers = [];
    List<String> newBoardMembers = [];
    //List<String> finalRemovedBoardMembers = [];

    if (invitationMember != null /* && invitationMember.isNotEmpty*/) {
      for (int i = 0;
      i < boardModel.boardMember!.boardMembersStatus!.length;
      i++) {
        if (boardModel.boardMember!.boardMembersStatus![i] == "uninvited") {
          lastBoardMembers.add(boardModel.boardMember!.boardMembers![i]);
        }
      }
      for (int i = 0;
      i < boardModel.boardMember!.boardMembersStatus!.length;
      i++) {
        if (boardModel.boardMember!.boardMembersStatus![i] == "invited") {
          lastInvitedBoardMembers.add(boardModel.boardMember!.boardMembers![i]);
        }
      }

      boardModel.boardMember!.timestamp!.add(Timestamp.now());
      // Find Removed Members And Update Status
      for (int i = 0; i < boardModel.boardMember!.boardMembers!.length; i++) {
        if (!invitationMember
            .contains(boardModel.boardMember!.boardMembers![i])) {
          int removedIndex = boardModel.boardMember!.boardMembers!
              .indexOf(boardModel.boardMember!.boardMembers![i]);
          boardModel.boardMember!.boardMembersStatus![removedIndex] =
          "uninvited";
          removedBoardMembers
              .add(boardModel.boardMember!.boardMembers![removedIndex]);
        }
      }
      // Find New Members And Add Thier Status
      for (int i = 0; i < invitationMember.length; i++) {
        if (!boardModel.boardMember!.boardMembers!
            .contains(invitationMember[i])) {
          boardModel.boardMember!.boardMembers!.add(invitationMember[i]);
          boardModel.boardMember!.boardMembersStatus!.add("invited");
          newBoardMembers.add(invitationMember[i]);
        } else {
          boardModel.boardMember!.boardMembersStatus![boardModel
              .boardMember!.boardMembers!
              .indexOf(invitationMember[i])] = "invited";
          newBoardMembers.add(invitationMember[i]);
          //boardModel.boardMember!.boardMembersStatus![i] = "invited";
        }
      }
    }

    batch.set(
      boardCollection.doc(boardId),
      boardModel.toMap(),
      SetOptions(merge: true),
    );

    await batch.commit().then((value) {
      update();
      if (invitationMember != null && newBoardMembers.isNotEmpty) {
        List<String> toMembers = [];
        for (var element in newBoardMembers) {
          if (!lastInvitedBoardMembers.contains(element)) {
            toMembers.add(element);
            // appNotificationController.sendNotification(
            //   "${element}topic",
            //    "Invitation",
            //    "${empFullName(Get.find<AddEmployeeController>().employeeEntity!.email!).capitalize} has "
            //    "invited you to board: ${boardModel.boardName!.boardgName!.last}"
            //    " on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",element);
          }
        }
        appNotificationController.sendNotificationToMultiple(
          type: 'board',
          topics: toMembers,
          title: "Invitation",
          arabicTitle: 'دعوة',
          body:
          "${empFullName(Get.find<MainCoreEmployeeController>().employeeEntity!.email!).capitalize} has invited you to board: ${boardModel.boardName!.boardgName!.last} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
          arabicBody:
          "${CurrentUserArabicName()} ${'قام بدعوتك إلي لوحة:'} ${boardModel.boardName!.boardgName!.last} ${'في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
        );
      }
      if (removedBoardMembers.isNotEmpty) {
        List<String> toMembers = [];

        for (String element in removedBoardMembers) {
          if (!lastBoardMembers.contains(element)) {
            toMembers.add(element);
          }
        }
        appNotificationController.sendNotificationToMultiple(
          type: 'board',
          topics: toMembers,
          title: boardModel.boardName!.boardgName!.last,
          arabicTitle: boardModel.boardName!.boardgName!.last,
          body:
          "${empFullName(Get.find<MainCoreEmployeeController>().employeeEntity!.email!).capitalize} has removed you from board: ${boardModel.boardName!.boardgName!.last} on ${DateFormat("yyyy/MM/dd 'at' hh:mm aaa").format(DateTime.now())}",
          arabicBody:
          "${CurrentUserArabicName()} ${'قام بإزالتك من لوحة:'} ${boardModel.boardName!.boardgName!.last} ${'في'} ${DateFormat("yyyy/MM/dd hh:mm aaa", 'ar').format(DateTime.now())}",
        );
      }
      taskDetailsController.setMembers(boardModel);
      taskDetailsController.getAllMembersNum(boardModel);
      getAllBoards();
    });
    loading = false;
    // Update the controller state.
    hideLoadingIndicator();
    update();
  }

  /// Retrieves all boards from the database and populates the `allBoards` and `boards` lists.
  Future<void> getAllBoards() async {
    loading = true;
    allBoards = [];
    boards = [];

    final CollectionReference boardCollection =
    db.collection(getBaseUrl('Boards'));
    final CollectionReference cardCollection =
    db.collection(getBaseUrl('Cards'));

    boardCollection.get().then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        BoardModel boardModel =
        BoardModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        cardCollection
            .doc(GetUtils.capitalize(boardModel.boardName!.boardgName!.last)!)
            .collection(getBaseUrl('Cards'))
            .get()
            .then((QuerySnapshot querySnapshot) {
          for (var doc in querySnapshot.docs) {
            boardModel.cards.add(
                CardModel.fromMap(doc.data() as Map<String, dynamic>, doc.id));
          }
        });

        //boardModel.boardName!.boardgName!.
        //allBoards.add(BoardModel.fromMap(doc1.data() as Map<String, dynamic>, doc1.id));
        if (boardModel.boardCreator ==
            Get.find<MainCoreEmployeeController>().employeeEntity?.email &&
            boardModel.status == "active") {
          allBoards.add(boardModel);
          boards.add(boardModel);
        } else {
          for (int i = 0;
          i < boardModel.boardMember!.boardMembers!.length;
          i++) {
            if (boardModel.boardMember!.boardMembersStatus![i] == "invited" &&
                boardModel.status == "active") {
              if (boardModel.boardMember!.boardMembers![i] ==
                  Get.find<MainCoreEmployeeController>().employeeEntity!.email!) {
                allBoards.add(boardModel);
                boards.add(boardModel);
              }
            }
          }
        }
        update();
      }
      update();
    });
    loading = false;
    update();
  }
}
