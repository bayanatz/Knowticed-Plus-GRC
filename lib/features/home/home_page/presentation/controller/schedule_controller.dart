/// *************************** FILE INFO ****************************
/// File Name: schedule_controller.dart
/// Purpose: This file contains the controller for the schedule section of the home page.
/// Author: Mohamed Elrashidy
/// Created at: 11/2/2025

import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/features/home/home_page/presentation/controller/skeleton_home_controller.dart';
import 'package:demo_app/core/helper/todo_new_module/todo_stub.dart';

import 'package:demo_app/core/helper/events/events_stub.dart';
import 'package:demo_app/features/home/helper/events/controllers/events_controllers/model/event_model.dart';
import 'package:demo_app/features/home/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/features/home/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/features/home/helper/task_management_module/task/data/model/card_model/checklist_item.dart';

import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/home/home_page/presentation/utils/helper.dart';

class ScheduleController extends GetxController {
  List<EventModel> inviteAtEvents = [];
  List<EventModel> surveyEvents = [];
  List<TodoModel> todoList = [];
  List<BoardModel> boardsModel = [];
  List<CardModel> cardsModel = [];

  List<dynamic> requestedServices = [];
  List<CheckListItems> filteredItems = [];
  bool isThereTodo = false;
  bool isThereEvent = false;
  bool isThereTasks = false;
  bool isThereServices = false;
  bool isThereSurvey = false;

  bool isThereAnyWork() {
    return isThereEvent ||
        isThereTodo ||
        isThereTasks ||
        isThereServices ||
        isThereSurvey;
  }

  DateTime selectedDate = DateTime.now();

  TodoController todoController = Get.find();
  //TaskController taskController = Get.find();
  EventsEmployeeController eventsEmployeeController = Get.find();

  @override
  onInit() {
    super.onInit();
    getAnyWorkToDO();
  }

  /// Method Name: [getAnyWorkToDO]
  ///
  /// Purpose: This method is responsible for fetching all the work that the user has to do on the selected date.
  getAnyWorkToDO() async {
    await Future.wait(
        [getTodo(), getEvents(), getSurveyEvents(), getTasks(), getServices()]);
  }

  /// Method Name: [getTodo]
  ///
  /// Purpose: This method is responsible for fetching all the todos that the user has to do on the selected date.
  Future<void> getTodo() async {
    isThereTodo = false;
    todoList = [];
    if (!Get.find<SkeletonHomeController>().modules.contains(Modules.todo)) {
      todoController.update();
      return;
    }
    for (TodoModel todo in todoController.allTodoList) {
/*       Map<String, int> todoSplitDate =
          HomeHelper.splitDateString(todo.date!.date!.last!);
      if (todoSplitDate['year'] == selectedDate.year &&
          todoSplitDate['month'] == selectedDate.month &&
          todoSplitDate['day'] == selectedDate.day) {
        todoList.add(todo);
      } */
    }
    todoController.update();
    if (todoList.isNotEmpty) isThereTodo = true;
  }

  /// Method Name: [getEvents]
  ///
  /// Purpose: This method is responsible for fetching all the events that the user has to attend on the selected date.
  Future<void> getEvents() async {
    isThereEvent = false;
    inviteAtEvents = [];
    if (!Get.find<SkeletonHomeController>().modules.contains(Modules.events)) {
      eventsEmployeeController.update();
      return;
    }

    for (EventModel event in eventsEmployeeController.inviteAtEvents) {
      Map<String, int> eventSplitDate =
          HomeHelper.splitDateString(event.date.toLowerCase());
      DateTime eventDate = _createEventDateTime(eventSplitDate, event);
      if (eventSplitDate['year'] == selectedDate.year &&
          eventSplitDate['month'] == selectedDate.month &&
          eventSplitDate['day'] == selectedDate.day &&
          eventsEmployeeController.acceptInvitation(eventId: event.id) &&
          eventDate.isAfter(selectedDate.add(Duration(
              hours: DateTime.now().hour, minutes: DateTime.now().minute)))) {
        inviteAtEvents.add(event);
      }
    }
    eventsEmployeeController.update();
    if (inviteAtEvents.isNotEmpty) isThereEvent = true;
  }

