import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/organization_chart_module/requests/requests_components/requests_filter_appbar.dart';
import 'package:demo_app/core/helper/main_helper/date_time_in_arabic.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/constants/system_actions.dart';
import 'package:demo_app/features/employee/data/models/emplyees_model/new_employee_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/presentation/controller/employee_controller.dart';
import 'package:demo_app/core/helper/organization_chart_module/presentation/controller/main_core_department_controller.dart';
import 'package:demo_app/features/notification/notification_controller.dart';
import 'package:demo_app/features/home/helper/events/controllers/events_controllers/model/event_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/department_owner_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/event_agenda_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/event_date_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/event_flyer_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/event_id_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/event_invite_guest_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/event_maximum_capacity_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/event_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/event_summary_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/event_time_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/event_title_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/event_type_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/event_venue_data_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/has_reminder.dart';
import 'package:demo_app/core/helper/events/models/events_models/has_survey_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/is_onsite_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/is_remote_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/reminder_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/requires_approval_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/status_model.dart';
import 'package:demo_app/core/helper/events/models/more_models/assigned_event_model.dart';
import 'package:demo_app/core/helper/events/models/more_models/employee_model.dart';
import 'package:demo_app/core/helper/events/models/survey_models/assigned_event_id_model.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';
import 'package:demo_app/features/onboarding/welcome_screen/views/mobile_view/nav_bar.dart';

List<String> arabicQuestionsTypes = [
  'اختيار من متعدد',
  'إجابة قصيرة',
  'إجابة طويلة',
  'قائمة منسدلة',
  'صح او خطأ'
];
List<String> arabicInviteAndApproveStatus = [
  'تم القبول',
  'مرفوض',
  'لم يتم الرد'
];
List<String> englishEventType = ['Workshop', 'Ceremony', 'Announcement'];
List<String> englishTrueAndFalse = ["True", "False"];
List<String> englishQuestionsTypes = [
  'Multiple Choice',
  'Short Answer',
  'Long Answer',
  'Drop Menu',
  'True Or False'
];
List<String> englishInviteAndApproveStatus = [
  'Accepted',
  'Rejected',
  'No Response'
];

List<String> arabicEventType = ['ورشة عمل', 'حفل', 'إعلان'];
List<String> arabicTrueAndFalse = ["صح", "خطأ"];

class EventController extends GetxController {
  var events = <EventModel>[];
  var filteredevents = <EventModel>[];
  var approvalEvents = <EventModel>[];
  var historicalEvents = <EventModel>[];
  List<Employee> allEmployees = [];

  // add yous list instead of this one --------------------------

  // List<EmployeeModel> employeesModels = [
  //   EmployeeModel(
  //       id: "amira@gmail.com",
  //       role: ["Media"],
  //       department: ["Social Media"],
  //       imageUrl: ["assets/images/profile1.png"],
  //       name: ["Amira"]),
  //   EmployeeModel(
  //       id: "hussien@gmail.com",
  //       role: ["Android"],
  //       department: ["Android Developer"],
  //       imageUrl: ["assets/images/profile1.png"],
  //       name: ["Mohamed Hussien"]),
  //   EmployeeModel(
  //       id: "nageh@gmail.com",
  //       role: ["Backend Engineer"],
  //       department: ["Software"],
  //       imageUrl: ["assets/images/profile1.png"],
  //       name: ["Nageh"])
  // ];

  // --------------------------------

  List<EventsModel> fetchedEvents = [];

  List<String> departmentList = [];
  List<String> departmentArabicList = [];

  Map<String, ApprovalAndInvitedListModel> allApprovalsAndInvitations = {};

  AppNotificationController appNotificationController =
      Get.put(AppNotificationController());

  @override
  void onInit() async {
    await fetchEmployees().then((value) async {
      await fetchEventsFromFirebase();
      await fetchDepartmentList();
      fetchApprovals();

      filterEvents(0);
    });

    super.onInit();
  }

  // ------------------------------------- fetch departments ---------------------------------------------------------------

  Future<void> fetchDepartmentList() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Departments')
          .doc('Departments')
          .get();

      departmentList = List<String>.from(documentSnapshot['Departments']);
      departmentList
          .assignAll(departmentList.map((e) => capitalize(e)).toList());

      departmentArabicList =
          List<String>.from(documentSnapshot['Departments_In_Arabic']);

