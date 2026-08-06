/// ***************************** FILE INFO ***************************** ///
/// File Name: notification_cubit.dart
/// Purpose: FCM topic messaging + the logged-in employee's notification list.
/// Description: Converted from MainCoreNotificationController
///              (GetxController). `allNotifications` / `isLoading` are now
///              carried by [MainCoreNotificationState] instead of `update()`;
///              the fields are kept as getters so any existing reader keeps
///              working. Network and Firestore logic is unchanged.
/// ********************************************************************* ///

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/features/notification/data/models/notification_model_core.dart';

part './notification_state.dart';

class MainCoreNotificationCubit extends Cubit<MainCoreNotificationState> {
  MainCoreNotificationCubit() : super(const MainCoreNotificationInitial());

  FirebaseFirestore db = FirebaseFirestore.instance;
  final fcm = FirebaseMessaging.instance;

  List<NotificationModel> allNotifications = [];
  bool isLoading = false;

  /// ✨Format a topic.⭐
  /// Replaces all "@", ":", " ", and "-" in the topic with "_"
  /// and appends "topic" to the end. This is the format that
  /// Firebase Cloud Messaging expects for topics.
  String formatTopic(String topic) {
    return "${topic.replaceAll("@", "_").replaceAll(":", "_").replaceAll(" ", "_").replaceAll("-", "_")}topic";
  }

  /// ✨Subscribe to a topic.⭐
  /// This will subscribe the user to a topic, and they will start receiving
  /// notifications for that topi
  /*
  Future<void> subscribeToTopic(String topic) async {
    await fcm.subscribeToTopic(formatTopic(topic));
    debugPrint("subscribe to topic $topic");
  }*/

  /// ✨Unsubscribe from a topic.⭐
  /// This will remove the user from a topic, and they will stop receiving notifications
  /// for that topic.
/*  Future<void> unsubscribeFromTopic(String topic) async {
    await fcm.unsubscribeFromTopic(formatTopic(topic));
    debugPrint("unsubscribe topic $topic");
  }*/

  /// ✨Requests permission from the user to receive notifications.⭐
  Future<void> requestPermission() async {
    NotificationSettings settings = await fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("User granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint("User granted provisional permission");
    } else {
      debugPrint("User declined or has not accepted permission");
    }
  }

  /// ✨Initializes Firebase Cloud Messaging (FCM) by requesting permission
  /// for the app to receive notifications and retrieves a Firebase
  /// messaging token. The token is used to authenticate with the FCM API.⭐
  Future<void> initNotifications() async {
    await requestPermission();
    String? firebaseMessagingToken = await fcm.getToken();
    debugPrint("firebaseMessagingToken : $firebaseMessagingToken");
  }

