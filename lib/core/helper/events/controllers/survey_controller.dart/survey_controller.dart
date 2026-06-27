import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/constants/system_actions.dart';
import 'package:demo_app/features/notification/notification_controller.dart';
import 'package:demo_app/core/helper/events/components/survey_components/question_card.dart';
import 'package:demo_app/core/helper/events/controllers/employee_controller.dart';
import 'package:demo_app/core/helper/events/controllers/events_controllers/event_controller.dart';
import 'package:demo_app/features/home/helper/events/controllers/events_controllers/model/event_model.dart';
import 'package:demo_app/core/helper/events/controllers/survey_controller.dart/model/participants_model.dart';
import 'package:demo_app/core/helper/events/controllers/survey_controller.dart/model/question_card_analytic_model.dart';
import 'package:demo_app/core/helper/events/controllers/survey_controller.dart/model/question_model.dart';
import 'package:demo_app/core/helper/events/controllers/survey_controller.dart/model/survey_model.dart';
import 'package:demo_app/core/helper/events/models/events_models/event_model.dart';
import 'package:demo_app/core/helper/events/models/more_models/email_model.dart';
import 'package:demo_app/core/helper/events/models/more_models/employee_submission_model.dart';
import 'package:demo_app/core/helper/events/models/more_models/filled_surveys_model.dart';
import 'package:demo_app/core/helper/events/models/more_models/remaining_time_model.dart';
import 'package:demo_app/core/helper/events/models/more_models/submission_status_model.dart';
import 'package:demo_app/core/helper/events/models/survey_models/assigned_event_id_model.dart';
import 'package:demo_app/core/helper/events/models/survey_models/show_responses_model.dart';
import 'package:demo_app/core/helper/events/models/survey_models/survey_description_model.dart';
import 'package:demo_app/core/helper/events/models/survey_models/survey_firebase_model.dart';
import 'package:demo_app/core/helper/events/models/survey_models/survey_question_model.dart';
import 'package:demo_app/core/helper/events/models/survey_models/survey_status_model.dart';
import 'package:demo_app/core/helper/events/models/survey_models/survey_title_model.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';
import 'package:demo_app/features/onboarding/welcome_screen/views/mobile_view/nav_bar.dart';

class SurveyController extends GetxController {
  var surveys = <SurveyModel>[];
  List<QuestionCard> surveyCards = [];
  FirebaseFirestore db = FirebaseFirestore.instance;
  int showSurveyselectedIndex = 0;
  bool showResponseresponseSwitch = false;
  List<SurveyFirebaseModel> firebaseSurveys = [];
  var filteredSurveys = <SurveyModel>[];
  Map<String, FilledSurveyModel> filledSurveys = {};

  EventController eventController = Get.put(EventController());

  List<TextEditingController> questionEditControllers = [];
  List<TextEditingController> paragraphEditControllers = [];
  //List<List<TextEditingController>> _choicesControllers = [];
  List<List<TextEditingController>> mcqEditControllers = [];
  AppNotificationController appNotificationController =
      Get.put(AppNotificationController());
  void initializeEditControllers(SurveyModel? survey) {
    questionEditControllers = survey!.questions.map((q) {
      return TextEditingController(text: q.question);
    }).toList();

    paragraphEditControllers = survey.questions.map((a) {
      return TextEditingController(text: a.answer);
    }).toList();
    // Initialize controllers for multiple choice questions
    mcqEditControllers = survey.questions.map((q) {
      List<TextEditingController> temp = [];
      String choice = "";
      for (int i = 0; i < q.choices.length; i++) {
        if (q.choices[i] == ',') {
          temp.add(TextEditingController(text: choice));
          choice = "";
        } else {
          choice += q.choices[i];
        }
      }
      return temp;
    }).toList();
  }

  @override
  void onInit() async {
    await eventController.fetchEventsFromFirebase().then(
      (value) async {
        await fetchFilledSurveyModel().then((value) async {
          await fetchSurveys().then((value) async {
            surveyCards.add(_buildSurveyCard());
            filteredSurveys.assignAll(surveys);
          });
        });
      },
    );

    super.onInit();
  }

  void deleteSurvey(SurveyModel survey) async {
    log("delete survey");
    EventsEmployeeController employeeController = Get.put(EventsEmployeeController());

    await employeeController.fetchEmployees();
    await employeeController.fetchEventsFromFirebase();
    await employeeController.fetchSurveys();
    update();
  }

  QuestionCard _buildSurveyCard() {
    return QuestionCard(
      isRequired: true,
      questionType: "Short Answer",
      shortAnswerController: TextEditingController(),
      paragaraphAnswerController: TextEditingController(),
      questionController: TextEditingController(),
      pointsController: TextEditingController(),
      dropDownControllers: [TextEditingController()],
      mcqControllers: [TextEditingController()],
      selectedImagePath: null,
      imagePaths: const [],
      switchValue: false, // Example switch value
      onQuestionChanged: (value) {
        // Handle question change
      },
      onSwitchChanged: (value) {
        // Handle switch value change
      },
      onDuplicate: () {
        // Handle duplicate action
      },
      onDelete: () {
        // Handle delete action
      },
      onCorrectAnswerSelected: "",
      controllerState: (value) {
        // Handle controller state changes
      },
    );
  }

  void addSurveyCard() {
    surveyCards.add(_buildSurveyCard());
    update();
  }

  Future<void> onSent(String status, String eventID) async {
    String surveyID = DateTime.now().toString();
    try {
      showLoadingIndicator();
      SurveyFirebaseModel surveyModel = SurveyFirebaseModel(
          showResponse:
              ShowResponses(showResponse: [false], timestamps: [timestamp]),
          englishTitle: SurveyTitle(
              title: [newSurveyTitle.text], timestamps: [timestamp]),
          arabicTitle: SurveyTitle(
              title: [newSurveyTitleArabic.text], timestamps: [timestamp]),
          arabicDescription: SurveyDescription(
              description: [newSurveyArabic.text], timestamps: [timestamp]),
          englishDescription: SurveyDescription(
              description: [newSurveySummary.text], timestamps: [timestamp]),
          questions: surveyCards
              .map((event) => SurveyQuestion(
                  questionTitle: [event.questionController.text],
                  questionType: [event.questionType!.toLowerCase()],
                  correctAnswer: event.questionType == "Short Answer"
                      ? [event.shortAnswerController!.text.trim()]
                      : (event.questionType == "Long Answer"
                          ? [event.paragaraphAnswerController!.text.trim()]
                          : [
                              event.onCorrectAnswerSelected.trim()
                            ]), // -------------------------------------------------------------------
                  choices: event.questionType == "Multiple Choice"
                      ? [getChoices(event.mcqControllers)]
                      : (event.questionType == "Drop Menu"
                          ? [getChoices(event.dropDownControllers)]
                          : (event.questionType == "True Or False"
                              ? ["True,False,"]
                              : [null])),
                  status: ["sent"],
                  answer: [null],
                  isCorrectAnswer: [null],
                  timestamps: [timestamp],
                  isRequired: [event.isRequired]))
              .toList(),
          status: SurveyStatus(
            status: [status],
            timestamps: [timestamp],
          ),
          assignedEventId: AssignedId(
            id: [eventID],
            timestamps: [timestamp],
          ));

      var collRef = db.collection("Surveys");
      await collRef.doc(surveyID).set(surveyModel.toMap());

      await eventController.updateSurveyIdInEvent(
          eventId: eventID, timestamp: timestamp, surveyId: surveyID);
      EventModel event =
          eventController.events.firstWhere((element) => element.id == eventID);
      List<String> topics = event.guests
          .where((element) => element.invitedEvents[event.id] == 'Accepted')
          .map((element) => element.email)
          .toList();

      appNotificationController.sendNotificationToMultiple(
          title: "Survey invitation",
          arabicTitle: "تقديم استفتاء",
          body:
              "${addEmployeeController.getEmployeeNameEnglishArabic(employee!.email.last!, true)} Make Survey at Event: ${event.eventNameEnglish}",
          arabicBody:
              "قام ${addEmployeeController.getEmployeeNameEnglishArabic(employee!.email.last!, false)} بتقديم استفتاء للحدث: ${event.eventNameArabic}",
          type: "survey",
          surveyId: surveyID,
          eventId: eventID,
          topics: topics);

      await fetchSurveys();
      filteredSurveys.assignAll(surveys);
      departmetFilter = null;
      dateFilter = '';
      typeFilter = null;
      statusFilter = null;
      await eventController.fetchEventsFromFirebase();
      hideLoadingIndicator();
      update();
    } catch (e) {
      log("Error At Creating Survey : $e");
    }
  }

