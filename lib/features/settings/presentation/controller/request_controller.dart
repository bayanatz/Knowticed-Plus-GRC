import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/constants/system_actions.dart';
import 'package:demo_app/features/employee/data/models/emplyees_model/new_employee_model.dart';

import 'package:demo_app/features/settings/data/models/request_model.dart';
import 'package:demo_app/features/notification/presentation/controller/app_notification_controller.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';

import 'package:demo_app/features/onboarding/authentication/welcome_screen/views/mobile_view/nav_bar.dart';


class RequestController extends GetxController with StateMixin {
  // FirebaseFirestore instance for interacting with Firestore.
  FirebaseFirestore db = FirebaseFirestore.instance;
  Rx<RequestsModel> requestsModel = RequestsModel().obs;
  List<RequestsModel> requestsList = [];
  Map<String, List<RequestsModel>> allRequestsPending = {};
  Map<String, List<RequestsModel>> allRequestReview = {};
  bool isLoading = false;
  //Map<String, List<RequestsModel>> userRequests = {};
  AppNotificationController appNotificationController =
      Get.put(AppNotificationController());
  Future createRequest(
    RequestsModel requestsModel,
    String requestsId,
  ) async {
    // Update the controller state.
    update();

    final CollectionReference requestsCollection = db.collection('/Requests');

    await requestsCollection
        .doc(
            '${employee!.email.last!}_${requestsModel.section!.toLowerCase().replaceAll(' ', '_')}')
        .collection('User_Requests')
        .doc(requestsId)
        .set((requestsModel).toMap(), SetOptions(merge: true));

    // Update the controller state.
    update();
    systemLogsController
        .systemLogsAction(SystemActions.requestChangePersonalInfo);
    // Set the controller status to success.
    change(requestsModel, status: RxStatus.success());
  }

