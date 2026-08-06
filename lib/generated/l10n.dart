// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `th`
  String get th {
    return Intl.message('th', name: 'th', desc: '', args: []);
  }

  /// `3rd`
  String get k3rd {
    return Intl.message('3rd', name: 'k3rd', desc: '', args: []);
  }

  /// `2nd`
  String get k2nd {
    return Intl.message('2nd', name: 'k2nd', desc: '', args: []);
  }

  /// `1st`
  String get k1st {
    return Intl.message('1st', name: 'k1st', desc: '', args: []);
  }

  /// `You cannot add an option that already exists`
  String get youCannotAddAnOptionThatAlreadyExists {
    return Intl.message(
      'You cannot add an option that already exists',
      name: 'youCannotAddAnOptionThatAlreadyExists',
      desc: '',
      args: [],
    );
  }

  /// `UnAggregated`
  String get unaggregated {
    return Intl.message(
      'UnAggregated',
      name: 'unaggregated',
      desc: '',
      args: [],
    );
  }

  /// `timeMinutes`
  String get timeminutes {
    return Intl.message('timeMinutes', name: 'timeminutes', desc: '', args: []);
  }

  /// `Tabulated`
  String get tabulated {
    return Intl.message('Tabulated', name: 'tabulated', desc: '', args: []);
  }

  /// `Saved Colors`
  String get savedColors {
    return Intl.message(
      'Saved Colors',
      name: 'savedColors',
      desc: '',
      args: [],
    );
  }

  /// `Requested Form`
  String get requestedForm {
    return Intl.message(
      'Requested Form',
      name: 'requestedForm',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter The valid Phone Number`
  String get pleaseEnterTheValidPhoneNumber {
    return Intl.message(
      'Please Enter The valid Phone Number',
      name: 'pleaseEnterTheValidPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter The valid Email`
  String get pleaseEnterTheValidEmail {
    return Intl.message(
      'Please Enter The valid Email',
      name: 'pleaseEnterTheValidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter The Text In English Language`
  String get pleaseEnterTheTextInEnglishLanguage {
    return Intl.message(
      'Please Enter The Text In English Language',
      name: 'pleaseEnterTheTextInEnglishLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter The Text In Arabic Language`
  String get pleaseEnterTheTextInArabicLanguage {
    return Intl.message(
      'Please Enter The Text In Arabic Language',
      name: 'pleaseEnterTheTextInArabicLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Please enter numbers only more then 0`
  String get pleaseEnterNumbersOnlyMoreThen0 {
    return Intl.message(
      'Please enter numbers only more then 0',
      name: 'pleaseEnterNumbersOnlyMoreThen0',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid link`
  String get pleaseEnterAValidLink {
    return Intl.message(
      'Please enter a valid link',
      name: 'pleaseEnterAValidLink',
      desc: '',
      args: [],
    );
  }

  /// `Month`
  String get month2 {
    return Intl.message('Month', name: 'month2', desc: '', args: []);
  }

  /// `Longitude invalid.`
  String get longitudeInvalid {
    return Intl.message(
      'Longitude invalid.',
      name: 'longitudeInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Link invalid`
  String get linkInvalid {
    return Intl.message(
      'Link invalid',
      name: 'linkInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Latitude invalid.`
  String get latitudeInvalid {
    return Intl.message(
      'Latitude invalid.',
      name: 'latitudeInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Document Details`
  String get documentDetails {
    return Intl.message(
      'Document Details',
      name: 'documentDetails',
      desc: '',
      args: [],
    );
  }

  /// `Click`
  String get click {
    return Intl.message('Click', name: 'click', desc: '', args: []);
  }

  /// `UnTabulated`
  String get untabulated {
    return Intl.message('UnTabulated', name: 'untabulated', desc: '', args: []);
  }

  /// `Aggregated`
  String get aggregated {
    return Intl.message('Aggregated', name: 'aggregated', desc: '', args: []);
  }

  /// `Total: `
  String get total2 {
    return Intl.message('Total: ', name: 'total2', desc: '', args: []);
  }

  /// `Total Response: `
  String get totalResponse {
    return Intl.message(
      'Total Response: ',
      name: 'totalResponse',
      desc: '',
      args: [],
    );
  }

  /// `No Group Found`
  String get noGroupFound {
    return Intl.message(
      'No Group Found',
      name: 'noGroupFound',
      desc: '',
      args: [],
    );
  }

  /// `Message Form Owner`
  String get messageFormOwner {
    return Intl.message(
      'Message Form Owner',
      name: 'messageFormOwner',
      desc: '',
      args: [],
    );
  }

  /// `Building / Apartment`
  String get buildingApartment {
    return Intl.message(
      'Building / Apartment',
      name: 'buildingApartment',
      desc: '',
      args: [],
    );
  }

  /// `Not Accepted`
  String get notAccepted {
    return Intl.message(
      'Not Accepted',
      name: 'notAccepted',
      desc: '',
      args: [],
    );
  }

  /// `Accepted`
  String get accepted {
    return Intl.message('Accepted', name: 'accepted', desc: '', args: []);
  }

  /// `Draft saved successfully!`
  String get draftSavedSuccessfully {
    return Intl.message(
      'Draft saved successfully!',
      name: 'draftSavedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Edit File Name`
  String get editFileName {
    return Intl.message(
      'Edit File Name',
      name: 'editFileName',
      desc: '',
      args: [],
    );
  }

  /// `Error loading services`
  String get errorLoadingServices {
    return Intl.message(
      'Error loading services',
      name: 'errorLoadingServices',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create service request. Please try again.`
  String get failedToCreateServiceRequest {
    return Intl.message(
      'Failed to create service request. Please try again.',
      name: 'failedToCreateServiceRequest',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load service data`
  String get failedToLoadServiceData {
    return Intl.message(
      'Failed to load service data',
      name: 'failedToLoadServiceData',
      desc: '',
      args: [],
    );
  }

  /// `Load more`
  String get loadMore {
    return Intl.message('Load more', name: 'loadMore', desc: '', args: []);
  }

  /// `No more results`
  String get noMoreResults {
    return Intl.message(
      'No more results',
      name: 'noMoreResults',
      desc: '',
      args: [],
    );
  }

  /// `No results`
  String get noResults {
    return Intl.message('No results', name: 'noResults', desc: '', args: []);
  }

  /// `No services found`
  String get noServicesFound {
    return Intl.message(
      'No services found',
      name: 'noServicesFound',
      desc: '',
      args: [],
    );
  }

  /// `Processing file...`
  String get processingFile {
    return Intl.message(
      'Processing file...',
      name: 'processingFile',
      desc: '',
      args: [],
    );
  }

  /// `Redirecting...`
  String get redirecting {
    return Intl.message(
      'Redirecting...',
      name: 'redirecting',
      desc: '',
      args: [],
    );
  }

  /// `Step 2: Service Requests`
  String get step2ServiceRequests {
    return Intl.message(
      'Step 2: Service Requests',
      name: 'step2ServiceRequests',
      desc: '',
      args: [],
    );
  }

  /// `This request has no assigned provider`
  String get requestHasNoAssignedProvider {
    return Intl.message(
      'This request has no assigned provider',
      name: 'requestHasNoAssignedProvider',
      desc: '',
      args: [],
    );
  }

  /// `App Theme`
  String get appTheme {
    return Intl.message('App Theme', name: 'appTheme', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Service Department Manager`
  String get ServiceDepartmentManager {
    return Intl.message(
      'Service Department Manager',
      name: 'ServiceDepartmentManager',
      desc: '',
      args: [],
    );
  }

  /// `Admin Services`
  String get ServiceADMIN {
    return Intl.message(
      'Admin Services',
      name: 'ServiceADMIN',
      desc: '',
      args: [],
    );
  }

  /// `Employee Services`
  String get ServiceEmployee {
    return Intl.message(
      'Employee Services',
      name: 'ServiceEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Approval Cycle`
  String get approvalCycle {
    return Intl.message(
      'Approval Cycle',
      name: 'approvalCycle',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `Active`
  String get active {
    return Intl.message('Active', name: 'active', desc: '', args: []);
  }

  /// `Inactive`
  String get inactive {
    return Intl.message('Inactive', name: 'inactive', desc: '', args: []);
  }

  /// `Draft`
  String get draft {
    return Intl.message('Draft', name: 'draft', desc: '', args: []);
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message('Dashboard', name: 'dashboard', desc: '', args: []);
  }

  /// `Approvals`
  String get approvals {
    return Intl.message('Approvals', name: 'approvals', desc: '', args: []);
  }

  /// `Service Requests`
  String get serviceRequests {
    return Intl.message(
      'Service Requests',
      name: 'serviceRequests',
      desc: '',
      args: [],
    );
  }

  /// `Create Service`
  String get createService {
    return Intl.message(
      'Create Service',
      name: 'createService',
      desc: '',
      args: [],
    );
  }

  /// `Export`
  String get export {
    return Intl.message('Export', name: 'export', desc: '', args: []);
  }

  /// `Services`
  String get services {
    return Intl.message('Services', name: 'services', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Done Services`
  String get doneServices {
    return Intl.message(
      'Done Services',
      name: 'doneServices',
      desc: '',
      args: [],
    );
  }

  /// `Start Date`
  String get startDate {
    return Intl.message('Start Date', name: 'startDate', desc: '', args: []);
  }

  /// `Duration`
  String get duration {
    return Intl.message('Duration', name: 'duration', desc: '', args: []);
  }

  /// `Add Service`
  String get addService {
    return Intl.message('Add Service', name: 'addService', desc: '', args: []);
  }

  /// `Bulk Upload`
  String get bulkUpload {
    return Intl.message('Bulk Upload', name: 'bulkUpload', desc: '', args: []);
  }

  /// `Browse Files`
  String get browseFiles {
    return Intl.message(
      'Browse Files',
      name: 'browseFiles',
      desc: '',
      args: [],
    );
  }

  /// `Discard`
  String get discard {
    return Intl.message('Discard', name: 'discard', desc: '', args: []);
  }

  /// `Drag and drop files here`
  String get dragDropFilesHere {
    return Intl.message(
      'Drag and drop files here',
      name: 'dragDropFilesHere',
      desc: '',
      args: [],
    );
  }

  /// `Service`
  String get service {
    return Intl.message('Service', name: 'service', desc: '', args: []);
  }

  /// `Duration of Service`
  String get durationOfService {
    return Intl.message(
      'Duration of Service',
      name: 'durationOfService',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Hours`
  String get hours {
    return Intl.message('Hours', name: 'hours', desc: '', args: []);
  }

  /// `Minutes`
  String get minutes {
    return Intl.message('Minutes', name: 'minutes', desc: '', args: []);
  }

  /// `Seconds`
  String get seconds {
    return Intl.message('Seconds', name: 'seconds', desc: '', args: []);
  }

  /// `Weeks`
  String get week {
    return Intl.message('Weeks', name: 'week', desc: '', args: []);
  }

  /// `Creating New Service`
  String get creatingNewService {
    return Intl.message(
      'Creating New Service',
      name: 'creatingNewService',
      desc: '',
      args: [],
    );
  }

  /// `Save For Later`
  String get saveForLater {
    return Intl.message(
      'Save For Later',
      name: 'saveForLater',
      desc: '',
      args: [],
    );
  }

  /// `Service Provider`
  String get serviceProvider {
    return Intl.message(
      'Service Provider',
      name: 'serviceProvider',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Job Title`
  String get jobTitle {
    return Intl.message('Job Title', name: 'jobTitle', desc: '', args: []);
  }

  /// `Service Description`
  String get serviceDescription {
    return Intl.message(
      'Service Description',
      name: 'serviceDescription',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Service Details`
  String get serviceDetails {
    return Intl.message(
      'Service Details',
      name: 'serviceDetails',
      desc: '',
      args: [],
    );
  }

  /// `Limit Service Availability`
  String get limitServiceAvailability {
    return Intl.message(
      'Limit Service Availability',
      name: 'limitServiceAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Requires Approvals`
  String get requiresApprovals {
    return Intl.message(
      'Requires Approvals',
      name: 'requiresApprovals',
      desc: '',
      args: [],
    );
  }

  /// `Add Approvals`
  String get addApprovals {
    return Intl.message(
      'Add Approvals',
      name: 'addApprovals',
      desc: '',
      args: [],
    );
  }

  /// `Department`
  String get department {
    return Intl.message('Department', name: 'department', desc: '', args: []);
  }

  /// `Notify Service Requester`
  String get notifyServiceRequester {
    return Intl.message(
      'Notify Service Requester',
      name: 'notifyServiceRequester',
      desc: '',
      args: [],
    );
  }

  /// `When Their Manager Approves The Service, If It Requires Approvals`
  String get whenManagerApprovesServiceIfRequired {
    return Intl.message(
      'When Their Manager Approves The Service, If It Requires Approvals',
      name: 'whenManagerApprovesServiceIfRequired',
      desc: '',
      args: [],
    );
  }

  /// `When Service Status Change`
  String get whenServiceStattusChanges {
    return Intl.message(
      'When Service Status Change',
      name: 'whenServiceStattusChanges',
      desc: '',
      args: [],
    );
  }

  /// `When Service Status Changes`
  String get whenServiceStatusChanges {
    return Intl.message(
      'When Service Status Changes',
      name: 'whenServiceStatusChanges',
      desc: '',
      args: [],
    );
  }

  /// `When They Receive A Comment From The Service Provider`
  String get whenTheyReceiveCommentFromServiceProvider {
    return Intl.message(
      'When They Receive A Comment From The Service Provider',
      name: 'whenTheyReceiveCommentFromServiceProvider',
      desc: '',
      args: [],
    );
  }

  /// `When SLA Is Breached`
  String get whenSlaIsBreached {
    return Intl.message(
      'When SLA Is Breached',
      name: 'whenSlaIsBreached',
      desc: '',
      args: [],
    );
  }

  /// `Notify Service Provider`
  String get notifyServiceProvider {
    return Intl.message(
      'Notify Service Provider',
      name: 'notifyServiceProvider',
      desc: '',
      args: [],
    );
  }

  /// `When Service Is Requested And Approved By The Requester’s Manager If It Requires Approval`
  String get whenServiceRequestedAndApprovedIfRequired {
    return Intl.message(
      'When Service Is Requested And Approved By The Requester’s Manager If It Requires Approval',
      name: 'whenServiceRequestedAndApprovedIfRequired',
      desc: '',
      args: [],
    );
  }

  /// `When Services Is Requested And Approved By The Requester’s Manager If It Requires Approval`
  String get whenServicesRequestedAndApprovedIfRequired {
    return Intl.message(
      'When Services Is Requested And Approved By The Requester’s Manager If It Requires Approval',
      name: 'whenServicesRequestedAndApprovedIfRequired',
      desc: '',
      args: [],
    );
  }

  /// `When They Receive A Comment From Service Requester`
  String get whenTheyReceiveCommentFromRequester {
    return Intl.message(
      'When They Receive A Comment From Service Requester',
      name: 'whenTheyReceiveCommentFromRequester',
      desc: '',
      args: [],
    );
  }

  /// `When Service SLA Is Breached`
  String get whenServiceSlaIsBreached {
    return Intl.message(
      'When Service SLA Is Breached',
      name: 'whenServiceSlaIsBreached',
      desc: '',
      args: [],
    );
  }

  /// `When Service SLA Is About To Be Breached By`
  String get whenServiceSlaIsAboutToBeBreached {
    return Intl.message(
      'When Service SLA Is About To Be Breached By',
      name: 'whenServiceSlaIsAboutToBeBreached',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Notify Provider Manager`
  String get notifyProviderManager {
    return Intl.message(
      'Notify Provider Manager',
      name: 'notifyProviderManager',
      desc: '',
      args: [],
    );
  }

  /// `When Service Provider Breached SLA`
  String get whenProviderBreachedSla {
    return Intl.message(
      'When Service Provider Breached SLA',
      name: 'whenProviderBreachedSla',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `Creating Service`
  String get creatingService {
    return Intl.message(
      'Creating Service',
      name: 'creatingService',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Service?`
  String get areYouSureCreateService {
    return Intl.message(
      'Are You Sure You Want To Create This Service?',
      name: 'areYouSureCreateService',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `Service Requested`
  String get serviceRequested {
    return Intl.message(
      'Service Requested',
      name: 'serviceRequested',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created This Service`
  String get successfullyCreatedService {
    return Intl.message(
      'You Successfully Created This Service',
      name: 'successfullyCreatedService',
      desc: '',
      args: [],
    );
  }

  /// `Service Provider`
  String get ServiceProvider {
    return Intl.message(
      'Service Provider',
      name: 'ServiceProvider',
      desc: '',
      args: [],
    );
  }

  /// `Job Title`
  String get JobTitle {
    return Intl.message('Job Title', name: 'JobTitle', desc: '', args: []);
  }

  /// `Approval`
  String get Approval {
    return Intl.message('Approval', name: 'Approval', desc: '', args: []);
  }

  /// `Hours`
  String get duration_unit_hours {
    return Intl.message(
      'Hours',
      name: 'duration_unit_hours',
      desc: '',
      args: [],
    );
  }

  /// `Minutes`
  String get duration_unit_minutes {
    return Intl.message(
      'Minutes',
      name: 'duration_unit_minutes',
      desc: '',
      args: [],
    );
  }

  /// `Seconds`
  String get duration_unit_seconds {
    return Intl.message(
      'Seconds',
      name: 'duration_unit_seconds',
      desc: '',
      args: [],
    );
  }

  /// `Week`
  String get duration_unit_week {
    return Intl.message('Week', name: 'duration_unit_week', desc: '', args: []);
  }

  /// `Requests`
  String get requests {
    return Intl.message('Requests', name: 'requests', desc: '', args: []);
  }

  /// `My Requests`
  String get myRequests {
    return Intl.message('My Requests', name: 'myRequests', desc: '', args: []);
  }

  /// `Marketing`
  String get department_marketing {
    return Intl.message(
      'Marketing',
      name: 'department_marketing',
      desc: '',
      args: [],
    );
  }

  /// `Sales`
  String get department_sales {
    return Intl.message('Sales', name: 'department_sales', desc: '', args: []);
  }

  /// `HR`
  String get department_hr {
    return Intl.message('HR', name: 'department_hr', desc: '', args: []);
  }

  /// `Executive`
  String get department_executive {
    return Intl.message(
      'Executive',
      name: 'department_executive',
      desc: '',
      args: [],
    );
  }

  /// `Customer Support`
  String get department_customer_support {
    return Intl.message(
      'Customer Support',
      name: 'department_customer_support',
      desc: '',
      args: [],
    );
  }

  /// `Operations`
  String get department_operations {
    return Intl.message(
      'Operations',
      name: 'department_operations',
      desc: '',
      args: [],
    );
  }

  /// `Finance`
  String get department_finance {
    return Intl.message(
      'Finance',
      name: 'department_finance',
      desc: '',
      args: [],
    );
  }

  /// `Information Technology`
  String get department_it {
    return Intl.message(
      'Information Technology',
      name: 'department_it',
      desc: '',
      args: [],
    );
  }

  /// `Human Resources`
  String get department_human_resources {
    return Intl.message(
      'Human Resources',
      name: 'department_human_resources',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get status_pending {
    return Intl.message('Pending', name: 'status_pending', desc: '', args: []);
  }

  /// `Approved`
  String get status_approved {
    return Intl.message(
      'Approved',
      name: 'status_approved',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get status_done {
    return Intl.message('Done', name: 'status_done', desc: '', args: []);
  }

  /// `Rejected`
  String get status_rejected {
    return Intl.message(
      'Rejected',
      name: 'status_rejected',
      desc: '',
      args: [],
    );
  }

  /// `Canceled`
  String get status_cancel {
    return Intl.message('Canceled', name: 'status_cancel', desc: '', args: []);
  }

  /// `Last Update`
  String get lastUpdate {
    return Intl.message('Last Update', name: 'lastUpdate', desc: '', args: []);
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `In progress`
  String get status_inprogress {
    return Intl.message(
      'In progress',
      name: 'status_inprogress',
      desc: '',
      args: [],
    );
  }

  /// `Breached SLA`
  String get status_breached {
    return Intl.message(
      'Breached SLA',
      name: 'status_breached',
      desc: '',
      args: [],
    );
  }

  /// `Service Description`
  String get ServiceDescription {
    return Intl.message(
      'Service Description',
      name: 'ServiceDescription',
      desc: '',
      args: [],
    );
  }

  /// `Offered Date`
  String get OfferedDate {
    return Intl.message(
      'Offered Date',
      name: 'OfferedDate',
      desc: '',
      args: [],
    );
  }

  /// `Duration of Service`
  String get DurationofService {
    return Intl.message(
      'Duration of Service',
      name: 'DurationofService',
      desc: '',
      args: [],
    );
  }

  /// `Breached SLA`
  String get BreachedSLA {
    return Intl.message(
      'Breached SLA',
      name: 'BreachedSLA',
      desc: '',
      args: [],
    );
  }

  /// `In progress`
  String get Inprogress {
    return Intl.message('In progress', name: 'Inprogress', desc: '', args: []);
  }

  /// `Canceled`
  String get Canceled {
    return Intl.message('Canceled', name: 'Canceled', desc: '', args: []);
  }

  /// `Pending`
  String get Pending {
    return Intl.message('Pending', name: 'Pending', desc: '', args: []);
  }

  /// `Done Services`
  String get DoneServices {
    return Intl.message(
      'Done Services',
      name: 'DoneServices',
      desc: '',
      args: [],
    );
  }

  /// `Employees`
  String get Employees {
    return Intl.message('Employees', name: 'Employees', desc: '', args: []);
  }

  /// `Requested Services`
  String get RequestedServices {
    return Intl.message(
      'Requested Services',
      name: 'RequestedServices',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get Filter {
    return Intl.message('Filter', name: 'Filter', desc: '', args: []);
  }

  /// `NO`
  String get NO {
    return Intl.message('NO', name: 'NO', desc: '', args: []);
  }

  /// `Department`
  String get Department {
    return Intl.message('Department', name: 'Department', desc: '', args: []);
  }

  /// `Service Requestor`
  String get ServiceRequestor {
    return Intl.message(
      'Service Requestor',
      name: 'ServiceRequestor',
      desc: '',
      args: [],
    );
  }

  /// `Request Date`
  String get RequestDate {
    return Intl.message(
      'Request Date',
      name: 'RequestDate',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get Status {
    return Intl.message('Status', name: 'Status', desc: '', args: []);
  }

  /// `Service Name Details`
  String get ServiceNameDetails {
    return Intl.message(
      'Service Name Details',
      name: 'ServiceNameDetails',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get Edit {
    return Intl.message('Edit', name: 'Edit', desc: '', args: []);
  }

  /// `Delete`
  String get Delete {
    return Intl.message('Delete', name: 'Delete', desc: '', args: []);
  }

  /// `Editing Service Name`
  String get EditingerviceName {
    return Intl.message(
      'Editing Service Name',
      name: 'EditingerviceName',
      desc: '',
      args: [],
    );
  }

  /// `The Name of Request`
  String get TheNameOfRequest {
    return Intl.message(
      'The Name of Request',
      name: 'TheNameOfRequest',
      desc: '',
      args: [],
    );
  }

  /// `Service Requests`
  String get ServiceRequests {
    return Intl.message(
      'Service Requests',
      name: 'ServiceRequests',
      desc: '',
      args: [],
    );
  }

  /// `Request Service`
  String get RequestService {
    return Intl.message(
      'Request Service',
      name: 'RequestService',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to request this service?`
  String get AreYouSureYouWantToRequestThisService {
    return Intl.message(
      'Are you sure you want to request this service?',
      name: 'AreYouSureYouWantToRequestThisService',
      desc: '',
      args: [],
    );
  }

  /// `Service Requested`
  String get ServiceRequested {
    return Intl.message(
      'Service Requested',
      name: 'ServiceRequested',
      desc: '',
      args: [],
    );
  }

  /// `You successfully requested this service`
  String get YouSuccessfullyRequestedThisService {
    return Intl.message(
      'You successfully requested this service',
      name: 'YouSuccessfullyRequestedThisService',
      desc: '',
      args: [],
    );
  }

  /// `Approved`
  String get Approved {
    return Intl.message('Approved', name: 'Approved', desc: '', args: []);
  }

  /// `Done`
  String get Done {
    return Intl.message('Done', name: 'Done', desc: '', args: []);
  }

  /// `Date Requested`
  String get DateRequested {
    return Intl.message(
      'Date Requested',
      name: 'DateRequested',
      desc: '',
      args: [],
    );
  }

  /// `Point of Contact`
  String get PointofContact {
    return Intl.message(
      'Point of Contact',
      name: 'PointofContact',
      desc: '',
      args: [],
    );
  }

  /// `Last update`
  String get Lastupdate {
    return Intl.message('Last update', name: 'Lastupdate', desc: '', args: []);
  }

  /// `Service Name`
  String get ServiceName {
    return Intl.message(
      'Service Name',
      name: 'ServiceName',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get Cancel {
    return Intl.message('Cancel', name: 'Cancel', desc: '', args: []);
  }

  /// `Send Reminder`
  String get SendReminder {
    return Intl.message(
      'Send Reminder',
      name: 'SendReminder',
      desc: '',
      args: [],
    );
  }

  /// `Expand`
  String get Expand {
    return Intl.message('Expand', name: 'Expand', desc: '', args: []);
  }

  /// `Hide`
  String get Hide {
    return Intl.message('Hide', name: 'Hide', desc: '', args: []);
  }

  /// `Inquiries and Comments`
  String get InquiriesAndComments {
    return Intl.message(
      'Inquiries and Comments',
      name: 'InquiriesAndComments',
      desc: '',
      args: [],
    );
  }

  /// `Rejected`
  String get Rejected {
    return Intl.message('Rejected', name: 'Rejected', desc: '', args: []);
  }

  /// `Are you sure you want to delete this message?`
  String get AreYousureYouWanttoDeleteThisMessage {
    return Intl.message(
      'Are you sure you want to delete this message?',
      name: 'AreYousureYouWanttoDeleteThisMessage',
      desc: '',
      args: [],
    );
  }

  /// `Delete Message`
  String get DeleteMessage {
    return Intl.message(
      'Delete Message',
      name: 'DeleteMessage',
      desc: '',
      args: [],
    );
  }

  /// `Justifications`
  String get Justifications {
    return Intl.message(
      'Justifications',
      name: 'Justifications',
      desc: '',
      args: [],
    );
  }

  /// `You successfully canceled this request`
  String get YouSuccessfullyCanceledThisRequest {
    return Intl.message(
      'You successfully canceled this request',
      name: 'YouSuccessfullyCanceledThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Request`
  String get CancelRequest {
    return Intl.message(
      'Cancel Request',
      name: 'CancelRequest',
      desc: '',
      args: [],
    );
  }

  /// `Text Here`
  String get Texthere {
    return Intl.message('Text Here', name: 'Texthere', desc: '', args: []);
  }

  /// `Reason of Cancellation`
  String get ReasonOfCancelation {
    return Intl.message(
      'Reason of Cancellation',
      name: 'ReasonOfCancelation',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel this request?`
  String get AreYousureYouWanttoCancelThisRequest {
    return Intl.message(
      'Are you sure you want to cancel this request?',
      name: 'AreYousureYouWanttoCancelThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `Write a Comment`
  String get WriteaComment {
    return Intl.message(
      'Write a Comment',
      name: 'WriteaComment',
      desc: '',
      args: [],
    );
  }

  /// `Requested Date`
  String get RequestedDate {
    return Intl.message(
      'Requested Date',
      name: 'RequestedDate',
      desc: '',
      args: [],
    );
  }

  /// `Sort`
  String get Sort {
    return Intl.message('Sort', name: 'Sort', desc: '', args: []);
  }

  /// `Requested by`
  String get Requestedby {
    return Intl.message(
      'Requested by',
      name: 'Requestedby',
      desc: '',
      args: [],
    );
  }

  /// `Reject`
  String get Reject {
    return Intl.message('Reject', name: 'Reject', desc: '', args: []);
  }

  /// `Approve Request`
  String get ApproveRequest {
    return Intl.message(
      'Approve Request',
      name: 'ApproveRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to approve this request?`
  String get AreYouSureYouWantToApproveThisRequest {
    return Intl.message(
      'Are you sure you want to approve this request?',
      name: 'AreYouSureYouWantToApproveThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `You successfully approved this request`
  String get YouSuccessfullyApprovedThisRequest {
    return Intl.message(
      'You successfully approved this request',
      name: 'YouSuccessfullyApprovedThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `Reject Request`
  String get RejectRequest {
    return Intl.message(
      'Reject Request',
      name: 'RejectRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to reject this request?`
  String get AreYouSureYouWantToRejectThisRequest {
    return Intl.message(
      'Are you sure you want to reject this request?',
      name: 'AreYouSureYouWantToRejectThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `Reason of Rejection`
  String get ReasonOfRejection {
    return Intl.message(
      'Reason of Rejection',
      name: 'ReasonOfRejection',
      desc: '',
      args: [],
    );
  }

  /// `Successful`
  String get Successful {
    return Intl.message('Successful', name: 'Successful', desc: '', args: []);
  }

  /// `Phone`
  String get phone {
    return Intl.message('Phone', name: 'phone', desc: '', args: []);
  }

  /// `You successfully rejected this request`
  String get YouSuccessfullyRejectedThisRequest {
    return Intl.message(
      'You successfully rejected this request',
      name: 'YouSuccessfullyRejectedThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `Service Fulfillment`
  String get ServiceFulfillment {
    return Intl.message(
      'Service Fulfillment',
      name: 'ServiceFulfillment',
      desc: '',
      args: [],
    );
  }

  /// `Send Notifications`
  String get SendNotifications {
    return Intl.message(
      'Send Notifications',
      name: 'SendNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Percentage`
  String get EnterPercentage {
    return Intl.message(
      'Percentage',
      name: 'EnterPercentage',
      desc: '',
      args: [],
    );
  }

  /// `Only numbers are allowed.`
  String get Onlynumbersareallowed {
    return Intl.message(
      'Only numbers are allowed.',
      name: 'Onlynumbersareallowed',
      desc: '',
      args: [],
    );
  }

  /// `Approve`
  String get Approve {
    return Intl.message('Approve', name: 'Approve', desc: '', args: []);
  }

  /// `No provider data found.`
  String get Noproviderdatafound {
    return Intl.message(
      'No provider data found.',
      name: 'Noproviderdatafound',
      desc: '',
      args: [],
    );
  }

  /// `Requester Details`
  String get RequesterDetails {
    return Intl.message(
      'Requester Details',
      name: 'RequesterDetails',
      desc: '',
      args: [],
    );
  }

  /// `Reason of Approval`
  String get ReasonOfApprove {
    return Intl.message(
      'Reason of Approval',
      name: 'ReasonOfApprove',
      desc: '',
      args: [],
    );
  }

  /// `Total Hours`
  String get TotalHours {
    return Intl.message('Total Hours', name: 'TotalHours', desc: '', args: []);
  }

  /// `Service Requester`
  String get serviceRequester {
    return Intl.message(
      'Service Requester',
      name: 'serviceRequester',
      desc: '',
      args: [],
    );
  }

  /// `Please select at least one employee.`
  String get Pleaseselectatleastoneemployee {
    return Intl.message(
      'Please select at least one employee.',
      name: 'Pleaseselectatleastoneemployee',
      desc: '',
      args: [],
    );
  }

  /// `Employee Information`
  String get EmployeeInformation {
    return Intl.message(
      'Employee Information',
      name: 'EmployeeInformation',
      desc: '',
      args: [],
    );
  }

  /// `Fourth`
  String get Fourth {
    return Intl.message('Fourth', name: 'Fourth', desc: '', args: []);
  }

  /// `Third`
  String get Third {
    return Intl.message('Third', name: 'Third', desc: '', args: []);
  }

  /// `Second`
  String get Second {
    return Intl.message('Second', name: 'Second', desc: '', args: []);
  }

  /// `First`
  String get First {
    return Intl.message('First', name: 'First', desc: '', args: []);
  }

  /// `Service Provider Details`
  String get ServiceProviderDetails {
    return Intl.message(
      'Service Provider Details',
      name: 'ServiceProviderDetails',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created This Service`
  String get YouSuccessfullyCreatedThisService {
    return Intl.message(
      'You Successfully Created This Service',
      name: 'YouSuccessfullyCreatedThisService',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited This Service`
  String get YouSuccessfullyEditedThisService {
    return Intl.message(
      'You Successfully Edited This Service',
      name: 'YouSuccessfullyEditedThisService',
      desc: '',
      args: [],
    );
  }

  /// `When Manager Approves The Service,If It Requires Approvals`
  String get WhenTheirManagerApprovesTheService {
    return Intl.message(
      'When Manager Approves The Service,If It Requires Approvals',
      name: 'WhenTheirManagerApprovesTheService',
      desc: '',
      args: [],
    );
  }

  /// `When Service Is Requested And Approved By \nThe Requester’s Manager If It Requires Approval`
  String get WhenServiceIsRequestedAndApprovedByTheRequester {
    return Intl.message(
      'When Service Is Requested And Approved By \nThe Requester’s Manager If It Requires Approval',
      name: 'WhenServiceIsRequestedAndApprovedByTheRequester',
      desc: '',
      args: [],
    );
  }

  /// `When Service Is Requested And Approved By The Requester’s Manager \nIf It Requires Approval`
  String get WhenServiceIsRequestedAndApproved {
    return Intl.message(
      'When Service Is Requested And Approved By The Requester’s Manager \nIf It Requires Approval',
      name: 'WhenServiceIsRequestedAndApproved',
      desc: '',
      args: [],
    );
  }

  /// `When Service Requested And Approved by Manager`
  String get WhenServiceRequestedAndApproved {
    return Intl.message(
      'When Service Requested And Approved by Manager',
      name: 'WhenServiceRequestedAndApproved',
      desc: '',
      args: [],
    );
  }

  /// ` If It Requires Approval`
  String get ManagerIfItRequiresApproval {
    return Intl.message(
      ' If It Requires Approval',
      name: 'ManagerIfItRequiresApproval',
      desc: '',
      args: [],
    );
  }

  /// `Services Done`
  String get ServicesDone {
    return Intl.message(
      'Services Done',
      name: 'ServicesDone',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get Reset {
    return Intl.message('Reset', name: 'Reset', desc: '', args: []);
  }

  /// `Apply`
  String get Apply {
    return Intl.message('Apply', name: 'Apply', desc: '', args: []);
  }

  /// `Needs Approval`
  String get NeedsApproval {
    return Intl.message(
      'Needs Approval',
      name: 'NeedsApproval',
      desc: '',
      args: [],
    );
  }

  /// `Request`
  String get Request {
    return Intl.message('Request', name: 'Request', desc: '', args: []);
  }

  /// `Reminder`
  String get Reminder {
    return Intl.message('Reminder', name: 'Reminder', desc: '', args: []);
  }

  /// `Save`
  String get Save {
    return Intl.message('Save', name: 'Save', desc: '', args: []);
  }

  /// `Edit your message`
  String get Edityourmessage {
    return Intl.message(
      'Edit your message',
      name: 'Edityourmessage',
      desc: '',
      args: [],
    );
  }

  /// `Edit Message`
  String get EditMessage {
    return Intl.message(
      'Edit Message',
      name: 'EditMessage',
      desc: '',
      args: [],
    );
  }

  /// `Requested Services Details`
  String get RequestedServicesDetails {
    return Intl.message(
      'Requested Services Details',
      name: 'RequestedServicesDetails',
      desc: '',
      args: [],
    );
  }

  /// `Status Of Services`
  String get StatusOfServices {
    return Intl.message(
      'Status Of Services',
      name: 'StatusOfServices',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get total {
    return Intl.message('Total', name: 'total', desc: '', args: []);
  }

  /// `Other`
  String get other {
    return Intl.message('Other', name: 'other', desc: '', args: []);
  }

  /// `No. of Service`
  String get NoOfService {
    return Intl.message(
      'No. of Service',
      name: 'NoOfService',
      desc: '',
      args: [],
    );
  }

  /// `Services Offered`
  String get servicesOffered {
    return Intl.message(
      'Services Offered',
      name: 'servicesOffered',
      desc: '',
      args: [],
    );
  }

  /// `Number Of Services`
  String get numberOfServices {
    return Intl.message(
      'Number Of Services',
      name: 'numberOfServices',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get Requests {
    return Intl.message('Requests', name: 'Requests', desc: '', args: []);
  }

  /// `Statistics`
  String get Statistics {
    return Intl.message('Statistics', name: 'Statistics', desc: '', args: []);
  }

  /// `Executive`
  String get Executive {
    return Intl.message('Executive', name: 'Executive', desc: '', args: []);
  }

  /// `Customer Support`
  String get CustomerSupport {
    return Intl.message(
      'Customer Support',
      name: 'CustomerSupport',
      desc: '',
      args: [],
    );
  }

  /// `Operations`
  String get Operations {
    return Intl.message('Operations', name: 'Operations', desc: '', args: []);
  }

  /// `Finance`
  String get Finance {
    return Intl.message('Finance', name: 'Finance', desc: '', args: []);
  }

  /// `Information Technology`
  String get InformationTechnology {
    return Intl.message(
      'Information Technology',
      name: 'InformationTechnology',
      desc: '',
      args: [],
    );
  }

  /// `Human Resources`
  String get HumanResources {
    return Intl.message(
      'Human Resources',
      name: 'HumanResources',
      desc: '',
      args: [],
    );
  }

  /// `Marketing`
  String get Marketing {
    return Intl.message('Marketing', name: 'Marketing', desc: '', args: []);
  }

  /// `Sales`
  String get Sales {
    return Intl.message('Sales', name: 'Sales', desc: '', args: []);
  }

  /// `Data Management`
  String get DataManagement {
    return Intl.message(
      'Data Management',
      name: 'DataManagement',
      desc: '',
      args: [],
    );
  }

  /// `Compliance & Legal`
  String get ComplianceLegal {
    return Intl.message(
      'Compliance & Legal',
      name: 'ComplianceLegal',
      desc: '',
      args: [],
    );
  }

  /// `Software`
  String get Software {
    return Intl.message('Software', name: 'Software', desc: '', args: []);
  }

  /// `Editing`
  String get Editing {
    return Intl.message('Editing', name: 'Editing', desc: '', args: []);
  }

  /// `تعديل`
  String get ss {
    return Intl.message('تعديل', name: 'ss', desc: '', args: []);
  }

  /// `File Name`
  String get fileName {
    return Intl.message('File Name', name: 'fileName', desc: '', args: []);
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `Download`
  String get download {
    return Intl.message('Download', name: 'download', desc: '', args: []);
  }

  /// `Days`
  String get days {
    return Intl.message('Days', name: 'days', desc: '', args: []);
  }

  /// `Owning Department`
  String get OwningDepartment {
    return Intl.message(
      'Owning Department',
      name: 'OwningDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Request Date`
  String get requestDate {
    return Intl.message(
      'Request Date',
      name: 'requestDate',
      desc: '',
      args: [],
    );
  }

  /// `ٌDelete Service`
  String get deleteServices {
    return Intl.message(
      'ٌDelete Service',
      name: 'deleteServices',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure Delete This Service`
  String get AreYouSureDeleteThisService {
    return Intl.message(
      'Are You Sure Delete This Service',
      name: 'AreYouSureDeleteThisService',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Deleted This Service`
  String get servicesDeleteDone {
    return Intl.message(
      'You Successfully Deleted This Service',
      name: 'servicesDeleteDone',
      desc: '',
      args: [],
    );
  }

  /// `Hours`
  String get unit_hour {
    return Intl.message('Hours', name: 'unit_hour', desc: '', args: []);
  }

  /// `Minutes`
  String get unit_minute {
    return Intl.message('Minutes', name: 'unit_minute', desc: '', args: []);
  }

  /// `Seconds`
  String get unit_second {
    return Intl.message('Seconds', name: 'unit_second', desc: '', args: []);
  }

  /// `Weeks`
  String get unit_week {
    return Intl.message('Weeks', name: 'unit_week', desc: '', args: []);
  }

  /// `Are you sure you want to change this status`
  String get Areyousureyouwanttochangethisstatus {
    return Intl.message(
      'Are you sure you want to change this status',
      name: 'Areyousureyouwanttochangethisstatus',
      desc: '',
      args: [],
    );
  }

  /// `Changing Status`
  String get changingStatus {
    return Intl.message(
      'Changing Status',
      name: 'changingStatus',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Completed This Request`
  String get YouSuccessfullyCompletedThisRequest {
    return Intl.message(
      'You Successfully Completed This Request',
      name: 'YouSuccessfullyCompletedThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `Draft Saved`
  String get draftSaved {
    return Intl.message('Draft Saved', name: 'draftSaved', desc: '', args: []);
  }

  /// `Saving Draft...`
  String get savingDraft {
    return Intl.message(
      'Saving Draft...',
      name: 'savingDraft',
      desc: '',
      args: [],
    );
  }

  /// `Please wait while we save your draft`
  String get pleaseWaitSaving {
    return Intl.message(
      'Please wait while we save your draft',
      name: 'pleaseWaitSaving',
      desc: '',
      args: [],
    );
  }

  /// `Your draft was saved successfully`
  String get yourDraftWasSaved {
    return Intl.message(
      'Your draft was saved successfully',
      name: 'yourDraftWasSaved',
      desc: '',
      args: [],
    );
  }

  /// `Time Unit`
  String get timeUnit {
    return Intl.message('Time Unit', name: 'timeUnit', desc: '', args: []);
  }

  /// `Requires Approval`
  String get requiresApproval {
    return Intl.message(
      'Requires Approval',
      name: 'requiresApproval',
      desc: '',
      args: [],
    );
  }

  /// `Service Name`
  String get serviceName {
    return Intl.message(
      'Service Name',
      name: 'serviceName',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message('Description', name: 'description', desc: '', args: []);
  }

  /// `Camera`
  String get camera {
    return Intl.message('Camera', name: 'camera', desc: '', args: []);
  }

  /// `Gallery`
  String get gallery {
    return Intl.message('Gallery', name: 'gallery', desc: '', args: []);
  }

  /// `Document`
  String get document {
    return Intl.message('Document', name: 'document', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Select file source`
  String get selectFileSource {
    return Intl.message(
      'Select file source',
      name: 'selectFileSource',
      desc: '',
      args: [],
    );
  }

  /// `Upload successful`
  String get uploadSuccess {
    return Intl.message(
      'Upload successful',
      name: 'uploadSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Upload failed`
  String get uploadFailed {
    return Intl.message(
      'Upload failed',
      name: 'uploadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Requested Date`
  String get requestedDate {
    return Intl.message(
      'Requested Date',
      name: 'requestedDate',
      desc: '',
      args: [],
    );
  }

  /// `Request Service`
  String get requestService {
    return Intl.message(
      'Request Service',
      name: 'requestService',
      desc: '',
      args: [],
    );
  }

  /// `Discard Changes`
  String get discardChange {
    return Intl.message(
      'Discard Changes',
      name: 'discardChange',
      desc: '',
      args: [],
    );
  }

  /// `Request`
  String get request {
    return Intl.message('Request', name: 'request', desc: '', args: []);
  }

  /// `Services Control And Cycle`
  String get servicesControlAndCycle {
    return Intl.message(
      'Services Control And Cycle',
      name: 'servicesControlAndCycle',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Request`
  String get cancelRequest {
    return Intl.message(
      'Cancel Request',
      name: 'cancelRequest',
      desc: '',
      args: [],
    );
  }

  /// `You successfully canceled this request.`
  String get cancelSuccessMessage {
    return Intl.message(
      'You successfully canceled this request.',
      name: 'cancelSuccessMessage',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel this request?`
  String get cancelConfirmation {
    return Intl.message(
      'Are you sure you want to cancel this request?',
      name: 'cancelConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Changing Service Provider`
  String get changingServiceProvider {
    return Intl.message(
      'Changing Service Provider',
      name: 'changingServiceProvider',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Change Service Provider?`
  String get confirmChangeServiceProvider {
    return Intl.message(
      'Are You Sure You Want To Change Service Provider?',
      name: 'confirmChangeServiceProvider',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Changed Service Provider`
  String get successChangeServiceProvider {
    return Intl.message(
      'You Successfully Changed Service Provider',
      name: 'successChangeServiceProvider',
      desc: '',
      args: [],
    );
  }

  /// `HR`
  String get hr {
    return Intl.message('HR', name: 'hr', desc: '', args: []);
  }

  /// `Design`
  String get design {
    return Intl.message('Design', name: 'design', desc: '', args: []);
  }

  /// `Executive Management`
  String get executive {
    return Intl.message(
      'Executive Management',
      name: 'executive',
      desc: '',
      args: [],
    );
  }

  /// `Customer Support`
  String get customerSupport {
    return Intl.message(
      'Customer Support',
      name: 'customerSupport',
      desc: '',
      args: [],
    );
  }

  /// `Finance`
  String get finance {
    return Intl.message('Finance', name: 'finance', desc: '', args: []);
  }

  /// `Operations`
  String get operations {
    return Intl.message('Operations', name: 'operations', desc: '', args: []);
  }

  /// `Information Technology`
  String get informationTechnology {
    return Intl.message(
      'Information Technology',
      name: 'informationTechnology',
      desc: '',
      args: [],
    );
  }

  /// `Human Resources`
  String get humanResources {
    return Intl.message(
      'Human Resources',
      name: 'humanResources',
      desc: '',
      args: [],
    );
  }

  /// `Marketing`
  String get marketing {
    return Intl.message('Marketing', name: 'marketing', desc: '', args: []);
  }

  /// `Sales`
  String get sales {
    return Intl.message('Sales', name: 'sales', desc: '', args: []);
  }

  /// `Data Management`
  String get dataManagement {
    return Intl.message(
      'Data Management',
      name: 'dataManagement',
      desc: '',
      args: [],
    );
  }

  /// `Compliance & Legal`
  String get complianceAndLegal {
    return Intl.message(
      'Compliance & Legal',
      name: 'complianceAndLegal',
      desc: '',
      args: [],
    );
  }

  /// `Software`
  String get software {
    return Intl.message('Software', name: 'software', desc: '', args: []);
  }

  /// `Requested Services`
  String get requestedServices {
    return Intl.message(
      'Requested Services',
      name: 'requestedServices',
      desc: '',
      args: [],
    );
  }

  /// `Editing Service`
  String get editingService {
    return Intl.message(
      'Editing Service',
      name: 'editingService',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to edit this service?`
  String get areYouSureEditService {
    return Intl.message(
      'Are you sure you want to edit this service?',
      name: 'areYouSureEditService',
      desc: '',
      args: [],
    );
  }

  /// `Edited Service`
  String get editedService {
    return Intl.message(
      'Edited Service',
      name: 'editedService',
      desc: '',
      args: [],
    );
  }

  /// `You successfully edited this service.`
  String get successfullyEditedService {
    return Intl.message(
      'You successfully edited this service.',
      name: 'successfullyEditedService',
      desc: '',
      args: [],
    );
  }

  /// `Requested Service`
  String get requestedService {
    return Intl.message(
      'Requested Service',
      name: 'requestedService',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to disable the service?`
  String get areYouSureToDisableService {
    return Intl.message(
      'Are you sure you want to disable the service?',
      name: 'areYouSureToDisableService',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Changed the Status Of This Module`
  String get successfullyChangedStatus {
    return Intl.message(
      'You Successfully Changed the Status Of This Module',
      name: 'successfullyChangedStatus',
      desc: '',
      args: [],
    );
  }

  /// `Reminder`
  String get reminder {
    return Intl.message('Reminder', name: 'reminder', desc: '', args: []);
  }

  /// `Request Details`
  String get requestDetails {
    return Intl.message(
      'Request Details',
      name: 'requestDetails',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a cancellation reason`
  String get pleaseEnterCancelReason {
    return Intl.message(
      'Please enter a cancellation reason',
      name: 'pleaseEnterCancelReason',
      desc: '',
      args: [],
    );
  }

  /// `Exported successfully. You have successfully exported this file.`
  String get exportSuccess {
    return Intl.message(
      'Exported successfully. You have successfully exported this file.',
      name: 'exportSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Exported`
  String get exported {
    return Intl.message('Exported', name: 'exported', desc: '', args: []);
  }

  /// `Approval Request Details`
  String get approval_request_details {
    return Intl.message(
      'Approval Request Details',
      name: 'approval_request_details',
      desc: '',
      args: [],
    );
  }

  /// `Day`
  String get day {
    return Intl.message('Day', name: 'day', desc: '', args: []);
  }

  /// `Months`
  String get month {
    return Intl.message('Months', name: 'month', desc: '', args: []);
  }

  /// `years`
  String get year {
    return Intl.message('years', name: 'year', desc: '', args: []);
  }

  /// `Download Successful`
  String get downloadSuccessTitle {
    return Intl.message(
      'Download Successful',
      name: 'downloadSuccessTitle',
      desc: '',
      args: [],
    );
  }

  /// `You have successfully downloaded this document.`
  String get downloadSuccessMessage {
    return Intl.message(
      'You have successfully downloaded this document.',
      name: 'downloadSuccessMessage',
      desc: '',
      args: [],
    );
  }

  /// `Service Provider Details`
  String get serviceProviderDetails {
    return Intl.message(
      'Service Provider Details',
      name: 'serviceProviderDetails',
      desc: '',
      args: [],
    );
  }

  /// `Date Requested`
  String get dateRequested {
    return Intl.message(
      'Date Requested',
      name: 'dateRequested',
      desc: '',
      args: [],
    );
  }

  /// `Reason of Approval`
  String get reasonOfApproval {
    return Intl.message(
      'Reason of Approval',
      name: 'reasonOfApproval',
      desc: '',
      args: [],
    );
  }

  /// `Reason of Rejection`
  String get reasonOfRejection {
    return Intl.message(
      'Reason of Rejection',
      name: 'reasonOfRejection',
      desc: '',
      args: [],
    );
  }

  /// `Warning`
  String get warning {
    return Intl.message('Warning', name: 'warning', desc: '', args: []);
  }

  /// `Please select at least one provider`
  String get pleaseSelectOneProviderAtLeast {
    return Intl.message(
      'Please select at least one provider',
      name: 'pleaseSelectOneProviderAtLeast',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to save as draft?`
  String get areYouSureYouWantToSaveAsDraft {
    return Intl.message(
      'Are you sure you want to save as draft?',
      name: 'areYouSureYouWantToSaveAsDraft',
      desc: '',
      args: [],
    );
  }

  /// `Draft saved successfully`
  String get successSavingDraft {
    return Intl.message(
      'Draft saved successfully',
      name: 'successSavingDraft',
      desc: '',
      args: [],
    );
  }

  /// `Export Successful`
  String get exportSuccessful {
    return Intl.message(
      'Export Successful',
      name: 'exportSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Your CSV file has been saved`
  String get csvFileSaved {
    return Intl.message(
      'Your CSV file has been saved',
      name: 'csvFileSaved',
      desc: '',
      args: [],
    );
  }

  /// `Image uploaded successfully`
  String get imageUploadedSuccessfully {
    return Intl.message(
      'Image uploaded successfully',
      name: 'imageUploadedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Delete Image`
  String get deleteImage {
    return Intl.message(
      'Delete Image',
      name: 'deleteImage',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete the image?`
  String get areYouSureToDeleteImage {
    return Intl.message(
      'Are you sure you want to delete the image?',
      name: 'areYouSureToDeleteImage',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Validation Error`
  String get validationError {
    return Intl.message(
      'Validation Error',
      name: 'validationError',
      desc: '',
      args: [],
    );
  }

  /// `You must select at least one department when limiting service availability`
  String get mustSelectDepartment {
    return Intl.message(
      'You must select at least one department when limiting service availability',
      name: 'mustSelectDepartment',
      desc: '',
      args: [],
    );
  }

  /// `You must select at least one employee for the approval cycle`
  String get mustSelectApprovalEmployees {
    return Intl.message(
      'You must select at least one employee for the approval cycle',
      name: 'mustSelectApprovalEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Draft Service`
  String get draftService {
    return Intl.message(
      'Draft Service',
      name: 'draftService',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Drafted This Service`
  String get successfullyDraftedService {
    return Intl.message(
      'You Successfully Drafted This Service',
      name: 'successfullyDraftedService',
      desc: '',
      args: [],
    );
  }

  /// `Copy Done`
  String get copyDone {
    return Intl.message('Copy Done', name: 'copyDone', desc: '', args: []);
  }

  /// `Please disable all notification switches before unchecking this section.`
  String get checkValidation {
    return Intl.message(
      'Please disable all notification switches before unchecking this section.',
      name: 'checkValidation',
      desc: '',
      args: [],
    );
  }

  /// `Total Hours`
  String get totalHours {
    return Intl.message('Total Hours', name: 'totalHours', desc: '', args: []);
  }

  /// `services Done`
  String get servicesDone {
    return Intl.message(
      'services Done',
      name: 'servicesDone',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message('Ok', name: 'ok', desc: '', args: []);
  }

  /// `File downloaded successfully`
  String get successDownloadFile {
    return Intl.message(
      'File downloaded successfully',
      name: 'successDownloadFile',
      desc: '',
      args: [],
    );
  }

  /// `See All`
  String get seeAll {
    return Intl.message('See All', name: 'seeAll', desc: '', args: []);
  }

  /// `See Less`
  String get seeLess {
    return Intl.message('See Less', name: 'seeLess', desc: '', args: []);
  }

  /// `An error occurred while processing your request.`
  String get anErrorOccurred {
    return Intl.message(
      'An error occurred while processing your request.',
      name: 'anErrorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `Request Submitted`
  String get requestSubmitted {
    return Intl.message(
      'Request Submitted',
      name: 'requestSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Your request has been submitted successfully.`
  String get requestSuccess {
    return Intl.message(
      'Your request has been submitted successfully.',
      name: 'requestSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Processing request...`
  String get processingRequest {
    return Intl.message(
      'Processing request...',
      name: 'processingRequest',
      desc: '',
      args: [],
    );
  }

  /// `Admin Dashboard`
  String get adminDashboard {
    return Intl.message(
      'Admin Dashboard',
      name: 'adminDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Inventory Management`
  String get inventoryManagement {
    return Intl.message(
      'Inventory Management',
      name: 'inventoryManagement',
      desc: '',
      args: [],
    );
  }

  /// `Product Requests`
  String get productRequests {
    return Intl.message(
      'Product Requests',
      name: 'productRequests',
      desc: '',
      args: [],
    );
  }

  /// `Employees`
  String get employees {
    return Intl.message('Employees', name: 'employees', desc: '', args: []);
  }

  /// `Product Name`
  String get productName {
    return Intl.message(
      'Product Name',
      name: 'productName',
      desc: '',
      args: [],
    );
  }

  /// `Assets`
  String get assets {
    return Intl.message('Assets', name: 'assets', desc: '', args: []);
  }

  /// `Consumables`
  String get consumables {
    return Intl.message('Consumables', name: 'consumables', desc: '', args: []);
  }

  /// `Orders`
  String get orders {
    return Intl.message('Orders', name: 'orders', desc: '', args: []);
  }

  /// `Suppliers`
  String get suppliers {
    return Intl.message('Suppliers', name: 'suppliers', desc: '', args: []);
  }

  /// `Storage Locations`
  String get storageLocations {
    return Intl.message(
      'Storage Locations',
      name: 'storageLocations',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get filter {
    return Intl.message('Filter', name: 'filter', desc: '', args: []);
  }

  /// `product Name`
  String get product {
    return Intl.message('product Name', name: 'product', desc: '', args: []);
  }

  /// `InStock`
  String get inStock {
    return Intl.message('InStock', name: 'inStock', desc: '', args: []);
  }

  /// `Out Of Stock`
  String get outOfStock {
    return Intl.message('Out Of Stock', name: 'outOfStock', desc: '', args: []);
  }

  /// `Low Stock`
  String get lowStock {
    return Intl.message('Low Stock', name: 'lowStock', desc: '', args: []);
  }

  /// `Product ID`
  String get productID {
    return Intl.message('Product ID', name: 'productID', desc: '', args: []);
  }

  /// `Product Type`
  String get productType {
    return Intl.message(
      'Product Type',
      name: 'productType',
      desc: '',
      args: [],
    );
  }

  /// `Supplier`
  String get supplier {
    return Intl.message('Supplier', name: 'supplier', desc: '', args: []);
  }

  /// `Adding New Product`
  String get addingNewProduct {
    return Intl.message(
      'Adding New Product',
      name: 'addingNewProduct',
      desc: '',
      args: [],
    );
  }

  /// `Order ID`
  String get orderID {
    return Intl.message('Order ID', name: 'orderID', desc: '', args: []);
  }

  /// `Category`
  String get category {
    return Intl.message('Category', name: 'category', desc: '', args: []);
  }

  /// `Brand`
  String get brand {
    return Intl.message('Brand', name: 'brand', desc: '', args: []);
  }

  /// `Quantity`
  String get quantity {
    return Intl.message('Quantity', name: 'quantity', desc: '', args: []);
  }

  /// `Currency`
  String get currency {
    return Intl.message('Currency', name: 'currency', desc: '', args: []);
  }

  /// `Subcategory`
  String get subcategory {
    return Intl.message('Subcategory', name: 'subcategory', desc: '', args: []);
  }

  /// `Model`
  String get model {
    return Intl.message('Model', name: 'model', desc: '', args: []);
  }

  /// `Unit Cost`
  String get unitCost {
    return Intl.message('Unit Cost', name: 'unitCost', desc: '', args: []);
  }

  /// `Supplier Name`
  String get supplierName {
    return Intl.message(
      'Supplier Name',
      name: 'supplierName',
      desc: '',
      args: [],
    );
  }

  /// `Order Details`
  String get orderDetails {
    return Intl.message(
      'Order Details',
      name: 'orderDetails',
      desc: '',
      args: [],
    );
  }

  /// `Product Details`
  String get productDetails {
    return Intl.message(
      'Product Details',
      name: 'productDetails',
      desc: '',
      args: [],
    );
  }

  /// `Reorder Level`
  String get reorderLevel {
    return Intl.message(
      'Reorder Level',
      name: 'reorderLevel',
      desc: '',
      args: [],
    );
  }

  /// `Reorder Quantity`
  String get reorderQuantity {
    return Intl.message(
      'Reorder Quantity',
      name: 'reorderQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Additional Note`
  String get additionalNote {
    return Intl.message(
      'Additional Note',
      name: 'additionalNote',
      desc: '',
      args: [],
    );
  }

  /// `Storage Location`
  String get storageLocation {
    return Intl.message(
      'Storage Location',
      name: 'storageLocation',
      desc: '',
      args: [],
    );
  }

  /// `Storage`
  String get storage {
    return Intl.message('Storage', name: 'storage', desc: '', args: []);
  }

  /// `Product Specification`
  String get productSpecification {
    return Intl.message(
      'Product Specification',
      name: 'productSpecification',
      desc: '',
      args: [],
    );
  }

  /// `Product Warranty`
  String get productWarranty {
    return Intl.message(
      'Product Warranty',
      name: 'productWarranty',
      desc: '',
      args: [],
    );
  }

  /// `Text here`
  String get textHere {
    return Intl.message('Text here', name: 'textHere', desc: '', args: []);
  }

  /// `Upload`
  String get upload {
    return Intl.message('Upload', name: 'upload', desc: '', args: []);
  }

  /// `Expected Lifetime`
  String get expectedLifetime {
    return Intl.message(
      'Expected Lifetime',
      name: 'expectedLifetime',
      desc: '',
      args: [],
    );
  }

  /// `Select Storage Location`
  String get selectStorageLocation {
    return Intl.message(
      'Select Storage Location',
      name: 'selectStorageLocation',
      desc: '',
      args: [],
    );
  }

  /// `Different Approval Cycle For The Other Request Types`
  String get differentApprovalCycleForTheOtherRequestTypes {
    return Intl.message(
      'Different Approval Cycle For The Other Request Types',
      name: 'differentApprovalCycleForTheOtherRequestTypes',
      desc: '',
      args: [],
    );
  }

  /// `Add Asset`
  String get addAsset {
    return Intl.message('Add Asset', name: 'addAsset', desc: '', args: []);
  }

  /// `Select Request Types`
  String get selectRequestTypes {
    return Intl.message(
      'Select Request Types',
      name: 'selectRequestTypes',
      desc: '',
      args: [],
    );
  }

  /// `To Which Types Of Requests Does This Apply`
  String get toWhichTypesOfRequestsDoesThisApply {
    return Intl.message(
      'To Which Types Of Requests Does This Apply',
      name: 'toWhichTypesOfRequestsDoesThisApply',
      desc: '',
      args: [],
    );
  }

  /// `If you select 'All Requests', the approval cycle will be applied to all request types.`
  String get ifYouSelectAllRequests {
    return Intl.message(
      'If you select \'All Requests\', the approval cycle will be applied to all request types.',
      name: 'ifYouSelectAllRequests',
      desc: '',
      args: [],
    );
  }

  /// `If you select a specific request type, the approval cycle will only apply to that type, and the remaining request types will not have an approval cycle assigned.`
  String get selectSpecificTypeOnly {
    return Intl.message(
      'If you select a specific request type, the approval cycle will only apply to that type, and the remaining request types will not have an approval cycle assigned.',
      name: 'selectSpecificTypeOnly',
      desc: '',
      args: [],
    );
  }

  /// `Storage Requirement`
  String get storageRequirement {
    return Intl.message(
      'Storage Requirement',
      name: 'storageRequirement',
      desc: '',
      args: [],
    );
  }

  /// `If you wish to add approval cycles for the remaining request types, click 'Add Different Approval Cycle for Other Request Types' and select the additional requests as needed.`
  String get clickAddDifferentApprovalCycle {
    return Intl.message(
      'If you wish to add approval cycles for the remaining request types, click \'Add Different Approval Cycle for Other Request Types\' and select the additional requests as needed.',
      name: 'clickAddDifferentApprovalCycle',
      desc: '',
      args: [],
    );
  }

  /// `hybrid`
  String get hybrid {
    return Intl.message('hybrid', name: 'hybrid', desc: '', args: []);
  }

  /// `Number Of Product`
  String get numberOfProduct {
    return Intl.message(
      'Number Of Product',
      name: 'numberOfProduct',
      desc: '',
      args: [],
    );
  }

  /// `Receiving Date`
  String get receivingDate {
    return Intl.message(
      'Receiving Date',
      name: 'receivingDate',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message('Reset', name: 'reset', desc: '', args: []);
  }

  /// `Apply`
  String get apply {
    return Intl.message('Apply', name: 'apply', desc: '', args: []);
  }

  /// `Usage Frequency`
  String get usageFrequency {
    return Intl.message(
      'Usage Frequency',
      name: 'usageFrequency',
      desc: '',
      args: [],
    );
  }

  /// `Unit Of Measurement`
  String get unitOfMeasurement {
    return Intl.message(
      'Unit Of Measurement',
      name: 'unitOfMeasurement',
      desc: '',
      args: [],
    );
  }

  /// `Attachments`
  String get attachments {
    return Intl.message('Attachments', name: 'attachments', desc: '', args: []);
  }

  /// `Adding Attachment`
  String get addingAttachment {
    return Intl.message(
      'Adding Attachment',
      name: 'addingAttachment',
      desc: '',
      args: [],
    );
  }

  /// `Drag & Drop files here`
  String get dragDropHere {
    return Intl.message(
      'Drag & Drop files here',
      name: 'dragDropHere',
      desc: '',
      args: [],
    );
  }

  /// `Or`
  String get or {
    return Intl.message('Or', name: 'or', desc: '', args: []);
  }

  /// `File`
  String get file {
    return Intl.message('File', name: 'file', desc: '', args: []);
  }

  /// `Date`
  String get date {
    return Intl.message('Date', name: 'date', desc: '', args: []);
  }

  /// `Title Name`
  String get titleName {
    return Intl.message('Title Name', name: 'titleName', desc: '', args: []);
  }

  /// `Are You Sure You Want To Add This Asset ?`
  String get confirmAddAsset {
    return Intl.message(
      'Are You Sure You Want To Add This Asset ?',
      name: 'confirmAddAsset',
      desc: '',
      args: [],
    );
  }

  /// `Adding Asset`
  String get addingAsset {
    return Intl.message(
      'Adding Asset',
      name: 'addingAsset',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Added This Asset`
  String get successAddAsset {
    return Intl.message(
      'You Successfully Added This Asset',
      name: 'successAddAsset',
      desc: '',
      args: [],
    );
  }

  /// `Warranty`
  String get warranty {
    return Intl.message('Warranty', name: 'warranty', desc: '', args: []);
  }

  /// `Specification`
  String get specification {
    return Intl.message(
      'Specification',
      name: 'specification',
      desc: '',
      args: [],
    );
  }

  /// `Restock`
  String get restock {
    return Intl.message('Restock', name: 'restock', desc: '', args: []);
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Storage Location And Quantity`
  String get storageLocationAndQuantity {
    return Intl.message(
      'Storage Location And Quantity',
      name: 'storageLocationAndQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get location {
    return Intl.message('Location', name: 'location', desc: '', args: []);
  }

  /// `Batch`
  String get batch {
    return Intl.message('Batch', name: 'batch', desc: '', args: []);
  }

  /// `Hide`
  String get hide {
    return Intl.message('Hide', name: 'hide', desc: '', args: []);
  }

  /// `Expand`
  String get expand {
    return Intl.message('Expand', name: 'expand', desc: '', args: []);
  }

  /// `Assigned`
  String get assigned {
    return Intl.message('Assigned', name: 'assigned', desc: '', args: []);
  }

  /// `Stock`
  String get stock {
    return Intl.message('Stock', name: 'stock', desc: '', args: []);
  }

  /// `Title`
  String get title {
    return Intl.message('Title', name: 'title', desc: '', args: []);
  }

  /// `Assigned Date`
  String get assignedDate {
    return Intl.message(
      'Assigned Date',
      name: 'assignedDate',
      desc: '',
      args: [],
    );
  }

  /// `Return Date`
  String get returnDate {
    return Intl.message('Return Date', name: 'returnDate', desc: '', args: []);
  }

  /// `Quantity Assigned`
  String get quantityAssigned {
    return Intl.message(
      'Quantity Assigned',
      name: 'quantityAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Restocking Existing Batch`
  String get existingBatchRestockTitle {
    return Intl.message(
      'Restocking Existing Batch',
      name: 'existingBatchRestockTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter Order ID`
  String get enterOrderId {
    return Intl.message(
      'Enter Order ID',
      name: 'enterOrderId',
      desc: '',
      args: [],
    );
  }

  /// `+ Storage`
  String get addStorage {
    return Intl.message('+ Storage', name: 'addStorage', desc: '', args: []);
  }

  /// `Invoice`
  String get invoice {
    return Intl.message('Invoice', name: 'invoice', desc: '', args: []);
  }

  /// `Existing Batch`
  String get existingBatch {
    return Intl.message(
      'Existing Batch',
      name: 'existingBatch',
      desc: '',
      args: [],
    );
  }

  /// `New Batch`
  String get newBatch {
    return Intl.message('New Batch', name: 'newBatch', desc: '', args: []);
  }

  /// `Restocking New Batch`
  String get newBatchRestockTitle {
    return Intl.message(
      'Restocking New Batch',
      name: 'newBatchRestockTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Period`
  String get enterThePeriod {
    return Intl.message(
      'Enter The Period',
      name: 'enterThePeriod',
      desc: '',
      args: [],
    );
  }

  /// `Automatic IDs`
  String get automaticIDs {
    return Intl.message(
      'Automatic IDs',
      name: 'automaticIDs',
      desc: '',
      args: [],
    );
  }

  /// `Supplier ID`
  String get supplierId {
    return Intl.message('Supplier ID', name: 'supplierId', desc: '', args: []);
  }

  /// `Business Type`
  String get businessType {
    return Intl.message(
      'Business Type',
      name: 'businessType',
      desc: '',
      args: [],
    );
  }

  /// `Tax Number`
  String get taxNumber {
    return Intl.message('Tax Number', name: 'taxNumber', desc: '', args: []);
  }

  /// `Business Registration Number`
  String get businessRegistrationNumber {
    return Intl.message(
      'Business Registration Number',
      name: 'businessRegistrationNumber',
      desc: '',
      args: [],
    );
  }

  /// `Supplier Rank`
  String get supplierRank {
    return Intl.message(
      'Supplier Rank',
      name: 'supplierRank',
      desc: '',
      args: [],
    );
  }

  /// `Created By`
  String get createdBy {
    return Intl.message('Created By', name: 'createdBy', desc: '', args: []);
  }

  /// `Date Added`
  String get dateAdded {
    return Intl.message('Date Added', name: 'dateAdded', desc: '', args: []);
  }

  /// `Point Of Contact Details`
  String get pointOfContactDetails {
    return Intl.message(
      'Point Of Contact Details',
      name: 'pointOfContactDetails',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get firstName {
    return Intl.message('First Name', name: 'firstName', desc: '', args: []);
  }

  /// `Middle Name`
  String get middleName {
    return Intl.message('Middle Name', name: 'middleName', desc: '', args: []);
  }

  /// `Last Name`
  String get lastName {
    return Intl.message('Last Name', name: 'lastName', desc: '', args: []);
  }

  /// `Phone Number`
  String get phoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Fax Number`
  String get faxNumber {
    return Intl.message('Fax Number', name: 'faxNumber', desc: '', args: []);
  }

  /// `Preferred Language`
  String get preferredLanguage {
    return Intl.message(
      'Preferred Language',
      name: 'preferredLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Bank Transfer Details`
  String get bankTransferDetails {
    return Intl.message(
      'Bank Transfer Details',
      name: 'bankTransferDetails',
      desc: '',
      args: [],
    );
  }

  /// `Beneficiary Name`
  String get beneficiaryName {
    return Intl.message(
      'Beneficiary Name',
      name: 'beneficiaryName',
      desc: '',
      args: [],
    );
  }

  /// `Beneficiary Bank Name`
  String get beneficiaryBankName {
    return Intl.message(
      'Beneficiary Bank Name',
      name: 'beneficiaryBankName',
      desc: '',
      args: [],
    );
  }

  /// `Beneficiary Bank Account Number / IBAN`
  String get iban {
    return Intl.message(
      'Beneficiary Bank Account Number / IBAN',
      name: 'iban',
      desc: '',
      args: [],
    );
  }

  /// `Bank SWIFT/BIC Code`
  String get swiftCode {
    return Intl.message(
      'Bank SWIFT/BIC Code',
      name: 'swiftCode',
      desc: '',
      args: [],
    );
  }

  /// `Bank Address`
  String get bankAddress {
    return Intl.message(
      'Bank Address',
      name: 'bankAddress',
      desc: '',
      args: [],
    );
  }

  /// `Address Details`
  String get addressDetails {
    return Intl.message(
      'Address Details',
      name: 'addressDetails',
      desc: '',
      args: [],
    );
  }

  /// `Country`
  String get country {
    return Intl.message('Country', name: 'country', desc: '', args: []);
  }

  /// `State or Province`
  String get state {
    return Intl.message('State or Province', name: 'state', desc: '', args: []);
  }

  /// `City`
  String get city {
    return Intl.message('City', name: 'city', desc: '', args: []);
  }

  /// `Postal Code`
  String get postalCode {
    return Intl.message('Postal Code', name: 'postalCode', desc: '', args: []);
  }

  /// `Street Name`
  String get streetName {
    return Intl.message('Street Name', name: 'streetName', desc: '', args: []);
  }

  /// `Contract Details`
  String get contractDetails {
    return Intl.message(
      'Contract Details',
      name: 'contractDetails',
      desc: '',
      args: [],
    );
  }

  /// `Contract Start Date`
  String get contractStartDate {
    return Intl.message(
      'Contract Start Date',
      name: 'contractStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Contract End Date`
  String get contractEndDate {
    return Intl.message(
      'Contract End Date',
      name: 'contractEndDate',
      desc: '',
      args: [],
    );
  }

  /// `Contract Document`
  String get contractDocument {
    return Intl.message(
      'Contract Document',
      name: 'contractDocument',
      desc: '',
      args: [],
    );
  }

  /// `Registration Document`
  String get registrationDocument {
    return Intl.message(
      'Registration Document',
      name: 'registrationDocument',
      desc: '',
      args: [],
    );
  }

  /// `Tax Certificate`
  String get taxCertificate {
    return Intl.message(
      'Tax Certificate',
      name: 'taxCertificate',
      desc: '',
      args: [],
    );
  }

  /// `File Size`
  String get fileSize {
    return Intl.message('File Size', name: 'fileSize', desc: '', args: []);
  }

  /// `Date`
  String get fileDate {
    return Intl.message('Date', name: 'fileDate', desc: '', args: []);
  }

  /// `Supplier Details`
  String get supplierDetails {
    return Intl.message(
      'Supplier Details',
      name: 'supplierDetails',
      desc: '',
      args: [],
    );
  }

  /// `Orders History`
  String get ordersHistory {
    return Intl.message(
      'Orders History',
      name: 'ordersHistory',
      desc: '',
      args: [],
    );
  }

  /// `Closure Status`
  String get closureStatus {
    return Intl.message(
      'Closure Status',
      name: 'closureStatus',
      desc: '',
      args: [],
    );
  }

  /// `Order Date`
  String get orderDate {
    return Intl.message('Order Date', name: 'orderDate', desc: '', args: []);
  }

  /// `Order Created By`
  String get orderCreatedBy {
    return Intl.message(
      'Order Created By',
      name: 'orderCreatedBy',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message('Share', name: 'share', desc: '', args: []);
  }

  /// `Order Request`
  String get orderRequest {
    return Intl.message(
      'Order Request',
      name: 'orderRequest',
      desc: '',
      args: [],
    );
  }

  /// `Total Amount`
  String get totalAmount {
    return Intl.message(
      'Total Amount',
      name: 'totalAmount',
      desc: '',
      args: [],
    );
  }

  /// `Order Type`
  String get orderType {
    return Intl.message('Order Type', name: 'orderType', desc: '', args: []);
  }

  /// `Order Status`
  String get orderStatus {
    return Intl.message(
      'Order Status',
      name: 'orderStatus',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Method`
  String get deliveryMethod {
    return Intl.message(
      'Delivery Method',
      name: 'deliveryMethod',
      desc: '',
      args: [],
    );
  }

  /// `Received By`
  String get receivedBy {
    return Intl.message('Received By', name: 'receivedBy', desc: '', args: []);
  }

  /// `Expected Delivery Date`
  String get expectedDeliveryDate {
    return Intl.message(
      'Expected Delivery Date',
      name: 'expectedDeliveryDate',
      desc: '',
      args: [],
    );
  }

  /// `Received Date`
  String get receivedDate {
    return Intl.message(
      'Received Date',
      name: 'receivedDate',
      desc: '',
      args: [],
    );
  }

  /// `Order Note`
  String get orderNote {
    return Intl.message('Order Note', name: 'orderNote', desc: '', args: []);
  }

  /// `We are pleased to place a new purchase order with your company. Please find attached the details of our order, including item descriptions, quantities, pricing, and delivery address. Kindly confirm receipt of this order and provide an estimated delivery date. Should you have any questions or need clarification, please do not hesitate to contact us.`
  String get infoOrder {
    return Intl.message(
      'We are pleased to place a new purchase order with your company. Please find attached the details of our order, including item descriptions, quantities, pricing, and delivery address. Kindly confirm receipt of this order and provide an estimated delivery date. Should you have any questions or need clarification, please do not hesitate to contact us.',
      name: 'infoOrder',
      desc: '',
      args: [],
    );
  }

  /// `Payment Type`
  String get paymentType {
    return Intl.message(
      'Payment Type',
      name: 'paymentType',
      desc: '',
      args: [],
    );
  }

  /// `Advanced Deposit`
  String get advancedDeposit {
    return Intl.message(
      'Advanced Deposit',
      name: 'advancedDeposit',
      desc: '',
      args: [],
    );
  }

  /// `Total HT`
  String get totalHT {
    return Intl.message('Total HT', name: 'totalHT', desc: '', args: []);
  }

  /// `Total VAT`
  String get totalVAT {
    return Intl.message('Total VAT', name: 'totalVAT', desc: '', args: []);
  }

  /// `Total Price`
  String get totalPrice {
    return Intl.message('Total Price', name: 'totalPrice', desc: '', args: []);
  }

  /// `Employee Details`
  String get employeeDetails {
    return Intl.message(
      'Employee Details',
      name: 'employeeDetails',
      desc: '',
      args: [],
    );
  }

  /// `Damaged`
  String get damaged {
    return Intl.message('Damaged', name: 'damaged', desc: '', args: []);
  }

  /// `Under Repair`
  String get underRepair {
    return Intl.message(
      'Under Repair',
      name: 'underRepair',
      desc: '',
      args: [],
    );
  }

  /// `Missing`
  String get missing {
    return Intl.message('Missing', name: 'missing', desc: '', args: []);
  }

  /// `Stolen`
  String get stolen {
    return Intl.message('Stolen', name: 'stolen', desc: '', args: []);
  }

  /// `Returned`
  String get returned {
    return Intl.message('Returned', name: 'returned', desc: '', args: []);
  }

  /// `In Use`
  String get inUse {
    return Intl.message('In Use', name: 'inUse', desc: '', args: []);
  }

  /// `Issue Type`
  String get issueType {
    return Intl.message('Issue Type', name: 'issueType', desc: '', args: []);
  }

  /// `Request ID`
  String get requestId {
    return Intl.message('Request ID', name: 'requestId', desc: '', args: []);
  }

  /// `Retrieve`
  String get retrieve {
    return Intl.message('Retrieve', name: 'retrieve', desc: '', args: []);
  }

  /// `Maintenance Details`
  String get maintenanceDetails {
    return Intl.message(
      'Maintenance Details',
      name: 'maintenanceDetails',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance Schedule`
  String get maintenanceSchedule {
    return Intl.message(
      'Maintenance Schedule',
      name: 'maintenanceSchedule',
      desc: '',
      args: [],
    );
  }

  /// `Requested Maintenance`
  String get requestedMaintenance {
    return Intl.message(
      'Requested Maintenance',
      name: 'requestedMaintenance',
      desc: '',
      args: [],
    );
  }

  /// `Message`
  String get msg {
    return Intl.message('Message', name: 'msg', desc: '', args: []);
  }

  /// `Asset Id`
  String get assetId {
    return Intl.message('Asset Id', name: 'assetId', desc: '', args: []);
  }

  /// `Maintenance Frequency`
  String get maintenanceFrequency {
    return Intl.message(
      'Maintenance Frequency',
      name: 'maintenanceFrequency',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance`
  String get maintenance {
    return Intl.message('Maintenance', name: 'maintenance', desc: '', args: []);
  }

  /// `Download as PNG`
  String get downloadAsPng {
    return Intl.message(
      'Download as PNG',
      name: 'downloadAsPng',
      desc: '',
      args: [],
    );
  }

  /// `End Date`
  String get endDate {
    return Intl.message('End Date', name: 'endDate', desc: '', args: []);
  }

  /// `Condition`
  String get condition {
    return Intl.message('Condition', name: 'condition', desc: '', args: []);
  }

  /// `Assign`
  String get assign {
    return Intl.message('Assign', name: 'assign', desc: '', args: []);
  }

  /// `Employee Information`
  String get employeeInformation {
    return Intl.message(
      'Employee Information',
      name: 'employeeInformation',
      desc: '',
      args: [],
    );
  }

  /// `Assigning Product`
  String get assigningProduct {
    return Intl.message(
      'Assigning Product',
      name: 'assigningProduct',
      desc: '',
      args: [],
    );
  }

  /// `Create Barcode`
  String get createBarcode {
    return Intl.message(
      'Create Barcode',
      name: 'createBarcode',
      desc: '',
      args: [],
    );
  }

  /// `Create Automatic IDs`
  String get createAutomaticIDs {
    return Intl.message(
      'Create Automatic IDs',
      name: 'createAutomaticIDs',
      desc: '',
      args: [],
    );
  }

  /// `Request ID`
  String get requestID {
    return Intl.message('Request ID', name: 'requestID', desc: '', args: []);
  }

  /// `Expected Return Date`
  String get expectedReturnDate {
    return Intl.message(
      'Expected Return Date',
      name: 'expectedReturnDate',
      desc: '',
      args: [],
    );
  }

  /// `Purpose Of Use`
  String get purposeOfUse {
    return Intl.message(
      'Purpose Of Use',
      name: 'purposeOfUse',
      desc: '',
      args: [],
    );
  }

  /// `Assigning Details`
  String get assigningDetails {
    return Intl.message(
      'Assigning Details',
      name: 'assigningDetails',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get preview {
    return Intl.message('Preview', name: 'preview', desc: '', args: []);
  }

  /// `Pick Up`
  String get pickup {
    return Intl.message('Pick Up', name: 'pickup', desc: '', args: []);
  }

  /// `Hand Delivery`
  String get handDelivery {
    return Intl.message(
      'Hand Delivery',
      name: 'handDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Storage Location Details`
  String get storageLocationDetails {
    return Intl.message(
      'Storage Location Details',
      name: 'storageLocationDetails',
      desc: '',
      args: [],
    );
  }

  /// `History Product Storage`
  String get historyProductStorage {
    return Intl.message(
      'History Product Storage',
      name: 'historyProductStorage',
      desc: '',
      args: [],
    );
  }

  /// `Stored Products`
  String get storedProducts {
    return Intl.message(
      'Stored Products',
      name: 'storedProducts',
      desc: '',
      args: [],
    );
  }

  /// `Area`
  String get area {
    return Intl.message('Area', name: 'area', desc: '', args: []);
  }

  /// `Branch Name`
  String get branchName {
    return Intl.message('Branch Name', name: 'branchName', desc: '', args: []);
  }

  /// `Storage Location ID`
  String get storageLocationID {
    return Intl.message(
      'Storage Location ID',
      name: 'storageLocationID',
      desc: '',
      args: [],
    );
  }

  /// `storageLocation Name`
  String get storageLocationIDName {
    return Intl.message(
      'storageLocation Name',
      name: 'storageLocationIDName',
      desc: '',
      args: [],
    );
  }

  /// `Storage Capacity`
  String get storageCapacity {
    return Intl.message(
      'Storage Capacity',
      name: 'storageCapacity',
      desc: '',
      args: [],
    );
  }

  /// `Condition Of Storage`
  String get conditionOfStorage {
    return Intl.message(
      'Condition Of Storage',
      name: 'conditionOfStorage',
      desc: '',
      args: [],
    );
  }

  /// `Equipment Available`
  String get equipmentAvailable {
    return Intl.message(
      'Equipment Available',
      name: 'equipmentAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Access Level`
  String get accessLevel {
    return Intl.message(
      'Access Level',
      name: 'accessLevel',
      desc: '',
      args: [],
    );
  }

  /// `Employee Assigned Information`
  String get employeeAssignedInformation {
    return Intl.message(
      'Employee Assigned Information',
      name: 'employeeAssignedInformation',
      desc: '',
      args: [],
    );
  }

  /// `State or Province`
  String get stateOrProvince {
    return Intl.message(
      'State or Province',
      name: 'stateOrProvince',
      desc: '',
      args: [],
    );
  }

  /// `Assigned Department`
  String get assignedDepartment {
    return Intl.message(
      'Assigned Department',
      name: 'assignedDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Unit`
  String get unit {
    return Intl.message('Unit', name: 'unit', desc: '', args: []);
  }

  /// `Storage ID`
  String get storageId {
    return Intl.message('Storage ID', name: 'storageId', desc: '', args: []);
  }

  /// `Expiration Date`
  String get expirationDate {
    return Intl.message(
      'Expiration Date',
      name: 'expirationDate',
      desc: '',
      args: [],
    );
  }

  /// `Stored On`
  String get storedOn {
    return Intl.message('Stored On', name: 'storedOn', desc: '', args: []);
  }

  /// `My Request`
  String get myRequest {
    return Intl.message('My Request', name: 'myRequest', desc: '', args: []);
  }

  /// `Asset Details`
  String get assetDetails {
    return Intl.message(
      'Asset Details',
      name: 'assetDetails',
      desc: '',
      args: [],
    );
  }

  /// `Urgent`
  String get priorityUrgent {
    return Intl.message('Urgent', name: 'priorityUrgent', desc: '', args: []);
  }

  /// `High`
  String get priorityHigh {
    return Intl.message('High', name: 'priorityHigh', desc: '', args: []);
  }

  /// `Medium`
  String get priorityMedium {
    return Intl.message('Medium', name: 'priorityMedium', desc: '', args: []);
  }

  /// `Low`
  String get priorityLow {
    return Intl.message('Low', name: 'priorityLow', desc: '', args: []);
  }

  /// `Assets Name`
  String get assetsName {
    return Intl.message('Assets Name', name: 'assetsName', desc: '', args: []);
  }

  /// `Expected Delivery`
  String get expectedDelivery {
    return Intl.message(
      'Expected Delivery',
      name: 'expectedDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Expected Return`
  String get expectedReturn {
    return Intl.message(
      'Expected Return',
      name: 'expectedReturn',
      desc: '',
      args: [],
    );
  }

  /// `Priority`
  String get priority {
    return Intl.message('Priority', name: 'priority', desc: '', args: []);
  }

  /// `Submit For Approval`
  String get submitForApproval {
    return Intl.message(
      'Submit For Approval',
      name: 'submitForApproval',
      desc: '',
      args: [],
    );
  }

  /// `Date Received`
  String get dateReceived {
    return Intl.message(
      'Date Received',
      name: 'dateReceived',
      desc: '',
      args: [],
    );
  }

  /// `Next Scheduled Date`
  String get nextScheduledDate {
    return Intl.message(
      'Next Scheduled Date',
      name: 'nextScheduledDate',
      desc: '',
      args: [],
    );
  }

  /// `Canceled`
  String get canceled {
    return Intl.message('Canceled', name: 'canceled', desc: '', args: []);
  }

  /// `Rejected`
  String get rejected {
    return Intl.message('Rejected', name: 'rejected', desc: '', args: []);
  }

  /// `Pending`
  String get pending {
    return Intl.message('Pending', name: 'pending', desc: '', args: []);
  }

  /// `Approved`
  String get approved {
    return Intl.message('Approved', name: 'approved', desc: '', args: []);
  }

  /// `Request Type`
  String get requestType {
    return Intl.message(
      'Request Type',
      name: 'requestType',
      desc: '',
      args: [],
    );
  }

  /// `Create New Request`
  String get createNewRequest {
    return Intl.message(
      'Create New Request',
      name: 'createNewRequest',
      desc: '',
      args: [],
    );
  }

  /// `Branch`
  String get branch {
    return Intl.message('Branch', name: 'branch', desc: '', args: []);
  }

  /// `Allocated`
  String get allocated {
    return Intl.message('Allocated', name: 'allocated', desc: '', args: []);
  }

  /// `Asset Missing`
  String get assetMissing {
    return Intl.message(
      'Asset Missing',
      name: 'assetMissing',
      desc: '',
      args: [],
    );
  }

  /// `Routine Maintenance`
  String get routineMaintenance {
    return Intl.message(
      'Routine Maintenance',
      name: 'routineMaintenance',
      desc: '',
      args: [],
    );
  }

  /// `Asset Repair`
  String get assetRepair {
    return Intl.message(
      'Asset Repair',
      name: 'assetRepair',
      desc: '',
      args: [],
    );
  }

  /// `Asset Return`
  String get assetReturn {
    return Intl.message(
      'Asset Return',
      name: 'assetReturn',
      desc: '',
      args: [],
    );
  }

  /// `Pick Up Date`
  String get pickUpDate {
    return Intl.message('Pick Up Date', name: 'pickUpDate', desc: '', args: []);
  }

  /// `Due Date of Return`
  String get dueDateOfReturn {
    return Intl.message(
      'Due Date of Return',
      name: 'dueDateOfReturn',
      desc: '',
      args: [],
    );
  }

  /// `Expected Lifetime Ended`
  String get expectedLifetimeEnded {
    return Intl.message(
      'Expected Lifetime Ended',
      name: 'expectedLifetimeEnded',
      desc: '',
      args: [],
    );
  }

  /// `Reason Of Return`
  String get reasonOfReturn {
    return Intl.message(
      'Reason Of Return',
      name: 'reasonOfReturn',
      desc: '',
      args: [],
    );
  }

  /// `New Request`
  String get newRequest {
    return Intl.message('New Request', name: 'newRequest', desc: '', args: []);
  }

  /// `Are you sure you want to create this request?`
  String get confirmCreateRequest {
    return Intl.message(
      'Are you sure you want to create this request?',
      name: 'confirmCreateRequest',
      desc: '',
      args: [],
    );
  }

  /// `You successfully created this request.`
  String get successCreateRequest {
    return Intl.message(
      'You successfully created this request.',
      name: 'successCreateRequest',
      desc: '',
      args: [],
    );
  }

  /// `Employee Name`
  String get employeeName {
    return Intl.message(
      'Employee Name',
      name: 'employeeName',
      desc: '',
      args: [],
    );
  }

  /// `Description of Issue/Service Needed`
  String get descriptionOfIssue {
    return Intl.message(
      'Description of Issue/Service Needed',
      name: 'descriptionOfIssue',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance Date`
  String get maintenanceDate {
    return Intl.message(
      'Maintenance Date',
      name: 'maintenanceDate',
      desc: '',
      args: [],
    );
  }

  /// `Approve`
  String get approve {
    return Intl.message('Approve', name: 'approve', desc: '', args: []);
  }

  /// `Reject`
  String get reject {
    return Intl.message('Reject', name: 'reject', desc: '', args: []);
  }

  /// `Approve Request`
  String get approveRequest {
    return Intl.message(
      'Approve Request',
      name: 'approveRequest',
      desc: '',
      args: [],
    );
  }

  /// `Reject Request`
  String get rejectRequest {
    return Intl.message(
      'Reject Request',
      name: 'rejectRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to approve this request?`
  String get areYouSureYouWantToApproveThisRequest {
    return Intl.message(
      'Are you sure you want to approve this request?',
      name: 'areYouSureYouWantToApproveThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to reject this request?`
  String get areYouSureYouWantToRejectThisRequest {
    return Intl.message(
      'Are you sure you want to reject this request?',
      name: 'areYouSureYouWantToRejectThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `Reason of Approval`
  String get reasonOfApprove {
    return Intl.message(
      'Reason of Approval',
      name: 'reasonOfApprove',
      desc: '',
      args: [],
    );
  }

  /// `Justifications`
  String get justifications {
    return Intl.message(
      'Justifications',
      name: 'justifications',
      desc: '',
      args: [],
    );
  }

  /// `You successfully approved this request`
  String get youSuccessfullyApprovedThisRequest {
    return Intl.message(
      'You successfully approved this request',
      name: 'youSuccessfullyApprovedThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `You successfully rejected this request`
  String get youSuccessfullyRejectedThisRequest {
    return Intl.message(
      'You successfully rejected this request',
      name: 'youSuccessfullyRejectedThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `Approval Justification`
  String get approvalJustification {
    return Intl.message(
      'Approval Justification',
      name: 'approvalJustification',
      desc: '',
      args: [],
    );
  }

  /// `Optional`
  String get optional {
    return Intl.message('Optional', name: 'optional', desc: '', args: []);
  }

  /// `Request Name`
  String get requestName {
    return Intl.message(
      'Request Name',
      name: 'requestName',
      desc: '',
      args: [],
    );
  }

  /// `Overall`
  String get overall {
    return Intl.message('Overall', name: 'overall', desc: '', args: []);
  }

  /// `Warehouses`
  String get warehouses {
    return Intl.message('Warehouses', name: 'warehouses', desc: '', args: []);
  }

  /// `Stocks Overview`
  String get stocksOverview {
    return Intl.message(
      'Stocks Overview',
      name: 'stocksOverview',
      desc: '',
      args: [],
    );
  }

  /// `Demands`
  String get demands {
    return Intl.message('Demands', name: 'demands', desc: '', args: []);
  }

  /// `Order Fulfillment Status`
  String get orderFulfillmentStatus {
    return Intl.message(
      'Order Fulfillment Status',
      name: 'orderFulfillmentStatus',
      desc: '',
      args: [],
    );
  }

  /// `Sort`
  String get sort {
    return Intl.message('Sort', name: 'sort', desc: '', args: []);
  }

  /// `Product Consumption`
  String get productConsumption {
    return Intl.message(
      'Product Consumption',
      name: 'productConsumption',
      desc: '',
      args: [],
    );
  }

  /// `Products Discrepancy`
  String get productsDiscrepancy {
    return Intl.message(
      'Products Discrepancy',
      name: 'productsDiscrepancy',
      desc: '',
      args: [],
    );
  }

  /// `Expenses`
  String get expenses {
    return Intl.message('Expenses', name: 'expenses', desc: '', args: []);
  }

  /// `Maintenance Requests`
  String get maintenanceRequests {
    return Intl.message(
      'Maintenance Requests',
      name: 'maintenanceRequests',
      desc: '',
      args: [],
    );
  }

  /// `Assets Name Details`
  String get assetsNameDetails {
    return Intl.message(
      'Assets Name Details',
      name: 'assetsNameDetails',
      desc: '',
      args: [],
    );
  }

  /// `Retrieve Product`
  String get retrieveProduct {
    return Intl.message(
      'Retrieve Product',
      name: 'retrieveProduct',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to retrieve this product?`
  String get confirmRetrieveProduct {
    return Intl.message(
      'Are you sure you want to retrieve this product?',
      name: 'confirmRetrieveProduct',
      desc: '',
      args: [],
    );
  }

  /// `You successfully retrieved this product`
  String get successRetrieveProduct {
    return Intl.message(
      'You successfully retrieved this product',
      name: 'successRetrieveProduct',
      desc: '',
      args: [],
    );
  }

  /// `Assigning History`
  String get assigningHistory {
    return Intl.message(
      'Assigning History',
      name: 'assigningHistory',
      desc: '',
      args: [],
    );
  }

  /// `Service History`
  String get serviceHistory {
    return Intl.message(
      'Service History',
      name: 'serviceHistory',
      desc: '',
      args: [],
    );
  }

  /// `Unassigned`
  String get unassigned {
    return Intl.message('Unassigned', name: 'unassigned', desc: '', args: []);
  }

  /// `Assigning Assets`
  String get assigningAssets {
    return Intl.message(
      'Assigning Assets',
      name: 'assigningAssets',
      desc: '',
      args: [],
    );
  }

  /// `Assigning Asset`
  String get assigningAsset {
    return Intl.message(
      'Assigning Asset',
      name: 'assigningAsset',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to assign this asset?`
  String get confirmAssignAsset {
    return Intl.message(
      'Are you sure you want to assign this asset?',
      name: 'confirmAssignAsset',
      desc: '',
      args: [],
    );
  }

  /// `You successfully assigned this asset`
  String get successAssignAsset {
    return Intl.message(
      'You successfully assigned this asset',
      name: 'successAssignAsset',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance ID`
  String get maintenanceId {
    return Intl.message(
      'Maintenance ID',
      name: 'maintenanceId',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance Status`
  String get maintenanceStatus {
    return Intl.message(
      'Maintenance Status',
      name: 'maintenanceStatus',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance Service`
  String get maintenanceService {
    return Intl.message(
      'Maintenance Service',
      name: 'maintenanceService',
      desc: '',
      args: [],
    );
  }

  /// `Assigned To`
  String get assignedTo {
    return Intl.message('Assigned To', name: 'assignedTo', desc: '', args: []);
  }

  /// `Assignment Date`
  String get assignmentDate {
    return Intl.message(
      'Assignment Date',
      name: 'assignmentDate',
      desc: '',
      args: [],
    );
  }

  /// `Estimated Completion Date`
  String get estimatedCompletionDate {
    return Intl.message(
      'Estimated Completion Date',
      name: 'estimatedCompletionDate',
      desc: '',
      args: [],
    );
  }

  /// `Next Scheduled Maintenance`
  String get nextScheduledMaintenance {
    return Intl.message(
      'Next Scheduled Maintenance',
      name: 'nextScheduledMaintenance',
      desc: '',
      args: [],
    );
  }

  /// `Damage Type`
  String get damageType {
    return Intl.message('Damage Type', name: 'damageType', desc: '', args: []);
  }

  /// `Severity Level`
  String get severityLevel {
    return Intl.message(
      'Severity Level',
      name: 'severityLevel',
      desc: '',
      args: [],
    );
  }

  /// `Warranty & Coverage Status`
  String get warrantyCoverageStatus {
    return Intl.message(
      'Warranty & Coverage Status',
      name: 'warrantyCoverageStatus',
      desc: '',
      args: [],
    );
  }

  /// `Warranty Expiration Date`
  String get warrantyExpirationDate {
    return Intl.message(
      'Warranty Expiration Date',
      name: 'warrantyExpirationDate',
      desc: '',
      args: [],
    );
  }

  /// `Recommended Action`
  String get recommendedAction {
    return Intl.message(
      'Recommended Action',
      name: 'recommendedAction',
      desc: '',
      args: [],
    );
  }

  /// `Asset Conditions`
  String get assetConditions {
    return Intl.message(
      'Asset Conditions',
      name: 'assetConditions',
      desc: '',
      args: [],
    );
  }

  /// `Work Performed/Service Actions`
  String get workPerformed {
    return Intl.message(
      'Work Performed/Service Actions',
      name: 'workPerformed',
      desc: '',
      args: [],
    );
  }

  /// `List Of Items Replaced/Used`
  String get itemsReplacedUsed {
    return Intl.message(
      'List Of Items Replaced/Used',
      name: 'itemsReplacedUsed',
      desc: '',
      args: [],
    );
  }

  /// `On Hold`
  String get onHold {
    return Intl.message('On Hold', name: 'onHold', desc: '', args: []);
  }

  /// `Select Damage Type`
  String get selectDamageType {
    return Intl.message(
      'Select Damage Type',
      name: 'selectDamageType',
      desc: '',
      args: [],
    );
  }

  /// `Select Severity Level`
  String get selectSeverityLevel {
    return Intl.message(
      'Select Severity Level',
      name: 'selectSeverityLevel',
      desc: '',
      args: [],
    );
  }

  /// `Select Asset Conditions`
  String get selectAssetConditions {
    return Intl.message(
      'Select Asset Conditions',
      name: 'selectAssetConditions',
      desc: '',
      args: [],
    );
  }

  /// `Select Recommended Action`
  String get selectRecommendedAction {
    return Intl.message(
      'Select Recommended Action',
      name: 'selectRecommendedAction',
      desc: '',
      args: [],
    );
  }

  /// `Select Warranty & Coverage Status`
  String get selectWarrantyCoverageStatus {
    return Intl.message(
      'Select Warranty & Coverage Status',
      name: 'selectWarrantyCoverageStatus',
      desc: '',
      args: [],
    );
  }

  /// `Edit your message`
  String get editYourMessage {
    return Intl.message(
      'Edit your message',
      name: 'editYourMessage',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Inquiries And Comments`
  String get inquiriesAndComments {
    return Intl.message(
      'Inquiries And Comments',
      name: 'inquiriesAndComments',
      desc: '',
      args: [],
    );
  }

  /// `Write a comment`
  String get writeAComment {
    return Intl.message(
      'Write a comment',
      name: 'writeAComment',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get open {
    return Intl.message('Open', name: 'open', desc: '', args: []);
  }

  /// `Received`
  String get received {
    return Intl.message('Received', name: 'received', desc: '', args: []);
  }

  /// `Partially Received`
  String get partiallyReceived {
    return Intl.message(
      'Partially Received',
      name: 'partiallyReceived',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get cancelled {
    return Intl.message('Cancelled', name: 'cancelled', desc: '', args: []);
  }

  /// `Draft`
  String get test {
    return Intl.message('Draft', name: 'test', desc: '', args: []);
  }

  /// `Permissions`
  String get permissions {
    return Intl.message('Permissions', name: 'permissions', desc: '', args: []);
  }

  /// `Inventory`
  String get inventory {
    return Intl.message('Inventory', name: 'inventory', desc: '', args: []);
  }

  /// `In-Service Date`
  String get inServiceDate {
    return Intl.message(
      'In-Service Date',
      name: 'inServiceDate',
      desc: '',
      args: [],
    );
  }

  /// `Action Taken`
  String get actionTaken {
    return Intl.message(
      'Action Taken',
      name: 'actionTaken',
      desc: '',
      args: [],
    );
  }

  /// `Missing Date`
  String get missingDate {
    return Intl.message(
      'Missing Date',
      name: 'missingDate',
      desc: '',
      args: [],
    );
  }

  /// `Last Seen Location`
  String get lastSeenLocation {
    return Intl.message(
      'Last Seen Location',
      name: 'lastSeenLocation',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance Inspector`
  String get maintenanceInspector {
    return Intl.message(
      'Maintenance Inspector',
      name: 'maintenanceInspector',
      desc: '',
      args: [],
    );
  }

  /// `Accessories Returned`
  String get accessoriesReturned {
    return Intl.message(
      'Accessories Returned',
      name: 'accessoriesReturned',
      desc: '',
      args: [],
    );
  }

  /// `Reviewed Date`
  String get reviewedDate {
    return Intl.message(
      'Reviewed Date',
      name: 'reviewedDate',
      desc: '',
      args: [],
    );
  }

  /// `Next Disposition`
  String get nextDisposition {
    return Intl.message(
      'Next Disposition',
      name: 'nextDisposition',
      desc: '',
      args: [],
    );
  }

  /// `Notes & Observations`
  String get notesObservations {
    return Intl.message(
      'Notes & Observations',
      name: 'notesObservations',
      desc: '',
      args: [],
    );
  }

  /// `Write-Off`
  String get writeOff {
    return Intl.message('Write-Off', name: 'writeOff', desc: '', args: []);
  }

  /// `Contact`
  String get contact {
    return Intl.message('Contact', name: 'contact', desc: '', args: []);
  }

  /// `Address`
  String get address {
    return Intl.message('Address', name: 'address', desc: '', args: []);
  }

  /// `Warehouse Name`
  String get warehouseName {
    return Intl.message(
      'Warehouse Name',
      name: 'warehouseName',
      desc: '',
      args: [],
    );
  }

  /// `Warehouses Details`
  String get warehousesDetails {
    return Intl.message(
      'Warehouses Details',
      name: 'warehousesDetails',
      desc: '',
      args: [],
    );
  }

  /// `Supplier Edited`
  String get supplierEdited {
    return Intl.message(
      'Supplier Edited',
      name: 'supplierEdited',
      desc: '',
      args: [],
    );
  }

  /// `You successfully edited this supplier`
  String get successfullyEditedSupplier {
    return Intl.message(
      'You successfully edited this supplier',
      name: 'successfullyEditedSupplier',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to edit this supplier?`
  String get confirmEditSupplier {
    return Intl.message(
      'Are you sure you want to edit this supplier?',
      name: 'confirmEditSupplier',
      desc: '',
      args: [],
    );
  }

  /// `Editing Supplier Details`
  String get editingSupplierDetails {
    return Intl.message(
      'Editing Supplier Details',
      name: 'editingSupplierDetails',
      desc: '',
      args: [],
    );
  }

  /// `Asset Request`
  String get assetRequest {
    return Intl.message(
      'Asset Request',
      name: 'assetRequest',
      desc: '',
      args: [],
    );
  }

  /// `Receiving Method`
  String get receivingMethod {
    return Intl.message(
      'Receiving Method',
      name: 'receivingMethod',
      desc: '',
      args: [],
    );
  }

  /// `Location Delivery`
  String get locationDelivery {
    return Intl.message(
      'Location Delivery',
      name: 'locationDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Schedule`
  String get schedule {
    return Intl.message('Schedule', name: 'schedule', desc: '', args: []);
  }

  /// `Requested`
  String get requested {
    return Intl.message('Requested', name: 'requested', desc: '', args: []);
  }

  /// `Type`
  String get type {
    return Intl.message('Type', name: 'type', desc: '', args: []);
  }

  /// `Type of Asset Request`
  String get typeOfAssetRequest {
    return Intl.message(
      'Type of Asset Request',
      name: 'typeOfAssetRequest',
      desc: '',
      args: [],
    );
  }

  /// `Office Coordinates`
  String get officeCoordinates {
    return Intl.message(
      'Office Coordinates',
      name: 'officeCoordinates',
      desc: '',
      args: [],
    );
  }

  /// `Reason for Request`
  String get reasonForRequest {
    return Intl.message(
      'Reason for Request',
      name: 'reasonForRequest',
      desc: '',
      args: [],
    );
  }

  /// `Requesting Asset`
  String get requestingAsset {
    return Intl.message(
      'Requesting Asset',
      name: 'requestingAsset',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to request this asset?`
  String get areYouSureToRequestAsset {
    return Intl.message(
      'Are you sure you want to request this asset?',
      name: 'areYouSureToRequestAsset',
      desc: '',
      args: [],
    );
  }

  /// `Asset Requested`
  String get assetRequested {
    return Intl.message(
      'Asset Requested',
      name: 'assetRequested',
      desc: '',
      args: [],
    );
  }

  /// `You successfully requested this asset`
  String get successfullyRequestedAsset {
    return Intl.message(
      'You successfully requested this asset',
      name: 'successfullyRequestedAsset',
      desc: '',
      args: [],
    );
  }

  /// `Repair`
  String get repair {
    return Intl.message('Repair', name: 'repair', desc: '', args: []);
  }

  /// `Send Reminder`
  String get sendReminder {
    return Intl.message(
      'Send Reminder',
      name: 'sendReminder',
      desc: '',
      args: [],
    );
  }

  /// `Submission Date`
  String get submissionDate {
    return Intl.message(
      'Submission Date',
      name: 'submissionDate',
      desc: '',
      args: [],
    );
  }

  /// `Entry Date`
  String get entryDate {
    return Intl.message('Entry Date', name: 'entryDate', desc: '', args: []);
  }

  /// `Batch ID`
  String get batchId {
    return Intl.message('Batch ID', name: 'batchId', desc: '', args: []);
  }

  /// `Category / Subcategory`
  String get categorySubcategory {
    return Intl.message(
      'Category / Subcategory',
      name: 'categorySubcategory',
      desc: '',
      args: [],
    );
  }

  /// `Unit Price`
  String get unitPrice {
    return Intl.message('Unit Price', name: 'unitPrice', desc: '', args: []);
  }

  /// `VAT`
  String get vat {
    return Intl.message('VAT', name: 'vat', desc: '', args: []);
  }

  /// `Final Amount`
  String get finalAmount {
    return Intl.message(
      'Final Amount',
      name: 'finalAmount',
      desc: '',
      args: [],
    );
  }

  /// `Total Assigned Tasks`
  String get totalAssignedTasks {
    return Intl.message(
      'Total Assigned Tasks',
      name: 'totalAssignedTasks',
      desc: '',
      args: [],
    );
  }

  /// `Under Maintenance`
  String get underMaintenance {
    return Intl.message(
      'Under Maintenance',
      name: 'underMaintenance',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get completed {
    return Intl.message('Completed', name: 'completed', desc: '', args: []);
  }

  /// `Standard Storage`
  String get standardStorage {
    return Intl.message(
      'Standard Storage',
      name: 'standardStorage',
      desc: '',
      args: [],
    );
  }

  /// `Temperature-Controlled`
  String get temperatureControlled {
    return Intl.message(
      'Temperature-Controlled',
      name: 'temperatureControlled',
      desc: '',
      args: [],
    );
  }

  /// `Humidity-Controlled`
  String get humidityControlled {
    return Intl.message(
      'Humidity-Controlled',
      name: 'humidityControlled',
      desc: '',
      args: [],
    );
  }

  /// `Dry Storage`
  String get dryStorage {
    return Intl.message('Dry Storage', name: 'dryStorage', desc: '', args: []);
  }

  /// `Flammable Storage`
  String get flammableStorage {
    return Intl.message(
      'Flammable Storage',
      name: 'flammableStorage',
      desc: '',
      args: [],
    );
  }

  /// `Hazardous Material Storage`
  String get hazardousMaterialStorage {
    return Intl.message(
      'Hazardous Material Storage',
      name: 'hazardousMaterialStorage',
      desc: '',
      args: [],
    );
  }

  /// `Secure / Restricted Access`
  String get secureRestrictedAccess {
    return Intl.message(
      'Secure / Restricted Access',
      name: 'secureRestrictedAccess',
      desc: '',
      args: [],
    );
  }

  /// `Fragile – Handle with Care`
  String get fragileHandleWithCare {
    return Intl.message(
      'Fragile – Handle with Care',
      name: 'fragileHandleWithCare',
      desc: '',
      args: [],
    );
  }

  /// `Outdoor Storage`
  String get outdoorStorage {
    return Intl.message(
      'Outdoor Storage',
      name: 'outdoorStorage',
      desc: '',
      args: [],
    );
  }

  /// `Heavy-Duty Storage`
  String get heavyDutyStorage {
    return Intl.message(
      'Heavy-Duty Storage',
      name: 'heavyDutyStorage',
      desc: '',
      args: [],
    );
  }

  /// `Radiation-Protected Storage`
  String get radiationProtectedStorage {
    return Intl.message(
      'Radiation-Protected Storage',
      name: 'radiationProtectedStorage',
      desc: '',
      args: [],
    );
  }

  /// `Cold Chain Logistics`
  String get coldChainLogistics {
    return Intl.message(
      'Cold Chain Logistics',
      name: 'coldChainLogistics',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure To Proceed`
  String get areYouSureToProceed {
    return Intl.message(
      'Are You Sure To Proceed',
      name: 'areYouSureToProceed',
      desc: '',
      args: [],
    );
  }

  /// `Proceed`
  String get proceed {
    return Intl.message('Proceed', name: 'proceed', desc: '', args: []);
  }

  /// `Product`
  String get productN {
    return Intl.message('Product', name: 'productN', desc: '', args: []);
  }

  /// `Please choose a storage location for all added rows.`
  String get chooseStorageLocation {
    return Intl.message(
      'Please choose a storage location for all added rows.',
      name: 'chooseStorageLocation',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a positive quantity for location.`
  String get positiveQuantityLocation {
    return Intl.message(
      'Please enter a positive quantity for location.',
      name: 'positiveQuantityLocation',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a positive quantity for the default storage location.`
  String get positiveQuantityDefaultLocation {
    return Intl.message(
      'Please enter a positive quantity for the default storage location.',
      name: 'positiveQuantityDefaultLocation',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate storage location.`
  String get duplicateStorageLocation {
    return Intl.message(
      'Duplicate storage location.',
      name: 'duplicateStorageLocation',
      desc: '',
      args: [],
    );
  }

  /// `This is not allowed.`
  String get notAllowed {
    return Intl.message(
      'This is not allowed.',
      name: 'notAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Please complete all required fields before continuing.`
  String get completeRequiredFields {
    return Intl.message(
      'Please complete all required fields before continuing.',
      name: 'completeRequiredFields',
      desc: '',
      args: [],
    );
  }

  /// `Incomplete Form`
  String get incompleteForm {
    return Intl.message(
      'Incomplete Form',
      name: 'incompleteForm',
      desc: '',
      args: [],
    );
  }

  /// `Selected`
  String get selected {
    return Intl.message('Selected', name: 'selected', desc: '', args: []);
  }

  /// `Please complete all required fields before submitting.`
  String get completeRequiredFieldsBeforeSubmitting {
    return Intl.message(
      'Please complete all required fields before submitting.',
      name: 'completeRequiredFieldsBeforeSubmitting',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continueText {
    return Intl.message('Continue', name: 'continueText', desc: '', args: []);
  }

  /// `Do you want to proceed to the next product?`
  String get doYouWantToProceedToNextProduct {
    return Intl.message(
      'Do you want to proceed to the next product?',
      name: 'doYouWantToProceedToNextProduct',
      desc: '',
      args: [],
    );
  }

  /// `Continue to Next Product`
  String get continueToNextProduct {
    return Intl.message(
      'Continue to Next Product',
      name: 'continueToNextProduct',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to add this product?`
  String get areYouSureYouWantToAddThisProduct {
    return Intl.message(
      'Are you sure you want to add this product?',
      name: 'areYouSureYouWantToAddThisProduct',
      desc: '',
      args: [],
    );
  }

  /// `Editing Product Details`
  String get editingProductDetails {
    return Intl.message(
      'Editing Product Details',
      name: 'editingProductDetails',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to edit this product?`
  String get areYouSureEditProduct {
    return Intl.message(
      'Are you sure you want to edit this product?',
      name: 'areYouSureEditProduct',
      desc: '',
      args: [],
    );
  }

  /// `Supplier ID`
  String get supplierID {
    return Intl.message('Supplier ID', name: 'supplierID', desc: '', args: []);
  }

  /// `Created`
  String get created {
    return Intl.message('Created', name: 'created', desc: '', args: []);
  }

  /// `Location ID`
  String get locationID {
    return Intl.message('Location ID', name: 'locationID', desc: '', args: []);
  }

  /// `Capacity`
  String get capacity {
    return Intl.message('Capacity', name: 'capacity', desc: '', args: []);
  }

  /// `Adding New Order`
  String get addingNewOrder {
    return Intl.message(
      'Adding New Order',
      name: 'addingNewOrder',
      desc: '',
      args: [],
    );
  }

  /// `Order & Product Details`
  String get orderAndProductDetails {
    return Intl.message(
      'Order & Product Details',
      name: 'orderAndProductDetails',
      desc: '',
      args: [],
    );
  }

  /// `Select Order Type`
  String get selectOrderType {
    return Intl.message(
      'Select Order Type',
      name: 'selectOrderType',
      desc: '',
      args: [],
    );
  }

  /// `Add new item`
  String get addNewItem {
    return Intl.message('Add new item', name: 'addNewItem', desc: '', args: []);
  }

  /// `Saved to history`
  String get savedToHistory {
    return Intl.message(
      'Saved to history',
      name: 'savedToHistory',
      desc: '',
      args: [],
    );
  }

  /// `Discount Percentage`
  String get discountPercentage {
    return Intl.message(
      'Discount Percentage',
      name: 'discountPercentage',
      desc: '',
      args: [],
    );
  }

  /// `Payment Method`
  String get paymentMethod {
    return Intl.message(
      'Payment Method',
      name: 'paymentMethod',
      desc: '',
      args: [],
    );
  }

  /// `Shipping`
  String get shipping {
    return Intl.message('Shipping', name: 'shipping', desc: '', args: []);
  }

  /// `Order Value`
  String get orderValue {
    return Intl.message('Order Value', name: 'orderValue', desc: '', args: []);
  }

  /// `Method of Payment`
  String get methodOfPayment {
    return Intl.message(
      'Method of Payment',
      name: 'methodOfPayment',
      desc: '',
      args: [],
    );
  }

  /// `Advanced Payment`
  String get advancedPayment {
    return Intl.message(
      'Advanced Payment',
      name: 'advancedPayment',
      desc: '',
      args: [],
    );
  }

  /// `Supplier Bank Transfer Details`
  String get supplierBankTransferDetails {
    return Intl.message(
      'Supplier Bank Transfer Details',
      name: 'supplierBankTransferDetails',
      desc: '',
      args: [],
    );
  }

  /// `Already exists and selected`
  String get alreadyExistsAndSelected {
    return Intl.message(
      'Already exists and selected',
      name: 'alreadyExistsAndSelected',
      desc: '',
      args: [],
    );
  }

  /// `Item added successfully`
  String get itemAddSuccessful {
    return Intl.message(
      'Item added successfully',
      name: 'itemAddSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Cash`
  String get deliveryMethodCash {
    return Intl.message('Cash', name: 'deliveryMethodCash', desc: '', args: []);
  }

  /// `Credit Card`
  String get deliveryMethodCreditCard {
    return Intl.message(
      'Credit Card',
      name: 'deliveryMethodCreditCard',
      desc: '',
      args: [],
    );
  }

  /// `Bank Transfer`
  String get deliveryMethodBankTransfer {
    return Intl.message(
      'Bank Transfer',
      name: 'deliveryMethodBankTransfer',
      desc: '',
      args: [],
    );
  }

  /// `Cheque`
  String get deliveryMethodCheque {
    return Intl.message(
      'Cheque',
      name: 'deliveryMethodCheque',
      desc: '',
      args: [],
    );
  }

  /// `On Account`
  String get deliveryMethodOnAccount {
    return Intl.message(
      'On Account',
      name: 'deliveryMethodOnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Advanced Payment`
  String get deliveryMethodAdvancedPayment {
    return Intl.message(
      'Advanced Payment',
      name: 'deliveryMethodAdvancedPayment',
      desc: '',
      args: [],
    );
  }

  /// `Installments`
  String get deliveryMethodInstallments {
    return Intl.message(
      'Installments',
      name: 'deliveryMethodInstallments',
      desc: '',
      args: [],
    );
  }

  /// `Cash On Delivery`
  String get deliveryMethodCashOnDelivery {
    return Intl.message(
      'Cash On Delivery',
      name: 'deliveryMethodCashOnDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Delivery`
  String get delivery {
    return Intl.message('Delivery', name: 'delivery', desc: '', args: []);
  }

  /// `Product Added`
  String get productAdded {
    return Intl.message(
      'Product Added',
      name: 'productAdded',
      desc: '',
      args: [],
    );
  }

  /// `You successfully added this product`
  String get youSuccessfullyAddedThisProduct {
    return Intl.message(
      'You successfully added this product',
      name: 'youSuccessfullyAddedThisProduct',
      desc: '',
      args: [],
    );
  }

  /// `Add Supplier`
  String get addSupplier {
    return Intl.message(
      'Add Supplier',
      name: 'addSupplier',
      desc: '',
      args: [],
    );
  }

  /// `Add Location`
  String get addLocation {
    return Intl.message(
      'Add Location',
      name: 'addLocation',
      desc: '',
      args: [],
    );
  }

  /// `Adding New Supplier`
  String get addingNewSupplier {
    return Intl.message(
      'Adding New Supplier',
      name: 'addingNewSupplier',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Add This Supplier?`
  String get areYouSureAddSupplier {
    return Intl.message(
      'Are You Sure You Want To Add This Supplier?',
      name: 'areYouSureAddSupplier',
      desc: '',
      args: [],
    );
  }

  /// `New Supplier Added`
  String get newSupplierAdded {
    return Intl.message(
      'New Supplier Added',
      name: 'newSupplierAdded',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Added This Supplier`
  String get supplierAddedSuccessfully {
    return Intl.message(
      'You Successfully Added This Supplier',
      name: 'supplierAddedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Adding Order`
  String get addOrder {
    return Intl.message('Adding Order', name: 'addOrder', desc: '', args: []);
  }

  /// `Are you sure you want to add this order`
  String get areYouSureAddingOrder {
    return Intl.message(
      'Are you sure you want to add this order',
      name: 'areYouSureAddingOrder',
      desc: '',
      args: [],
    );
  }

  /// `Order added successfully`
  String get addingOrderSuccessfully {
    return Intl.message(
      'Order added successfully',
      name: 'addingOrderSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Invoice Details`
  String get invoiceDetails {
    return Intl.message(
      'Invoice Details',
      name: 'invoiceDetails',
      desc: '',
      args: [],
    );
  }

  /// `No attachments available`
  String get noAttachmentsAvailable {
    return Intl.message(
      'No attachments available',
      name: 'noAttachmentsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No orders found`
  String get noOrdersFound {
    return Intl.message(
      'No orders found',
      name: 'noOrdersFound',
      desc: '',
      args: [],
    );
  }

  /// `Download Page`
  String get downloadPage {
    return Intl.message(
      'Download Page',
      name: 'downloadPage',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to download this page`
  String get areYouSureDownloadPage {
    return Intl.message(
      'Are you sure you want to download this page',
      name: 'areYouSureDownloadPage',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully download This page`
  String get successDownloadPage {
    return Intl.message(
      'You Successfully download This page',
      name: 'successDownloadPage',
      desc: '',
      args: [],
    );
  }

  /// `Add New Storage`
  String get addNewStorage {
    return Intl.message(
      'Add New Storage',
      name: 'addNewStorage',
      desc: '',
      args: [],
    );
  }

  /// `Storage Location ID`
  String get storageLocationId {
    return Intl.message(
      'Storage Location ID',
      name: 'storageLocationId',
      desc: '',
      args: [],
    );
  }

  /// `Adding New Storage Location`
  String get addingNewStorageLocation {
    return Intl.message(
      'Adding New Storage Location',
      name: 'addingNewStorageLocation',
      desc: '',
      args: [],
    );
  }

  /// `Location Type`
  String get locationType {
    return Intl.message(
      'Location Type',
      name: 'locationType',
      desc: '',
      args: [],
    );
  }

  /// `Location Details`
  String get locationDetails {
    return Intl.message(
      'Location Details',
      name: 'locationDetails',
      desc: '',
      args: [],
    );
  }

  /// `Public Access`
  String get publicAccess {
    return Intl.message(
      'Public Access',
      name: 'publicAccess',
      desc: '',
      args: [],
    );
  }

  /// `Internal Access Only`
  String get internalAccessOnly {
    return Intl.message(
      'Internal Access Only',
      name: 'internalAccessOnly',
      desc: '',
      args: [],
    );
  }

  /// `Authorized Personnel Only`
  String get authorizedPersonnelOnly {
    return Intl.message(
      'Authorized Personnel Only',
      name: 'authorizedPersonnelOnly',
      desc: '',
      args: [],
    );
  }

  /// `Department-Restricted`
  String get departmentRestricted {
    return Intl.message(
      'Department-Restricted',
      name: 'departmentRestricted',
      desc: '',
      args: [],
    );
  }

  /// `Managerial Access`
  String get managerialAccess {
    return Intl.message(
      'Managerial Access',
      name: 'managerialAccess',
      desc: '',
      args: [],
    );
  }

  /// `Admin-Only Access`
  String get adminOnlyAccess {
    return Intl.message(
      'Admin-Only Access',
      name: 'adminOnlyAccess',
      desc: '',
      args: [],
    );
  }

  /// `Confidential / Secure Access`
  String get confidentialSecureAccess {
    return Intl.message(
      'Confidential / Secure Access',
      name: 'confidentialSecureAccess',
      desc: '',
      args: [],
    );
  }

  /// `Units`
  String get units {
    return Intl.message('Units', name: 'units', desc: '', args: []);
  }

  /// `Volume`
  String get volume {
    return Intl.message('Volume', name: 'volume', desc: '', args: []);
  }

  /// `Pallet Space`
  String get palletSpace {
    return Intl.message(
      'Pallet Space',
      name: 'palletSpace',
      desc: '',
      args: [],
    );
  }

  /// `Weight`
  String get weight {
    return Intl.message('Weight', name: 'weight', desc: '', args: []);
  }

  /// `Standard`
  String get standard {
    return Intl.message('Standard', name: 'standard', desc: '', args: []);
  }

  /// `Cold Storage`
  String get coldStorage {
    return Intl.message(
      'Cold Storage',
      name: 'coldStorage',
      desc: '',
      args: [],
    );
  }

  /// `Frozen Storage`
  String get frozenStorage {
    return Intl.message(
      'Frozen Storage',
      name: 'frozenStorage',
      desc: '',
      args: [],
    );
  }

  /// `Ambient Storage`
  String get ambientStorage {
    return Intl.message(
      'Ambient Storage',
      name: 'ambientStorage',
      desc: '',
      args: [],
    );
  }

  /// `Secure Storage`
  String get secureStorage {
    return Intl.message(
      'Secure Storage',
      name: 'secureStorage',
      desc: '',
      args: [],
    );
  }

  /// `Warehouse`
  String get warehouse {
    return Intl.message('Warehouse', name: 'warehouse', desc: '', args: []);
  }

  /// `Main Storage`
  String get mainStorage {
    return Intl.message(
      'Main Storage',
      name: 'mainStorage',
      desc: '',
      args: [],
    );
  }

  /// `Secure Vault`
  String get secureVault {
    return Intl.message(
      'Secure Vault',
      name: 'secureVault',
      desc: '',
      args: [],
    );
  }

  /// `Outdoor Yard`
  String get outdoorYard {
    return Intl.message(
      'Outdoor Yard',
      name: 'outdoorYard',
      desc: '',
      args: [],
    );
  }

  /// `Locker`
  String get locker {
    return Intl.message('Locker', name: 'locker', desc: '', args: []);
  }

  /// `Cabinet`
  String get cabinet {
    return Intl.message('Cabinet', name: 'cabinet', desc: '', args: []);
  }

  /// `Shelf`
  String get shelf {
    return Intl.message('Shelf', name: 'shelf', desc: '', args: []);
  }

  /// `Dispatch Zone`
  String get dispatchZone {
    return Intl.message(
      'Dispatch Zone',
      name: 'dispatchZone',
      desc: '',
      args: [],
    );
  }

  /// `Receiving Zone`
  String get receivingZone {
    return Intl.message(
      'Receiving Zone',
      name: 'receivingZone',
      desc: '',
      args: [],
    );
  }

  /// `Archive Room`
  String get archiveRoom {
    return Intl.message(
      'Archive Room',
      name: 'archiveRoom',
      desc: '',
      args: [],
    );
  }

  /// `External`
  String get external {
    return Intl.message('External', name: 'external', desc: '', args: []);
  }

  /// `Forklift`
  String get forklift {
    return Intl.message('Forklift', name: 'forklift', desc: '', args: []);
  }

  /// `Hand Pallet Truck (Manual Jack)`
  String get handPalletTruck {
    return Intl.message(
      'Hand Pallet Truck (Manual Jack)',
      name: 'handPalletTruck',
      desc: '',
      args: [],
    );
  }

  /// `Notified Security Team`
  String get notifiedSecurityTeam {
    return Intl.message(
      'Notified Security Team',
      name: 'notifiedSecurityTeam',
      desc: '',
      args: [],
    );
  }

  /// `Conveyor System`
  String get conveyorSystem {
    return Intl.message(
      'Conveyor System',
      name: 'conveyorSystem',
      desc: '',
      args: [],
    );
  }

  /// `Lifting Crane / Hoist`
  String get liftingCrane {
    return Intl.message(
      'Lifting Crane / Hoist',
      name: 'liftingCrane',
      desc: '',
      args: [],
    );
  }

  /// `Shelving / Racking System`
  String get shelvingRackingSystem {
    return Intl.message(
      'Shelving / Racking System',
      name: 'shelvingRackingSystem',
      desc: '',
      args: [],
    );
  }

  /// `Temperature Monitoring Devices`
  String get temperatureMonitoringDevices {
    return Intl.message(
      'Temperature Monitoring Devices',
      name: 'temperatureMonitoringDevices',
      desc: '',
      args: [],
    );
  }

  /// `Security Cameras (CCTV)`
  String get securityCameras {
    return Intl.message(
      'Security Cameras (CCTV)',
      name: 'securityCameras',
      desc: '',
      args: [],
    );
  }

  /// `Labeling / Scanning Devices`
  String get labelingScanningDevices {
    return Intl.message(
      'Labeling / Scanning Devices',
      name: 'labelingScanningDevices',
      desc: '',
      args: [],
    );
  }

  /// `Packaging / Unpacking Station`
  String get packagingUnpackingStation {
    return Intl.message(
      'Packaging / Unpacking Station',
      name: 'packagingUnpackingStation',
      desc: '',
      args: [],
    );
  }

  /// `Workstations System`
  String get workstationsSystem {
    return Intl.message(
      'Workstations System',
      name: 'workstationsSystem',
      desc: '',
      args: [],
    );
  }

  /// `Hazardous Material Handling Kit`
  String get hazardousMaterialHandlingKit {
    return Intl.message(
      'Hazardous Material Handling Kit',
      name: 'hazardousMaterialHandlingKit',
      desc: '',
      args: [],
    );
  }

  /// `Computer Terminal / Inventory Access Point`
  String get computerTerminal {
    return Intl.message(
      'Computer Terminal / Inventory Access Point',
      name: 'computerTerminal',
      desc: '',
      args: [],
    );
  }

  /// `Shelving / Racking`
  String get shelvingRacking {
    return Intl.message(
      'Shelving / Racking',
      name: 'shelvingRacking',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get none {
    return Intl.message('None', name: 'none', desc: '', args: []);
  }

  /// `Adding New Location`
  String get addingNewLocation {
    return Intl.message(
      'Adding New Location',
      name: 'addingNewLocation',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Add This Location?`
  String get confirmAddLocation {
    return Intl.message(
      'Are You Sure You Want To Add This Location?',
      name: 'confirmAddLocation',
      desc: '',
      args: [],
    );
  }

  /// `New Storage Location Added`
  String get newStorageLocationAdded {
    return Intl.message(
      'New Storage Location Added',
      name: 'newStorageLocationAdded',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Added This Location`
  String get locationAddedSuccess {
    return Intl.message(
      'You Successfully Added This Location',
      name: 'locationAddedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Added On`
  String get addedOn {
    return Intl.message('Added On', name: 'addedOn', desc: '', args: []);
  }

  /// `Contract Date Range`
  String get contractDateRange {
    return Intl.message(
      'Contract Date Range',
      name: 'contractDateRange',
      desc: '',
      args: [],
    );
  }

  /// `Supplier ID is required`
  String get supplierIdRequired {
    return Intl.message(
      'Supplier ID is required',
      name: 'supplierIdRequired',
      desc: '',
      args: [],
    );
  }

  /// `Supplier Name is required`
  String get supplierNameRequired {
    return Intl.message(
      'Supplier Name is required',
      name: 'supplierNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Business Type is required`
  String get businessTypeRequired {
    return Intl.message(
      'Business Type is required',
      name: 'businessTypeRequired',
      desc: '',
      args: [],
    );
  }

  /// `Tax Number is required`
  String get taxNumberRequired {
    return Intl.message(
      'Tax Number is required',
      name: 'taxNumberRequired',
      desc: '',
      args: [],
    );
  }

  /// `Business Registration Number is required`
  String get businessRegistrationRequired {
    return Intl.message(
      'Business Registration Number is required',
      name: 'businessRegistrationRequired',
      desc: '',
      args: [],
    );
  }

  /// `First Name is required`
  String get firstNameRequired {
    return Intl.message(
      'First Name is required',
      name: 'firstNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Last Name is required`
  String get lastNameRequired {
    return Intl.message(
      'Last Name is required',
      name: 'lastNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number is required`
  String get phoneNumberRequired {
    return Intl.message(
      'Phone Number is required',
      name: 'phoneNumberRequired',
      desc: '',
      args: [],
    );
  }

  /// `Email is required`
  String get emailRequired {
    return Intl.message(
      'Email is required',
      name: 'emailRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email`
  String get validEmailRequired {
    return Intl.message(
      'Please enter a valid email',
      name: 'validEmailRequired',
      desc: '',
      args: [],
    );
  }

  /// `Contact {number}: First Name is required`
  String contactNumberFirstName(Object number) {
    return Intl.message(
      'Contact $number: First Name is required',
      name: 'contactNumberFirstName',
      desc: '',
      args: [number],
    );
  }

  /// `Contact {number}: Last Name is required`
  String contactNumberLastName(Object number) {
    return Intl.message(
      'Contact $number: Last Name is required',
      name: 'contactNumberLastName',
      desc: '',
      args: [number],
    );
  }

  /// `Contact {number}: Phone Number is required`
  String contactNumberPhoneNumber(Object number) {
    return Intl.message(
      'Contact $number: Phone Number is required',
      name: 'contactNumberPhoneNumber',
      desc: '',
      args: [number],
    );
  }

  /// `Contact {number}: Email is required`
  String contactNumberEmail(Object number) {
    return Intl.message(
      'Contact $number: Email is required',
      name: 'contactNumberEmail',
      desc: '',
      args: [number],
    );
  }

  /// `Contact {number}: Please enter a valid email`
  String contactNumberValidEmail(Object number) {
    return Intl.message(
      'Contact $number: Please enter a valid email',
      name: 'contactNumberValidEmail',
      desc: '',
      args: [number],
    );
  }

  /// `Please fill all required fields`
  String get fillAllRequiredFields {
    return Intl.message(
      'Please fill all required fields',
      name: 'fillAllRequiredFields',
      desc: '',
      args: [],
    );
  }

  /// `Beneficiary Name is required`
  String get beneficiaryNameRequired {
    return Intl.message(
      'Beneficiary Name is required',
      name: 'beneficiaryNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Beneficiary Bank Name is required`
  String get beneficiaryBankNameRequired {
    return Intl.message(
      'Beneficiary Bank Name is required',
      name: 'beneficiaryBankNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `IBAN is required`
  String get ibanRequired {
    return Intl.message(
      'IBAN is required',
      name: 'ibanRequired',
      desc: '',
      args: [],
    );
  }

  /// `Bank Address is required`
  String get bankAddressRequired {
    return Intl.message(
      'Bank Address is required',
      name: 'bankAddressRequired',
      desc: '',
      args: [],
    );
  }

  /// `Country is required`
  String get countryRequired {
    return Intl.message(
      'Country is required',
      name: 'countryRequired',
      desc: '',
      args: [],
    );
  }

  /// `City is required`
  String get cityRequired {
    return Intl.message(
      'City is required',
      name: 'cityRequired',
      desc: '',
      args: [],
    );
  }

  /// `Street Name is required`
  String get streetNameRequired {
    return Intl.message(
      'Street Name is required',
      name: 'streetNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Postal Code is required`
  String get postalCodeRequired {
    return Intl.message(
      'Postal Code is required',
      name: 'postalCodeRequired',
      desc: '',
      args: [],
    );
  }

  /// `Address {0}: Country is required`
  String get addressNumberCountry {
    return Intl.message(
      'Address {0}: Country is required',
      name: 'addressNumberCountry',
      desc: '',
      args: [],
    );
  }

  /// `Address {0}: City is required`
  String get addressNumberCity {
    return Intl.message(
      'Address {0}: City is required',
      name: 'addressNumberCity',
      desc: '',
      args: [],
    );
  }

  /// `Address {0}: Street Name is required`
  String get addressNumberStreetName {
    return Intl.message(
      'Address {0}: Street Name is required',
      name: 'addressNumberStreetName',
      desc: '',
      args: [],
    );
  }

  /// `Address {0}: Postal Code is required`
  String get addressNumberPostalCode {
    return Intl.message(
      'Address {0}: Postal Code is required',
      name: 'addressNumberPostalCode',
      desc: '',
      args: [],
    );
  }

  /// `Contract Start Date is required`
  String get contractStartDateRequired {
    return Intl.message(
      'Contract Start Date is required',
      name: 'contractStartDateRequired',
      desc: '',
      args: [],
    );
  }

  /// `Contract End Date is required`
  String get contractEndDateRequired {
    return Intl.message(
      'Contract End Date is required',
      name: 'contractEndDateRequired',
      desc: '',
      args: [],
    );
  }

  /// `End date must be after start date`
  String get endDateMustBeAfterStartDate {
    return Intl.message(
      'End date must be after start date',
      name: 'endDateMustBeAfterStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Warehouse {0}: Country is required`
  String get warehouseNumberCountry {
    return Intl.message(
      'Warehouse {0}: Country is required',
      name: 'warehouseNumberCountry',
      desc: '',
      args: [],
    );
  }

  /// `Warehouse {0}: City is required`
  String get warehouseNumberCity {
    return Intl.message(
      'Warehouse {0}: City is required',
      name: 'warehouseNumberCity',
      desc: '',
      args: [],
    );
  }

  /// `Warehouse {0}: Street Name is required`
  String get warehouseNumberStreetName {
    return Intl.message(
      'Warehouse {0}: Street Name is required',
      name: 'warehouseNumberStreetName',
      desc: '',
      args: [],
    );
  }

  /// `Warehouse {0}: Postal Code is required`
  String get warehouseNumberPostalCode {
    return Intl.message(
      'Warehouse {0}: Postal Code is required',
      name: 'warehouseNumberPostalCode',
      desc: '',
      args: [],
    );
  }

  /// `Storage Location ID is required`
  String get storageLocationIdRequired {
    return Intl.message(
      'Storage Location ID is required',
      name: 'storageLocationIdRequired',
      desc: '',
      args: [],
    );
  }

  /// `Branch Name is required`
  String get branchNameRequired {
    return Intl.message(
      'Branch Name is required',
      name: 'branchNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Area is required`
  String get areaRequired {
    return Intl.message(
      'Area is required',
      name: 'areaRequired',
      desc: '',
      args: [],
    );
  }

  /// `Location Type is required`
  String get locationTypeRequired {
    return Intl.message(
      'Location Type is required',
      name: 'locationTypeRequired',
      desc: '',
      args: [],
    );
  }

  /// `Assigned Department is required`
  String get assignedDepartmentRequired {
    return Intl.message(
      'Assigned Department is required',
      name: 'assignedDepartmentRequired',
      desc: '',
      args: [],
    );
  }

  /// `Storage Capacity is required`
  String get storageCapacityRequired {
    return Intl.message(
      'Storage Capacity is required',
      name: 'storageCapacityRequired',
      desc: '',
      args: [],
    );
  }

  /// `Unit is required`
  String get unitRequired {
    return Intl.message(
      'Unit is required',
      name: 'unitRequired',
      desc: '',
      args: [],
    );
  }

  /// `Access Level is required`
  String get accessLevelRequired {
    return Intl.message(
      'Access Level is required',
      name: 'accessLevelRequired',
      desc: '',
      args: [],
    );
  }

  /// `Equipment Available is required`
  String get equipmentAvailableRequired {
    return Intl.message(
      'Equipment Available is required',
      name: 'equipmentAvailableRequired',
      desc: '',
      args: [],
    );
  }

  /// `Condition of Storage is required`
  String get conditionOfStorageRequired {
    return Intl.message(
      'Condition of Storage is required',
      name: 'conditionOfStorageRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid storage capacity (greater than 0)`
  String get validStorageCapacityRequired {
    return Intl.message(
      'Please enter a valid storage capacity (greater than 0)',
      name: 'validStorageCapacityRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please select at least one employee`
  String get atLeastOneEmployeeRequired {
    return Intl.message(
      'Please select at least one employee',
      name: 'atLeastOneEmployeeRequired',
      desc: '',
      args: [],
    );
  }

  /// `Uploading Supplier`
  String get uploadingSupplier {
    return Intl.message(
      'Uploading Supplier',
      name: 'uploadingSupplier',
      desc: '',
      args: [],
    );
  }

  /// `Please wait while we save your data`
  String get pleaseWait {
    return Intl.message(
      'Please wait while we save your data',
      name: 'pleaseWait',
      desc: '',
      args: [],
    );
  }

  /// `Preparing data...`
  String get preparingData {
    return Intl.message(
      'Preparing data...',
      name: 'preparingData',
      desc: '',
      args: [],
    );
  }

  /// `Uploading images...`
  String get uploadingImages {
    return Intl.message(
      'Uploading images...',
      name: 'uploadingImages',
      desc: '',
      args: [],
    );
  }

  /// `Uploading documents...`
  String get uploadingDocuments {
    return Intl.message(
      'Uploading documents...',
      name: 'uploadingDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Uploading registration documents...`
  String get uploadingRegistrationDocuments {
    return Intl.message(
      'Uploading registration documents...',
      name: 'uploadingRegistrationDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Uploading attachments...`
  String get uploadingAttachments {
    return Intl.message(
      'Uploading attachments...',
      name: 'uploadingAttachments',
      desc: '',
      args: [],
    );
  }

  /// `Preparing data structure...`
  String get preparingDataStructure {
    return Intl.message(
      'Preparing data structure...',
      name: 'preparingDataStructure',
      desc: '',
      args: [],
    );
  }

  /// `Saving to database...`
  String get savingToDatabase {
    return Intl.message(
      'Saving to database...',
      name: 'savingToDatabase',
      desc: '',
      args: [],
    );
  }

  /// `Saving contacts...`
  String get savingContacts {
    return Intl.message(
      'Saving contacts...',
      name: 'savingContacts',
      desc: '',
      args: [],
    );
  }

  /// `Saving addresses...`
  String get savingAddresses {
    return Intl.message(
      'Saving addresses...',
      name: 'savingAddresses',
      desc: '',
      args: [],
    );
  }

  /// `Saving warehouses...`
  String get savingWarehouses {
    return Intl.message(
      'Saving warehouses...',
      name: 'savingWarehouses',
      desc: '',
      args: [],
    );
  }

  /// `Finalizing...`
  String get finalizing {
    return Intl.message(
      'Finalizing...',
      name: 'finalizing',
      desc: '',
      args: [],
    );
  }

  /// `There was an error uploading your supplier data. Please try again.`
  String get uploadErrorMessage {
    return Intl.message(
      'There was an error uploading your supplier data. Please try again.',
      name: 'uploadErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Uploading...`
  String get uploading {
    return Intl.message('Uploading...', name: 'uploading', desc: '', args: []);
  }

  /// `Processing your data, please wait`
  String get processingData {
    return Intl.message(
      'Processing your data, please wait',
      name: 'processingData',
      desc: '',
      args: [],
    );
  }

  /// `Delete Supplier`
  String get deleteSupplier {
    return Intl.message(
      'Delete Supplier',
      name: 'deleteSupplier',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this supplier?`
  String get confirmDeleteSupplier {
    return Intl.message(
      'Are you sure you want to delete this supplier?',
      name: 'confirmDeleteSupplier',
      desc: '',
      args: [],
    );
  }

  /// `Supplier Deleted`
  String get supplierDeleted {
    return Intl.message(
      'Supplier Deleted',
      name: 'supplierDeleted',
      desc: '',
      args: [],
    );
  }

  /// `The supplier has been successfully deleted from the system.`
  String get successfullyDeletedSupplier {
    return Intl.message(
      'The supplier has been successfully deleted from the system.',
      name: 'successfullyDeletedSupplier',
      desc: '',
      args: [],
    );
  }

  /// `Middle name is required.`
  String get middleNameRequired {
    return Intl.message(
      'Middle name is required.',
      name: 'middleNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Title is required.`
  String get titleRequired {
    return Intl.message(
      'Title is required.',
      name: 'titleRequired',
      desc: '',
      args: [],
    );
  }

  /// `Fax number is required.`
  String get faxNumberRequired {
    return Intl.message(
      'Fax number is required.',
      name: 'faxNumberRequired',
      desc: '',
      args: [],
    );
  }

  /// `Preferred language is required.`
  String get preferredLanguageRequired {
    return Intl.message(
      'Preferred language is required.',
      name: 'preferredLanguageRequired',
      desc: '',
      args: [],
    );
  }

  /// `Contact #{n}: middle name is required.`
  String contactNumberMiddleName(Object n) {
    return Intl.message(
      'Contact #$n: middle name is required.',
      name: 'contactNumberMiddleName',
      desc: '',
      args: [n],
    );
  }

  /// `Contact #{n}: title is required.`
  String contactNumberTitle(Object n) {
    return Intl.message(
      'Contact #$n: title is required.',
      name: 'contactNumberTitle',
      desc: '',
      args: [n],
    );
  }

  /// `Contact #{n}: fax number is required.`
  String contactNumberFaxNumber(Object n) {
    return Intl.message(
      'Contact #$n: fax number is required.',
      name: 'contactNumberFaxNumber',
      desc: '',
      args: [n],
    );
  }

  /// `Contact #{n}: preferred language is required.`
  String contactNumberPreferredLanguage(Object n) {
    return Intl.message(
      'Contact #$n: preferred language is required.',
      name: 'contactNumberPreferredLanguage',
      desc: '',
      args: [n],
    );
  }

  /// `State/Province is required.`
  String get stateRequired {
    return Intl.message(
      'State/Province is required.',
      name: 'stateRequired',
      desc: '',
      args: [],
    );
  }

  /// `Address #{n}: state/province is required.`
  String addressNumberState(Object n) {
    return Intl.message(
      'Address #$n: state/province is required.',
      name: 'addressNumberState',
      desc: '',
      args: [n],
    );
  }

  /// `SWIFT/BIC code is required.`
  String get swiftCodeRequired {
    return Intl.message(
      'SWIFT/BIC code is required.',
      name: 'swiftCodeRequired',
      desc: '',
      args: [],
    );
  }

  /// `Created Date Range`
  String get createdDateRange {
    return Intl.message(
      'Created Date Range',
      name: 'createdDateRange',
      desc: '',
      args: [],
    );
  }

  /// `Existing Product`
  String get existingProduct {
    return Intl.message(
      'Existing Product',
      name: 'existingProduct',
      desc: '',
      args: [],
    );
  }

  /// `New Product`
  String get newProduct {
    return Intl.message('New Product', name: 'newProduct', desc: '', args: []);
  }

  /// `Select Delivery Method`
  String get selectDeliveryMethod {
    return Intl.message(
      'Select Delivery Method',
      name: 'selectDeliveryMethod',
      desc: '',
      args: [],
    );
  }

  /// `Select Payment Method`
  String get selectPaymentMethod {
    return Intl.message(
      'Select Payment Method',
      name: 'selectPaymentMethod',
      desc: '',
      args: [],
    );
  }

  /// `Select Supplier Name`
  String get selectSupplierName {
    return Intl.message(
      'Select Supplier Name',
      name: 'selectSupplierName',
      desc: '',
      args: [],
    );
  }

  /// `Select Advanced Payment`
  String get selectAdvancedPayment {
    return Intl.message(
      'Select Advanced Payment',
      name: 'selectAdvancedPayment',
      desc: '',
      args: [],
    );
  }

  /// `Select Method Of Payment`
  String get selectMethodOfPayment {
    return Intl.message(
      'Select Method Of Payment',
      name: 'selectMethodOfPayment',
      desc: '',
      args: [],
    );
  }

  /// `Select Product Type`
  String get selectProductType {
    return Intl.message(
      'Select Product Type',
      name: 'selectProductType',
      desc: '',
      args: [],
    );
  }

  /// `Select Category`
  String get selectCategory {
    return Intl.message(
      'Select Category',
      name: 'selectCategory',
      desc: '',
      args: [],
    );
  }

  /// `Select Subcategory`
  String get selectSubcategory {
    return Intl.message(
      'Select Subcategory',
      name: 'selectSubcategory',
      desc: '',
      args: [],
    );
  }

  /// `Select Order Date`
  String get selectOrderDate {
    return Intl.message(
      'Select Order Date',
      name: 'selectOrderDate',
      desc: '',
      args: [],
    );
  }

  /// `Select Receiving Date`
  String get selectReceivingDate {
    return Intl.message(
      'Select Receiving Date',
      name: 'selectReceivingDate',
      desc: '',
      args: [],
    );
  }

  /// `Add Product`
  String get addProduct {
    return Intl.message('Add Product', name: 'addProduct', desc: '', args: []);
  }

  /// `Will it be a new batch?`
  String get willItBeANewBatch {
    return Intl.message(
      'Will it be a new batch?',
      name: 'willItBeANewBatch',
      desc: '',
      args: [],
    );
  }

  /// `Remaining Quantity`
  String get remainingQuantity {
    return Intl.message(
      'Remaining Quantity',
      name: 'remainingQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Order`
  String get purchaseOrder {
    return Intl.message(
      'Purchase Order',
      name: 'purchaseOrder',
      desc: '',
      args: [],
    );
  }

  /// `Warning: Wrong Entry`
  String get warningWrongEntry {
    return Intl.message(
      'Warning: Wrong Entry',
      name: 'warningWrongEntry',
      desc: '',
      args: [],
    );
  }

  /// `Valid Order ID`
  String get validOrderId {
    return Intl.message(
      'Valid Order ID',
      name: 'validOrderId',
      desc: '',
      args: [],
    );
  }

  /// `Restocking Product`
  String get restockingProduct {
    return Intl.message(
      'Restocking Product',
      name: 'restockingProduct',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to restock this product?`
  String get confirmRestockProduct {
    return Intl.message(
      'Are you sure you want to restock this product?',
      name: 'confirmRestockProduct',
      desc: '',
      args: [],
    );
  }

  /// `Restock Added`
  String get restockAdded {
    return Intl.message(
      'Restock Added',
      name: 'restockAdded',
      desc: '',
      args: [],
    );
  }

  /// `You successfully added a restock to this product`
  String get restockAddedSuccess {
    return Intl.message(
      'You successfully added a restock to this product',
      name: 'restockAddedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Batch created`
  String get batchCreated {
    return Intl.message(
      'Batch created',
      name: 'batchCreated',
      desc: '',
      args: [],
    );
  }

  /// `Batch created successfully`
  String get batchCreatedSuccess {
    return Intl.message(
      'Batch created successfully',
      name: 'batchCreatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Create new batch`
  String get createNewBatch {
    return Intl.message(
      'Create new batch',
      name: 'createNewBatch',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to create a new batch?`
  String get confirmCreateNewBatch {
    return Intl.message(
      'Are you sure you want to create a new batch?',
      name: 'confirmCreateNewBatch',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get saveChanges {
    return Intl.message(
      'Save Changes',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Product Updated Successfully`
  String get productUpdatedSuccessfully {
    return Intl.message(
      'Product Updated Successfully',
      name: 'productUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `The product has been updated successfully`
  String get productHasBeenUpdatedSuccessfully {
    return Intl.message(
      'The product has been updated successfully',
      name: 'productHasBeenUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update product`
  String get failedToUpdateProduct {
    return Intl.message(
      'Failed to update product',
      name: 'failedToUpdateProduct',
      desc: '',
      args: [],
    );
  }

  /// `Please select an employee`
  String get pleaseSelectAnEmployee {
    return Intl.message(
      'Please select an employee',
      name: 'pleaseSelectAnEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to assign this product to the selected employee?`
  String get confirmAssignProduct {
    return Intl.message(
      'Are you sure you want to assign this product to the selected employee?',
      name: 'confirmAssignProduct',
      desc: '',
      args: [],
    );
  }

  /// `Available`
  String get available {
    return Intl.message('Available', name: 'available', desc: '', args: []);
  }

  /// `Item Already Assigned`
  String get itemAlreadyAssigned {
    return Intl.message(
      'Item Already Assigned',
      name: 'itemAlreadyAssigned',
      desc: '',
      args: [],
    );
  }

  /// `This item has already been assigned to someone. You cannot select it for assignment.`
  String get itemAssignedMessage {
    return Intl.message(
      'This item has already been assigned to someone. You cannot select it for assignment.',
      name: 'itemAssignedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Select Different Product`
  String get selectDifferentProduct {
    return Intl.message(
      'Select Different Product',
      name: 'selectDifferentProduct',
      desc: '',
      args: [],
    );
  }

  /// `Replacement`
  String get replacement {
    return Intl.message('Replacement', name: 'replacement', desc: '', args: []);
  }

  /// `New Asset`
  String get newAsset {
    return Intl.message('New Asset', name: 'newAsset', desc: '', args: []);
  }

  /// `Office`
  String get office {
    return Intl.message('Office', name: 'office', desc: '', args: []);
  }

  /// `Expected Pick Up Date`
  String get expectedPickUpDate {
    return Intl.message(
      'Expected Pick Up Date',
      name: 'expectedPickUpDate',
      desc: '',
      args: [],
    );
  }

  /// `Expected Pick Up Time`
  String get expectedPickUpTime {
    return Intl.message(
      'Expected Pick Up Time',
      name: 'expectedPickUpTime',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate Request`
  String get duplicateRequest {
    return Intl.message(
      'Duplicate Request',
      name: 'duplicateRequest',
      desc: '',
      args: [],
    );
  }

  /// `You have already requested this asset`
  String get youHaveAlreadyRequestedThisAsset {
    return Intl.message(
      'You have already requested this asset',
      name: 'youHaveAlreadyRequestedThisAsset',
      desc: '',
      args: [],
    );
  }

  /// `Mechanical`
  String get mechanical {
    return Intl.message('Mechanical', name: 'mechanical', desc: '', args: []);
  }

  /// `Electrical`
  String get electrical {
    return Intl.message('Electrical', name: 'electrical', desc: '', args: []);
  }

  /// `Performance`
  String get performance {
    return Intl.message('Performance', name: 'performance', desc: '', args: []);
  }

  /// `Safety`
  String get safety {
    return Intl.message('Safety', name: 'safety', desc: '', args: []);
  }

  /// `Last Seen Date`
  String get lastSeenDate {
    return Intl.message(
      'Last Seen Date',
      name: 'lastSeenDate',
      desc: '',
      args: [],
    );
  }

  /// `Internal Search`
  String get internalSearch {
    return Intl.message(
      'Internal Search',
      name: 'internalSearch',
      desc: '',
      args: [],
    );
  }

  /// `Escalate to Supervisor`
  String get escalateToSupervisor {
    return Intl.message(
      'Escalate to Supervisor',
      name: 'escalateToSupervisor',
      desc: '',
      args: [],
    );
  }

  /// `Asset Stolen`
  String get assetStolen {
    return Intl.message(
      'Asset Stolen',
      name: 'assetStolen',
      desc: '',
      args: [],
    );
  }

  /// `Incident Date`
  String get incidentDate {
    return Intl.message(
      'Incident Date',
      name: 'incidentDate',
      desc: '',
      args: [],
    );
  }

  /// `Reported To Police`
  String get reportedToPolice {
    return Intl.message(
      'Reported To Police',
      name: 'reportedToPolice',
      desc: '',
      args: [],
    );
  }

  /// `Incident Location`
  String get incidentLocation {
    return Intl.message(
      'Incident Location',
      name: 'incidentLocation',
      desc: '',
      args: [],
    );
  }

  /// `Description of Incident`
  String get descriptionOfIncident {
    return Intl.message(
      'Description of Incident',
      name: 'descriptionOfIncident',
      desc: '',
      args: [],
    );
  }

  /// `Consumable Return`
  String get consumableReturn {
    return Intl.message(
      'Consumable Return',
      name: 'consumableReturn',
      desc: '',
      args: [],
    );
  }

  /// `Consumable Expired`
  String get consumableExpired {
    return Intl.message(
      'Consumable Expired',
      name: 'consumableExpired',
      desc: '',
      args: [],
    );
  }

  /// `Consumable Missing`
  String get consumableMissing {
    return Intl.message(
      'Consumable Missing',
      name: 'consumableMissing',
      desc: '',
      args: [],
    );
  }

  /// `Consumable Stolen`
  String get consumableStolen {
    return Intl.message(
      'Consumable Stolen',
      name: 'consumableStolen',
      desc: '',
      args: [],
    );
  }

  /// `Error submitting request`
  String get errorSubmittingRequest {
    return Intl.message(
      'Error submitting request',
      name: 'errorSubmittingRequest',
      desc: '',
      args: [],
    );
  }

  /// `Assets Assigned`
  String get assetsAssigned {
    return Intl.message(
      'Assets Assigned',
      name: 'assetsAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Assets Under Maintenance`
  String get assetsUnderMaintenance {
    return Intl.message(
      'Assets Under Maintenance',
      name: 'assetsUnderMaintenance',
      desc: '',
      args: [],
    );
  }

  /// `Overdue Return`
  String get overdueReturn {
    return Intl.message(
      'Overdue Return',
      name: 'overdueReturn',
      desc: '',
      args: [],
    );
  }

  /// `Consumables Assigned`
  String get consumablesAssigned {
    return Intl.message(
      'Consumables Assigned',
      name: 'consumablesAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Piece`
  String get unitPiece {
    return Intl.message('Piece', name: 'unitPiece', desc: '', args: []);
  }

  /// `Set`
  String get unitSet {
    return Intl.message('Set', name: 'unitSet', desc: '', args: []);
  }

  /// `Box`
  String get unitBox {
    return Intl.message('Box', name: 'unitBox', desc: '', args: []);
  }

  /// `Pack`
  String get unitPack {
    return Intl.message('Pack', name: 'unitPack', desc: '', args: []);
  }

  /// `Bottle`
  String get unitBottle {
    return Intl.message('Bottle', name: 'unitBottle', desc: '', args: []);
  }

  /// `Unit`
  String get unitUnit {
    return Intl.message('Unit', name: 'unitUnit', desc: '', args: []);
  }

  /// `Bag`
  String get unitBag {
    return Intl.message('Bag', name: 'unitBag', desc: '', args: []);
  }

  /// `Reel`
  String get unitReel {
    return Intl.message('Reel', name: 'unitReel', desc: '', args: []);
  }

  /// `Kit`
  String get unitKit {
    return Intl.message('Kit', name: 'unitKit', desc: '', args: []);
  }

  /// `Kilogram`
  String get unitKilogram {
    return Intl.message('Kilogram', name: 'unitKilogram', desc: '', args: []);
  }

  /// `Gram`
  String get unitGram {
    return Intl.message('Gram', name: 'unitGram', desc: '', args: []);
  }

  /// `Ton`
  String get unitTon {
    return Intl.message('Ton', name: 'unitTon', desc: '', args: []);
  }

  /// `Pound`
  String get unitPound {
    return Intl.message('Pound', name: 'unitPound', desc: '', args: []);
  }

  /// `Ounce`
  String get unitOunce {
    return Intl.message('Ounce', name: 'unitOunce', desc: '', args: []);
  }

  /// `Liter`
  String get unitLiter {
    return Intl.message('Liter', name: 'unitLiter', desc: '', args: []);
  }

  /// `Milliliter`
  String get unitMilliliter {
    return Intl.message(
      'Milliliter',
      name: 'unitMilliliter',
      desc: '',
      args: [],
    );
  }

  /// `Gallon`
  String get unitGallon {
    return Intl.message('Gallon', name: 'unitGallon', desc: '', args: []);
  }

  /// `Meter`
  String get unitMeter {
    return Intl.message('Meter', name: 'unitMeter', desc: '', args: []);
  }

  /// `Centimeter`
  String get unitCentimeter {
    return Intl.message(
      'Centimeter',
      name: 'unitCentimeter',
      desc: '',
      args: [],
    );
  }

  /// `Inch`
  String get unitInch {
    return Intl.message('Inch', name: 'unitInch', desc: '', args: []);
  }

  /// `Daily`
  String get frequencyDaily {
    return Intl.message('Daily', name: 'frequencyDaily', desc: '', args: []);
  }

  /// `Biweekly`
  String get frequencyBiweekly {
    return Intl.message(
      'Biweekly',
      name: 'frequencyBiweekly',
      desc: '',
      args: [],
    );
  }

  /// `Monthly`
  String get frequencyMonthly {
    return Intl.message(
      'Monthly',
      name: 'frequencyMonthly',
      desc: '',
      args: [],
    );
  }

  /// `Quarterly`
  String get frequencyQuarterly {
    return Intl.message(
      'Quarterly',
      name: 'frequencyQuarterly',
      desc: '',
      args: [],
    );
  }

  /// `Annually`
  String get frequencyAnnually {
    return Intl.message(
      'Annually',
      name: 'frequencyAnnually',
      desc: '',
      args: [],
    );
  }

  /// `Occasionally`
  String get frequencyOccasionally {
    return Intl.message(
      'Occasionally',
      name: 'frequencyOccasionally',
      desc: '',
      args: [],
    );
  }

  /// `On Demand / As Needed`
  String get frequencyOnDemandAsNeeded {
    return Intl.message(
      'On Demand / As Needed',
      name: 'frequencyOnDemandAsNeeded',
      desc: '',
      args: [],
    );
  }

  /// `Continuous / Real-Time`
  String get frequencyContinuousRealTime {
    return Intl.message(
      'Continuous / Real-Time',
      name: 'frequencyContinuousRealTime',
      desc: '',
      args: [],
    );
  }

  /// `Rarely`
  String get frequencyRarely {
    return Intl.message('Rarely', name: 'frequencyRarely', desc: '', args: []);
  }

  /// `One-Time Use`
  String get frequencyOneTimeUse {
    return Intl.message(
      'One-Time Use',
      name: 'frequencyOneTimeUse',
      desc: '',
      args: [],
    );
  }

  /// `Seasonally`
  String get frequencySeasonally {
    return Intl.message(
      'Seasonally',
      name: 'frequencySeasonally',
      desc: '',
      args: [],
    );
  }

  /// `Shift-Based`
  String get frequencyShiftBased {
    return Intl.message(
      'Shift-Based',
      name: 'frequencyShiftBased',
      desc: '',
      args: [],
    );
  }

  /// `New`
  String get instock {
    return Intl.message('New', name: 'instock', desc: '', args: []);
  }

  /// `Consumable Details`
  String get consumableDetails {
    return Intl.message(
      'Consumable Details',
      name: 'consumableDetails',
      desc: '',
      args: [],
    );
  }

  /// `Reason`
  String get reason {
    return Intl.message('Reason', name: 'reason', desc: '', args: []);
  }

  /// `Low`
  String get low {
    return Intl.message('Low', name: 'low', desc: '', args: []);
  }

  /// `Medium`
  String get medium {
    return Intl.message('Medium', name: 'medium', desc: '', args: []);
  }

  /// `High`
  String get high {
    return Intl.message('High', name: 'high', desc: '', args: []);
  }

  /// `Critical`
  String get critical {
    return Intl.message('Critical', name: 'critical', desc: '', args: []);
  }

  /// `Granted Access`
  String get grantedAccess {
    return Intl.message(
      'Granted Access',
      name: 'grantedAccess',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to add these users access?`
  String get confirmAddUsersAccess {
    return Intl.message(
      'Are you sure you want to add these users access?',
      name: 'confirmAddUsersAccess',
      desc: '',
      args: [],
    );
  }

  /// `Please select a role and at least one employee`
  String get selectRoleAndEmployee {
    return Intl.message(
      'Please select a role and at least one employee',
      name: 'selectRoleAndEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Please select a role type`
  String get selectRoleType {
    return Intl.message(
      'Please select a role type',
      name: 'selectRoleType',
      desc: '',
      args: [],
    );
  }

  /// `Please select at least one employee`
  String get selectAtLeastOneEmployee {
    return Intl.message(
      'Please select at least one employee',
      name: 'selectAtLeastOneEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Knowledge Hub`
  String get knowledge_hub {
    return Intl.message(
      'Knowledge Hub',
      name: 'knowledge_hub',
      desc: '',
      args: [],
    );
  }

  /// `Submissions`
  String get submissions {
    return Intl.message('Submissions', name: 'submissions', desc: '', args: []);
  }

  /// `Owning Department`
  String get owning_department {
    return Intl.message(
      'Owning Department',
      name: 'owning_department',
      desc: '',
      args: [],
    );
  }

  /// `Publish Date`
  String get publish_date {
    return Intl.message(
      'Publish Date',
      name: 'publish_date',
      desc: '',
      args: [],
    );
  }

  /// `Last Edit`
  String get last_edit {
    return Intl.message('Last Edit', name: 'last_edit', desc: '', args: []);
  }

  /// `Document Type`
  String get document_type {
    return Intl.message(
      'Document Type',
      name: 'document_type',
      desc: '',
      args: [],
    );
  }

  /// `Presentation`
  String get presentation {
    return Intl.message(
      'Presentation',
      name: 'presentation',
      desc: '',
      args: [],
    );
  }

  /// `Form`
  String get form {
    return Intl.message('Form', name: 'form', desc: '', args: []);
  }

  /// `Report`
  String get report {
    return Intl.message('Report', name: 'report', desc: '', args: []);
  }

  /// `Booklet`
  String get booklet {
    return Intl.message('Booklet', name: 'booklet', desc: '', args: []);
  }

  /// `Video Recording`
  String get video_recording {
    return Intl.message(
      'Video Recording',
      name: 'video_recording',
      desc: '',
      args: [],
    );
  }

  /// `Letter`
  String get letter {
    return Intl.message('Letter', name: 'letter', desc: '', args: []);
  }

  /// `Mandate`
  String get mandate {
    return Intl.message('Mandate', name: 'mandate', desc: '', args: []);
  }

  /// `Policy`
  String get policy {
    return Intl.message('Policy', name: 'policy', desc: '', args: []);
  }

  /// `Framework`
  String get framework {
    return Intl.message('Framework', name: 'framework', desc: '', args: []);
  }

  /// `WorkShop`
  String get workshop {
    return Intl.message('WorkShop', name: 'workshop', desc: '', args: []);
  }

  /// `Guidelines`
  String get guidelines {
    return Intl.message('Guidelines', name: 'guidelines', desc: '', args: []);
  }

  /// `Choose Type`
  String get choose_type {
    return Intl.message('Choose Type', name: 'choose_type', desc: '', args: []);
  }

  /// `Creating Knowledge Hub`
  String get creating_knowledge_hub {
    return Intl.message(
      'Creating Knowledge Hub',
      name: 'creating_knowledge_hub',
      desc: '',
      args: [],
    );
  }

  /// `Attach Document`
  String get attach_document {
    return Intl.message(
      'Attach Document',
      name: 'attach_document',
      desc: '',
      args: [],
    );
  }

  /// `Limit Department Availability`
  String get limit_department_availability {
    return Intl.message(
      'Limit Department Availability',
      name: 'limit_department_availability',
      desc: '',
      args: [],
    );
  }

  /// `Schedule Publishing`
  String get schedule_publishing {
    return Intl.message(
      'Schedule Publishing',
      name: 'schedule_publishing',
      desc: '',
      args: [],
    );
  }

  /// `Start Date`
  String get start_date {
    return Intl.message('Start Date', name: 'start_date', desc: '', args: []);
  }

  /// `End Date`
  String get end_date {
    return Intl.message('End Date', name: 'end_date', desc: '', args: []);
  }

  /// `Submit For Approval`
  String get submit_for_approval {
    return Intl.message(
      'Submit For Approval',
      name: 'submit_for_approval',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Submit For Approval?`
  String get are_you_sure_submit {
    return Intl.message(
      'Are You Sure You Want To Submit For Approval?',
      name: 'are_you_sure_submit',
      desc: '',
      args: [],
    );
  }

  /// `Successful`
  String get successful {
    return Intl.message('Successful', name: 'successful', desc: '', args: []);
  }

  /// `You Successfully Submitted For Approval`
  String get submit_success_message {
    return Intl.message(
      'You Successfully Submitted For Approval',
      name: 'submit_success_message',
      desc: '',
      args: [],
    );
  }

  /// `Please select a document type`
  String get please_select_doc_type {
    return Intl.message(
      'Please select a document type',
      name: 'please_select_doc_type',
      desc: '',
      args: [],
    );
  }

  /// `Untitled`
  String get untitled {
    return Intl.message('Untitled', name: 'untitled', desc: '', args: []);
  }

  /// `Add New Item`
  String get add_New_Item {
    return Intl.message(
      'Add New Item',
      name: 'add_New_Item',
      desc: '',
      args: [],
    );
  }

  /// `Create New Knowledge`
  String get create_new_knowledge {
    return Intl.message(
      'Create New Knowledge',
      name: 'create_new_knowledge',
      desc: '',
      args: [],
    );
  }

  /// `Document Name`
  String get document_name {
    return Intl.message(
      'Document Name',
      name: 'document_name',
      desc: '',
      args: [],
    );
  }

  /// `Document Description`
  String get document_description {
    return Intl.message(
      'Document Description',
      name: 'document_description',
      desc: '',
      args: [],
    );
  }

  /// `Published Date`
  String get published_date {
    return Intl.message(
      'Published Date',
      name: 'published_date',
      desc: '',
      args: [],
    );
  }

  /// `View`
  String get view {
    return Intl.message('View', name: 'view', desc: '', args: []);
  }

  /// `Inquiries And Comments`
  String get inquiries_and_comments {
    return Intl.message(
      'Inquiries And Comments',
      name: 'inquiries_and_comments',
      desc: '',
      args: [],
    );
  }

  /// `Collapse`
  String get collapse {
    return Intl.message('Collapse', name: 'collapse', desc: '', args: []);
  }

  /// `Write a Comment`
  String get write_a_comment {
    return Intl.message(
      'Write a Comment',
      name: 'write_a_comment',
      desc: '',
      args: [],
    );
  }

  /// `Error Viewing File`
  String get error_viewing_file {
    return Intl.message(
      'Error Viewing File',
      name: 'error_viewing_file',
      desc: '',
      args: [],
    );
  }

  /// `Error Downloading File`
  String get error_downloading_file {
    return Intl.message(
      'Error Downloading File',
      name: 'error_downloading_file',
      desc: '',
      args: [],
    );
  }

  /// `Could not open download link`
  String get error_opening_download_link {
    return Intl.message(
      'Could not open download link',
      name: 'error_opening_download_link',
      desc: '',
      args: [],
    );
  }

  /// `Could not open file`
  String get error_opening_file {
    return Intl.message(
      'Could not open file',
      name: 'error_opening_file',
      desc: '',
      args: [],
    );
  }

  /// `Loading departments...`
  String get loadingDepartments {
    return Intl.message(
      'Loading departments...',
      name: 'loadingDepartments',
      desc: '',
      args: [],
    );
  }

  /// `Please fill all required fields correctly`
  String get pleaseFillAllRequiredFieldsCorrectly {
    return Intl.message(
      'Please fill all required fields correctly',
      name: 'pleaseFillAllRequiredFieldsCorrectly',
      desc: '',
      args: [],
    );
  }

  /// `Please select a document type`
  String get pleaseSelectDocumentType {
    return Intl.message(
      'Please select a document type',
      name: 'pleaseSelectDocumentType',
      desc: '',
      args: [],
    );
  }

  /// `Please attach a document`
  String get pleaseAttachDocument {
    return Intl.message(
      'Please attach a document',
      name: 'pleaseAttachDocument',
      desc: '',
      args: [],
    );
  }

  /// `Add departments or switch off limit department availability`
  String get addDepartmentsOrSwitchOffLimitAvailability {
    return Intl.message(
      'Add departments or switch off limit department availability',
      name: 'addDepartmentsOrSwitchOffLimitAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Add start date or switch off Schedule Publishing`
  String get addStartDateOrSwitchOffSchedulePublishing {
    return Intl.message(
      'Add start date or switch off Schedule Publishing',
      name: 'addStartDateOrSwitchOffSchedulePublishing',
      desc: '',
      args: [],
    );
  }

  /// `Editing {documentName} Details`
  String editingDocumentDetails(Object documentName) {
    return Intl.message(
      'Editing $documentName Details',
      name: 'editingDocumentDetails',
      desc: '',
      args: [documentName],
    );
  }

  /// `Requesting Resubmit`
  String get requestingResubmit {
    return Intl.message(
      'Requesting Resubmit',
      name: 'requestingResubmit',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to resubmit this document?`
  String get areYouSureYouWantToResubmit {
    return Intl.message(
      'Are you sure you want to resubmit this document?',
      name: 'areYouSureYouWantToResubmit',
      desc: '',
      args: [],
    );
  }

  /// `No knowledge documents found`
  String get noKnowledgedocumentsFound {
    return Intl.message(
      'No knowledge documents found',
      name: 'noKnowledgedocumentsFound',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded date`
  String get uploaded_date {
    return Intl.message(
      'Uploaded date',
      name: 'uploaded_date',
      desc: '',
      args: [],
    );
  }

  /// `NO`
  String get number {
    return Intl.message('NO', name: 'number', desc: '', args: []);
  }

  /// `Indicates number in table`
  String get indicatesNumberInTable {
    return Intl.message(
      'Indicates number in table',
      name: 'indicatesNumberInTable',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get time {
    return Intl.message('Time', name: 'time', desc: '', args: []);
  }

  /// `Action`
  String get action {
    return Intl.message('Action', name: 'action', desc: '', args: []);
  }

  /// `No statistics available`
  String get noStatisticsAvailable {
    return Intl.message(
      'No statistics available',
      name: 'noStatisticsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Marital Status`
  String get maritalStatus {
    return Intl.message(
      'Marital Status',
      name: 'maritalStatus',
      desc: '',
      args: [],
    );
  }

  /// `Birthday`
  String get birthday {
    return Intl.message('Birthday', name: 'birthday', desc: '', args: []);
  }

  /// `Gender`
  String get gender {
    return Intl.message('Gender', name: 'gender', desc: '', args: []);
  }

  /// `Hired On`
  String get hiredOn {
    return Intl.message('Hired On', name: 'hiredOn', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Editing My Personal Data`
  String get editingMyPersonalData {
    return Intl.message(
      'Editing My Personal Data',
      name: 'editingMyPersonalData',
      desc: '',
      args: [],
    );
  }

  /// `Current Details`
  String get current_details {
    return Intl.message(
      'Current Details',
      name: 'current_details',
      desc: '',
      args: [],
    );
  }

  /// `New Details`
  String get new_details {
    return Intl.message('New Details', name: 'new_details', desc: '', args: []);
  }

  /// `Request Note`
  String get request_note {
    return Intl.message(
      'Request Note',
      name: 'request_note',
      desc: '',
      args: [],
    );
  }

  /// `Requesting A Change`
  String get requesting_a_change {
    return Intl.message(
      'Requesting A Change',
      name: 'requesting_a_change',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Submit This Request?`
  String get are_you_sure_submit_request {
    return Intl.message(
      'Are You Sure You Want To Submit This Request?',
      name: 'are_you_sure_submit_request',
      desc: '',
      args: [],
    );
  }

  /// `Request Submitted`
  String get request_submitted {
    return Intl.message(
      'Request Submitted',
      name: 'request_submitted',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Submitted This Request`
  String get successfully_submitted_request {
    return Intl.message(
      'You Successfully Submitted This Request',
      name: 'successfully_submitted_request',
      desc: '',
      args: [],
    );
  }

  /// `Insurance Name`
  String get insuranceName {
    return Intl.message(
      'Insurance Name',
      name: 'insuranceName',
      desc: '',
      args: [],
    );
  }

  /// `Insurance Policy Number`
  String get insurancePolicyNumber {
    return Intl.message(
      'Insurance Policy Number',
      name: 'insurancePolicyNumber',
      desc: '',
      args: [],
    );
  }

  /// `SuperVisor`
  String get superVisor {
    return Intl.message('SuperVisor', name: 'superVisor', desc: '', args: []);
  }

  /// `Personal Information`
  String get personalInformation {
    return Intl.message(
      'Personal Information',
      name: 'personalInformation',
      desc: '',
      args: [],
    );
  }

  /// `No Change Found`
  String get noChangeFound {
    return Intl.message(
      'No Change Found',
      name: 'noChangeFound',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded Documents`
  String get uploadedDocuments {
    return Intl.message(
      'Uploaded Documents',
      name: 'uploadedDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Knowledge Hub Resources`
  String get knowledgeHubResources {
    return Intl.message(
      'Knowledge Hub Resources',
      name: 'knowledgeHubResources',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update knowledge hub`
  String get failedToUpdateKnowledgeHub {
    return Intl.message(
      'Failed to update knowledge hub',
      name: 'failedToUpdateKnowledgeHub',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create knowledge hub`
  String get failedToCreateKnowledgeHub {
    return Intl.message(
      'Failed to create knowledge hub',
      name: 'failedToCreateKnowledgeHub',
      desc: '',
      args: [],
    );
  }

  /// `Error submitting to Firebase`
  String get errorSubmittingToFirebase {
    return Intl.message(
      'Error submitting to Firebase',
      name: 'errorSubmittingToFirebase',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load departments`
  String get failedToLoadDepartments {
    return Intl.message(
      'Failed to load departments',
      name: 'failedToLoadDepartments',
      desc: '',
      args: [],
    );
  }

  /// `Successfully fetched specific knowledge`
  String get successfullyFetchedSpecificKnowledge {
    return Intl.message(
      'Successfully fetched specific knowledge',
      name: 'successfullyFetchedSpecificKnowledge',
      desc: '',
      args: [],
    );
  }

  /// `Reason Of Removing`
  String get reasonOfRemoving {
    return Intl.message(
      'Reason Of Removing',
      name: 'reasonOfRemoving',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get details {
    return Intl.message('Details', name: 'details', desc: '', args: []);
  }

  /// `Requested By`
  String get requestedBy {
    return Intl.message(
      'Requested By',
      name: 'requestedBy',
      desc: '',
      args: [],
    );
  }

  /// `Error loading dashboard`
  String get errorLoadingDashboard {
    return Intl.message(
      'Error loading dashboard',
      name: 'errorLoadingDashboard',
      desc: '',
      args: [],
    );
  }

  /// `No documents found`
  String get noDocumentsFound {
    return Intl.message(
      'No documents found',
      name: 'noDocumentsFound',
      desc: '',
      args: [],
    );
  }

  /// `Loading dashboard...`
  String get loadingDashboard {
    return Intl.message(
      'Loading dashboard...',
      name: 'loadingDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Got it`
  String get gotIt {
    return Intl.message('Got it', name: 'gotIt', desc: '', args: []);
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `No resources data available`
  String get noResourcesDataAvailable {
    return Intl.message(
      'No resources data available',
      name: 'noResourcesDataAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Failed to add comment`
  String get failedToAddComment {
    return Intl.message(
      'Failed to add comment',
      name: 'failedToAddComment',
      desc: '',
      args: [],
    );
  }

  /// `Expiring Soon`
  String get expiringSoon {
    return Intl.message(
      'Expiring Soon',
      name: 'expiringSoon',
      desc: '',
      args: [],
    );
  }

  /// `Owner`
  String get owner {
    return Intl.message('Owner', name: 'owner', desc: '', args: []);
  }

  /// `Contributor`
  String get contributor {
    return Intl.message('Contributor', name: 'contributor', desc: '', args: []);
  }

  /// `Owning Status`
  String get owningStatus {
    return Intl.message(
      'Owning Status',
      name: 'owningStatus',
      desc: '',
      args: [],
    );
  }

  /// `No Submissions Match Filters`
  String get noSubmissionsMatchFilters {
    return Intl.message(
      'No Submissions Match Filters',
      name: 'noSubmissionsMatchFilters',
      desc: '',
      args: [],
    );
  }

  /// `Published`
  String get published {
    return Intl.message('Published', name: 'published', desc: '', args: []);
  }

  /// `Scheduled`
  String get scheduled {
    return Intl.message('Scheduled', name: 'scheduled', desc: '', args: []);
  }

  /// `Removed`
  String get removed {
    return Intl.message('Removed', name: 'removed', desc: '', args: []);
  }

  /// `Archived`
  String get archive {
    return Intl.message('Archived', name: 'archive', desc: '', args: []);
  }

  /// `Remove`
  String get remove {
    return Intl.message('Remove', name: 'remove', desc: '', args: []);
  }

  /// `Removing Document`
  String get removingDocument {
    return Intl.message(
      'Removing Document',
      name: 'removingDocument',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove this document?`
  String get areYouSureYouWantToRemoveDocument {
    return Intl.message(
      'Are you sure you want to remove this document?',
      name: 'areYouSureYouWantToRemoveDocument',
      desc: '',
      args: [],
    );
  }

  /// `Limited Department Availability`
  String get limitedDepartmentAvailability {
    return Intl.message(
      'Limited Department Availability',
      name: 'limitedDepartmentAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Analytics`
  String get analytics {
    return Intl.message('Analytics', name: 'analytics', desc: '', args: []);
  }

  /// `Statistics`
  String get statistics {
    return Intl.message('Statistics', name: 'statistics', desc: '', args: []);
  }

  /// `Comments`
  String get comments {
    return Intl.message('Comments', name: 'comments', desc: '', args: []);
  }

  /// `No comments yet`
  String get noCommentsYet {
    return Intl.message(
      'No comments yet',
      name: 'noCommentsYet',
      desc: '',
      args: [],
    );
  }

  /// `Error loading analytics`
  String get errorLoadingAnalytics {
    return Intl.message(
      'Error loading analytics',
      name: 'errorLoadingAnalytics',
      desc: '',
      args: [],
    );
  }

  /// `No analytics data available yet`
  String get noAnalyticsDataAvailableYet {
    return Intl.message(
      'No analytics data available yet',
      name: 'noAnalyticsDataAvailableYet',
      desc: '',
      args: [],
    );
  }

  /// `Data will appear once users interact with this document`
  String get dataWillAppearOnceUsersInteract {
    return Intl.message(
      'Data will appear once users interact with this document',
      name: 'dataWillAppearOnceUsersInteract',
      desc: '',
      args: [],
    );
  }

  /// `Views`
  String get views {
    return Intl.message('Views', name: 'views', desc: '', args: []);
  }

  /// `Downloads`
  String get downloads {
    return Intl.message('Downloads', name: 'downloads', desc: '', args: []);
  }

  /// `Number of Downloads`
  String get numberOfDownloads {
    return Intl.message(
      'Number of Downloads',
      name: 'numberOfDownloads',
      desc: '',
      args: [],
    );
  }

  /// `Number of Views`
  String get numberOfViews {
    return Intl.message(
      'Number of Views',
      name: 'numberOfViews',
      desc: '',
      args: [],
    );
  }

  /// `Departments`
  String get departments {
    return Intl.message('Departments', name: 'departments', desc: '', args: []);
  }

  /// `No data available`
  String get noDataAvailable {
    return Intl.message(
      'No data available',
      name: 'noDataAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Error loading statistics`
  String get errorLoadingStatistics {
    return Intl.message(
      'Error loading statistics',
      name: 'errorLoadingStatistics',
      desc: '',
      args: [],
    );
  }

  /// `No statistics available yet`
  String get noStatisticsAvailableYet {
    return Intl.message(
      'No statistics available yet',
      name: 'noStatisticsAvailableYet',
      desc: '',
      args: [],
    );
  }

  /// `At`
  String get at {
    return Intl.message('At', name: 'at', desc: '', args: []);
  }

  /// `No submissions found`
  String get noSubmissionsFound {
    return Intl.message(
      'No submissions found',
      name: 'noSubmissionsFound',
      desc: '',
      args: [],
    );
  }

  /// `No approvals found`
  String get noApprovalsFound {
    return Intl.message(
      'No approvals found',
      name: 'noApprovalsFound',
      desc: '',
      args: [],
    );
  }

  /// `Error loading approvals`
  String get errorLoadingApprovals {
    return Intl.message(
      'Error loading approvals',
      name: 'errorLoadingApprovals',
      desc: '',
      args: [],
    );
  }

  /// `Error Loading Submissions`
  String get errorLoadingSubmissions {
    return Intl.message(
      'Error Loading Submissions',
      name: 'errorLoadingSubmissions',
      desc: '',
      args: [],
    );
  }

  /// `No approvals match your filters`
  String get noApprovalsMatchFilters {
    return Intl.message(
      'No approvals match your filters',
      name: 'noApprovalsMatchFilters',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to approve this request?`
  String get areYouSureYouWantToApproveRequest {
    return Intl.message(
      'Are you sure you want to approve this request?',
      name: 'areYouSureYouWantToApproveRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to reject this request?`
  String get areYouSureYouWantToRejectRequest {
    return Intl.message(
      'Are you sure you want to reject this request?',
      name: 'areYouSureYouWantToRejectRequest',
      desc: '',
      args: [],
    );
  }

  /// `General Information`
  String get generalInformation {
    return Intl.message(
      'General Information',
      name: 'generalInformation',
      desc: '',
      args: [],
    );
  }

  /// `Branding & Theme`
  String get brandingAndTheme {
    return Intl.message(
      'Branding & Theme',
      name: 'brandingAndTheme',
      desc: '',
      args: [],
    );
  }

  /// `Home Layout`
  String get homeLayout {
    return Intl.message('Home Layout', name: 'homeLayout', desc: '', args: []);
  }

  /// `Reordering Active - Click to Disable`
  String get reorderingActive {
    return Intl.message(
      'Reordering Active - Click to Disable',
      name: 'reorderingActive',
      desc: '',
      args: [],
    );
  }

  /// `Enable Drawer Reordering`
  String get enableDrawerReordering {
    return Intl.message(
      'Enable Drawer Reordering',
      name: 'enableDrawerReordering',
      desc: '',
      args: [],
    );
  }

  /// `Company`
  String get company {
    return Intl.message('Company', name: 'company', desc: '', args: []);
  }

  /// `University or Institute`
  String get universityOrInstitute {
    return Intl.message(
      'University or Institute',
      name: 'universityOrInstitute',
      desc: '',
      args: [],
    );
  }

  /// `Choose Degree`
  String get chooseDegree {
    return Intl.message(
      'Choose Degree',
      name: 'chooseDegree',
      desc: '',
      args: [],
    );
  }

  /// `Bachelor's Degree`
  String get bachelorDegree {
    return Intl.message(
      'Bachelor\'s Degree',
      name: 'bachelorDegree',
      desc: '',
      args: [],
    );
  }

  /// `Master's Degree`
  String get masterDegree {
    return Intl.message(
      'Master\'s Degree',
      name: 'masterDegree',
      desc: '',
      args: [],
    );
  }

  /// `PhD`
  String get phdDegree {
    return Intl.message('PhD', name: 'phdDegree', desc: '', args: []);
  }

  /// `Diploma`
  String get diploma {
    return Intl.message('Diploma', name: 'diploma', desc: '', args: []);
  }

  /// `Certificate`
  String get certificate {
    return Intl.message('Certificate', name: 'certificate', desc: '', args: []);
  }

  /// `Graduation Year`
  String get graduationYear {
    return Intl.message(
      'Graduation Year',
      name: 'graduationYear',
      desc: '',
      args: [],
    );
  }

  /// `More`
  String get more {
    return Intl.message('More', name: 'more', desc: '', args: []);
  }

  /// `Skill Name`
  String get skillName {
    return Intl.message('Skill Name', name: 'skillName', desc: '', args: []);
  }

  /// `Skill Level`
  String get skillLevel {
    return Intl.message('Skill Level', name: 'skillLevel', desc: '', args: []);
  }

  /// `Beginner`
  String get beginner {
    return Intl.message('Beginner', name: 'beginner', desc: '', args: []);
  }

  /// `Intermediate`
  String get intermediate {
    return Intl.message(
      'Intermediate',
      name: 'intermediate',
      desc: '',
      args: [],
    );
  }

  /// `Expert`
  String get expert {
    return Intl.message('Expert', name: 'expert', desc: '', args: []);
  }

  /// `Import`
  String get import {
    return Intl.message('Import', name: 'import', desc: '', args: []);
  }

  /// `Editing Success`
  String get editSuccess {
    return Intl.message(
      'Editing Success',
      name: 'editSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Creating Success`
  String get createSuccess {
    return Intl.message(
      'Creating Success',
      name: 'createSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Row`
  String get row {
    return Intl.message('Row', name: 'row', desc: '', args: []);
  }

  /// `Duplication`
  String get duplication {
    return Intl.message('Duplication', name: 'duplication', desc: '', args: []);
  }

  /// `Remove Selection`
  String get removeSelection {
    return Intl.message(
      'Remove Selection',
      name: 'removeSelection',
      desc: '',
      args: [],
    );
  }

  /// `Total Roles`
  String get totalRoles {
    return Intl.message('Total Roles', name: 'totalRoles', desc: '', args: []);
  }

  /// `Activate`
  String get activate {
    return Intl.message('Activate', name: 'activate', desc: '', args: []);
  }

  /// `Activating Roles`
  String get activatingRoles {
    return Intl.message(
      'Activating Roles',
      name: 'activatingRoles',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to activate these roles?`
  String get confirmActivateRoles {
    return Intl.message(
      'Are you sure you want to activate these roles?',
      name: 'confirmActivateRoles',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Statement`
  String get privacyStatement {
    return Intl.message(
      'Privacy Statement',
      name: 'privacyStatement',
      desc: '',
      args: [],
    );
  }

  /// `Emergency Contact`
  String get emergencyContact {
    return Intl.message(
      'Emergency Contact',
      name: 'emergencyContact',
      desc: '',
      args: [],
    );
  }

  /// `Second Emergency Contact`
  String get secondEmergencyContact {
    return Intl.message(
      'Second Emergency Contact',
      name: 'secondEmergencyContact',
      desc: '',
      args: [],
    );
  }

  /// `Health Insurance`
  String get healthInsurance {
    return Intl.message(
      'Health Insurance',
      name: 'healthInsurance',
      desc: '',
      args: [],
    );
  }

  /// `Street`
  String get street {
    return Intl.message('Street', name: 'street', desc: '', args: []);
  }

  /// `Enter Phone Number`
  String get enterPhoneNumber {
    return Intl.message(
      'Enter Phone Number',
      name: 'enterPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter Language`
  String get enterLanguage {
    return Intl.message(
      'Enter Language',
      name: 'enterLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Select Date`
  String get selectdate {
    return Intl.message('Select Date', name: 'selectdate', desc: '', args: []);
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Editing Health Insurance`
  String get editingHealthInsurance {
    return Intl.message(
      'Editing Health Insurance',
      name: 'editingHealthInsurance',
      desc: '',
      args: [],
    );
  }

  /// `Insurance Details`
  String get insuranceDetails {
    return Intl.message(
      'Insurance Details',
      name: 'insuranceDetails',
      desc: '',
      args: [],
    );
  }

  /// `Please ensure that all email and password fields are filled in correctly.`
  String get confirmEmailAndPassword {
    return Intl.message(
      'Please ensure that all email and password fields are filled in correctly.',
      name: 'confirmEmailAndPassword',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout?`
  String get confirmLogout {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'confirmLogout',
      desc: '',
      args: [],
    );
  }

  /// `Comment and Feedback`
  String get commentAndFeedback {
    return Intl.message(
      'Comment and Feedback',
      name: 'commentAndFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Downloading`
  String get downloading {
    return Intl.message('Downloading', name: 'downloading', desc: '', args: []);
  }

  /// `FileDownloadedSuccessfully`
  String get fileDownloadedSuccessfully {
    return Intl.message(
      'FileDownloadedSuccessfully',
      name: 'fileDownloadedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `FailedToDownloadFile`
  String get failedToDownloadFile {
    return Intl.message(
      'FailedToDownloadFile',
      name: 'failedToDownloadFile',
      desc: '',
      args: [],
    );
  }

  /// `OpeningFile`
  String get openingFile {
    return Intl.message('OpeningFile', name: 'openingFile', desc: '', args: []);
  }

  /// `CouldNotOpenFile`
  String get couldNotOpenFile {
    return Intl.message(
      'CouldNotOpenFile',
      name: 'couldNotOpenFile',
      desc: '',
      args: [],
    );
  }

  /// `My Services`
  String get myServices {
    return Intl.message('My Services', name: 'myServices', desc: '', args: []);
  }

  /// `Market Research Service`
  String get marketResearchService {
    return Intl.message(
      'Market Research Service',
      name: 'marketResearchService',
      desc: '',
      args: [],
    );
  }

  /// `Service Status`
  String get serviceStatus {
    return Intl.message(
      'Service Status',
      name: 'serviceStatus',
      desc: '',
      args: [],
    );
  }

  /// `Skills`
  String get skills {
    return Intl.message('Skills', name: 'skills', desc: '', args: []);
  }

  /// `Hobbys`
  String get hobbys {
    return Intl.message('Hobbys', name: 'hobbys', desc: '', args: []);
  }

  /// `Academic History`
  String get academicHistory {
    return Intl.message(
      'Academic History',
      name: 'academicHistory',
      desc: '',
      args: [],
    );
  }

  /// `Relationship`
  String get relationship {
    return Intl.message(
      'Relationship',
      name: 'relationship',
      desc: '',
      args: [],
    );
  }

  /// `Mobile Phone`
  String get mobilePhone {
    return Intl.message(
      'Mobile Phone',
      name: 'mobilePhone',
      desc: '',
      args: [],
    );
  }

  /// `Province`
  String get province {
    return Intl.message('Province', name: 'province', desc: '', args: []);
  }

  /// `Request Note`
  String get requestNote {
    return Intl.message(
      'Request Note',
      name: 'requestNote',
      desc: '',
      args: [],
    );
  }

  /// `Insurance`
  String get insurance {
    return Intl.message('Insurance', name: 'insurance', desc: '', args: []);
  }

  /// `Enter bug details`
  String get enter_bug_details {
    return Intl.message(
      'Enter bug details',
      name: 'enter_bug_details',
      desc: '',
      args: [],
    );
  }

  /// `Enter your comments`
  String get enter_your_comments {
    return Intl.message(
      'Enter your comments',
      name: 'enter_your_comments',
      desc: '',
      args: [],
    );
  }

  /// `Describe the feature`
  String get describe_the_feature {
    return Intl.message(
      'Describe the feature',
      name: 'describe_the_feature',
      desc: '',
      args: [],
    );
  }

  /// `Terms and Conditions`
  String get termsAndConditions {
    return Intl.message(
      'Terms and Conditions',
      name: 'termsAndConditions',
      desc: '',
      args: [],
    );
  }

  /// `Preview Health Insurance Changes`
  String get previewHealthInsuranceChanges {
    return Intl.message(
      'Preview Health Insurance Changes',
      name: 'previewHealthInsuranceChanges',
      desc: '',
      args: [],
    );
  }

  /// `Submitted Date: `
  String get submittedDate {
    return Intl.message(
      'Submitted Date: ',
      name: 'submittedDate',
      desc: '',
      args: [],
    );
  }

  /// `Publishing Date: `
  String get publishingDate {
    return Intl.message(
      'Publishing Date: ',
      name: 'publishingDate',
      desc: '',
      args: [],
    );
  }

  /// `Rejected Date: `
  String get rejectedDate {
    return Intl.message(
      'Rejected Date: ',
      name: 'rejectedDate',
      desc: '',
      args: [],
    );
  }

  /// `Removed Date: `
  String get removedDate {
    return Intl.message(
      'Removed Date: ',
      name: 'removedDate',
      desc: '',
      args: [],
    );
  }

  /// `Publish Date: `
  String get publishDate {
    return Intl.message(
      'Publish Date: ',
      name: 'publishDate',
      desc: '',
      args: [],
    );
  }

  /// `Last Edit`
  String get lastEdit {
    return Intl.message('Last Edit', name: 'lastEdit', desc: '', args: []);
  }

  /// `Owning Department`
  String get owningDepartment {
    return Intl.message(
      'Owning Department',
      name: 'owningDepartment',
      desc: '',
      args: [],
    );
  }

  /// `No Submissions Yet`
  String get noSubmissionsYet {
    return Intl.message(
      'No Submissions Yet',
      name: 'noSubmissionsYet',
      desc: '',
      args: [],
    );
  }

  /// `Document Utilization`
  String get document_utilization {
    return Intl.message(
      'Document Utilization',
      name: 'document_utilization',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created This GRC Control`
  String get successSubtitle {
    return Intl.message(
      'You Successfully Created This GRC Control',
      name: 'successSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Control Owner`
  String get controlOwner {
    return Intl.message(
      'Control Owner',
      name: 'controlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Airflow Inspection`
  String get airflowInspection {
    return Intl.message(
      'Airflow Inspection',
      name: 'airflowInspection',
      desc: '',
      args: [],
    );
  }

  /// `Choose Baseline`
  String get chooseBaseline {
    return Intl.message(
      'Choose Baseline',
      name: 'chooseBaseline',
      desc: '',
      args: [],
    );
  }

  /// `Activation Date`
  String get activationDate {
    return Intl.message(
      'Activation Date',
      name: 'activationDate',
      desc: '',
      args: [],
    );
  }

  /// `Control Owners`
  String get controlOwners {
    return Intl.message(
      'Control Owners',
      name: 'controlOwners',
      desc: '',
      args: [],
    );
  }

  /// `Policy Number`
  String get policyNumber {
    return Intl.message(
      'Policy Number',
      name: 'policyNumber',
      desc: '',
      args: [],
    );
  }

  /// `Module Name`
  String get moduleName {
    return Intl.message('Module Name', name: 'moduleName', desc: '', args: []);
  }

  /// `Marketing Manager`
  String get marketingManager {
    return Intl.message(
      'Marketing Manager',
      name: 'marketingManager',
      desc: '',
      args: [],
    );
  }

  /// `Pest Control`
  String get pestControl {
    return Intl.message(
      'Pest Control',
      name: 'pestControl',
      desc: '',
      args: [],
    );
  }

  /// `Choose Here`
  String get chooseHere {
    return Intl.message('Choose Here', name: 'chooseHere', desc: '', args: []);
  }

  /// `Ensure room temperature remains stable.`
  String get ensureRoomTemperatureRemainsStable {
    return Intl.message(
      'Ensure room temperature remains stable.',
      name: 'ensureRoomTemperatureRemainsStable',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get restore {
    return Intl.message('Restore', name: 'restore', desc: '', args: []);
  }

  /// `Message`
  String get message {
    return Intl.message('Message', name: 'message', desc: '', args: []);
  }

  /// `You Successfully Restored This Module`
  String get successfullyRestoredGrc {
    return Intl.message(
      'You Successfully Restored This Module',
      name: 'successfullyRestoredGrc',
      desc: '',
      args: [],
    );
  }

  /// `Feb`
  String get feb {
    return Intl.message('Feb', name: 'feb', desc: '', args: []);
  }

  /// `Equal Control Weight`
  String get equalControlWeight {
    return Intl.message(
      'Equal Control Weight',
      name: 'equalControlWeight',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yesTitleButton {
    return Intl.message('Yes', name: 'yesTitleButton', desc: '', args: []);
  }

  /// `Creating policy`
  String get creatingPolicy {
    return Intl.message(
      'Creating policy',
      name: 'creatingPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Add Baseline`
  String get addBaseline {
    return Intl.message(
      'Add Baseline',
      name: 'addBaseline',
      desc: '',
      args: [],
    );
  }

  /// `Baseline Color`
  String get baselineColor {
    return Intl.message(
      'Baseline Color',
      name: 'baselineColor',
      desc: '',
      args: [],
    );
  }

  /// `Creating Modules`
  String get creatingModules {
    return Intl.message(
      'Creating Modules',
      name: 'creatingModules',
      desc: '',
      args: [],
    );
  }

  /// `Control Name`
  String get controlName {
    return Intl.message(
      'Control Name',
      name: 'controlName',
      desc: '',
      args: [],
    );
  }

  /// `Choose Date`
  String get chooseDate {
    return Intl.message('Choose Date', name: 'chooseDate', desc: '', args: []);
  }

  /// `Are You Sure You Want To Create This Module?`
  String get areYouSureCreate {
    return Intl.message(
      'Are You Sure You Want To Create This Module?',
      name: 'areYouSureCreate',
      desc: '',
      args: [],
    );
  }

  /// `Expired`
  String get expired {
    return Intl.message('Expired', name: 'expired', desc: '', args: []);
  }

  /// `Policy Compliance`
  String get policyCompliance {
    return Intl.message(
      'Policy Compliance',
      name: 'policyCompliance',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Control?`
  String get subtitle {
    return Intl.message(
      'Are You Sure You Want To Create This Control?',
      name: 'subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Inspect fire extinguishers and alarms.`
  String get inspectFireExtinguishersAndAlarms {
    return Intl.message(
      'Inspect fire extinguishers and alarms.',
      name: 'inspectFireExtinguishersAndAlarms',
      desc: '',
      args: [],
    );
  }

  /// `Create Arabic Version`
  String get createArabicVersion {
    return Intl.message(
      'Create Arabic Version',
      name: 'createArabicVersion',
      desc: '',
      args: [],
    );
  }

  /// `Quality Assurance`
  String get qualityAssurance {
    return Intl.message(
      'Quality Assurance',
      name: 'qualityAssurance',
      desc: '',
      args: [],
    );
  }

  /// `Monthly`
  String get monthly {
    return Intl.message('Monthly', name: 'monthly', desc: '', args: []);
  }

  /// `Publish`
  String get publish {
    return Intl.message('Publish', name: 'publish', desc: '', args: []);
  }

  /// `Create Module`
  String get createModule {
    return Intl.message(
      'Create Module',
      name: 'createModule',
      desc: '',
      args: [],
    );
  }

  /// `Apr`
  String get apr {
    return Intl.message('Apr', name: 'apr', desc: '', args: []);
  }

  /// `Module Owner`
  String get moduleOwner {
    return Intl.message(
      'Module Owner',
      name: 'moduleOwner',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to proceed with assigning equal weight to all controls?`
  String get areYouSureYouWantToProceedWithAssigningEqualWeightToAllControls {
    return Intl.message(
      'Are you sure you want to proceed with assigning equal weight to all controls?',
      name: 'areYouSureYouWantToProceedWithAssigningEqualWeightToAllControls',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Disable The Module?`
  String get areYouSureDisable {
    return Intl.message(
      'Are You Sure You Want To Disable The Module?',
      name: 'areYouSureDisable',
      desc: '',
      args: [],
    );
  }

  /// `Weekly`
  String get weekly {
    return Intl.message('Weekly', name: 'weekly', desc: '', args: []);
  }

  /// `Choose Department`
  String get chooseDepartment {
    return Intl.message(
      'Choose Department',
      name: 'chooseDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Restored GRC Module`
  String get restoredGrcModule {
    return Intl.message(
      'Restored GRC Module',
      name: 'restoredGrcModule',
      desc: '',
      args: [],
    );
  }

  /// `DES`
  String get des {
    return Intl.message('DES', name: 'des', desc: '', args: []);
  }

  /// `Top`
  String get top {
    return Intl.message('Top', name: 'top', desc: '', args: []);
  }

  /// `Policy Details`
  String get policyDetails {
    return Intl.message(
      'Policy Details',
      name: 'policyDetails',
      desc: '',
      args: [],
    );
  }

  /// `assets/icons_assets/main_icons_assets/check_circle_green.svg`
  String get imageAsset {
    return Intl.message(
      'assets/icons_assets/main_icons_assets/check_circle_green.svg',
      name: 'imageAsset',
      desc: '',
      args: [],
    );
  }

  /// `Governance, Risk, and Compliance`
  String get governanceRiskCompliance {
    return Intl.message(
      'Governance, Risk, and Compliance',
      name: 'governanceRiskCompliance',
      desc: '',
      args: [],
    );
  }

  /// `Select Modules`
  String get selectModules {
    return Intl.message(
      'Select Modules',
      name: 'selectModules',
      desc: '',
      args: [],
    );
  }

  /// `Daily`
  String get daily {
    return Intl.message('Daily', name: 'daily', desc: '', args: []);
  }

  /// `Red`
  String get red {
    return Intl.message('Red', name: 'red', desc: '', args: []);
  }

  /// `Amro Handousa`
  String get amroHandousa {
    return Intl.message(
      'Amro Handousa',
      name: 'amroHandousa',
      desc: '',
      args: [],
    );
  }

  /// `Deleted GRC Module`
  String get deletedGrcModule {
    return Intl.message(
      'Deleted GRC Module',
      name: 'deletedGrcModule',
      desc: '',
      args: [],
    );
  }

  /// `Orange`
  String get orange {
    return Intl.message('Orange', name: 'orange', desc: '', args: []);
  }

  /// `Select Activation Date`
  String get selectActivationDate {
    return Intl.message(
      'Select Activation Date',
      name: 'selectActivationDate',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to create this policy?`
  String get areYouSureYouWantToCreateThisPolicy {
    return Intl.message(
      'Are you sure you want to create this policy?',
      name: 'areYouSureYouWantToCreateThisPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Bi weekly`
  String get biWeekly {
    return Intl.message('Bi weekly', name: 'biWeekly', desc: '', args: []);
  }

  /// `Check for cleanliness and hygiene standards.`
  String get checkForCleanlinessAndHygieneStandards {
    return Intl.message(
      'Check for cleanliness and hygiene standards.',
      name: 'checkForCleanlinessAndHygieneStandards',
      desc: '',
      args: [],
    );
  }

  /// `No of Controls`
  String get noOfControls {
    return Intl.message(
      'No of Controls',
      name: 'noOfControls',
      desc: '',
      args: [],
    );
  }

  /// `Successfully`
  String get successfully {
    return Intl.message(
      'Successfully',
      name: 'successfully',
      desc: '',
      args: [],
    );
  }

  /// `Ali`
  String get ali {
    return Intl.message('Ali', name: 'ali', desc: '', args: []);
  }

  /// `Ensure all security protocols are followed.`
  String get ensureAllSecurityProtocolsAreFollowed {
    return Intl.message(
      'Ensure all security protocols are followed.',
      name: 'ensureAllSecurityProtocolsAreFollowed',
      desc: '',
      args: [],
    );
  }

  /// `Inventory Audit`
  String get inventoryAudit {
    return Intl.message(
      'Inventory Audit',
      name: 'inventoryAudit',
      desc: '',
      args: [],
    );
  }

  /// `Jun`
  String get jun {
    return Intl.message('Jun', name: 'jun', desc: '', args: []);
  }

  /// `Monitor humidity levels and adjust if necessary.`
  String get monitorHumidityLevelsAndAdjustIfNecessary {
    return Intl.message(
      'Monitor humidity levels and adjust if necessary.',
      name: 'monitorHumidityLevelsAndAdjustIfNecessary',
      desc: '',
      args: [],
    );
  }

  /// `Security Audit`
  String get securityAudit {
    return Intl.message(
      'Security Audit',
      name: 'securityAudit',
      desc: '',
      args: [],
    );
  }

  /// `You successfully created this GRC policy`
  String get youSuccessfullyCreatedThisGrcPolicy {
    return Intl.message(
      'You successfully created this GRC policy',
      name: 'youSuccessfullyCreatedThisGrcPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Create New Policy`
  String get createNewPolicy {
    return Intl.message(
      'Create New Policy',
      name: 'createNewPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Delete This GRC Module?`
  String get areYouSureDelete {
    return Intl.message(
      'Are You Sure You Want To Delete This GRC Module?',
      name: 'areYouSureDelete',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Blue`
  String get blue {
    return Intl.message('Blue', name: 'blue', desc: '', args: []);
  }

  /// `Qiyas 2`
  String get qiyas2 {
    return Intl.message('Qiyas 2', name: 'qiyas2', desc: '', args: []);
  }

  /// `Health, Safety and Environment`
  String get hse {
    return Intl.message(
      'Health, Safety and Environment',
      name: 'hse',
      desc: '',
      args: [],
    );
  }

  /// `Control Champions`
  String get controlChampions {
    return Intl.message(
      'Control Champions',
      name: 'controlChampions',
      desc: '',
      args: [],
    );
  }

  /// `ASC`
  String get asc {
    return Intl.message('ASC', name: 'asc', desc: '', args: []);
  }

  /// `Cleanliness Audit`
  String get cleanlinessAudit {
    return Intl.message(
      'Cleanliness Audit',
      name: 'cleanlinessAudit',
      desc: '',
      args: [],
    );
  }

  /// `Count items and verify stock levels.`
  String get countItemsAndVerifyStockLevels {
    return Intl.message(
      'Count items and verify stock levels.',
      name: 'countItemsAndVerifyStockLevels',
      desc: '',
      args: [],
    );
  }

  /// `GRC`
  String get grc {
    return Intl.message('GRC', name: 'grc', desc: '', args: []);
  }

  /// `Creating Control`
  String get successTitle {
    return Intl.message(
      'Creating Control',
      name: 'successTitle',
      desc: '',
      args: [],
    );
  }

  /// `GRC Module Name`
  String get grcModuleName {
    return Intl.message(
      'GRC Module Name',
      name: 'grcModuleName',
      desc: '',
      args: [],
    );
  }

  /// `Add Policy Controls`
  String get addPolicyControls {
    return Intl.message(
      'Add Policy Controls',
      name: 'addPolicyControls',
      desc: '',
      args: [],
    );
  }

  /// `Controls`
  String get controls {
    return Intl.message('Controls', name: 'controls', desc: '', args: []);
  }

  /// `Control Description`
  String get controlDescription {
    return Intl.message(
      'Control Description',
      name: 'controlDescription',
      desc: '',
      args: [],
    );
  }

  /// `Cyber Security`
  String get cyberSecurity {
    return Intl.message(
      'Cyber Security',
      name: 'cyberSecurity',
      desc: '',
      args: [],
    );
  }

  /// `Control Document`
  String get controlDocument {
    return Intl.message(
      'Control Document',
      name: 'controlDocument',
      desc: '',
      args: [],
    );
  }

  /// `Total Weight`
  String get totalWeight {
    return Intl.message(
      'Total Weight',
      name: 'totalWeight',
      desc: '',
      args: [],
    );
  }

  /// `Temperature Control`
  String get temperatureControl {
    return Intl.message(
      'Temperature Control',
      name: 'temperatureControl',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `Search People`
  String get searchPeople {
    return Intl.message(
      'Search People',
      name: 'searchPeople',
      desc: '',
      args: [],
    );
  }

  /// `Policy Name 2`
  String get policyName2 {
    return Intl.message(
      'Policy Name 2',
      name: 'policyName2',
      desc: '',
      args: [],
    );
  }

  /// `Policies`
  String get policies {
    return Intl.message('Policies', name: 'policies', desc: '', args: []);
  }

  /// `Above Baseline Color`
  String get aboveBaselineColor {
    return Intl.message(
      'Above Baseline Color',
      name: 'aboveBaselineColor',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited This Module`
  String get successfullyEditedGrc {
    return Intl.message(
      'You Successfully Edited This Module',
      name: 'successfullyEditedGrc',
      desc: '',
      args: [],
    );
  }

  /// `Total Weight Should be`
  String get totalWeightShouldBe {
    return Intl.message(
      'Total Weight Should be',
      name: 'totalWeightShouldBe',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Proceed With Assigning Equal Weight To All Controls?`
  String get confirmEqualWeight {
    return Intl.message(
      'Are You Sure You Want To Proceed With Assigning Equal Weight To All Controls?',
      name: 'confirmEqualWeight',
      desc: '',
      args: [],
    );
  }

  /// `Frequency`
  String get frequency {
    return Intl.message('Frequency', name: 'frequency', desc: '', args: []);
  }

  /// `Policy Document`
  String get policyDocument {
    return Intl.message(
      'Policy Document',
      name: 'policyDocument',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Create Policy`
  String get youSuccessfullyCreatePolicy {
    return Intl.message(
      'You Successfully Create Policy',
      name: 'youSuccessfullyCreatePolicy',
      desc: '',
      args: [],
    );
  }

  /// `Compliance Timeline`
  String get complianceTimeline {
    return Intl.message(
      'Compliance Timeline',
      name: 'complianceTimeline',
      desc: '',
      args: [],
    );
  }

  /// `Policy Weight`
  String get policyWeight {
    return Intl.message(
      'Policy Weight',
      name: 'policyWeight',
      desc: '',
      args: [],
    );
  }

  /// `Annually`
  String get annually {
    return Intl.message('Annually', name: 'annually', desc: '', args: []);
  }

  /// `Services Offered`
  String get servicSOffered {
    return Intl.message(
      'Services Offered',
      name: 'servicSOffered',
      desc: '',
      args: [],
    );
  }

  /// `Equal Weight`
  String get equalWeight {
    return Intl.message(
      'Equal Weight',
      name: 'equalWeight',
      desc: '',
      args: [],
    );
  }

  /// `Control Status`
  String get controlStatus {
    return Intl.message(
      'Control Status',
      name: 'controlStatus',
      desc: '',
      args: [],
    );
  }

  /// `Changed Status`
  String get changedStatus {
    return Intl.message(
      'Changed Status',
      name: 'changedStatus',
      desc: '',
      args: [],
    );
  }

  /// `عنوان اطار الحوكمه`
  String get grcModuleNameArabic {
    return Intl.message(
      'عنوان اطار الحوكمه',
      name: 'grcModuleNameArabic',
      desc: '',
      args: [],
    );
  }

  /// `Compliance Score`
  String get complianceScore {
    return Intl.message(
      'Compliance Score',
      name: 'complianceScore',
      desc: '',
      args: [],
    );
  }

  /// `Policy Name 4`
  String get policyName4 {
    return Intl.message(
      'Policy Name 4',
      name: 'policyName4',
      desc: '',
      args: [],
    );
  }

  /// `Equipment Check`
  String get equipmentCheck {
    return Intl.message(
      'Equipment Check',
      name: 'equipmentCheck',
      desc: '',
      args: [],
    );
  }

  /// `May`
  String get may {
    return Intl.message('May', name: 'may', desc: '', args: []);
  }

  /// `Humidity Check`
  String get humidityCheck {
    return Intl.message(
      'Humidity Check',
      name: 'humidityCheck',
      desc: '',
      args: [],
    );
  }

  /// `Choose Module Mode`
  String get chooseModuleMode {
    return Intl.message(
      'Choose Module Mode',
      name: 'chooseModuleMode',
      desc: '',
      args: [],
    );
  }

  /// `الوصف`
  String get descriptionArabic {
    return Intl.message('الوصف', name: 'descriptionArabic', desc: '', args: []);
  }

  /// `You Have Successfully Assigned Equal Weight To All Controls`
  String get successEqualWeight {
    return Intl.message(
      'You Have Successfully Assigned Equal Weight To All Controls',
      name: 'successEqualWeight',
      desc: '',
      args: [],
    );
  }

  /// `Policy Description`
  String get policyDescription {
    return Intl.message(
      'Policy Description',
      name: 'policyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Ensure all equipment is functional.`
  String get ensureAllEquipmentIsFunctional {
    return Intl.message(
      'Ensure all equipment is functional.',
      name: 'ensureAllEquipmentIsFunctional',
      desc: '',
      args: [],
    );
  }

  /// `Control Number`
  String get controlNumber {
    return Intl.message(
      'Control Number',
      name: 'controlNumber',
      desc: '',
      args: [],
    );
  }

  /// `Qiyas 1`
  String get qiyas1 {
    return Intl.message('Qiyas 1', name: 'qiyas1', desc: '', args: []);
  }

  /// `Qiyas`
  String get qiyas {
    return Intl.message('Qiyas', name: 'qiyas', desc: '', args: []);
  }

  /// `Health, Safety, and Environment`
  String get healthSafetyEnvironment {
    return Intl.message(
      'Health, Safety, and Environment',
      name: 'healthSafetyEnvironment',
      desc: '',
      args: [],
    );
  }

  /// `Control Weight`
  String get controlWeight {
    return Intl.message(
      'Control Weight',
      name: 'controlWeight',
      desc: '',
      args: [],
    );
  }

  /// `Previewing Policy & Controls`
  String get previewingPolicyAndControls {
    return Intl.message(
      'Previewing Policy & Controls',
      name: 'previewingPolicyAndControls',
      desc: '',
      args: [],
    );
  }

  /// `Policy Name`
  String get policyName {
    return Intl.message('Policy Name', name: 'policyName', desc: '', args: []);
  }

  /// `Policy Name 5`
  String get policyName5 {
    return Intl.message(
      'Policy Name 5',
      name: 'policyName5',
      desc: '',
      args: [],
    );
  }

  /// `Check air circulation in storage area.`
  String get checkAirCirculationInStorageArea {
    return Intl.message(
      'Check air circulation in storage area.',
      name: 'checkAirCirculationInStorageArea',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get num {
    return Intl.message('No', name: 'num', desc: '', args: []);
  }

  /// `Approved Evidence`
  String get approvedEvidence {
    return Intl.message(
      'Approved Evidence',
      name: 'approvedEvidence',
      desc: '',
      args: [],
    );
  }

  /// `Select Year`
  String get selectYear {
    return Intl.message('Select Year', name: 'selectYear', desc: '', args: []);
  }

  /// `Department Performance`
  String get departmentPerformance {
    return Intl.message(
      'Department Performance',
      name: 'departmentPerformance',
      desc: '',
      args: [],
    );
  }

  /// `Inspect for any signs of pests.`
  String get inspectForAnySignsOfPests {
    return Intl.message(
      'Inspect for any signs of pests.',
      name: 'inspectForAnySignsOfPests',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get noTitleButton {
    return Intl.message('No', name: 'noTitleButton', desc: '', args: []);
  }

  /// `Check all lighting fixtures.`
  String get checkAllLightingFixtures {
    return Intl.message(
      'Check all lighting fixtures.',
      name: 'checkAllLightingFixtures',
      desc: '',
      args: [],
    );
  }

  /// `Discard Changes`
  String get discardChanges {
    return Intl.message(
      'Discard Changes',
      name: 'discardChanges',
      desc: '',
      args: [],
    );
  }

  /// `Yellow`
  String get yellow {
    return Intl.message('Yellow', name: 'yellow', desc: '', args: []);
  }

  /// `Fire Safety`
  String get fireSafety {
    return Intl.message('Fire Safety', name: 'fireSafety', desc: '', args: []);
  }

  /// `Welcome to our app`
  String get welcome {
    return Intl.message(
      'Welcome to our app',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `Policy Weight Issue`
  String get policyWeightIssue {
    return Intl.message(
      'Policy Weight Issue',
      name: 'policyWeightIssue',
      desc: '',
      args: [],
    );
  }

  /// `Department Score`
  String get departmentScore {
    return Intl.message(
      'Department Score',
      name: 'departmentScore',
      desc: '',
      args: [],
    );
  }

  /// `Mar`
  String get mar {
    return Intl.message('Mar', name: 'mar', desc: '', args: []);
  }

  /// `Edited Modules`
  String get editedModules {
    return Intl.message(
      'Edited Modules',
      name: 'editedModules',
      desc: '',
      args: [],
    );
  }

  /// `The Module Name Already Exists`
  String get moduleNameAlreadyExists {
    return Intl.message(
      'The Module Name Already Exists',
      name: 'moduleNameAlreadyExists',
      desc: '',
      args: [],
    );
  }

  /// `You have successfully assigned equal weight for all controls`
  String get youHaveSuccessfullyEqualWeightForAllControls {
    return Intl.message(
      'You have successfully assigned equal weight for all controls',
      name: 'youHaveSuccessfullyEqualWeightForAllControls',
      desc: '',
      args: [],
    );
  }

  /// `Semi Annual`
  String get semiAnnual {
    return Intl.message('Semi Annual', name: 'semiAnnual', desc: '', args: []);
  }

  /// `Deleting GRC Module`
  String get deletingGrcModule {
    return Intl.message(
      'Deleting GRC Module',
      name: 'deletingGrcModule',
      desc: '',
      args: [],
    );
  }

  /// `Editing GRC Module`
  String get editingGrcModule {
    return Intl.message(
      'Editing GRC Module',
      name: 'editingGrcModule',
      desc: '',
      args: [],
    );
  }

  /// `Edit Policy`
  String get editPolicy {
    return Intl.message('Edit Policy', name: 'editPolicy', desc: '', args: []);
  }

  /// `Policy Name 3`
  String get policyName3 {
    return Intl.message(
      'Policy Name 3',
      name: 'policyName3',
      desc: '',
      args: [],
    );
  }

  /// `Mohamed`
  String get mohamed {
    return Intl.message('Mohamed', name: 'mohamed', desc: '', args: []);
  }

  /// `Creation Date`
  String get creationDate {
    return Intl.message(
      'Creation Date',
      name: 'creationDate',
      desc: '',
      args: [],
    );
  }

  /// `Score`
  String get score {
    return Intl.message('Score', name: 'score', desc: '', args: []);
  }

  /// `Created Modules`
  String get createdModules {
    return Intl.message(
      'Created Modules',
      name: 'createdModules',
      desc: '',
      args: [],
    );
  }

  /// `Lighting Inspection`
  String get lightingInspection {
    return Intl.message(
      'Lighting Inspection',
      name: 'lightingInspection',
      desc: '',
      args: [],
    );
  }

  /// `Control`
  String get control {
    return Intl.message('Control', name: 'control', desc: '', args: []);
  }

  /// `Strategy & Alignment`
  String get strategyAlignment {
    return Intl.message(
      'Strategy & Alignment',
      name: 'strategyAlignment',
      desc: '',
      args: [],
    );
  }

  /// `Modules`
  String get modules {
    return Intl.message('Modules', name: 'modules', desc: '', args: []);
  }

  /// `Jan`
  String get jan {
    return Intl.message('Jan', name: 'jan', desc: '', args: []);
  }

  /// `Create New GRC Module`
  String get createNewGrcModule {
    return Intl.message(
      'Create New GRC Module',
      name: 'createNewGrcModule',
      desc: '',
      args: [],
    );
  }

  /// `Restoring Module`
  String get restoringModule {
    return Intl.message(
      'Restoring Module',
      name: 'restoringModule',
      desc: '',
      args: [],
    );
  }

  /// `Risk Management`
  String get riskManagement {
    return Intl.message(
      'Risk Management',
      name: 'riskManagement',
      desc: '',
      args: [],
    );
  }

  /// `Create GRC Module`
  String get createGrcModule {
    return Intl.message(
      'Create GRC Module',
      name: 'createGrcModule',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created This GRC Module`
  String get successfullyCreatedGrc {
    return Intl.message(
      'You Successfully Created This GRC Module',
      name: 'successfullyCreatedGrc',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Edit This Module?`
  String get areYouSureEdit {
    return Intl.message(
      'Are You Sure You Want To Edit This Module?',
      name: 'areYouSureEdit',
      desc: '',
      args: [],
    );
  }

  /// `Policy Name 1`
  String get policyName1 {
    return Intl.message(
      'Policy Name 1',
      name: 'policyName1',
      desc: '',
      args: [],
    );
  }

  /// `Least`
  String get least {
    return Intl.message('Least', name: 'least', desc: '', args: []);
  }

  /// `Ahmed`
  String get ahmed {
    return Intl.message('Ahmed', name: 'ahmed', desc: '', args: []);
  }

  /// `Not Assigned`
  String get notAssigned {
    return Intl.message(
      'Not Assigned',
      name: 'notAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Restore The Module?`
  String get areYouSureRestore {
    return Intl.message(
      'Are You Sure You Want To Restore The Module?',
      name: 'areYouSureRestore',
      desc: '',
      args: [],
    );
  }

  /// `Editing Modules`
  String get editingModules {
    return Intl.message(
      'Editing Modules',
      name: 'editingModules',
      desc: '',
      args: [],
    );
  }

  /// `Policy Name 6`
  String get policyName6 {
    return Intl.message(
      'Policy Name 6',
      name: 'policyName6',
      desc: '',
      args: [],
    );
  }

  /// `Department Score`
  String get departmentScores {
    return Intl.message(
      'Department Score',
      name: 'departmentScores',
      desc: '',
      args: [],
    );
  }

  /// `Module Owners`
  String get moduleOwners {
    return Intl.message(
      'Module Owners',
      name: 'moduleOwners',
      desc: '',
      args: [],
    );
  }

  /// `Internal Audit`
  String get internalAudit {
    return Intl.message(
      'Internal Audit',
      name: 'internalAudit',
      desc: '',
      args: [],
    );
  }

  /// `Departments Score`
  String get departmentsScore {
    return Intl.message(
      'Departments Score',
      name: 'departmentsScore',
      desc: '',
      args: [],
    );
  }

  /// `Baseline`
  String get basline {
    return Intl.message('Baseline', name: 'basline', desc: '', args: []);
  }

  /// `Below Baseline Color`
  String get belowBaselineColor {
    return Intl.message(
      'Below Baseline Color',
      name: 'belowBaselineColor',
      desc: '',
      args: [],
    );
  }

  /// `Quarterly`
  String get quarterly {
    return Intl.message('Quarterly', name: 'quarterly', desc: '', args: []);
  }

  /// `Color Coding`
  String get colorCoding {
    return Intl.message(
      'Color Coding',
      name: 'colorCoding',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Deleted This Module`
  String get successfullyDeletedGrc {
    return Intl.message(
      'You Successfully Deleted This Module',
      name: 'successfullyDeletedGrc',
      desc: '',
      args: [],
    );
  }

  /// `Add Policy`
  String get addPolicy {
    return Intl.message('Add Policy', name: 'addPolicy', desc: '', args: []);
  }

  /// `Select Control`
  String get selectControl {
    return Intl.message(
      'Select Control',
      name: 'selectControl',
      desc: '',
      args: [],
    );
  }

  /// `Years`
  String get years {
    return Intl.message('Years', name: 'years', desc: '', args: []);
  }

  /// `Select Department`
  String get selectDepartment {
    return Intl.message(
      'Select Department',
      name: 'selectDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Select Policy`
  String get selectPolicy {
    return Intl.message(
      'Select Policy',
      name: 'selectPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Select Module`
  String get selectModule {
    return Intl.message(
      'Select Module',
      name: 'selectModule',
      desc: '',
      args: [],
    );
  }

  /// `CREATION_DATE`
  String get CREATION_DATE {
    return Intl.message(
      'CREATION_DATE',
      name: 'CREATION_DATE',
      desc: '',
      args: [],
    );
  }

  /// `Senior Auditor`
  String get seniorAuditor {
    return Intl.message(
      'Senior Auditor',
      name: 'seniorAuditor',
      desc: '',
      args: [],
    );
  }

  /// `Risk Manager`
  String get riskManager {
    return Intl.message(
      'Risk Manager',
      name: 'riskManager',
      desc: '',
      args: [],
    );
  }

  /// `Legal Department`
  String get legalDepartment {
    return Intl.message(
      'Legal Department',
      name: 'legalDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Operations Department`
  String get operationsDepartment {
    return Intl.message(
      'Operations Department',
      name: 'operationsDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Write a Comment`
  String get writeComment {
    return Intl.message(
      'Write a Comment',
      name: 'writeComment',
      desc: '',
      args: [],
    );
  }

  /// `Control Average Weight`
  String get controlAverageWeight {
    return Intl.message(
      'Control Average Weight',
      name: 'controlAverageWeight',
      desc: '',
      args: [],
    );
  }

  /// `Previous Control Owners`
  String get previousControlOwners {
    return Intl.message(
      'Previous Control Owners',
      name: 'previousControlOwners',
      desc: '',
      args: [],
    );
  }

  /// `Assigned By`
  String get assignedBy {
    return Intl.message('Assigned By', name: 'assignedBy', desc: '', args: []);
  }

  /// `Uploaded On`
  String get uploadedOn {
    return Intl.message('Uploaded On', name: 'uploadedOn', desc: '', args: []);
  }

  /// `Table`
  String get table {
    return Intl.message('Table', name: 'table', desc: '', args: []);
  }

  /// `Applied Controls`
  String get appliedControls {
    return Intl.message(
      'Applied Controls',
      name: 'appliedControls',
      desc: '',
      args: [],
    );
  }

  /// `Reporting and Audit`
  String get reportingAndAudit {
    return Intl.message(
      'Reporting and Audit',
      name: 'reportingAndAudit',
      desc: '',
      args: [],
    );
  }

  /// `History Control Owners`
  String get historyControlOwners {
    return Intl.message(
      'History Control Owners',
      name: 'historyControlOwners',
      desc: '',
      args: [],
    );
  }

  /// `Published By`
  String get publishedBy {
    return Intl.message(
      'Published By',
      name: 'publishedBy',
      desc: '',
      args: [],
    );
  }

  /// `Choose Policy`
  String get choosePolicy {
    return Intl.message(
      'Choose Policy',
      name: 'choosePolicy',
      desc: '',
      args: [],
    );
  }

  /// `Food Service`
  String get foodService {
    return Intl.message(
      'Food Service',
      name: 'foodService',
      desc: '',
      args: [],
    );
  }

  /// `Baseline`
  String get baseline {
    return Intl.message('Baseline', name: 'baseline', desc: '', args: []);
  }

  /// `Financial Service`
  String get financialService {
    return Intl.message(
      'Financial Service',
      name: 'financialService',
      desc: '',
      args: [],
    );
  }

  /// `Hospitality`
  String get hospitality {
    return Intl.message('Hospitality', name: 'hospitality', desc: '', args: []);
  }

  /// `Online Retail`
  String get onlineRetail {
    return Intl.message(
      'Online Retail',
      name: 'onlineRetail',
      desc: '',
      args: [],
    );
  }

  /// `Departments Weight`
  String get departmentsWeight {
    return Intl.message(
      'Departments Weight',
      name: 'departmentsWeight',
      desc: '',
      args: [],
    );
  }

  /// `Applied Policies`
  String get appliedPolicies {
    return Intl.message(
      'Applied Policies',
      name: 'appliedPolicies',
      desc: '',
      args: [],
    );
  }

  /// `OWNER`
  String get OWNER {
    return Intl.message('OWNER', name: 'OWNER', desc: '', args: []);
  }

  /// `Download File`
  String get downloadFile {
    return Intl.message(
      'Download File',
      name: 'downloadFile',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to save it for later?`
  String get saveForLaterMessage {
    return Intl.message(
      'Do you want to save it for later?',
      name: 'saveForLaterMessage',
      desc: '',
      args: [],
    );
  }

  /// `Compliance Officer`
  String get complianceOfficer {
    return Intl.message(
      'Compliance Officer',
      name: 'complianceOfficer',
      desc: '',
      args: [],
    );
  }

  /// `Operations Manager`
  String get operationsManager {
    return Intl.message(
      'Operations Manager',
      name: 'operationsManager',
      desc: '',
      args: [],
    );
  }

  /// `Finance Department`
  String get financeDepartment {
    return Intl.message(
      'Finance Department',
      name: 'financeDepartment',
      desc: '',
      args: [],
    );
  }

  /// `IT Department`
  String get itDepartment {
    return Intl.message(
      'IT Department',
      name: 'itDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Legal Officer`
  String get legalOfficer {
    return Intl.message(
      'Legal Officer',
      name: 'legalOfficer',
      desc: '',
      args: [],
    );
  }

  /// `Finance Officer`
  String get financeOfficer {
    return Intl.message(
      'Finance Officer',
      name: 'financeOfficer',
      desc: '',
      args: [],
    );
  }

  /// `Restoring GRC Module`
  String get restoringGrcModule {
    return Intl.message(
      'Restoring GRC Module',
      name: 'restoringGrcModule',
      desc: '',
      args: [],
    );
  }

  /// `Successfully Restored Module`
  String get successfullyRestoredModule {
    return Intl.message(
      'Successfully Restored Module',
      name: 'successfullyRestoredModule',
      desc: '',
      args: [],
    );
  }

  /// `Under Review`
  String get underReview {
    return Intl.message(
      'Under Review',
      name: 'underReview',
      desc: '',
      args: [],
    );
  }

  /// `Archived`
  String get archived {
    return Intl.message('Archived', name: 'archived', desc: '', args: []);
  }

  /// `Image not found`
  String get imageNotFound {
    return Intl.message(
      'Image not found',
      name: 'imageNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Module updated successfully!`
  String get moduleUpdatedSuccessfully {
    return Intl.message(
      'Module updated successfully!',
      name: 'moduleUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `No controls found`
  String get noControlsFound {
    return Intl.message(
      'No controls found',
      name: 'noControlsFound',
      desc: '',
      args: [],
    );
  }

  /// `Edit control screen not implemented yet`
  String get editControlScreenNotImplemented {
    return Intl.message(
      'Edit control screen not implemented yet',
      name: 'editControlScreenNotImplemented',
      desc: '',
      args: [],
    );
  }

  /// `Control owners history screen not implemented yet`
  String get controlOwnersHistoryScreenNotImplemented {
    return Intl.message(
      'Control owners history screen not implemented yet',
      name: 'controlOwnersHistoryScreenNotImplemented',
      desc: '',
      args: [],
    );
  }

  /// `Deleting Controls`
  String get deletingControls {
    return Intl.message(
      'Deleting Controls',
      name: 'deletingControls',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Deleted This Control`
  String get successfullyDeletedControl {
    return Intl.message(
      'You Successfully Deleted This Control',
      name: 'successfullyDeletedControl',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Delete This Control?`
  String get areYouSureDeleteControl {
    return Intl.message(
      'Are You Sure You Want To Delete This Control?',
      name: 'areYouSureDeleteControl',
      desc: '',
      args: [],
    );
  }

  /// `Chart Examples`
  String get chartExamples {
    return Intl.message(
      'Chart Examples',
      name: 'chartExamples',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Choose Control`
  String get chooseControl {
    return Intl.message(
      'Choose Control',
      name: 'chooseControl',
      desc: '',
      args: [],
    );
  }

  /// `Add New Control Champion`
  String get addNewControlChampion {
    return Intl.message(
      'Add New Control Champion',
      name: 'addNewControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Assign Control`
  String get assignControl {
    return Intl.message(
      'Assign Control',
      name: 'assignControl',
      desc: '',
      args: [],
    );
  }

  /// `Please select at least one row to remove.`
  String get pleaseSelectAtLeastOneRowToRemove {
    return Intl.message(
      'Please select at least one row to remove.',
      name: 'pleaseSelectAtLeastOneRowToRemove',
      desc: '',
      args: [],
    );
  }

  /// `Please select exactly one row to duplicate.`
  String get pleaseSelectExactlyOneRowToDuplicate {
    return Intl.message(
      'Please select exactly one row to duplicate.',
      name: 'pleaseSelectExactlyOneRowToDuplicate',
      desc: '',
      args: [],
    );
  }

  /// `Total Errors`
  String get totalErrors {
    return Intl.message(
      'Total Errors',
      name: 'totalErrors',
      desc: '',
      args: [],
    );
  }

  /// `You must correct all errors before uploading`
  String get youMustCorrectAllErrorsBeforeUploading {
    return Intl.message(
      'You must correct all errors before uploading',
      name: 'youMustCorrectAllErrorsBeforeUploading',
      desc: '',
      args: [],
    );
  }

  /// `Activating Service`
  String get activatingService {
    return Intl.message(
      'Activating Service',
      name: 'activatingService',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Activate These Services?`
  String get areYouSureYouWantToActivateTheseServices {
    return Intl.message(
      'Are You Sure You Want To Activate These Services?',
      name: 'areYouSureYouWantToActivateTheseServices',
      desc: '',
      args: [],
    );
  }

  /// `Activated`
  String get activated {
    return Intl.message('Activated', name: 'activated', desc: '', args: []);
  }

  /// `You Successfully Activated These Services`
  String get youSuccessfullyActivatedTheseServices {
    return Intl.message(
      'You Successfully Activated These Services',
      name: 'youSuccessfullyActivatedTheseServices',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Deletion`
  String get confirmDeletion {
    return Intl.message(
      'Confirm Deletion',
      name: 'confirmDeletion',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this row?`
  String get areYouSureYouWantToDeleteThisRow {
    return Intl.message(
      'Are you sure you want to delete this row?',
      name: 'areYouSureYouWantToDeleteThisRow',
      desc: '',
      args: [],
    );
  }

  /// `You must solve these errors`
  String get youMustSolveTheseErrors {
    return Intl.message(
      'You must solve these errors',
      name: 'youMustSolveTheseErrors',
      desc: '',
      args: [],
    );
  }

  /// `The specified`
  String get theSpecified {
    return Intl.message(
      'The specified',
      name: 'theSpecified',
      desc: '',
      args: [],
    );
  }

  /// `! .Please verify the entry`
  String get pleaseVerifyTheEntry {
    return Intl.message(
      '! .Please verify the entry',
      name: 'pleaseVerifyTheEntry',
      desc: '',
      args: [],
    );
  }

  /// `Required`
  String get required {
    return Intl.message('Required', name: 'required', desc: '', args: []);
  }

  /// `Cannot be "null"`
  String get cannotBeNull {
    return Intl.message(
      'Cannot be "null"',
      name: 'cannotBeNull',
      desc: '',
      args: [],
    );
  }

  /// `Must be a valid email address`
  String get mustBeAValidEmailAddress {
    return Intl.message(
      'Must be a valid email address',
      name: 'mustBeAValidEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Department cannot be empty`
  String get departmentCannotBeEmpty {
    return Intl.message(
      'Department cannot be empty',
      name: 'departmentCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Policy Name cannot be empty`
  String get policyNameCannotBeEmpty {
    return Intl.message(
      'Policy Name cannot be empty',
      name: 'policyNameCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Control Name cannot be empty`
  String get controlNameCannotBeEmpty {
    return Intl.message(
      'Control Name cannot be empty',
      name: 'controlNameCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Comma cannot be at start or end`
  String get commaCannotBeAtStartOrEnd {
    return Intl.message(
      'Comma cannot be at start or end',
      name: 'commaCannotBeAtStartOrEnd',
      desc: '',
      args: [],
    );
  }

  /// `Double commas not allowed`
  String get doubleCommasNotAllowed {
    return Intl.message(
      'Double commas not allowed',
      name: 'doubleCommasNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Empty control name between commas`
  String get emptyControlNameBetweenCommas {
    return Intl.message(
      'Empty control name between commas',
      name: 'emptyControlNameBetweenCommas',
      desc: '',
      args: [],
    );
  }

  /// `Header Mismatch`
  String get headerMismatch {
    return Intl.message(
      'Header Mismatch',
      name: 'headerMismatch',
      desc: '',
      args: [],
    );
  }

  /// `The Excel file is not accepted.`
  String get theExcelFileIsNotAccepted {
    return Intl.message(
      'The Excel file is not accepted.',
      name: 'theExcelFileIsNotAccepted',
      desc: '',
      args: [],
    );
  }

  /// `Missing columns`
  String get missingColumns {
    return Intl.message(
      'Missing columns',
      name: 'missingColumns',
      desc: '',
      args: [],
    );
  }

  /// `Unknown columns`
  String get unknownColumns {
    return Intl.message(
      'Unknown columns',
      name: 'unknownColumns',
      desc: '',
      args: [],
    );
  }

  /// `Missing column`
  String get missingColumn {
    return Intl.message(
      'Missing column',
      name: 'missingColumn',
      desc: '',
      args: [],
    );
  }

  /// `Data saved locally.`
  String get dataSavedLocally {
    return Intl.message(
      'Data saved locally.',
      name: 'dataSavedLocally',
      desc: '',
      args: [],
    );
  }

  /// `Please enter justification`
  String get pleaseEnterJustification {
    return Intl.message(
      'Please enter justification',
      name: 'pleaseEnterJustification',
      desc: '',
      args: [],
    );
  }

  /// `Status updated successfully`
  String get statusUpdatedSuccessfully {
    return Intl.message(
      'Status updated successfully',
      name: 'statusUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Error occurred`
  String get errorOccurred {
    return Intl.message(
      'Error occurred',
      name: 'errorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `Tracking Time`
  String get trackingTime {
    return Intl.message(
      'Tracking Time',
      name: 'trackingTime',
      desc: '',
      args: [],
    );
  }

  /// `Check In`
  String get checkIn {
    return Intl.message('Check In', name: 'checkIn', desc: '', args: []);
  }

  /// `Check Out`
  String get checkOut {
    return Intl.message('Check Out', name: 'checkOut', desc: '', args: []);
  }

  /// `Pause`
  String get pause {
    return Intl.message('Pause', name: 'pause', desc: '', args: []);
  }

  /// `Resume`
  String get resume {
    return Intl.message('Resume', name: 'resume', desc: '', args: []);
  }

  /// `Check In Time`
  String get checkInTime {
    return Intl.message(
      'Check In Time',
      name: 'checkInTime',
      desc: '',
      args: [],
    );
  }

  /// `Check Out Time`
  String get checkOutTime {
    return Intl.message(
      'Check Out Time',
      name: 'checkOutTime',
      desc: '',
      args: [],
    );
  }

  /// `Break`
  String get breakKey {
    return Intl.message('Break', name: 'breakKey', desc: '', args: []);
  }

  /// `Attendance`
  String get attendance {
    return Intl.message('Attendance', name: 'attendance', desc: '', args: []);
  }

  /// `Last Week`
  String get lastWeek {
    return Intl.message('Last Week', name: 'lastWeek', desc: '', args: []);
  }

  /// `Last Month`
  String get lastMonth {
    return Intl.message('Last Month', name: 'lastMonth', desc: '', args: []);
  }

  /// `Last Year`
  String get lastYear {
    return Intl.message('Last Year', name: 'lastYear', desc: '', args: []);
  }

  /// `Present`
  String get present {
    return Intl.message('Present', name: 'present', desc: '', args: []);
  }

  /// `Absence`
  String get absence {
    return Intl.message('Absence', name: 'absence', desc: '', args: []);
  }

  /// `Late`
  String get late {
    return Intl.message('Late', name: 'late', desc: '', args: []);
  }

  /// `Vacation Credits`
  String get vacationCredits {
    return Intl.message(
      'Vacation Credits',
      name: 'vacationCredits',
      desc: '',
      args: [],
    );
  }

  /// `Late History`
  String get lateHistory {
    return Intl.message(
      'Late History',
      name: 'lateHistory',
      desc: '',
      args: [],
    );
  }

  /// `Counts`
  String get counts {
    return Intl.message('Counts', name: 'counts', desc: '', args: []);
  }

  /// `Wrong Location`
  String get wrongLocation {
    return Intl.message(
      'Wrong Location',
      name: 'wrongLocation',
      desc: '',
      args: [],
    );
  }

  /// `Your check-in location does not match the company's designated location. Please check in from the correct location.`
  String get wrongLocationMessage {
    return Intl.message(
      'Your check-in location does not match the company\'s designated location. Please check in from the correct location.',
      name: 'wrongLocationMessage',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed`
  String get confirmed {
    return Intl.message('Confirmed', name: 'confirmed', desc: '', args: []);
  }

  /// `Your Location Matches the Company’s Location`
  String get successLocationMessage {
    return Intl.message(
      'Your Location Matches the Company’s Location',
      name: 'successLocationMessage',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Checked Out`
  String get successCheckOutMessage {
    return Intl.message(
      'You Successfully Checked Out',
      name: 'successCheckOutMessage',
      desc: '',
      args: [],
    );
  }

  /// `Absent`
  String get absent {
    return Intl.message('Absent', name: 'absent', desc: '', args: []);
  }

  /// `Vacation`
  String get vacation {
    return Intl.message('Vacation', name: 'vacation', desc: '', args: []);
  }

  /// `Sick Leave`
  String get sickLeave {
    return Intl.message('Sick Leave', name: 'sickLeave', desc: '', args: []);
  }

  /// `Excused`
  String get excused {
    return Intl.message('Excused', name: 'excused', desc: '', args: []);
  }

  /// `Transaction`
  String get transaction {
    return Intl.message('Transaction', name: 'transaction', desc: '', args: []);
  }

  /// `Check In Date`
  String get checkInDate {
    return Intl.message(
      'Check In Date',
      name: 'checkInDate',
      desc: '',
      args: [],
    );
  }

  /// `Check Out Date`
  String get checkOutDate {
    return Intl.message(
      'Check Out Date',
      name: 'checkOutDate',
      desc: '',
      args: [],
    );
  }

  /// `Choose Time`
  String get chooseTime {
    return Intl.message('Choose Time', name: 'chooseTime', desc: '', args: []);
  }

  /// `Enter Description`
  String get enterDescription {
    return Intl.message(
      'Enter Description',
      name: 'enterDescription',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Document`
  String get transactionDocument {
    return Intl.message(
      'Transaction Document',
      name: 'transactionDocument',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded Date`
  String get uploadedDate {
    return Intl.message(
      'Uploaded Date',
      name: 'uploadedDate',
      desc: '',
      args: [],
    );
  }

  /// `Upload Attachment`
  String get uploadAttachment {
    return Intl.message(
      'Upload Attachment',
      name: 'uploadAttachment',
      desc: '',
      args: [],
    );
  }

  /// `Creating Transaction`
  String get creatingTransaction {
    return Intl.message(
      'Creating Transaction',
      name: 'creatingTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Transaction ?`
  String get areYouSureCreatingTransaction {
    return Intl.message(
      'Are You Sure You Want To Create This Transaction ?',
      name: 'areYouSureCreatingTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Submitted Transaction`
  String get submittedTransaction {
    return Intl.message(
      'Submitted Transaction',
      name: 'submittedTransaction',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Submitted This Transaction`
  String get submittedTransactionMessage {
    return Intl.message(
      'You Successfully Submitted This Transaction',
      name: 'submittedTransactionMessage',
      desc: '',
      args: [],
    );
  }

  /// `Request Time Frame`
  String get requestTimeFrame {
    return Intl.message(
      'Request Time Frame',
      name: 'requestTimeFrame',
      desc: '',
      args: [],
    );
  }

  /// `Total Time`
  String get totalTime {
    return Intl.message('Total Time', name: 'totalTime', desc: '', args: []);
  }

  /// `Business Mission`
  String get businessMission {
    return Intl.message(
      'Business Mission',
      name: 'businessMission',
      desc: '',
      args: [],
    );
  }

  /// `Personal Leave`
  String get personalLeave {
    return Intl.message(
      'Personal Leave',
      name: 'personalLeave',
      desc: '',
      args: [],
    );
  }

  /// `Annual Vacation`
  String get annualVacation {
    return Intl.message(
      'Annual Vacation',
      name: 'annualVacation',
      desc: '',
      args: [],
    );
  }

  /// `Sick Vacation`
  String get sickVacation {
    return Intl.message(
      'Sick Vacation',
      name: 'sickVacation',
      desc: '',
      args: [],
    );
  }

  /// `Emergency Vacation`
  String get emergencyVacation {
    return Intl.message(
      'Emergency Vacation',
      name: 'emergencyVacation',
      desc: '',
      args: [],
    );
  }

  /// `Marriage Vacation`
  String get marriageVacation {
    return Intl.message(
      'Marriage Vacation',
      name: 'marriageVacation',
      desc: '',
      args: [],
    );
  }

  /// `Birth Vacation`
  String get birthVacation {
    return Intl.message(
      'Birth Vacation',
      name: 'birthVacation',
      desc: '',
      args: [],
    );
  }

  /// `Death Vacation`
  String get deathVacation {
    return Intl.message(
      'Death Vacation',
      name: 'deathVacation',
      desc: '',
      args: [],
    );
  }

  /// `Adding Transaction`
  String get addingTransaction {
    return Intl.message(
      'Adding Transaction',
      name: 'addingTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Excused – Workshop`
  String get excusedWorkshop {
    return Intl.message(
      'Excused – Workshop',
      name: 'excusedWorkshop',
      desc: '',
      args: [],
    );
  }

  /// `Excused – Conference`
  String get excusedConference {
    return Intl.message(
      'Excused – Conference',
      name: 'excusedConference',
      desc: '',
      args: [],
    );
  }

  /// `Excused – Urgent Personal`
  String get excusedUrgentPersonal {
    return Intl.message(
      'Excused – Urgent Personal',
      name: 'excusedUrgentPersonal',
      desc: '',
      args: [],
    );
  }

  /// `Paternity Leave`
  String get paternityLeave {
    return Intl.message(
      'Paternity Leave',
      name: 'paternityLeave',
      desc: '',
      args: [],
    );
  }

  /// `Canceled By HR`
  String get canceledByHr {
    return Intl.message(
      'Canceled By HR',
      name: 'canceledByHr',
      desc: '',
      args: [],
    );
  }

  /// `Reasons of Cancellation`
  String get reasonsOfCancellation {
    return Intl.message(
      'Reasons of Cancellation',
      name: 'reasonsOfCancellation',
      desc: '',
      args: [],
    );
  }

  /// `Manager`
  String get manager {
    return Intl.message('Manager', name: 'manager', desc: '', args: []);
  }

  /// `Request To Cancellation`
  String get requestToCancellation {
    return Intl.message(
      'Request To Cancellation',
      name: 'requestToCancellation',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want to Cancel This Request ?`
  String get areYouSureCancelRequest {
    return Intl.message(
      'Are You Sure You Want to Cancel This Request ?',
      name: 'areYouSureCancelRequest',
      desc: '',
      args: [],
    );
  }

  /// `Request Cancelation`
  String get requestCancelation {
    return Intl.message(
      'Request Cancelation',
      name: 'requestCancelation',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Requested Cancelation For This Request`
  String get successfulRequestCancelation {
    return Intl.message(
      'You Successfully Requested Cancelation For This Request',
      name: 'successfulRequestCancelation',
      desc: '',
      args: [],
    );
  }

  /// `Creating New Request Type`
  String get creatingNewRequestType {
    return Intl.message(
      'Creating New Request Type',
      name: 'creatingNewRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Request Description`
  String get requestDescription {
    return Intl.message(
      'Request Description',
      name: 'requestDescription',
      desc: '',
      args: [],
    );
  }

  /// `All Day`
  String get allDay {
    return Intl.message('All Day', name: 'allDay', desc: '', args: []);
  }

  /// `Request Attachments`
  String get requestAttachments {
    return Intl.message(
      'Request Attachments',
      name: 'requestAttachments',
      desc: '',
      args: [],
    );
  }

  /// `Start Time`
  String get startTime {
    return Intl.message('Start Time', name: 'startTime', desc: '', args: []);
  }

  /// `End Time`
  String get endTime {
    return Intl.message('End Time', name: 'endTime', desc: '', args: []);
  }

  /// `PM`
  String get pm {
    return Intl.message('PM', name: 'pm', desc: '', args: []);
  }

  /// `AM`
  String get am {
    return Intl.message('AM', name: 'am', desc: '', args: []);
  }

  /// `Creating Request`
  String get creatingRequest {
    return Intl.message(
      'Creating Request',
      name: 'creatingRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Request ?`
  String get areYouSureCreatingRequest {
    return Intl.message(
      'Are You Sure You Want To Create This Request ?',
      name: 'areYouSureCreatingRequest',
      desc: '',
      args: [],
    );
  }

  /// `Your Request Has Been Successfully Submitted`
  String get successfulRequestSubmission {
    return Intl.message(
      'Your Request Has Been Successfully Submitted',
      name: 'successfulRequestSubmission',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Description`
  String get transactionDescription {
    return Intl.message(
      'Transaction Description',
      name: 'transactionDescription',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Created`
  String get transactionCreated {
    return Intl.message(
      'Transaction Created',
      name: 'transactionCreated',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get success {
    return Intl.message('Success', name: 'success', desc: '', args: []);
  }

  /// `Failed to pick image`
  String get failedToPickImage {
    return Intl.message(
      'Failed to pick image',
      name: 'failedToPickImage',
      desc: '',
      args: [],
    );
  }

  /// `No image selected`
  String get noImageSelected {
    return Intl.message(
      'No image selected',
      name: 'noImageSelected',
      desc: '',
      args: [],
    );
  }

  /// `This Month`
  String get thisMonth {
    return Intl.message('This Month', name: 'thisMonth', desc: '', args: []);
  }

  /// `Vacations Credit`
  String get vacationsCredit {
    return Intl.message(
      'Vacations Credit',
      name: 'vacationsCredit',
      desc: '',
      args: [],
    );
  }

  /// `Start Shift`
  String get startShift {
    return Intl.message('Start Shift', name: 'startShift', desc: '', args: []);
  }

  /// `Work Location`
  String get workLocation {
    return Intl.message(
      'Work Location',
      name: 'workLocation',
      desc: '',
      args: [],
    );
  }

  /// `Choose work location`
  String get chooseWorkLocation {
    return Intl.message(
      'Choose work location',
      name: 'chooseWorkLocation',
      desc: '',
      args: [],
    );
  }

  /// `Ware House`
  String get wareHouse {
    return Intl.message('Ware House', name: 'wareHouse', desc: '', args: []);
  }

  /// `Main Office`
  String get mainOffice {
    return Intl.message('Main Office', name: 'mainOffice', desc: '', args: []);
  }

  /// `Office - 1`
  String get office1 {
    return Intl.message('Office - 1', name: 'office1', desc: '', args: []);
  }

  /// `Remote`
  String get remote {
    return Intl.message('Remote', name: 'remote', desc: '', args: []);
  }

  /// `Client Site`
  String get clientSite {
    return Intl.message('Client Site', name: 'clientSite', desc: '', args: []);
  }

  /// `Attendance Date`
  String get attendanceDate {
    return Intl.message(
      'Attendance Date',
      name: 'attendanceDate',
      desc: '',
      args: [],
    );
  }

  /// `Oncoming Time`
  String get oncomingTime {
    return Intl.message(
      'Oncoming Time',
      name: 'oncomingTime',
      desc: '',
      args: [],
    );
  }

  /// `Leaving Time`
  String get leavingTime {
    return Intl.message(
      'Leaving Time',
      name: 'leavingTime',
      desc: '',
      args: [],
    );
  }

  /// `Break Time`
  String get breakTime {
    return Intl.message('Break Time', name: 'breakTime', desc: '', args: []);
  }

  /// `Jul`
  String get jul {
    return Intl.message('Jul', name: 'jul', desc: '', args: []);
  }

  /// `Aug`
  String get aug {
    return Intl.message('Aug', name: 'aug', desc: '', args: []);
  }

  /// `Sep`
  String get sep {
    return Intl.message('Sep', name: 'sep', desc: '', args: []);
  }

  /// `Oct`
  String get oct {
    return Intl.message('Oct', name: 'oct', desc: '', args: []);
  }

  /// `Nov`
  String get nov {
    return Intl.message('Nov', name: 'nov', desc: '', args: []);
  }

  /// `Dec`
  String get dec {
    return Intl.message('Dec', name: 'dec', desc: '', args: []);
  }

  /// `30 Minutes`
  String get minutesShort {
    return Intl.message('30 Minutes', name: 'minutesShort', desc: '', args: []);
  }

  /// `This Week`
  String get thisWeek {
    return Intl.message('This Week', name: 'thisWeek', desc: '', args: []);
  }

  /// `To`
  String get to {
    return Intl.message('To', name: 'to', desc: '', args: []);
  }

  /// `Choose Request Type`
  String get chooseRequestType {
    return Intl.message(
      'Choose Request Type',
      name: 'chooseRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Delete Attachment`
  String get deleteAttachment {
    return Intl.message(
      'Delete Attachment',
      name: 'deleteAttachment',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Request ?`
  String get areYouSureCreatingRequestType {
    return Intl.message(
      'Are You Sure You Want To Create This Request ?',
      name: 'areYouSureCreatingRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Request Types`
  String get requestTypes {
    return Intl.message(
      'Request Types',
      name: 'requestTypes',
      desc: '',
      args: [],
    );
  }

  /// `Locations`
  String get locations {
    return Intl.message('Locations', name: 'locations', desc: '', args: []);
  }

  /// `Employee`
  String get employee {
    return Intl.message('Employee', name: 'employee', desc: '', args: []);
  }

  /// `Development`
  String get development {
    return Intl.message('Development', name: 'development', desc: '', args: []);
  }

  /// `Cairo`
  String get cairo {
    return Intl.message('Cairo', name: 'cairo', desc: '', args: []);
  }

  /// `Riyadh`
  String get riyadh {
    return Intl.message('Riyadh', name: 'riyadh', desc: '', args: []);
  }

  /// `Dubai`
  String get dubai {
    return Intl.message('Dubai', name: 'dubai', desc: '', args: []);
  }

  /// `London`
  String get london {
    return Intl.message('London', name: 'london', desc: '', args: []);
  }

  /// `Editing Request Type`
  String get editingRequestType {
    return Intl.message(
      'Editing Request Type',
      name: 'editingRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Edit This Request Type ?`
  String get areYouSureEditRequestType {
    return Intl.message(
      'Are You Sure You Want To Edit This Request Type ?',
      name: 'areYouSureEditRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Delete This Request Type ?`
  String get areYouSureDeleteRequestType {
    return Intl.message(
      'Are You Sure You Want To Delete This Request Type ?',
      name: 'areYouSureDeleteRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Inactive The Request Type?`
  String get areYouSureChangeStatus {
    return Intl.message(
      'Are You Sure You Want To Inactive The Request Type?',
      name: 'areYouSureChangeStatus',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited This Request Type`
  String get successfulRequestTypeEdit {
    return Intl.message(
      'You Successfully Edited This Request Type',
      name: 'successfulRequestTypeEdit',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Deleted This Request Type`
  String get successfulRequestTypeDelete {
    return Intl.message(
      'You Successfully Deleted This Request Type',
      name: 'successfulRequestTypeDelete',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Changed the Status Of This Request Type`
  String get successfulStatusChange {
    return Intl.message(
      'You Successfully Changed the Status Of This Request Type',
      name: 'successfulStatusChange',
      desc: '',
      args: [],
    );
  }

  /// `Office - 2`
  String get office2 {
    return Intl.message('Office - 2', name: 'office2', desc: '', args: []);
  }

  /// `Reasons of Rejection: `
  String get reasonsOfRejection {
    return Intl.message(
      'Reasons of Rejection: ',
      name: 'reasonsOfRejection',
      desc: '',
      args: [],
    );
  }

  /// `Creating Request Type`
  String get creatingRequestType {
    return Intl.message(
      'Creating Request Type',
      name: 'creatingRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Request Name (Arabic)`
  String get requestNameAr {
    return Intl.message(
      'Request Name (Arabic)',
      name: 'requestNameAr',
      desc: '',
      args: [],
    );
  }

  /// `Request Name (English)`
  String get requestNameEn {
    return Intl.message(
      'Request Name (English)',
      name: 'requestNameEn',
      desc: '',
      args: [],
    );
  }

  /// `Description (Arabic)`
  String get descriptionAr {
    return Intl.message(
      'Description (Arabic)',
      name: 'descriptionAr',
      desc: '',
      args: [],
    );
  }

  /// `Description (English)`
  String get descriptionEn {
    return Intl.message(
      'Description (English)',
      name: 'descriptionEn',
      desc: '',
      args: [],
    );
  }

  /// `HR Approval`
  String get hrApproval {
    return Intl.message('HR Approval', name: 'hrApproval', desc: '', args: []);
  }

  /// `Manager Approval`
  String get managerApproval {
    return Intl.message(
      'Manager Approval',
      name: 'managerApproval',
      desc: '',
      args: [],
    );
  }

  /// `Requires Description`
  String get requiresDescription {
    return Intl.message(
      'Requires Description',
      name: 'requiresDescription',
      desc: '',
      args: [],
    );
  }

  /// `Requires Attachments`
  String get requiresAttachments {
    return Intl.message(
      'Requires Attachments',
      name: 'requiresAttachments',
      desc: '',
      args: [],
    );
  }

  /// `Limit Location Availability`
  String get limitLocationAvailability {
    return Intl.message(
      'Limit Location Availability',
      name: 'limitLocationAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Limit Department Availability`
  String get limitDepartmentAvailability {
    return Intl.message(
      'Limit Department Availability',
      name: 'limitDepartmentAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Select Attachment Type`
  String get selectAttachmentType {
    return Intl.message(
      'Select Attachment Type',
      name: 'selectAttachmentType',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get image {
    return Intl.message('Image', name: 'image', desc: '', args: []);
  }

  /// `Marketing lead`
  String get marketingLead {
    return Intl.message(
      'Marketing lead',
      name: 'marketingLead',
      desc: '',
      args: [],
    );
  }

  /// `Created Date`
  String get createdDate {
    return Intl.message(
      'Created Date',
      name: 'createdDate',
      desc: '',
      args: [],
    );
  }

  /// `My Dashboard`
  String get myDashboard {
    return Intl.message(
      'My Dashboard',
      name: 'myDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Request By`
  String get requestBy {
    return Intl.message('Request By', name: 'requestBy', desc: '', args: []);
  }

  /// `Request Position`
  String get requestPosition {
    return Intl.message(
      'Request Position',
      name: 'requestPosition',
      desc: '',
      args: [],
    );
  }

  /// `Request Description (English)`
  String get requestDescriptionEn {
    return Intl.message(
      'Request Description (English)',
      name: 'requestDescriptionEn',
      desc: '',
      args: [],
    );
  }

  /// `Request Description (Arabic)`
  String get requestDescriptionAr {
    return Intl.message(
      'Request Description (Arabic)',
      name: 'requestDescriptionAr',
      desc: '',
      args: [],
    );
  }

  /// `Ahmed Wael`
  String get ahmedWael {
    return Intl.message('Ahmed Wael', name: 'ahmedWael', desc: '', args: []);
  }

  /// `About this platform`
  String get aboutThisPlatform {
    return Intl.message(
      'About this platform',
      name: 'aboutThisPlatform',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get select {
    return Intl.message('Select', name: 'select', desc: '', args: []);
  }

  /// `Start Date`
  String get homeScreenStartDateTitle {
    return Intl.message(
      'Start Date',
      name: 'homeScreenStartDateTitle',
      desc: '',
      args: [],
    );
  }

  /// `End Date`
  String get homeScreenEndDateTitle {
    return Intl.message(
      'End Date',
      name: 'homeScreenEndDateTitle',
      desc: '',
      args: [],
    );
  }

  /// `Third Reminder`
  String get thirdReminder {
    return Intl.message(
      'Third Reminder',
      name: 'thirdReminder',
      desc: '',
      args: [],
    );
  }

  /// `Second Reminder`
  String get secReminder {
    return Intl.message(
      'Second Reminder',
      name: 'secReminder',
      desc: '',
      args: [],
    );
  }

  /// `First Reminder`
  String get firstReminder {
    return Intl.message(
      'First Reminder',
      name: 'firstReminder',
      desc: '',
      args: [],
    );
  }

  /// `Second`
  String get second {
    return Intl.message('Second', name: 'second', desc: '', args: []);
  }

  /// `Minute`
  String get minute {
    return Intl.message('Minute', name: 'minute', desc: '', args: []);
  }

  /// `Hour`
  String get hour {
    return Intl.message('Hour', name: 'hour', desc: '', args: []);
  }

  /// `Set Frequency`
  String get setFrequency {
    return Intl.message(
      'Set Frequency',
      name: 'setFrequency',
      desc: '',
      args: [],
    );
  }

  /// `Discard`
  String get discardTitle {
    return Intl.message('Discard', name: 'discardTitle', desc: '', args: []);
  }

  /// `Save`
  String get saveTitle {
    return Intl.message('Save', name: 'saveTitle', desc: '', args: []);
  }

  /// `Create`
  String get createTitle {
    return Intl.message('Create', name: 'createTitle', desc: '', args: []);
  }

  /// `All`
  String get homeScreenAllTitle {
    return Intl.message('All', name: 'homeScreenAllTitle', desc: '', args: []);
  }

  /// `To-Do`
  String get toDo {
    return Intl.message('To-Do', name: 'toDo', desc: '', args: []);
  }

  /// `Deleted`
  String get deleted {
    return Intl.message('Deleted', name: 'deleted', desc: '', args: []);
  }

  /// `Overdue`
  String get overdue {
    return Intl.message('Overdue', name: 'overdue', desc: '', args: []);
  }

  /// `To-Do List`
  String get homeScreenToDoListTitle {
    return Intl.message(
      'To-Do List',
      name: 'homeScreenToDoListTitle',
      desc: '',
      args: [],
    );
  }

  /// `Sort`
  String get homeScreenSortTitle {
    return Intl.message(
      'Sort',
      name: 'homeScreenSortTitle',
      desc: '',
      args: [],
    );
  }

  /// `Frequency`
  String get homeScreenFrequencyTitle {
    return Intl.message(
      'Frequency',
      name: 'homeScreenFrequencyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Schedule`
  String get homeScreenScheduleTitle {
    return Intl.message(
      'Schedule',
      name: 'homeScreenScheduleTitle',
      desc: '',
      args: [],
    );
  }

  /// `Create To-Do`
  String get homeScreenCreateToDoListTitle {
    return Intl.message(
      'Create To-Do',
      name: 'homeScreenCreateToDoListTitle',
      desc: '',
      args: [],
    );
  }

  /// `Item`
  String get item {
    return Intl.message('Item', name: 'item', desc: '', args: []);
  }

  /// `To Do List`
  String get toDoListTitle {
    return Intl.message(
      'To Do List',
      name: 'toDoListTitle',
      desc: '',
      args: [],
    );
  }

  /// `Creating To Do`
  String get creatingToDoTitle {
    return Intl.message(
      'Creating To Do',
      name: 'creatingToDoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Editing To Do`
  String get editingToDoTitle {
    return Intl.message(
      'Editing To Do',
      name: 'editingToDoTitle',
      desc: '',
      args: [],
    );
  }

  /// `To Do Details`
  String get detailsPageTitle {
    return Intl.message(
      'To Do Details',
      name: 'detailsPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Document Utilization`
  String get documentUtilization {
    return Intl.message(
      'Document Utilization',
      name: 'documentUtilization',
      desc: '',
      args: [],
    );
  }

  /// `All Departments`
  String get all_departments {
    return Intl.message(
      'All Departments',
      name: 'all_departments',
      desc: '',
      args: [],
    );
  }

  /// `Filter by Department`
  String get filter_by_department {
    return Intl.message(
      'Filter by Department',
      name: 'filter_by_department',
      desc: '',
      args: [],
    );
  }

  /// `Select Department`
  String get select_department {
    return Intl.message(
      'Select Department',
      name: 'select_department',
      desc: '',
      args: [],
    );
  }

  /// `Add Department`
  String get add_department {
    return Intl.message(
      'Add Department',
      name: 'add_department',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message('Create', name: 'create', desc: '', args: []);
  }

  /// `Frame Work`
  String get frame_work {
    return Intl.message('Frame Work', name: 'frame_work', desc: '', args: []);
  }

  /// `Organization Chart`
  String get organizationChart {
    return Intl.message(
      'Organization Chart',
      name: 'organizationChart',
      desc: '',
      args: [],
    );
  }

  /// `Employee Info`
  String get employeeInfo {
    return Intl.message(
      'Employee Info',
      name: 'employeeInfo',
      desc: '',
      args: [],
    );
  }

  /// `Working Hours`
  String get workingHours {
    return Intl.message(
      'Working Hours',
      name: 'workingHours',
      desc: '',
      args: [],
    );
  }

  /// `Days Off`
  String get daysOff {
    return Intl.message('Days Off', name: 'daysOff', desc: '', args: []);
  }

  /// `Salary`
  String get salary {
    return Intl.message('Salary', name: 'salary', desc: '', args: []);
  }

  /// `Job Location`
  String get jobLocation {
    return Intl.message(
      'Job Location',
      name: 'jobLocation',
      desc: '',
      args: [],
    );
  }

  /// `Institution Name`
  String get institutionName {
    return Intl.message(
      'Institution Name',
      name: 'institutionName',
      desc: '',
      args: [],
    );
  }

  /// `Degree or Certification`
  String get degreeOrCertification {
    return Intl.message(
      'Degree or Certification',
      name: 'degreeOrCertification',
      desc: '',
      args: [],
    );
  }

  /// `Graduation From`
  String get graduationFrom {
    return Intl.message(
      'Graduation From',
      name: 'graduationFrom',
      desc: '',
      args: [],
    );
  }

  /// `Request Rejected`
  String get requestRejected {
    return Intl.message(
      'Request Rejected',
      name: 'requestRejected',
      desc: '',
      args: [],
    );
  }

  /// `The request has been rejected successfully`
  String get theRequestHasBeenRejectedSuccessfully {
    return Intl.message(
      'The request has been rejected successfully',
      name: 'theRequestHasBeenRejectedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Request Approved`
  String get requestApproved {
    return Intl.message(
      'Request Approved',
      name: 'requestApproved',
      desc: '',
      args: [],
    );
  }

  /// `The request has been approved successfully`
  String get theRequestHasBeenApprovedSuccessfully {
    return Intl.message(
      'The request has been approved successfully',
      name: 'theRequestHasBeenApprovedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `User Management`
  String get userManagement {
    return Intl.message(
      'User Management',
      name: 'userManagement',
      desc: '',
      args: [],
    );
  }

  /// `Cleared`
  String get cleared {
    return Intl.message('Cleared', name: 'cleared', desc: '', args: []);
  }

  /// `Pin`
  String get pin {
    return Intl.message('Pin', name: 'pin', desc: '', args: []);
  }

  /// `CleanAll`
  String get cleanAll {
    return Intl.message('CleanAll', name: 'cleanAll', desc: '', args: []);
  }

  /// `Notifications Type`
  String get notificationsType {
    return Intl.message(
      'Notifications Type',
      name: 'notificationsType',
      desc: '',
      args: [],
    );
  }

  /// `ByType`
  String get byType {
    return Intl.message('ByType', name: 'byType', desc: '', args: []);
  }

  /// `Cleaning Notifications`
  String get cleaningNotifications {
    return Intl.message(
      'Cleaning Notifications',
      name: 'cleaningNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Clean All ?`
  String get areYouSureYouWantToCleanAll {
    return Intl.message(
      'Are You Sure You Want To Clean All ?',
      name: 'areYouSureYouWantToCleanAll',
      desc: '',
      args: [],
    );
  }

  /// `All Notifications Cleared`
  String get allNotificationsCleared {
    return Intl.message(
      'All Notifications Cleared',
      name: 'allNotificationsCleared',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Cleaned All Notification`
  String get youSuccessfullyCleanedAllNotification {
    return Intl.message(
      'You Successfully Cleaned All Notification',
      name: 'youSuccessfullyCleanedAllNotification',
      desc: '',
      args: [],
    );
  }

  /// `Access Grantor`
  String get access_grantor {
    return Intl.message(
      'Access Grantor',
      name: 'access_grantor',
      desc: '',
      args: [],
    );
  }

  /// `Supervisor`
  String get supervisor {
    return Intl.message('Supervisor', name: 'supervisor', desc: '', args: []);
  }

  /// `Access Granted`
  String get access_granted {
    return Intl.message(
      'Access Granted',
      name: 'access_granted',
      desc: '',
      args: [],
    );
  }

  /// `Access Revoked`
  String get access_revoked {
    return Intl.message(
      'Access Revoked',
      name: 'access_revoked',
      desc: '',
      args: [],
    );
  }

  /// `Last Login`
  String get last_login {
    return Intl.message('Last Login', name: 'last_login', desc: '', args: []);
  }

  /// `Total Modules`
  String get total_modules {
    return Intl.message(
      'Total Modules',
      name: 'total_modules',
      desc: '',
      args: [],
    );
  }

  /// `Remove Access`
  String get remove_access {
    return Intl.message(
      'Remove Access',
      name: 'remove_access',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove access for this employee? This will change their status to inactive and remove their role.`
  String get remove_access_confirmation {
    return Intl.message(
      'Are you sure you want to remove access for this employee? This will change their status to inactive and remove their role.',
      name: 'remove_access_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Access Removed`
  String get access_removed {
    return Intl.message(
      'Access Removed',
      name: 'access_removed',
      desc: '',
      args: [],
    );
  }

  /// `User access has been successfully removed. Status changed to inactive and role cleared.`
  String get access_removed_success {
    return Intl.message(
      'User access has been successfully removed. Status changed to inactive and role cleared.',
      name: 'access_removed_success',
      desc: '',
      args: [],
    );
  }

  /// `Select Start Date`
  String get selectStartDate {
    return Intl.message(
      'Select Start Date',
      name: 'selectStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Select End Date`
  String get selectEndDate {
    return Intl.message(
      'Select End Date',
      name: 'selectEndDate',
      desc: '',
      args: [],
    );
  }

  /// `Select Time`
  String get selectStartTime {
    return Intl.message(
      'Select Time',
      name: 'selectStartTime',
      desc: '',
      args: [],
    );
  }

  /// `Select Time`
  String get selectEndTime {
    return Intl.message(
      'Select Time',
      name: 'selectEndTime',
      desc: '',
      args: [],
    );
  }

  /// `Download Failed`
  String get downloadFailed {
    return Intl.message(
      'Download Failed',
      name: 'downloadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Video`
  String get video {
    return Intl.message('Video', name: 'video', desc: '', args: []);
  }

  /// `Recording`
  String get recording {
    return Intl.message('Recording', name: 'recording', desc: '', args: []);
  }

  /// `UnPin`
  String get unpin {
    return Intl.message('UnPin', name: 'unpin', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Pin Notification`
  String get pinNotification {
    return Intl.message(
      'Pin Notification',
      name: 'pinNotification',
      desc: '',
      args: [],
    );
  }

  /// `Are your sure to restore request type?`
  String get restoreRequestType {
    return Intl.message(
      'Are your sure to restore request type?',
      name: 'restoreRequestType',
      desc: '',
      args: [],
    );
  }

  /// `No Locations Found`
  String get noLocationsFound {
    return Intl.message(
      'No Locations Found',
      name: 'noLocationsFound',
      desc: '',
      args: [],
    );
  }

  /// `No Search Results`
  String get noSearchResults {
    return Intl.message(
      'No Search Results',
      name: 'noSearchResults',
      desc: '',
      args: [],
    );
  }

  /// `Editing Group Details`
  String get editingGroupDetails {
    return Intl.message(
      'Editing Group Details',
      name: 'editingGroupDetails',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Edit This Group ?`
  String get areYouSureEditGroup {
    return Intl.message(
      'Are You Sure You Want To Edit This Group ?',
      name: 'areYouSureEditGroup',
      desc: '',
      args: [],
    );
  }

  /// `Edited Group`
  String get editedGroup {
    return Intl.message(
      'Edited Group',
      name: 'editedGroup',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited This Group`
  String get youSuccessfullyEditedGroup {
    return Intl.message(
      'You Successfully Edited This Group',
      name: 'youSuccessfullyEditedGroup',
      desc: '',
      args: [],
    );
  }

  /// `Deleting Groups`
  String get deletingGroups {
    return Intl.message(
      'Deleting Groups',
      name: 'deletingGroups',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Delete This Group?`
  String get areYouSureDeleteGroup {
    return Intl.message(
      'Are You Sure You Want To Delete This Group?',
      name: 'areYouSureDeleteGroup',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Deleted This Group`
  String get youSuccessfullyDeletedGroup {
    return Intl.message(
      'You Successfully Deleted This Group',
      name: 'youSuccessfullyDeletedGroup',
      desc: '',
      args: [],
    );
  }

  /// `Edit Group`
  String get editGroup {
    return Intl.message('Edit Group', name: 'editGroup', desc: '', args: []);
  }

  /// `Time Tracker`
  String get timeTracker {
    return Intl.message(
      'Time Tracker',
      name: 'timeTracker',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Request Type?`
  String get areYouSureYouWantToCreateThisRequestType {
    return Intl.message(
      'Are You Sure You Want To Create This Request Type?',
      name: 'areYouSureYouWantToCreateThisRequestType',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created This Request Type`
  String get successfulRequestTypeCreate {
    return Intl.message(
      'You Successfully Created This Request Type',
      name: 'successfulRequestTypeCreate',
      desc: '',
      args: [],
    );
  }

  /// `Deleting Request Type`
  String get deletingRequestType {
    return Intl.message(
      'Deleting Request Type',
      name: 'deletingRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Location Name`
  String get locationName {
    return Intl.message(
      'Location Name',
      name: 'locationName',
      desc: '',
      args: [],
    );
  }

  /// `Google Maps`
  String get googleMaps {
    return Intl.message('Google Maps', name: 'googleMaps', desc: '', args: []);
  }

  /// `Latitude`
  String get latitude {
    return Intl.message('Latitude', name: 'latitude', desc: '', args: []);
  }

  /// `Longitude`
  String get longitude {
    return Intl.message('Longitude', name: 'longitude', desc: '', args: []);
  }

  /// `Geofencing`
  String get geofencing {
    return Intl.message('Geofencing', name: 'geofencing', desc: '', args: []);
  }

  /// `Geofencing perimeter`
  String get geofencingPerimeter {
    return Intl.message(
      'Geofencing perimeter',
      name: 'geofencingPerimeter',
      desc: '',
      args: [],
    );
  }

  /// `Geofencing Area`
  String get geofencingArea {
    return Intl.message(
      'Geofencing Area',
      name: 'geofencingArea',
      desc: '',
      args: [],
    );
  }

  /// `Allow Breaks in Attendance`
  String get allowBreaksInAttendance {
    return Intl.message(
      'Allow Breaks in Attendance',
      name: 'allowBreaksInAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Allow Pause`
  String get allowPause {
    return Intl.message('Allow Pause', name: 'allowPause', desc: '', args: []);
  }

  /// `Added By`
  String get addedBy {
    return Intl.message('Added By', name: 'addedBy', desc: '', args: []);
  }

  /// `Location Description`
  String get locationDescription {
    return Intl.message(
      'Location Description',
      name: 'locationDescription',
      desc: '',
      args: [],
    );
  }

  /// `Street Address`
  String get streetAddress {
    return Intl.message(
      'Street Address',
      name: 'streetAddress',
      desc: '',
      args: [],
    );
  }

  /// `Select All`
  String get selectAll {
    return Intl.message('Select All', name: 'selectAll', desc: '', args: []);
  }

  /// `Unknown Group`
  String get unknownGroup {
    return Intl.message(
      'Unknown Group',
      name: 'unknownGroup',
      desc: '',
      args: [],
    );
  }

  /// `No employees found`
  String get noEmployeesFound {
    return Intl.message(
      'No employees found',
      name: 'noEmployeesFound',
      desc: '',
      args: [],
    );
  }

  /// `No employees at this location`
  String get noEmployeesAtLocation {
    return Intl.message(
      'No employees at this location',
      name: 'noEmployeesAtLocation',
      desc: '',
      args: [],
    );
  }

  /// `Assign Date`
  String get assignDate {
    return Intl.message('Assign Date', name: 'assignDate', desc: '', args: []);
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `Grant Access`
  String get grantAccess {
    return Intl.message(
      'Grant Access',
      name: 'grantAccess',
      desc: '',
      args: [],
    );
  }

  /// `No approvals`
  String get noApprovals {
    return Intl.message(
      'No approvals',
      name: 'noApprovals',
      desc: '',
      args: [],
    );
  }

  /// `Requested Name`
  String get requestedName {
    return Intl.message(
      'Requested Name',
      name: 'requestedName',
      desc: '',
      args: [],
    );
  }

  /// `Location Availability`
  String get locationAvailability {
    return Intl.message(
      'Location Availability',
      name: 'locationAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Department Availability`
  String get departmentAvailability {
    return Intl.message(
      'Department Availability',
      name: 'departmentAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Groups`
  String get groups {
    return Intl.message('Groups', name: 'groups', desc: '', args: []);
  }

  /// `Unknown`
  String get unknown {
    return Intl.message('Unknown', name: 'unknown', desc: '', args: []);
  }

  /// `Review`
  String get review {
    return Intl.message('Review', name: 'review', desc: '', args: []);
  }

  /// `Group`
  String get group {
    return Intl.message('Group', name: 'group', desc: '', args: []);
  }

  /// `Ascending`
  String get ascending {
    return Intl.message('Ascending', name: 'ascending', desc: '', args: []);
  }

  /// `Descending`
  String get descending {
    return Intl.message('Descending', name: 'descending', desc: '', args: []);
  }

  /// `Reassign`
  String get reassign {
    return Intl.message('Reassign', name: 'reassign', desc: '', args: []);
  }

  /// `Mins`
  String get mins {
    return Intl.message('Mins', name: 'mins', desc: '', args: []);
  }

  /// `Select Location`
  String get selectLocation {
    return Intl.message(
      'Select Location',
      name: 'selectLocation',
      desc: '',
      args: [],
    );
  }

  /// `Allow Different Work Locations`
  String get allowDifferentWorkLocations {
    return Intl.message(
      'Allow Different Work Locations',
      name: 'allowDifferentWorkLocations',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Edit This Location ?`
  String get areYouSureEditLocation {
    return Intl.message(
      'Are You Sure You Want To Edit This Location ?',
      name: 'areYouSureEditLocation',
      desc: '',
      args: [],
    );
  }

  /// `Location Edited`
  String get locationEdited {
    return Intl.message(
      'Location Edited',
      name: 'locationEdited',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited This Location`
  String get locationEditedSuccess {
    return Intl.message(
      'You Successfully Edited This Location',
      name: 'locationEditedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Deleting Location`
  String get deletingLocation {
    return Intl.message(
      'Deleting Location',
      name: 'deletingLocation',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Delete This Location ?`
  String get areYouSureDeleteLocation {
    return Intl.message(
      'Are You Sure You Want To Delete This Location ?',
      name: 'areYouSureDeleteLocation',
      desc: '',
      args: [],
    );
  }

  /// `Location Deleted`
  String get locationDeleted {
    return Intl.message(
      'Location Deleted',
      name: 'locationDeleted',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Deleted This Location`
  String get locationDeletedSuccess {
    return Intl.message(
      'You Successfully Deleted This Location',
      name: 'locationDeletedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Location ?`
  String get areYouSureCreateLocation {
    return Intl.message(
      'Are You Sure You Want To Create This Location ?',
      name: 'areYouSureCreateLocation',
      desc: '',
      args: [],
    );
  }

  /// `Location Created`
  String get locationCreated {
    return Intl.message(
      'Location Created',
      name: 'locationCreated',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created New Location`
  String get locationCreatedSuccess {
    return Intl.message(
      'You Successfully Created New Location',
      name: 'locationCreatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Editing Location`
  String get editingLocation {
    return Intl.message(
      'Editing Location',
      name: 'editingLocation',
      desc: '',
      args: [],
    );
  }

  /// `Expand Calendar`
  String get expandCalendar {
    return Intl.message(
      'Expand Calendar',
      name: 'expandCalendar',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Checked In`
  String get successCheckedInMessage {
    return Intl.message(
      'You Successfully Checked In',
      name: 'successCheckedInMessage',
      desc: '',
      args: [],
    );
  }

  /// `Tracker`
  String get tracker {
    return Intl.message('Tracker', name: 'tracker', desc: '', args: []);
  }

  /// `Tracker - Overall`
  String get trackerOverall {
    return Intl.message(
      'Tracker - Overall',
      name: 'trackerOverall',
      desc: '',
      args: [],
    );
  }

  /// `Total Present`
  String get totalPresent {
    return Intl.message(
      'Total Present',
      name: 'totalPresent',
      desc: '',
      args: [],
    );
  }

  /// `Total Absent`
  String get totalAbsent {
    return Intl.message(
      'Total Absent',
      name: 'totalAbsent',
      desc: '',
      args: [],
    );
  }

  /// `Total Late`
  String get totalLate {
    return Intl.message('Total Late', name: 'totalLate', desc: '', args: []);
  }

  /// `Assigned Employees`
  String get assignedEmployees {
    return Intl.message(
      'Assigned Employees',
      name: 'assignedEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Create New Group`
  String get createNewGroup {
    return Intl.message(
      'Create New Group',
      name: 'createNewGroup',
      desc: '',
      args: [],
    );
  }

  /// `Group Name`
  String get groupName {
    return Intl.message('Group Name', name: 'groupName', desc: '', args: []);
  }

  /// `All Departments`
  String get allDepartmentsLong {
    return Intl.message(
      'All Departments',
      name: 'allDepartmentsLong',
      desc: '',
      args: [],
    );
  }

  /// `Location Settings`
  String get location_settings {
    return Intl.message(
      'Location Settings',
      name: 'location_settings',
      desc: '',
      args: [],
    );
  }

  /// `Allow Geofence`
  String get allowGeofence {
    return Intl.message(
      'Allow Geofence',
      name: 'allowGeofence',
      desc: '',
      args: [],
    );
  }

  /// `meter`
  String get meter {
    return Intl.message('meter', name: 'meter', desc: '', args: []);
  }

  /// `meter2`
  String get meter2 {
    return Intl.message('meter2', name: 'meter2', desc: '', args: []);
  }

  /// `Type here`
  String get typeHere {
    return Intl.message('Type here', name: 'typeHere', desc: '', args: []);
  }

  /// `Location at Google Maps`
  String get locationAtGoogleMaps {
    return Intl.message(
      'Location at Google Maps',
      name: 'locationAtGoogleMaps',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Approve This Request?`
  String get areYouSureApproveRequest {
    return Intl.message(
      'Are You Sure You Want To Approve This Request?',
      name: 'areYouSureApproveRequest',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get custom {
    return Intl.message('Custom', name: 'custom', desc: '', args: []);
  }

  /// `Creating New Location`
  String get creatingNewLocation {
    return Intl.message(
      'Creating New Location',
      name: 'creatingNewLocation',
      desc: '',
      args: [],
    );
  }

  /// `Your check-out location does not match the company's designated location. Please check in from the correct location.`
  String get wrongCheckOutLocationMessage {
    return Intl.message(
      'Your check-out location does not match the company\'s designated location. Please check in from the correct location.',
      name: 'wrongCheckOutLocationMessage',
      desc: '',
      args: [],
    );
  }

  /// `Archive Date`
  String get archiveDate {
    return Intl.message(
      'Archive Date',
      name: 'archiveDate',
      desc: '',
      args: [],
    );
  }

  /// `Create Hub`
  String get createHub {
    return Intl.message('Create Hub', name: 'createHub', desc: '', args: []);
  }

  /// `The password you entered is incorrect. Please verify your credentials and try again. If you have forgotten your password, you can reset it using the "Forgot Password" option.`
  String get incorrectPasswordMessage {
    return Intl.message(
      'The password you entered is incorrect. Please verify your credentials and try again. If you have forgotten your password, you can reset it using the "Forgot Password" option.',
      name: 'incorrectPasswordMessage',
      desc: '',
      args: [],
    );
  }

  /// `Access Blocked`
  String get accessBlocked {
    return Intl.message(
      'Access Blocked',
      name: 'accessBlocked',
      desc: '',
      args: [],
    );
  }

  /// `Reset Your Account`
  String get resetYourAccount {
    return Intl.message(
      'Reset Your Account',
      name: 'resetYourAccount',
      desc: '',
      args: [],
    );
  }

  /// `Unlock Request Submitted`
  String get unlockRequestSubmitted {
    return Intl.message(
      'Unlock Request Submitted',
      name: 'unlockRequestSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Calendar`
  String get calendar {
    return Intl.message('Calendar', name: 'calendar', desc: '', args: []);
  }

  /// `Permission Controls`
  String get permissionControls {
    return Intl.message(
      'Permission Controls',
      name: 'permissionControls',
      desc: '',
      args: [],
    );
  }

  /// `Role Information`
  String get roleInformation {
    return Intl.message(
      'Role Information',
      name: 'roleInformation',
      desc: '',
      args: [],
    );
  }

  /// `Edit Role Permissions`
  String get editRolePermissions {
    return Intl.message(
      'Edit Role Permissions',
      name: 'editRolePermissions',
      desc: '',
      args: [],
    );
  }

  /// `Edit Role Settings Permissions`
  String get editRoleSettingsPermissions {
    return Intl.message(
      'Edit Role Settings Permissions',
      name: 'editRoleSettingsPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Please select at least one department`
  String get pleaseSelectAtLeastOneDepartment {
    return Intl.message(
      'Please select at least one department',
      name: 'pleaseSelectAtLeastOneDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Please select start date`
  String get pleaseSelectStartDate {
    return Intl.message(
      'Please select start date',
      name: 'pleaseSelectStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Please select end date`
  String get pleaseSelectEndDate {
    return Intl.message(
      'Please select end date',
      name: 'pleaseSelectEndDate',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate value – must be unique`
  String get duplicateValue {
    return Intl.message(
      'Duplicate value – must be unique',
      name: 'duplicateValue',
      desc: '',
      args: [],
    );
  }

  /// `English letters only`
  String get englishOnly {
    return Intl.message(
      'English letters only',
      name: 'englishOnly',
      desc: '',
      args: [],
    );
  }

  /// `Arabic letters only`
  String get arabicOnly {
    return Intl.message(
      'Arabic letters only',
      name: 'arabicOnly',
      desc: '',
      args: [],
    );
  }

  /// `Arabic not allowed`
  String get arabicNotAllowed {
    return Intl.message(
      'Arabic not allowed',
      name: 'arabicNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `English not allowed`
  String get englishNotAllowed {
    return Intl.message(
      'English not allowed',
      name: 'englishNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Special characters not allowed`
  String get specialCharsNotAllowed {
    return Intl.message(
      'Special characters not allowed',
      name: 'specialCharsNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Only one space allowed between words`
  String get extraSpaces {
    return Intl.message(
      'Only one space allowed between words',
      name: 'extraSpaces',
      desc: '',
      args: [],
    );
  }

  /// `Only . : " , special characters are allowed`
  String get descriptionSpecialChars {
    return Intl.message(
      'Only . : " , special characters are allowed',
      name: 'descriptionSpecialChars',
      desc: '',
      args: [],
    );
  }

  /// `Must be a number`
  String get mustBeNumber {
    return Intl.message(
      'Must be a number',
      name: 'mustBeNumber',
      desc: '',
      args: [],
    );
  }

  /// `Must be > 0`
  String get mustBeGreaterThanZero {
    return Intl.message(
      'Must be > 0',
      name: 'mustBeGreaterThanZero',
      desc: '',
      args: [],
    );
  }

  /// `Must be ≤ 1000`
  String get mustBeLessThanOrEqual {
    return Intl.message(
      'Must be ≤ 1000',
      name: 'mustBeLessThanOrEqual',
      desc: '',
      args: [],
    );
  }

  /// `Numbers not allowed`
  String get numbersNotAllowed {
    return Intl.message(
      'Numbers not allowed',
      name: 'numbersNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Must be one of: Hours, Days, Seconds, Minutes`
  String get invalidTimeUnit {
    return Intl.message(
      'Must be one of: Hours, Days, Seconds, Minutes',
      name: 'invalidTimeUnit',
      desc: '',
      args: [],
    );
  }

  /// `Must be "yes" or "no"`
  String get invalidYesNo {
    return Intl.message(
      'Must be "yes" or "no"',
      name: 'invalidYesNo',
      desc: '',
      args: [],
    );
  }

  /// `Emails must be comma-separated without spaces or special characters`
  String get emailsCommaSeparated {
    return Intl.message(
      'Emails must be comma-separated without spaces or special characters',
      name: 'emailsCommaSeparated',
      desc: '',
      args: [],
    );
  }

  /// `Comma cannot be at start or end`
  String get commaAtStartOrEnd {
    return Intl.message(
      'Comma cannot be at start or end',
      name: 'commaAtStartOrEnd',
      desc: '',
      args: [],
    );
  }

  /// `Double commas not allowed`
  String get doubleCommas {
    return Intl.message(
      'Double commas not allowed',
      name: 'doubleCommas',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate emails not allowed`
  String get duplicateEmails {
    return Intl.message(
      'Duplicate emails not allowed',
      name: 'duplicateEmails',
      desc: '',
      args: [],
    );
  }

  /// `Empty email between commas`
  String get emptyEmail {
    return Intl.message(
      'Empty email between commas',
      name: 'emptyEmail',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email format`
  String get invalidEmailFormat {
    return Intl.message(
      'Invalid email format',
      name: 'invalidEmailFormat',
      desc: '',
      args: [],
    );
  }

  /// `Email does not exist`
  String get emailDoesNotExist {
    return Intl.message(
      'Email does not exist',
      name: 'emailDoesNotExist',
      desc: '',
      args: [],
    );
  }

  /// `Department required when limit is enabled`
  String get departmentRequired {
    return Intl.message(
      'Department required when limit is enabled',
      name: 'departmentRequired',
      desc: '',
      args: [],
    );
  }

  /// `Only letters, numbers, spaces, and commas are allowed`
  String get invalidDepartmentChars {
    return Intl.message(
      'Only letters, numbers, spaces, and commas are allowed',
      name: 'invalidDepartmentChars',
      desc: '',
      args: [],
    );
  }

  /// `Empty department between commas`
  String get emptyDepartment {
    return Intl.message(
      'Empty department between commas',
      name: 'emptyDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Department name must be at least 2 characters`
  String get departmentMinLength {
    return Intl.message(
      'Department name must be at least 2 characters',
      name: 'departmentMinLength',
      desc: '',
      args: [],
    );
  }

  /// `Department does not exist`
  String get departmentDoesNotExist {
    return Intl.message(
      'Department does not exist',
      name: 'departmentDoesNotExist',
      desc: '',
      args: [],
    );
  }

  /// `No file selected`
  String get noFileSelected {
    return Intl.message(
      'No file selected',
      name: 'noFileSelected',
      desc: '',
      args: [],
    );
  }

  /// `Total Services`
  String get totalServices {
    return Intl.message(
      'Total Services',
      name: 'totalServices',
      desc: '',
      args: [],
    );
  }

  /// `Disabled`
  String get disabled {
    return Intl.message('Disabled', name: 'disabled', desc: '', args: []);
  }

  /// `The Excel file is not accepted.`
  String get excelNotAccepted {
    return Intl.message(
      'The Excel file is not accepted.',
      name: 'excelNotAccepted',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this row?`
  String get areYouSureDeleteRow {
    return Intl.message(
      'Are you sure you want to delete this row?',
      name: 'areYouSureDeleteRow',
      desc: '',
      args: [],
    );
  }

  /// `You must correct all errors before uploading`
  String get mustCorrectErrors {
    return Intl.message(
      'You must correct all errors before uploading',
      name: 'mustCorrectErrors',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Activate These Services?`
  String get areYouSureActivate {
    return Intl.message(
      'Are You Sure You Want To Activate These Services?',
      name: 'areYouSureActivate',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Activated These Services`
  String get successfullyActivated {
    return Intl.message(
      'You Successfully Activated These Services',
      name: 'successfullyActivated',
      desc: '',
      args: [],
    );
  }

  /// `The specified {field} does not exist. Please verify the entry`
  String specifiedDoesNotExist(Object field) {
    return Intl.message(
      'The specified $field does not exist. Please verify the entry',
      name: 'specifiedDoesNotExist',
      desc: '',
      args: [field],
    );
  }

  /// `The specified {field} {error}! Please verify the entry`
  String specifiedError(Object field, Object error) {
    return Intl.message(
      'The specified $field $error! Please verify the entry',
      name: 'specifiedError',
      desc: '',
      args: [field, error],
    );
  }

  /// `Monthly Comparison`
  String get monthlyComparison {
    return Intl.message(
      'Monthly Comparison',
      name: 'monthlyComparison',
      desc: '',
      args: [],
    );
  }

  /// `You must turn off all notification switches before unchecking this option.`
  String get TurnOffAllNotificationSwitches {
    return Intl.message(
      'You must turn off all notification switches before unchecking this option.',
      name: 'TurnOffAllNotificationSwitches',
      desc: '',
      args: [],
    );
  }

  /// `Weeks`
  String get weeks {
    return Intl.message('Weeks', name: 'weeks', desc: '', args: []);
  }

  /// `Months`
  String get months {
    return Intl.message('Months', name: 'months', desc: '', args: []);
  }

  /// `All Services`
  String get all_services {
    return Intl.message(
      'All Services',
      name: 'all_services',
      desc: '',
      args: [],
    );
  }

  /// `Services Comparison`
  String get services_comparison {
    return Intl.message(
      'Services Comparison',
      name: 'services_comparison',
      desc: '',
      args: [],
    );
  }

  /// `Select Service`
  String get select_service {
    return Intl.message(
      'Select Service',
      name: 'select_service',
      desc: '',
      args: [],
    );
  }

  /// `No canceled or rejected services found`
  String get no_data_available {
    return Intl.message(
      'No canceled or rejected services found',
      name: 'no_data_available',
      desc: '',
      args: [],
    );
  }

  /// `Deleting To Do List`
  String get deletingToDoList {
    return Intl.message(
      'Deleting To Do List',
      name: 'deletingToDoList',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Delete This List To Do?`
  String get areYouSureYouWantToDeleteThisListToDo {
    return Intl.message(
      'Are You Sure You Want To Delete This List To Do?',
      name: 'areYouSureYouWantToDeleteThisListToDo',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Deleted This To Do`
  String get youSuccessfullyDeletedThisToDo {
    return Intl.message(
      'You Successfully Deleted This To Do',
      name: 'youSuccessfullyDeletedThisToDo',
      desc: '',
      args: [],
    );
  }

  /// `Restoring To Do`
  String get restoringToDo {
    return Intl.message(
      'Restoring To Do',
      name: 'restoringToDo',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Restore This List To Do?`
  String get areYouSureYouWantToRestoreThisListToDo {
    return Intl.message(
      'Are You Sure You Want To Restore This List To Do?',
      name: 'areYouSureYouWantToRestoreThisListToDo',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Restored This To Do`
  String get youSuccessfullyRestoredThisToDo {
    return Intl.message(
      'You Successfully Restored This To Do',
      name: 'youSuccessfullyRestoredThisToDo',
      desc: '',
      args: [],
    );
  }

  /// `Creating To Do`
  String get creatingToDodialoge {
    return Intl.message(
      'Creating To Do',
      name: 'creatingToDodialoge',
      desc: '',
      args: [],
    );
  }

  /// `Editing To Do`
  String get editingToDodialog {
    return Intl.message(
      'Editing To Do',
      name: 'editingToDodialog',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited The To Do`
  String get youSuccessfullyEditedTheToDo {
    return Intl.message(
      'You Successfully Edited The To Do',
      name: 'youSuccessfullyEditedTheToDo',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created New To Do`
  String get youSuccessfullyCreatedNewToDo {
    return Intl.message(
      'You Successfully Created New To Do',
      name: 'youSuccessfullyCreatedNewToDo',
      desc: '',
      args: [],
    );
  }

  /// `Please select both start date and start time`
  String get pleaseselectbothstartdateandstarttime {
    return Intl.message(
      'Please select both start date and start time',
      name: 'pleaseselectbothstartdateandstarttime',
      desc: '',
      args: [],
    );
  }

  /// `Please select a priority`
  String get pleaseselectapriority {
    return Intl.message(
      'Please select a priority',
      name: 'pleaseselectapriority',
      desc: '',
      args: [],
    );
  }

  /// `Please select a frequency unit`
  String get pleaseselectafrequencyunit {
    return Intl.message(
      'Please select a frequency unit',
      name: 'pleaseselectafrequencyunit',
      desc: '',
      args: [],
    );
  }

  /// `Please select at least one day`
  String get pleaseselectatleastoneday {
    return Intl.message(
      'Please select at least one day',
      name: 'pleaseselectatleastoneday',
      desc: '',
      args: [],
    );
  }

  /// `End date must be after start date`
  String get enddatemustbeafterstartdate {
    return Intl.message(
      'End date must be after start date',
      name: 'enddatemustbeafterstartdate',
      desc: '',
      args: [],
    );
  }

  /// `Sched`
  String get schedAbbreviation {
    return Intl.message('Sched', name: 'schedAbbreviation', desc: '', args: []);
  }

  /// `Freq`
  String get freqAbbreviation {
    return Intl.message('Freq', name: 'freqAbbreviation', desc: '', args: []);
  }

  /// `Notice`
  String get notice {
    return Intl.message('Notice', name: 'notice', desc: '', args: []);
  }

  /// `Are you sure you would like to proceed with editing this to-do?`
  String get areYouSureYouWouldLikeToProceedWithEditingToDo {
    return Intl.message(
      'Are you sure you would like to proceed with editing this to-do?',
      name: 'areYouSureYouWouldLikeToProceedWithEditingToDo',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you would like to proceed with creating this to-do?`
  String get areYouSureYouWouldLikeToProceedWithCreatingToDo {
    return Intl.message(
      'Are you sure you would like to proceed with creating this to-do?',
      name: 'areYouSureYouWouldLikeToProceedWithCreatingToDo',
      desc: '',
      args: [],
    );
  }

  /// `Please select a duration unit for reminder`
  String get pleaseselectadurationunitforreminder {
    return Intl.message(
      'Please select a duration unit for reminder',
      name: 'pleaseselectadurationunitforreminder',
      desc: '',
      args: [],
    );
  }

  /// `Select Priority`
  String get selectpriority {
    return Intl.message(
      'Select Priority',
      name: 'selectpriority',
      desc: '',
      args: [],
    );
  }

  /// `Reason for Rejection`
  String get reasonForRejection {
    return Intl.message(
      'Reason for Rejection',
      name: 'reasonForRejection',
      desc: '',
      args: [],
    );
  }

  /// `Please provide a detailed reason for rejecting this document`
  String get pleaseProvideReasonForRejection {
    return Intl.message(
      'Please provide a detailed reason for rejecting this document',
      name: 'pleaseProvideReasonForRejection',
      desc: '',
      args: [],
    );
  }

  /// `Enter rejection reason here...`
  String get enterRejectionReason {
    return Intl.message(
      'Enter rejection reason here...',
      name: 'enterRejectionReason',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a rejection reason`
  String get pleaseEnterRejectionReason {
    return Intl.message(
      'Please enter a rejection reason',
      name: 'pleaseEnterRejectionReason',
      desc: '',
      args: [],
    );
  }

  /// `Reason must be at least 10 characters`
  String get reasonMustBeAtLeast10Characters {
    return Intl.message(
      'Reason must be at least 10 characters',
      name: 'reasonMustBeAtLeast10Characters',
      desc: '',
      args: [],
    );
  }

  /// `Submitting...`
  String get submitting {
    return Intl.message(
      'Submitting...',
      name: 'submitting',
      desc: '',
      args: [],
    );
  }

  /// `Request Rejected Successfully`
  String get requestRejectedSuccessfully {
    return Intl.message(
      'Request Rejected Successfully',
      name: 'requestRejectedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `The document has been rejected and the creator will be notified`
  String get theDocumentHasBeenRejected {
    return Intl.message(
      'The document has been rejected and the creator will be notified',
      name: 'theDocumentHasBeenRejected',
      desc: '',
      args: [],
    );
  }

  /// `Please provide a justification for approving this document`
  String get pleaseProvideJustificationForApproval {
    return Intl.message(
      'Please provide a justification for approving this document',
      name: 'pleaseProvideJustificationForApproval',
      desc: '',
      args: [],
    );
  }

  /// `Enter approval justification here...`
  String get enterApprovalJustification {
    return Intl.message(
      'Enter approval justification here...',
      name: 'enterApprovalJustification',
      desc: '',
      args: [],
    );
  }

  /// `Please enter approval justification`
  String get pleaseEnterApprovalJustification {
    return Intl.message(
      'Please enter approval justification',
      name: 'pleaseEnterApprovalJustification',
      desc: '',
      args: [],
    );
  }

  /// `Justification must be at least 10 characters`
  String get justificationMustBeAtLeast10Characters {
    return Intl.message(
      'Justification must be at least 10 characters',
      name: 'justificationMustBeAtLeast10Characters',
      desc: '',
      args: [],
    );
  }

  /// `Request Approved Successfully`
  String get requestApprovedSuccessfully {
    return Intl.message(
      'Request Approved Successfully',
      name: 'requestApprovedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `The document has been approved and will be published`
  String get theDocumentHasBeenApproved {
    return Intl.message(
      'The document has been approved and will be published',
      name: 'theDocumentHasBeenApproved',
      desc: '',
      args: [],
    );
  }

  /// `Error rejecting document`
  String get errorRejectingDocument {
    return Intl.message(
      'Error rejecting document',
      name: 'errorRejectingDocument',
      desc: '',
      args: [],
    );
  }

  /// `Error approving document`
  String get errorApprovingDocument {
    return Intl.message(
      'Error approving document',
      name: 'errorApprovingDocument',
      desc: '',
      args: [],
    );
  }

  /// `End time must be after start time`
  String get endtimemustbeafterstarttime {
    return Intl.message(
      'End time must be after start time',
      name: 'endtimemustbeafterstarttime',
      desc: '',
      args: [],
    );
  }

  /// `Please select start date before selecting end date or end time`
  String get pleaseselectstartdatebeforeenddate {
    return Intl.message(
      'Please select start date before selecting end date or end time',
      name: 'pleaseselectstartdatebeforeenddate',
      desc: '',
      args: [],
    );
  }

  /// `Knowledge Monthly Comparison`
  String get knowledge_monthly_comparison {
    return Intl.message(
      'Knowledge Monthly Comparison',
      name: 'knowledge_monthly_comparison',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this knowledge?`
  String get areYouSureDeleteKnowledge {
    return Intl.message(
      'Are you sure you want to delete this knowledge?',
      name: 'areYouSureDeleteKnowledge',
      desc: '',
      args: [],
    );
  }

  /// `Remove Knowledge`
  String get removeKnowledge {
    return Intl.message(
      'Remove Knowledge',
      name: 'removeKnowledge',
      desc: '',
      args: [],
    );
  }

  /// `You removed this knowledge successfully`
  String get knowledgeRemovedSuccessfully {
    return Intl.message(
      'You removed this knowledge successfully',
      name: 'knowledgeRemovedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Notification Control`
  String get notificationControl {
    return Intl.message(
      'Notification Control',
      name: 'notificationControl',
      desc: '',
      args: [],
    );
  }

  /// `Knowledge Hub`
  String get knowledgeHub {
    return Intl.message(
      'Knowledge Hub',
      name: 'knowledgeHub',
      desc: '',
      args: [],
    );
  }

  /// `Request Status`
  String get requestStatus {
    return Intl.message(
      'Request Status',
      name: 'requestStatus',
      desc: '',
      args: [],
    );
  }

  /// `Subject`
  String get subject {
    return Intl.message('Subject', name: 'subject', desc: '', args: []);
  }

  /// `Body`
  String get body {
    return Intl.message('Body', name: 'body', desc: '', args: []);
  }

  /// `Push Notification`
  String get pushNotification {
    return Intl.message(
      'Push Notification',
      name: 'pushNotification',
      desc: '',
      args: [],
    );
  }

  /// `Request Cancelled`
  String get requestCancelled {
    return Intl.message(
      'Request Cancelled',
      name: 'requestCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Request In Progress`
  String get requestInProgress {
    return Intl.message(
      'Request In Progress',
      name: 'requestInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Request Done`
  String get requestDone {
    return Intl.message(
      'Request Done',
      name: 'requestDone',
      desc: '',
      args: [],
    );
  }

  /// `Request SLA Exceed`
  String get requestSLAExceed {
    return Intl.message(
      'Request SLA Exceed',
      name: 'requestSLAExceed',
      desc: '',
      args: [],
    );
  }

  /// `Download Complete`
  String get downloadComplete {
    return Intl.message(
      'Download Complete',
      name: 'downloadComplete',
      desc: '',
      args: [],
    );
  }

  /// `save To`
  String get saveTo {
    return Intl.message('save To', name: 'saveTo', desc: '', args: []);
  }

  /// `No Comment uploaded yet`
  String get commentNotFound {
    return Intl.message(
      'No Comment uploaded yet',
      name: 'commentNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Download PDF of About This Platform`
  String get downloadPDFofAboutThisApp {
    return Intl.message(
      'Download PDF of About This Platform',
      name: 'downloadPDFofAboutThisApp',
      desc: '',
      args: [],
    );
  }

  /// `Download PDF of Terms And Condition`
  String get downloadPDFofTermsAndCondition {
    return Intl.message(
      'Download PDF of Terms And Condition',
      name: 'downloadPDFofTermsAndCondition',
      desc: '',
      args: [],
    );
  }

  /// `Download PDF of Privacy And Policy`
  String get downloadPDFofPrivacyAndPolicy {
    return Intl.message(
      'Download PDF of Privacy And Policy',
      name: 'downloadPDFofPrivacyAndPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Desktop View`
  String get desktopView {
    return Intl.message(
      'Desktop View',
      name: 'desktopView',
      desc: '',
      args: [],
    );
  }

  /// `Tablet View`
  String get tabletView {
    return Intl.message('Tablet View', name: 'tabletView', desc: '', args: []);
  }

  /// `Mobile View`
  String get mobileView {
    return Intl.message('Mobile View', name: 'mobileView', desc: '', args: []);
  }

  /// `Widget`
  String get widget {
    return Intl.message('Widget', name: 'widget', desc: '', args: []);
  }

  /// `Chart & Graph`
  String get chartGraph {
    return Intl.message(
      'Chart & Graph',
      name: 'chartGraph',
      desc: '',
      args: [],
    );
  }

  /// `Adding Widget`
  String get addingWidget {
    return Intl.message(
      'Adding Widget',
      name: 'addingWidget',
      desc: '',
      args: [],
    );
  }

  /// `View Draft Form`
  String get viewDraftForm {
    return Intl.message(
      'View Draft Form',
      name: 'viewDraftForm',
      desc: '',
      args: [],
    );
  }

  /// `View Requested Form`
  String get viewRequestedForm {
    return Intl.message(
      'View Requested Form',
      name: 'viewRequestedForm',
      desc: '',
      args: [],
    );
  }

  /// `Form Name`
  String get formName {
    return Intl.message('Form Name', name: 'formName', desc: '', args: []);
  }

  /// `Form Submissions`
  String get formSubmissions {
    return Intl.message(
      'Form Submissions',
      name: 'formSubmissions',
      desc: '',
      args: [],
    );
  }

  /// `Schedule Message`
  String get scheduleMessage {
    return Intl.message(
      'Schedule Message',
      name: 'scheduleMessage',
      desc: '',
      args: [],
    );
  }

  /// `For Group`
  String get forGroup {
    return Intl.message('For Group', name: 'forGroup', desc: '', args: []);
  }

  /// `For Direct Message`
  String get forDirectMessage {
    return Intl.message(
      'For Direct Message',
      name: 'forDirectMessage',
      desc: '',
      args: [],
    );
  }

  /// `Create New`
  String get createNew {
    return Intl.message('Create New', name: 'createNew', desc: '', args: []);
  }

  /// `Icons`
  String get icons {
    return Intl.message('Icons', name: 'icons', desc: '', args: []);
  }

  /// `Roles`
  String get roles {
    return Intl.message('Roles', name: 'roles', desc: '', args: []);
  }

  /// `User Access`
  String get userAccess {
    return Intl.message('User Access', name: 'userAccess', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Light/Dark Mode`
  String get lightDarkMode {
    return Intl.message(
      'Light/Dark Mode',
      name: 'lightDarkMode',
      desc: '',
      args: [],
    );
  }

  /// `Service Dashboard`
  String get serviceDashboard {
    return Intl.message(
      'Service Dashboard',
      name: 'serviceDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Inventory Dashboard`
  String get inventoryDashboard {
    return Intl.message(
      'Inventory Dashboard',
      name: 'inventoryDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Qiyas Dashboard`
  String get qiyasDashboard {
    return Intl.message(
      'Qiyas Dashboard',
      name: 'qiyasDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Service Approvals`
  String get serviceApprovals {
    return Intl.message(
      'Service Approvals',
      name: 'serviceApprovals',
      desc: '',
      args: [],
    );
  }

  /// `Create To Do`
  String get createToDo {
    return Intl.message('Create To Do', name: 'createToDo', desc: '', args: []);
  }

  /// `Create Task`
  String get createTask {
    return Intl.message('Create Task', name: 'createTask', desc: '', args: []);
  }

  /// `Check In-Out`
  String get checkInOut {
    return Intl.message('Check In-Out', name: 'checkInOut', desc: '', args: []);
  }

  /// `Your data has been successfully updated`
  String get successMessage {
    return Intl.message(
      'Your data has been successfully updated',
      name: 'successMessage',
      desc: '',
      args: [],
    );
  }

  /// `Show`
  String get show {
    return Intl.message('Show', name: 'show', desc: '', args: []);
  }

  /// `Messages Permissions`
  String get messagesPermissions {
    return Intl.message(
      'Messages Permissions',
      name: 'messagesPermissions',
      desc: '',
      args: [],
    );
  }

  /// `More Permissions`
  String get morePermissions {
    return Intl.message(
      'More Permissions',
      name: 'morePermissions',
      desc: '',
      args: [],
    );
  }

  /// `Create Group`
  String get createGroup {
    return Intl.message(
      'Create Group',
      name: 'createGroup',
      desc: '',
      args: [],
    );
  }

  /// `Seen and Unseen`
  String get seenAndUnseen {
    return Intl.message(
      'Seen and Unseen',
      name: 'seenAndUnseen',
      desc: '',
      args: [],
    );
  }

  /// `Edit Message`
  String get editMessage {
    return Intl.message(
      'Edit Message',
      name: 'editMessage',
      desc: '',
      args: [],
    );
  }

  /// `Delete Message`
  String get deleteMessage {
    return Intl.message(
      'Delete Message',
      name: 'deleteMessage',
      desc: '',
      args: [],
    );
  }

  /// `Reactions`
  String get reactions {
    return Intl.message('Reactions', name: 'reactions', desc: '', args: []);
  }

  /// `Forward Message`
  String get forwardMessage {
    return Intl.message(
      'Forward Message',
      name: 'forwardMessage',
      desc: '',
      args: [],
    );
  }

  /// `Photo`
  String get photo {
    return Intl.message('Photo', name: 'photo', desc: '', args: []);
  }

  /// `Documents`
  String get documents {
    return Intl.message('Documents', name: 'documents', desc: '', args: []);
  }

  /// `Poll`
  String get poll {
    return Intl.message('Poll', name: 'poll', desc: '', args: []);
  }

  /// `Mute Notifications`
  String get muteNotifications {
    return Intl.message(
      'Mute Notifications',
      name: 'muteNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Disappearing Messages`
  String get disappearingMessages {
    return Intl.message(
      'Disappearing Messages',
      name: 'disappearingMessages',
      desc: '',
      args: [],
    );
  }

  /// `Schedule Messages`
  String get scheduleMessages {
    return Intl.message(
      'Schedule Messages',
      name: 'scheduleMessages',
      desc: '',
      args: [],
    );
  }

  /// `Settings Permission`
  String get settingsPermission {
    return Intl.message(
      'Settings Permission',
      name: 'settingsPermission',
      desc: '',
      args: [],
    );
  }

  /// `Editing Role`
  String get editingRole {
    return Intl.message(
      'Editing Role',
      name: 'editingRole',
      desc: '',
      args: [],
    );
  }

  /// `Completing Draft Role`
  String get completingDraftRole {
    return Intl.message(
      'Completing Draft Role',
      name: 'completingDraftRole',
      desc: '',
      args: [],
    );
  }

  /// `Creating Role`
  String get creatingRole {
    return Intl.message(
      'Creating Role',
      name: 'creatingRole',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to edit this role?`
  String get areYouSureEditRole {
    return Intl.message(
      'Are you sure you want to edit this role?',
      name: 'areYouSureEditRole',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to complete this draft role?`
  String get areYouSureCompleteDraftRole {
    return Intl.message(
      'Are you sure you want to complete this draft role?',
      name: 'areYouSureCompleteDraftRole',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to create this role?`
  String get areYouSureCreateRole {
    return Intl.message(
      'Are you sure you want to create this role?',
      name: 'areYouSureCreateRole',
      desc: '',
      args: [],
    );
  }

  /// `No Wrong Data Found`
  String get noWrongDataFound {
    return Intl.message(
      'No Wrong Data Found',
      name: 'noWrongDataFound',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get employeeStatusAll {
    return Intl.message('All', name: 'employeeStatusAll', desc: '', args: []);
  }

  /// `Active`
  String get employeeStatusActive {
    return Intl.message(
      'Active',
      name: 'employeeStatusActive',
      desc: '',
      args: [],
    );
  }

  /// `Inactive`
  String get employeeStatusInactive {
    return Intl.message(
      'Inactive',
      name: 'employeeStatusInactive',
      desc: '',
      args: [],
    );
  }

  /// `Request to Reset Password`
  String get employeeStatusResetPassword {
    return Intl.message(
      'Request to Reset Password',
      name: 'employeeStatusResetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Locked with Send Request`
  String get employeeStatusLockedWithRequest {
    return Intl.message(
      'Locked with Send Request',
      name: 'employeeStatusLockedWithRequest',
      desc: '',
      args: [],
    );
  }

  /// `Locked`
  String get employeeStatusLocked {
    return Intl.message(
      'Locked',
      name: 'employeeStatusLocked',
      desc: '',
      args: [],
    );
  }

  /// `Deactivated`
  String get employeeStatusDeactivated {
    return Intl.message(
      'Deactivated',
      name: 'employeeStatusDeactivated',
      desc: '',
      args: [],
    );
  }

  /// `Scheduled Deactivation`
  String get employeeStatusWillBeDeactivated {
    return Intl.message(
      'Scheduled Deactivation',
      name: 'employeeStatusWillBeDeactivated',
      desc: '',
      args: [],
    );
  }

  /// `Scheduled Activation`
  String get employeeStatusWillBeActivated {
    return Intl.message(
      'Scheduled Activation',
      name: 'employeeStatusWillBeActivated',
      desc: '',
      args: [],
    );
  }

  /// `Unsuccessful`
  String get unsuccessful {
    return Intl.message(
      'Unsuccessful',
      name: 'unsuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Please Select Image In SVG Format`
  String get pleaseSelectImageInSvgFormat {
    return Intl.message(
      'Please Select Image In SVG Format',
      name: 'pleaseSelectImageInSvgFormat',
      desc: '',
      args: [],
    );
  }

  /// `Services Updated`
  String get servicesUpdated {
    return Intl.message(
      'Services Updated',
      name: 'servicesUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Birth Date`
  String get enterbirthday {
    return Intl.message(
      'Enter Your Birth Date',
      name: 'enterbirthday',
      desc: '',
      args: [],
    );
  }

  /// `Enter Skill`
  String get enterSkill {
    return Intl.message('Enter Skill', name: 'enterSkill', desc: '', args: []);
  }

  /// `Enter Hex Code`
  String get enterhexacolor {
    return Intl.message(
      'Enter Hex Code',
      name: 'enterhexacolor',
      desc: '',
      args: [],
    );
  }

  /// `Total Modules`
  String get totalModules {
    return Intl.message(
      'Total Modules',
      name: 'totalModules',
      desc: '',
      args: [],
    );
  }

  /// `UnStar`
  String get unStar {
    return Intl.message('UnStar', name: 'unStar', desc: '', args: []);
  }

  /// `Star`
  String get star {
    return Intl.message('Star', name: 'star', desc: '', args: []);
  }

  /// `Started Messages`
  String get startedMessages {
    return Intl.message(
      'Started Messages',
      name: 'startedMessages',
      desc: '',
      args: [],
    );
  }

  /// `Mute Notification`
  String get muteNotification {
    return Intl.message(
      'Mute Notification',
      name: 'muteNotification',
      desc: '',
      args: [],
    );
  }

  /// `Groups Common`
  String get groupsCommon {
    return Intl.message(
      'Groups Common',
      name: 'groupsCommon',
      desc: '',
      args: [],
    );
  }

  /// `Select Role`
  String get selectRole {
    return Intl.message('Select Role', name: 'selectRole', desc: '', args: []);
  }

  /// `Select Date`
  String get selectDate {
    return Intl.message('Select Date', name: 'selectDate', desc: '', args: []);
  }

  /// `Save Draft`
  String get saveDraft {
    return Intl.message('Save Draft', name: 'saveDraft', desc: '', args: []);
  }

  /// `Do you want to save this role as draft?`
  String get doYouWantToSaveThisRoleAsDraft {
    return Intl.message(
      'Do you want to save this role as draft?',
      name: 'doYouWantToSaveThisRoleAsDraft',
      desc: '',
      args: [],
    );
  }

  /// `Role saved as draft successfully`
  String get roleSavedAsDraftSuccessfully {
    return Intl.message(
      'Role saved as draft successfully',
      name: 'roleSavedAsDraftSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Failed to save draft. Please try again.`
  String get failedToSaveDraftPleaseTryAgain {
    return Intl.message(
      'Failed to save draft. Please try again.',
      name: 'failedToSaveDraftPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Export Roles`
  String get exportRoles {
    return Intl.message(
      'Export Roles',
      name: 'exportRoles',
      desc: '',
      args: [],
    );
  }

  /// `Enter file name`
  String get enterFileName {
    return Intl.message(
      'Enter file name',
      name: 'enterFileName',
      desc: '',
      args: [],
    );
  }

  /// `Export CSV`
  String get exportCsv {
    return Intl.message('Export CSV', name: 'exportCsv', desc: '', args: []);
  }

  /// `Exporting...`
  String get exporting {
    return Intl.message('Exporting...', name: 'exporting', desc: '', args: []);
  }

  /// `Please enter a file name`
  String get pleaseEnterAFileName {
    return Intl.message(
      'Please enter a file name',
      name: 'pleaseEnterAFileName',
      desc: '',
      args: [],
    );
  }

  /// `No Data`
  String get noData {
    return Intl.message('No Data', name: 'noData', desc: '', args: []);
  }

  /// `No roles to export`
  String get noRolesToExport {
    return Intl.message(
      'No roles to export',
      name: 'noRolesToExport',
      desc: '',
      args: [],
    );
  }

  /// `Export Failed`
  String get exportFailed {
    return Intl.message(
      'Export Failed',
      name: 'exportFailed',
      desc: '',
      args: [],
    );
  }

  /// `Export User Management`
  String get exportUserManagement {
    return Intl.message(
      'Export User Management',
      name: 'exportUserManagement',
      desc: '',
      args: [],
    );
  }

  /// `No user permissions to export`
  String get noUserPermissionsToExport {
    return Intl.message(
      'No user permissions to export',
      name: 'noUserPermissionsToExport',
      desc: '',
      args: [],
    );
  }

  /// `Editing Access Details`
  String get editingAccessDetails {
    return Intl.message(
      'Editing Access Details',
      name: 'editingAccessDetails',
      desc: '',
      args: [],
    );
  }

  /// `Expiration Time`
  String get expirationTime {
    return Intl.message(
      'Expiration Time',
      name: 'expirationTime',
      desc: '',
      args: [],
    );
  }

  /// `Default Password`
  String get defaultPassword {
    return Intl.message(
      'Default Password',
      name: 'defaultPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter Default Password`
  String get enterDefaultPassword {
    return Intl.message(
      'Enter Default Password',
      name: 'enterDefaultPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please enter expiration time`
  String get pleaseEnterExpirationTime {
    return Intl.message(
      'Please enter expiration time',
      name: 'pleaseEnterExpirationTime',
      desc: '',
      args: [],
    );
  }

  /// `Please enter default password`
  String get pleaseEnterDefaultPassword {
    return Intl.message(
      'Please enter default password',
      name: 'pleaseEnterDefaultPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password and Expiration Time Updated Successfully`
  String get passwordAndExpirationTimeUpdatedSuccessfully {
    return Intl.message(
      'Password and Expiration Time Updated Successfully',
      name: 'passwordAndExpirationTimeUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Platform Controls and Management`
  String get platformControlsAndManagement {
    return Intl.message(
      'Platform Controls and Management',
      name: 'platformControlsAndManagement',
      desc: '',
      args: [],
    );
  }

  /// `Role Details`
  String get roleDetails {
    return Intl.message(
      'Role Details',
      name: 'roleDetails',
      desc: '',
      args: [],
    );
  }

  /// `Delete Role`
  String get deleteRole {
    return Intl.message('Delete Role', name: 'deleteRole', desc: '', args: []);
  }

  /// `Are you sure you want to delete this role?`
  String get areYouSureYouWantToDeleteThisRole {
    return Intl.message(
      'Are you sure you want to delete this role?',
      name: 'areYouSureYouWantToDeleteThisRole',
      desc: '',
      args: [],
    );
  }

  /// `Adding New Role`
  String get addingNewRole {
    return Intl.message(
      'Adding New Role',
      name: 'addingNewRole',
      desc: '',
      args: [],
    );
  }

  /// `Role Permissions`
  String get rolePermissions {
    return Intl.message(
      'Role Permissions',
      name: 'rolePermissions',
      desc: '',
      args: [],
    );
  }

  /// `Selected modules`
  String get selectedModules {
    return Intl.message(
      'Selected modules',
      name: 'selectedModules',
      desc: '',
      args: [],
    );
  }

  /// `No permission configuration needed for these modules.`
  String get noPermissionNeeded {
    return Intl.message(
      'No permission configuration needed for these modules.',
      name: 'noPermissionNeeded',
      desc: '',
      args: [],
    );
  }

  /// `Click Next to continue to Settings.`
  String get clickNextToContinue {
    return Intl.message(
      'Click Next to continue to Settings.',
      name: 'clickNextToContinue',
      desc: '',
      args: [],
    );
  }

  /// `Loading employee details`
  String get loadingEmployeeDetails {
    return Intl.message(
      'Loading employee details',
      name: 'loadingEmployeeDetails',
      desc: '',
      args: [],
    );
  }

  /// `Please select a role type`
  String get pleaseSelectARoleType {
    return Intl.message(
      'Please select a role type',
      name: 'pleaseSelectARoleType',
      desc: '',
      args: [],
    );
  }

  /// `Please select access granted date`
  String get pleaseSelectAccessGrantedDate {
    return Intl.message(
      'Please select access granted date',
      name: 'pleaseSelectAccessGrantedDate',
      desc: '',
      args: [],
    );
  }

  /// `Please select access revoked date`
  String get pleaseSelectAccessRevokedDate {
    return Intl.message(
      'Please select access revoked date',
      name: 'pleaseSelectAccessRevokedDate',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to activate this role?`
  String get areYouSureYouWantToActivateThisRole {
    return Intl.message(
      'Are you sure you want to activate this role?',
      name: 'areYouSureYouWantToActivateThisRole',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to deactivate this role?`
  String get areYouSureYouWantToDeactivateThisRole {
    return Intl.message(
      'Are you sure you want to deactivate this role?',
      name: 'areYouSureYouWantToDeactivateThisRole',
      desc: '',
      args: [],
    );
  }

  /// `Role Name`
  String get role_name {
    return Intl.message('Role Name', name: 'role_name', desc: '', args: []);
  }

  /// `Role Name (AR)`
  String get role_name_ar {
    return Intl.message(
      'Role Name (AR)',
      name: 'role_name_ar',
      desc: '',
      args: [],
    );
  }

  /// `Role Description`
  String get role_description {
    return Intl.message(
      'Role Description',
      name: 'role_description',
      desc: '',
      args: [],
    );
  }

  /// `Role Description (AR)`
  String get role_description_ar {
    return Intl.message(
      'Role Description (AR)',
      name: 'role_description_ar',
      desc: '',
      args: [],
    );
  }

  /// `Created By`
  String get created_by {
    return Intl.message('Created By', name: 'created_by', desc: '', args: []);
  }

  /// `Created At`
  String get created_at {
    return Intl.message('Created At', name: 'created_at', desc: '', args: []);
  }

  /// `Active Permissions`
  String get active_permissions {
    return Intl.message(
      'Active Permissions',
      name: 'active_permissions',
      desc: '',
      args: [],
    );
  }

  /// `No specific permissions`
  String get no_specific_permissions {
    return Intl.message(
      'No specific permissions',
      name: 'no_specific_permissions',
      desc: '',
      args: [],
    );
  }

  /// `Error loading`
  String get error_loading {
    return Intl.message(
      'Error loading',
      name: 'error_loading',
      desc: '',
      args: [],
    );
  }

  /// `Tasks`
  String get tasks {
    return Intl.message('Tasks', name: 'tasks', desc: '', args: []);
  }

  /// `To Do List`
  String get todo {
    return Intl.message('To Do List', name: 'todo', desc: '', args: []);
  }

  /// `Events`
  String get events {
    return Intl.message('Events', name: 'events', desc: '', args: []);
  }

  /// `Notes`
  String get notes {
    return Intl.message('Notes', name: 'notes', desc: '', args: []);
  }

  /// `Tracking`
  String get tracking {
    return Intl.message('Tracking', name: 'tracking', desc: '', args: []);
  }

  /// `Messages`
  String get messages {
    return Intl.message('Messages', name: 'messages', desc: '', args: []);
  }

  /// `Database Builder`
  String get database_builder {
    return Intl.message(
      'Database Builder',
      name: 'database_builder',
      desc: '',
      args: [],
    );
  }

  /// `Form Builder`
  String get services_app {
    return Intl.message(
      'Form Builder',
      name: 'services_app',
      desc: '',
      args: [],
    );
  }

  /// `Roles Export`
  String get rolesExport {
    return Intl.message(
      'Roles Export',
      name: 'rolesExport',
      desc: '',
      args: [],
    );
  }

  /// `Role Name`
  String get roleName {
    return Intl.message('Role Name', name: 'roleName', desc: '', args: []);
  }

  /// `Role Name (Arabic)`
  String get roleNameArabic {
    return Intl.message(
      'Role Name (Arabic)',
      name: 'roleNameArabic',
      desc: '',
      args: [],
    );
  }

  /// `Role Description`
  String get roleDescription {
    return Intl.message(
      'Role Description',
      name: 'roleDescription',
      desc: '',
      args: [],
    );
  }

  /// `Role Description (Arabic)`
  String get roleDescriptionArabic {
    return Intl.message(
      'Role Description (Arabic)',
      name: 'roleDescriptionArabic',
      desc: '',
      args: [],
    );
  }

  /// `Created At`
  String get createdAt {
    return Intl.message('Created At', name: 'createdAt', desc: '', args: []);
  }

  /// `Activating Requests`
  String get activatingRequests {
    return Intl.message(
      'Activating Requests',
      name: 'activatingRequests',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to activate these requests?`
  String get areYouSureActivateRequests {
    return Intl.message(
      'Are you sure you want to activate these requests?',
      name: 'areYouSureActivateRequests',
      desc: '',
      args: [],
    );
  }

  /// `Edit Service Provider`
  String get editServiceProvider {
    return Intl.message(
      'Edit Service Provider',
      name: 'editServiceProvider',
      desc: '',
      args: [],
    );
  }

  /// `Master Upload`
  String get masterUpload {
    return Intl.message(
      'Master Upload',
      name: 'masterUpload',
      desc: '',
      args: [],
    );
  }

  /// `Services Data`
  String get servicesData {
    return Intl.message(
      'Services Data',
      name: 'servicesData',
      desc: '',
      args: [],
    );
  }

  /// `Services & Requests Activated Successfully`
  String get servicesRequestsActivatedSuccessfully {
    return Intl.message(
      'Services & Requests Activated Successfully',
      name: 'servicesRequestsActivatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Approved`
  String get sm_approved {
    return Intl.message('Approved', name: 'sm_approved', desc: '', args: []);
  }

  /// `Breached SLA`
  String get sm_breachedSla {
    return Intl.message(
      'Breached SLA',
      name: 'sm_breachedSla',
      desc: '',
      args: [],
    );
  }

  /// `chooseUnit`
  String get sm_chooseunit {
    return Intl.message(
      'chooseUnit',
      name: 'sm_chooseunit',
      desc: '',
      args: [],
    );
  }

  /// `day`
  String get sm_day {
    return Intl.message('day', name: 'sm_day', desc: '', args: []);
  }

  /// `days`
  String get sm_days {
    return Intl.message('days', name: 'sm_days', desc: '', args: []);
  }

  /// `Doesn't Need Approval`
  String get sm_doesnTNeedApproval {
    return Intl.message(
      'Doesn\'t Need Approval',
      name: 'sm_doesnTNeedApproval',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get sm_done {
    return Intl.message('Done', name: 'sm_done', desc: '', args: []);
  }

  /// `Duplicate Info Name`
  String get sm_duplicateInfoName {
    return Intl.message(
      'Duplicate Info Name',
      name: 'sm_duplicateInfoName',
      desc: '',
      args: [],
    );
  }

  /// `hour`
  String get sm_hour {
    return Intl.message('hour', name: 'sm_hour', desc: '', args: []);
  }

  /// `hours`
  String get sm_hours {
    return Intl.message('hours', name: 'sm_hours', desc: '', args: []);
  }

  /// `Inprogress`
  String get sm_inprogress {
    return Intl.message(
      'Inprogress',
      name: 'sm_inprogress',
      desc: '',
      args: [],
    );
  }

  /// `minute`
  String get sm_minute {
    return Intl.message('minute', name: 'sm_minute', desc: '', args: []);
  }

  /// `minutes`
  String get sm_minutes {
    return Intl.message('minutes', name: 'sm_minutes', desc: '', args: []);
  }

  /// `month`
  String get sm_month {
    return Intl.message('month', name: 'sm_month', desc: '', args: []);
  }

  /// `months`
  String get sm_months {
    return Intl.message('months', name: 'sm_months', desc: '', args: []);
  }

  /// `Need Approval`
  String get sm_needApproval {
    return Intl.message(
      'Need Approval',
      name: 'sm_needApproval',
      desc: '',
      args: [],
    );
  }

  /// `No requests found`
  String get sm_noRequestsFound {
    return Intl.message(
      'No requests found',
      name: 'sm_noRequestsFound',
      desc: '',
      args: [],
    );
  }

  /// `second`
  String get sm_second {
    return Intl.message('second', name: 'sm_second', desc: '', args: []);
  }

  /// `seconds`
  String get sm_seconds {
    return Intl.message('seconds', name: 'sm_seconds', desc: '', args: []);
  }

  /// `Selected`
  String get sm_selected {
    return Intl.message('Selected', name: 'sm_selected', desc: '', args: []);
  }

  /// `selected`
  String get sm_selected2 {
    return Intl.message('selected', name: 'sm_selected2', desc: '', args: []);
  }

  /// `Service Created Successfully`
  String get sm_serviceCreatedSuccessfully {
    return Intl.message(
      'Service Created Successfully',
      name: 'sm_serviceCreatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Service Updated Successfully`
  String get sm_serviceUpdatedSuccessfully {
    return Intl.message(
      'Service Updated Successfully',
      name: 'sm_serviceUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get sm_unknown {
    return Intl.message('Unknown', name: 'sm_unknown', desc: '', args: []);
  }

  /// `Unknown Unit`
  String get sm_unknownUnit {
    return Intl.message(
      'Unknown Unit',
      name: 'sm_unknownUnit',
      desc: '',
      args: [],
    );
  }

  /// `Unspecified`
  String get sm_unspecified {
    return Intl.message(
      'Unspecified',
      name: 'sm_unspecified',
      desc: '',
      args: [],
    );
  }

  /// `week`
  String get sm_week {
    return Intl.message('week', name: 'sm_week', desc: '', args: []);
  }

  /// `weeks`
  String get sm_weeks {
    return Intl.message('weeks', name: 'sm_weeks', desc: '', args: []);
  }

  /// `year`
  String get sm_year {
    return Intl.message('year', name: 'sm_year', desc: '', args: []);
  }

  /// `Afghan`
  String get afghan {
    return Intl.message('Afghan', name: 'afghan', desc: '', args: []);
  }

  /// `Albanian`
  String get albanian {
    return Intl.message('Albanian', name: 'albanian', desc: '', args: []);
  }

  /// `Algerian`
  String get algerian {
    return Intl.message('Algerian', name: 'algerian', desc: '', args: []);
  }

  /// `American`
  String get american {
    return Intl.message('American', name: 'american', desc: '', args: []);
  }

  /// `Andorran`
  String get andorran {
    return Intl.message('Andorran', name: 'andorran', desc: '', args: []);
  }

  /// `Angolan`
  String get angolan {
    return Intl.message('Angolan', name: 'angolan', desc: '', args: []);
  }

  /// `Antiguans`
  String get antiguans {
    return Intl.message('Antiguans', name: 'antiguans', desc: '', args: []);
  }

  /// `Argentinean`
  String get argentinean {
    return Intl.message('Argentinean', name: 'argentinean', desc: '', args: []);
  }

  /// `Armenian`
  String get armenian {
    return Intl.message('Armenian', name: 'armenian', desc: '', args: []);
  }

  /// `Australian`
  String get australian {
    return Intl.message('Australian', name: 'australian', desc: '', args: []);
  }

  /// `Austrian`
  String get austrian {
    return Intl.message('Austrian', name: 'austrian', desc: '', args: []);
  }

  /// `Azerbaijani`
  String get azerbaijani {
    return Intl.message('Azerbaijani', name: 'azerbaijani', desc: '', args: []);
  }

  /// `Bahamian`
  String get bahamian {
    return Intl.message('Bahamian', name: 'bahamian', desc: '', args: []);
  }

  /// `Bahraini`
  String get bahraini {
    return Intl.message('Bahraini', name: 'bahraini', desc: '', args: []);
  }

  /// `Bangladeshi`
  String get bangladeshi {
    return Intl.message('Bangladeshi', name: 'bangladeshi', desc: '', args: []);
  }

  /// `Barbadian`
  String get barbadian {
    return Intl.message('Barbadian', name: 'barbadian', desc: '', args: []);
  }

  /// `Barbudans`
  String get barbudans {
    return Intl.message('Barbudans', name: 'barbudans', desc: '', args: []);
  }

  /// `Batswana`
  String get batswana {
    return Intl.message('Batswana', name: 'batswana', desc: '', args: []);
  }

  /// `Belarusian`
  String get belarusian {
    return Intl.message('Belarusian', name: 'belarusian', desc: '', args: []);
  }

  /// `Belgian`
  String get belgian {
    return Intl.message('Belgian', name: 'belgian', desc: '', args: []);
  }

  /// `Belizean`
  String get belizean {
    return Intl.message('Belizean', name: 'belizean', desc: '', args: []);
  }

  /// `Beninese`
  String get beninese {
    return Intl.message('Beninese', name: 'beninese', desc: '', args: []);
  }

  /// `Bhutanese`
  String get bhutanese {
    return Intl.message('Bhutanese', name: 'bhutanese', desc: '', args: []);
  }

  /// `Bolivian`
  String get bolivian {
    return Intl.message('Bolivian', name: 'bolivian', desc: '', args: []);
  }

  /// `Bosnian`
  String get bosnian {
    return Intl.message('Bosnian', name: 'bosnian', desc: '', args: []);
  }

  /// `Brazilian`
  String get brazilian {
    return Intl.message('Brazilian', name: 'brazilian', desc: '', args: []);
  }

  /// `British`
  String get british {
    return Intl.message('British', name: 'british', desc: '', args: []);
  }

  /// `Bruneian`
  String get bruneian {
    return Intl.message('Bruneian', name: 'bruneian', desc: '', args: []);
  }

  /// `Bulgarian`
  String get bulgarian {
    return Intl.message('Bulgarian', name: 'bulgarian', desc: '', args: []);
  }

  /// `Burkinabe`
  String get burkinabe {
    return Intl.message('Burkinabe', name: 'burkinabe', desc: '', args: []);
  }

  /// `Burmese`
  String get burmese {
    return Intl.message('Burmese', name: 'burmese', desc: '', args: []);
  }

  /// `Burundian`
  String get burundian {
    return Intl.message('Burundian', name: 'burundian', desc: '', args: []);
  }

  /// `Cambodian`
  String get cambodian {
    return Intl.message('Cambodian', name: 'cambodian', desc: '', args: []);
  }

  /// `Cameroonian`
  String get cameroonian {
    return Intl.message('Cameroonian', name: 'cameroonian', desc: '', args: []);
  }

  /// `Canadian`
  String get canadian {
    return Intl.message('Canadian', name: 'canadian', desc: '', args: []);
  }

  /// `Cape Verdean`
  String get capeVerdean {
    return Intl.message(
      'Cape Verdean',
      name: 'capeVerdean',
      desc: '',
      args: [],
    );
  }

  /// `Central African`
  String get centralAfrican {
    return Intl.message(
      'Central African',
      name: 'centralAfrican',
      desc: '',
      args: [],
    );
  }

  /// `Chadian`
  String get chadian {
    return Intl.message('Chadian', name: 'chadian', desc: '', args: []);
  }

  /// `Chilean`
  String get chilean {
    return Intl.message('Chilean', name: 'chilean', desc: '', args: []);
  }

  /// `Chinese`
  String get chinese {
    return Intl.message('Chinese', name: 'chinese', desc: '', args: []);
  }

  /// `Colombian`
  String get colombian {
    return Intl.message('Colombian', name: 'colombian', desc: '', args: []);
  }

  /// `Comoran`
  String get comoran {
    return Intl.message('Comoran', name: 'comoran', desc: '', args: []);
  }

  /// `Congolese`
  String get congolese {
    return Intl.message('Congolese', name: 'congolese', desc: '', args: []);
  }

  /// `Costa Rican`
  String get costaRican {
    return Intl.message('Costa Rican', name: 'costaRican', desc: '', args: []);
  }

  /// `Croatian`
  String get croatian {
    return Intl.message('Croatian', name: 'croatian', desc: '', args: []);
  }

  /// `Cuban`
  String get cuban {
    return Intl.message('Cuban', name: 'cuban', desc: '', args: []);
  }

  /// `Cypriot`
  String get cypriot {
    return Intl.message('Cypriot', name: 'cypriot', desc: '', args: []);
  }

  /// `Czech`
  String get czech {
    return Intl.message('Czech', name: 'czech', desc: '', args: []);
  }

  /// `Danish`
  String get danish {
    return Intl.message('Danish', name: 'danish', desc: '', args: []);
  }

  /// `Djibouti`
  String get djibouti {
    return Intl.message('Djibouti', name: 'djibouti', desc: '', args: []);
  }

  /// `Dominican`
  String get dominican {
    return Intl.message('Dominican', name: 'dominican', desc: '', args: []);
  }

  /// `Dutch`
  String get dutch {
    return Intl.message('Dutch', name: 'dutch', desc: '', args: []);
  }

  /// `East Timorese`
  String get eastTimorese {
    return Intl.message(
      'East Timorese',
      name: 'eastTimorese',
      desc: '',
      args: [],
    );
  }

  /// `Ecuadorean`
  String get ecuadorean {
    return Intl.message('Ecuadorean', name: 'ecuadorean', desc: '', args: []);
  }

  /// `Egyptian`
  String get egyptian {
    return Intl.message('Egyptian', name: 'egyptian', desc: '', args: []);
  }

  /// `Emirian`
  String get emirian {
    return Intl.message('Emirian', name: 'emirian', desc: '', args: []);
  }

  /// `Equatorial Guinean`
  String get equatorialGuinean {
    return Intl.message(
      'Equatorial Guinean',
      name: 'equatorialGuinean',
      desc: '',
      args: [],
    );
  }

  /// `Eritrean`
  String get eritrean {
    return Intl.message('Eritrean', name: 'eritrean', desc: '', args: []);
  }

  /// `Estonian`
  String get estonian {
    return Intl.message('Estonian', name: 'estonian', desc: '', args: []);
  }

  /// `Ethiopian`
  String get ethiopian {
    return Intl.message('Ethiopian', name: 'ethiopian', desc: '', args: []);
  }

  /// `Fijian`
  String get fijian {
    return Intl.message('Fijian', name: 'fijian', desc: '', args: []);
  }

  /// `Filipino`
  String get filipino {
    return Intl.message('Filipino', name: 'filipino', desc: '', args: []);
  }

  /// `Finnish`
  String get finnish {
    return Intl.message('Finnish', name: 'finnish', desc: '', args: []);
  }

  /// `French`
  String get french {
    return Intl.message('French', name: 'french', desc: '', args: []);
  }

  /// `Gabonese`
  String get gabonese {
    return Intl.message('Gabonese', name: 'gabonese', desc: '', args: []);
  }

  /// `Gambian`
  String get gambian {
    return Intl.message('Gambian', name: 'gambian', desc: '', args: []);
  }

  /// `Georgian`
  String get georgian {
    return Intl.message('Georgian', name: 'georgian', desc: '', args: []);
  }

  /// `German`
  String get german {
    return Intl.message('German', name: 'german', desc: '', args: []);
  }

  /// `Ghanaian`
  String get ghanaian {
    return Intl.message('Ghanaian', name: 'ghanaian', desc: '', args: []);
  }

  /// `Greek`
  String get greek {
    return Intl.message('Greek', name: 'greek', desc: '', args: []);
  }

  /// `Grenadian`
  String get grenadian {
    return Intl.message('Grenadian', name: 'grenadian', desc: '', args: []);
  }

  /// `Guatemalan`
  String get guatemalan {
    return Intl.message('Guatemalan', name: 'guatemalan', desc: '', args: []);
  }

  /// `Guinea-Bissauan`
  String get guineaBissauan {
    return Intl.message(
      'Guinea-Bissauan',
      name: 'guineaBissauan',
      desc: '',
      args: [],
    );
  }

  /// `Guinean`
  String get guinean {
    return Intl.message('Guinean', name: 'guinean', desc: '', args: []);
  }

  /// `Guyanese`
  String get guyanese {
    return Intl.message('Guyanese', name: 'guyanese', desc: '', args: []);
  }

  /// `Haitian`
  String get haitian {
    return Intl.message('Haitian', name: 'haitian', desc: '', args: []);
  }

  /// `Herzegovinian`
  String get herzegovinian {
    return Intl.message(
      'Herzegovinian',
      name: 'herzegovinian',
      desc: '',
      args: [],
    );
  }

  /// `Honduran`
  String get honduran {
    return Intl.message('Honduran', name: 'honduran', desc: '', args: []);
  }

  /// `Hungarian`
  String get hungarian {
    return Intl.message('Hungarian', name: 'hungarian', desc: '', args: []);
  }

  /// `I-Kiribati`
  String get iKiribati {
    return Intl.message('I-Kiribati', name: 'iKiribati', desc: '', args: []);
  }

  /// `Icelander`
  String get icelander {
    return Intl.message('Icelander', name: 'icelander', desc: '', args: []);
  }

  /// `Indian`
  String get indian {
    return Intl.message('Indian', name: 'indian', desc: '', args: []);
  }

  /// `Indonesian`
  String get indonesian {
    return Intl.message('Indonesian', name: 'indonesian', desc: '', args: []);
  }

  /// `Iranian`
  String get iranian {
    return Intl.message('Iranian', name: 'iranian', desc: '', args: []);
  }

  /// `Iraqi`
  String get iraqi {
    return Intl.message('Iraqi', name: 'iraqi', desc: '', args: []);
  }

  /// `Irish`
  String get irish {
    return Intl.message('Irish', name: 'irish', desc: '', args: []);
  }

  /// `Israeli`
  String get israeli {
    return Intl.message('Israeli', name: 'israeli', desc: '', args: []);
  }

  /// `Italian`
  String get italian {
    return Intl.message('Italian', name: 'italian', desc: '', args: []);
  }

  /// `Ivorian`
  String get ivorian {
    return Intl.message('Ivorian', name: 'ivorian', desc: '', args: []);
  }

  /// `Jamaican`
  String get jamaican {
    return Intl.message('Jamaican', name: 'jamaican', desc: '', args: []);
  }

  /// `Japanese`
  String get japanese {
    return Intl.message('Japanese', name: 'japanese', desc: '', args: []);
  }

  /// `Jordanian`
  String get jordanian {
    return Intl.message('Jordanian', name: 'jordanian', desc: '', args: []);
  }

  /// `Kazakhstani`
  String get kazakhstani {
    return Intl.message('Kazakhstani', name: 'kazakhstani', desc: '', args: []);
  }

  /// `Kenyan`
  String get kenyan {
    return Intl.message('Kenyan', name: 'kenyan', desc: '', args: []);
  }

  /// `Kittian and Nevisian`
  String get kittianAndNevisian {
    return Intl.message(
      'Kittian and Nevisian',
      name: 'kittianAndNevisian',
      desc: '',
      args: [],
    );
  }

  /// `Kuwaiti`
  String get kuwaiti {
    return Intl.message('Kuwaiti', name: 'kuwaiti', desc: '', args: []);
  }

  /// `Kyrgyz`
  String get kyrgyz {
    return Intl.message('Kyrgyz', name: 'kyrgyz', desc: '', args: []);
  }

  /// `Laotian`
  String get laotian {
    return Intl.message('Laotian', name: 'laotian', desc: '', args: []);
  }

  /// `Latvian`
  String get latvian {
    return Intl.message('Latvian', name: 'latvian', desc: '', args: []);
  }

  /// `Lebanese`
  String get lebanese {
    return Intl.message('Lebanese', name: 'lebanese', desc: '', args: []);
  }

  /// `Liberian`
  String get liberian {
    return Intl.message('Liberian', name: 'liberian', desc: '', args: []);
  }

  /// `Libyan`
  String get libyan {
    return Intl.message('Libyan', name: 'libyan', desc: '', args: []);
  }

  /// `Liechtensteiner`
  String get liechtensteiner {
    return Intl.message(
      'Liechtensteiner',
      name: 'liechtensteiner',
      desc: '',
      args: [],
    );
  }

  /// `Lithuanian`
  String get lithuanian {
    return Intl.message('Lithuanian', name: 'lithuanian', desc: '', args: []);
  }

  /// `Luxembourger`
  String get luxembourger {
    return Intl.message(
      'Luxembourger',
      name: 'luxembourger',
      desc: '',
      args: [],
    );
  }

  /// `Macedonian`
  String get macedonian {
    return Intl.message('Macedonian', name: 'macedonian', desc: '', args: []);
  }

  /// `Malagasy`
  String get malagasy {
    return Intl.message('Malagasy', name: 'malagasy', desc: '', args: []);
  }

  /// `Malawian`
  String get malawian {
    return Intl.message('Malawian', name: 'malawian', desc: '', args: []);
  }

  /// `Malaysian`
  String get malaysian {
    return Intl.message('Malaysian', name: 'malaysian', desc: '', args: []);
  }

  /// `Maldivan`
  String get maldivan {
    return Intl.message('Maldivan', name: 'maldivan', desc: '', args: []);
  }

  /// `Malian`
  String get malian {
    return Intl.message('Malian', name: 'malian', desc: '', args: []);
  }

  /// `Maltese`
  String get maltese {
    return Intl.message('Maltese', name: 'maltese', desc: '', args: []);
  }

  /// `Marshallese`
  String get marshallese {
    return Intl.message('Marshallese', name: 'marshallese', desc: '', args: []);
  }

  /// `Mauritanian`
  String get mauritanian {
    return Intl.message('Mauritanian', name: 'mauritanian', desc: '', args: []);
  }

  /// `Mauritian`
  String get mauritian {
    return Intl.message('Mauritian', name: 'mauritian', desc: '', args: []);
  }

  /// `Mexican`
  String get mexican {
    return Intl.message('Mexican', name: 'mexican', desc: '', args: []);
  }

  /// `Micronesian`
  String get micronesian {
    return Intl.message('Micronesian', name: 'micronesian', desc: '', args: []);
  }

  /// `Moldovan`
  String get moldovan {
    return Intl.message('Moldovan', name: 'moldovan', desc: '', args: []);
  }

  /// `Monacan`
  String get monacan {
    return Intl.message('Monacan', name: 'monacan', desc: '', args: []);
  }

  /// `Mongolian`
  String get mongolian {
    return Intl.message('Mongolian', name: 'mongolian', desc: '', args: []);
  }

  /// `Moroccan`
  String get moroccan {
    return Intl.message('Moroccan', name: 'moroccan', desc: '', args: []);
  }

  /// `Mosotho`
  String get mosotho {
    return Intl.message('Mosotho', name: 'mosotho', desc: '', args: []);
  }

  /// `Motswana`
  String get motswana {
    return Intl.message('Motswana', name: 'motswana', desc: '', args: []);
  }

  /// `Mozambican`
  String get mozambican {
    return Intl.message('Mozambican', name: 'mozambican', desc: '', args: []);
  }

  /// `Namibian`
  String get namibian {
    return Intl.message('Namibian', name: 'namibian', desc: '', args: []);
  }

  /// `Nauruan`
  String get nauruan {
    return Intl.message('Nauruan', name: 'nauruan', desc: '', args: []);
  }

  /// `Nepalese`
  String get nepalese {
    return Intl.message('Nepalese', name: 'nepalese', desc: '', args: []);
  }

  /// `New Zealander`
  String get newZealander {
    return Intl.message(
      'New Zealander',
      name: 'newZealander',
      desc: '',
      args: [],
    );
  }

  /// `Nicaraguan`
  String get nicaraguan {
    return Intl.message('Nicaraguan', name: 'nicaraguan', desc: '', args: []);
  }

  /// `Nigerian`
  String get nigerian {
    return Intl.message('Nigerian', name: 'nigerian', desc: '', args: []);
  }

  /// `Nigerien`
  String get nigerien {
    return Intl.message('Nigerien', name: 'nigerien', desc: '', args: []);
  }

  /// `North Korean`
  String get northKorean {
    return Intl.message(
      'North Korean',
      name: 'northKorean',
      desc: '',
      args: [],
    );
  }

  /// `Northern Irish`
  String get northernIrish {
    return Intl.message(
      'Northern Irish',
      name: 'northernIrish',
      desc: '',
      args: [],
    );
  }

  /// `Norwegian`
  String get norwegian {
    return Intl.message('Norwegian', name: 'norwegian', desc: '', args: []);
  }

  /// `Omani`
  String get omani {
    return Intl.message('Omani', name: 'omani', desc: '', args: []);
  }

  /// `Pakistani`
  String get pakistani {
    return Intl.message('Pakistani', name: 'pakistani', desc: '', args: []);
  }

  /// `Palauan`
  String get palauan {
    return Intl.message('Palauan', name: 'palauan', desc: '', args: []);
  }

  /// `Panamanian`
  String get panamanian {
    return Intl.message('Panamanian', name: 'panamanian', desc: '', args: []);
  }

  /// `Papua New Guinean`
  String get papuaNewGuinean {
    return Intl.message(
      'Papua New Guinean',
      name: 'papuaNewGuinean',
      desc: '',
      args: [],
    );
  }

  /// `Paraguayan`
  String get paraguayan {
    return Intl.message('Paraguayan', name: 'paraguayan', desc: '', args: []);
  }

  /// `Peruvian`
  String get peruvian {
    return Intl.message('Peruvian', name: 'peruvian', desc: '', args: []);
  }

  /// `Polish`
  String get polish {
    return Intl.message('Polish', name: 'polish', desc: '', args: []);
  }

  /// `Portuguese`
  String get portuguese {
    return Intl.message('Portuguese', name: 'portuguese', desc: '', args: []);
  }

  /// `Qatari`
  String get qatari {
    return Intl.message('Qatari', name: 'qatari', desc: '', args: []);
  }

  /// `Romanian`
  String get romanian {
    return Intl.message('Romanian', name: 'romanian', desc: '', args: []);
  }

  /// `Russian`
  String get russian {
    return Intl.message('Russian', name: 'russian', desc: '', args: []);
  }

  /// `Rwandan`
  String get rwandan {
    return Intl.message('Rwandan', name: 'rwandan', desc: '', args: []);
  }

  /// `Saint Lucian`
  String get saintLucian {
    return Intl.message(
      'Saint Lucian',
      name: 'saintLucian',
      desc: '',
      args: [],
    );
  }

  /// `Salvadoran`
  String get salvadoran {
    return Intl.message('Salvadoran', name: 'salvadoran', desc: '', args: []);
  }

  /// `Samoan`
  String get samoan {
    return Intl.message('Samoan', name: 'samoan', desc: '', args: []);
  }

  /// `San Marinese`
  String get sanMarinese {
    return Intl.message(
      'San Marinese',
      name: 'sanMarinese',
      desc: '',
      args: [],
    );
  }

  /// `Sao Tomean`
  String get saoTomean {
    return Intl.message('Sao Tomean', name: 'saoTomean', desc: '', args: []);
  }

  /// `Saudi`
  String get saudi {
    return Intl.message('Saudi', name: 'saudi', desc: '', args: []);
  }

  /// `Scottish`
  String get scottish {
    return Intl.message('Scottish', name: 'scottish', desc: '', args: []);
  }

  /// `Senegalese`
  String get senegalese {
    return Intl.message('Senegalese', name: 'senegalese', desc: '', args: []);
  }

  /// `Serbian`
  String get serbian {
    return Intl.message('Serbian', name: 'serbian', desc: '', args: []);
  }

  /// `Seychellois`
  String get seychellois {
    return Intl.message('Seychellois', name: 'seychellois', desc: '', args: []);
  }

  /// `Sierra Leonean`
  String get sierraLeonean {
    return Intl.message(
      'Sierra Leonean',
      name: 'sierraLeonean',
      desc: '',
      args: [],
    );
  }

  /// `Singaporean`
  String get singaporean {
    return Intl.message('Singaporean', name: 'singaporean', desc: '', args: []);
  }

  /// `Slovakian`
  String get slovakian {
    return Intl.message('Slovakian', name: 'slovakian', desc: '', args: []);
  }

  /// `Slovenian`
  String get slovenian {
    return Intl.message('Slovenian', name: 'slovenian', desc: '', args: []);
  }

  /// `Solomon Islander`
  String get solomonIslander {
    return Intl.message(
      'Solomon Islander',
      name: 'solomonIslander',
      desc: '',
      args: [],
    );
  }

  /// `Somali`
  String get somali {
    return Intl.message('Somali', name: 'somali', desc: '', args: []);
  }

  /// `South African`
  String get southAfrican {
    return Intl.message(
      'South African',
      name: 'southAfrican',
      desc: '',
      args: [],
    );
  }

  /// `South Korean`
  String get southKorean {
    return Intl.message(
      'South Korean',
      name: 'southKorean',
      desc: '',
      args: [],
    );
  }

  /// `South Sudanese`
  String get southSudanese {
    return Intl.message(
      'South Sudanese',
      name: 'southSudanese',
      desc: '',
      args: [],
    );
  }

  /// `Spanish`
  String get spanish {
    return Intl.message('Spanish', name: 'spanish', desc: '', args: []);
  }

  /// `Sri Lankan`
  String get sriLankan {
    return Intl.message('Sri Lankan', name: 'sriLankan', desc: '', args: []);
  }

  /// `Sudanese`
  String get sudanese {
    return Intl.message('Sudanese', name: 'sudanese', desc: '', args: []);
  }

  /// `Surinamer`
  String get surinamer {
    return Intl.message('Surinamer', name: 'surinamer', desc: '', args: []);
  }

  /// `Swazi`
  String get swazi {
    return Intl.message('Swazi', name: 'swazi', desc: '', args: []);
  }

  /// `Swedish`
  String get swedish {
    return Intl.message('Swedish', name: 'swedish', desc: '', args: []);
  }

  /// `Swiss`
  String get swiss {
    return Intl.message('Swiss', name: 'swiss', desc: '', args: []);
  }

  /// `Syrian`
  String get syrian {
    return Intl.message('Syrian', name: 'syrian', desc: '', args: []);
  }

  /// `Taiwanese`
  String get taiwanese {
    return Intl.message('Taiwanese', name: 'taiwanese', desc: '', args: []);
  }

  /// `Tajik`
  String get tajik {
    return Intl.message('Tajik', name: 'tajik', desc: '', args: []);
  }

  /// `Tanzanian`
  String get tanzanian {
    return Intl.message('Tanzanian', name: 'tanzanian', desc: '', args: []);
  }

  /// `Thai`
  String get thai {
    return Intl.message('Thai', name: 'thai', desc: '', args: []);
  }

  /// `Togolese`
  String get togolese {
    return Intl.message('Togolese', name: 'togolese', desc: '', args: []);
  }

  /// `Tongan`
  String get tongan {
    return Intl.message('Tongan', name: 'tongan', desc: '', args: []);
  }

  /// `Trinidadian or Tobagonian`
  String get trinidadianOrTobagonian {
    return Intl.message(
      'Trinidadian or Tobagonian',
      name: 'trinidadianOrTobagonian',
      desc: '',
      args: [],
    );
  }

  /// `Tunisian`
  String get tunisian {
    return Intl.message('Tunisian', name: 'tunisian', desc: '', args: []);
  }

  /// `Turkish`
  String get turkish {
    return Intl.message('Turkish', name: 'turkish', desc: '', args: []);
  }

  /// `Tuvaluan`
  String get tuvaluan {
    return Intl.message('Tuvaluan', name: 'tuvaluan', desc: '', args: []);
  }

  /// `Ugandan`
  String get ugandan {
    return Intl.message('Ugandan', name: 'ugandan', desc: '', args: []);
  }

  /// `Ukrainian`
  String get ukrainian {
    return Intl.message('Ukrainian', name: 'ukrainian', desc: '', args: []);
  }

  /// `Uruguayan`
  String get uruguayan {
    return Intl.message('Uruguayan', name: 'uruguayan', desc: '', args: []);
  }

  /// `Uzbekistani`
  String get uzbekistani {
    return Intl.message('Uzbekistani', name: 'uzbekistani', desc: '', args: []);
  }

  /// `Venezuelan`
  String get venezuelan {
    return Intl.message('Venezuelan', name: 'venezuelan', desc: '', args: []);
  }

  /// `Vietnamese`
  String get vietnamese {
    return Intl.message('Vietnamese', name: 'vietnamese', desc: '', args: []);
  }

  /// `Welsh`
  String get welsh {
    return Intl.message('Welsh', name: 'welsh', desc: '', args: []);
  }

  /// `Yemenite`
  String get yemenite {
    return Intl.message('Yemenite', name: 'yemenite', desc: '', args: []);
  }

  /// `Zambian`
  String get zambian {
    return Intl.message('Zambian', name: 'zambian', desc: '', args: []);
  }

  /// `Zimbabwean`
  String get zimbabwean {
    return Intl.message('Zimbabwean', name: 'zimbabwean', desc: '', args: []);
  }

  /// `Set Date`
  String get setDate {
    return Intl.message('Set Date', name: 'setDate', desc: '', args: []);
  }

  /// `Choose here`
  String get chooseHere2 {
    return Intl.message('Choose here', name: 'chooseHere2', desc: '', args: []);
  }

  /// `GrcResponsivePage`
  String get grcresponsivepage {
    return Intl.message(
      'GrcResponsivePage',
      name: 'grcresponsivepage',
      desc: '',
      args: [],
    );
  }

  /// `FormResponsivePage`
  String get formresponsivepage {
    return Intl.message(
      'FormResponsivePage',
      name: 'formresponsivepage',
      desc: '',
      args: [],
    );
  }

  /// `TrackerPageResponsivePageRefactor`
  String get trackerpageresponsivepagerefactor {
    return Intl.message(
      'TrackerPageResponsivePageRefactor',
      name: 'trackerpageresponsivepagerefactor',
      desc: '',
      args: [],
    );
  }

  /// `TasksResponsivePage`
  String get tasksresponsivepage {
    return Intl.message(
      'TasksResponsivePage',
      name: 'tasksresponsivepage',
      desc: '',
      args: [],
    );
  }

  /// `Marketing Team`
  String get marketingTeam {
    return Intl.message(
      'Marketing Team',
      name: 'marketingTeam',
      desc: '',
      args: [],
    );
  }

  /// `Development Team`
  String get developmentTeam {
    return Intl.message(
      'Development Team',
      name: 'developmentTeam',
      desc: '',
      args: [],
    );
  }

  /// `Media Team`
  String get mediaTeam {
    return Intl.message('Media Team', name: 'mediaTeam', desc: '', args: []);
  }

  /// `Tech Team`
  String get techTeam {
    return Intl.message('Tech Team', name: 'techTeam', desc: '', args: []);
  }

  /// `1 H Before`
  String get k1HBefore {
    return Intl.message('1 H Before', name: 'k1HBefore', desc: '', args: []);
  }

  /// `2 H Before`
  String get k2HBefore {
    return Intl.message('2 H Before', name: 'k2HBefore', desc: '', args: []);
  }

  /// `Set Time`
  String get setTime {
    return Intl.message('Set Time', name: 'setTime', desc: '', args: []);
  }

  /// `Today`
  String get today {
    return Intl.message('Today', name: 'today', desc: '', args: []);
  }

  /// `1h`
  String get k1h {
    return Intl.message('1h', name: 'k1h', desc: '', args: []);
  }

  /// `Reschedule`
  String get reschedule {
    return Intl.message('Reschedule', name: 'reschedule', desc: '', args: []);
  }

  /// `Begins in 30m`
  String get beginsIn30m {
    return Intl.message(
      'Begins in 30m',
      name: 'beginsIn30m',
      desc: '',
      args: [],
    );
  }

  /// `Reset Personal Branding`
  String get resetPersonalBranding {
    return Intl.message(
      'Reset Personal Branding',
      name: 'resetPersonalBranding',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Reset Your Personal Branding To Company Defaults?`
  String get areYouSureYouWantToResetYourPersonalBrandingToCo {
    return Intl.message(
      'Are You Sure You Want To Reset Your Personal Branding To Company Defaults?',
      name: 'areYouSureYouWantToResetYourPersonalBrandingToCo',
      desc: '',
      args: [],
    );
  }

  /// `Personal Branding`
  String get personalBranding {
    return Intl.message(
      'Personal Branding',
      name: 'personalBranding',
      desc: '',
      args: [],
    );
  }

  /// `Reset to Company Defaults`
  String get resetToCompanyDefaults {
    return Intl.message(
      'Reset to Company Defaults',
      name: 'resetToCompanyDefaults',
      desc: '',
      args: [],
    );
  }

  /// `Customize your personal branding. These settings will override company branding for your account only.`
  String get customizeYourPersonalBrandingTheseSettingsWillOv {
    return Intl.message(
      'Customize your personal branding. These settings will override company branding for your account only.',
      name: 'customizeYourPersonalBrandingTheseSettingsWillOv',
      desc: '',
      args: [],
    );
  }

  /// `Personal Logo`
  String get personalLogo {
    return Intl.message(
      'Personal Logo',
      name: 'personalLogo',
      desc: '',
      args: [],
    );
  }

  /// `Colors`
  String get colors {
    return Intl.message('Colors', name: 'colors', desc: '', args: []);
  }

  /// `Fonts`
  String get fonts {
    return Intl.message('Fonts', name: 'fonts', desc: '', args: []);
  }

  /// `Select English Font`
  String get selectEnglishFont {
    return Intl.message(
      'Select English Font',
      name: 'selectEnglishFont',
      desc: '',
      args: [],
    );
  }

  /// `Select Arabic Font`
  String get selectArabicFont {
    return Intl.message(
      'Select Arabic Font',
      name: 'selectArabicFont',
      desc: '',
      args: [],
    );
  }

  /// `Save Personal Branding`
  String get savePersonalBranding {
    return Intl.message(
      'Save Personal Branding',
      name: 'savePersonalBranding',
      desc: '',
      args: [],
    );
  }

  /// `Add Employee`
  String get addEmployee {
    return Intl.message(
      'Add Employee',
      name: 'addEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Employee Profile`
  String get employeeProfile {
    return Intl.message(
      'Employee Profile',
      name: 'employeeProfile',
      desc: '',
      args: [],
    );
  }

  /// `Permission`
  String get permission {
    return Intl.message('Permission', name: 'permission', desc: '', args: []);
  }

  /// `Employees Attendance`
  String get employeesAttendance {
    return Intl.message(
      'Employees Attendance',
      name: 'employeesAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Pending Projects`
  String get pendingProjects {
    return Intl.message(
      'Pending Projects',
      name: 'pendingProjects',
      desc: '',
      args: [],
    );
  }

  /// `In Progress Projects`
  String get inProgressProjects {
    return Intl.message(
      'In Progress Projects',
      name: 'inProgressProjects',
      desc: '',
      args: [],
    );
  }

  /// `Done Projects`
  String get doneProjects {
    return Intl.message(
      'Done Projects',
      name: 'doneProjects',
      desc: '',
      args: [],
    );
  }

  /// `Project Performance`
  String get projectPerformance {
    return Intl.message(
      'Project Performance',
      name: 'projectPerformance',
      desc: '',
      args: [],
    );
  }

  /// `Create Task from Home Page`
  String get createTaskFromHomePage {
    return Intl.message(
      'Create Task from Home Page',
      name: 'createTaskFromHomePage',
      desc: '',
      args: [],
    );
  }

  /// `Create Meeting from Home Page`
  String get createMeetingFromHomePage {
    return Intl.message(
      'Create Meeting from Home Page',
      name: 'createMeetingFromHomePage',
      desc: '',
      args: [],
    );
  }

  /// `Task Reminder`
  String get taskReminder {
    return Intl.message(
      'Task Reminder',
      name: 'taskReminder',
      desc: '',
      args: [],
    );
  }

  /// `Task Details`
  String get taskDetails {
    return Intl.message(
      'Task Details',
      name: 'taskDetails',
      desc: '',
      args: [],
    );
  }

  /// `Custom Table`
  String get customTable {
    return Intl.message(
      'Custom Table',
      name: 'customTable',
      desc: '',
      args: [],
    );
  }

  /// `See More`
  String get seeMore {
    return Intl.message('See More', name: 'seeMore', desc: '', args: []);
  }

  /// `Add Member`
  String get addMember {
    return Intl.message('Add Member', name: 'addMember', desc: '', args: []);
  }

  /// `Remove Member`
  String get removeMember {
    return Intl.message(
      'Remove Member',
      name: 'removeMember',
      desc: '',
      args: [],
    );
  }

  /// `Create Board`
  String get createBoard {
    return Intl.message(
      'Create Board',
      name: 'createBoard',
      desc: '',
      args: [],
    );
  }

  /// `Create Meeting`
  String get createMeeting {
    return Intl.message(
      'Create Meeting',
      name: 'createMeeting',
      desc: '',
      args: [],
    );
  }

  /// `Edit Meeting`
  String get editMeeting {
    return Intl.message(
      'Edit Meeting',
      name: 'editMeeting',
      desc: '',
      args: [],
    );
  }

  /// `Reschedule Meeting`
  String get rescheduleMeeting {
    return Intl.message(
      'Reschedule Meeting',
      name: 'rescheduleMeeting',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Meeting`
  String get cancelMeeting {
    return Intl.message(
      'Cancel Meeting',
      name: 'cancelMeeting',
      desc: '',
      args: [],
    );
  }

  /// `My Profile`
  String get myProfile {
    return Intl.message('My Profile', name: 'myProfile', desc: '', args: []);
  }

  /// `Company Information`
  String get companyInformation {
    return Intl.message(
      'Company Information',
      name: 'companyInformation',
      desc: '',
      args: [],
    );
  }

  /// `Subscription`
  String get subscription {
    return Intl.message(
      'Subscription',
      name: 'subscription',
      desc: '',
      args: [],
    );
  }

  /// `Male`
  String get male {
    return Intl.message('Male', name: 'male', desc: '', args: []);
  }

  /// `Female`
  String get female {
    return Intl.message('Female', name: 'female', desc: '', args: []);
  }

  /// `On Site`
  String get onSite {
    return Intl.message('On Site', name: 'onSite', desc: '', args: []);
  }

  /// `Hybrid`
  String get hybrid2 {
    return Intl.message('Hybrid', name: 'hybrid2', desc: '', args: []);
  }

  /// `Full-time`
  String get fullTime {
    return Intl.message('Full-time', name: 'fullTime', desc: '', args: []);
  }

  /// `Part-time`
  String get partTime {
    return Intl.message('Part-time', name: 'partTime', desc: '', args: []);
  }

  /// `Contract`
  String get contract {
    return Intl.message('Contract', name: 'contract', desc: '', args: []);
  }

  /// `Employees Added`
  String get employeesAdded {
    return Intl.message(
      'Employees Added',
      name: 'employeesAdded',
      desc: '',
      args: [],
    );
  }

  /// `Employees Terminated`
  String get employeesTerminated {
    return Intl.message(
      'Employees Terminated',
      name: 'employeesTerminated',
      desc: '',
      args: [],
    );
  }

  /// `Add Photo`
  String get addPhoto {
    return Intl.message('Add Photo', name: 'addPhoto', desc: '', args: []);
  }

  /// `Add New Employees`
  String get addNewEmployees {
    return Intl.message(
      'Add New Employees',
      name: 'addNewEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Yearly`
  String get yearly {
    return Intl.message('Yearly', name: 'yearly', desc: '', args: []);
  }

  /// `Org Chart`
  String get orgChart {
    return Intl.message('Org Chart', name: 'orgChart', desc: '', args: []);
  }

  /// `Team Departments`
  String get teamDepartments {
    return Intl.message(
      'Team Departments',
      name: 'teamDepartments',
      desc: '',
      args: [],
    );
  }

  /// `On Time`
  String get onTime {
    return Intl.message('On Time', name: 'onTime', desc: '', args: []);
  }

  /// `Less than 30 minutes`
  String get lessThan30Minutes {
    return Intl.message(
      'Less than 30 minutes',
      name: 'lessThan30Minutes',
      desc: '',
      args: [],
    );
  }

  /// `More than 30 minutes`
  String get moreThan30Minutes {
    return Intl.message(
      'More than 30 minutes',
      name: 'moreThan30Minutes',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Email`
  String get invalidEmail {
    return Intl.message(
      'Invalid Email',
      name: 'invalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Date`
  String get invalidDate {
    return Intl.message(
      'Invalid Date',
      name: 'invalidDate',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Phone Number`
  String get invalidPhoneNumber {
    return Intl.message(
      'Invalid Phone Number',
      name: 'invalidPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Postal Code`
  String get invalidPostalCode {
    return Intl.message(
      'Invalid Postal Code',
      name: 'invalidPostalCode',
      desc: '',
      args: [],
    );
  }

  /// `Why you want to leave..?`
  String get whyYouWantToLeave {
    return Intl.message(
      'Why you want to leave..?',
      name: 'whyYouWantToLeave',
      desc: '',
      args: [],
    );
  }

  /// `Fields`
  String get fields {
    return Intl.message('Fields', name: 'fields', desc: '', args: []);
  }

  /// `Personal Data`
  String get personalData {
    return Intl.message(
      'Personal Data',
      name: 'personalData',
      desc: '',
      args: [],
    );
  }

  /// `Contact Information`
  String get contactInformation {
    return Intl.message(
      'Contact Information',
      name: 'contactInformation',
      desc: '',
      args: [],
    );
  }

  /// `Location Information`
  String get locationInformation {
    return Intl.message(
      'Location Information',
      name: 'locationInformation',
      desc: '',
      args: [],
    );
  }

  /// `Emergency Contact Information`
  String get emergencyContactInformation {
    return Intl.message(
      'Emergency Contact Information',
      name: 'emergencyContactInformation',
      desc: '',
      args: [],
    );
  }

  /// `Additional Information`
  String get additionalInformation {
    return Intl.message(
      'Additional Information',
      name: 'additionalInformation',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'current' key

  /// `Escalates`
  String get escalates {
    return Intl.message('Escalates', name: 'escalates', desc: '', args: []);
  }

  /// `Send`
  String get send {
    return Intl.message('Send', name: 'send', desc: '', args: []);
  }

  /// `A password reset link has been sent to your email`
  String get passwordResetLinkSent {
    return Intl.message(
      'A password reset link has been sent to your email',
      name: 'passwordResetLinkSent',
      desc: '',
      args: [],
    );
  }

  /// `Thank You`
  String get thankYou {
    return Intl.message('Thank You', name: 'thankYou', desc: '', args: []);
  }

  /// `We'd love to hear more about your service`
  String get weDLoveToHearMoreAboutYourService {
    return Intl.message(
      'We\'d love to hear more about your service',
      name: 'weDLoveToHearMoreAboutYourService',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logOut {
    return Intl.message('Log Out', name: 'logOut', desc: '', args: []);
  }

  /// `This module is not available`
  String get thisModuleIsNotAvailable {
    return Intl.message(
      'This module is not available',
      name: 'thisModuleIsNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Can't Connect .. Check Internet`
  String get canTConnectCheckInternet {
    return Intl.message(
      'Can\'t Connect .. Check Internet',
      name: 'canTConnectCheckInternet',
      desc: '',
      args: [],
    );
  }

  /// `Upcoming Schedule`
  String get upcomingSchedule {
    return Intl.message(
      'Upcoming Schedule',
      name: 'upcomingSchedule',
      desc: '',
      args: [],
    );
  }

  /// `Quick Actions`
  String get quickActions {
    return Intl.message(
      'Quick Actions',
      name: 'quickActions',
      desc: '',
      args: [],
    );
  }

  /// `System Managements`
  String get systemManagements {
    return Intl.message(
      'System Managements',
      name: 'systemManagements',
      desc: '',
      args: [],
    );
  }

  /// `+1K`
  String get k1k {
    return Intl.message('+1K', name: 'k1k', desc: '', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `View Submissions`
  String get viewSubmissions {
    return Intl.message(
      'View Submissions',
      name: 'viewSubmissions',
      desc: '',
      args: [],
    );
  }

  /// `Remind All`
  String get remindAll {
    return Intl.message('Remind All', name: 'remindAll', desc: '', args: []);
  }

  /// `Forms`
  String get forms {
    return Intl.message('Forms', name: 'forms', desc: '', args: []);
  }

  /// `Create Form`
  String get createForm {
    return Intl.message('Create Form', name: 'createForm', desc: '', args: []);
  }

  /// `Order`
  String get order {
    return Intl.message('Order', name: 'order', desc: '', args: []);
  }

  /// `Asset`
  String get asset {
    return Intl.message('Asset', name: 'asset', desc: '', args: []);
  }

  /// `Consumable`
  String get consumable {
    return Intl.message('Consumable', name: 'consumable', desc: '', args: []);
  }

  /// `Total Product`
  String get totalProduct {
    return Intl.message(
      'Total Product',
      name: 'totalProduct',
      desc: '',
      args: [],
    );
  }

  /// `Total Damaged`
  String get totalDamaged {
    return Intl.message(
      'Total Damaged',
      name: 'totalDamaged',
      desc: '',
      args: [],
    );
  }

  /// `Total Missing`
  String get totalMissing {
    return Intl.message(
      'Total Missing',
      name: 'totalMissing',
      desc: '',
      args: [],
    );
  }

  /// `Total Salon`
  String get totalSalon {
    return Intl.message('Total Salon', name: 'totalSalon', desc: '', args: []);
  }

  /// `Stocks`
  String get stocks {
    return Intl.message('Stocks', name: 'stocks', desc: '', args: []);
  }

  /// `Error loading data`
  String get errorLoadingData {
    return Intl.message(
      'Error loading data',
      name: 'errorLoadingData',
      desc: '',
      args: [],
    );
  }

  /// `View Dashboard`
  String get viewDashboard {
    return Intl.message(
      'View Dashboard',
      name: 'viewDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Near Breached SLA`
  String get nearBreachedSLA {
    return Intl.message(
      'Near Breached SLA',
      name: 'nearBreachedSLA',
      desc: '',
      args: [],
    );
  }

  /// `No near breached SLA services`
  String get noNearBreachedSLAServices {
    return Intl.message(
      'No near breached SLA services',
      name: 'noNearBreachedSLAServices',
      desc: '',
      args: [],
    );
  }

  /// `SLA`
  String get sla {
    return Intl.message('SLA', name: 'sla', desc: '', args: []);
  }

  /// `In Progress`
  String get inProgress {
    return Intl.message('In Progress', name: 'inProgress', desc: '', args: []);
  }

  /// `Services Status`
  String get servicesStatus {
    return Intl.message(
      'Services Status',
      name: 'servicesStatus',
      desc: '',
      args: [],
    );
  }

  /// `Error loading tasks`
  String get errorLoadingTasks {
    return Intl.message(
      'Error loading tasks',
      name: 'errorLoadingTasks',
      desc: '',
      args: [],
    );
  }

  /// `No active tasks`
  String get noActiveTasks {
    return Intl.message(
      'No active tasks',
      name: 'noActiveTasks',
      desc: '',
      args: [],
    );
  }

  /// `Untitled Task`
  String get untitledTask {
    return Intl.message(
      'Untitled Task',
      name: 'untitledTask',
      desc: '',
      args: [],
    );
  }

  /// `Sign Out`
  String get signOut {
    return Intl.message('Sign Out', name: 'signOut', desc: '', args: []);
  }

  /// `Delete starred messages`
  String get deleteStarredMessages {
    return Intl.message(
      'Delete starred messages',
      name: 'deleteStarredMessages',
      desc: '',
      args: [],
    );
  }

  /// `HomePageHelper`
  String get homepagehelper {
    return Intl.message(
      'HomePageHelper',
      name: 'homepagehelper',
      desc: '',
      args: [],
    );
  }

  /// `Authentication Error`
  String get authenticationError {
    return Intl.message(
      'Authentication Error',
      name: 'authenticationError',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred during login. Please try again.`
  String get anErrorOccurredDuringLoginPleaseTryAgain {
    return Intl.message(
      'An error occurred during login. Please try again.',
      name: 'anErrorOccurredDuringLoginPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Authentication Failed`
  String get authenticationFailed {
    return Intl.message(
      'Authentication Failed',
      name: 'authenticationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Invalid credentials. Please verify and try again.`
  String get invalidCredentialsPleaseVerifyAndTryAgain {
    return Intl.message(
      'Invalid credentials. Please verify and try again.',
      name: 'invalidCredentialsPleaseVerifyAndTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Account Locked`
  String get accountLocked {
    return Intl.message(
      'Account Locked',
      name: 'accountLocked',
      desc: '',
      args: [],
    );
  }

  /// `Knowticed Plus`
  String get demoAppPlus {
    return Intl.message(
      'Knowticed Plus',
      name: 'demoAppPlus',
      desc: '',
      args: [],
    );
  }

  /// `Navigate the Digital Frontier with Ease`
  String get navigateTheDigitalFrontierWithEase {
    return Intl.message(
      'Navigate the Digital Frontier with Ease',
      name: 'navigateTheDigitalFrontierWithEase',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot Password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get signIn {
    return Intl.message('Sign In', name: 'signIn', desc: '', args: []);
  }

  /// `Please Check Your Internet Connection`
  String get pleaseCheckYourInternetConnection {
    return Intl.message(
      'Please Check Your Internet Connection',
      name: 'pleaseCheckYourInternetConnection',
      desc: '',
      args: [],
    );
  }

  /// `Missing Information`
  String get missingInformation {
    return Intl.message(
      'Missing Information',
      name: 'missingInformation',
      desc: '',
      args: [],
    );
  }

  /// `Please enter both email and password to sign in`
  String get pleaseEnterBothEmailAndPasswordToSignIn {
    return Intl.message(
      'Please enter both email and password to sign in',
      name: 'pleaseEnterBothEmailAndPasswordToSignIn',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get resetPassword {
    return Intl.message(
      'Reset Password',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get newPassword {
    return Intl.message(
      'New Password',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwordsDoNotMatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up is not available in demo mode.`
  String get signUpIsNotAvailableInDemoMode {
    return Intl.message(
      'Sign Up is not available in demo mode.',
      name: 'signUpIsNotAvailableInDemoMode',
      desc: '',
      args: [],
    );
  }

  /// `Effortless Task Management`
  String get effortlessTaskManagement {
    return Intl.message(
      'Effortless Task Management',
      name: 'effortlessTaskManagement',
      desc: '',
      args: [],
    );
  }

  /// `Streamlined Requests`
  String get streamlinedRequests {
    return Intl.message(
      'Streamlined Requests',
      name: 'streamlinedRequests',
      desc: '',
      args: [],
    );
  }

  /// `Comprehensive Service Management`
  String get comprehensiveServiceManagement {
    return Intl.message(
      'Comprehensive Service Management',
      name: 'comprehensiveServiceManagement',
      desc: '',
      args: [],
    );
  }

  /// `Efficient Event Management`
  String get efficientEventManagement {
    return Intl.message(
      'Efficient Event Management',
      name: 'efficientEventManagement',
      desc: '',
      args: [],
    );
  }

  /// `Flexible Role Management`
  String get flexibleRoleManagement {
    return Intl.message(
      'Flexible Role Management',
      name: 'flexibleRoleManagement',
      desc: '',
      args: [],
    );
  }

  /// `Personalized To-Do Lists`
  String get personalizedToDoLists {
    return Intl.message(
      'Personalized To-Do Lists',
      name: 'personalizedToDoLists',
      desc: '',
      args: [],
    );
  }

  /// `Real-Time Team Chat`
  String get realTimeTeamChat {
    return Intl.message(
      'Real-Time Team Chat',
      name: 'realTimeTeamChat',
      desc: '',
      args: [],
    );
  }

  /// `Clear Organization Chart`
  String get clearOrganizationChart {
    return Intl.message(
      'Clear Organization Chart',
      name: 'clearOrganizationChart',
      desc: '',
      args: [],
    );
  }

  /// `Get Start`
  String get getStart {
    return Intl.message('Get Start', name: 'getStart', desc: '', args: []);
  }

  /// `Skip`
  String get skip {
    return Intl.message('Skip', name: 'skip', desc: '', args: []);
  }

  /// `Forgot Password`
  String get forgotPassword2 {
    return Intl.message(
      'Forgot Password',
      name: 'forgotPassword2',
      desc: '',
      args: [],
    );
  }

  /// `Submit Request`
  String get submitRequest {
    return Intl.message(
      'Submit Request',
      name: 'submitRequest',
      desc: '',
      args: [],
    );
  }

  /// `Attention`
  String get attention {
    return Intl.message('Attention', name: 'attention', desc: '', args: []);
  }

  /// `This Email Not Found`
  String get thisEmailNotFound {
    return Intl.message(
      'This Email Not Found',
      name: 'thisEmailNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Deactivating User Account`
  String get deactivatingUserAccount {
    return Intl.message(
      'Deactivating User Account',
      name: 'deactivatingUserAccount',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Deactivate This Account?`
  String get areYouSureYouWantToDeactivateThisAccount {
    return Intl.message(
      'Are You Sure You Want To Deactivate This Account?',
      name: 'areYouSureYouWantToDeactivateThisAccount',
      desc: '',
      args: [],
    );
  }

  /// `Activating User Account`
  String get activatingUserAccount {
    return Intl.message(
      'Activating User Account',
      name: 'activatingUserAccount',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Activate This Account?`
  String get areYouSureYouWantToActivateThisAccount {
    return Intl.message(
      'Are You Sure You Want To Activate This Account?',
      name: 'areYouSureYouWantToActivateThisAccount',
      desc: '',
      args: [],
    );
  }

  /// `First Login`
  String get firstLogin {
    return Intl.message('First Login', name: 'firstLogin', desc: '', args: []);
  }

  /// `Expiration Time of Password`
  String get expirationTimeOfPassword {
    return Intl.message(
      'Expiration Time of Password',
      name: 'expirationTimeOfPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter Expiration Time`
  String get enterExpirationTime {
    return Intl.message(
      'Enter Expiration Time',
      name: 'enterExpirationTime',
      desc: '',
      args: [],
    );
  }

  /// `Requested To Reset Password ?`
  String get requestedToResetPassword {
    return Intl.message(
      'Requested To Reset Password ?',
      name: 'requestedToResetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Unlock Account`
  String get unlockAccount {
    return Intl.message(
      'Unlock Account',
      name: 'unlockAccount',
      desc: '',
      args: [],
    );
  }

  /// `Schedule for Activate`
  String get scheduleForActivate {
    return Intl.message(
      'Schedule for Activate',
      name: 'scheduleForActivate',
      desc: '',
      args: [],
    );
  }

  /// `Please select a date`
  String get pleaseSelectADate {
    return Intl.message(
      'Please select a date',
      name: 'pleaseSelectADate',
      desc: '',
      args: [],
    );
  }

  /// `Schedule for Deactivation`
  String get scheduleForDeactivation {
    return Intl.message(
      'Schedule for Deactivation',
      name: 'scheduleForDeactivation',
      desc: '',
      args: [],
    );
  }

  /// `CSV Import`
  String get csvImport {
    return Intl.message('CSV Import', name: 'csvImport', desc: '', args: []);
  }

  /// `Edit Role`
  String get editRole {
    return Intl.message('Edit Role', name: 'editRole', desc: '', args: []);
  }

  /// `Adding New Role Permissions`
  String get addingNewRolePermissions {
    return Intl.message(
      'Adding New Role Permissions',
      name: 'addingNewRolePermissions',
      desc: '',
      args: [],
    );
  }

  /// `No modules granted`
  String get noModulesGranted {
    return Intl.message(
      'No modules granted',
      name: 'noModulesGranted',
      desc: '',
      args: [],
    );
  }

  /// `Platform Roles`
  String get platformRoles {
    return Intl.message(
      'Platform Roles',
      name: 'platformRoles',
      desc: '',
      args: [],
    );
  }

  /// `Role`
  String get role {
    return Intl.message('Role', name: 'role', desc: '', args: []);
  }

  /// `OK`
  String get ok2 {
    return Intl.message('OK', name: 'ok2', desc: '', args: []);
  }

  /// `Downloading File`
  String get downloadingFile {
    return Intl.message(
      'Downloading File',
      name: 'downloadingFile',
      desc: '',
      args: [],
    );
  }

  /// `Adding New Access`
  String get addingNewAccess {
    return Intl.message(
      'Adding New Access',
      name: 'addingNewAccess',
      desc: '',
      args: [],
    );
  }

  /// `Add Access`
  String get addAccess {
    return Intl.message('Add Access', name: 'addAccess', desc: '', args: []);
  }

  /// `User Access Details`
  String get userAccessDetails {
    return Intl.message(
      'User Access Details',
      name: 'userAccessDetails',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove this access?`
  String get areYouSureYouWantToRemoveThisAccess {
    return Intl.message(
      'Are you sure you want to remove this access?',
      name: 'areYouSureYouWantToRemoveThisAccess',
      desc: '',
      args: [],
    );
  }

  /// `Access`
  String get access {
    return Intl.message('Access', name: 'access', desc: '', args: []);
  }

  /// `Access Details`
  String get accessDetails {
    return Intl.message(
      'Access Details',
      name: 'accessDetails',
      desc: '',
      args: [],
    );
  }

  /// `Select Access Granted`
  String get selectAccessGranted {
    return Intl.message(
      'Select Access Granted',
      name: 'selectAccessGranted',
      desc: '',
      args: [],
    );
  }

  /// `Select Access Revoked`
  String get selectAccessRevoked {
    return Intl.message(
      'Select Access Revoked',
      name: 'selectAccessRevoked',
      desc: '',
      args: [],
    );
  }

  /// `Total Employees`
  String get totalEmployees {
    return Intl.message(
      'Total Employees',
      name: 'totalEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Total Departments`
  String get totalDepartments {
    return Intl.message(
      'Total Departments',
      name: 'totalDepartments',
      desc: '',
      args: [],
    );
  }

  /// `No Role`
  String get noRole {
    return Intl.message('No Role', name: 'noRole', desc: '', args: []);
  }

  /// `Access Updated`
  String get accessUpdated {
    return Intl.message(
      'Access Updated',
      name: 'accessUpdated',
      desc: '',
      args: [],
    );
  }

  /// `No permissions found`
  String get noPermissionsFound {
    return Intl.message(
      'No permissions found',
      name: 'noPermissionsFound',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chat {
    return Intl.message('Chat', name: 'chat', desc: '', args: []);
  }

  /// `Not Available`
  String get notAvailable {
    return Intl.message(
      'Not Available',
      name: 'notAvailable',
      desc: '',
      args: [],
    );
  }

  /// `About This App`
  String get aboutThisApp {
    return Intl.message(
      'About This App',
      name: 'aboutThisApp',
      desc: '',
      args: [],
    );
  }

  /// `Comments And Feedbacks`
  String get commentsAndFeedbacks {
    return Intl.message(
      'Comments And Feedbacks',
      name: 'commentsAndFeedbacks',
      desc: '',
      args: [],
    );
  }

  /// `Report Bugs`
  String get reportBugs {
    return Intl.message('Report Bugs', name: 'reportBugs', desc: '', args: []);
  }

  /// `Comments And Feedback`
  String get commentsAndFeedback {
    return Intl.message(
      'Comments And Feedback',
      name: 'commentsAndFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Request New Feature`
  String get requestNewFeature {
    return Intl.message(
      'Request New Feature',
      name: 'requestNewFeature',
      desc: '',
      args: [],
    );
  }

  /// `Thanks for sharing your feedback`
  String get thanksForSharingYourFeedback {
    return Intl.message(
      'Thanks for sharing your feedback',
      name: 'thanksForSharingYourFeedback',
      desc: '',
      args: [],
    );
  }

  /// `We value our customers and strive to exceed their expectations`
  String get weValueOurCustomersAndStriveToExceedTheirExpecta {
    return Intl.message(
      'We value our customers and strive to exceed their expectations',
      name: 'weValueOurCustomersAndStriveToExceedTheirExpecta',
      desc: '',
      args: [],
    );
  }

  /// `Single`
  String get single {
    return Intl.message('Single', name: 'single', desc: '', args: []);
  }

  /// `Married`
  String get married {
    return Intl.message('Married', name: 'married', desc: '', args: []);
  }

  /// `Divorced`
  String get divorced {
    return Intl.message('Divorced', name: 'divorced', desc: '', args: []);
  }

  /// `Widowed`
  String get widowed {
    return Intl.message('Widowed', name: 'widowed', desc: '', args: []);
  }

  /// `Please fill in all required fields`
  String get pleaseFillInAllRequiredFields {
    return Intl.message(
      'Please fill in all required fields',
      name: 'pleaseFillInAllRequiredFields',
      desc: '',
      args: [],
    );
  }

  /// `You haven't made any changes to submit`
  String get youHavenTMadeAnyChangesToSubmit {
    return Intl.message(
      'You haven\'t made any changes to submit',
      name: 'youHavenTMadeAnyChangesToSubmit',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your First Name`
  String get enterYourFirstName {
    return Intl.message(
      'Enter Your First Name',
      name: 'enterYourFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Middle Name`
  String get enterYourMiddleName {
    return Intl.message(
      'Enter Your Middle Name',
      name: 'enterYourMiddleName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Last Name`
  String get enterYourLastName {
    return Intl.message(
      'Enter Your Last Name',
      name: 'enterYourLastName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Email`
  String get enterYourEmail {
    return Intl.message(
      'Enter Your Email',
      name: 'enterYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Phone Number`
  String get enterThePhoneNumber {
    return Intl.message(
      'Enter The Phone Number',
      name: 'enterThePhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Country`
  String get enterYourCountry {
    return Intl.message(
      'Enter Your Country',
      name: 'enterYourCountry',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your State Or Province`
  String get enterYourStateOrProvince {
    return Intl.message(
      'Enter Your State Or Province',
      name: 'enterYourStateOrProvince',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your City`
  String get enterYourCity {
    return Intl.message(
      'Enter Your City',
      name: 'enterYourCity',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Street Address`
  String get enterYourStreetAddress {
    return Intl.message(
      'Enter Your Street Address',
      name: 'enterYourStreetAddress',
      desc: '',
      args: [],
    );
  }

  /// `Request to Change`
  String get requestToChange {
    return Intl.message(
      'Request to Change',
      name: 'requestToChange',
      desc: '',
      args: [],
    );
  }

  /// `Terms And Conditions`
  String get termsAndConditions2 {
    return Intl.message(
      'Terms And Conditions',
      name: 'termsAndConditions2',
      desc: '',
      args: [],
    );
  }

  /// `Haptic Feedback`
  String get hapticFeedback {
    return Intl.message(
      'Haptic Feedback',
      name: 'hapticFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Biometrics`
  String get biometrics {
    return Intl.message('Biometrics', name: 'biometrics', desc: '', args: []);
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message('Dark Mode', name: 'darkMode', desc: '', args: []);
  }

  /// `Animation`
  String get animation {
    return Intl.message('Animation', name: 'animation', desc: '', args: []);
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Update Social Information`
  String get updateSocialInformation {
    return Intl.message(
      'Update Social Information',
      name: 'updateSocialInformation',
      desc: '',
      args: [],
    );
  }

  /// `Primary Color`
  String get primaryColor {
    return Intl.message(
      'Primary Color',
      name: 'primaryColor',
      desc: '',
      args: [],
    );
  }

  /// `Secondary Color`
  String get secondaryColor {
    return Intl.message(
      'Secondary Color',
      name: 'secondaryColor',
      desc: '',
      args: [],
    );
  }

  /// `Reset Branding`
  String get resetBranding {
    return Intl.message(
      'Reset Branding',
      name: 'resetBranding',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Reset The Company Branding?`
  String get areYouSureYouWantToResetTheCompanyBranding {
    return Intl.message(
      'Are You Sure You Want To Reset The Company Branding?',
      name: 'areYouSureYouWantToResetTheCompanyBranding',
      desc: '',
      args: [],
    );
  }

  /// `Company Name`
  String get companyName {
    return Intl.message(
      'Company Name',
      name: 'companyName',
      desc: '',
      args: [],
    );
  }

  /// `Industry`
  String get industry {
    return Intl.message('Industry', name: 'industry', desc: '', args: []);
  }

  /// `Company Size`
  String get companySize {
    return Intl.message(
      'Company Size',
      name: 'companySize',
      desc: '',
      args: [],
    );
  }

  /// `Enter Company Name`
  String get enterCompanyName {
    return Intl.message(
      'Enter Company Name',
      name: 'enterCompanyName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Tax Number`
  String get enterTaxNumber {
    return Intl.message(
      'Enter Tax Number',
      name: 'enterTaxNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter Street Address`
  String get enterStreetAddress {
    return Intl.message(
      'Enter Street Address',
      name: 'enterStreetAddress',
      desc: '',
      args: [],
    );
  }

  /// `Enter City`
  String get enterCity {
    return Intl.message('Enter City', name: 'enterCity', desc: '', args: []);
  }

  /// `Zip Code or Postal Code`
  String get zipCodeOrPostalCode {
    return Intl.message(
      'Zip Code or Postal Code',
      name: 'zipCodeOrPostalCode',
      desc: '',
      args: [],
    );
  }

  /// `Enter State Or Province`
  String get enterStateOrProvince {
    return Intl.message(
      'Enter State Or Province',
      name: 'enterStateOrProvince',
      desc: '',
      args: [],
    );
  }

  /// `Enter Country`
  String get enterCountry {
    return Intl.message(
      'Enter Country',
      name: 'enterCountry',
      desc: '',
      args: [],
    );
  }

  /// `Enters Country`
  String get entersCountry {
    return Intl.message(
      'Enters Country',
      name: 'entersCountry',
      desc: '',
      args: [],
    );
  }

  /// `Company Industry`
  String get companyIndustry {
    return Intl.message(
      'Company Industry',
      name: 'companyIndustry',
      desc: '',
      args: [],
    );
  }

  /// `Enter Email`
  String get enterEmail {
    return Intl.message('Enter Email', name: 'enterEmail', desc: '', args: []);
  }

  /// `Enter Your Mobile Number`
  String get enterYourMobileNumber {
    return Intl.message(
      'Enter Your Mobile Number',
      name: 'enterYourMobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter New Email`
  String get enterNewEmail {
    return Intl.message(
      'Enter New Email',
      name: 'enterNewEmail',
      desc: '',
      args: [],
    );
  }

  /// `Select Country`
  String get selectCountry {
    return Intl.message(
      'Select Country',
      name: 'selectCountry',
      desc: '',
      args: [],
    );
  }

  /// `Search country...`
  String get searchCountry {
    return Intl.message(
      'Search country...',
      name: 'searchCountry',
      desc: '',
      args: [],
    );
  }

  /// `No countries found`
  String get noCountriesFound {
    return Intl.message(
      'No countries found',
      name: 'noCountriesFound',
      desc: '',
      args: [],
    );
  }

  /// `Enter Contact Relation`
  String get enterContactRelation {
    return Intl.message(
      'Enter Contact Relation',
      name: 'enterContactRelation',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Mobile Phone`
  String get enterYourMobilePhone {
    return Intl.message(
      'Enter Your Mobile Phone',
      name: 'enterYourMobilePhone',
      desc: '',
      args: [],
    );
  }

  /// `Enter Insurance Name`
  String get enterInsuranceName {
    return Intl.message(
      'Enter Insurance Name',
      name: 'enterInsuranceName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Policy Number`
  String get enterPolicyNumber {
    return Intl.message(
      'Enter Policy Number',
      name: 'enterPolicyNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter First Name`
  String get enterFirstName {
    return Intl.message(
      'Enter First Name',
      name: 'enterFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Middle Name`
  String get enterMiddleName {
    return Intl.message(
      'Enter Middle Name',
      name: 'enterMiddleName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Last Name`
  String get enterLastName {
    return Intl.message(
      'Enter Last Name',
      name: 'enterLastName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Postal Code`
  String get enterPostalCode {
    return Intl.message(
      'Enter Postal Code',
      name: 'enterPostalCode',
      desc: '',
      args: [],
    );
  }

  /// `Enter Insurance Police Number`
  String get enterInsurancePoliceNumber {
    return Intl.message(
      'Enter Insurance Police Number',
      name: 'enterInsurancePoliceNumber',
      desc: '',
      args: [],
    );
  }

  /// `Select Gender`
  String get selectGender {
    return Intl.message(
      'Select Gender',
      name: 'selectGender',
      desc: '',
      args: [],
    );
  }

  /// `Rather Not Say`
  String get ratherNotSay {
    return Intl.message(
      'Rather Not Say',
      name: 'ratherNotSay',
      desc: '',
      args: [],
    );
  }

  /// `Separated`
  String get separated {
    return Intl.message('Separated', name: 'separated', desc: '', args: []);
  }

  /// `Engaged`
  String get engaged {
    return Intl.message('Engaged', name: 'engaged', desc: '', args: []);
  }

  /// `Nationality`
  String get nationality {
    return Intl.message('Nationality', name: 'nationality', desc: '', args: []);
  }

  /// `Bio`
  String get bio {
    return Intl.message('Bio', name: 'bio', desc: '', args: []);
  }

  /// `Share Something About Yourself`
  String get shareSomethingAboutYourself {
    return Intl.message(
      'Share Something About Yourself',
      name: 'shareSomethingAboutYourself',
      desc: '',
      args: [],
    );
  }

  /// `Hobbies`
  String get hobbies {
    return Intl.message('Hobbies', name: 'hobbies', desc: '', args: []);
  }

  /// `Enter Hobby`
  String get enterHobby {
    return Intl.message('Enter Hobby', name: 'enterHobby', desc: '', args: []);
  }

  /// `Company Services`
  String get companyServices {
    return Intl.message(
      'Company Services',
      name: 'companyServices',
      desc: '',
      args: [],
    );
  }

  /// `Why`
  String get why {
    return Intl.message('Why', name: 'why', desc: '', args: []);
  }

  /// `Meeting`
  String get meeting {
    return Intl.message('Meeting', name: 'meeting', desc: '', args: []);
  }

  /// `And`
  String get and {
    return Intl.message('And', name: 'and', desc: '', args: []);
  }

  /// `Rescheduled`
  String get rescheduled {
    return Intl.message('Rescheduled', name: 'rescheduled', desc: '', args: []);
  }

  /// `From`
  String get from {
    return Intl.message('From', name: 'from', desc: '', args: []);
  }

  /// `M`
  String get m {
    return Intl.message('M', name: 'm', desc: '', args: []);
  }

  /// `K`
  String get k {
    return Intl.message('K', name: 'k', desc: '', args: []);
  }

  /// `Seconds Ago`
  String get secondsAgo {
    return Intl.message('Seconds Ago', name: 'secondsAgo', desc: '', args: []);
  }

  /// `Minutes Ago`
  String get minutesAgo {
    return Intl.message('Minutes Ago', name: 'minutesAgo', desc: '', args: []);
  }

  /// `Hours Ago`
  String get hoursAgo {
    return Intl.message('Hours Ago', name: 'hoursAgo', desc: '', args: []);
  }

  /// `Days Ago`
  String get daysAgo {
    return Intl.message('Days Ago', name: 'daysAgo', desc: '', args: []);
  }

  /// `Weeks Ago`
  String get weeksAgo {
    return Intl.message('Weeks Ago', name: 'weeksAgo', desc: '', args: []);
  }

  /// `Months Ago`
  String get monthsAgo {
    return Intl.message('Months Ago', name: 'monthsAgo', desc: '', args: []);
  }

  /// `Years Ago`
  String get yearsAgo {
    return Intl.message('Years Ago', name: 'yearsAgo', desc: '', args: []);
  }

  /// `is not available`
  String get isNotAvailable {
    return Intl.message(
      'is not available',
      name: 'isNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Good Morning`
  String get goodMorning {
    return Intl.message(
      'Good Morning',
      name: 'goodMorning',
      desc: '',
      args: [],
    );
  }

  /// `Good Afternoon`
  String get goodAfternoon {
    return Intl.message(
      'Good Afternoon',
      name: 'goodAfternoon',
      desc: '',
      args: [],
    );
  }

  /// `Good Evening`
  String get goodEvening {
    return Intl.message(
      'Good Evening',
      name: 'goodEvening',
      desc: '',
      args: [],
    );
  }

  /// `Due Date`
  String get dueDate {
    return Intl.message('Due Date', name: 'dueDate', desc: '', args: []);
  }

  /// `Copyright`
  String get copyright {
    return Intl.message('Copyright', name: 'copyright', desc: '', args: []);
  }

  /// `ALL RIGHTS RESERVED`
  String get allRIGHTSRESERVED {
    return Intl.message(
      'ALL RIGHTS RESERVED',
      name: 'allRIGHTSRESERVED',
      desc: '',
      args: [],
    );
  }

  /// `Version:`
  String get version {
    return Intl.message('Version:', name: 'version', desc: '', args: []);
  }

  /// `Inactive For Now`
  String get inactiveForNow {
    return Intl.message(
      'Inactive For Now',
      name: 'inactiveForNow',
      desc: '',
      args: [],
    );
  }

  /// `Active For Now`
  String get activeForNow {
    return Intl.message(
      'Active For Now',
      name: 'activeForNow',
      desc: '',
      args: [],
    );
  }

  /// `Deactivated For Now`
  String get deactivatedForNow {
    return Intl.message(
      'Deactivated For Now',
      name: 'deactivatedForNow',
      desc: '',
      args: [],
    );
  }

  /// `Will Be Reactivated At`
  String get willBeReactivatedAt {
    return Intl.message(
      'Will Be Reactivated At',
      name: 'willBeReactivatedAt',
      desc: '',
      args: [],
    );
  }

  /// `Role Type`
  String get roleType {
    return Intl.message('Role Type', name: 'roleType', desc: '', args: []);
  }

  /// `Current`
  String get currentLabel {
    return Intl.message('Current', name: 'currentLabel', desc: '', args: []);
  }

  /// `Yesterday`
  String get yesterday {
    return Intl.message('Yesterday', name: 'yesterday', desc: '', args: []);
  }

  /// `Please enter a valid email address for communication`
  String get pleaseEnterAValidEmailAddressForCommunication {
    return Intl.message(
      'Please enter a valid email address for communication',
      name: 'pleaseEnterAValidEmailAddressForCommunication',
      desc: '',
      args: [],
    );
  }

  /// `The email must follow the format user@domain.com`
  String get theEmailMustFollowTheFormatUserDomainCom {
    return Intl.message(
      'The email must follow the format user@domain.com',
      name: 'theEmailMustFollowTheFormatUserDomainCom',
      desc: '',
      args: [],
    );
  }

  /// `Email Required`
  String get emailRequired2 {
    return Intl.message(
      'Email Required',
      name: 'emailRequired2',
      desc: '',
      args: [],
    );
  }

  /// `Kindly enter the employee’s first name. This field is mandatory for identification`
  String get kindlyEnterTheEmployeeSFirstNameThisFieldIsMandatoryFor {
    return Intl.message(
      'Kindly enter the employee’s first name. This field is mandatory for identification',
      name: 'kindlyEnterTheEmployeeSFirstNameThisFieldIsMandatoryFor',
      desc: '',
      args: [],
    );
  }

  /// `This field accepts English only. Please provide your entry in English script; entries in any other language cannot be accepted.`
  String get thisFieldAcceptsEnglishOnlyPleaseProvideYourEntryInEngl {
    return Intl.message(
      'This field accepts English only. Please provide your entry in English script; entries in any other language cannot be accepted.',
      name: 'thisFieldAcceptsEnglishOnlyPleaseProvideYourEntryInEngl',
      desc: '',
      args: [],
    );
  }

  /// `Invalid First Name`
  String get invalidFirstName {
    return Intl.message(
      'Invalid First Name',
      name: 'invalidFirstName',
      desc: '',
      args: [],
    );
  }

  /// `First Name Missing`
  String get firstNameMissing {
    return Intl.message(
      'First Name Missing',
      name: 'firstNameMissing',
      desc: '',
      args: [],
    );
  }

  /// `English Language Mandatory`
  String get englishLanguageMandatory {
    return Intl.message(
      'English Language Mandatory',
      name: 'englishLanguageMandatory',
      desc: '',
      args: [],
    );
  }

  /// `Kindly enter the employee’s middle name. This field is mandatory for identification`
  String get kindlyEnterTheEmployeeSMiddleNameThisFieldIsMandatoryFo {
    return Intl.message(
      'Kindly enter the employee’s middle name. This field is mandatory for identification',
      name: 'kindlyEnterTheEmployeeSMiddleNameThisFieldIsMandatoryFo',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Middle Name`
  String get invalidMiddleName {
    return Intl.message(
      'Invalid Middle Name',
      name: 'invalidMiddleName',
      desc: '',
      args: [],
    );
  }

  /// `Middle Name Missing`
  String get middleNameMissing {
    return Intl.message(
      'Middle Name Missing',
      name: 'middleNameMissing',
      desc: '',
      args: [],
    );
  }

  /// `Kindly enter the employee’s last name. This field is mandatory for identification`
  String get kindlyEnterTheEmployeeSLastNameThisFieldIsMandatoryForI {
    return Intl.message(
      'Kindly enter the employee’s last name. This field is mandatory for identification',
      name: 'kindlyEnterTheEmployeeSLastNameThisFieldIsMandatoryForI',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Last Name`
  String get invalidLastName {
    return Intl.message(
      'Invalid Last Name',
      name: 'invalidLastName',
      desc: '',
      args: [],
    );
  }

  /// `Last Name Missing`
  String get lastNameMissing {
    return Intl.message(
      'Last Name Missing',
      name: 'lastNameMissing',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the first name in Arabic. This is a required field for localization purposes.`
  String get pleaseEnterTheFirstNameInArabicThisIsARequiredFieldForL {
    return Intl.message(
      'Please enter the first name in Arabic. This is a required field for localization purposes.',
      name: 'pleaseEnterTheFirstNameInArabicThisIsARequiredFieldForL',
      desc: '',
      args: [],
    );
  }

  /// `This field accepts Arabic only. Please provide your entry in Arabic script; entries in any other language cannot be accepted.`
  String get thisFieldAcceptsArabicOnlyPleaseProvideYourEntryInArabi {
    return Intl.message(
      'This field accepts Arabic only. Please provide your entry in Arabic script; entries in any other language cannot be accepted.',
      name: 'thisFieldAcceptsArabicOnlyPleaseProvideYourEntryInArabi',
      desc: '',
      args: [],
    );
  }

  /// `Arabic First Name Missing`
  String get arabicFirstNameMissing {
    return Intl.message(
      'Arabic First Name Missing',
      name: 'arabicFirstNameMissing',
      desc: '',
      args: [],
    );
  }

  /// `Arabic Language Mandatory`
  String get arabicLanguageMandatory {
    return Intl.message(
      'Arabic Language Mandatory',
      name: 'arabicLanguageMandatory',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the middle name in Arabic. This is a required field for localization purposes.`
  String get pleaseEnterTheMiddleNameInArabicThisIsARequiredFieldFor {
    return Intl.message(
      'Please enter the middle name in Arabic. This is a required field for localization purposes.',
      name: 'pleaseEnterTheMiddleNameInArabicThisIsARequiredFieldFor',
      desc: '',
      args: [],
    );
  }

  /// `Arabic Middle Name Missing`
  String get arabicMiddleNameMissing {
    return Intl.message(
      'Arabic Middle Name Missing',
      name: 'arabicMiddleNameMissing',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the last name in Arabic. This is a required field for localization purposes.`
  String get pleaseEnterTheLastNameInArabicThisIsARequiredFieldForLo {
    return Intl.message(
      'Please enter the last name in Arabic. This is a required field for localization purposes.',
      name: 'pleaseEnterTheLastNameInArabicThisIsARequiredFieldForLo',
      desc: '',
      args: [],
    );
  }

  /// `Arabic Last Name Missing`
  String get arabicLastNameMissing {
    return Intl.message(
      'Arabic Last Name Missing',
      name: 'arabicLastNameMissing',
      desc: '',
      args: [],
    );
  }

  /// `Please provide a valid department ID. This field is mandatory for organizational structure.`
  String get pleaseProvideAValidDepartmentIDThisFieldIsMandatoryForO {
    return Intl.message(
      'Please provide a valid department ID. This field is mandatory for organizational structure.',
      name: 'pleaseProvideAValidDepartmentIDThisFieldIsMandatoryForO',
      desc: '',
      args: [],
    );
  }

  /// `The Department ID must be numeric and contain no letters`
  String get theDepartmentIDMustBeNumericAndContainNoLetters {
    return Intl.message(
      'The Department ID must be numeric and contain no letters',
      name: 'theDepartmentIDMustBeNumericAndContainNoLetters',
      desc: '',
      args: [],
    );
  }

  /// `Missing Department ID`
  String get missingDepartmentID {
    return Intl.message(
      'Missing Department ID',
      name: 'missingDepartmentID',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Department ID Format`
  String get invalidDepartmentIDFormat {
    return Intl.message(
      'Invalid Department ID Format',
      name: 'invalidDepartmentIDFormat',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid date in DD/MM/YYYY format.`
  String get pleaseEnterAValidDateInDDMMYYYYFormat {
    return Intl.message(
      'Please enter a valid date in DD/MM/YYYY format.',
      name: 'pleaseEnterAValidDateInDDMMYYYYFormat',
      desc: '',
      args: [],
    );
  }

  /// `Please select a date later than today for the National ID expiration.`
  String get pleaseSelectADateLaterThanTodayForTheNationalIDExpirati {
    return Intl.message(
      'Please select a date later than today for the National ID expiration.',
      name: 'pleaseSelectADateLaterThanTodayForTheNationalIDExpirati',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Expiry Date`
  String get invalidExpiryDate {
    return Intl.message(
      'Invalid Expiry Date',
      name: 'invalidExpiryDate',
      desc: '',
      args: [],
    );
  }

  /// `Expiry Date Must Be in the Future`
  String get expiryDateMustBeInTheFuture {
    return Intl.message(
      'Expiry Date Must Be in the Future',
      name: 'expiryDateMustBeInTheFuture',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid date of birth. Future dates are not allowed`
  String get pleaseEnterAValidDateOfBirthFutureDatesAreNotAllowed {
    return Intl.message(
      'Please enter a valid date of birth. Future dates are not allowed',
      name: 'pleaseEnterAValidDateOfBirthFutureDatesAreNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Birth Date`
  String get invalidBirthDate {
    return Intl.message(
      'Invalid Birth Date',
      name: 'invalidBirthDate',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the office extension number`
  String get pleaseEnterTheOfficeExtensionNumber {
    return Intl.message(
      'Please enter the office extension number',
      name: 'pleaseEnterTheOfficeExtensionNumber',
      desc: '',
      args: [],
    );
  }

  /// `Only digits are permitted in the extension field`
  String get onlyDigitsArePermittedInTheExtensionField {
    return Intl.message(
      'Only digits are permitted in the extension field',
      name: 'onlyDigitsArePermittedInTheExtensionField',
      desc: '',
      args: [],
    );
  }

  /// `Extension Required`
  String get extensionRequired {
    return Intl.message(
      'Extension Required',
      name: 'extensionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid phone number in the format +[Country Code][Number]`
  String get pleaseEnterAValidPhoneNumberInTheFormatCountryCodeNumbe {
    return Intl.message(
      'Please enter a valid phone number in the format +[Country Code][Number]',
      name: 'pleaseEnterAValidPhoneNumberInTheFormatCountryCodeNumbe',
      desc: '',
      args: [],
    );
  }

  /// `The phone number must be between 8 and 15 digit`
  String get thePhoneNumberMustBeBetween8And15Digit {
    return Intl.message(
      'The phone number must be between 8 and 15 digit',
      name: 'thePhoneNumberMustBeBetween8And15Digit',
      desc: '',
      args: [],
    );
  }

  /// `Phone Required`
  String get phoneRequired {
    return Intl.message(
      'Phone Required',
      name: 'phoneRequired',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Phone Format`
  String get invalidPhoneFormat {
    return Intl.message(
      'Invalid Phone Format',
      name: 'invalidPhoneFormat',
      desc: '',
      args: [],
    );
  }

  /// `Only digits are allowed. Please remove any letters or symbols.`
  String get onlyDigitsAreAllowedPleaseRemoveAnyLettersOrSymbols {
    return Intl.message(
      'Only digits are allowed. Please remove any letters or symbols.',
      name: 'onlyDigitsAreAllowedPleaseRemoveAnyLettersOrSymbols',
      desc: '',
      args: [],
    );
  }

  /// `National ID must be exactly 14 digits long.`
  String get nationalIDMustBeExactly14DigitsLong {
    return Intl.message(
      'National ID must be exactly 14 digits long.',
      name: 'nationalIDMustBeExactly14DigitsLong',
      desc: '',
      args: [],
    );
  }

  /// `Non-Numeric Characters in National ID`
  String get nonNumericCharactersInNationalID {
    return Intl.message(
      'Non-Numeric Characters in National ID',
      name: 'nonNumericCharactersInNationalID',
      desc: '',
      args: [],
    );
  }

  /// `Invalid National ID`
  String get invalidNationalID {
    return Intl.message(
      'Invalid National ID',
      name: 'invalidNationalID',
      desc: '',
      args: [],
    );
  }

  /// `Unsupported Characters in Passport Number`
  String get unsupportedCharactersInPassportNumber {
    return Intl.message(
      'Unsupported Characters in Passport Number',
      name: 'unsupportedCharactersInPassportNumber',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Passport Number`
  String get invalidPassportNumber {
    return Intl.message(
      'Invalid Passport Number',
      name: 'invalidPassportNumber',
      desc: '',
      args: [],
    );
  }

  /// `Gender field must be either 'male', 'female', or 'other'.`
  String get genderFieldMustBeEitherMaleFemaleOrOther {
    return Intl.message(
      'Gender field must be either \'male\', \'female\', or \'other\'.',
      name: 'genderFieldMustBeEitherMaleFemaleOrOther',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Gender`
  String get invalidGender {
    return Intl.message(
      'Invalid Gender',
      name: 'invalidGender',
      desc: '',
      args: [],
    );
  }

  /// `Please provide a valid postal code. It must match the city and province.`
  String get pleaseProvideAValidPostalCodeItMustMatchTheCityAndProvi {
    return Intl.message(
      'Please provide a valid postal code. It must match the city and province.',
      name: 'pleaseProvideAValidPostalCodeItMustMatchTheCityAndProvi',
      desc: '',
      args: [],
    );
  }

  /// `Error Occured, Please try again`
  String get errorOccuredPleaseTryAgain {
    return Intl.message(
      'Error Occured, Please try again',
      name: 'errorOccuredPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Please enable microphone service!`
  String get pleaseEnableMicrophoneService {
    return Intl.message(
      'Please enable microphone service!',
      name: 'pleaseEnableMicrophoneService',
      desc: '',
      args: [],
    );
  }

  /// `Forward to`
  String get forwardTo {
    return Intl.message('Forward to', name: 'forwardTo', desc: '', args: []);
  }

  /// `Frequently Contacted`
  String get frequentlyContacted {
    return Intl.message(
      'Frequently Contacted',
      name: 'frequentlyContacted',
      desc: '',
      args: [],
    );
  }

  /// `Recently Contacted`
  String get recentlyContacted {
    return Intl.message(
      'Recently Contacted',
      name: 'recentlyContacted',
      desc: '',
      args: [],
    );
  }

  /// `Edited`
  String get edited {
    return Intl.message('Edited', name: 'edited', desc: '', args: []);
  }

  /// `You deleted this message`
  String get youDeletedThisMessage {
    return Intl.message(
      'You deleted this message',
      name: 'youDeletedThisMessage',
      desc: '',
      args: [],
    );
  }

  /// `Add Caption`
  String get addCaption {
    return Intl.message('Add Caption', name: 'addCaption', desc: '', args: []);
  }

  /// `Contact Info`
  String get contactInfo {
    return Intl.message(
      'Contact Info',
      name: 'contactInfo',
      desc: '',
      args: [],
    );
  }

  /// `No common groups`
  String get noCommonGroups {
    return Intl.message(
      'No common groups',
      name: 'noCommonGroups',
      desc: '',
      args: [],
    );
  }

  /// `No starred messages`
  String get noStarredMessages {
    return Intl.message(
      'No starred messages',
      name: 'noStarredMessages',
      desc: '',
      args: [],
    );
  }

  /// `You`
  String get you {
    return Intl.message('You', name: 'you', desc: '', args: []);
  }

  /// `Audio`
  String get audio {
    return Intl.message('Audio', name: 'audio', desc: '', args: []);
  }

  /// `Schedule a message`
  String get scheduleAMessage {
    return Intl.message(
      'Schedule a message',
      name: 'scheduleAMessage',
      desc: '',
      args: [],
    );
  }

  /// `Total Picked Files`
  String get totalPickedFiles {
    return Intl.message(
      'Total Picked Files',
      name: 'totalPickedFiles',
      desc: '',
      args: [],
    );
  }

  /// `Pages`
  String get pages {
    return Intl.message('Pages', name: 'pages', desc: '', args: []);
  }

  /// `Reply`
  String get reply {
    return Intl.message('Reply', name: 'reply', desc: '', args: []);
  }

  /// `Copy`
  String get copy {
    return Intl.message('Copy', name: 'copy', desc: '', args: []);
  }

  /// `Poll Details`
  String get pollDetails {
    return Intl.message(
      'Poll Details',
      name: 'pollDetails',
      desc: '',
      args: [],
    );
  }

  /// `of`
  String get ofLabel {
    return Intl.message('of', name: 'ofLabel', desc: '', args: []);
  }

  /// `members voted`
  String get membersVoted {
    return Intl.message(
      'members voted',
      name: 'membersVoted',
      desc: '',
      args: [],
    );
  }

  /// `Create Poll`
  String get createPoll {
    return Intl.message('Create Poll', name: 'createPoll', desc: '', args: []);
  }

  /// `Question`
  String get question {
    return Intl.message('Question', name: 'question', desc: '', args: []);
  }

  /// `Ask a Question`
  String get askAQuestion {
    return Intl.message(
      'Ask a Question',
      name: 'askAQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Options`
  String get options {
    return Intl.message('Options', name: 'options', desc: '', args: []);
  }

  /// `Option`
  String get option {
    return Intl.message('Option', name: 'option', desc: '', args: []);
  }

  /// `Add option`
  String get addOption {
    return Intl.message('Add option', name: 'addOption', desc: '', args: []);
  }

  /// `Allow Multiple Answers`
  String get allowMultipleAnswers {
    return Intl.message(
      'Allow Multiple Answers',
      name: 'allowMultipleAnswers',
      desc: '',
      args: [],
    );
  }

  /// `Type your Message...`
  String get typeYourMessage {
    return Intl.message(
      'Type your Message...',
      name: 'typeYourMessage',
      desc: '',
      args: [],
    );
  }

  /// `Typing...`
  String get typing {
    return Intl.message('Typing...', name: 'typing', desc: '', args: []);
  }

  /// `Deleted Message`
  String get deletedMessage {
    return Intl.message(
      'Deleted Message',
      name: 'deletedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Leader`
  String get leader {
    return Intl.message('Leader', name: 'leader', desc: '', args: []);
  }

  /// `Starred Messages`
  String get starredMessages {
    return Intl.message(
      'Starred Messages',
      name: 'starredMessages',
      desc: '',
      args: [],
    );
  }

  /// `No groups in common`
  String get noGroupsInCommon {
    return Intl.message(
      'No groups in common',
      name: 'noGroupsInCommon',
      desc: '',
      args: [],
    );
  }

  /// `Groups in common`
  String get groupsInCommon {
    return Intl.message(
      'Groups in common',
      name: 'groupsInCommon',
      desc: '',
      args: [],
    );
  }

  /// `Create a new group with`
  String get createANewGroupWith {
    return Intl.message(
      'Create a new group with',
      name: 'createANewGroupWith',
      desc: '',
      args: [],
    );
  }

  /// `You,`
  String get you2 {
    return Intl.message('You,', name: 'you2', desc: '', args: []);
  }

  /// `Expansion`
  String get expansion {
    return Intl.message('Expansion', name: 'expansion', desc: '', args: []);
  }

  /// `Direct Message`
  String get directMessage {
    return Intl.message(
      'Direct Message',
      name: 'directMessage',
      desc: '',
      args: [],
    );
  }

  /// `Also delete media received in this chat from the device gallery`
  String get alsoDeleteMediaReceivedInThisChatFromTheDeviceGallery {
    return Intl.message(
      'Also delete media received in this chat from the device gallery',
      name: 'alsoDeleteMediaReceivedInThisChatFromTheDeviceGallery',
      desc: '',
      args: [],
    );
  }

  /// `Member`
  String get member {
    return Intl.message('Member', name: 'member', desc: '', args: []);
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `View Contact`
  String get viewContact {
    return Intl.message(
      'View Contact',
      name: 'viewContact',
      desc: '',
      args: [],
    );
  }

  /// `View Group`
  String get viewGroup {
    return Intl.message('View Group', name: 'viewGroup', desc: '', args: []);
  }

  /// `Media, links, and docs`
  String get mediaLinksAndDocs {
    return Intl.message(
      'Media, links, and docs',
      name: 'mediaLinksAndDocs',
      desc: '',
      args: [],
    );
  }

  /// `Message removed from starred messages!`
  String get messageRemovedFromStarredMessages {
    return Intl.message(
      'Message removed from starred messages!',
      name: 'messageRemovedFromStarredMessages',
      desc: '',
      args: [],
    );
  }

  /// `Message added to starred messages!`
  String get messageAddedToStarredMessages {
    return Intl.message(
      'Message added to starred messages!',
      name: 'messageAddedToStarredMessages',
      desc: '',
      args: [],
    );
  }

  /// `Please enable location services!`
  String get pleaseEnableLocationServices {
    return Intl.message(
      'Please enable location services!',
      name: 'pleaseEnableLocationServices',
      desc: '',
      args: [],
    );
  }

  /// `Please add a question`
  String get pleaseAddAQuestion {
    return Intl.message(
      'Please add a question',
      name: 'pleaseAddAQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Fill at least two options`
  String get fillAtLeastTwoOptions {
    return Intl.message(
      'Fill at least two options',
      name: 'fillAtLeastTwoOptions',
      desc: '',
      args: [],
    );
  }

  /// `Options must be unique`
  String get optionsMustBeUnique {
    return Intl.message(
      'Options must be unique',
      name: 'optionsMustBeUnique',
      desc: '',
      args: [],
    );
  }

  /// `Swipe Left To Cancel`
  String get swipeLeftToCancel {
    return Intl.message(
      'Swipe Left To Cancel',
      name: 'swipeLeftToCancel',
      desc: '',
      args: [],
    );
  }

  /// `Tap and hold on a message to star it, and it will show up here.`
  String get tapAndHoldOnAMessageToStarItAndItWillShowUpHere {
    return Intl.message(
      'Tap and hold on a message to star it, and it will show up here.',
      name: 'tapAndHoldOnAMessageToStarItAndItWillShowUpHere',
      desc: '',
      args: [],
    );
  }

  /// `Make Private`
  String get makePrivate {
    return Intl.message(
      'Make Private',
      name: 'makePrivate',
      desc: '',
      args: [],
    );
  }

  /// `It can view or Join with invite`
  String get itCanViewOrJoinWithInvite {
    return Intl.message(
      'It can view or Join with invite',
      name: 'itCanViewOrJoinWithInvite',
      desc: '',
      args: [],
    );
  }

  /// `Admin Only`
  String get adminOnly {
    return Intl.message('Admin Only', name: 'adminOnly', desc: '', args: []);
  }

  /// `Only Admins can share content`
  String get onlyAdminsCanShareContent {
    return Intl.message(
      'Only Admins can share content',
      name: 'onlyAdminsCanShareContent',
      desc: '',
      args: [],
    );
  }

  /// `Media`
  String get media {
    return Intl.message('Media', name: 'media', desc: '', args: []);
  }

  /// `No Media`
  String get noMedia {
    return Intl.message('No Media', name: 'noMedia', desc: '', args: []);
  }

  /// `Links`
  String get links {
    return Intl.message('Links', name: 'links', desc: '', args: []);
  }

  /// `No Links`
  String get noLinks {
    return Intl.message('No Links', name: 'noLinks', desc: '', args: []);
  }

  /// `No Docs`
  String get noDocs {
    return Intl.message('No Docs', name: 'noDocs', desc: '', args: []);
  }

  /// `Pick a location`
  String get pickALocation {
    return Intl.message(
      'Pick a location',
      name: 'pickALocation',
      desc: '',
      args: [],
    );
  }

  /// `ID`
  String get iD {
    return Intl.message('ID', name: 'iD', desc: '', args: []);
  }

  /// `Friend`
  String get friend {
    return Intl.message('Friend', name: 'friend', desc: '', args: []);
  }

  /// `Family`
  String get family {
    return Intl.message('Family', name: 'family', desc: '', args: []);
  }

  /// `Education Certificate`
  String get educationCertificate {
    return Intl.message(
      'Education Certificate',
      name: 'educationCertificate',
      desc: '',
      args: [],
    );
  }

  /// `ID Photo`
  String get iDPhoto {
    return Intl.message('ID Photo', name: 'iDPhoto', desc: '', args: []);
  }

  /// `Enter The First Name`
  String get enterTheFirstName {
    return Intl.message(
      'Enter The First Name',
      name: 'enterTheFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Middle Name`
  String get enterTheMiddleName {
    return Intl.message(
      'Enter The Middle Name',
      name: 'enterTheMiddleName',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Last Name`
  String get enterTheLastName {
    return Intl.message(
      'Enter The Last Name',
      name: 'enterTheLastName',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Arabic First Name`
  String get enterTheArabicFirstName {
    return Intl.message(
      'Enter The Arabic First Name',
      name: 'enterTheArabicFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Arabic Middle Name`
  String get enterTheArabicMiddleName {
    return Intl.message(
      'Enter The Arabic Middle Name',
      name: 'enterTheArabicMiddleName',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Arabic Last Name`
  String get enterTheArabicLastName {
    return Intl.message(
      'Enter The Arabic Last Name',
      name: 'enterTheArabicLastName',
      desc: '',
      args: [],
    );
  }

  /// `Enter The National ID`
  String get enterTheNationalID {
    return Intl.message(
      'Enter The National ID',
      name: 'enterTheNationalID',
      desc: '',
      args: [],
    );
  }

  /// `Enter The National ID Expiration Date`
  String get enterTheNationalIDExpirationDate {
    return Intl.message(
      'Enter The National ID Expiration Date',
      name: 'enterTheNationalIDExpirationDate',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Email`
  String get enterTheEmail {
    return Intl.message(
      'Enter The Email',
      name: 'enterTheEmail',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Country`
  String get enterTheCountry {
    return Intl.message(
      'Enter The Country',
      name: 'enterTheCountry',
      desc: '',
      args: [],
    );
  }

  /// `Enter The City`
  String get enterTheCity {
    return Intl.message(
      'Enter The City',
      name: 'enterTheCity',
      desc: '',
      args: [],
    );
  }

  /// `Enter The State Or Province`
  String get enterTheStateOrProvince {
    return Intl.message(
      'Enter The State Or Province',
      name: 'enterTheStateOrProvince',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Postal Code`
  String get enterThePostalCode {
    return Intl.message(
      'Enter The Postal Code',
      name: 'enterThePostalCode',
      desc: '',
      args: [],
    );
  }

  /// `Arabic`
  String get arabic {
    return Intl.message('Arabic', name: 'arabic', desc: '', args: []);
  }

  /// `Mandarin Chinese`
  String get mandarinChinese {
    return Intl.message(
      'Mandarin Chinese',
      name: 'mandarinChinese',
      desc: '',
      args: [],
    );
  }

  /// `Hindi`
  String get hindi {
    return Intl.message('Hindi', name: 'hindi', desc: '', args: []);
  }

  /// `Martial Service Proof`
  String get martialServiceProof {
    return Intl.message(
      'Martial Service Proof',
      name: 'martialServiceProof',
      desc: '',
      args: [],
    );
  }

  /// `Driving License`
  String get drivingLicense {
    return Intl.message(
      'Driving License',
      name: 'drivingLicense',
      desc: '',
      args: [],
    );
  }

  /// `Marital Certificate`
  String get maritalCertificate {
    return Intl.message(
      'Marital Certificate',
      name: 'maritalCertificate',
      desc: '',
      args: [],
    );
  }

  /// `Life Insurance Card`
  String get lifeInsuranceCard {
    return Intl.message(
      'Life Insurance Card',
      name: 'lifeInsuranceCard',
      desc: '',
      args: [],
    );
  }

  /// `Saturday`
  String get saturday {
    return Intl.message('Saturday', name: 'saturday', desc: '', args: []);
  }

  /// `Sunday`
  String get sunday {
    return Intl.message('Sunday', name: 'sunday', desc: '', args: []);
  }

  /// `Monday`
  String get monday {
    return Intl.message('Monday', name: 'monday', desc: '', args: []);
  }

  /// `Tuesday`
  String get tuesday {
    return Intl.message('Tuesday', name: 'tuesday', desc: '', args: []);
  }

  /// `Wednesday`
  String get wednesday {
    return Intl.message('Wednesday', name: 'wednesday', desc: '', args: []);
  }

  /// `Thursday`
  String get thursday {
    return Intl.message('Thursday', name: 'thursday', desc: '', args: []);
  }

  /// `Friday`
  String get friday {
    return Intl.message('Friday', name: 'friday', desc: '', args: []);
  }

  /// `CEO`
  String get cEO {
    return Intl.message('CEO', name: 'cEO', desc: '', args: []);
  }

  /// `General Manager`
  String get generalManager {
    return Intl.message(
      'General Manager',
      name: 'generalManager',
      desc: '',
      args: [],
    );
  }

  /// `Team Lead`
  String get teamLead {
    return Intl.message('Team Lead', name: 'teamLead', desc: '', args: []);
  }

  /// `Title In Arabic`
  String get titleInArabic {
    return Intl.message(
      'Title In Arabic',
      name: 'titleInArabic',
      desc: '',
      args: [],
    );
  }

  /// `Job Type`
  String get jobType {
    return Intl.message('Job Type', name: 'jobType', desc: '', args: []);
  }

  /// `Fixed`
  String get fixed {
    return Intl.message('Fixed', name: 'fixed', desc: '', args: []);
  }

  /// `Hourly`
  String get hourly {
    return Intl.message('Hourly', name: 'hourly', desc: '', args: []);
  }

  /// `Fixed + Bonus`
  String get fixedBonus {
    return Intl.message(
      'Fixed + Bonus',
      name: 'fixedBonus',
      desc: '',
      args: [],
    );
  }

  /// `Compensation`
  String get compensation {
    return Intl.message(
      'Compensation',
      name: 'compensation',
      desc: '',
      args: [],
    );
  }

  /// `USD`
  String get uSD {
    return Intl.message('USD', name: 'uSD', desc: '', args: []);
  }

  /// `EGP`
  String get eGP {
    return Intl.message('EGP', name: 'eGP', desc: '', args: []);
  }

  /// `EUR`
  String get eUR {
    return Intl.message('EUR', name: 'eUR', desc: '', args: []);
  }

  /// `Enter The Work Days`
  String get enterTheWorkDays {
    return Intl.message(
      'Enter The Work Days',
      name: 'enterTheWorkDays',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Employee ID`
  String get invalidEmployeeID {
    return Intl.message(
      'Invalid Employee ID',
      name: 'invalidEmployeeID',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Country Name`
  String get invalidCountryName {
    return Intl.message(
      'Invalid Country Name',
      name: 'invalidCountryName',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Province`
  String get invalidProvince {
    return Intl.message(
      'Invalid Province',
      name: 'invalidProvince',
      desc: '',
      args: [],
    );
  }

  /// `Invalid City`
  String get invalidCity {
    return Intl.message(
      'Invalid City',
      name: 'invalidCity',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Street`
  String get invalidStreet {
    return Intl.message(
      'Invalid Street',
      name: 'invalidStreet',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Language`
  String get invalidLanguage {
    return Intl.message(
      'Invalid Language',
      name: 'invalidLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Kindly enter the name of the department to complete the assignment.`
  String get kindlyEnterTheNameOfTheDepartmentToCompleteTheAssignmen {
    return Intl.message(
      'Kindly enter the name of the department to complete the assignment.',
      name: 'kindlyEnterTheNameOfTheDepartmentToCompleteTheAssignmen',
      desc: '',
      args: [],
    );
  }

  /// `Please provide the department name in Arabic for bilingual consistency.`
  String get pleaseProvideTheDepartmentNameInArabicForBilingualConsi {
    return Intl.message(
      'Please provide the department name in Arabic for bilingual consistency.',
      name: 'pleaseProvideTheDepartmentNameInArabicForBilingualConsi',
      desc: '',
      args: [],
    );
  }

  /// `This field accepts Arabic only. Please provide your entry in Arabic script; entries in any other language cannot be accepted`
  String get thisFieldAcceptsArabicOnlyPleaseProvideYourEntryInArabi2 {
    return Intl.message(
      'This field accepts Arabic only. Please provide your entry in Arabic script; entries in any other language cannot be accepted',
      name: 'thisFieldAcceptsArabicOnlyPleaseProvideYourEntryInArabi2',
      desc: '',
      args: [],
    );
  }

  /// `Kindly assign a role to the employee. This is a required field for access permissions.`
  String get kindlyAssignARoleToTheEmployeeThisIsARequiredFieldForAc {
    return Intl.message(
      'Kindly assign a role to the employee. This is a required field for access permissions.',
      name: 'kindlyAssignARoleToTheEmployeeThisIsARequiredFieldForAc',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the employee's job title. It is essential for internal designation`
  String get pleaseEnterTheEmployeeSJobTitleItIsEssentialForInternal {
    return Intl.message(
      'Please enter the employee\'s job title. It is essential for internal designation',
      name: 'pleaseEnterTheEmployeeSJobTitleItIsEssentialForInternal',
      desc: '',
      args: [],
    );
  }

  /// `Kindly provide the Arabic translation of the job title for bilingual records`
  String get kindlyProvideTheArabicTranslationOfTheJobTitleForBiling {
    return Intl.message(
      'Kindly provide the Arabic translation of the job title for bilingual records',
      name: 'kindlyProvideTheArabicTranslationOfTheJobTitleForBiling',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Work Location`
  String get invalidWorkLocation {
    return Intl.message(
      'Invalid Work Location',
      name: 'invalidWorkLocation',
      desc: '',
      args: [],
    );
  }

  /// `Department Name Required.`
  String get departmentNameRequired {
    return Intl.message(
      'Department Name Required.',
      name: 'departmentNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Arabic Department Name Missing`
  String get arabicDepartmentNameMissing {
    return Intl.message(
      'Arabic Department Name Missing',
      name: 'arabicDepartmentNameMissing',
      desc: '',
      args: [],
    );
  }

  /// `Role Not Assigned`
  String get roleNotAssigned {
    return Intl.message(
      'Role Not Assigned',
      name: 'roleNotAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Job Title Missing`
  String get jobTitleMissing {
    return Intl.message(
      'Job Title Missing',
      name: 'jobTitleMissing',
      desc: '',
      args: [],
    );
  }

  /// `Arabic Job Title Required`
  String get arabicJobTitleRequired {
    return Intl.message(
      'Arabic Job Title Required',
      name: 'arabicJobTitleRequired',
      desc: '',
      args: [],
    );
  }

  /// `You have unsaved changes. Do you want to save them?`
  String get youHaveUnsavedChangesDoYouWantToSaveThem {
    return Intl.message(
      'You have unsaved changes. Do you want to save them?',
      name: 'youHaveUnsavedChangesDoYouWantToSaveThem',
      desc: '',
      args: [],
    );
  }

  /// `Data has been saved successfully`
  String get dataHasBeenSavedSuccessfully {
    return Intl.message(
      'Data has been saved successfully',
      name: 'dataHasBeenSavedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Un Successful`
  String get unSuccessful {
    return Intl.message(
      'Un Successful',
      name: 'unSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Clear Filter`
  String get clearFilter {
    return Intl.message(
      'Clear Filter',
      name: 'clearFilter',
      desc: '',
      args: [],
    );
  }

  /// `Export Details`
  String get exportDetails {
    return Intl.message(
      'Export Details',
      name: 'exportDetails',
      desc: '',
      args: [],
    );
  }

  /// `matches`
  String get matches {
    return Intl.message('matches', name: 'matches', desc: '', args: []);
  }

  /// `Matches`
  String get matches2 {
    return Intl.message('Matches', name: 'matches2', desc: '', args: []);
  }

  /// `Search employee...`
  String get searchEmployee {
    return Intl.message(
      'Search employee...',
      name: 'searchEmployee',
      desc: '',
      args: [],
    );
  }

  /// `No matches found`
  String get noMatchesFound {
    return Intl.message(
      'No matches found',
      name: 'noMatchesFound',
      desc: '',
      args: [],
    );
  }

  /// `Choose which backup you want to restore`
  String get chooseWhichBackupYouWantToRestore {
    return Intl.message(
      'Choose which backup you want to restore',
      name: 'chooseWhichBackupYouWantToRestore',
      desc: '',
      args: [],
    );
  }

  /// `Second Backup`
  String get secondBackup {
    return Intl.message(
      'Second Backup',
      name: 'secondBackup',
      desc: '',
      args: [],
    );
  }

  /// `First Backup`
  String get firstBackup {
    return Intl.message(
      'First Backup',
      name: 'firstBackup',
      desc: '',
      args: [],
    );
  }

  /// `Removing Employee`
  String get removingEmployee {
    return Intl.message(
      'Removing Employee',
      name: 'removingEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Remove This Employee?`
  String get areYouSureYouWantToRemoveThisEmployee {
    return Intl.message(
      'Are You Sure You Want To Remove This Employee?',
      name: 'areYouSureYouWantToRemoveThisEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Employee Removed`
  String get employeeRemoved {
    return Intl.message(
      'Employee Removed',
      name: 'employeeRemoved',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Removed Employee`
  String get youSuccessfullyRemovedEmployee {
    return Intl.message(
      'You Successfully Removed Employee',
      name: 'youSuccessfullyRemovedEmployee',
      desc: '',
      args: [],
    );
  }

  /// `The data for this field is empty.`
  String get theDataForThisFieldIsEmpty {
    return Intl.message(
      'The data for this field is empty.',
      name: 'theDataForThisFieldIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `No system logs found`
  String get noSystemLogsFound {
    return Intl.message(
      'No system logs found',
      name: 'noSystemLogsFound',
      desc: '',
      args: [],
    );
  }

  /// `Document Rejected`
  String get documentFileRejected {
    return Intl.message(
      'Document Rejected',
      name: 'documentFileRejected',
      desc: '',
      args: [],
    );
  }

  /// `The document has been rejected successfully`
  String get documentRemoveSuccess {
    return Intl.message(
      'The document has been rejected successfully',
      name: 'documentRemoveSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Knowledge Hub Permissions`
  String get knowledgeHubPermissions {
    return Intl.message(
      'Knowledge Hub Permissions',
      name: 'knowledgeHubPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Approval`
  String get approval {
    return Intl.message('Approval', name: 'approval', desc: '', args: []);
  }

  /// `Create Knowledge Hub`
  String get createKnowledgeHub {
    return Intl.message(
      'Create Knowledge Hub',
      name: 'createKnowledgeHub',
      desc: '',
      args: [],
    );
  }

  /// `Select Owning Department`
  String get selectOwningDepartment {
    return Intl.message(
      'Select Owning Department',
      name: 'selectOwningDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Download Documents`
  String get downloadDocuments {
    return Intl.message(
      'Download Documents',
      name: 'downloadDocuments',
      desc: '',
      args: [],
    );
  }

  /// `View Documents`
  String get viewDocuments {
    return Intl.message(
      'View Documents',
      name: 'viewDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Allows Removing Documents Owned By Anyone`
  String get allowsRemovingDocumentsOwnedByAnyone {
    return Intl.message(
      'Allows Removing Documents Owned By Anyone',
      name: 'allowsRemovingDocumentsOwnedByAnyone',
      desc: '',
      args: [],
    );
  }

  /// `Edit Document With Approval`
  String get editDocumentWithApproval {
    return Intl.message(
      'Edit Document With Approval',
      name: 'editDocumentWithApproval',
      desc: '',
      args: [],
    );
  }

  /// `Edit Document Without Approval`
  String get editDocumentWithoutApproval {
    return Intl.message(
      'Edit Document Without Approval',
      name: 'editDocumentWithoutApproval',
      desc: '',
      args: [],
    );
  }

  /// `Remove Documents`
  String get removeDocuments {
    return Intl.message(
      'Remove Documents',
      name: 'removeDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Export Statistics Table`
  String get exportStatisticsTable {
    return Intl.message(
      'Export Statistics Table',
      name: 'exportStatisticsTable',
      desc: '',
      args: [],
    );
  }

  /// `Action Failed`
  String get actionFailed {
    return Intl.message(
      'Action Failed',
      name: 'actionFailed',
      desc: '',
      args: [],
    );
  }

  /// `Activate Policies`
  String get activatePolicies {
    return Intl.message(
      'Activate Policies',
      name: 'activatePolicies',
      desc: '',
      args: [],
    );
  }

  /// `Add at least one row`
  String get addAtLeastOneRow {
    return Intl.message(
      'Add at least one row',
      name: 'addAtLeastOneRow',
      desc: '',
      args: [],
    );
  }

  /// `Add Champion`
  String get addChampion {
    return Intl.message(
      'Add Champion',
      name: 'addChampion',
      desc: '',
      args: [],
    );
  }

  /// `Add Control`
  String get addControl {
    return Intl.message('Add Control', name: 'addControl', desc: '', args: []);
  }

  /// `Add Control Champion`
  String get addControlChampion {
    return Intl.message(
      'Add Control Champion',
      name: 'addControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Add Control Owner`
  String get addControlOwner {
    return Intl.message(
      'Add Control Owner',
      name: 'addControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Add Controller`
  String get addController {
    return Intl.message(
      'Add Controller',
      name: 'addController',
      desc: '',
      args: [],
    );
  }

  /// `Add Owner`
  String get addOwner {
    return Intl.message('Add Owner', name: 'addOwner', desc: '', args: []);
  }

  /// `Adding New Control Champion`
  String get addingNewControlChampion {
    return Intl.message(
      'Adding New Control Champion',
      name: 'addingNewControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Adding New Control Owner`
  String get addingNewControlOwner {
    return Intl.message(
      'Adding New Control Owner',
      name: 'addingNewControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Apply Changes`
  String get applyChanges {
    return Intl.message(
      'Apply Changes',
      name: 'applyChanges',
      desc: '',
      args: [],
    );
  }

  /// `Approve Evidence`
  String get approveEvidence {
    return Intl.message(
      'Approve Evidence',
      name: 'approveEvidence',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to activate these assignments?`
  String get areYouSureYouWantToActivateTheseAssignments {
    return Intl.message(
      'Are you sure you want to activate these assignments?',
      name: 'areYouSureYouWantToActivateTheseAssignments',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to activate these policies?`
  String get areYouSureYouWantToActivateThesePolicies {
    return Intl.message(
      'Are you sure you want to activate these policies?',
      name: 'areYouSureYouWantToActivateThesePolicies',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to add this control champion?`
  String get areYouSureYouWantToAddThisControlChampion {
    return Intl.message(
      'Are you sure you want to add this control champion?',
      name: 'areYouSureYouWantToAddThisControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to add this control owner?`
  String get areYouSureYouWantToAddThisControlOwner {
    return Intl.message(
      'Are you sure you want to add this control owner?',
      name: 'areYouSureYouWantToAddThisControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to approve this evidence?`
  String get areYouSureYouWantToApproveThisEvidence {
    return Intl.message(
      'Are you sure you want to approve this evidence?',
      name: 'areYouSureYouWantToApproveThisEvidence',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to change the status of this module?`
  String get areYouSureYouWantToChangeTheStatusOfThisModule {
    return Intl.message(
      'Are you sure you want to change the status of this module?',
      name: 'areYouSureYouWantToChangeTheStatusOfThisModule',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to create this module?`
  String get areYouSureYouWantToCreateThisModule {
    return Intl.message(
      'Are you sure you want to create this module?',
      name: 'areYouSureYouWantToCreateThisModule',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this GRC module?`
  String get areYouSureYouWantToDeleteThisGrcModule {
    return Intl.message(
      'Are you sure you want to delete this GRC module?',
      name: 'areYouSureYouWantToDeleteThisGrcModule',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to discard this policy?`
  String get areYouSureYouWantToDiscardThisPolicy {
    return Intl.message(
      'Are you sure you want to discard this policy?',
      name: 'areYouSureYouWantToDiscardThisPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to edit controls weight?`
  String get areYouSureYouWantToEditControlsWeight {
    return Intl.message(
      'Are you sure you want to edit controls weight?',
      name: 'areYouSureYouWantToEditControlsWeight',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to edit policies weight?`
  String get areYouSureYouWantToEditPoliciesWeight {
    return Intl.message(
      'Are you sure you want to edit policies weight?',
      name: 'areYouSureYouWantToEditPoliciesWeight',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to edit this module?`
  String get areYouSureYouWantToEditThisModule {
    return Intl.message(
      'Are you sure you want to edit this module?',
      name: 'areYouSureYouWantToEditThisModule',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to edit this policy?`
  String get areYouSureYouWantToEditThisPolicy {
    return Intl.message(
      'Are you sure you want to edit this policy?',
      name: 'areYouSureYouWantToEditThisPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to publish this policy?`
  String get areYouSureYouWantToPublishThisPolicy {
    return Intl.message(
      'Are you sure you want to publish this policy?',
      name: 'areYouSureYouWantToPublishThisPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to reject this document?`
  String get areYouSureYouWantToRejectThisDocument {
    return Intl.message(
      'Are you sure you want to reject this document?',
      name: 'areYouSureYouWantToRejectThisDocument',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to reject this evidence?`
  String get areYouSureYouWantToRejectThisEvidence {
    return Intl.message(
      'Are you sure you want to reject this evidence?',
      name: 'areYouSureYouWantToRejectThisEvidence',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove this control champion?`
  String get areYouSureYouWantToRemoveThisControlChampion {
    return Intl.message(
      'Are you sure you want to remove this control champion?',
      name: 'areYouSureYouWantToRemoveThisControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove this control owner?`
  String get areYouSureYouWantToRemoveThisControlOwner {
    return Intl.message(
      'Are you sure you want to remove this control owner?',
      name: 'areYouSureYouWantToRemoveThisControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to restore this module?`
  String get areYouSureYouWantToRestoreThisModule {
    return Intl.message(
      'Are you sure you want to restore this module?',
      name: 'areYouSureYouWantToRestoreThisModule',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to save these changes?`
  String get areYouSureYouWantToSaveTheseChanges {
    return Intl.message(
      'Are you sure you want to save these changes?',
      name: 'areYouSureYouWantToSaveTheseChanges',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to save this control as a draft?`
  String get areYouSureYouWantToSaveThisControlAsADraft {
    return Intl.message(
      'Are you sure you want to save this control as a draft?',
      name: 'areYouSureYouWantToSaveThisControlAsADraft',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to save this policy as a draft?`
  String get areYouSureYouWantToSaveThisPolicyAsADraft {
    return Intl.message(
      'Are you sure you want to save this policy as a draft?',
      name: 'areYouSureYouWantToSaveThisPolicyAsADraft',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to submit this evidence?`
  String get areYouSureYouWantToSubmitThisEvidence {
    return Intl.message(
      'Are you sure you want to submit this evidence?',
      name: 'areYouSureYouWantToSubmitThisEvidence',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to submit this reassignment request?`
  String get areYouSureYouWantToSubmitThisReassignmentRequest {
    return Intl.message(
      'Are you sure you want to submit this reassignment request?',
      name: 'areYouSureYouWantToSubmitThisReassignmentRequest',
      desc: '',
      args: [],
    );
  }

  /// `Assigned Controls`
  String get assignedControls {
    return Intl.message(
      'Assigned Controls',
      name: 'assignedControls',
      desc: '',
      args: [],
    );
  }

  /// `Assignees Created`
  String get assigneesCreated {
    return Intl.message(
      'Assignees Created',
      name: 'assigneesCreated',
      desc: '',
      args: [],
    );
  }

  /// `Assigning Control`
  String get assigningControl {
    return Intl.message(
      'Assigning Control',
      name: 'assigningControl',
      desc: '',
      args: [],
    );
  }

  /// `Assigning Controls`
  String get assigningControls {
    return Intl.message(
      'Assigning Controls',
      name: 'assigningControls',
      desc: '',
      args: [],
    );
  }

  /// `Assignment Controls`
  String get assignmentControls {
    return Intl.message(
      'Assignment Controls',
      name: 'assignmentControls',
      desc: '',
      args: [],
    );
  }

  /// `Bulk Upload Preview`
  String get bulkUploadPreview {
    return Intl.message(
      'Bulk Upload Preview',
      name: 'bulkUploadPreview',
      desc: '',
      args: [],
    );
  }

  /// `Choose the date`
  String get chooseTheDate {
    return Intl.message(
      'Choose the date',
      name: 'chooseTheDate',
      desc: '',
      args: [],
    );
  }

  /// `Contact Manager`
  String get contactManager {
    return Intl.message(
      'Contact Manager',
      name: 'contactManager',
      desc: '',
      args: [],
    );
  }

  /// `Control Bulk Upload`
  String get controlBulkUpload {
    return Intl.message(
      'Control Bulk Upload',
      name: 'controlBulkUpload',
      desc: '',
      args: [],
    );
  }

  /// `Control Bulk Upload Preview`
  String get controlBulkUploadPreview {
    return Intl.message(
      'Control Bulk Upload Preview',
      name: 'controlBulkUploadPreview',
      desc: '',
      args: [],
    );
  }

  /// `Control Champion`
  String get controlChampion {
    return Intl.message(
      'Control Champion',
      name: 'controlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Control Champion Added`
  String get controlChampionAdded {
    return Intl.message(
      'Control Champion Added',
      name: 'controlChampionAdded',
      desc: '',
      args: [],
    );
  }

  /// `Control Champion Removed`
  String get controlChampionRemoved {
    return Intl.message(
      'Control Champion Removed',
      name: 'controlChampionRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Control champion removed successfully`
  String get controlChampionRemovedSuccessfully {
    return Intl.message(
      'Control champion removed successfully',
      name: 'controlChampionRemovedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Control Created`
  String get controlCreated {
    return Intl.message(
      'Control Created',
      name: 'controlCreated',
      desc: '',
      args: [],
    );
  }

  /// `Control Deleted`
  String get controlDeleted {
    return Intl.message(
      'Control Deleted',
      name: 'controlDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Control description must be written in Arabic`
  String get controlDescriptionMustBeWrittenInArabic {
    return Intl.message(
      'Control description must be written in Arabic',
      name: 'controlDescriptionMustBeWrittenInArabic',
      desc: '',
      args: [],
    );
  }

  /// `Control description must be written in English`
  String get controlDescriptionMustBeWrittenInEnglish {
    return Intl.message(
      'Control description must be written in English',
      name: 'controlDescriptionMustBeWrittenInEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Control Details`
  String get controlDetails {
    return Intl.message(
      'Control Details',
      name: 'controlDetails',
      desc: '',
      args: [],
    );
  }

  /// `Control Document (Arabic)`
  String get controlDocumentAr {
    return Intl.message(
      'Control Document (Arabic)',
      name: 'controlDocumentAr',
      desc: '',
      args: [],
    );
  }

  /// `Control Document (English)`
  String get controlDocumentEng {
    return Intl.message(
      'Control Document (English)',
      name: 'controlDocumentEng',
      desc: '',
      args: [],
    );
  }

  /// `Control name must be written in Arabic`
  String get controlNameMustBeWrittenInArabic {
    return Intl.message(
      'Control name must be written in Arabic',
      name: 'controlNameMustBeWrittenInArabic',
      desc: '',
      args: [],
    );
  }

  /// `Control name must be written in English`
  String get controlNameMustBeWrittenInEnglish {
    return Intl.message(
      'Control name must be written in English',
      name: 'controlNameMustBeWrittenInEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Control number must be written in Arabic`
  String get controlNumberMustBeWrittenInArabic {
    return Intl.message(
      'Control number must be written in Arabic',
      name: 'controlNumberMustBeWrittenInArabic',
      desc: '',
      args: [],
    );
  }

  /// `Control number must be written in English`
  String get controlNumberMustBeWrittenInEnglish {
    return Intl.message(
      'Control number must be written in English',
      name: 'controlNumberMustBeWrittenInEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Control Owner Added`
  String get controlOwnerAdded {
    return Intl.message(
      'Control Owner Added',
      name: 'controlOwnerAdded',
      desc: '',
      args: [],
    );
  }

  /// `Control Owner Removed`
  String get controlOwnerRemoved {
    return Intl.message(
      'Control Owner Removed',
      name: 'controlOwnerRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Control owner removed successfully`
  String get controlOwnerRemovedSuccessfully {
    return Intl.message(
      'Control owner removed successfully',
      name: 'controlOwnerRemovedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Control(s) Created`
  String get controlSCreated {
    return Intl.message(
      'Control(s) Created',
      name: 'controlSCreated',
      desc: '',
      args: [],
    );
  }

  /// `Control saved as draft successfully`
  String get controlSavedAsDraftSuccessfully {
    return Intl.message(
      'Control saved as draft successfully',
      name: 'controlSavedAsDraftSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Control Updated`
  String get controlUpdated {
    return Intl.message(
      'Control Updated',
      name: 'controlUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Control weight cannot be more than 100`
  String get controlWeightCannotBeMoreThan100 {
    return Intl.message(
      'Control weight cannot be more than 100',
      name: 'controlWeightCannotBeMoreThan100',
      desc: '',
      args: [],
    );
  }

  /// `Control Weight Issue`
  String get controlWeightIssue {
    return Intl.message(
      'Control Weight Issue',
      name: 'controlWeightIssue',
      desc: '',
      args: [],
    );
  }

  /// `Control weight must be a positive number`
  String get controlWeightMustBeAPositiveNumber {
    return Intl.message(
      'Control weight must be a positive number',
      name: 'controlWeightMustBeAPositiveNumber',
      desc: '',
      args: [],
    );
  }

  /// `Control weight must be a valid number`
  String get controlWeightMustBeAValidNumber {
    return Intl.message(
      'Control weight must be a valid number',
      name: 'controlWeightMustBeAValidNumber',
      desc: '',
      args: [],
    );
  }

  /// `Controls Updated`
  String get controlsUpdated {
    return Intl.message(
      'Controls Updated',
      name: 'controlsUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Controls updated successfully`
  String get controlsUpdatedSuccessfully {
    return Intl.message(
      'Controls updated successfully',
      name: 'controlsUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Could not read the selected file. Please try again.`
  String get couldNotReadTheSelectedFilePleaseTryAgain {
    return Intl.message(
      'Could not read the selected file. Please try again.',
      name: 'couldNotReadTheSelectedFilePleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Current Control Champion`
  String get currentControlChampion {
    return Intl.message(
      'Current Control Champion',
      name: 'currentControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Current Control Owner`
  String get currentControlOwner {
    return Intl.message(
      'Current Control Owner',
      name: 'currentControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Department Manager`
  String get departmentManager {
    return Intl.message(
      'Department Manager',
      name: 'departmentManager',
      desc: '',
      args: [],
    );
  }

  /// `Description is required`
  String get descriptionIsRequired {
    return Intl.message(
      'Description is required',
      name: 'descriptionIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Description must be written in Arabic`
  String get descriptionMustBeWrittenInArabic {
    return Intl.message(
      'Description must be written in Arabic',
      name: 'descriptionMustBeWrittenInArabic',
      desc: '',
      args: [],
    );
  }

  /// `Discard Policy`
  String get discardPolicy {
    return Intl.message(
      'Discard Policy',
      name: 'discardPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Document Title`
  String get documentTitle {
    return Intl.message(
      'Document Title',
      name: 'documentTitle',
      desc: '',
      args: [],
    );
  }

  /// `Does each department carry a distinct weighting?`
  String get doesEachDepartmentCarryADistinctWeighting {
    return Intl.message(
      'Does each department carry a distinct weighting?',
      name: 'doesEachDepartmentCarryADistinctWeighting',
      desc: '',
      args: [],
    );
  }

  /// `Edit Controls`
  String get editControls {
    return Intl.message(
      'Edit Controls',
      name: 'editControls',
      desc: '',
      args: [],
    );
  }

  /// `Editing Controls Weight`
  String get editingControlsWeight {
    return Intl.message(
      'Editing Controls Weight',
      name: 'editingControlsWeight',
      desc: '',
      args: [],
    );
  }

  /// `Editing Policies Weight`
  String get editingPoliciesWeight {
    return Intl.message(
      'Editing Policies Weight',
      name: 'editingPoliciesWeight',
      desc: '',
      args: [],
    );
  }

  /// `Editing Policy`
  String get editingPolicy {
    return Intl.message(
      'Editing Policy',
      name: 'editingPolicy',
      desc: '',
      args: [],
    );
  }

  /// `End date cannot be after the policy end date`
  String get endDateCannotBeAfterThePolicyEndDate {
    return Intl.message(
      'End date cannot be after the policy end date',
      name: 'endDateCannotBeAfterThePolicyEndDate',
      desc: '',
      args: [],
    );
  }

  /// `End date cannot be before start date`
  String get endDateCannotBeBeforeStartDate {
    return Intl.message(
      'End date cannot be before start date',
      name: 'endDateCannotBeBeforeStartDate',
      desc: '',
      args: [],
    );
  }

  /// `End date cannot be before the policy start date`
  String get endDateCannotBeBeforeThePolicyStartDate {
    return Intl.message(
      'End date cannot be before the policy start date',
      name: 'endDateCannotBeBeforeThePolicyStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Equal Policy Weight`
  String get equalPolicyWeight {
    return Intl.message(
      'Equal Policy Weight',
      name: 'equalPolicyWeight',
      desc: '',
      args: [],
    );
  }

  /// `Equal Weights`
  String get equalWeights {
    return Intl.message(
      'Equal Weights',
      name: 'equalWeights',
      desc: '',
      args: [],
    );
  }

  /// `Evidence Submitted`
  String get evidenceSubmitted {
    return Intl.message(
      'Evidence Submitted',
      name: 'evidenceSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Give a Score`
  String get giveAScore {
    return Intl.message('Give a Score', name: 'giveAScore', desc: '', args: []);
  }

  /// `GRC module name is required`
  String get grcModuleNameIsRequired {
    return Intl.message(
      'GRC module name is required',
      name: 'grcModuleNameIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `GRC module name must be written in Arabic`
  String get grcModuleNameMustBeWrittenInArabic {
    return Intl.message(
      'GRC module name must be written in Arabic',
      name: 'grcModuleNameMustBeWrittenInArabic',
      desc: '',
      args: [],
    );
  }

  /// `GRC Policy Number`
  String get grcPolicyNumber {
    return Intl.message(
      'GRC Policy Number',
      name: 'grcPolicyNumber',
      desc: '',
      args: [],
    );
  }

  /// `History of Control Owners`
  String get historyOfControlOwners {
    return Intl.message(
      'History of Control Owners',
      name: 'historyOfControlOwners',
      desc: '',
      args: [],
    );
  }

  /// `Inquiries`
  String get inquires {
    return Intl.message('Inquiries', name: 'inquires', desc: '', args: []);
  }

  /// `Inquiries coming soon`
  String get inquiriesComingSoon {
    return Intl.message(
      'Inquiries coming soon',
      name: 'inquiriesComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `My Audit`
  String get myAudit {
    return Intl.message('My Audit', name: 'myAudit', desc: '', args: []);
  }

  /// `My Audits`
  String get myAudits {
    return Intl.message('My Audits', name: 'myAudits', desc: '', args: []);
  }

  /// `New champion cannot be the current champion`
  String get newChampionCannotBeTheCurrentChampion {
    return Intl.message(
      'New champion cannot be the current champion',
      name: 'newChampionCannotBeTheCurrentChampion',
      desc: '',
      args: [],
    );
  }

  /// `New Control Champion`
  String get newControlChampion {
    return Intl.message(
      'New Control Champion',
      name: 'newControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `New Control Owner`
  String get newControlOwner {
    return Intl.message(
      'New Control Owner',
      name: 'newControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `New owner cannot be the current owner`
  String get newOwnerCannotBeTheCurrentOwner {
    return Intl.message(
      'New owner cannot be the current owner',
      name: 'newOwnerCannotBeTheCurrentOwner',
      desc: '',
      args: [],
    );
  }

  /// `No approvals in this status`
  String get noApprovalsInThisStatus {
    return Intl.message(
      'No approvals in this status',
      name: 'noApprovalsInThisStatus',
      desc: '',
      args: [],
    );
  }

  /// `No audits in this status`
  String get noAuditsInThisStatus {
    return Intl.message(
      'No audits in this status',
      name: 'noAuditsInThisStatus',
      desc: '',
      args: [],
    );
  }

  /// `No control champions found`
  String get noControlChampionsFound {
    return Intl.message(
      'No control champions found',
      name: 'noControlChampionsFound',
      desc: '',
      args: [],
    );
  }

  /// `No control owners found`
  String get noControlOwnersFound {
    return Intl.message(
      'No control owners found',
      name: 'noControlOwnersFound',
      desc: '',
      args: [],
    );
  }

  /// `No controls assigned`
  String get noControlsAssigned {
    return Intl.message(
      'No controls assigned',
      name: 'noControlsAssigned',
      desc: '',
      args: [],
    );
  }

  /// `No controls in this status`
  String get noControlsInThisStatus {
    return Intl.message(
      'No controls in this status',
      name: 'noControlsInThisStatus',
      desc: '',
      args: [],
    );
  }

  /// `No data rows found in the Excel file`
  String get noDataRowsFoundInTheExcelFile {
    return Intl.message(
      'No data rows found in the Excel file',
      name: 'noDataRowsFoundInTheExcelFile',
      desc: '',
      args: [],
    );
  }

  /// `No GRC modules found`
  String get noGrcModulesFound {
    return Intl.message(
      'No GRC modules found',
      name: 'noGrcModulesFound',
      desc: '',
      args: [],
    );
  }

  /// `No owners assigned`
  String get noOwnersAssigned {
    return Intl.message(
      'No owners assigned',
      name: 'noOwnersAssigned',
      desc: '',
      args: [],
    );
  }

  /// `No people found`
  String get noPeopleFound {
    return Intl.message(
      'No people found',
      name: 'noPeopleFound',
      desc: '',
      args: [],
    );
  }

  /// `No policies found`
  String get noPoliciesFound {
    return Intl.message(
      'No policies found',
      name: 'noPoliciesFound',
      desc: '',
      args: [],
    );
  }

  /// `No previous control owners`
  String get noPreviousControlOwners {
    return Intl.message(
      'No previous control owners',
      name: 'noPreviousControlOwners',
      desc: '',
      args: [],
    );
  }

  /// `No previous module owners`
  String get noPreviousModuleOwners {
    return Intl.message(
      'No previous module owners',
      name: 'noPreviousModuleOwners',
      desc: '',
      args: [],
    );
  }

  /// `No submission was made before the deadline`
  String get noSubmissionWasMadeBeforeTheDeadline {
    return Intl.message(
      'No submission was made before the deadline',
      name: 'noSubmissionWasMadeBeforeTheDeadline',
      desc: '',
      args: [],
    );
  }

  /// `No weight changes`
  String get noWeightChanges {
    return Intl.message(
      'No weight changes',
      name: 'noWeightChanges',
      desc: '',
      args: [],
    );
  }

  /// `Number`
  String get numberLabel {
    return Intl.message('Number', name: 'numberLabel', desc: '', args: []);
  }

  /// `Please assign at least one control`
  String get pleaseAssignAtLeastOneControl {
    return Intl.message(
      'Please assign at least one control',
      name: 'pleaseAssignAtLeastOneControl',
      desc: '',
      args: [],
    );
  }

  /// `Please choose a start date`
  String get pleaseChooseAStartDate {
    return Intl.message(
      'Please choose a start date',
      name: 'pleaseChooseAStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Please drop an Excel file (.xlsx or .xls)`
  String get pleaseDropAnExcelFileXlsxOrXls {
    return Intl.message(
      'Please drop an Excel file (.xlsx or .xls)',
      name: 'pleaseDropAnExcelFileXlsxOrXls',
      desc: '',
      args: [],
    );
  }

  /// `Please fix the highlighted errors before continuing`
  String get pleaseFixTheHighlightedErrorsBeforeContinuing {
    return Intl.message(
      'Please fix the highlighted errors before continuing',
      name: 'pleaseFixTheHighlightedErrorsBeforeContinuing',
      desc: '',
      args: [],
    );
  }

  /// `Please select a control champion`
  String get pleaseSelectAControlChampion {
    return Intl.message(
      'Please select a control champion',
      name: 'pleaseSelectAControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Please select a control owner`
  String get pleaseSelectAControlOwner {
    return Intl.message(
      'Please select a control owner',
      name: 'pleaseSelectAControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Please select a new control champion`
  String get pleaseSelectANewControlChampion {
    return Intl.message(
      'Please select a new control champion',
      name: 'pleaseSelectANewControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Please select a new control owner`
  String get pleaseSelectANewControlOwner {
    return Intl.message(
      'Please select a new control owner',
      name: 'pleaseSelectANewControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Policy(ies) Created`
  String get policYIesCreated {
    return Intl.message(
      'Policy(ies) Created',
      name: 'policYIesCreated',
      desc: '',
      args: [],
    );
  }

  /// `Policy Bulk Upload`
  String get policyBulkUpload {
    return Intl.message(
      'Policy Bulk Upload',
      name: 'policyBulkUpload',
      desc: '',
      args: [],
    );
  }

  /// `Policy Bulk Upload Preview`
  String get policyBulkUploadPreview {
    return Intl.message(
      'Policy Bulk Upload Preview',
      name: 'policyBulkUploadPreview',
      desc: '',
      args: [],
    );
  }

  /// `Policy Created`
  String get policyCreated {
    return Intl.message(
      'Policy Created',
      name: 'policyCreated',
      desc: '',
      args: [],
    );
  }

  /// `Policy Deleted`
  String get policyDeleted {
    return Intl.message(
      'Policy Deleted',
      name: 'policyDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Policy description must be written in English`
  String get policyDescriptionMustBeWrittenInEnglish {
    return Intl.message(
      'Policy description must be written in English',
      name: 'policyDescriptionMustBeWrittenInEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Policy Document (Arabic)`
  String get policyDocumentAr {
    return Intl.message(
      'Policy Document (Arabic)',
      name: 'policyDocumentAr',
      desc: '',
      args: [],
    );
  }

  /// `Policy Document (English)`
  String get policyDocumentEng {
    return Intl.message(
      'Policy Document (English)',
      name: 'policyDocumentEng',
      desc: '',
      args: [],
    );
  }

  /// `Policy number must be written in English`
  String get policyNumberMustBeWrittenInEnglish {
    return Intl.message(
      'Policy number must be written in English',
      name: 'policyNumberMustBeWrittenInEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Policy saved as draft successfully`
  String get policySavedAsDraftSuccessfully {
    return Intl.message(
      'Policy saved as draft successfully',
      name: 'policySavedAsDraftSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Policy saved, but one or more controls failed to save`
  String get policySavedButOneOrMoreControlsFailedToSave {
    return Intl.message(
      'Policy saved, but one or more controls failed to save',
      name: 'policySavedButOneOrMoreControlsFailedToSave',
      desc: '',
      args: [],
    );
  }

  /// `Policy Updated`
  String get policyUpdated {
    return Intl.message(
      'Policy Updated',
      name: 'policyUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Policy weight cannot be more than 100`
  String get policyWeightCannotBeMoreThan100 {
    return Intl.message(
      'Policy weight cannot be more than 100',
      name: 'policyWeightCannotBeMoreThan100',
      desc: '',
      args: [],
    );
  }

  /// `Policy weight must be a positive number`
  String get policyWeightMustBeAPositiveNumber {
    return Intl.message(
      'Policy weight must be a positive number',
      name: 'policyWeightMustBeAPositiveNumber',
      desc: '',
      args: [],
    );
  }

  /// `Policy weight must be a valid number`
  String get policyWeightMustBeAValidNumber {
    return Intl.message(
      'Policy weight must be a valid number',
      name: 'policyWeightMustBeAValidNumber',
      desc: '',
      args: [],
    );
  }

  /// `Previous Module Owners`
  String get previousModuleOwners {
    return Intl.message(
      'Previous Module Owners',
      name: 'previousModuleOwners',
      desc: '',
      args: [],
    );
  }

  /// `Publish Policy`
  String get publishPolicy {
    return Intl.message(
      'Publish Policy',
      name: 'publishPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Reasons of Rejection`
  String get reasonsOfRejectionTitle {
    return Intl.message(
      'Reasons of Rejection',
      name: 'reasonsOfRejectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Reassign Champion`
  String get reassignChampion {
    return Intl.message(
      'Reassign Champion',
      name: 'reassignChampion',
      desc: '',
      args: [],
    );
  }

  /// `Reassign Control Champion Request`
  String get reassignControlChampionRequest {
    return Intl.message(
      'Reassign Control Champion Request',
      name: 'reassignControlChampionRequest',
      desc: '',
      args: [],
    );
  }

  /// `Reassign Control Owner Request`
  String get reassignControlOwnerRequest {
    return Intl.message(
      'Reassign Control Owner Request',
      name: 'reassignControlOwnerRequest',
      desc: '',
      args: [],
    );
  }

  /// `Reassign Owner`
  String get reassignOwner {
    return Intl.message(
      'Reassign Owner',
      name: 'reassignOwner',
      desc: '',
      args: [],
    );
  }

  /// `Reject Document`
  String get rejectDocument {
    return Intl.message(
      'Reject Document',
      name: 'rejectDocument',
      desc: '',
      args: [],
    );
  }

  /// `Reject Evidence`
  String get rejectEvidence {
    return Intl.message(
      'Reject Evidence',
      name: 'rejectEvidence',
      desc: '',
      args: [],
    );
  }

  /// `Remove Control Champion`
  String get removeControlChampion {
    return Intl.message(
      'Remove Control Champion',
      name: 'removeControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Remove Control Owner`
  String get removeControlOwner {
    return Intl.message(
      'Remove Control Owner',
      name: 'removeControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Request Updated`
  String get requestUpdated {
    return Intl.message(
      'Request Updated',
      name: 'requestUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Request Details`
  String get requestsDetails {
    return Intl.message(
      'Request Details',
      name: 'requestsDetails',
      desc: '',
      args: [],
    );
  }

  /// `Restored Modules`
  String get restoredModules {
    return Intl.message(
      'Restored Modules',
      name: 'restoredModules',
      desc: '',
      args: [],
    );
  }

  /// `Save as Draft`
  String get saveAsDraft {
    return Intl.message(
      'Save as Draft',
      name: 'saveAsDraft',
      desc: '',
      args: [],
    );
  }

  /// `Saved as Draft`
  String get savedAsDraft {
    return Intl.message(
      'Saved as Draft',
      name: 'savedAsDraft',
      desc: '',
      args: [],
    );
  }

  /// `Saving...`
  String get saving {
    return Intl.message('Saving...', name: 'saving', desc: '', args: []);
  }

  /// `Select at least one row`
  String get selectAtLeastOneRow {
    return Intl.message(
      'Select at least one row',
      name: 'selectAtLeastOneRow',
      desc: '',
      args: [],
    );
  }

  /// `Select exactly one row to duplicate`
  String get selectExactlyOneRowToDuplicate {
    return Intl.message(
      'Select exactly one row to duplicate',
      name: 'selectExactlyOneRowToDuplicate',
      desc: '',
      args: [],
    );
  }

  /// `Some champion/owner assignments couldn't be saved`
  String get someChampionOwnerAssignmentsCouldnTBeSaved {
    return Intl.message(
      'Some champion/owner assignments couldn\'t be saved',
      name: 'someChampionOwnerAssignmentsCouldnTBeSaved',
      desc: '',
      args: [],
    );
  }

  /// `Start date cannot be after the policy end date`
  String get startDateCannotBeAfterThePolicyEndDate {
    return Intl.message(
      'Start date cannot be after the policy end date',
      name: 'startDateCannotBeAfterThePolicyEndDate',
      desc: '',
      args: [],
    );
  }

  /// `Start date cannot be before the policy start date`
  String get startDateCannotBeBeforeThePolicyStartDate {
    return Intl.message(
      'Start date cannot be before the policy start date',
      name: 'startDateCannotBeBeforeThePolicyStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Submission`
  String get submission {
    return Intl.message('Submission', name: 'submission', desc: '', args: []);
  }

  /// `Submission Note`
  String get submissionNote {
    return Intl.message(
      'Submission Note',
      name: 'submissionNote',
      desc: '',
      args: [],
    );
  }

  /// `Submission Notes`
  String get submissionNotes {
    return Intl.message(
      'Submission Notes',
      name: 'submissionNotes',
      desc: '',
      args: [],
    );
  }

  /// `Submit Evidence`
  String get submitEvidence {
    return Intl.message(
      'Submit Evidence',
      name: 'submitEvidence',
      desc: '',
      args: [],
    );
  }

  /// `The request has been updated successfully`
  String get theRequestHasBeenUpdatedSuccessfully {
    return Intl.message(
      'The request has been updated successfully',
      name: 'theRequestHasBeenUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `This field is required`
  String get thisFieldIsRequired {
    return Intl.message(
      'This field is required',
      name: 'thisFieldIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `This request type is not supported yet`
  String get thisRequestTypeIsNotSupportedYet {
    return Intl.message(
      'This request type is not supported yet',
      name: 'thisRequestTypeIsNotSupportedYet',
      desc: '',
      args: [],
    );
  }

  /// `Total weight should be 100`
  String get totalWeightShouldBe100 {
    return Intl.message(
      'Total weight should be 100',
      name: 'totalWeightShouldBe100',
      desc: '',
      args: [],
    );
  }

  /// `Unable to read the selected file`
  String get unableToReadTheSelectedFile {
    return Intl.message(
      'Unable to read the selected file',
      name: 'unableToReadTheSelectedFile',
      desc: '',
      args: [],
    );
  }

  /// `Upload Control Document (Arabic)`
  String get uploadControlDocumentArabic {
    return Intl.message(
      'Upload Control Document (Arabic)',
      name: 'uploadControlDocumentArabic',
      desc: '',
      args: [],
    );
  }

  /// `Upload Control Document (English)`
  String get uploadControlDocumentEnglish {
    return Intl.message(
      'Upload Control Document (English)',
      name: 'uploadControlDocumentEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Upload Policy Document (Arabic)`
  String get uploadPolicyDocumentArabic {
    return Intl.message(
      'Upload Policy Document (Arabic)',
      name: 'uploadPolicyDocumentArabic',
      desc: '',
      args: [],
    );
  }

  /// `Upload Policy Document (English)`
  String get uploadPolicyDocumentEnglish {
    return Intl.message(
      'Upload Policy Document (English)',
      name: 'uploadPolicyDocumentEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Write a description`
  String get writeADescription {
    return Intl.message(
      'Write a description',
      name: 'writeADescription',
      desc: '',
      args: [],
    );
  }

  /// `You have successfully edited controls weights`
  String get youHaveSuccessfullyEditedControlsWeights {
    return Intl.message(
      'You have successfully edited controls weights',
      name: 'youHaveSuccessfullyEditedControlsWeights',
      desc: '',
      args: [],
    );
  }

  /// `You have successfully edited policies weights`
  String get youHaveSuccessfullyEditedPoliciesWeights {
    return Intl.message(
      'You have successfully edited policies weights',
      name: 'youHaveSuccessfullyEditedPoliciesWeights',
      desc: '',
      args: [],
    );
  }

  /// `You successfully added this control champion`
  String get youSuccessfullyAddedThisControlChampion {
    return Intl.message(
      'You successfully added this control champion',
      name: 'youSuccessfullyAddedThisControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `You successfully added this control owner`
  String get youSuccessfullyAddedThisControlOwner {
    return Intl.message(
      'You successfully added this control owner',
      name: 'youSuccessfullyAddedThisControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `You successfully approved this evidence`
  String get youSuccessfullyApprovedThisEvidence {
    return Intl.message(
      'You successfully approved this evidence',
      name: 'youSuccessfullyApprovedThisEvidence',
      desc: '',
      args: [],
    );
  }

  /// `You successfully created this control`
  String get youSuccessfullyCreatedThisControl {
    return Intl.message(
      'You successfully created this control',
      name: 'youSuccessfullyCreatedThisControl',
      desc: '',
      args: [],
    );
  }

  /// `You successfully created this policy`
  String get youSuccessfullyCreatedThisPolicy {
    return Intl.message(
      'You successfully created this policy',
      name: 'youSuccessfullyCreatedThisPolicy',
      desc: '',
      args: [],
    );
  }

  /// `You successfully deleted this control`
  String get youSuccessfullyDeletedThisControl {
    return Intl.message(
      'You successfully deleted this control',
      name: 'youSuccessfullyDeletedThisControl',
      desc: '',
      args: [],
    );
  }

  /// `You successfully deleted this policy`
  String get youSuccessfullyDeletedThisPolicy {
    return Intl.message(
      'You successfully deleted this policy',
      name: 'youSuccessfullyDeletedThisPolicy',
      desc: '',
      args: [],
    );
  }

  /// `You successfully rejected this evidence`
  String get youSuccessfullyRejectedThisEvidence {
    return Intl.message(
      'You successfully rejected this evidence',
      name: 'youSuccessfullyRejectedThisEvidence',
      desc: '',
      args: [],
    );
  }

  /// `You successfully updated this control`
  String get youSuccessfullyUpdatedThisControl {
    return Intl.message(
      'You successfully updated this control',
      name: 'youSuccessfullyUpdatedThisControl',
      desc: '',
      args: [],
    );
  }

  /// `You successfully updated this policy`
  String get youSuccessfullyUpdatedThisPolicy {
    return Intl.message(
      'You successfully updated this policy',
      name: 'youSuccessfullyUpdatedThisPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Your evidence was submitted successfully`
  String get yourEvidenceWasSubmittedSuccessfully {
    return Intl.message(
      'Your evidence was submitted successfully',
      name: 'yourEvidenceWasSubmittedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Your reassign champion request has been submitted`
  String get yourReassignChampionRequestHasBeenSubmitted {
    return Intl.message(
      'Your reassign champion request has been submitted',
      name: 'yourReassignChampionRequestHasBeenSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Your reassign owner request has been submitted`
  String get yourReassignOwnerRequestHasBeenSubmitted {
    return Intl.message(
      'Your reassign owner request has been submitted',
      name: 'yourReassignOwnerRequestHasBeenSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Changed By`
  String get changedBy {
    return Intl.message('Changed By', name: 'changedBy', desc: '', args: []);
  }

  /// `Control Changes`
  String get controlChanges {
    return Intl.message(
      'Control Changes',
      name: 'controlChanges',
      desc: '',
      args: [],
    );
  }

  /// `Control Weight Current`
  String get controlWeightCurrent {
    return Intl.message(
      'Control Weight Current',
      name: 'controlWeightCurrent',
      desc: '',
      args: [],
    );
  }

  /// `Control Weight Previous`
  String get controlWeightPrevious {
    return Intl.message(
      'Control Weight Previous',
      name: 'controlWeightPrevious',
      desc: '',
      args: [],
    );
  }

  /// `Date Of Action`
  String get dateOfAction {
    return Intl.message(
      'Date Of Action',
      name: 'dateOfAction',
      desc: '',
      args: [],
    );
  }

  /// `In Review`
  String get inReview {
    return Intl.message('In Review', name: 'inReview', desc: '', args: []);
  }

  /// `No of Departments`
  String get noOfDepartments {
    return Intl.message(
      'No of Departments',
      name: 'noOfDepartments',
      desc: '',
      args: [],
    );
  }

  /// `Outstanding`
  String get outstanding {
    return Intl.message('Outstanding', name: 'outstanding', desc: '', args: []);
  }

  /// `Policy Number Ar`
  String get policyNumberAr {
    return Intl.message(
      'Policy Number Ar',
      name: 'policyNumberAr',
      desc: '',
      args: [],
    );
  }

  /// `Policy Weight Current`
  String get policyWeightCurrent {
    return Intl.message(
      'Policy Weight Current',
      name: 'policyWeightCurrent',
      desc: '',
      args: [],
    );
  }

  /// `Policy Weight Previous`
  String get policyWeightPrevious {
    return Intl.message(
      'Policy Weight Previous',
      name: 'policyWeightPrevious',
      desc: '',
      args: [],
    );
  }

  /// `Previous Owner`
  String get previousOwner {
    return Intl.message(
      'Previous Owner',
      name: 'previousOwner',
      desc: '',
      args: [],
    );
  }

  /// `Reassign Control Champion`
  String get reassignControlChampion {
    return Intl.message(
      'Reassign Control Champion',
      name: 'reassignControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Reassign Control Owner`
  String get reassignControlOwner {
    return Intl.message(
      'Reassign Control Owner',
      name: 'reassignControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Resubmit Evidence`
  String get resubmitEvidence {
    return Intl.message(
      'Resubmit Evidence',
      name: 'resubmitEvidence',
      desc: '',
      args: [],
    );
  }

  /// `Scored`
  String get scored {
    return Intl.message('Scored', name: 'scored', desc: '', args: []);
  }

  /// `Submitted`
  String get submitted {
    return Intl.message('Submitted', name: 'submitted', desc: '', args: []);
  }

  /// `Technician`
  String get technician {
    return Intl.message('Technician', name: 'technician', desc: '', args: []);
  }

  /// `Upload Evidence`
  String get uploadEvidence {
    return Intl.message(
      'Upload Evidence',
      name: 'uploadEvidence',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to create this control?`
  String get areYouSureYouWantToCreateThisControl {
    return Intl.message(
      'Are you sure you want to create this control?',
      name: 'areYouSureYouWantToCreateThisControl',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to edit this control?`
  String get areYouSureYouWantToEditThisControl {
    return Intl.message(
      'Are you sure you want to edit this control?',
      name: 'areYouSureYouWantToEditThisControl',
      desc: '',
      args: [],
    );
  }

  /// `Editing Control`
  String get editingControl {
    return Intl.message(
      'Editing Control',
      name: 'editingControl',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
