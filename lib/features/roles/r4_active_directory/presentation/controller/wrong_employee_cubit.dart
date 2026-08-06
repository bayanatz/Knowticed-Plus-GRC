// ignore_for_file: avoid_print

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/wrong_employee_model.dart';

part './wrong_employee_state.dart';

/// Cubit for wrong-employee records.
///
/// Converted from AddWrongEmployeeController (GetxController + StateMixin) and
/// moved here from onboarding/o3_authentication, since every consumer of the
/// wrong-data flow lives in active_directory.
///
/// Dependency lookup still goes through GetX (`Get.put` in login_controller,
/// `Get.find` in ActiveDirectoryController) — only the state mechanism changed.
class AddWrongEmployeeController extends Cubit<WrongEmployeeState> {
  AddWrongEmployeeController() : super(WrongEmployeeInitial());

  FirebaseFirestore db = FirebaseFirestore.instance;

  /// Last record written (was an Rx field under GetX).
  WrongEmployeeModel wrongEmployeeModel = WrongEmployeeModel();

  List<WrongEmployeeModel>? allWrongEmployees;
  List<WrongEmployeeModel>? employeesWithoutFilter;

  Future<void> createWrongEmployee(
      WrongEmployeeModel wrongEmployeeModel, String email) async {
    emit(WrongEmployeeLoading());

    final CollectionReference employeeCollection =
        db.collection('/Wrong_Employees_Profile');

    await employeeCollection
        .doc(email)
        .set((wrongEmployeeModel).toMap(), SetOptions(merge: true));

    this.wrongEmployeeModel = wrongEmployeeModel;
    emit(WrongEmployeeUpdated());
  }

  Future<List<WrongEmployeeModel>?> getAllEmployees() async {
    final CollectionReference employeeCollection =
        db.collection(ApiConstants.wrongEmployees);

    try {
      QuerySnapshot querySnapshot = await employeeCollection.get();

      allWrongEmployees = querySnapshot.docs
          .map((DocumentSnapshot document) => WrongEmployeeModel.fromMap(
              document.data() as Map<String, dynamic>))
          .toList();

      emit(WrongEmployeeUpdated());
      return allWrongEmployees;
    } catch (e) {
      emit(WrongEmployeeError(e.toString()));
      return [];
    }
  }
}