  Future<List<RequestsModel>> getuserRequests(
      String userEmail, String section, bool isPending) async {
    // Update the controller state.

    final CollectionReference requestsCollection = db.collection('/Requests');

    // Fetch all documents from the 'User_Requests' sub-collection for the specified user.
    QuerySnapshot querySnapshot = isPending
        ? await requestsCollection
            .doc('${userEmail}_$section')
            .collection('User_Requests')
            .where('Status', isEqualTo: 'pending')
            .get()
        : await requestsCollection
            .doc('${userEmail}_$section')
            .collection('User_Requests')
            .where('Status', isNotEqualTo: 'pending')
            .get();

    // Convert the documents into a list of RequestsModel objects.
    List<RequestsModel> requestsList = querySnapshot.docs
        .map((doc) => RequestsModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    // Update the controller state.
    update();

    // Set the controller status to success.
    change(requestsList, status: RxStatus.success());

    return requestsList;
  }

  void updateRequest(String status, RequestsModel requestsModel) async {
    {
      requestsModel.status = status;
      final CollectionReference requestsCollection = db.collection('/Requests');

      await requestsCollection
          .doc(
              '${requestsModel.email!}_${requestsModel.section!.replaceAll(' ', '_')}')
          .collection('User_Requests')
          .doc(requestsModel.requestId)
          .set((requestsModel).toMap(), SetOptions(merge: true))
          .then((value) {
        appNotificationController.sendNotification(
            type: 'request',
            topic: requestsModel.email!,
            title: 'Request status changed',
            arabicTitle: 'تم تغيير حالة الطلب',
            body:
                'Your request to change ${requestsModel.whatChanged} has been ${status == 'approved' ? 'approved' : 'rejected'}',
            arabicBody:
                'الطلب لتغيير ${requestsModel.whatChanged?.capitalize?.tr}  ${status == 'approved' ? 'تمت الموافقة عليه' : 'تم رفضه'}');
        updateEmployeeProfile(requestsModel);
        getAllRequests(true);
        getAllRequests(false);
      });

      // Update the controller state.
      update();
      systemLogsController.systemLogsAction(SystemActions.updateRequestStatus);
    }
  }

  void acceptAll(List<RequestsModel> requestsModel) async {
    {
      final CollectionReference requestsCollection = db.collection('/Requests');
      WriteBatch batch = db.batch();
      for (var request in requestsModel) {
        request.status = 'approved';
        await requestsCollection
            .doc('${request.email!}_${request.section!.replaceAll(' ', '_')}')
            .collection('User_Requests')
            .doc(request.requestId)
            .set((request).toMap(), SetOptions(merge: true));
      }

      batch.commit().then((value) {
        appNotificationController.sendNotification(
          type: 'request',
          topic: requestsModel[0].email!,
          title: 'Request status changed',
          arabicTitle: 'تم تغيير حالة الطلب',
          body:
              'Your request to change ${requestsModel[0].section} has been approved',
          arabicBody:
              'الطلب لتغيير ${requestsModel[0].section?.capitalize?.tr}  تمت الموافقة عليه',
        );
        for (var request in requestsModel) {
          updateEmployeeProfile(request);
        }
        getAllRequests(true);
        getAllRequests(false);
      });

      // Update the controller state.
      update();
      systemLogsController.systemLogsAction(SystemActions.updateRequestStatus);
    }
  }

  EmployeeController addEmployeeController = Get.find();
  List<String> sections = [
    'personal_info',
    'additional_info',
    'health_insurance'
  ];
  Map<String, List<RequestsModel>> pendingRequests = {};
  Map<String, List<RequestsModel>> reviewRequests = {};
  Future<Map<String, List<RequestsModel>>> getAllRequests(
      bool isPending) async {
    //  userRequests = {};
    isPending ? pendingRequests = {} : reviewRequests = {};
    isLoading = true;
    for (var employee in addEmployeeController.allEmployees!) {
      for (int i = 0; i < sections.length; i++) {
        List<RequestsModel> requests = await getuserRequests(
            employee.email.last!, sections[i], isPending);
        if (requests.isNotEmpty) {
          isPending
              ? pendingRequests[
                  '${employee.email.last!}_${sections[i]}'] = requests
              : reviewRequests[
                  '${employee.email.last!}_${sections[i]}'] = requests;
        }
      }

      update();
    }
    isLoading = false;

    return isPending ? pendingRequests : reviewRequests;
  }

  void updateEmployeeProfile(RequestsModel requestsModel) async {
    NewEmployeeModelHistory? currentEmployee =
        await addEmployeeController.getEmployee(requestsModel.email!);
/*
    if (requestsModel.whatChanged! == 'first name') {
      currentEmployee!.firstName!.firstNames!.add(requestsModel.newData!);
      currentEmployee.firstName!.timestamps!.add(Timestamp.now());
      employeeDirectory!.firstName!.firstNames!.add(requestsModel.newData!);
      employeeDirectory!.firstName!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'middle name') {
      currentEmployee!.middleName!.middleName!.add(requestsModel.newData!);
      currentEmployee.middleName!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'last name') {
      currentEmployee!.lastName!.lastNames!.add(requestsModel.newData!);
      currentEmployee.lastName!.timestamps!.add(Timestamp.now());
      employeeDirectory!.lastName!.lastNames!.add(requestsModel.newData!);
      employeeDirectory!.lastName!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'nationality') {
      currentEmployee!.nationality!.nationality!.add(requestsModel.newData!);
      currentEmployee.nationality!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'birthdate') {
      currentEmployee!.birthDay!.birthDays!.add(requestsModel.newData!);
      currentEmployee.birthDay!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'gender') {
      currentEmployee!.gender!.gender!.add(requestsModel.newData!);
      currentEmployee.gender!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'marital status') {
      currentEmployee!.maritalStatus!.maritalStatus!
          .add(requestsModel.newData!);
      currentEmployee.maritalStatus!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'phone') {
      currentEmployee!.phone!.phones!.add(requestsModel.newData!);
      currentEmployee.phone!.timestamps!.add(Timestamp.now());
      employeeDirectory!.phone!.phones!.add(requestsModel.newData!);
      employeeDirectory!.phone!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'email') {
      currentEmployee!.email.add(requestsModel.newData!);
      currentEmployee.email!.timestamps!.add(Timestamp.now());
      employeeDirectory!.email.add(requestsModel.newData!);
      employeeDirectory!.email!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'country') {
      currentEmployee!.country!.country!.add(requestsModel.newData!);
      currentEmployee.country!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'province') {
      currentEmployee!.province!.province!.add(requestsModel.newData!);
      currentEmployee.province!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'city') {
      currentEmployee!.city!.city!.add(requestsModel.newData!);
      currentEmployee.city!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'address') {
      currentEmployee!.address!.address!.add(requestsModel.newData!);
      currentEmployee.address!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'insurance name') {
      currentEmployee!.insuranceName!.insuranceNames!
          .add(requestsModel.newData!);
      currentEmployee.insuranceName!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'insurance police number') {
      currentEmployee!.insurancePoliceNumber!.insurancePoliceNumber!
          .add(requestsModel.newData!);
      currentEmployee.insurancePoliceNumber!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'insurance phone number') {
      currentEmployee!.insurancePhoneNumber!.insurancePhoneNumber!
          .add(requestsModel.newData!);
      currentEmployee.insurancePhoneNumber!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'contact first name') {
      currentEmployee!.contactFirstName!.contactFirstName!
          .add(requestsModel.newData!);
      currentEmployee.contactFirstName!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'contact middle name') {
      currentEmployee!.contactMiddleName!.contactMiddleName!
          .add(requestsModel.newData!);
      currentEmployee.contactMiddleName!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'contact last name') {
      currentEmployee!.contactLastName!.contactLastName!
          .add(requestsModel.newData!);
      currentEmployee.contactLastName!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'contact relation') {
      currentEmployee!.contactRelation!.contactRelation!
          .add(requestsModel.newData!);
      currentEmployee.contactRelation!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'contact number') {
      currentEmployee!.contactNumber!.contactNumber!
          .add(requestsModel.newData!);
      currentEmployee.contactRelation!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'contact email') {
      currentEmployee!.contactEmail!.contactEmail!.add(requestsModel.newData!);
      currentEmployee.contactEmail!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'contact country') {
      currentEmployee!.contactCountry!.contactCountry!
          .add(requestsModel.newData!);
      currentEmployee.contactCountry!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'contact province') {
      currentEmployee!.contactProvince!.contactProvince!
          .add(requestsModel.newData!);
      currentEmployee.contactProvince!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'contact city') {
      currentEmployee!.contactCity!.contactCity!.add(requestsModel.newData!);
      currentEmployee.contactCity!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'contact address') {
      currentEmployee!.contactAddress!.contactAddress!
          .add(requestsModel.newData!);
      currentEmployee.contactAddress!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'education certificate') {
      currentEmployee!.educationCertificate!.educationCertificate!
          .add(requestsModel.newData!);
      currentEmployee.educationCertificate!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'id photo') {
      currentEmployee!.idPhoto!.idPhoto!.add(requestsModel.newData!);
      currentEmployee.idPhoto!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'driving license') {
      currentEmployee!.drivingLicense!.drivingLicense!
          .add(requestsModel.newData!);
      currentEmployee.drivingLicense!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'marital certificate') {
      currentEmployee!.maritalCertificate!.maritalCertificate!
          .add(requestsModel.newData!);
      currentEmployee.maritalCertificate!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'insurance card') {
      currentEmployee!.insuranceCard!.insuranceCard!
          .add(requestsModel.newData!);
      currentEmployee.insuranceCard!.timestamps!.add(Timestamp.now());
    }
    if (requestsModel.whatChanged! == 'army certificate') {
      currentEmployee!.armyCertificate!.armyCertificate!
          .add(requestsModel.newData!);
      currentEmployee.armyCertificate!.timestamps!.add(Timestamp.now());
    }

    systemLogsController.systemLogsAction(SystemActions.updateEmployee);
    await addEmployeeController.createEmployee(
        currentEmployee!, null, requestsModel.email!, false);*/
  }
}
