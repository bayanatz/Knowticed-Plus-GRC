/// Module: roles / r4_active_directory / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: department_model.dart
/// Purpose: Declares `DepartmentModelPro`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentModelPro {
  String? departmentID;
  String? departmentName;
  String? departmentNameInArabic;
  Timestamp? creationDate;
  String? addedBy;

  DepartmentModelPro({
    this.departmentID,
    this.departmentName,
    this.departmentNameInArabic,
    this.creationDate,
    this.addedBy,
  });

  factory DepartmentModelPro.fromMap(Map<String, dynamic> map) {
    return DepartmentModelPro(
      departmentID: map['Department_ID'] as String? ?? '',
      departmentName: map['Department_Name'] as String? ?? '',
      departmentNameInArabic: map['Department_Name_In_Arabic'] as String? ?? '',
      creationDate: _creationDate(map['Creation_Date']),
      addedBy: map['Added_By'] as String? ?? '',
    );
  }

  /// Tolerant read (18/10/2026): one department saved with a text date made
  /// the strict `as Timestamp?` cast throw and the WHOLE department list
  /// failed to load (Org Chart lost its departments, tabs and columns).
  static Timestamp _creationDate(Object? value) {
    if (value is Timestamp) return value;
    if (value is DateTime) return Timestamp.fromDate(value);
    if (value is String) {
      final DateTime? parsed = DateTime.tryParse(value);
      if (parsed != null) return Timestamp.fromDate(parsed);
    }
    return Timestamp.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'Department_ID': departmentID,
      'Department_Name': departmentName,
      'Department_Name_In_Arabic': departmentNameInArabic,
      'Creation_Date': creationDate,
      'Added_By': addedBy,
    };
  }
}
