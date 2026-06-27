import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/organization_chart_module/requests/requests_components/requests_filter_appbar.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/constants/system_actions.dart';
import 'package:demo_app/features/employee/data/models/emplyees_model/new_employee_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/presentation/controller/main_core_department_controller.dart';
import 'package:demo_app/core/helper/organization_chart_module/presentation/controller/employee_controller.dart';
import 'package:demo_app/features/notification/notification_controller.dart';
import 'package:demo_app/core/helper/events/components/survey_components/question_card.dart';
import 'package:demo_app/core/helper/events/controllers/events_controllers/event_controller.dart';
import 'package:demo_app/features/home/helper/events/controllers/events_controllers/model/event_model.dart';
import 'package:demo_app/core/helper/events/controllers/survey_controller.dart/model/participants_model.dart';
import 'package:demo_app/core/helper/events/controllers/survey_controller.dart/model/question_card_analytic_model.dart';
import 'package:demo_app/core/helper/events/controllers/survey_controller.dart/model/question_model.dart';
import 'package:demo_app/core/helper/events/controllers/survey_controller.dart/model/survey_model.dart';
import 'package:demo_app/core/helper/events/controllers/survey_controller.dart/survey_controller.dart';
import 'package:demo_app/core/helper/events/models/events_models/event_model.dart';
import 'package:demo_app/core/helper/events/models/more_models/assigned_event_model.dart';
import 'package:demo_app/core/helper/events/models/more_models/email_model.dart';
import 'package:demo_app/core/helper/events/models/more_models/employee_model.dart';
import 'package:demo_app/core/helper/events/models/more_models/employee_submission_model.dart';
import 'package:demo_app/core/helper/events/models/more_models/filled_surveys_model.dart';
import 'package:demo_app/core/helper/events/models/more_models/remaining_time_model.dart';
import 'package:demo_app/core/helper/events/models/more_models/submission_status_model.dart';
import 'package:demo_app/core/helper/events/models/survey_models/survey_firebase_model.dart';
import 'package:demo_app/core/helper/events/models/survey_models/survey_question_model.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';
import 'package:demo_app/features/onboarding/welcome_screen/views/mobile_view/nav_bar.dart';

import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/new_employee_model.dart';

late EmployeeController addEmployeeController;

class EventsEmployeeController extends GetxController {
  var inviteAtEvents = <EventModel>[];
  var approvalEvents = <EventModel>[];
  var filteredevents = <EventModel>[];
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
  var surveys = <SurveyModel>[];
  List<QuestionCard> surveyCards = [];
  NewEmployeeModelHistory? fetchedEmployee;
  Map<String, FilledSurveyModel> filledSurveys = {};

  Map<String, ApprovalAndInvitedListModel> allApprovalsAndInvitations = {};

  List<TextEditingController> employeeSubmissionAnswer = [];

  initalizeEmployeeSubmissionAnswer(int size) {
    employeeSubmissionAnswer =
        List.generate(size, (index) => TextEditingController());
  }

  final EventController eventController = Get.put(EventController());
  SurveyController surveyController = Get.put(SurveyController());
  AppNotificationController appNotificationController =
      Get.put(AppNotificationController());
  @override
  void onInit() async {
    addEmployeeController = Get.put(EmployeeController());

    await fetchEmployees().then((value) async {
      await fetchFilledSurveyModel().then((value) async {
        await fetchEventsFromFirebase();
        fetchApprovals();
        fetchSurveys();
      });
    });

    super.onInit();
  }

  SurveyModel? getSurvey({required String eventId}) {
    for (var survey in surveys) {
      if (survey.eventID == eventId) {
        return survey;
      }
    }
    return null;
  }
  // ------------------------------------- fetch Events ---------------------------------------------------------------

