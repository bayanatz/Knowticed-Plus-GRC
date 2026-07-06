import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/features/home/data/models/attendance_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';

class AttendanceController extends GetxController with StateMixin {
  FirebaseFirestore db = FirebaseFirestore.instance;
  Rx<AttendanceModel> attendanceModel = AttendanceModel().obs;
  List<AttendanceModel> employeeAttendances = [];
  List<AttendanceModel> allAttendances = [];

  Future addAttendance(AttendanceModel model, String email) async {
    update();
    final col = db.collection('/Attendances');
    await col
        .doc(email)
        .collection('EmployeeAttendances')
        .doc(DateFormat('MMM dd, yyyy').format(DateTime.now()))
        .set(model.toMap());
    update();
    change(model, status: RxStatus.success());
  }

  Future<List<AttendanceModel>> getUserAttendances(String email) async {
    try {
      final col = db
          .collection('/Attendances')
          .doc(email)
          .collection('EmployeeAttendances');
      QuerySnapshot q = await col.get();
      employeeAttendances = q.docs
          .map((doc) => AttendanceModel.fromMap(doc.data() as Map))
          .toList();
      return employeeAttendances;
    } catch (e) {
      print('Error fetching attendances: $e');
      return [];
    }
  }

  EmployeeController addEmployeeController = Get.find();

  Future<List<AttendanceModel>> getAllAttendance() async {
    allAttendances = [];
    for (var employee in addEmployeeController.allEmployees ?? []) {
      allAttendances.addAll(await getUserAttendances(employee.email?.last ?? ''));
    }
    return allAttendances;
  }
}
