/// Module: Core · Constants · Firebase Collections
/// Description: Central catalogue of Firestore collection / subcollection names.
///              Use these constants instead of hardcoding collection strings in
///              the codebase (CR-KP-SET §15 / R-06).
/// Author: Amr Mesbah
/// Date: 26/06/2026
/// Dependencies: none
/// Revision History:
///   - 26/06/2026 (Amr Mesbah): Initial creation.
library;

abstract class FirebaseCollections {
  /// Employee change-request subcollection.
  static const String employeesRequest = 'Employees_Request';

  /// Employee info collection/subcollection.
  static const String employeesInfo = 'Employees_Info';

  /// Company data collection.
  static const String companyData = 'Company_Data';

  /// Document templates subcollection (about / privacy / terms).
  static const String templates = 'templates';

  /// Root tenant collection (legacy name kept for compatibility with
  /// existing documents — companies are stored as docs under this
  /// top-level collection, keyed by company id).
  static const String demo = 'Demo';

  /// Request-services subcollection under a tenant doc
  /// (`Demo/{companyId}/RequestServices`).
  static const String requestServices = 'RequestServices';
}