  /// ✨Returns a Firebase access token that can be used to call Firebase APIs.⭐
  ///
  /// This method is used to get a token that can be used to call Firebase APIs,
  /// such as the Firebase Cloud Messaging (FCM) API. The token is obtained by
  /// using a service account to authenticate with Google.
  ///
  /// The returned token is a string that can be used as a Bearer token in the
  /// Authorization header of HTTP requests to Firebase APIs.
  ///
  /// The token is valid for one hour. After that, the method needs to be called
  /// again to obtain a new token.
  Future<String?> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "knowticed-v2-scheme",
      "private_key_id": "4a18f36d82625b3ded56c78a85068c63e3061b5a",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDn4Smuy0H40uaC\nKfPqf7yEAaft7nHyxZgaeSyXxQRY4DEpGxdxettZQh9nmhqpVSi/KcKLzVCXxuaq\n+rdy34ejCkaemyzGj5NSD+bE3v3kSfvWoiQ6nqMTuuN6KJPoxgCMhJsP323VXHoV\nqXE1OA8iwzQ2CKoUc4KM25hrHONxrJ+uVwHcGEscwZRe9z3UXo4KSixl1oQwshoL\nIu1PQoP+xTm08NpsbTtr/pXPyv7GPbPZwvXjBq8eS4uTOamOYYe+LNYPmnjr7EL6\nvihoMsCKyKSQRp+DVglNDipOsD4Rp5UIoKdGUN0TeKesmdg4AhKZzd0Nz/9U2jpR\nzfFMEy0RAgMBAAECggEAAtQo3YSGRAJSpJDddGVlh9i7Uzg+9J67ecszo5BYOrtV\nbjJx6UT96wtW9b0YCSvMSPS59lmlW4ymILzZQxH+Bhuoe+PZunxi6DPgdVNhFole\nhKJKvdpUk/eKMeHP2B2eQRiXCa0Imns71ArSojsSWDK4btZRONml5JEDPX9HOQpD\nn6kpYJRFXazVG0VjxD7oRNNpw3C8AP6R+pr6zKwFyE5WFL1WtGcSashkN6TV/RUV\nmbofrEgs96Y1SGi9tyuQDMww9MtkomsBlN0PcHH/6YdZ00VxBe4mxxE8fOmlGyyB\n+t4co3Qi88hkgSAdZWK+XMkHuY0EKvB60qEV9HHNZwKBgQD8chRnx9onHjzlpq1c\nSbNGE7y+BPM3aRnfD/WjgJgIiK7d2QdnEiv+EwDorXWLBCxSEMK0oZb+dg2O6Xbq\n3DTehF7TRTUnO6bBUBzvPMmlpvlvdTAsbFU8wcrPt+ZiVVHsu86kzvq73gd6c5BO\nxsMjjzrYjqiSySnTZKNM76cJywKBgQDrJPRM/mvyYWWIbD4FhVSAkFmwtPDtIG0s\nCR5t8Pv84IQQRHujyR2YVLrBIqMO69SlP2c7M7dVxsPaND1XdbpHcwsWfMulUj9s\nQT0QV54kzpeKFHAr4uooiA6AziP9GDIQ4qUFAbwkwb1K1eWq5zHi3Uzj+G7CNqDy\n0aidJZX5EwKBgQDdB3FQUI50M6h0FpSxOiJKGBvob+MXv+EUCiAzcPMsfahFu7Ec\nkK+N/MuN7dn9xsCbdetURiszTt+eIlGpXva3YUS5TF42pKbjmSZMXXfcny7EZOGx\n84RJ9w+BAW4o6LUbRnCuoj6sYMFBeI+AOc0/hDesxnNYWeNSIEpOoYIqMwKBgEa1\nPw0j+FvTM8/ZFLFeTXG3dnDvh/8WIB38w/y1WWDKNowZu8AdituyptHK05N6EOB7\n91PTEk8lzOEBkmyJRzGTA4OIlUgqOk4YM/+FCVXyFZl82dooitcTSqEq26GQtAVl\n0c92nRfEdmJZfY1tpg+dEjD/FHcsLCu4JebTVYynAoGAJ/nXaFnQiLjWxJHdOMPP\n5X169jsnMTDwIl6t2jurnLt9nomP2uhyTYdUKMMZ4lSh5YflxuKXl9/h4IQ4HgOq\nFPHxW+fwfE43xA7m6pj18uCjrT3/owzZdpauACPJ7HuSSjOcRgsaXbvd1sSyRyNE\nET/QqNPNcmkhjo/y11UF2r0=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-2szdm@knowticed-v2-scheme.iam.gserviceaccount.com",
      "client_id": "108712132861240366762",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-2szdm%40knowticed-v2-scheme.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    try {
      http.Client client = await auth.clientViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

      auth.AccessCredentials credentials =
          await auth.obtainAccessCredentialsViaServiceAccount(
              auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
              scopes,
              client);

      client.close();

      debugPrint("Access Token: ${credentials.accessToken.data}");
      debugPrint("fcm Token : ${await fcm.getToken()}");
      return credentials.accessToken.data;
    } catch (e) {
      return null;
    }
  }

  /// ✨Send a notification to a given topic.⭐
  Future<void> sendNotification(
      {required String title,
      required String arabicTitle,
      required String body,
      required String arabicBody,
      required String type,
      required String topic,
      String? noteId,
      String? cardId,
      String? todoId,
      String? eventId,
      String? surveyId,
      String? boardId,
      String? serviceId,
      String? serviceRequestId}) async {
    if (topic != '') {
      try {
        var serverKeyAuthorization = await getAccessToken();

        const String urlEndPoint =
            "https://fcm.googleapis.com/v1/projects/knowticed-v2-scheme/messages:send";

        Dio dio = Dio();
        dio.options.headers['Content-Type'] = 'application/json';
        dio.options.headers['Authorization'] = 'Bearer $serverKeyAuthorization';

        await dio
            .post(
          urlEndPoint,
          data: NotificationPayload(
            fcmToken: '/topics/${formatTopic(topic)}',
            data: NotificationData(
              arabicTitle: arabicTitle,
              arabicBody: arabicBody,
              englishTitle: title.capitalize!,
              englishBody: body.capitalize!,
              type: type.toLowerCase(),
              noteId: noteId,
              cardId: cardId,
              todoId: todoId,
              eventId: eventId,
              surveyId: surveyId,
              boardId: boardId,
              serviceId: serviceId,
              serviceRequestId: serviceRequestId,
              clickAction: "FLUTTER_NOTIFICATION_CLICK",
            ),
            notification: NotificationContent(
              title: title.capitalize!,
              body: body.capitalize!,
            ),
          ).toMap(),
        )
            .then(
          (value) async {
            debugPrint("Notification sent successfully999");
          },
        );
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  /// ✨Sends a notification to multiple topics.⭐
  ///
  /// This method takes a list of topics and sends a notification to all of them.
  /// The notification is stored in the database and has a unique id generated
  /// by the server.
  Future<void> sendNotificationToMultiple(
      {required String title,
      required String arabicTitle,
      required String body,
      required String arabicBody,
      required String type,
      required List<String> topics,
      String? noteId,
      String? cardId,
      String? todoId,
      String? eventId,
      String? surveyId,
      String? boardId,
      String? serviceId,
      String? serviceRequestId}) async {
    try {
      WriteBatch batch = db.batch();
      var serverKeyAuthorization = await getAccessToken();

      const String urlEndPoint =
          "https://fcm.googleapis.com/v1/projects/knowticed-v2-scheme/messages:send";

      Dio dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = 'Bearer $serverKeyAuthorization';

      for (var element in topics) {
        debugPrint(element);
        await dio.post(urlEndPoint,
            data: NotificationPayload(
                fcmToken: '/topics/${formatTopic(element)}',
                data: NotificationData(
                  arabicTitle: arabicTitle,
                  arabicBody: arabicBody,
                  englishTitle: title.capitalize!,
                  englishBody: body.capitalize!,
                  type: type.toLowerCase(),
                  noteId: noteId,
                  cardId: cardId,
                  todoId: todoId,
                  eventId: eventId,
                  surveyId: surveyId,
                  boardId: boardId,
                  serviceId: serviceId,
                  serviceRequestId: serviceRequestId,
                  clickAction: "FLUTTER_NOTIFICATION_CLICK",
                ),
                notification: NotificationContent(
                  title: title.capitalize!,
                  body: body.capitalize!,
                )).toMap());
      }
      await batch.commit();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// ✨Fetch all notifications for the currently logged in employee and store them⭐
  /// in the [allNotifications] list.
  Future<void> fetchNotifications() async {
    isLoading = true;
    emit(const MainCoreNotificationLoading());

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Notifications')
        .doc(Get.find<MainCoreEmployeeController>().employeeEntity!.email!)
        .collection('Notifications')
        .orderBy('Timestamp', descending: true)
        .get();

    allNotifications = querySnapshot.docs.map((doc) {
      return NotificationModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
    debugPrint("fetch allNotifications : ${allNotifications.length}");
    isLoading = false;

    emit(MainCoreNotificationLoaded(
      notifications: List.unmodifiable(allNotifications),
    ));
  }

  /// ✨Stream that emits a snapshot whenever unseen notifications for the currently
  /// logged in employee change.⭐
  ///  The snapshot contains all unseen notifications for the employee.
  Stream<QuerySnapshot> getUnseenNotificationsStream() {
    return FirebaseFirestore.instance
        .collection('Notifications')
        .doc(Get.find<MainCoreEmployeeController>().employeeEntity!.email!)
        .collection('Notifications')
        .where('seen', isEqualTo: false)
        .snapshots();
  }

  /// ✨Mark all unseen notifications for the currently logged in employee as seen.⭐
  /// This is typically called when the user opens the notifications screen.
  Future<void> updateSeenNotifications() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Notifications')
        .doc(Get.find<MainCoreEmployeeController>().employeeEntity!.email!)
        .collection('Notifications')
        .where('seen', isEqualTo: false)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'seen': true});
    }
  }
}

class NotificationPayload {
  final String fcmToken;
  final NotificationContent notification;
  final NotificationData data;

  NotificationPayload({
    required this.fcmToken,
    required this.notification,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      "message": {
        "token": fcmToken,
        "apns": {
          "payload": {
            "aps": {
              "content_available": true,
              "alert": notification.toMap(),
              "sound": "default",
            },
          },
        },
        "data": data.toMap(),
      },
    };
  }
}

class NotificationContent {
  final String title;
  final String body;

  NotificationContent({
    required this.title,
    required this.body,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "body": body,
    };
  }
}

class NotificationData {
  final String? type;
  final String arabicTitle, arabicBody, englishTitle, englishBody;
  final String? noteId,
      cardId,
      todoId,
      eventId,
      surveyId,
      boardId,
      serviceId,
      serviceRequestId;
  final String clickAction;

  NotificationData({
    this.type,
    this.noteId,
    this.cardId,
    this.todoId,
    this.eventId,
    this.surveyId,
    this.boardId,
    this.serviceId,
    this.serviceRequestId,
    this.clickAction = "FLUTTER_NOTIFICATION_CLICK",
    required this.englishTitle,
    required this.arabicTitle,
    required this.englishBody,
    required this.arabicBody,
  });

  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "click_action": clickAction,
      "Arabic_Title": arabicTitle,
      "English_Title": englishTitle,
      "Arabic_Body": arabicBody,
      "English_Body": englishBody,
      "Note_Id": noteId,
      "Card_Id": cardId,
      "Todo_Id": todoId,
      "Event_Id": eventId,
      "Survey_Id": surveyId,
      "Board_Id": boardId,
      "Service_Id": serviceId,
      "Service_Request_Id": serviceRequestId,
    };
  }

  // from map

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      type: map["type"],
      noteId: map["Note_Id"],
      cardId: map["Card_Id"],
      todoId: map["Todo_Id"],
      eventId: map["Event_Id"],
      surveyId: map["Survey_Id"],
      boardId: map["Board_Id"],
      serviceId: map["Service_Id"],
      serviceRequestId: map["Service_Request_Id"],
      clickAction: map["click_action"] ?? "FLUTTER_NOTIFICATION_CLICK",
      englishTitle: map["English_Title"],
      arabicTitle: map["Arabic_Title"],
      englishBody: map["English_Body"],
      arabicBody: map["Arabic_Body"],
    );
  }
}