  // here where you send the data
  TextEditingController newSurveyTitle = TextEditingController();
  TextEditingController newSurveyTitleArabic = TextEditingController();
  TextEditingController newSurveySummary = TextEditingController();
  TextEditingController newSurveyArabic = TextEditingController();
  Timestamp timestamp = Timestamp.now();

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

  Future<void> fetchSurveys() async {
    List<SurveyModel> fetchedSurveys = [];
    firebaseSurveys.clear();
    try {
      var surveysDocuments = await db.collection("Surveys").get();

      for (var doc in surveysDocuments.docs) {
        SurveyFirebaseModel surveyFirebase =
            SurveyFirebaseModel.fromMap(data: doc.data(), docId: doc.id);
        firebaseSurveys.add(surveyFirebase);
        EventModel event = eventController.events.firstWhere(
            (event) => event.id == surveyFirebase.assignedEventId.id!.last);
        if (surveyFirebase.status.status?.last != "deleted") {
          List<QuestionModel> questions = [];
          for (var question in surveyFirebase.questions) {
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

          if (count != 0) avg = avg / count;
          if (min == double.infinity) min = 0;
          if (max == double.negativeInfinity) max = 0;
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
              surveyPhoto: event.eventPhoto,
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
              maxResponseTime: "$stringMax ${"Mins".tr}",
              averageTime: "$stringAvg ${"Mins".tr}",
              minResponseTime: "$stringMin ${"Mins".tr}",
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

  String getChoices(List<TextEditingController> x) {
    String returnValue = "";
    for (var choice in x) {
      returnValue += "${choice.text},";
    }
    return returnValue;
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

  // --------------------------------------------------- Update Survey --------------------------------------------------------------------

  Future<void> updateSurvey(
      {required String status, required SurveyModel survey}) async {
    try {
      showLoadingIndicator();
      bool change = false;
      int index = 0;
      for (int i = 0; i < firebaseSurveys.length; i++) {
        if (firebaseSurveys[index].id == survey.id) {
          if (status == "deleted") {
            firebaseSurveys[index].status.status?.add(status);
            firebaseSurveys[index].status.timestamps?.add(timestamp);
          } else {
            change = updateValuesOfSurvey(
                index: index, survey: survey, status: status);
          }
          break;
        }
        index++;
      }

      final CollectionReference exam = db.collection('/Surveys');
      await exam
          .doc(firebaseSurveys[index].id)
          .set(firebaseSurveys[index].toMap(), SetOptions(merge: true))
          .then((_) async {
        if (status == "deleted") {
          await deleteHasSurveyAtEvent(index: index);
          sendNotificationWhenUpdateOrDeletedSurvey(index, survey, true);
        } else {
          if (change) {
            sendNotificationWhenUpdateOrDeletedSurvey(index, survey, false);
          }
        }

        await eventController.fetchEventsFromFirebase();
        await fetchSurveys();
        filteredSurveys.assignAll(surveys);
        departmetFilter = null;
        dateFilter = '';
        typeFilter = null;
        statusFilter = null;
        filteredSurveys.assignAll(surveys);

        hideLoadingIndicator();
        systemLogsController.systemLogsAction(SystemActions.updateSurvey);
      });

      // DocumentReference documentReference = FirebaseFirestore.instance
      //     .collection("Surveys")
      //     .doc(firebaseSurveys[index].id);

      // await documentReference.update(firebaseSurveys[index].toMap());
      // hideLoadingIndicator();
      log("---------------Successfully edit data---------------");

      update();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> deleteHasSurveyAtEvent({
    required int index,
  }) async {
    EventsModel eventModel = eventController.fetchedEvents.firstWhere(
        (element) =>
            element.id == firebaseSurveys[index].assignedEventId.id!.last!);
    eventModel.hasSurvey.hasSurvey?.add(false);
    eventModel.hasSurvey.timestamps?.add(timestamp);
    eventModel.surveyId.id?.add("");
    eventModel.surveyId.timestamps?.add(timestamp);
    final CollectionReference event = db.collection('/Events');
    await event
        .doc(eventModel.id)
        .set(eventModel.toMap(), SetOptions(merge: true));
    systemLogsController.systemLogsAction(SystemActions.deleteSurvey);
  }

  void sendNotificationWhenUpdateOrDeletedSurvey(
      int index, SurveyModel survey, bool isDeleted) {
    EventModel event = eventController.events.firstWhere((element) =>
        element.id == firebaseSurveys[index].assignedEventId.id!.last!);
    List<String> topics = event.guests
        .where((element) => element.invitedEvents[event.id] == 'Accepted')
        .map((element) => element.email)
        .toList();

    appNotificationController.sendNotificationToMultiple(
        title: survey.surveyTitle,
        arabicTitle: survey.surveyTitleArabic,
        body: isDeleted
            ? "${addEmployeeController.getEmployeeNameEnglishArabic(employee!.email.last!, true)} Delete Survey at Event: ${event.eventNameEnglish}"
            : "${addEmployeeController.getEmployeeNameEnglishArabic(employee!.email.last!, true)} Edit Survey at Event: ${event.eventNameEnglish}",
        arabicBody: isDeleted
            ? "قام ${addEmployeeController.getEmployeeNameEnglishArabic(employee!.email.last!, false)} بحذف الاستفتاء في الحدث: ${event.eventNameEnglish}"
            : "قام ${addEmployeeController.getEmployeeNameEnglishArabic(employee!.email.last!, false)} بتعديل الاستفتاء في الحدث: ${event.eventNameEnglish}",
        eventId: event.id,
        surveyId: survey.id,
        type: "survey",
        topics: topics);
  }

  bool updateValuesOfSurvey(
      {required int index,
      required String status,
      required SurveyModel survey}) {
    Timestamp timestamp = Timestamp.now();
    bool changeState = false;
    if (firebaseSurveys[index].arabicDescription.description?.last !=
        survey.summaryInArabic) {
      firebaseSurveys[index]
          .arabicDescription
          .description
          ?.add(survey.summaryInArabic);
      firebaseSurveys[index].arabicDescription.timestamps?.add(timestamp);
      changeState = true;
    }
    if (firebaseSurveys[index].arabicTitle.title?.last !=
        survey.surveyTitleArabic) {
      firebaseSurveys[index].arabicTitle.title?.add(survey.surveyTitleArabic);
      firebaseSurveys[index].arabicTitle.timestamps?.add(timestamp);
      changeState = true;
    }

    if (firebaseSurveys[index].englishTitle.title?.last != survey.surveyTitle) {
      firebaseSurveys[index].englishTitle.title?.add(survey.surveyTitle);
      firebaseSurveys[index].englishTitle.timestamps?.add(timestamp);
      changeState = true;
    }

    if (firebaseSurveys[index].englishDescription.description?.last !=
        survey.summary) {
      firebaseSurveys[index]
          .englishDescription
          .description
          ?.add(survey.summary);
      firebaseSurveys[index].englishDescription.timestamps?.add(timestamp);
      changeState = true;
    }

    if (firebaseSurveys[index].status.status?.last != status) {
      firebaseSurveys[index].status.status?.add(status);
      firebaseSurveys[index].status.timestamps?.add(timestamp);
      changeState = true;
    }
    bool changed = false;
    for (int i = 0; i < survey.questions.length; i++) {
      survey.questions[i].question = questionEditControllers[i].text;
      survey.questions[i].answer = paragraphEditControllers[i].text;
      survey.questions[i].choices = getChoices(mcqEditControllers[i]);
      if (i >= firebaseSurveys[index].questions.length) {
        firebaseSurveys[index].questions.add(SurveyQuestion(
              answer: [null],
              choices: [survey.questions[i].choices],
              correctAnswer: [survey.questions[i].answer],
              isCorrectAnswer: [null],
              isRequired: [survey.questions[i].isRequired],
              questionTitle: [survey.questions[i].question],
              questionType: [survey.questions[i].questionType],
              status: [survey.status],
              timestamps: [timestamp],
            ));
        changeState = true;
      } else {
        // String checkAnswer =
        //     survey.questions[i].questionType == "Short Answer" ||
        //             survey.questions[i].questionType == "Long Answer"
        //         ? paragraphEditControllers[i].text
        //         : survey.questions[i].answer;

        if (firebaseSurveys[index].questions[i].correctAnswer!.last !=
            survey.questions[i].answer) {
          firebaseSurveys[index]
              .questions[i]
              .correctAnswer!
              .add(survey.questions[i].answer);
          changed = true;
        }
        log("checkAnswer: ${survey.questions[i].answer}");

        if (firebaseSurveys[index]
                .questions[i]
                .questionTitle!
                .last!
                .toLowerCase() !=
            survey.questions[i].question.toLowerCase()) {
          firebaseSurveys[index]
              .questions[i]
              .questionTitle!
              .add(survey.questions[i].question.toLowerCase());
          changed = true;
        }

        if (firebaseSurveys[index].questions[i].questionType!.last !=
            survey.questions[i].questionType) {
          firebaseSurveys[index]
              .questions[i]
              .questionType!
              .add(survey.questions[i].questionType);
          changed = true;
        }

        if (firebaseSurveys[index].questions[i].status!.last !=
            survey.questions[i].status) {
          firebaseSurveys[index]
              .questions[i]
              .status!
              .add(survey.questions[i].status);
          changed = true;
        }

        if (firebaseSurveys[index].questions[i].isRequired!.last !=
            survey.questions[i].isRequired) {
          firebaseSurveys[index]
              .questions[i]
              .isRequired!
              .add(survey.questions[i].isRequired);
          changed = true;
        }

        String Choise = getChoices(mcqEditControllers[i]);
        log("Choise: $Choise");
        if (firebaseSurveys[index].questions[i].choices!.last != Choise) {
          firebaseSurveys[index].questions[i].choices!.add(Choise);
          changed = true;
        }

        if (changed) {
          firebaseSurveys[index].questions[i].timestamps!.add(timestamp);
        }
      }
    }

    // if (survey.questions.length < firebaseSurveys[index].questions.length) {
    //   for (int i = survey.questions.length;
    //       i < firebaseSurveys[index].questions.length;
    //       i++) {
    //     if (firebaseSurveys[index].questions[i].status!.last != "deleted") {
    //       firebaseSurveys[index].questions[i].status!.add("deleted");
    //       firebaseSurveys[index].questions[i].timestamps!.add(Timestamp.now());
    //     }
    //   }
    // }
    return (changeState == true || changed == true) ? true : false;
  }

  // ---------------------------------- deleteQuestion && duplicateQuestion --------------------------------------------

  void deleteQuestion(int index) {
    surveyCards.removeAt(index);
    update();
  }

  void duplicateQuestion(int index) {
    TextEditingController questionController;
    TextEditingController pointsController;
    TextEditingController? shortAnswerController;
    TextEditingController? paragaraphAnswerController;
    List<TextEditingController> dropDownControllers;
    List<TextEditingController> mcqControllers;
    String? questionType;
    bool switchValue;
    bool isrequired;
    void Function(String?)? onQuestionChanged;
    ValueChanged<bool> onSwitchChanged;
    VoidCallback onDuplicate;
    VoidCallback onDelete;
    String onCorrectAnswerSelected;
    void Function(String)? controllerState;

    questionController =
        TextEditingController(text: surveyCards[index].questionController.text);

    shortAnswerController = TextEditingController(
        text: surveyCards[index].shortAnswerController!.text);
    paragaraphAnswerController = TextEditingController(
        text: surveyCards[index].paragaraphAnswerController!.text);
    dropDownControllers = surveyCards[index].dropDownControllers.map((element) {
      return TextEditingController(text: element.text);
    }).toList();
    mcqControllers = surveyCards[index].mcqControllers.map((element) {
      return TextEditingController(text: element.text);
    }).toList();

    questionType = surveyCards[index].questionType;
    switchValue = surveyCards[index].switchValue;
    isrequired = surveyCards[index].isRequired;
    pointsController =
        TextEditingController(text: surveyCards[index].pointsController.text);

    onQuestionChanged = surveyCards[index].onQuestionChanged;
    onSwitchChanged = surveyCards[index].onSwitchChanged;
    onDuplicate = surveyCards[index].onDuplicate;
    onDelete = surveyCards[index].onDelete;
    onCorrectAnswerSelected = surveyCards[index].onCorrectAnswerSelected;
    controllerState = surveyCards[index].controllerState;

    QuestionCard temp = QuestionCard(
      isRequired: isrequired,
      questionType: questionType,
      shortAnswerController: shortAnswerController,
      paragaraphAnswerController: paragaraphAnswerController,
      questionController: questionController,
      pointsController: pointsController,
      dropDownControllers: dropDownControllers,
      mcqControllers: mcqControllers,
      selectedImagePath: null,
      imagePaths: const [],
      switchValue: switchValue, // Example switch value
      onQuestionChanged: onQuestionChanged,
      onSwitchChanged: onSwitchChanged,
      onDuplicate: onDuplicate,
      onDelete: onDelete,
      onCorrectAnswerSelected: onCorrectAnswerSelected,
      controllerState: controllerState,
    );
    surveyCards.insert(index + 1, temp);
    update();
  }

  void duplicateSurveyQuestion(
      {required List<QuestionModel> questions, required int index}) {
    QuestionModel temp = QuestionModel(
      status: questions[index].status,
      answer: questions[index].answer,
      choices: questions[index].choices,
      hintText: questions[index].hintText,
      isMcq: questions[index].isMcq,
      isRequired: questions[index].isRequired,
      question: questions[index].question,
      questionType: questions[index].questionType,
      hasPhoto: questions[index].hasPhoto,
    );

    List<String> choicesList = [];
    for (var element in mcqEditControllers[index]) {
      choicesList.add(element.text);
    }

    mcqEditControllers.insert(index + 1, [
      ...choicesList.map((e) => TextEditingController(text: e)),
    ]);

    questionEditControllers.insert(index + 1,
        TextEditingController(text: questionEditControllers[index].text));

    paragraphEditControllers.insert(index + 1,
        TextEditingController(text: paragraphEditControllers[index].text));

    questions.insert(index + 1, temp);
    update();
  }

  // -----------------------------------------create survey from existing one----------------------------------------------------

  List<SurveyQuestion> appendQuestions(
      SurveyModel survey, Timestamp timestamp) {
    List<SurveyQuestion> surveyQuestions = [];
    for (int i = 0; i < questionEditControllers.length; i++) {
      if (survey.questions[i].questionType == "Short Answer" ||
          survey.questions[i].questionType == "Long Answer") {
        if (survey.questions[i].status != "deleted") {
          surveyQuestions.add(SurveyQuestion(
            answer: [null],
            choices: [null],
            correctAnswer: [paragraphEditControllers[i].text],
            isCorrectAnswer: [null],
            isRequired: [survey.questions[i].isRequired],
            questionTitle: [questionEditControllers[i].text],
            questionType: [survey.questions[i].questionType],
            status: ["sent"],
            timestamps: [timestamp],
          ));
        }
      } else {
        if (survey.questions[i].status != "deleted") {
          surveyQuestions.add(SurveyQuestion(
            answer: [null],
            choices: [getChoices(mcqEditControllers[i])],
            correctAnswer: [survey.questions[i].answer],
            isCorrectAnswer: [null],
            isRequired: [survey.questions[i].isRequired],
            questionTitle: [questionEditControllers[i].text],
            questionType: [survey.questions[i].questionType],
            status: ["sent"],
            timestamps: [timestamp],
          ));
        }
      }
    }
    return surveyQuestions;
  }

  Future<void> createSurveyFromExistingOne(
      String status, SurveyModel survey, String eventID) async {
    String surveyID = DateTime.now().toString();

    try {
      showLoadingIndicator();
      Timestamp timestamp = Timestamp.now();
      SurveyFirebaseModel surveyModel = SurveyFirebaseModel(
          showResponse: ShowResponses(
              showResponse: [survey.showResponse], timestamps: [timestamp]),
          englishTitle:
              SurveyTitle(title: [survey.surveyTitle], timestamps: [timestamp]),
          arabicTitle: SurveyTitle(
              title: [survey.surveyTitleArabic], timestamps: [timestamp]),
          arabicDescription: SurveyDescription(
              description: [survey.summary], timestamps: [timestamp]),
          englishDescription: SurveyDescription(
              description: [survey.summaryInArabic], timestamps: [timestamp]),
          questions: appendQuestions(survey, timestamp),
          status: SurveyStatus(
            status: [status],
            timestamps: [timestamp],
          ),
          assignedEventId: AssignedId(
            id: [eventID],
            timestamps: [timestamp],
          ));
      var collRef = db.collection("Surveys");
      await collRef.doc(surveyID).set(surveyModel.toMap());
      await eventController.updateSurveyIdInEvent(
          eventId: eventID, timestamp: timestamp, surveyId: surveyID);
      await fetchSurveys();
      await eventController.fetchEventsFromFirebase();
      hideLoadingIndicator();
      systemLogsController.systemLogsAction(SystemActions.createSurvey);
      update();
    } catch (e) {
      log("Error At Creating Survey : $e");
    }
  }

  // -------------------------------------------------get filled survey and employee's submission-------------------------------------------------

  List<EmployeeSubmissionModel> getFilledSurvey(String surveyId) {
    if (filledSurveys[surveyId] == null) return [];
    return filledSurveys[surveyId]!.answers;
  }

  EmployeeSubmissionModel? getEmployeeSubmission(
      String surveyId, String employeeEmail) {
    for (var element in filledSurveys[surveyId]!.answers) {
      if (element.email.employeeEmail!.last == employee!.email.last!) {
        return element;
      }
    }
    return null;
  }

  // ------------------------------------------------filter and search choose Existing-------------------------------------------------
  String? departmetFilterExisting;
  String dateFilterExisting = '';
  List<String> typesFilterExisting = ['Workshop', 'Cermony', 'Announcement'];
  String? typeFilterExisting;
  void filterDateValueExisitingState(String value) {
    dateFilterExisting = value;
    update();
  }

  void filterDepartmentValueExisitingState(String? value) {
    departmetFilterExisting = value;
    update();
  }

  void filterTypeValueExistingState(String? value) {
    typeFilterExisting = value;
    update();
  }

  void resetFilterExisting() {
    departmetFilterExisting = null;
    dateFilterExisting = '';
    typeFilterExisting = null;
    update();
    Get.back();
  }
  // ------------------------------------------------filter and search -------------------------------------------------

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
  List<String> departmentOwnerItems = ['Marketing', 'Media'];

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

  void resetFilter() {
    departmetFilter = null;
    dateFilter = '';
    typeFilter = null;
    statusFilter = null;
    filteredSurveys.assignAll(surveys);
    eventController.update();
    update();
    Get.back();
  }

  void showSurveyState(int value) {
    showSurveyselectedIndex = value;

    update();
  }

  void showSResponseState(bool value) async {
    showResponseresponseSwitch = value;
    changeShowResponseValueInFirebase(value);
    update();
  }

  String passedSurveyId = "";
  Future<void> changeShowResponseValueInFirebase(bool value) async {
    EventsEmployeeController employeeController = Get.put(EventsEmployeeController());

    for (var survey in firebaseSurveys) {
      log("survey id : ${survey.id} , passed survey id : $passedSurveyId");
      if (survey.id == passedSurveyId) {
        if (survey.showResponse.showResponse!.last != value) {
          survey.showResponse.showResponse!.add(value);
          survey.showResponse.timestamps!.add(Timestamp.now());

          var collRef = db.collection("Surveys");
          await collRef.doc(survey.id).set(survey.toMap());
        }
        break;
      }
    }
    await eventController.fetchEventsFromFirebase();
    await fetchSurveys();
    filteredSurveys.assignAll(surveys);
    await employeeController.fetchEmployees();
    await employeeController.fetchEventsFromFirebase();
    await employeeController.fetchSurveys();
    update();
  }

  String? searchText;
  void onSearchTextChanged(String value) {
    searchText = value;
    searchforSurvey();
    update();
  }

  void searchforSurvey() {
    if (searchText != "" && searchText != null) {
      Get.locale.toString().contains('en')
          ? filteredSurveys.assignAll(filteredSurveys
              .where((event) => event.surveyTitle
                  .toLowerCase()
                  .contains(searchText!.toLowerCase()))
              .toList())
          : filteredSurveys.assignAll(filteredSurveys
              .where((event) => event.surveyTitleArabic
                  .toLowerCase()
                  .contains(searchText!.toLowerCase()))
              .toList());
    } else {
      filteredSurveys.assignAll(surveys);
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

      List<SurveyModel> temp = [];
      for (int i = 0; i < filteredSurveys.length; i++) {
        String x = filteredSurveys[i].date;
        DateTime y = dateFormat.parse(x);

        if (y.isAtSameMomentAs(start) ||
            y.isAtSameMomentAs(end) ||
            (y.isAfter(start) && y.isBefore(end))) {
          temp.add(filteredSurveys[i]);
        }
      }
      filteredSurveys.assignAll(temp);
    }
    if (typeFilter != null) {
      filteredSurveys.assignAll(
          filteredSurveys.where((event) => event.type == typeFilter).toList());
    }
    if (departmetFilter != null) {
      filteredSurveys.assignAll(filteredSurveys
          .where((event) => event.departmentOwner == departmetFilter)
          .toList());
    }

    update();
  }

  //----------------------------participants filter---------------------------
  List<ParticipantModel> filterListParticipant = [];
  void changeListFilter(int index, SurveyModel? survey) {
    switch (index) {
      case 0:
        filterListParticipant.assignAll(survey!.partitcipants);
        break;
      case 1:
        filterListParticipant.assignAll(survey!.partitcipants
            .where((participant) => participant.status == "Responded")
            .toList());
        break;
      case 2:
        filterListParticipant.assignAll(survey!.partitcipants
            .where((participant) => participant.status == "Started")
            .toList());
        break;
      case 3:
        filterListParticipant.assignAll(survey!.partitcipants
            .where((participant) => participant.status == "Pending")
            .toList());
        break;
    }
  }

  void searchParticipants(String searchText, SurveyModel? survey) {
    filterListParticipant.assignAll(survey!.partitcipants
        .where((participant) =>
            participant.name.toLowerCase().contains(searchText))
        .toList());
  }

  void sortSurveysByTitle() {
    storeOriginalOrder();
    Get.locale.toString().contains('en')
        ? filteredSurveys.sort(
            (survey1, survey2) {
              return survey1.surveyTitle
                  .toLowerCase()
                  .compareTo(survey2.surveyTitle.toLowerCase());
            },
          )
        : filteredSurveys.sort(
            (survey1, survey2) {
              return survey1.surveyTitleArabic
                  .toLowerCase()
                  .compareTo(survey2.surveyTitleArabic.toLowerCase());
            },
          );
    update();
  }

  void sortSurveysByDate() {
    storeOriginalOrder();
    filteredSurveys.sort((survey1, survey2) {
      DateTime date1 = DateFormat('dd MMM yyyy').parse(survey1.date);
      DateTime date2 = DateFormat('dd MMM yyyy').parse(survey2.date);
      return date2.compareTo(date1);
    });
    update();
  }

  List<SurveyModel> originalSurveys = [];

  void storeOriginalOrder() {
    originalSurveys = List.from(originalSurveys);
  }

  // ----------------------------------------------------------------------------------------------------------------------------------
}

/*
    [
      SurveyModel(
          summary: "smacmsammsamcsamcmsa,cmsacs,acmsacmsa",
          summaryInArabic: "ستؤمتشؤىسشتىؤتيشىؤتىيشنتؤىستنىؤتسىنؤتىنتسىشتؤنىش",
          surveyTitleArabic: "أيفينت ميديا",
          departmentOwner: "Marketing",
          date: "28 Dec 2024",
          eventName: "Media Event",
          status: "Published",
          surveyPhoto: "assets/images/taskImage.png",
          surveyTitle: "Media Event Survey",
          isSelected: false,
          partitcipants: [
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
          ],
          questions: [
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Short Answer",
                isMcq: false,
                hasPhoto: false,
                answer: "Loarum ipsum ....",
                choices: "A,b,c,d",
                questionType: "Short Answer"),
            QuestionModel(
              isRequired: true,
              question: "Loarum ipsum ....?",
              hintText: "Long Answer",
              isMcq: false,
              hasPhoto: false,
              answer: "sssss",
              choices: "s,s,s",
              questionType: "Long Answer",
            ),
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Multiple Choice",
                isMcq: true,
                hasPhoto: false,
                answer: "A",
                questionType: "Multiple Choice",
                choices: "A,b,c,d"),
          ],
          questionAnalytics: [
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 1,
              answer: "It was excellent!",
            ),
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 1,
              answer: "It was excellent!",
            ),
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 1,
              answer: "It was excellent!",
            ),
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 2,
              values: ['50', '30', '15', '5'],
            ),
            QuestionCardAnalyticModel(
              questionType: 3,
              questionName: "What Is Your Favorite Subject",
              values: ['70', '30'],
            ),
          ],
          maxResponseTime: "520 Mins",
          averageTime: "515 Mins",
          minResponseTime: "510 Mins",
          type: "Announcement"),
      SurveyModel(
          summary: "smacmsammsamcsamcmsa,cmsacs,acmsacmsa",
          summaryInArabic: "ستؤمتشؤىسشتىؤتيشىؤتىيشنتؤىستنىؤتسىنؤتىنتسىشتؤنىش",
          surveyTitleArabic: "أيفينت ميديا",
          partitcipants: [
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
          ],
          isSelected: false,
          departmentOwner: "Marketing",
          date: "28 Dec 2024",
          eventName: "Media Event",
          status: "Published",
          surveyPhoto: "assets/images/taskImage.png",
          surveyTitle: "Media Event Survey",
          questions: [
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Short Answer",
                isMcq: false,
                hasPhoto: false,
                answer: "Loarum ipsum ....",
                choices: "A,b,c,d",
                questionType: "Short Answer"),
            QuestionModel(
              isRequired: true,
              question: "Loarum ipsum ....?",
              hintText: "Long Answer",
              isMcq: false,
              hasPhoto: false,
              answer: "sssss",
              choices: "s,s,s",
              questionType: "Long Answer",
            ),
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Multiple Choice",
                isMcq: true,
                hasPhoto: false,
                answer: "A",
                questionType: "Multiple Choice",
                choices: "A,b,c,d"),
          ],
          questionAnalytics: [
            QuestionCardAnalyticModel(
              questionType: 3,
              questionName: "What Is Your Favorite Subject",
              values: ['70', '30'],
            ),
          ],
          maxResponseTime: "320 Mins",
          averageTime: "315 Mins",
          minResponseTime: "310 Mins",
          type: "Announcement"),
      SurveyModel(
          summary: "smacmsammsamcsamcmsa,cmsacs,acmsacmsa",
          summaryInArabic: "ستؤمتشؤىسشتىؤتيشىؤتىيشنتؤىستنىؤتسىنؤتىنتسىشتؤنىش",
          surveyTitleArabic: "أيفينت ميديا",
          partitcipants: [
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
          ],
          isSelected: false,
          departmentOwner: "Marketing",
          date: "28 Dec 2024",
          eventName: "Media Event",
          status: "Published",
          surveyPhoto: "assets/images/taskImage.png",
          surveyTitle: "Media Event Survey",
          questions: [
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Short Answer",
                isMcq: false,
                hasPhoto: false,
                answer: "Loarum ipsum ....",
                choices: "A,b,c,d",
                questionType: "Short Answer"),
            QuestionModel(
              isRequired: true,
              question: "Loarum ipsum ....?",
              hintText: "Long Answer",
              isMcq: false,
              hasPhoto: false,
              answer: "sssss",
              choices: "s,s,s",
              questionType: "Long Answer",
            ),
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Multiple Choice",
                isMcq: true,
                hasPhoto: false,
                answer: "A",
                questionType: "Multiple Choice",
                choices: "A,b,c,d"),
          ],
          questionAnalytics: [
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 1,
              answer: "It was excellent!",
            ),
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 2,
              values: ['50', '30', '15', '5'],
            ),
            QuestionCardAnalyticModel(
              questionType: 3,
              questionName: "What Is Your Favorite Subject",
              values: ['70', '30'],
            ),
          ],
          maxResponseTime: "20 Mins",
          averageTime: "15 Mins",
          minResponseTime: "10 Mins",
          type: "Announcement"),
      SurveyModel(
          summary: "smacmsammsamcsamcmsa,cmsacs,acmsacmsa",
          summaryInArabic: "ستؤمتشؤىسشتىؤتيشىؤتىيشنتؤىستنىؤتسىنؤتىنتسىشتؤنىش",
          surveyTitleArabic: "أيفينت ميديا",
          partitcipants: [
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
          ],
          isSelected: false,
          departmentOwner: "Marketing",
          date: "28 Dec 2024",
          eventName: "Media Event",
          status: "Published",
          surveyPhoto: "assets/images/taskImage.png",
          surveyTitle: "Media Event Survey",
          questions: [
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Short Answer",
                isMcq: false,
                hasPhoto: false,
                answer: "Loarum ipsum ....",
                choices: "A,b,c,d",
                questionType: "Short Answer"),
            QuestionModel(
              isRequired: true,
              question: "Loarum ipsum ....?",
              hintText: "Long Answer",
              isMcq: false,
              hasPhoto: false,
              answer: "sssss",
              choices: "s,s,s",
              questionType: "Long Answer",
            ),
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Multiple Choice",
                isMcq: true,
                hasPhoto: false,
                answer: "A",
                questionType: "Multiple Choice",
                choices: "A,b,c,d"),
          ],
          questionAnalytics: [
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 1,
              answer: "It was excellent!",
            ),
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 2,
              values: ['50', '30', '15', '5'],
            ),
            QuestionCardAnalyticModel(
              questionType: 3,
              questionName: "What Is Your Favorite Subject",
              values: ['70', '30'],
            ),
          ],
          maxResponseTime: "20 Mins",
          averageTime: "15 Mins",
          minResponseTime: "10 Mins",
          type: "Announcement"),
      SurveyModel(
          summary: "smacmsammsamcsamcmsa,cmsacs,acmsacmsa",
          summaryInArabic: "ستؤمتشؤىسشتىؤتيشىؤتىيشنتؤىستنىؤتسىنؤتىنتسىشتؤنىش",
          surveyTitleArabic: "أيفينت ميديا",
          partitcipants: [
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
          ],
          isSelected: false,
          departmentOwner: "Marketing",
          date: "28 Dec 2024",
          eventName: "Media Event",
          status: "Published",
          surveyPhoto: "assets/images/taskImage.png",
          surveyTitle: "Media Event Survey",
          questions: [
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Short Answer",
                isMcq: false,
                hasPhoto: false,
                answer: "Loarum ipsum ....",
                choices: "A,b,c,d",
                questionType: "Short Answer"),
            QuestionModel(
              isRequired: true,
              question: "Loarum ipsum ....?",
              hintText: "Long Answer",
              isMcq: false,
              hasPhoto: false,
              answer: "sssss",
              choices: "s,s,s",
              questionType: "Long Answer",
            ),
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Multiple Choice",
                isMcq: true,
                hasPhoto: false,
                answer: "A",
                questionType: "Multiple Choice",
                choices: "A,b,c,d"),
          ],
          questionAnalytics: [
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 1,
              answer: "It was excellent!",
            ),
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 2,
              values: ['50', '30', '15', '5'],
            ),
            QuestionCardAnalyticModel(
              questionType: 3,
              questionName: "What Is Your Favorite Subject",
              values: ['70', '30'],
            ),
          ],
          maxResponseTime: "20 Mins",
          averageTime: "15 Mins",
          minResponseTime: "10 Mins",
          type: "Announcement"),
      SurveyModel(
          summary: "smacmsammsamcsamcmsa,cmsacs,acmsacmsa",
          summaryInArabic: "ستؤمتشؤىسشتىؤتيشىؤتىيشنتؤىستنىؤتسىنؤتىنتسىشتؤنىش",
          surveyTitleArabic: "أيفينت ميديا",
          partitcipants: [
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
          ],
          isSelected: false,
          departmentOwner: "Marketing",
          date: "28 Dec 2024",
          eventName: "Media Event",
          status: "Published",
          surveyPhoto: "assets/images/taskImage.png",
          surveyTitle: "Media Event Survey",
          questions: [
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Short Answer",
                isMcq: false,
                hasPhoto: false,
                answer: "Loarum ipsum ....",
                choices: "A,b,c,d",
                questionType: "Short Answer"),
            QuestionModel(
              isRequired: true,
              question: "Loarum ipsum ....?",
              hintText: "Long Answer",
              isMcq: false,
              hasPhoto: false,
              answer: "sssss",
              choices: "s,s,s",
              questionType: "Long Answer",
            ),
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Multiple Choice",
                isMcq: true,
                hasPhoto: false,
                answer: "A",
                questionType: "Multiple Choice",
                choices: "A,b,c,d"),
          ],
          questionAnalytics: [
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 1,
              answer: "It was excellent!",

            ),
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 2,
              values: ['50', '30', '15', '5'],
            ),
            QuestionCardAnalyticModel(
              questionType: 3,
              questionName: "What Is Your Favorite Subject",
              values: ['70', '30'],
            ),
          ],
          maxResponseTime: "20 Mins",
          averageTime: "15 Mins",
          minResponseTime: "10 Mins",
          type: "Announcement"),
      SurveyModel(
          summary: "smacmsammsamcsamcmsa,cmsacs,acmsacmsa",
          summaryInArabic: "ستؤمتشؤىسشتىؤتيشىؤتىيشنتؤىستنىؤتسىنؤتىنتسىشتؤنىش",
          surveyTitleArabic: "أيفينت ميديا",
          partitcipants: [
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
          ],
          isSelected: false,
          departmentOwner: "Marketing",
          date: "28 Dec 2024",
          eventName: "Media Event",
          status: "Published",
          surveyPhoto: "assets/images/taskImage.png",
          surveyTitle: "Media Event Survey",
          questions: [
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Short Answer",
                isMcq: false,
                hasPhoto: false,
                answer: "Loarum ipsum ....",
                choices: "A,b,c,d",
                questionType: "Short Answer"),
            QuestionModel(
              isRequired: true,
              question: "Loarum ipsum ....?",
              hintText: "Long Answer",
              isMcq: false,
              hasPhoto: false,
              answer: "sssss",
              choices: "s,s,s",
              questionType: "Long Answer",
            ),
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Multiple Choice",
                isMcq: true,
                hasPhoto: false,
                answer: "A",
                questionType: "Multiple Choice",
                choices: "A,b,c,d"),
          ],
          questionAnalytics: [
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 1,
              answer: "It was excellent!",
            ),
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 2,
              values: ['50', '30', '15', '5'],
            ),
            QuestionCardAnalyticModel(
              questionType: 3,
              questionName: "What Is Your Favorite Subject",
              values: ['70', '30'],
            ),
          ],
          maxResponseTime: "20 Mins",
          averageTime: "15 Mins",
          minResponseTime: "10 Mins",
          type: "Announcement"),
      SurveyModel(
          summary: "smacmsammsamcsamcmsa,cmsacs,acmsacmsa",
          summaryInArabic: "ستؤمتشؤىسشتىؤتيشىؤتىيشنتؤىستنىؤتسىنؤتىنتسىشتؤنىش",
          surveyTitleArabic: "أيفينت ميديا",
          partitcipants: [
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
          ],
          isSelected: false,
          departmentOwner: "Marketing",
          date: "28 Dec 2024",
          eventName: "Media Event",
          status: "Published",
          surveyPhoto: "assets/images/taskImage.png",
          surveyTitle: "Media Event Survey",
          questions: [
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Short Answer",
                isMcq: false,
                hasPhoto: false,
                answer: "Loarum ipsum ....",
                choices: "A,b,c,d",
                questionType: "Short Answer"),
            QuestionModel(
              isRequired: true,
              question: "Loarum ipsum ....?",
              hintText: "Long Answer",
              isMcq: false,
              hasPhoto: false,
              answer: "sssss",
              choices: "s,s,s",
              questionType: "Long Answer",
            ),
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Multiple Choice",
                isMcq: true,
                hasPhoto: false,
                answer: "A",
                questionType: "Multiple Choice",
                choices: "A,b,c,d"),
          ],
          questionAnalytics: [
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 1,
              answer: "It was excellent!",
            ),
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 2,
              values: ['50', '30', '15', '5'],
            ),
            QuestionCardAnalyticModel(
              questionType: 3,
              questionName: "What Is Your Favorite Subject",
              values: ['70', '30'],
            ),
          ],
          maxResponseTime: "20 Mins",
          averageTime: "15 Mins",
          minResponseTime: "10 Mins",
          type: "Announcement"),
      SurveyModel(
          summary: "smacmsammsamcsamcmsa,cmsacs,acmsacmsa",
          summaryInArabic: "ستؤمتشؤىسشتىؤتيشىؤتىيشنتؤىستنىؤتسىنؤتىنتسىشتؤنىش",
          surveyTitleArabic: "أيفينت ميديا",
          partitcipants: [
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
          ],
          isSelected: false,
          departmentOwner: "Marketing",
          date: "28 Dec 2024",
          eventName: "Media Event",
          status: "Published",
          surveyPhoto: "assets/images/taskImage.png",
          surveyTitle: "Media Event Survey",
          questions: [
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Short Answer",
                isMcq: false,
                hasPhoto: false,
                answer: "Loarum ipsum ....",
                choices: "A,b,c,d",
                questionType: "Short Answer"),
            QuestionModel(
              isRequired: true,
              question: "Loarum ipsum ....?",
              hintText: "Long Answer",
              isMcq: false,
              hasPhoto: false,
              answer: "sssss",
              choices: "s,s,s",
              questionType: "Long Answer",
            ),
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Multiple Choice",
                isMcq: true,
                hasPhoto: false,
                answer: "A",
                questionType: "Multiple Choice",
                choices: "A,b,c,d"),
          ],
          questionAnalytics: [
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 1,
              answer: "It was excellent!",
            ),
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 2,
              values: ['50', '30', '15', '5'],
            ),
            QuestionCardAnalyticModel(
              questionType: 3,
              questionName: "What Is Your Favorite Subject",
              values: ['70', '30'],
            ),
          ],
          maxResponseTime: "20 Mins",
          averageTime: "15 Mins",
          minResponseTime: "10 Mins",
          type: "Announcement"),
      SurveyModel(
          summary: "smacmsammsamcsamcmsa,cmsacs,acmsacmsa",
          summaryInArabic: "ستؤمتشؤىسشتىؤتيشىؤتىيشنتؤىستنىؤتسىنؤتىنتسىشتؤنىش",
          surveyTitleArabic: "أيفينت ميديا",
          partitcipants: [
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
          ],
          isSelected: false,
          departmentOwner: "Marketing",
          date: "28 Dec 2024",
          eventName: "Media Event",
          status: "Published",
          surveyPhoto: "assets/images/taskImage.png",
          surveyTitle: "Media Event Survey",
          questions: [
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Short Answer",
                isMcq: false,
                hasPhoto: false,
                answer: "Loarum ipsum ....",
                choices: "A,b,c,d",
                questionType: "Short Answer"),
            QuestionModel(
              isRequired: true,
              question: "Loarum ipsum ....?",
              hintText: "Long Answer",
              isMcq: false,
              hasPhoto: false,
              answer: "sssss",
              choices: "s,s,s",
              questionType: "Long Answer",
            ),
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Multiple Choice",
                isMcq: true,
                hasPhoto: false,
                answer: "A",
                questionType: "Multiple Choice",
                choices: "A,b,c,d"),
          ],
          questionAnalytics: [
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 1,
              answer: "It was excellent!",
            ),
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 2,
              values: ['50', '30', '15', '5'],
            ),
            QuestionCardAnalyticModel(
              questionType: 3,
              questionName: "What Is Your Favorite Subject",
              values: ['70', '30'],
            ),
          ],
          maxResponseTime: "20 Mins",
          averageTime: "15 Mins",
          minResponseTime: "10 Mins",
          type: "Announcement"),
      SurveyModel(
          summary: "smacmsammsamcsamcmsa,cmsacs,acmsacmsa",
          summaryInArabic: "ستؤمتشؤىسشتىؤتيشىؤتىيشنتؤىستنىؤتسىنؤتىنتسىشتؤنىش",
          surveyTitleArabic: "أيفينت ميديا",
          partitcipants: [
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
          ],
          isSelected: false,
          departmentOwner: "Marketing",
          date: "28 Dec 2024",
          eventName: "Media Event",
          status: "Published",
          surveyPhoto: "assets/images/taskImage.png",
          surveyTitle: "Media Event Survey",
          questions: [
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Short Answer",
                isMcq: false,
                hasPhoto: false,
                answer: "Loarum ipsum ....",
                choices: "A,b,c,d",
                questionType: "Short Answer"),
            QuestionModel(
              isRequired: true,
              question: "Loarum ipsum ....?",
              hintText: "Long Answer",
              isMcq: false,
              hasPhoto: false,
              answer: "sssss",
              choices: "s,s,s",
              questionType: "Long Answer",
            ),
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Multiple Choice",
                isMcq: true,
                hasPhoto: false,
                answer: "A",
                questionType: "Multiple Choice",
                choices: "A,b,c,d"),
          ],
          questionAnalytics: [
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 1,
              answer: "It was excellent!",
            ),
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 2,
              values: ['50', '30', '15', '5'],
            ),
            QuestionCardAnalyticModel(
              questionType: 3,
              questionName: "What Is Your Favorite Subject",
              values: ['70', '30'],
            ),
          ],
          maxResponseTime: "20 Mins",
          averageTime: "15 Mins",
          minResponseTime: "10 Mins",
          type: "Announcement"),
      SurveyModel(
          summary: "smacmsammsamcsamcmsa,cmsacs,acmsacmsa",
          summaryInArabic: "ستؤمتشؤىسشتىؤتيشىؤتىيشنتؤىستنىؤتسىنؤتىنتسىشتؤنىش",
          surveyTitleArabic: "أيفينت ميديا",
          partitcipants: [
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
          ],
          isSelected: false,
          departmentOwner: "Marketing",
          date: "28 Dec 2024",
          eventName: "Media Event",
          status: "Published",
          surveyPhoto: "assets/images/taskImage.png",
          surveyTitle: "Media Event Survey",
          questions: [
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Short Answer",
                isMcq: false,
                hasPhoto: false,
                answer: "Loarum ipsum ....",
                choices: "A,b,c,d",
                questionType: "Short Answer"),
            QuestionModel(
              isRequired: true,
              question: "Loarum ipsum ....?",
              hintText: "Long Answer",
              isMcq: false,
              hasPhoto: false,
              answer: "sssss",
              choices: "s,s,s",
              questionType: "Long Answer",
            ),
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Multiple Choice",
                isMcq: true,
                hasPhoto: false,
                answer: "A",
                questionType: "Multiple Choice",
                choices: "A,b,c,d"),
          ],
          questionAnalytics: [
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 1,
              answer: "It was excellent!",
            ),
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 2,
              values: ['50', '30', '15', '5'],
            ),
            QuestionCardAnalyticModel(
              questionType: 3,
              questionName: "What Is Your Favorite Subject",
              values: ['70', '30'],
            ),
          ],
          maxResponseTime: "20 Mins",
          averageTime: "15 Mins",
          minResponseTime: "10 Mins",
          type: "Announcement"),
      SurveyModel(
          summary: "smacmsammsamcsamcmsa,cmsacs,acmsacmsa",
          summaryInArabic: "ستؤمتشؤىسشتىؤتيشىؤتىيشنتؤىستنىؤتسىنؤتىنتسىشتؤنىش",
          surveyTitleArabic: "أيفينت ميديا",
          partitcipants: [
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
          ],
          isSelected: false,
          departmentOwner: "Marketing",
          date: "28 Dec 2024",
          eventName: "Media Event",
          status: "Published",
          surveyPhoto: "assets/images/taskImage.png",
          surveyTitle: "Media Event Survey",
          questions: [
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Short Answer",
                isMcq: false,
                hasPhoto: false,
                answer: "Loarum ipsum ....",
                choices: "A,b,c,d",
                questionType: "Short Answer"),
            QuestionModel(
              isRequired: true,
              question: "Loarum ipsum ....?",
              hintText: "Long Answer",
              isMcq: false,
              hasPhoto: false,
              answer: "sssss",
              choices: "s,s,s",
              questionType: "Long Answer",
            ),
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Multiple Choice",
                isMcq: true,
                hasPhoto: false,
                answer: "A",
                questionType: "Multiple Choice",
                choices: "A,b,c,d"),
          ],
          questionAnalytics: [
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 1,
              answer: "It was excellent!",
            ),
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 2,
              values: ['50', '30', '15', '5'],
            ),
            QuestionCardAnalyticModel(
              questionType: 3,
              questionName: "What Is Your Favorite Subject",
              values: ['70', '30'],
            ),
          ],
          maxResponseTime: "20 Mins",
          averageTime: "15 Mins",
          minResponseTime: "10 Mins",
          type: "Announcement"),
      SurveyModel(
          summary: "smacmsammsamcsamcmsa,cmsacs,acmsacmsa",
          summaryInArabic: "ستؤمتشؤىسشتىؤتيشىؤتىيشنتؤىستنىؤتسىنؤتىنتسىشتؤنىش",
          surveyTitleArabic: "أيفينت ميديا",
          partitcipants: [
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Responded",
              dateSentResponse: "14 jul 2024, 08:00 Pm",
            ),
            ParticipantModel(
              department: "Marketing Manager",
              jobTitle: "Marketing",
              name: "Amro Handousa",
              profilePhoto: "assets/images/profile1.png",
              status: "Pending",
            ),
          ],
          isSelected: false,
          departmentOwner: "Marketing",
          date: "28 Dec 2024",
          eventName: "Media Event",
          status: "Published",
          surveyPhoto: "assets/images/taskImage.png",
          surveyTitle: "Media Event Survey",
          questions: [
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Short Answer",
                isMcq: false,
                hasPhoto: false,
                answer: "Loarum ipsum ....",
                choices: "A,b,c,d",
                questionType: "Short Answer"),
            QuestionModel(
              isRequired: true,
              question: "Loarum ipsum ....?",
              hintText: "Long Answer",
              isMcq: false,
              hasPhoto: false,
              answer: "sssss",
              choices: "s,s,s",
              questionType: "Long Answer",
            ),
            QuestionModel(
                isRequired: true,
                question: "Loarum ipsum ....?",
                hintText: "Multiple Choice",
                isMcq: true,
                hasPhoto: false,
                answer: "A",
                questionType: "Multiple Choice",
                choices: "A,b,c,d"),
          ],
          questionAnalytics: [
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 1,
              answer: "It was excellent!",
            ),
            QuestionCardAnalyticModel(
              questionName: "What Is Your Favorite Subject",
              questionType: 2,
              values: ['50', '30', '15', '5'],
            ),
            QuestionCardAnalyticModel(
              questionType: 3,
              questionName: "What Is Your Favorite Subject",
              values: ['70', '30'],
            ),
          ],
          maxResponseTime: "20 Mins",
          averageTime: "15 Mins",
          minResponseTime: "10 Mins",
          type: "Announcement"),
    ];
    
 */