  Future<void> fetchEventsFromFirebase() async {
    try {
      for (var emp in addEmployeeController.allEmployees!) {
        if (emp.email!.last == employee!.email!.last) {
          fetchedEmployee = emp;
        }
      }

      CollectionReference approvalAndInvitedEventsCollection =
          FirebaseFirestore.instance.collection("Approval_And_Invited_Events");

      DocumentReference approvalAndInvitedEdoc =
          approvalAndInvitedEventsCollection.doc(employee!.email!.last);

      DocumentSnapshot approvalAndInvited = await approvalAndInvitedEdoc.get();

      ApprovalAndInvitedListModel fetchedemployeeApproval =
          ApprovalAndInvitedListModel.fromMap(
        approvalAndInvitedEdoc.id,
        approvalAndInvited.data() as Map<String, dynamic>,
      );

      allApprovalsAndInvitations[fetchedEmployee!.email!.last]!
          .approvalEvents
          .assignAll(fetchedemployeeApproval.approvalEvents);

      allApprovalsAndInvitations[fetchedEmployee!.email!.last]!
          .invitedEvents
          .assignAll(fetchedemployeeApproval.invitedEvents);

      // get all events
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Events').get();

      fetchedEvents = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return EventsModel.fromMap(doc.id, data);
      }).toList();

      var temp = <EventModel>[];
      for (var element in fetchedEvents) {
        if (element.status.status!.last == 'sent') {
          for (var invitedEvent in allApprovalsAndInvitations[
                  fetchedEmployee!.email!.last]!
              .invitedEvents) {
            if (invitedEvent.eventId!.last == element.id &&
                invitedEvent.status!.last != "deleted") {
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
                    } else if (employee.invitedEvents[element.id] ==
                        "Rejected") {
                      numberOfRejectedGuests++;
                    }
                    tempGuests.add(Employee(
                        email: guest.guestEmail!.last!,
                        department: employee.department,
                        name: employee.name,
                        role: employee.role,
                        arabicDepartment: employee.arabicDepartment,
                        arabicName: employee.arabicName,
                        imageUrl: employee.imageUrl,
                        invitedEvents: employee.invitedEvents,
                        approvalEvents: employee.approvalEvents));
                  }
                }
              }

              Employee? tempApprovalEmployee;
              for (var employee in allEmployees) {
                if (employee.email == element.eventApproval.approval!.last) {
                  tempApprovalEmployee = Employee(
                      email: element.eventApproval.approval!.last!,
                      department: employee.department,
                      name: employee.name,
                      role: employee.role,
                      imageUrl: employee.imageUrl,
                      arabicDepartment: employee.arabicDepartment,
                      arabicName: employee.arabicName,
                      invitedEvents: employee.invitedEvents,
                      approvalEvents: employee.approvalEvents);
                }
              }