  /// Method Name: [getSurveyEvents]
  ///
  /// Purpose: This method is responsible for fetching all the survey events that the user has to attend on the selected date.
  Future<void> getSurveyEvents() async {
    surveyEvents = [];
    isThereSurvey = false;
    if (!Get.find<SkeletonHomeController>().modules.contains(Modules.events)) {
      eventsEmployeeController.update();
      return;
    }
    for (EventModel event in eventsEmployeeController.inviteAtEvents) {
      Map<String, int> eventSplitDate =
          HomeHelper.splitDateString(event.date.toLowerCase());
      DateTime eventDate = _createEventDateTime(eventSplitDate, event);
      if (HomeHelper.isDateInRange(
              selectedDate: selectedDate,
              startDate: DateFormat("d MMM yyyy").parse(event.date),
              endDate: DateFormat("d MMM yyyy")
                  .parse(event.date)
                  .add(const Duration(days: 5))) &&
          eventsEmployeeController.findEmployeeSubmission(
                  surveyId: event.surveyId) ==
              null &&
          eventsEmployeeController.acceptInvitation(eventId: event.id) &&
          eventDate.isBefore(selectedDate!.add(Duration(
              hours: DateTime.now().hour, minutes: DateTime.now().minute)))) {
        surveyEvents.add(event);
      }
    }
    if (inviteAtEvents.isNotEmpty) isThereSurvey = true;
    eventsEmployeeController.update();
  }

  /// Method Name: [_createEventDateTime]
  ///
  /// Purpose: This method is responsible for creating a DateTime object from the event date and time.
  DateTime _createEventDateTime(
      Map<String, int> eventSplitDate, EventModel event) {
    DateTime eventDate = DateTime(
        eventSplitDate['year']!,
        eventSplitDate['month']!,
        eventSplitDate['day']!,
        DateFormat("hh:mm a").parse(event.time).hour,
        DateFormat("hh:mm a").parse(event.time).minute);
    return eventDate;
  }

  /// Method Name: [getTasks]
  ///
  /// Purpose: This method is responsible for fetching all the tasks that the user has to do on the selected date.
  Future<void> getTasks() async {
    filteredItems = [];
    cardsModel = [];
    boardsModel = [];
    isThereTasks = false;
    if (!Get.find<SkeletonHomeController>().modules.contains(Modules.tasks)) {
      // taskController.update();
      return;
    }

    String memberId =
        Get.find<EmployeeController>().employee!.email!.last!;
    /*  for (var board in taskController.allBoards) {
      for (var card in board.cards) {
        //Skip cards with a null start date
        if (card.startDate!.startDate!.isNotEmpty) {
          for (var checklist in card.cardCheckLists!) {
            if (card.cardCheckLists != null &&
                card.cardCheckLists!.isNotEmpty) {
              for (var item in checklist.checkListItems!) {
                // Check if the item's status is "todo" and the member is in the list
                if (item.itemStatus!.last == 'todo' ||
                    item.itemMembers!.contains(memberId)) {
                  // Determine effective start date
                  DateTime? effectiveStartDate = DateFormat('dd/MM/yyyy').parse(
                      item.itemStartDate?.lastOrNull ??
                          card.startDate!.startDate!.last);
                  DateTime? effectiveEndDate = item.itemEndDate?.lastOrNull !=
                          null
                      ? DateFormat('dd/MM/yyyy').parse(item.itemEndDate!.last)
                      : null;

                  // Skip if both start and end dates are null
                  if (effectiveEndDate == null && item.itemStartDate == null)
                    continue;
                  // Check if the selected date is within the range
                  if (effectiveStartDate.isBefore(selectedDate) ||
                      effectiveStartDate.isAtSameMomentAs(selectedDate)) {
                    if (effectiveEndDate != null &&
                        (effectiveEndDate.isAfter(selectedDate) ||
                            effectiveEndDate.isAtSameMomentAs(selectedDate))) {
                      filteredItems.add(item);
                      cardsModel.add(card);
                      boardsModel.add(board);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
   */
    if (filteredItems.isNotEmpty) {
      isThereTasks = true;
    }
    // taskController.update();
  }

