/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: services_history_keys.dart
/// Purpose: Firestore field names of a ServicesHistoryModel document.
///          Split out of services_history_model.dart (rule "Max 200 lines
///          per model").
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

/// Class Name: [ServicesHistoryKeys]
///
/// Purpose: The document's field names (one constant per field).
abstract final class ServicesHistoryKeys {
  // ---- Firestore field keys ----
  static const String kTimestamps = 'timestamps';
  static const String kId = 'id';
  static const String kState = 'state';
  static const String kStatus = 'status';
  static const String kParentServiceId = 'Parent_Service_Id';
  static const String kFirstNameRequester = 'First_Name_Requester';
  static const String kLastNameRequester = 'Last_Name_Requester';
  static const String kDepartmentRequester = 'Department_Requester';
  static const String kJobTitleRequester = 'Job_Title_Requester';
  static const String kEmailRequester = 'Email_Requester';
  static const String kPhoneRequester = 'Phone_Requester';
  static const String kGenderRequester = 'Gender_Requester';
  static const String kAssignedProviderEmail = 'Assigned_Provider_Email';
  static const String kFirstNameRequesterArabic = 'First_Name_Requester_Arabic';
  static const String kLastNameRequesterArabic = 'Last_Name_Requester_Arabic';
  static const String kJobTitleRequesterArabic = 'Job_Title_Requester_Arabic';
  static const String kDepartmentRequesterArabic =
      'Department_Requester_Arabic';
  static const String kServiceNameEnglish = 'Service_Name_English';
  static const String kServiceNameArabic = 'Service_Name_Arabic';
  static const String kServiceDescriptionEnglish =
      'Service_Description_English';
  static const String kServiceDescriptionArabic = 'Service_Description_Arabic';
  static const String kDurationOfServices = 'Duration_Of_Services';
  static const String kSelectedDurationUnit = 'Selected_Duration_Unit';
  static const String kDurationOfServicesTimestamp =
      'Duration_Of_Services_Timestamp';
  static const String kImageUrl = 'Image_Url';
  static const String kProviderServices = 'Provider_Services';
  static const String kSelectDepartment = 'Select_Department';
  static const String kApprovalCycle = 'Approval_Cycle';
  static const String kLimitAvailability = 'Limit_Availability';
  static const String kRequireApproval = 'Require_Approval';
  static const String kSlaOneControllerEnglish = 'Sla_One_Controller_English';
  static const String kSlaTwoControllerEnglish = 'Sla_Two_Controller_English';
  static const String kNotifyRequesterChecked = 'Notify_Requester_Checked';
  static const String kNotifyProviderChecked = 'Notify_Provider_Checked';
  static const String kNotifyManagerChecked = 'Notify_Manager_Checked';
  static const String kNotifyRequesterSwitch0 = 'Notify_Requester_Switch0';
  static const String kNotifyManagerSwitch1 = 'Notify_Manager_Switch1';

  /// Soft-delete flag (ADDED 25/9/2026). A deleted service keeps its document
  /// so requests made before the delete still resolve its name/duration/image,
  /// but it is hidden from the Services home page and the Service Requests list.
  static const String kIsDeleted = 'Is_Deleted';
  static const String kDeletedAt = 'Deleted_At';
}
