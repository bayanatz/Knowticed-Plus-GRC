/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: academic_history_entity.dart
/// Purpose: One entry of an employee's academic history.
/// Author: Knowticed Team
/// Updated: 18/10/2026 by Amr Mesbah - split out of model_employee.dart (H17).
/// Created At: 18/10/2026
library;

class AcademicHistoryEntity {
  // ---- Firestore field keys (in-class, SCREAMING_SNAKE_CASE) ----
  static const String kGpa = 'gpa';
  static const String kGraduateFrom = 'graduateFrom';
  static const String kUniversity = 'university';
  static const String kYearOfGraduation = 'yearOfGraduation';
  static const String kGraduateFromStatus = 'graduateFromStatus';
  static const String kUniversityStatus = 'universityStatus';
  static const String kYearOfGraduationStatus = 'yearOfGraduationStatus';
  static const String kGpaStatus = 'gpaStatus';

  final String? gpa;
  final String? graduateFrom;
  final String? university;
  final String? yearOfGraduation;
  final String? graduateFromStatus;
  final String? universityStatus;
  final String? yearOfGraduationStatus;
  final String? gpaStatus;

  AcademicHistoryEntity({
    this.gpa,
    this.graduateFrom,
    this.university,
    this.yearOfGraduation,
    this.graduateFromStatus,
    this.universityStatus,
    this.yearOfGraduationStatus,
    this.gpaStatus,
  });

  factory AcademicHistoryEntity.fromJson(Map<String, dynamic> json) {
    return AcademicHistoryEntity(
      gpa: json[kGpa],
      graduateFrom: json[kGraduateFrom],
      university: json[kUniversity],
      yearOfGraduation: json[kYearOfGraduation],
      graduateFromStatus: json[kGraduateFromStatus],
      universityStatus: json[kUniversityStatus],
      yearOfGraduationStatus: json[kYearOfGraduationStatus],
      gpaStatus: json[kGpaStatus],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      kGpa: gpa,
      kGraduateFrom: graduateFrom,
      kUniversity: university,
      kYearOfGraduation: yearOfGraduation,
      kGraduateFromStatus: graduateFromStatus,
      kUniversityStatus: universityStatus,
      kYearOfGraduationStatus: yearOfGraduationStatus,
      kGpaStatus: gpaStatus,
    };
  }
}
