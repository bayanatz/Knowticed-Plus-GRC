// ignore_for_file: prefer_null_aware_operators

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/mobile_phone_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/email_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/first_name_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/last_name_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/supervisor_model.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
//
// Ported into services_app under features/settings (source: services_app
// features/employees/data/models/employee_model/employee_directory_model.dart).
//
// NOTE: the `Department` class below is inlined here on purpose. services_app
// already ships a `DepartmentId` model under
// features/roles/r4_active_directory/data/models/emplyees_model/department_model.dart
// but it uses a different field name and a different Firestore key
// ("Department_Id" vs "Department"), so it is NOT interchangeable.

class Department {
  List<String?>? department;
  List<Timestamp?>? timestamps;

  Department({
    this.department,
    this.timestamps,
  });

  Department copyWith({
    List<String?>? department,
    List<Timestamp?>? timestamps,
  }) {
    return Department(
      department: department ?? this.department,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Department': department,
      'Timestamp': timestamps,
    };
  }

  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(
      department: map['Department'] != null
          ? List<String?>.from(
              (map['Department']),
            )
          : null,
      timestamps: map['Timestamp'] != null
          ? List<Timestamp?>.from(
              (map['Timestamp']),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Department.fromJson(String source) =>
      Department.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Department(Department: $department, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Department other) {
    if (identical(this, other)) return true;

    return listEquals(other.department, department) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => department.hashCode ^ timestamps.hashCode;
}

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