              temp.add(EventModel(
                eventCreator: element.eventCreator!,
                id: element.id!,
                status: invitedEvent.status!.last!.capitalize!,
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
                departmentOwner: element.departmentOwner.departmentOwner!.last!,
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
          }
        }
      }

      inviteAtEvents.assignAll(temp);
      filterEvents(employeeSelectedIndex);
      historicalEvents.assignAll(temp);

      log("Successfully get Events From Firebase (Employee View)");

      update();
    } catch (e) {
      log(e.toString());
    }
  }

  // ------------------------------------- fetch Employees ---------------------------------------------------------------

  Future<void> fetchEmployees() async {
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

      for (var e in tempApprovalAndInvitedList) {
        allApprovalsAndInvitations[e.id!] = ApprovalAndInvitedListModel(
            id: e.id,
            approvalEvents: e.approvalEvents,
            invitedEvents: e.invitedEvents);
      }

      for (NewEmployeeModelHistory employeeModel
          in addEmployeeController.allEmployees!) {
        Map<String, String> tempInvited = {};
        for (AssignedEvent element
            in allApprovalsAndInvitations[employeeModel.email!.last]
                    ?.invitedEvents ??
                []) {
          if (element.status!.last!.capitalize != "Deleted") {
            tempInvited.putIfAbsent(element.eventId!.last!,
                () => element.status!.last!.capitalize!);
          }
        }
        Map<String, String> tempApproval = {};
        for (var element
            in allApprovalsAndInvitations[employeeModel.email!.last]
                    ?.approvalEvents ??
                []) {
          tempApproval.putIfAbsent(
              element.eventId!.last!, () => element.status!.last!.capitalize!);
        }

        Employee employee = Employee(
            arabicName:
                "${employeeModel.firstNameInArabic!.last!} ${employeeModel.lastNameInArabic!.last!}",
            arabicDepartment:
                addDepartmentController.getArabicDepartmentNameFromDepartmentId(
                        departmentId:
                            employeeModel.departmentId!.last!) ??
                    "",
            email: employeeModel.email!.last!,
            department:addDepartmentController.getEnglishDepartmentNameFromDepartmentId(
                departmentId:
                employeeModel.departmentId!.last!) ??
                "",
            name:
                "${employeeModel.firstName!.last!} ${employeeModel.lastName!.last!}",
            role: employeeModel.role!.last!,
            imageUrl: employeeModel.photo!.isNotEmpty
                ? employeeModel.photo!.last!
                : employeeModel.gender?.lastOrNull == 'female'
                    ? 'assets/images/female_avatar.png'
                    : 'assets/images/male_avatar.png',
            invitedEvents: tempInvited,
            approvalEvents: tempApproval);

        allEmployees.add(employee);
      }

      log("Successfully get data (Employee View)");
    } catch (e) {
      log(e.toString());
    }
  }

  // ------------------------------------- fetch Approvals ---------------------------------------------------------------

  void fetchApprovals() async {
    NewEmployeeModelHistory? employee2;
    try {
      for (var element in addEmployeeController.allEmployees!) {
        if (element.email!.last == employee!.email!.last) {
          employee2 = element;
        }
      }
      List<EventModel> temp = [];

      for (var approvalEvent
          in allApprovalsAndInvitations[employee2!.email!.last]!
              .approvalEvents) {
        for (var event in fetchedEvents) {
          if (approvalEvent.eventId!.last! == event.id &&
              approvalEvent.status!.last! != "deleted" &&
              approvalEvent.status!.last! == "Pending") {
            /// &&approvalEvent.status!.last! == "Pending"
            // ----------------- get all reminders----------------------
            List<Reminder> tempReminders = [];
            if (event.hasReminder.hasReminder!.last == true &&
                event.eventReminders.isNotEmpty) {
              for (var reminder in event.eventReminders) {
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
            for (var guest in event.invitedGuests) {
              for (var employee in allEmployees) {
                if (employee.email == guest.guestEmail!.last! &&
                    guest.status!.last != "deleted") {
                  if (employee.invitedEvents[event.id] == "Accepted") {
                    numberOfAcceptedGuests++;
                  } else if (employee.invitedEvents[event.id] == "Rejected") {
                    numberOfRejectedGuests++;
                  }
                  tempGuests.add(Employee(
                      email: guest.guestEmail!.last!,
                      department: employee.department,
                      name: employee.name,
                      role: employee.role,
                      imageUrl: employee.imageUrl,
                      arabicDepartment: employee.arabicDepartment,
                      arabicName: employee.arabicName,
                      invitedEvents: employee.invitedEvents,
                      approvalEvents: employee.approvalEvents));
                }
              }
            }

            Employee? tempApprovalEmployee;
            for (var employee in allEmployees) {
              if (employee.email == event.eventApproval.approval!.last) {
                tempApprovalEmployee = Employee(
                    email: event.eventApproval.approval!.last!,
                    department: employee.department,
                    name: employee.name,
                    role: employee.role,
                    arabicDepartment: employee.arabicDepartment,
                    arabicName: employee.arabicName,
                    imageUrl: employee.imageUrl,
                    invitedEvents: employee.invitedEvents,
                    approvalEvents: employee.approvalEvents);
              }
            }

            temp.add(EventModel(
              eventCreator: event.eventCreator!,
              id: event.id!,
              status: event.status.status!.last!.capitalize!,
              eventPhoto: event.flyer.eventFlyer!.last!,
              invited: tempGuests.length.toString(),
              accepted: numberOfAcceptedGuests.toString(),
              rejected: numberOfRejectedGuests.toString(),
              eventNameEnglish: event.englishTitle.title!.last!.capitalize!,
              eventNameArabic: event.arabicTitle.title!.last!,
              summary: event.englishSummary.summary!.last!.capitalize!,
              summaryArabic: event.arabicSummary.summary!.last!,
              agenda: event.englishAgenda.agenda!.last!.capitalize!,
              agendaArabic: event.arabicAgenda.agenda!.last!,
              departmentOwner: event.departmentOwner.departmentOwner!.last!,
              date: event.eventDate.eventDate!.last!,
              time: event.eventTime.eventTime!.last!,
              type: event.eventType.eventType!.last!,
              flyer: event.flyer.flyerName!.last!,
              isRemote: event.isRemote.isRemote!.last!,
              isOnsite: event.isOnSite.isOnSite!.last!,
              remoteUrl: event.isRemote.isRemote!.last!
                  ? event.eventVenue.venueData!.last!
                  : '',
              onSiteAddress: event.isOnSite.isOnSite!.last!
                  ? event.eventVenue.venueData!.last!.capitalize!
                  : '',
              maximumCapacity: event.maximumCapacity.maximumCapacity!.last!,
              guests: tempGuests,
              reminders: tempReminders,
              sendReminders: event.hasReminder.hasReminder!.last!,
              requiredApproval: event.eventApproval.hasApproval!.last!,
              approvalEmail: tempApprovalEmployee,
              hasSurvey: event.hasSurvey.hasSurvey!.last!,
              surveyId: event.surveyId.id!.last!,
            ));
          }
        }
      }
      approvalEvents.assignAll(temp);
      if (approvalEvents.isEmpty) {
        filterEvents(0);
        employeeSelectedIndex = 0;
      } else {
        filterEvents(employeeSelectedIndex);
      }
      log("fetchApprovals Done Successfully (Employee View)");
    } catch (e) {
      log("Error at fetchApprovals (Employee View): $e");
    }

    update();
  }

  // -----------------------------------------fetch surveys--------------------------------------------------

  Future<void> fetchSurveys() async {
    List<SurveyModel> fetchedSurveys = [];
    try {
      var surveysDocuments =
          await FirebaseFirestore.instance.collection("Surveys").get();

      for (var doc in surveysDocuments.docs) {
        SurveyFirebaseModel surveyFirebase =
            SurveyFirebaseModel.fromMap(data: doc.data(), docId: doc.id);

        EventModel event = eventController.events.firstWhere(
            (event) => event.id == surveyFirebase.assignedEventId.id!.last);

        if (surveyFirebase.status.status?.last != "deleted") {
          List<QuestionModel> questions = [];
          for (var question in surveyFirebase.questions) {
            if (question.status?.last != "deleted") {
              questions.add(
                QuestionModel(
                    isRequired: question.isRequired?.last ?? false,
                    question: question.questionTitle?.last?.capitalize ?? "",
                    hintText: "hint",
                    isMcq: question.questionType?.last == "Short Answer" ||
                            question.questionType?.last == "Long Answer"
                        ? false
                        : true,
                    hasPhoto: false,
                    answer: question.correctAnswer?.last ?? "",
                    choices: question.choices?.last ?? "",
                    questionType: question.questionType?.last ?? "Short Answer",
                    status: question.status!.last!),
              );
            }
          }

          List<QuestionCardAnalyticModel> questionAnalytics = [];
          for (var question in surveyFirebase.questions) {
            questionAnalytics.add(
              QuestionCardAnalyticModel(
                questionName:
                    question.questionTitle?.last?.capitalize ?? "Empty",
                questionType: 1,
                answer: question.questionType?.last == "Short Answer" ||
                        question.questionType?.last == "Long Answer"
                    ? question.correctAnswer?.last ?? ""
                    : null,
                values: question.questionType?.last != "Short Answer" &&
                        question.questionType?.last != "Long Answer"
                    ? question.choices?.last != null
                        ? question.choices!.last!.split(',')
                        : []
                    : null,
              ),
            );
          }

          double max = double.negativeInfinity,
              min = double.infinity,
              avg = 0,
              count = 0;
          if (filledSurveys[surveyFirebase.id] != null) {
            for (var response in filledSurveys[surveyFirebase.id]!.answers) {
              List<String> parts =
                  response.timeTaken.remainingTime!.last!.split(':');

              double hour = double.parse(parts[0]);
              double minutes = double.parse(parts[1]);
              double sec = double.parse(parts[2]);

              max = max > (hour * 60 * 60 + minutes * 60 + sec)
                  ? max
                  : (hour * 60 * 60 + minutes * 60 + sec);
              min = min < (hour * 60 * 60 + minutes * 60 + sec)
                  ? min
                  : (hour * 60 * 60 + minutes * 60 + sec);
              avg += (hour * 60 * 60 + minutes * 60 + sec);
              count++;
            }
          }

          avg = avg / count;
          avg /= 60;
          min /= 60;
          max /= 60;

          String stringMax = max == max.roundToDouble()
              ? max.toString()
              : max.toStringAsFixed(3);

          String stringMin = min == min.roundToDouble()
              ? min.toString()
              : min.toStringAsFixed(3);

          String stringAvg = avg == avg.roundToDouble()
              ? avg.toString()
              : avg.toStringAsFixed(3);

          var survey = SurveyModel(
              showResponse: surveyFirebase.showResponse.showResponse!.last!,
              eventNameArabic: event.eventNameArabic,
              id: surveyFirebase.id!,
              departmentOwner: event.departmentOwner?.capitalize ?? "",
              surveyTitle:
                  surveyFirebase.englishTitle.title?.last?.capitalize ?? "",
              surveyTitleArabic: surveyFirebase.arabicTitle.title?.last ?? "",
              summary: surveyFirebase
                      .englishDescription.description?.last?.capitalize ??
                  "",
              summaryInArabic:
                  surveyFirebase.arabicDescription.description?.last ?? "",
              date: event.date,
              eventName: event.eventNameEnglish.capitalize ?? "",
              isSelected: false,
              type: event.type?.capitalize ?? "",
              surveyPhoto: "assets/images/taskImage.png",
              status: surveyFirebase.status.status?.last ?? "",
              questions: questions,
              questionAnalytics: questionAnalytics,
              partitcipants: event.guests.map((element) {
                EmployeeSubmissionModel temp =
                    filledSurveys[surveyFirebase.id] != null
                        ? filledSurveys[surveyFirebase.id]!.answers.firstWhere(
                            (response) =>
                                response.email.employeeEmail!.last ==
                                element.email,
                            orElse: () => EmployeeSubmissionModel(
                                email: Email(),
                                questionModel: [],
                                status: SubmissionStatus(),
                                timeTaken: TimeTakenModel()))
                        : EmployeeSubmissionModel(
                            email: Email(),
                            questionModel: [],
                            status: SubmissionStatus(),
                            timeTaken: TimeTakenModel());
                return ParticipantModel(
                    email: element.email,
                    name: element.name,
                    nameArabic: element.arabicName,
                    departmentArabic: element.arabicDepartment,
                    department: element.department,
                    jobTitle: element.role,
                    profilePhoto: element.imageUrl,
                    status: temp.questionModel.isEmpty
                        ? "Pending"
                        : (temp.status.status!.last == 'saved'
                            ? "Started"
                            : "Responded"),
                    dateSentResponse: temp.questionModel.isEmpty
                        ? ""
                        : DateFormat('dd MMM yyyy').format(
                            temp.questionModel[0].timestamps!.last!.toDate()));
              }).toList(),
              maxResponseTime: "$stringMax Mins",
              averageTime: "$stringAvg Mins",
              minResponseTime: "$stringMin Mins",
              eventID: surveyFirebase.assignedEventId.id!.last!);
          fetchedSurveys.add(survey);
        }
      }
      surveys.assignAll(fetchedSurveys);

      log("Successfully fetched Surveys");
      update();
    } catch (e) {
      log(e.toString());
    }
  }

  // --------------------------------------------------- GET SURVEY BY EVENT ID --------------------------------------------------------------------

  SurveyModel? getSurvryByEventId(String eventId) {
    SurveyModel? temp;
    for (var survey in surveys) {
      if (survey.eventID == eventId) {
        temp = survey;
        break;
      }
    }
    return temp;
  }

  // -----------------------------------------Update intvitation status--------------------------------------------------

  TextEditingController rejectionReason = TextEditingController();

  Future<void> updateInvitationStatus(String eventId, String status) async {
    Timestamp timestamp = Timestamp.now();
    // change status in employee
    try {
      for (var approvalEvent
          in allApprovalsAndInvitations[fetchedEmployee!.email!.last]!
              .invitedEvents) {
        log("${approvalEvent.eventId!.last} /// $eventId");
        if (approvalEvent.eventId!.last == eventId) {
          log("event found");
          approvalEvent.status!.add(status);
          approvalEvent.timestamps!.add(timestamp);

          if (status == "Rejected") {
            approvalEvent.rejectionReason!.add(rejectionReason.text);
          }
        }
      }

      ApprovalAndInvitedListModel tempApprovalAndInvited =
          ApprovalAndInvitedListModel(
        id: fetchedEmployee!.email!.last,
        approvalEvents:
            allApprovalsAndInvitations[fetchedEmployee!.email!.last]!
                .approvalEvents,
        invitedEvents:
            allApprovalsAndInvitations[fetchedEmployee!.email!.last]!
                .invitedEvents,
      );

      await FirebaseFirestore.instance
          .collection('Approval_And_Invited_Events')
          .doc(tempApprovalAndInvited.id)
          .set(tempApprovalAndInvited.toMap(), SetOptions(merge: true));
      status == "Rejected"
          ? systemLogsController
              .systemLogsAction(SystemActions.rejectInvitation)
          : systemLogsController
              .systemLogsAction(SystemActions.acceptInvitation);
      log("Update approval status (employee) successfully");
    } catch (e) {
      log("Error at update approval status (employee): $e");
    }

    rejectionReason.clear();

    update();
  }

  // -----------------------------------------Update approval status--------------------------------------------------

  Future<void> inviteEmployees(String eventId, Timestamp timestamp) async {
    for (var event in approvalEvents) {
      if (event.id == eventId && event.guests.isNotEmpty) {
        for (var element in event.guests) {
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

            fetchedEmployee.invitedEvents.add(AssignedEvent(
              eventId: [eventId],
              status: ["Pending"],
              rejectionReason: [""],
              timestamps: [timestamp],
            ));

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
  }

  Future<void> updateApprovalStatus(String eventId, String status) async {
    Timestamp timestamp = Timestamp.now();

    // change status in event
    try {
      EventsModel? tempEvent;
      for (var event in fetchedEvents) {
        if (event.id == eventId) {
          tempEvent = event;
        }
      }

      tempEvent!.status.status!.add(status);
      tempEvent.status.timestamps!.add(timestamp);

      await FirebaseFirestore.instance
          .collection('Events')
          .doc(tempEvent.id)
          .set(tempEvent.toMap(), SetOptions(merge: true));

      log("Update approval status (event) successfully");
    } catch (e) {
      log("Error at update approval status (event): $e");
    }

    // change status in employee
    try {
      for (var employeeModel in addEmployeeController.allEmployees!) {
        if (employee!.email!.last ==
            employeeModel.email!.last) {
          log("employee found");
        }
      }

      for (var approvalEvent
          in allApprovalsAndInvitations[fetchedEmployee!.email!.last]!
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

      if (status == "sent") {
        inviteEmployees(eventId, timestamp);
      }

      ApprovalAndInvitedListModel tempApprovalAndInvited =
          ApprovalAndInvitedListModel(
        id: fetchedEmployee!.email!.last,
        approvalEvents:
            allApprovalsAndInvitations[fetchedEmployee!.email!.last]!
                .approvalEvents,
        invitedEvents:
            allApprovalsAndInvitations[fetchedEmployee!.email!.last]!
                .invitedEvents,
      );

      await FirebaseFirestore.instance
          .collection('Approval_And_Invited_Events')
          .doc(tempApprovalAndInvited.id)
          .set(tempApprovalAndInvited.toMap(), SetOptions(merge: true));

      log("Update approval status (employee) successfully");
    } catch (e) {
      log("Error at update approval status (employee): $e");
    }
    rejectionReason.clear();
    update();
  }

  // ------------------------------------------------ upload employee submission ---------------------------------------------------------------------

  List<SurveyQuestion> fillQuestionsList({required SurveyModel surveyModel}) {
    List<SurveyQuestion> questions = [];
    for (int i = 0; i < surveyModel.questions.length; i++) {
      if (employeeSubmissionAnswer[i].text == 'صح') {
        employeeSubmissionAnswer[i].text = 'True';
      } else if (employeeSubmissionAnswer[i].text == 'خطأ') {
        employeeSubmissionAnswer[i].text = 'False';
      }

      questions.add(SurveyQuestion(
        questionTitle: [surveyModel.questions[i].question],
        questionType: [surveyModel.questions[i].questionType],
        isRequired: [surveyModel.questions[i].isRequired],
        answer: [employeeSubmissionAnswer[i].text],
        choices: [surveyModel.questions[i].choices],
        timestamps: [Timestamp.now()],
        correctAnswer: [''],
        isCorrectAnswer: [false],
        status: ["sent"],
      ));
    }

    return questions;
  }

  Future<void> uploadEmployeeSubmission(
      {required String status,
      required SurveyModel surveyModel,
      required String takenTime}) async {
    Timestamp timestamp = Timestamp.now();

    try {
      showLoadingIndicator();
      FilledSurveyModel? filledSurvey = filledSurveys[surveyModel.id];

      if (filledSurvey != null) {
        EmployeeSubmissionModel? employeeSub =
            findEmployeeSubmission(surveyId: surveyModel.id);
        if (employeeSub == null) {
          filledSurvey.answers.add(
            EmployeeSubmissionModel(
              email: Email(
                employeeEmail: [employee!.email!.last],
                timestamps: [timestamp],
              ),
              questionModel: fillQuestionsList(surveyModel: surveyModel),
              status:
                  SubmissionStatus(status: [status], timestamps: [timestamp]),
              timeTaken: TimeTakenModel(
                  remainingTime: [takenTime], timestamps: [timestamp]),
            ),
          );
        } else {
          for (int i = 0; i < employeeSub.questionModel.length; i++) {
            if (employeeSubmissionAnswer[i].text == 'صح') {
              employeeSubmissionAnswer[i].text = 'True';
            } else if (employeeSubmissionAnswer[i].text == 'خطأ') {
              employeeSubmissionAnswer[i].text = 'False';
            }
            if (employeeSub.questionModel[i].answer!.last !=
                employeeSubmissionAnswer[i].text) {
              employeeSub.questionModel[i].answer!
                  .add(employeeSubmissionAnswer[i].text);
              employeeSub.questionModel[i].timestamps!.add(timestamp);
            }
          }

          employeeSub.timeTaken.remainingTime!.add(takenTime);
          employeeSub.timeTaken.timestamps!.add(timestamp);

          employeeSub.status.status!.add(status);
          employeeSub.status.timestamps!.add(timestamp);
        }
      } else {
        filledSurvey = FilledSurveyModel(
          surveyId: surveyModel.id,
          answers: [
            EmployeeSubmissionModel(
              email: Email(
                employeeEmail: [employee!.email!.last],
                timestamps: [timestamp],
              ),
              questionModel: fillQuestionsList(surveyModel: surveyModel),
              status:
                  SubmissionStatus(status: [status], timestamps: [timestamp]),
              timeTaken: TimeTakenModel(
                  remainingTime: [takenTime], timestamps: [timestamp]),
            ),
          ],
        );
      }

      await FirebaseFirestore.instance
          .collection('Filled_Surveys')
          .doc(surveyModel.id)
          .set(filledSurvey.toMap(), SetOptions(merge: true))
          .then((_) async {
        await eventController.fetchEventsFromFirebase();
        await fetchSurveys();
        surveyController.filteredSurveys.assignAll(surveyController.surveys);
        hideLoadingIndicator();
      });
      log("Upload employee submission successfully");
    } catch (e) {
      log("Error at upload employee submission: $e");
    }
  }

  void sendNotificationWhenFilledSurvey(SurveyModel survey) async {
    int index = 0;
    for (int i = 0; i < surveyController.firebaseSurveys.length; i++) {
      if (surveyController.firebaseSurveys[index].id == survey.id) {
        break;
      }
      index++;
    }
    EventModel event = eventController.events.firstWhere((element) =>
        element.id ==
        surveyController.firebaseSurveys[index].assignedEventId.id!.last!);
    await appNotificationController.sendNotification(
        title: survey.surveyTitle,
        arabicTitle: survey.surveyTitleArabic,
        body:
            "${addEmployeeController.getEmployeeNameEnglishArabic(employee!.email!.last!, true)} Filled Survey at Event: ${event.eventNameEnglish}",
        arabicBody:
            " قام ${addEmployeeController.getEmployeeNameEnglishArabic(employee!.email!.last!, false)} بملئي استفتاء في الحدث: ${event.eventNameArabic}",
        type: "survey",
        surveyId: event.surveyId,
        eventId: event.id,
        topic: event.eventCreator);
  }

  Future<void> fetchFilledSurveyModel() async {
    try {
      filledSurveys.clear();
      var filledSurveyCollection =
          await FirebaseFirestore.instance.collection("Filled_Surveys").get();

      for (var doc in filledSurveyCollection.docs) {
        FilledSurveyModel surveyFirebase =
            FilledSurveyModel.fromMap(doc.id, doc.data());

        filledSurveys[surveyFirebase.surveyId!] = surveyFirebase;
      }
    } catch (e) {
      log(" Error at fetchFilledSurveyModel: $e");
    }
  }

  EmployeeSubmissionModel? findEmployeeSubmission({required String surveyId}) {
    if (filledSurveys[surveyId] != null) {
      for (var employeeSub in filledSurveys[surveyId]!.answers) {
        if (employeeSub.email.employeeEmail!.last! ==
            employee!.email!.last) {
          return employeeSub;
        }
      }
    }

    return null;
  }

  bool acceptInvitation({required String eventId}) {
    print('allEmployees ${allEmployees.length}');

    for (var employees in allEmployees) {
      if (employees.email == employee!.email!.last) {
        if (employees.invitedEvents[eventId] == "Accepted") {
          print("true111");
          return true;
        }
      }
    }
    print("false111");
    return false;
  }
  // -------------------------get Status of employee submission ------------------------------------------------------------------------------

  String getEmployeeSubmissionStatus({required SurveyModel surveyModel}) {
    for (var participant in surveyModel.partitcipants) {
      if (participant.email == employee!.email!.last) {
        return participant.status!;
      }
    }
    return '';
  }

  // ------------------------------------------------------------------------------------------------------------------------------------------------------------

  List<String> departmentOwnerItems = ['Marketing', 'Media'];
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
    log("upper filter : $value");
    employeeSelectedIndex = value;
    filterEvents(employeeSelectedIndex);
    update();
  }

  void resetFilter() {
    departmetFilter = null;
    dateFilter = '';
    typeFilter = null;
    statusFilter = null;
    filterEvents(employeeSelectedIndex);
    update();
    Get.back();
  }

  void onSearchTextChanged(String value) {
    searchText = value;
    searchforEvent();
    update();
  }

  void filterDateValueState(String value) {
    dateFilter = value;
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

  void filterStatusValueState(String? value) {
    statusFilter = value;
    update();
  }

  bool isDateAndTimeNotPassed(EventModel element) {
    DateFormat dateFormat = DateFormat('dd MMM yyyy HH:mm');
    try {
      String dueDateTimeString = "${element.date} ${element.time}";
      DateTime dueDateTime = dateFormat.parse(dueDateTimeString);
      DateTime now = DateTime.now();
      return dueDateTime.isAfter(now);
    } catch (e) {
      log('Error parsing date or time: $e');
      return false;
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
      log('Error parsing date or time: $e');
      return false;
    }
  }

  void filterEvents(int employeeSelectedIndex) {
    switch (employeeSelectedIndex) {
      case 0:
        filteredevents.assignAll(inviteAtEvents.where((element) {
          return (isDateAndTimeNotPassed(element));
        }).toList());
        break;
      case 1:
        filteredevents.assignAll(inviteAtEvents.where((element) {
          return isDateAndTimePassed(element);
        }).toList());
        break;
      case 2:
        filteredevents.assignAll(approvalEvents);
        break;
      default:
        filteredevents.assignAll(inviteAtEvents);
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
      filterEvents(employeeSelectedIndex);
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
    if (statusFilter != null) {
      filteredevents.assignAll(filteredevents.where((event) {
        if (event.status == "Accepted") {
          return statusFilter == "Accepted";
        } else if (event.status == "Rejected") {
          return statusFilter == "Rejected";
        } else {
          // pending
          return statusFilter == "No Response";
        }
      }).toList());
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
              return event1.eventNameArabic
                  .toLowerCase()
                  .compareTo(event2.eventNameArabic.toLowerCase());
            },
          );
    update();
  }

  void sortApprovalEvents() {
    storeApprovalOrder();
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
              return event1.eventNameArabic
                  .toLowerCase()
                  .compareTo(event2.eventNameArabic.toLowerCase());
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

  void sortApprovalEventsByDate() {
    storeApprovalOrder();
    filteredevents.sort((event1, event2) {
      DateTime date1 = DateFormat('dd MMM yyyy').parse(event1.date);
      DateTime date2 = DateFormat('dd MMM yyyy').parse(event2.date);
      return date2.compareTo(date1);
    });
    update();
  }

  List<EventModel> originalEvents = [];
  List<EventModel> originalapprovalEvents = [];

  void storeOriginalOrder() {
    originalEvents = List.from(filteredevents);
  }

  void storeApprovalOrder() {
    originalapprovalEvents = List.from(approvalEvents);
  }

  void resetSorting() {
    filteredevents = List.from(originalEvents);
    update();
  }
}