  /// Method Name: [getServices]
  ///
  /// Purpose: This method is responsible for fetching all the services that the user has to do on the selected date.
  Future<void> getServices() async {
    isThereServices = false;
    requestedServices = [];
    if (!Get.find<SkeletonHomeController>()
        .modules
        .contains(Modules.services)) {
      // serviceController.update();
      return;
    }
    /* for (RequestedServiceModel service
        in serviceController.myRequestedServices) {
      if (HomeHelper.isDateWithinServiceRange(
            startDate: service.startDate!.toDate(),
            durationType:
                service.serviceModel!.durationType!.durationType!.last!,
            durationValue: int.parse(
                service.serviceModel!.serviceDuration!.serviceDuration!.last!),
            selectedDate: selectedDate,
          ) &&
          service.status!.requestStatus!.last == 'in progress') {
        requestedServices.add(service);
      }
    }*/
    if (requestedServices.isNotEmpty) isThereServices = true;
    // serviceController.update();
  }

  /// Method Name: [isDayHasToDo]
  ///
  /// Purpose: This method is responsible for checking if the selected date has any todos.
  ///
  /// Parameters: [currentDate] of type [DateTime] - The date to check.
  ///
  /// Returns: [bool] - True if the date has todos, false otherwise.
  bool isDayHasToDo(DateTime currentDate) {
    if (!Get.find<SkeletonHomeController>().modules.contains(Modules.todo)) {
      return false;
    }
    bool isExist = false;
/*     for (TodoModel todo in todoController.allTodoList) {
      Map<String, int> splitDate =
          HomeHelper.splitDateString(todo.date!.date!.last!);
      if (splitDate['year'] == currentDate.year &&
          splitDate['month'] == currentDate.month &&
          splitDate['day'] == currentDate.day) {
        isExist = true;
        break;
      }
    } */
    return isExist;
  }

  /// Method Name: [isDayHasRequestServices]
  ///
  /// Purpose: This method is responsible for checking if the selected date has any requested services.
  ///
  /// Parameters: [currentDate] of type [DateTime] - The date to check.
  ///
  /// Returns: [bool] - True if the date has requested services, false otherwise.
  bool isDayHasRequestServices(DateTime currentDate) {
    if (!Get.find<SkeletonHomeController>()
        .modules
        .contains(Modules.services)) {
      return false;
    }
    bool isExist = false;
/*    for (RequestedServiceModel service
        in serviceController.myRequestedServices) {
      if (HomeHelper.isDateWithinServiceRange(
              startDate: service.startDate!.toDate(),
              durationType:
                  service.serviceModel!.durationType!.durationType!.last!,
              durationValue: int.parse(service
                  .serviceModel!.serviceDuration!.serviceDuration!.last!),
              selectedDate: currentDate) &&
          service.status!.requestStatus!.last == 'in progress') {
        isExist = true;
        break;
      }
    }*/
    return isExist;
  }

