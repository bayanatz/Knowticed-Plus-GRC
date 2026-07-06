// ******************* FILE INFO *******************
// File Name: master_upload_headers
// Description: Expected Excel column headers for the master-upload screens.
// Module: services_management_module / core constants
// *************************************************

/// Expected Excel column headers for the master-upload flow.
///
/// These are data constants (the literal column names that appear in the
/// uploaded spreadsheets, including the Arabic variants), not UI strings — so
/// they live in a constants file rather than being embedded in the page
/// widget (§13 / §15).
class MasterUploadHeaders {
  const MasterUploadHeaders._();

  // Individual column names (used for switch/validation keying).
  static const String serviceNameEn = 'Service Name';
  static const String serviceNameAr = 'اسم الخدمة';
  static const String serviceDescriptionEn = 'Service Description';
  static const String serviceDescriptionAr = 'وصف الخدمة';

  static const List<String> step1ExpectedHeaders = [
    serviceNameEn,
    serviceNameAr,
    serviceDescriptionEn,
    serviceDescriptionAr,
    'Duration of Service',
    'Time Unit',
    'Service Provider',
    'Limit Service Availability',
    'Departments',
    'Requires Approvals',
    'Approvers',
  ];

  static const List<String> step2ExpectedHeaders = [
    'Service Name',
    'Email Requester',
    'Service Provider',
    'Approvers',
    'State',
    'Requested Date',
  ];
}
