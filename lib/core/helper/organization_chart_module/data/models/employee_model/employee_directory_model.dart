// ignore_for_file: prefer_null_aware_operators

import 'dart:convert';
import 'package:demo_app/features/employee/data/models/emplyees_model/mobile_phone_model.dart';

import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/email_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/first_name_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/last_name_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/supervisor_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/employee_model/department_model.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024

class EmployeeDirectoryModel {
  FirstName? firstName;
  LastName? lastName;
  Email? email;
  MobilePhone? phone;
  Department? department;
  Supervisor? supervisor;
  String? dateAdded;
  EmployeeDirectoryModel({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.department,
    this.supervisor,
    this.dateAdded,
  });

  factory EmployeeDirectoryModel.fromMap(Map? data) {
    return EmployeeDirectoryModel(
      firstName: FirstName.fromMap(data?['First_Name']),
      lastName: LastName.fromMap(data?['Last_Name']),
      email: Email.fromMap(data?['Email']),
      phone: MobilePhone.fromMap(data?['Phone']),
      department: Department.fromMap(data?['Department']),
      supervisor: Supervisor.fromMap(data?['Supervisor']),
      dateAdded: data?['Date_Added'],
    );
  }

  Map<String, dynamic> toMap() => {
        'First_Name': firstName != null ? firstName!.toMap() : null,
        'Last_Name': lastName != null ? lastName!.toMap() : null,
        'Email': email != null ? email!.toMap() : null,
        'Phone': phone != null ? phone!.toMap() : null,
        'Department': department != null ? department!.toMap() : null,
        'Supervisor': supervisor != null ? supervisor!.toMap() : null,
        'Date_Added': DateTime.now().toString()
      };

  String toJson() => json.encode(toMap());
  Map<String, dynamic> fromJson(String jsonString) => json.decode(jsonString);
}
