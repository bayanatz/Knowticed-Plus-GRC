class ApiConstants {
  // Private constants
  static String baseUri = "";
 // static const String _employeesProfile = "/Employees";
  static const String employeeInfo = "Employees_Info";

  // Raw Firestore collection names (merged from the old
  // core/constants/api_constants.dart). Used directly with getBaseUrl(...).
  // Note: use [departmentDocumentKey] for the raw "Departments" collection name
  // ([departments] is the baseUri-prefixed URL getter).
  static const String employees = "Employees";
  static const String employeesInfo = "Employees_Info";
  static const String _employeesProfileBackUpOne = "Employees Backup One";
  static const String _employeesProfileBackUpTwo = "/Employees Backup Two";
  static const String _employeesDirectory = "/Employees_Directory";
  static const String _departments = "/Departments";
  static const String _departmentDocumentKey = "Departments";
  static const String _insurance = "/Insurance";
  static const String _emergencyContacts = "/Emergency Contacts";
  static const String _roles = "/Roles";
  static const String _userAccess = "/Users Access";
  static const String _rolesNames = "/Access Types";
  static const String _roleImages = "/role_images";
  static const String _wrongEmployees = "/Wrong Employees";
  static const String _demoRequests = 'Demo_Requests';
  static const String _demoUsersAccounts = 'Demo_Users_Accounts';
  static const String _company = "/Companys";
  static const String _department = "/Departments";
  static const String _systemLogs = "System Logs";
  static const String _homeLayout = "/Home Layout";
  // Public getters
  static String get employeesProfile => '$baseUri/$employeeInfo';
  static String get employeesProfileBackUpOne =>
      '$baseUri/$_employeesProfileBackUpOne';
  static String get employeesProfileBackUpTwo =>
      '$baseUri$_employeesProfileBackUpTwo';
  static String get employeesDirectory => '$baseUri$_employeesDirectory';
  static String get departments => '$baseUri$_departments';
  static String get departmentDocumentKey =>
      _departmentDocumentKey; // Document key doesn't need URI prefix
  static String get insurance => '$baseUri$_insurance';
  static String get emergencyContacts => '$baseUri$_emergencyContacts';
  static String get roles => '$baseUri$_roles';
  static String get userAccess => '$baseUri$_userAccess';
  static String get rolesNames => '$baseUri$_rolesNames';
  static String get roleImages => '$baseUri$_roleImages';
  static String get wrongEmployees => '$baseUri$_wrongEmployees';
  static String get demoRequests => '$_demoRequests';
  static String get demoUsersAccounts => '$_demoUsersAccounts';
  static String get company => '$baseUri$_company';
  static String get systemLogs => '$baseUri/$_systemLogs';
  static String get homeLayout => '$baseUri$_homeLayout';
}

/// Central catalogue of Firestore collection / subcollection names.
/// Use these constants instead of hardcoding collection strings in the codebase
/// (CR-KP-SET §15 / R-06). Merged here from the old
/// core/constants/firebase_collections.dart.
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
  /// (`Demo/{companyId}/Modules/services/RequestServices`).
  static const String requestServices = 'RequestServices';

  /// Notifications subcollection under a tenant doc
  /// (`Demo/{companyId}/Notifications`).
  static const String notifications = 'Notifications';

  /// Top-level employees collection (lowercase legacy key).
  static const String employees = 'employees';

  /// Top-level departments collection (lowercase legacy key).
  static const String departments = 'departments';

  /// Knowledge documents subcollection key (used with getBaseUrl).
  static const String createKnowledge = 'Create_Knowledge';
}

/// Firestore collection names, merged here from the old
/// core/constants/constant.dart.
class FirestoreCollections {
  // Bare collection names. Keep these for NESTED subcollection references
  // (e.g. CreateServices/{doc}/RequestServices) which must NOT be moved.
  static const createServices = "CreateServices";
   static const requestServices = "RequestServices";

  // Top-level (tenant root) service collections now live under Modules/services.
  // Use these ONLY with getBaseUrl(...) which prepends "Demo/{companyId}".
  // Resolves to: Demo/{companyId}/Modules/services/CreateServices
  static const createServicesRoot = "Modules/services/CreateServices";
  // Resolves to: Demo/{companyId}/Modules/services/RequestServices
  static const requestServicesRoot = "Modules/services/RequestServices";
  // static const allServices = "myCreateRequests";
  static const accessEmployee = "User_Management";
  static const employeeInfo = "Employees_Info";
  static const services = "Services";
  static const requestedServices = "RequestedServices";
  static const users = "users";
}



//class FirestoreCollections {
//   static const createServices = "Create Services";
//   static const requestServices = "Request Services";
//   static const allServices = "My Create Requests";
// }// }

/// SLA notification keys, merged here from the old
/// s12_create_notification_mobile/constants/sla_notification_keys.dart.
/// Canonical keys for the three SLA notification toggles. These are used as
/// map keys and SharedPreferences keys (the persisted contract), so the string
/// values must never change — they are centralised here to remove magic-string
/// literals from widgets (§15).
class SlaNotificationKeys {
  const SlaNotificationKeys._();

  static const String serviceRequester = 'Notify Service Requester';
  static const String serviceProvider = 'Notify Service Provider';
  static const String providerManager = 'Notify Provider Manager';
}