      departmentArabicList
          .assignAll(departmentArabicList.map((e) => capitalize(e)).toList());
    } catch (e) {
      log('Error fetching departments: $e');
    }
  }

  // ------------------------------------- fetch Events ---------------------------------------------------------------

  Future<void> fetchEventsFromFirebase() async {
    try {
      // get all events
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Events').get();

      fetchedEvents = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return EventsModel.fromMap(doc.id, data);
      }).toList();

      var temp = <EventModel>[];
      for (var element in fetchedEvents) {
        // ----------------- get all reminders----------------------
        List<Reminder> tempReminders = [];
        if (element.hasReminder.hasReminder!.last == true &&
            element.eventReminders.isNotEmpty) {
          for (var reminder in element.eventReminders) {
            tempReminders.add(Reminder(
              date: reminder.reminderDate!.last!,
              time: reminder.reminderTime!.last!,
            ));
          }
        }

        // ---------------- get all guests ----------------------
        List<Employee> tempGuests = [];
        int numberOfAcceptedGuests = 0;
        int numberOfRejectedGuests = 0;
        for (var guest in element.invitedGuests) {
          for (var employee in allEmployees) {
            if (employee.email == guest.guestEmail!.last! &&
                guest.status!.last != "deleted") {
              if (employee.invitedEvents[element.id] == "Accepted") {
                numberOfAcceptedGuests++;
              } else if (employee.invitedEvents[element.id] == "Rejected") {
                numberOfRejectedGuests++;
              }
              tempGuests.add(Employee(
                  email: guest.guestEmail!.last!,
                  department: employee.department,
                  arabicDepartment: employee.arabicDepartment,
                  arabicName: employee.arabicName,
                  name: employee.name,
                  role: employee.role,
                  imageUrl: employee.imageUrl,
                  invitedEvents: employee.invitedEvents,
                  approvalEvents: employee.approvalEvents));
            }
          }
        }

        Employee? tempApprovalEmployee;
        for (var employee in allEmployees) {
          if (employee.email == element.eventApproval.approval!.last!) {
            tempApprovalEmployee = Employee(
                email: element.eventApproval.approval!.last!,
                department: employee.department,
                name: employee.name,
                arabicDepartment: employee.arabicDepartment,
                arabicName: employee.arabicName,
                role: employee.role,
                imageUrl: employee.imageUrl,
                invitedEvents: employee.invitedEvents,
                approvalEvents: employee.approvalEvents);
          }
        }

        temp.add(EventModel(
          eventCreator: element.eventCreator!,
          id: element.id!,
          status: element.status.status!.last!.capitalize!,
          eventPhoto: element.flyer.eventFlyer!.last!,
          invited: tempGuests.length.toString(),
          accepted: numberOfAcceptedGuests.toString(),
          rejected: numberOfRejectedGuests.toString(),
          eventNameEnglish: element.englishTitle.title!.last!.capitalize!,
          eventNameArabic: element.arabicTitle.title!.last!,
          summary: element.englishSummary.summary!.last!.capitalize!,
          summaryArabic: element.arabicSummary.summary!.last!,
          agenda: element.englishAgenda.agenda!.last!.capitalize!,
          agendaArabic: element.arabicAgenda.agenda!.last!,
          departmentOwner:
              element.departmentOwner.departmentOwner!.last!.capitalize!,
          date: element.eventDate.eventDate!.last!,
          time: element.eventTime.eventTime!.last!,
          type: element.eventType.eventType!.last!,
          flyer: element.flyer.flyerName!.last!,
          isRemote: element.isRemote.isRemote!.last!,
          isOnsite: element.isOnSite.isOnSite!.last!,
          remoteUrl: element.isRemote.isRemote!.last!
              ? element.eventVenue.venueData!.last!
              : '',
          onSiteAddress: element.isOnSite.isOnSite!.last!
              ? element.eventVenue.venueData!.last!.capitalize!
              : '',
          maximumCapacity: element.maximumCapacity.maximumCapacity!.last!,
          guests: tempGuests,
          reminders: tempReminders,
          sendReminders: element.hasReminder.hasReminder!.last!,
          requiredApproval: element.eventApproval.hasApproval!.last!,
          approvalEmail: tempApprovalEmployee,
          hasSurvey: element.hasSurvey.hasSurvey!.last!,
          surveyId: element.surveyId.id!.last!,
        ));
      }

      events.assignAll(temp);
      filterEvents(eventHomeSelectedIndexFilter);
      historicalEvents.assignAll(temp);

      log("Successfully get Events From Firebase");

      update();
    } catch (e) {
      log(e.toString());
    }
  }

  // ------------------------------------- fetch Employees ---------------------------------------------------------------

  Future<void> fetchEmployees() async {
    // print("fetchEmployees");
    try {
      allEmployees.clear();
      allApprovalsAndInvitations.clear();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Approval_And_Invited_Events")
          .get();

      List<ApprovalAndInvitedListModel> tempApprovalAndInvitedList =
          querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ApprovalAndInvitedListModel.fromMap(doc.id, data);
      }).toList();
      // print('0000000000000000000000000000');
      for (var e in tempApprovalAndInvitedList) {
        allApprovalsAndInvitations[e.id!] = ApprovalAndInvitedListModel(
            id: e.id,
            approvalEvents: e.approvalEvents,
            invitedEvents: e.invitedEvents);
      }
     // // print('1111111111111111111111111');
      for (NewEmployeeModelHistory employeeModel in Get.find<EmployeeController>().allEmployees!) {
        Map<String, String> tempInvited = {};
        for (AssignedEvent element
            in allApprovalsAndInvitations[employeeModel.email!.last]
                    ?.invitedEvents ??
                []) {
          if (element.status!.last!.capitalize! != "Deleted") {
            tempInvited.putIfAbsent(element.eventId!.last!,
                () => element.status!.last!.capitalize!);
          }
        }
      //  // print('22222222222222222222222');
        Map<String, String> tempApproval = {};
        for (AssignedEvent element
            in allApprovalsAndInvitations[employeeModel.email!.last]
                    ?.approvalEvents ??
                []) {
          tempApproval.putIfAbsent(
              element.eventId!.last!, () => element.status!.last!.capitalize!);
        }
      //  // print('33333333333333');
        Employee employee = Employee(
            email: employeeModel.email!.last!,
            department: addDepartmentController
                .getEnglishDepartmentNameFromDepartmentId(
                departmentId:
                employeeModel.departmentId!.last! )! ,
            arabicDepartment: addDepartmentController
                .getEnglishDepartmentNameFromDepartmentId(
                departmentId:
                employeeModel.departmentId!.last! )!,
            name:
                "${employeeModel.firstName!.last!} ${employeeModel.lastName!.last!}",
            arabicName:
                "${employeeModel.firstNameInArabic!.last!} ${employeeModel.lastNameInArabic!.last!}",
            role: employeeModel.role!.last!,
            imageUrl: employeeModel.photo!.isNotEmpty
                ? employeeModel.photo!.last!
                : employeeModel.gender?.lastOrNull == 'female'
                    ? 'assets/images/female_avatar.png'
                    : 'assets/images/male_avatar.png',
            invitedEvents: tempInvited,
            approvalEvents: tempApproval);
       // // print('employeesddfd6666666 $employee');
        allEmployees.add(employee);
      }

      log("Successfully get data");
    } catch (e) {
      log(e.toString());
    }
  }

  // ------------------------------------- fetch Approvals ---------------------------------------------------------------

  void fetchApprovals() async {
    try {
      List<EventModel> temp = [];
      for (var approvalEvent
          in allApprovalsAndInvitations[employee!.email!.last]!
              .approvalEvents) {
        for (var event in events) {
          if (approvalEvent.eventId!.last! == event.id &&
              approvalEvent.status!.last! == "Pending") {
            temp.add(event);
          }
        }
      }
      approvalEvents.assignAll(temp);
      filterEvents(eventHomeSelectedIndexFilter);
      log("fetchApprovals Done Successfully");
    } catch (e) {
      log("Error at fetchApprovals: $e");
    }

    update();
  }

  // ------------------------------------------------------------------------------------------------------------------

  //  for page filter in employee
  int employeeSelectedIndex = 0;
  List<String> filtersDataEmployee = [
    'Current'.tr,
    'History'.tr,
    'Approvals'.tr
  ];
  List<String> filtersDataEmployeeNoApprovals = [
    'Current'.tr,
    'History'.tr,
  ];

  void employeeFilterState(int value) {
    employeeSelectedIndex = value;
    update();
  }

  // ------------------------------------- create Event ---------------------------------------------------------------

  TextEditingController eventNameEnglish = TextEditingController();
  TextEditingController eventNameArabic = TextEditingController();
  TextEditingController summary = TextEditingController();
  TextEditingController summaryArabic = TextEditingController();
  TextEditingController agenda = TextEditingController();
  TextEditingController agendaArabic = TextEditingController();
  bool requiredApproval = false;
  bool sendReminders = false;
  TextEditingController maximumCapacity = TextEditingController();
  TextEditingController inviteController = TextEditingController();
  TextEditingController approvalFrom = TextEditingController();

  TextEditingController reminderDateFirsrt = TextEditingController();
  TextEditingController reminderTimeFirsrt = TextEditingController();
  TextEditingController reminderDateSecond = TextEditingController();
  TextEditingController reminderTimeSecond = TextEditingController();
  List<Reminder> reminders = [];

  TextEditingController date = TextEditingController();
  TextEditingController time = TextEditingController();
  String? type;
  TextEditingController flyer = TextEditingController();
  String? downloadUrl;
  bool isRemote = false;
  bool isOnsite = false;
  TextEditingController remoteUrl = TextEditingController();
  TextEditingController onSiteAddress = TextEditingController();
  String? departmentOwner;
  List<String> departmentOwnerItems = ['Marketing', 'Media'];
  List<Employee> invitedEmployees =
      []; // mazen this is the list of the invited employees

  FirebaseFirestore db = FirebaseFirestore.instance;

  List<EventReminderModel> appendReminders(Timestamp timestamp) {
    if (reminders.isNotEmpty) {
      List<EventReminderModel> temp = [];
      for (int i = 0; i < reminders.length; i++) {
        if (i == 0) {
          temp.add(EventReminderModel(
              reminderDate: [reminderDateFirsrt.text],
              reminderTime: [reminderTimeFirsrt.text],
              timestamps: [timestamp]));
        }
        if (i == 1) {
          temp.add(EventReminderModel(
              reminderDate: [reminderDateSecond.text],
              reminderTime: [reminderTimeSecond.text],
              timestamps: [timestamp]));
        }
      }
      return temp;
    }
    return [];
  }

  List<EventInviteGuestModel> appendGuests(Timestamp timestamp) {
    if (invitedEmployees.isNotEmpty) {
      return invitedEmployees
          .map((e) => EventInviteGuestModel(
              guestEmail: [e.email.trim()],
              status: ["sent"],
              timestamps: [timestamp]))
          .toList();
    }
    return [];
  }

  Future<void> createEvent(String status) async {
    try {
      showLoadingIndicator();
      Timestamp timestamp = Timestamp.now();

      // for translation
      onSiteAddress.text = convertNumberToEnglish(onSiteAddress.text);
      maximumCapacity.text = convertNumberToEnglish(maximumCapacity.text);
      requiredEmployee != null
          ? approvalFrom.text = requiredEmployee!.email
          : null;
      EventsModel event = EventsModel(
        eventCreator: employee!.email!.last,
        eventId: EventIdModel(eventId: ["0"], timestamps: [timestamp]),
        englishTitle: EventTitleModel(
            title: [eventNameEnglish.text.trim()], timestamps: [timestamp]),
        arabicTitle: EventTitleModel(
            title: [eventNameArabic.text.trim()], timestamps: [timestamp]),
        englishSummary: EventSummaryModel(
            summary: [summary.text.trim()], timestamps: [timestamp]),
        arabicSummary: EventSummaryModel(
            summary: [summaryArabic.text.trim()], timestamps: [timestamp]),
        englishAgenda: EventAgendaModel(
            agenda: [agenda.text.trim()], timestamps: [timestamp]),
        arabicAgenda: EventAgendaModel(
            agenda: [agendaArabic.text.trim()], timestamps: [timestamp]),
        departmentOwner: DepartmentOwnerModel(
            departmentOwner: [departmentOwner?.toLowerCase() ?? "".trim()],
            timestamps: [timestamp]),
        eventDate: EventDateModel(
            eventDate: [date.text.trim()], timestamps: [timestamp]),
        eventTime: EventTimeModel(
            eventTime: [time.text.trim()], timestamps: [timestamp]),
        eventType: EventTypeModel(
            eventType: [type ?? "".trim()], timestamps: [timestamp]),
        flyer: EventFlyerModel(
            flyerName: [flyer.text.trim()],
            eventFlyer: [downloadUrl ?? ""],
            timestamps: [timestamp]),
        isRemote: IsRemoteModel(isRemote: [isRemote], timestamps: [timestamp]),
        isOnSite: IsOnSiteModel(isOnSite: [isOnsite], timestamps: [timestamp]),
        eventVenue: EventVenueDataModel(venueData: [
          isRemote ? remoteUrl.text.trim() : onSiteAddress.text.trim()
        ], timestamps: [
          timestamp
        ]),
        maximumCapacity: EventMaximumCapacityModel(
            maximumCapacity: [maximumCapacity.text.trim()],
            timestamps: [timestamp]),
        invitedGuests: appendGuests(timestamp),
        hasReminder: HasReminder(
            hasReminder: [sendReminders],
            timestamps: [timestamp]), // no variable for reminder
        eventReminders: appendReminders(timestamp),
        eventApproval: EventApprovalModel(
            hasApproval: [requiredApproval],
            approval: [approvalFrom.text.trim()],
            timestamps: [timestamp]),
        hasSurvey: HasSurveyModel(hasSurvey: [false], timestamps: [timestamp]),
        status: EventStatus(
            status: [requiredApproval ? "Pending" : status.trim()],
            timestamps: [timestamp]),
        surveyId: AssignedId(id: [""], timestamps: [timestamp]),
      );

      var id = DateTime.now().toString();

      List<String> topics =
          invitedEmployees.map((e) => e.email.trim()).toList();

      final CollectionReference exam = db.collection('/Events');
    /*  await exam.doc(id).set(event.toMap()).then((value) {
        appNotificationController.sendNotificationToMultiple(
          title: "event invitation",
          arabicTitle: "دعوة الحدث",
          body:
              "${addEmployeeController.getEmployeeNameEnglishArabic(employee!.email!.emails!.last!, true)} invited you to ${event.englishTitle.title!.last!}",
          arabicBody:
              "قام ${addEmployeeController.getEmployeeNameEnglishArabic(employee!.email!.emails!.last!, false)} بدعوتك للحدث ${event.arabicTitle.title!.last!}",
          type: "event",
          eventId: event.eventId.eventId!.last!,
          topics: topics,
        );
      });*/

      if (!requiredApproval && status == "sent") {
        await inviteEmployees(id, timestamp);
      }

      if (requiredApproval && status == "sent") {
        await assignApprovalToEmployee(id, approvalFrom.text.trim(), timestamp);
      }
      filterEvents(0);
      eventHomeSelectedIndexFilter = 0;

      hideLoadingIndicator();
      clearData();
      systemLogsController.systemLogsAction(SystemActions.createEvent);
    } catch (e) {
      log("Error at creating event: $e");
    }
  }

  Future<void> inviteEmployees(String eventId, Timestamp timestamp) async {
    if (invitedEmployees.isNotEmpty) {
      for (var element in invitedEmployees) {
        try {
          CollectionReference employees = FirebaseFirestore.instance
              .collection('Approval_And_Invited_Events');

          DocumentReference employeeDoc = employees.doc(element.email);
          DocumentSnapshot docSnapshot = await employeeDoc.get();

          ApprovalAndInvitedListModel fetchedEmployee =
              ApprovalAndInvitedListModel.fromMap(
            employeeDoc.id,
            docSnapshot.data() as Map<String, dynamic>,
          );

          bool isInvitedBefore = false;
          for (var temp in fetchedEmployee.invitedEvents) {
            if (temp.eventId!.last == eventId) {
              isInvitedBefore = true;
              if (temp.status!.last != "Pending") {
                temp.status!.add("Pending");
                temp.timestamps!.add(timestamp);
              }
              break;
            }
          }

          if (!isInvitedBefore) {
            fetchedEmployee.invitedEvents.add(AssignedEvent(
              eventId: [eventId],
              status: ["Pending"],
              rejectionReason: [""],
              timestamps: [timestamp],
            ));
          }

          await FirebaseFirestore.instance
              .collection('Approval_And_Invited_Events')
              .doc(fetchedEmployee.id)
              .set(fetchedEmployee.toMap(), SetOptions(merge: true));

          log("Employee invited successfully");
        } catch (e) {
          log("Error at invite employees while creating event: $e");
        }
      }
    }
  }

  Future<void> assignApprovalToEmployee(
      String eventId, String email, Timestamp timestamp) async {
    try {
      CollectionReference employees =
          FirebaseFirestore.instance.collection('Approval_And_Invited_Events');

      DocumentReference approvalAndInvitedDoc = employees.doc(email);
      DocumentSnapshot docSnapshot = await approvalAndInvitedDoc.get();

      ApprovalAndInvitedListModel fetchedEmployee =
          ApprovalAndInvitedListModel.fromMap(
        approvalAndInvitedDoc.id,
        docSnapshot.data() as Map<String, dynamic>,
      );

      bool hasApprovalBefore = false;
      for (var temp in fetchedEmployee.approvalEvents) {
        if (temp.eventId!.last == eventId) {
          hasApprovalBefore = true;
          if (temp.status!.last != "Pending") {
            temp.status!.add("Pending");
            temp.timestamps!.add(timestamp);
          }
          break;
        }
      }

      if (!hasApprovalBefore) {
        fetchedEmployee.approvalEvents.add(AssignedEvent(
          eventId: [eventId],
          status: ["Pending"],
          rejectionReason: [""],
          timestamps: [timestamp],
        ));
      }

      await FirebaseFirestore.instance
          .collection('Approval_And_Invited_Events')
          .doc(fetchedEmployee.id)
          .set(fetchedEmployee.toMap(), SetOptions(merge: true));

      log("Assigned approval to employee successfully");
    } catch (e) {
      log("Error at invite employees while creating event: $e");
    }
  }

  clearData() {
    eventNameEnglish.clear();
    eventNameArabic.clear();
    summary.clear();
    summaryArabic.clear();
    agenda.clear();
    agendaArabic.clear();
    requiredApproval = false;
    maximumCapacity.clear();
    inviteController.clear();
    approvalFrom.clear();

    reminderDateFirsrt.clear();
    reminderTimeFirsrt.clear();
    reminderDateSecond.clear();
    reminderTimeSecond.clear();
    reminders = [];

    requiredApprovalController.text = '';
    searchEmployeesList.assignAll([]);
    requiredApprovalEmployeesList.assignAll([]);
    requiredEmployee = null;

    date.clear();
    time.clear();
    type = null;
    flyer.clear();
    isRemote = false;
    isOnsite = false;
    sendReminders = false;
    remoteUrl.clear();
    onSiteAddress.clear();
    departmentOwner = null;
    departmentOwnerItems = ['Marketing', 'Media'];
    invitedEmployees = [];
  }

  // -----------------------------------------Update approval status--------------------------------------------------

  TextEditingController rejectionReason = TextEditingController();

  Future<void> updateApprovalStatus(String eventId, String status) async {
    Timestamp timestamp = Timestamp.now();

    // change status in event
    try {
      EventsModel? tempEvent;
      int eventIndex = 0;
      for (int i = 0; i < fetchedEvents.length; i++) {
        if (fetchedEvents[i].status.status!.last != "deleted") {
          if (events[eventIndex].id == eventId) {
            invitedEmployees.assignAll(events[eventIndex].guests);
          }
          eventIndex++;
        }
        if (fetchedEvents[i].id == eventId) {
          tempEvent = fetchedEvents[i];
        }
      }

      tempEvent!.status.status!.add(status);
      tempEvent.status.timestamps!.add(timestamp);

      await FirebaseFirestore.instance
          .collection('Events')
          .doc(tempEvent.id)
          .set(tempEvent.toMap(), SetOptions(merge: true));
      status == "sent"
          ? systemLogsController.systemLogsAction(SystemActions.approveEvent)
          : systemLogsController.systemLogsAction(SystemActions.cancelEvent);
      log("Update approval status (event) successfully");
    } catch (e) {
      log("Error at update approval status (event): $e");
    }

    // change status in employee
    try {
      for (var approvalEvent
          in allApprovalsAndInvitations[employee!.email!.last]!
              .approvalEvents) {
        log("${approvalEvent.eventId!.last} /// $eventId");
        if (approvalEvent.eventId!.last == eventId) {
          log("event found");
          approvalEvent.status!.add(status);
          approvalEvent.timestamps!.add(timestamp);

          if (status == "canceled") {
            approvalEvent.rejectionReason!.add(rejectionReason.text);
          }
        }
      }

      ApprovalAndInvitedListModel tempApprovalAndInvited =
          ApprovalAndInvitedListModel(
        id: allApprovalsAndInvitations[employee!.email!.last]!.id,
        approvalEvents:
            allApprovalsAndInvitations[employee!.email!.last]!
                .approvalEvents,
        invitedEvents:
            allApprovalsAndInvitations[employee!.email!.last]!
                .invitedEvents,
      );

      await FirebaseFirestore.instance
          .collection('Approval_And_Invited_Events')
          .doc(tempApprovalAndInvited.id)
          .set(tempApprovalAndInvited.toMap(), SetOptions(merge: true));
      if (status == "sent") {
        await inviteEmployees(eventId, timestamp);
      }
      rejectionReason.text = "";
      log("Update approval status (employee) successfully");
    } catch (e) {
      log("Error at update approval status (employee): $e");
    }

    update();
  }

  //------------ ------------------------------------ edit event ---------------------------------------------------

  Future<void> editEvent(EventModel eventModel, String newStatus) async {
    // for translation
    onSiteAddress.text = convertNumberToEnglish(onSiteAddress.text);
    maximumCapacity.text = convertNumberToEnglish(maximumCapacity.text);

    EventsModel? oldModel;
    Timestamp timestamp = Timestamp.now();
    for (int i = 0; i < fetchedEvents.length; i++) {
      if (fetchedEvents[i].id == eventModel.id) {
        oldModel = fetchedEvents[i];
        break;
      }
    }
    bool flag = false;

    requiredEmployee != null
        ? approvalFrom.text = requiredEmployee!.email
        : null;
    try {
      showLoadingIndicator();

      if (oldModel!.eventApproval.hasApproval!.last != requiredApproval) {
        oldModel.eventApproval.hasApproval!.add(requiredApproval);
        oldModel.eventApproval.timestamps!.add(Timestamp.now());
        flag = true;
        if (oldModel.eventApproval.approval!.last != approvalFrom.text.trim()) {
          await updateApprovalInEdit(
              eventId: eventModel.id,
              newEmail: approvalFrom.text.trim(),
              oldEmail: oldModel.eventApproval.approval!.last!.trim(),
              timestamp: timestamp);
          oldModel.eventApproval.approval!.add(approvalFrom.text.trim());
        }

        if (!requiredApproval) {
          await updateApprovalInEdit(
              eventId: eventModel.id,
              newEmail: "",
              oldEmail: oldModel.eventApproval.approval!.last!.trim(),
              timestamp: timestamp);
        }
      }

      if (oldModel.status.status!.last == "saved" && newStatus == "sent") {
        if (!requiredApproval) {
          await inviteEmployees(oldModel.id!, timestamp);
        }

        if (requiredApproval) {
          await assignApprovalToEmployee(
              oldModel.id!, approvalFrom.text.trim(), timestamp);
        }

        flag = true;
      } else if (oldModel.status.status!.last == "sent" &&
          newStatus == "saved") {
        await deleteInviteEmployees(
            eventId: eventModel.id.trim(),
            newGuests: [],
            oldEvent: oldModel,
            timestamp: timestamp);
      } else if (oldModel.status.status!.last == newStatus &&
          newStatus == "sent") {
        await deleteInviteEmployees(
            eventId: eventModel.id.trim(),
            newGuests: invitedEmployees,
            oldEvent: oldModel,
            timestamp: timestamp);

        await addInviteGuestInEdit(
            eventId: eventModel.id.trim(),
            newGuests: invitedEmployees,
            oldEvent: oldModel,
            timestamp: timestamp);
        flag = true;
      }

      if (oldModel.status.status!.last != newStatus) {
        oldModel.status.status!.add(newStatus);
        oldModel.status.timestamps!.add(Timestamp.now());
        flag = true;
      }

      if (oldModel.arabicTitle.title!.last != eventNameArabic.text.trim()) {
        oldModel.arabicTitle.title!.add(eventNameArabic.text.trim());
        oldModel.arabicTitle.timestamps!.add(Timestamp.now());
        flag = true;
      }
      if (oldModel.englishTitle.title!.last != eventNameEnglish.text.trim()) {
        oldModel.englishTitle.title!.add(eventNameEnglish.text.trim());
        oldModel.englishTitle.timestamps!.add(Timestamp.now());
        flag = true;
      }

      if (oldModel.englishSummary.summary!.last != summary.text.trim()) {
        oldModel.englishSummary.summary!.add(summary.text.trim());
        oldModel.englishSummary.timestamps!.add(Timestamp.now());
        flag = true;
      }
      if (oldModel.arabicSummary.summary!.last != summaryArabic.text.trim()) {
        oldModel.arabicSummary.summary!.add(summaryArabic.text.trim());
        oldModel.arabicSummary.timestamps!.add(Timestamp.now());
        flag = true;
      }

      if (oldModel.englishAgenda.agenda!.last != agenda.text.trim()) {
        oldModel.englishAgenda.agenda!.add(agenda.text.trim());
        oldModel.englishAgenda.timestamps!.add(Timestamp.now());
        flag = true;
      }

      if (oldModel.arabicAgenda.agenda!.last != agendaArabic.text.trim()) {
        oldModel.arabicAgenda.agenda!.add(agendaArabic.text.trim());
        oldModel.arabicAgenda.timestamps!.add(Timestamp.now());
        flag = true;
      }

      if (oldModel.eventDate.eventDate!.last != date.text.trim()) {
        oldModel.eventDate.eventDate!.add(date.text.trim());
        oldModel.eventDate.timestamps!.add(Timestamp.now());
        flag = true;
      }

      if (oldModel.eventTime.eventTime!.last != time.text.trim()) {
        oldModel.eventTime.eventTime!.add(time.text.trim());
        oldModel.eventTime.timestamps!.add(Timestamp.now());
        flag = true;
      }

      if (oldModel.eventType.eventType!.last != type) {
        oldModel.eventType.eventType!.add(type);
        oldModel.eventType.timestamps!.add(Timestamp.now());
        flag = true;
      }

      if (oldModel.flyer.flyerName!.last != flyer.text.trim()) {
        oldModel.flyer.flyerName!.add(flyer.text.trim());
        oldModel.flyer.timestamps!.add(Timestamp.now());
        flag = true;
      }

      if (oldModel.flyer.eventFlyer!.last != downloadUrl &&
          downloadUrl != null) {
        oldModel.flyer.eventFlyer!.add(downloadUrl);
        oldModel.flyer.timestamps!.add(Timestamp.now());
        flag = true;
      }

      if (oldModel.isRemote.isRemote!.last != isRemote) {
        oldModel.isRemote.isRemote!.add(isRemote);
        oldModel.isRemote.timestamps!.add(Timestamp.now());
        flag = true;
      }

      if (oldModel.isOnSite.isOnSite!.last != isOnsite) {
        oldModel.isOnSite.isOnSite!.add(isOnsite);
        oldModel.isOnSite.timestamps!.add(Timestamp.now());
        flag = true;
      }

      if (oldModel.eventVenue.venueData!.last !=
          (isRemote ? remoteUrl.text.trim() : onSiteAddress.text.trim())) {
        oldModel.eventVenue.venueData!
            .add(isRemote ? remoteUrl.text.trim() : onSiteAddress.text.trim());
        oldModel.eventVenue.timestamps!.add(Timestamp.now());
        flag = true;
      }

      if (oldModel.departmentOwner.departmentOwner!.last != departmentOwner) {
        oldModel.departmentOwner.departmentOwner!.add(departmentOwner);
        oldModel.departmentOwner.timestamps!.add(Timestamp.now());
        flag = true;
      }

      if (oldModel.maximumCapacity.maximumCapacity!.last !=
          maximumCapacity.text.trim()) {
        oldModel.maximumCapacity.maximumCapacity!
            .add(maximumCapacity.text.trim());
        oldModel.maximumCapacity.timestamps!.add(Timestamp.now());
        flag = true;
      }

      if (invitedEmployees.length < oldModel.invitedGuests.length) {
        for (int i = invitedEmployees.length;
            i < oldModel.invitedGuests.length;
            i++) {
          oldModel.invitedGuests[i].status!.add("deleted");
          oldModel.invitedGuests[i].timestamps!.add(Timestamp.now());
          flag = true;
        }
      }

      for (int i = 0; i < invitedEmployees.length; i++) {
        String employeeEmail = invitedEmployees[i].email.trim();
        if (i >= oldModel.invitedGuests.length) {
          oldModel.invitedGuests.add(EventInviteGuestModel(
            guestEmail: [employeeEmail],
            status: ["sent"],
            timestamps: [Timestamp.now()],
          ));
          flag = true;
        } else {
          if (oldModel.invitedGuests[i].guestEmail!.last != employeeEmail) {
            oldModel.invitedGuests[i].guestEmail!.add(employeeEmail);
            oldModel.invitedGuests[i].timestamps!.add(Timestamp.now());
            if (oldModel.invitedGuests[i].status!.last == "deleted") {
              oldModel.invitedGuests[i].status!.add("sent");
            }
            flag = true;
          } else {
            if (oldModel.invitedGuests[i].status!.last == "deleted") {
              oldModel.invitedGuests[i].status!.add("sent");
              oldModel.invitedGuests[i].timestamps!.add(Timestamp.now());
              flag = true;
            }
          }
        }
      }

      if (oldModel.hasReminder.hasReminder!.last != sendReminders) {
        oldModel.hasReminder.hasReminder!.add(sendReminders);
        oldModel.hasReminder.timestamps!.add(Timestamp.now());
        flag = true;
      }

      if (sendReminders) {
        for (int i = 0; i < reminders.length; i++) {
          if (i >= oldModel.eventReminders.length) {
            if (i == 0) {
              log("Added First Reminder : ${reminderDateFirsrt.text} ");
              oldModel.eventReminders.add(EventReminderModel(
                  reminderDate: [reminderDateFirsrt.text],
                  reminderTime: [reminderTimeFirsrt.text],
                  timestamps: [timestamp]));
              flag = true;
            }
            if (i == 1) {
              log("Added Second Reminder : ${reminderDateSecond.text} ");
              oldModel.eventReminders.add(EventReminderModel(
                  reminderDate: [reminderDateSecond.text],
                  reminderTime: [reminderTimeSecond.text],
                  timestamps: [timestamp]));
              flag = true;
            }
          } else {
            if (i == 0) {
              bool changed = false;
              if (oldModel.eventReminders[i].reminderDate!.last !=
                  reminderDateFirsrt.text) {
                changed = true;
                oldModel.eventReminders[i].reminderDate!
                    .add(reminderDateFirsrt.text);
              }

              if (oldModel.eventReminders[i].reminderTime!.last !=
                  reminderTimeFirsrt.text) {
                changed = true;
                oldModel.eventReminders[i].reminderTime!
                    .add(reminderTimeFirsrt.text);
              }

              if (changed) {
                oldModel.eventReminders[i].timestamps!.add(Timestamp.now());
                flag = true;
              }
            }

            if (i == 1) {
              bool changed = false;
              if (oldModel.eventReminders[i].reminderDate!.last !=
                  reminderDateSecond.text) {
                changed = true;
                oldModel.eventReminders[i].reminderDate!
                    .add(reminderDateSecond.text);
              }

              if (oldModel.eventReminders[i].reminderTime!.last !=
                  reminderTimeSecond.text) {
                changed = true;
                oldModel.eventReminders[i].reminderTime!
                    .add(reminderTimeSecond.text);
              }

              if (changed) {
                flag = true;
                oldModel.eventReminders[i].timestamps!.add(Timestamp.now());
              }
            }
          }
        }
      } else {
        flag = true;
        oldModel.eventReminders.clear();
      }

      if (reminders.length < oldModel.eventReminders.length) {
        for (int i = reminders.length;
            i < oldModel.eventReminders.length;
            i++) {
          oldModel.eventReminders.removeAt(i);
          flag = true;
        }
      }

      List<String> topics = [];

      for (int i = 0; i < eventModel.guests.length; i++) {
        if (eventModel.guests[i].invitedEvents[eventModel.id] == "Accepted") {
          topics.add(eventModel.guests[i].email);
        }
      }

      final CollectionReference event = db.collection('/Events');
      await event
          .doc(eventModel.id)
          .set(oldModel.toMap(), SetOptions(merge: true))
          .then((_) async {
   /*     if (newStatus == 'sent') {
          if (flag) {
            await appNotificationController.sendNotificationToMultiple(
              topics: topics,
              arabicBody:
                  " تم تحديث الحدث  من قِبل ${addEmployeeController.getEmployeeNameEnglishArabic(oldModel!.eventCreator!, false)}, تحقق من التفاصيل للحصول على آخر المعلومات ",
              arabicTitle: oldModel.arabicTitle.title!.last!,
              body:
                  "${addEmployeeController.getEmployeeNameEnglishArabic(oldModel!.eventCreator!, true)} updated The event , Check the details for the latest information.",
              title: oldModel.englishTitle.title!.last!,
              eventId: oldModel.eventId.eventId!.last!,
              type: "event",
            );
          }
        }*/
        hideLoadingIndicator();
        clearData();
        systemLogsController.systemLogsAction(SystemActions.updateEvent);
      });

      log("edit Successfully");
    } catch (e) {
      log("Error at editing event: $e");
    }
  }

  Future<void> addInviteGuestInEdit(
      {required String eventId,
      required EventsModel oldEvent,
      required List<Employee> newGuests,
      required Timestamp timestamp}) async {
    try {
      if (newGuests.isNotEmpty) {
        for (var newGuest in newGuests) {
          bool isFound = false;
          for (var oldGuest in oldEvent.invitedGuests) {
            if (newGuest.email == oldGuest.guestEmail!.last &&
                oldGuest.status!.last != "deleted") {
              log(" Email found ");
              isFound = true;
            }
          }

          if (!isFound) {
            CollectionReference employees = FirebaseFirestore.instance
                .collection('Approval_And_Invited_Events');

            DocumentReference employeeDoc = employees.doc(newGuest.email);
            DocumentSnapshot docSnapshot = await employeeDoc.get();

            ApprovalAndInvitedListModel fetchedEmployee =
                ApprovalAndInvitedListModel.fromMap(
              employeeDoc.id,
              docSnapshot.data() as Map<String, dynamic>,
            );

            bool employeeHasEvent = false;

            for (var element in fetchedEmployee.invitedEvents) {
              if (element.eventId!.last == eventId) {
                employeeHasEvent = true;
                element.status!.add("Pending");
                element.timestamps!.add(timestamp);
              }
            }

            if (!employeeHasEvent) {
              fetchedEmployee.invitedEvents.add(AssignedEvent(
                  eventId: [eventId],
                  status: ["Pending"],
                  rejectionReason: [""],
                  timestamps: [timestamp]));
            }

            await FirebaseFirestore.instance
                .collection('Approval_And_Invited_Events')
                .doc(fetchedEmployee.id)
                .set(fetchedEmployee.toMap(), SetOptions(merge: true));
          }
        }
      }

      log("Added successfully");
    } catch (e) {
      log("Error at adding event: $e");
    }
  }

  Future<void> deleteInviteEmployees(
      {required String eventId,
      required EventsModel oldEvent,
      required List<Employee> newGuests,
      required Timestamp timestamp}) async {
    try {
      if (newGuests.isNotEmpty) {
        for (var oldGuest in oldEvent.invitedGuests) {
          bool isFound = false;
          for (var newGuest in newGuests) {
            if (newGuest.email == oldGuest.guestEmail!.last &&
                oldGuest.status!.last != "deleted") {
              log(" Email found ");
              isFound = true;
            }
          }

          if (oldEvent.invitedGuests.isEmpty) {
            addInviteGuestInEdit(
                eventId: eventId,
                newGuests: newGuests,
                oldEvent: oldEvent,
                timestamp: timestamp);
            break;
          }

          if (!isFound) {
            CollectionReference employees = FirebaseFirestore.instance
                .collection('Approval_And_Invited_Events');

            DocumentReference employeeDoc =
                employees.doc(oldGuest.guestEmail!.last);
            DocumentSnapshot docSnapshot = await employeeDoc.get();

            ApprovalAndInvitedListModel fetchedEmployee =
                ApprovalAndInvitedListModel.fromMap(
              employeeDoc.id,
              docSnapshot.data() as Map<String, dynamic>,
            );

            for (var i = 0; i < fetchedEmployee.invitedEvents.length; i++) {
              if (fetchedEmployee.invitedEvents[i].eventId!.last == eventId) {
                if (fetchedEmployee.invitedEvents[i].status!.last !=
                    "deleted") {
                  fetchedEmployee.invitedEvents[i].status!.add("deleted");
                  fetchedEmployee.invitedEvents[i].timestamps!.add(timestamp);
                }

                await FirebaseFirestore.instance
                    .collection('Approval_And_Invited_Events')
                    .doc(fetchedEmployee.id)
                    .set(fetchedEmployee.toMap(), SetOptions(merge: true));

                break;
              }
            }
          }
        }
      } else {
        /*for (var em in addEmployeeController.allEmployees!) {
          for (var i = 0;
              i <
                  allApprovalsAndInvitations[em.email!.emails!.last]!
                      .invitedEvents
                      .length;
              i++) {
            if (allApprovalsAndInvitations[em.email!.emails!.last]!
                    .invitedEvents[i]
                    .eventId!
                    .last ==
                eventId) {
              allApprovalsAndInvitations[em.email!.emails!.last]!
                  .invitedEvents[i]
                  .status!
                  .add("deleted");
              allApprovalsAndInvitations[em.email!.emails!.last]!
                  .invitedEvents[i]
                  .timestamps!
                  .add(timestamp);

              await FirebaseFirestore.instance
                  .collection('Approval_And_Invited_Events')
                  .doc(em.email!.emails!.last)
                  .set(em.toMap(), SetOptions(merge: true));

              break;
            }
          }
        }*/
      }

      log("succfully delete Invited employees");
    } on Exception catch (e) {
      log("Error at deleting event: $e");
    }
  }

  Future<void> updateApprovalInEdit(
      {required String eventId,
      required String newEmail,
      required String oldEmail,
      required Timestamp timestamp}) async {
    try {
      NewEmployeeModelHistory? newEmployee;
      NewEmployeeModelHistory? oldEmployee;

   /*   for (var element in addEmployeeController.allEmployees!) {
        if (element.email!.emails!.last == newEmail) {
          newEmployee = element;
        }

        if (element.email!.emails!.last == oldEmail) {
          oldEmployee = element;
        }
      }*/

      if (newEmployee != null) {
        bool employeeHasEvent = false;

        for (var element
            in allApprovalsAndInvitations[newEmployee.email!.last]!
                .approvalEvents) {
          if (element.eventId!.last == eventId) {
            employeeHasEvent = true;
            element.status!.add("Pending");
            element.timestamps!.add(timestamp);
          }
        }
        if (!employeeHasEvent) {
          allApprovalsAndInvitations[newEmployee.email!.last]!
              .approvalEvents
              .add(AssignedEvent(
                eventId: [eventId],
                status: ["Pending"],
                rejectionReason: [""],
                timestamps: [timestamp],
              ));
        }

        ApprovalAndInvitedListModel tempApprovalAndInvited =
            ApprovalAndInvitedListModel(
          id: newEmployee.email!.last,
          approvalEvents:
              allApprovalsAndInvitations[newEmployee.email!.last]!
                  .approvalEvents,
          invitedEvents:
              allApprovalsAndInvitations[newEmployee.email!.last]!
                  .invitedEvents,
        );

        await FirebaseFirestore.instance
            .collection('Approval_And_Invited_Events')
            .doc(tempApprovalAndInvited.id)
            .set(tempApprovalAndInvited.toMap(), SetOptions(merge: true));
      }

      if (oldEmployee != null) {
        for (var i = 0;
            i <
                allApprovalsAndInvitations[oldEmployee.email!.last]!
                    .approvalEvents
                    .length;
            i++) {
          if (allApprovalsAndInvitations[oldEmployee.email!.last]!
                  .approvalEvents[i]
                  .eventId!
                  .last ==
              eventId) {
            allApprovalsAndInvitations[oldEmployee.email!.last]!
                .approvalEvents[i]
                .status!
                .add("deleted");
            allApprovalsAndInvitations[oldEmployee.email!.last]!
                .approvalEvents[i]
                .timestamps!
                .add(timestamp);

            ApprovalAndInvitedListModel tempApprovalAndInvited =
                ApprovalAndInvitedListModel(
              id: oldEmployee.email!.last,
              approvalEvents:
                  allApprovalsAndInvitations[oldEmployee.email!.last]!
                      .approvalEvents,
              invitedEvents:
                  allApprovalsAndInvitations[oldEmployee.email!.last]!
                      .invitedEvents,
            );

            await FirebaseFirestore.instance
                .collection('Approval_And_Invited_Events')
                .doc(tempApprovalAndInvited.id)
                .set(tempApprovalAndInvited.toMap(), SetOptions(merge: true));
            break;
          }
        }
      }
      log("Assigned approval to employee successfully");
    } catch (e) {
      log("Error at invite employees while creating event: $e");
    }
  }

  // --------------------------------------// update event to toke survey id //--------------------------------------------------------------------------

  Future<void> updateSurveyIdInEvent(
      {required String eventId,
      required Timestamp timestamp,
      required String surveyId}) async {
    try {
      for (int i = 0; i < fetchedEvents.length; i++) {
        if (fetchedEvents[i].id == eventId) {
          fetchedEvents[i].surveyId.id!.add(surveyId);
          fetchedEvents[i].surveyId.timestamps!.add(timestamp);

          fetchedEvents[i].hasSurvey.hasSurvey!.add(true);
          fetchedEvents[i].hasSurvey.timestamps!.add(timestamp);

          final CollectionReference event = db.collection('/Events');
          await event
              .doc(eventId)
              .set(fetchedEvents[i].toMap(), SetOptions(merge: true));

          break;
        }
      }

      log("");
    } catch (e) {
      log("Error at update event to toke survey id : $e");
    }
  }

  //------------------------------------------------------------------------

  int createEventpageIndex = 0;
  void nextStepCreateEvent() {
    createEventpageIndex++;
    update();
  }

  void perviousStepCreateEvent() {
    createEventpageIndex--;
    update();
  }

  void onEditsavePressed() {
    update();
  }

  void addFlyer() async {
    ImagePicker imagePicker = ImagePicker();

    var image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      showLoadingIndicator();
      final reference = FirebaseStorage.instance
          .ref()
          .child("EventFlyer")
          .child(image.name.trim());
      flyer.text = image.name.trim();
      // Upload the image file
      await reference.putFile(File(image.path));

      // Get the download URL
      downloadUrl = await reference.getDownloadURL();

      hideLoadingIndicator();

      update();
    }
  }

  void changeisRemoteState() {
    isRemote = !isRemote;
    isRemote == true ? isOnsite = false : isOnsite = true;
    update();
  }

  void changeisOnsiteState() {
    isOnsite = !isOnsite;
    isOnsite == true ? isRemote = false : isRemote = true;
    update();
  }

  String? departmetFilter;
  String dateFilter = '';
  List<String> typesFilter = ['Workshop', 'Cermony', 'Announcement'];
  String? typeFilter;
  String? statusFilter;
  List<String> statusFilterDropDownItems = [
    'Accepted',
    'Rejected',
    'No Response'
  ];
  String? searchText;
  void resetFilter() {
    departmetFilter = null;
    dateFilter = '';
    typeFilter = null;
    statusFilter = null;
    filterEvents(eventHomeSelectedIndexFilter);
    update();
    Get.back();
  }

  void onSearchTextChanged(String value) {
    searchText = value;
    searchforEvent();
    update();
  }

  // the filter of the screen where you can change to show approval surveys and so on
  // 5 for survey 6 for approvals
  int eventHomeSelectedIndexFilter = 0;
  List<String> filterTitles = [
    'Current'.tr,
    'Pending'.tr,
    'Saved'.tr,
    'History'.tr,
    'Canceled'.tr,
    'Survey'.tr,
    'Approvals'.tr
  ];

  void changeFilterIndex(int value) {
    eventHomeSelectedIndexFilter = value;
    departmetFilter = null;
    dateFilter = '';
    typeFilter = null;
    statusFilter = null;

    filterEvents(eventHomeSelectedIndexFilter);

    update();
  }

  void filterDateValueState(String value) {
    dateFilter = value;
    update();
  }

  void filterStatusValueState(String? value) {
    statusFilter = value;
    update();
  }

  void filterDepartmentValueState(String? value) {
    departmetFilter = value;
    update();
  }

  void filterTypeValueState(String? value) {
    typeFilter = value;
    update();
  }

  void filterEvents(int employeeSelectedIndex) {
    switch (employeeSelectedIndex) {
      case 0:
        filteredevents.assignAll(events.where((element) {
          return (isDateAndTimeNotPassed(element) && element.status == 'Sent');
        }).toList());
        break;
      case 1:
        filteredevents.assignAll(events.where((event) {
          return (event.requiredApproval && event.status == 'Pending');
        }).toList());
        break;
      case 2:
        filteredevents.assignAll(
            events.where((event) => event.status == 'Saved').toList());
        break;
      case 3:
        filteredevents.assignAll(events.where((element) {
          return isDateAndTimePassed(element);
        }).toList());
        break;
      case 4:
        filteredevents.assignAll(
            events.where((event) => event.status == 'Canceled').toList());
        break;
      case 6:
        filteredevents.assignAll(approvalEvents);
        break;
      default:
        filteredevents.assignAll(events);
    }
  }

  bool isDateAndTimePassed(EventModel element) {
    DateFormat dateFormat = DateFormat('dd MMM yyyy HH:mm');
    try {
      String dueDateTimeString = "${element.date} ${element.time}";
      DateTime dueDateTime = dateFormat.parse(dueDateTimeString);
      DateTime now = DateTime.now();
      return dueDateTime.isBefore(now);
    } catch (e) {
      // debug// print('Error parsing date or time: $e');
      return false;
    }
  }

  bool isDateAndTimeNotPassed(EventModel element) {
    DateFormat dateFormat = DateFormat('dd MMM yyyy HH:mm');
    try {
      String dueDateTimeString = "${element.date} ${element.time}";
      DateTime dueDateTime = dateFormat.parse(dueDateTimeString);
      DateTime now = DateTime.now();
      return dueDateTime.isAfter(now);
    } catch (e) {
     // debug// print('Error parsing date or time: $e');
      return false;
    }
  }

  void searchforEvent() {
    if (searchText != "" && searchText != null) {
      Get.locale.toString().contains('en')
          ? filteredevents.assignAll(filteredevents
              .where((event) => event.eventNameEnglish
                  .toLowerCase()
                  .contains(searchText!.toLowerCase()))
              .toList())
          : filteredevents.assignAll(filteredevents
              .where((event) => event.eventNameArabic
                  .toLowerCase()
                  .contains(searchText!.toLowerCase()))
              .toList());
    } else {
      filterEvents(eventHomeSelectedIndexFilter);
    }
    update();
  }

  searchforEventByFilterButtom() {
    if (dateFilter != "") {
      String fromDate;
      String toDate;
      if (dateFilter.contains("To")) {
        fromDate = dateFilter.split("To ").first;
        fromDate = fromDate.replaceFirst("From ", "");
        toDate = dateFilter.split("To ").last;
      } else {
        fromDate = dateFilter.replaceFirst("From ", "");
        DateTime today = DateTime.now();
        toDate = DateFormat('dd MMM yyyy').format(today);
      }
      DateFormat dateFormat = DateFormat('dd MMM yyyy');
      DateTime start = dateFormat.parse(fromDate);
      DateTime end = dateFormat.parse(toDate);

      List<EventModel> temp = [];
      for (int i = 0; i < filteredevents.length; i++) {
        String x = filteredevents[i].date;
        DateTime y = dateFormat.parse(x);

        if (y.isAtSameMomentAs(start) ||
            y.isAtSameMomentAs(end) ||
            (y.isAfter(start) && y.isBefore(end))) {
          temp.add(filteredevents[i]);
        }
      }
      filteredevents.assignAll(temp);
    }
    if (typeFilter != null) {
      filteredevents.assignAll(
          filteredevents.where((event) => event.type == typeFilter).toList());
    }
    if (departmetFilter != null) {
      filteredevents.assignAll(filteredevents
          .where((event) => event.departmentOwner == departmetFilter)
          .toList());
    }

    update();
  }

  bool isSortHomeEnabled = false;

  void changeSortState() {
    isSortHomeEnabled = !isSortHomeEnabled;
    update();
  }

  void sortEvents() {
    storeOriginalOrder();
    Get.locale.toString().contains('en')
        ? filteredevents.sort(
            (event1, event2) {
              return event1.eventNameEnglish
                  .toLowerCase()
                  .compareTo(event2.eventNameEnglish.toLowerCase());
            },
          )
        : filteredevents.sort(
            (event1, event2) {
              return event1.eventNameArabic.compareTo(event2.eventNameArabic);
            },
          );
    update();
  }

  void sortEventsByDate() {
    storeOriginalOrder();
    filteredevents.sort((event1, event2) {
      DateTime date1 = DateFormat('dd MMM yyyy').parse(event1.date);
      DateTime date2 = DateFormat('dd MMM yyyy').parse(event2.date);
      return date2.compareTo(date1);
    });
    update();
  }

  List<EventModel> originalEvents = [];

  void storeOriginalOrder() {
    originalEvents = List.from(filteredevents);
  }

  void resetSorting() {
    filteredevents = List.from(originalEvents);
    update();
  }

  // --------------------------------------- handle invitation in create and edit event -------------------------------------------------------

  void appendInvitedEmployee(Employee employee) {
    // Use firstWhere with orElse to safely handle the absence of a match
    bool employeeAlreadyInvited = alreadyInvited(employee);

    if (!employeeAlreadyInvited) {
      if (maximumCapacity.text == '0' || maximumCapacity.text == '') {
        invitedEmployees = [];
      } else if (maximumCapacity.text != '0' &&
          maximumCapacity.text != '' &&
          invitedEmployees.length == int.parse(maximumCapacity.text)) {
        invitedEmployees.removeAt(0);
        invitedEmployees.add(employee);
      } else {
        invitedEmployees.add(employee);
      }

      update();
    } else {
      log('Employee already invited: ${employee.name}');
    }
  }

  bool alreadyInvited(Employee employee) {
    for (var element in invitedEmployees) {
      if (element.name.trim() == employee.name.trim()) {
        return true;
      }
    }
    return false;
  }

  List<Employee> searchEmployeesList = [];

  void inviteGuests() {
    // print('invite guests called ${inviteController.text}');
    if (inviteController.text != "") {
      searchEmployeesList.assignAll(allEmployees
          .where((employee) => employee.name
              .toLowerCase()
              .contains(inviteController.text.toLowerCase()))
          .toList());
    } else {
      searchEmployeesList.assignAll(invitedEmployees);
    }
    update();
  }

  void deleteInvitedEmployee(Employee employee) {
    searchEmployeesList.remove(employee);
    invitedEmployees.remove(employee);
    update();
  }

  //---------------------------required approval------------------
  List<Employee> requiredApprovalEmployeesList = [];
  TextEditingController requiredApprovalController = TextEditingController();
  Employee? requiredEmployee;

  void inviteRequireGuests() {
    if (requiredApprovalController.text != "") {
      requiredApprovalEmployeesList.assignAll(allEmployees
          .where((employee) => employee.name
              .toLowerCase()
              .contains(requiredApprovalController.text.toLowerCase()))
          .toList());
    } else {
      requiredApprovalEmployeesList.assignAll(invitedEmployees);
    }
    update();
  }

  void deleteInvitedRequiredEmployee(Employee employee) {
    requiredEmployee = null;
    update();
  }

  void appendInvitedRequiredEmployee(Employee employee) {
    // Use firstWhere with orElse to safely handle the absence of a match
    bool employeeAlreadyInvited = alreadyInvitedAtRequired(employee);

    if (!employeeAlreadyInvited) {
      requiredEmployee = employee;
      update();
    } else {
      log('Employee already invited: ${employee.name}');
    }
  }

  bool alreadyInvitedAtRequired(Employee employee) {
    if (requiredEmployee?.name != null &&
        requiredEmployee!.name.trim() == employee.name.trim()) {
      return true;
    }
    return false;
  }
}
