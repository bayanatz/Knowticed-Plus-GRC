class ApiConstants {
  // Private constants
  static String baseUri = "";
 // static const String _employeesProfile = "/Employees";
  static const String employeeInfo = "Employees_Info";
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
