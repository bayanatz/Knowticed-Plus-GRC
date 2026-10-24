/// Module: services / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: requester_info.dart
/// Purpose: The requester's names, job title and department as shown next to
///          a request. Moved out of the presentation folder so the data
///          layer can use it (rule H4); building it from an employee stays in
///          RequestDetailsLookup, which knows the department names.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

/// Requester information as shown on a request.
class RequesterInfo {
  const RequesterInfo({
    this.nameEnglish = '',
    this.nameArabic = '',
    this.departmentEnglish = '',
    this.departmentArabic = '',
    this.jobTitleEnglish = '',
    this.jobTitleArabic = '',
    this.gender = '',
  });

  /// Unknown requester.
  static const RequesterInfo empty = RequesterInfo();

  final String nameEnglish;
  final String nameArabic;
  final String departmentEnglish;
  final String departmentArabic;
  final String jobTitleEnglish;
  final String jobTitleArabic;
  final String gender;
}