  /// Method Name: [isDayHasEvent]
  ///
  /// Purpose: This method is responsible for checking if the selected date has any events.
  ///
  /// Parameters: [currentDate] of type [DateTime] - The date to check.
  ///
  /// Returns: [bool] - True if the date has events, false otherwise.
  bool isDayHasEvent(DateTime currentDate) {
    if (!Get.find<SkeletonHomeController>().modules.contains(Modules.events)) {
      return false;
    }
    bool isExist = false;
    for (EventModel event in eventsEmployeeController.inviteAtEvents) {
      bool isValidEvent = false;
      Map<String, int> splitDate =
          HomeHelper.splitDateString(event.date.toLowerCase());
      DateTime eventDate = _createEventDateTime(splitDate, event);
      bool isFirstSetValidEvent = splitDate['year'] == currentDate.year &&
          splitDate['month'] == currentDate.month &&
          splitDate['day'] == currentDate.day;
      isFirstSetValidEvent &=
          eventsEmployeeController.acceptInvitation(eventId: event.id);
      isFirstSetValidEvent &= eventDate.isAfter(currentDate.add(Duration(
          hours: DateTime.now().hour, minutes: DateTime.now().minute)));
      bool isSecondSetValidEvent = HomeHelper.isDateInRange(
          selectedDate: currentDate,
          startDate: DateFormat("d MMM yyyy").parse(event.date),
          endDate: DateFormat("d MMM yyyy")
              .parse(event.date)
              .add(const Duration(days: 5)));
      isSecondSetValidEvent &= eventsEmployeeController.findEmployeeSubmission(
              surveyId: event.surveyId) ==
          null;
      isSecondSetValidEvent &=
          eventsEmployeeController.acceptInvitation(eventId: event.id);
      isSecondSetValidEvent &= eventDate.isBefore(currentDate.add(Duration(
          hours: DateTime.now().hour, minutes: DateTime.now().minute)));
      isValidEvent = isFirstSetValidEvent || isSecondSetValidEvent;
      if (isValidEvent) {
        isExist = true;
        break;
      }
    }
    return isExist;
  }

  /// Method Name: [isDayHasSurvey]
  ///
  /// Purpose: This method is responsible for checking if the selected date has any survey events.
  ///
  /// Parameters:
  ///            [currentDate] of type [DateTime] - The date to check.
  ///            [memverId] of type [String] - The id of the member.
  ///
  /// Returns: [bool] - True if the date has survey events, false otherwise.
  bool isDayHasTasks(
      {required DateTime selectedDate, required String memberId}) {
    if (!Get.find<SkeletonHomeController>().modules.contains(Modules.tasks)) {
      return false;
    }
    List<CheckListItems> filteredItems = [];

/*     // Loop through each board in the list of boards
    for (var board in taskController.allBoards) {
      for (var card in board.cards) {
        //Skip cards with a null start date
        if (card.startDate!.startDate!.isNotEmpty) {
          for (var checklist in card.cardCheckLists!) {
            if (card.cardCheckLists != null &&
                card.cardCheckLists!.isNotEmpty) {
              for (var item in checklist.checkListItems!) {
                // Check if the item's status is "todo" and the member is in the list
                if (item.itemStatus!.last == 'todo' ||
                    item.itemMembers!.contains(memberId)) {
                  // Determine effective start date
                  DateTime? effectiveStartDate = DateFormat('dd/MM/yyyy').parse(
                      item.itemStartDate?.lastOrNull ??
                          card.startDate!.startDate!.last);
                  DateTime? effectiveEndDate = item.itemEndDate?.lastOrNull !=
                          null
                      ? DateFormat('dd/MM/yyyy').parse(item.itemEndDate!.last)
                      : null;

                  // Skip if both start and end dates are null
                  if (effectiveEndDate == null && item.itemStartDate == null) {
                    continue;
                  }

                  // Check if the selected date is within the range
                  if (effectiveStartDate.isBefore(selectedDate) ||
                      effectiveStartDate.isAtSameMomentAs(selectedDate)) {
                    if (effectiveEndDate != null &&
                        (effectiveEndDate.isAfter(selectedDate) ||
                            effectiveEndDate.isAtSameMomentAs(selectedDate))) {
                      filteredItems.add(item);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
 */
    return filteredItems.isNotEmpty;
  }

  /// Method Name: [updateUpcomingSchedule]
  ///
  /// Purpose: This method is responsible for updating the upcoming schedule list.
  ///
  /// Parameters: [selectedDate] of type [DateTime] - The selected date.
  updateUpcomingSchedule(DateTime selectedDate) {
    this.selectedDate = selectedDate;
    getAnyWorkToDO();
  }
}
