/// Module: services / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: service_repository.dart
/// Purpose: Abstract repository contract for the services module.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/features/services/domain/entities/approval_decision.dart';
import 'package:knowticed_plus/features/services/data/models/requested_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/models/sla_data_model.dart';

import 'package:knowticed_plus/features/services/domain/entities/parent_service_details.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';

abstract class CreateServicesRepository {
  // ✅ UPDATED: All ServicesModel changed to ServicesHistoryModel
  // Future<void> uploadServices(ServicesHistoryModel services, String departmentId);
  Future<List<ServicesHistoryModel>> getAllServices();
  Future<List<ServicesHistoryModel>> getAllRequestServices();

  /// SVC-HOME-01: only the services a user who does not manage services may
  /// see — open services, services limited to one of [departmentKeys]
  /// (see ServiceVisibility.userKeys) and the user's own services. Restricted
  /// services of other departments are not downloaded.
  Future<List<ServicesHistoryModel>> getVisibleRequestServices(
    List<String> departmentKeys,
  );

  /// A new Firestore auto id for a RequestServices document. Never build
  /// request ids from random numbers (SVC-CREATE-02 / SVC-REQ-01).
  String newRequestServiceId();

  /// Approves or rejects request [docId] for [approverEmail] — the single
  /// implementation used by every screen (SVC-REQ-05/06). Throws
  /// [ApprovalNotAllowed] when the request is not pending or it is not this
  /// approver's turn.
  Future<ApprovalDecision> decideApproval({
    required String docId,
    required String approverEmail,
    required bool approve,
    required String comment,
  });

  /// Creates a NEW CreateServices document; throws if [docId] already exists,
  /// so a new service can never overwrite another one (SVC-CREATE-03).
  Future<void> createService(String docId, ServicesHistoryModel model);

  /// Saves a new request in ONE batch: the record under the parent service
  /// and the request document itself (SVC-REQ-09). Throws if the parent
  /// service does not exist.
  Future<void> createRequest({
    required String parentServiceId,
    required String requestDocId,
    required Map<String, dynamic> requestData,
    required Map<String, dynamic> serviceRecord,
  });
  Future<void> deleteService(String innerDocId);
  Future<ServicesHistoryModel?> getServiceById(
    String departmentId,
    String serviceId,
  );
  Future<List<ServicesHistoryModel>> getMyRequestServices();
  Future<void> editService(String docId, ServicesHistoryModel updatedModel);
  Future<void> deleteMyRequest(String departmentId, String innerDocId);
  Future<List<ServicesHistoryModel>> getApprovalServices(String departmentId);
  Future<void> updateApprovalState({
    required String docID,
    required String email,
    required String newState,
  });
  Future<Map<String, Map<String, dynamic>>> getServiceProviderPerDoc();
  Future<void> addRequestedService({
    required String docId,
    required RequestedServices requestModel,
    required String uidUser,
  });
  Future<List<RequestedServices>> getRequestedServices({required String docId});

  // Firebase services
  Future<List<ServicesHistoryModel>> getFirebaseServices();

  // Local drafts from SharedPreferences
  Future<List<ServicesHistoryModel>> getLocalDrafts();

  // All CreateServices docs where the given email is a requester (for duplicate
  // checks / status lookups done in the create flow).
  Future<List<ServicesHistoryModel>> getServicesByRequesterEmail(String email);

  // Raw write helpers used by the bulk/master upload flow (keeps Firestore out
  // of the services_management_module — the page builds the map, the repo persists it).
  Future<void> setRequestServiceDoc(String docId, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getRequestServiceDocById(String docId);
  Future<void> updateRequestServiceDoc(String docId, Map<String, dynamic> data);

  /// Updates the assigned provider on a request-service doc and appends a
  /// timestamp entry. Keeps Firestore-specific value types (e.g. array-union)
  /// out of the presentation layer.
  Future<void> updateAssignedProvider({
    required String docId,
    required String providerEmail,
    required String providerJson,
  });

  /// All RequestServices docs as (id -> data) entries (raw, for dashboard
  /// aggregation that needs the document id alongside the data).
  Future<List<MapEntry<String, Map<String, dynamic>>>>
      getAllRequestServiceDocs();

  /// SVC-PROV-22: the RequestServices docs whose provider history contains
  /// [providerEmail] (not every request of the company).
  Future<List<MapEntry<String, Map<String, dynamic>>>>
      getRequestServiceDocsForProvider(String providerEmail);

  /// SVC-PROV-06: moves a request approved → inprogress → done in one
  /// transaction; throws StatusChangeRefused when the move is not allowed
  /// from the request's current status.
  Future<void> advanceRequestState({
    required String requestId,
    required String newState,
  });

  /// Most-recent RequestServices docs (ordered by timestamps desc, limited).
  Future<List<MapEntry<String, Map<String, dynamic>>>>
      getRecentRequestServiceDocs({required int limit});
  Future<Map<String, dynamic>?> getCreateServiceDoc(String docId);

  // Services collection (SLA draft docs).
  Future<Map<String, dynamic>?> getServicesDoc(String docId);
  Future<void> setServicesDoc(
    String docId,
    Map<String, dynamic> data, {
    bool merge,
  });
  Future<void> setCreateServiceDoc(String docId, Map<String, dynamic> data);
  Future<void> updateCreateServiceDoc(String docId, Map<String, dynamic> data);
  Future<void> deleteCreateServiceDoc(String docId);

  /// Generates a new (client-side) CreateServices document id without writing.
  String newCreateServiceId();

  // Count 'done' request services grouped by their Parent_Service_Id (handles
  // the array-typed Parent_Service_Id / state fields used by request docs).
  Future<Map<String, int>> getDoneServicesCountByParent();

  // Extract providers' info from services
  Future<Map<String, Map<String, dynamic>>> getSelectedProviders(
    List<ServicesHistoryModel> services,
  );

  // Check if service name already exists
  Future<bool> checkDuplicateServiceName(String name);

  // Save service form data to SharedPreferences (as draft)
  Future<void> saveServiceToPrefs(ServicesHistoryModel model);

  // Load service model into SharedPrefs (for editing)
  Future<void> loadServiceToFormControllers(ServicesHistoryModel model);

  // Update service status (active/inactive)
  Future<void> updateServiceStatus(String docId, bool isActive);

  // Fetch current service status
  Future<String?> getServiceStatus(String docId);

  // // Fetch all employees
  // Future<List<EmployeeEntityPro>> getAllEmployees();

  // Load SLA and notification values from SharedPreferences
  Future<SlaDataModel> loadFromSharedPrefs();

  // Save draft
  Future<void> saveDraft(ServicesHistoryModel model);

  // Update draft if editing existing one
  Future<void> updateDraft(
    ServicesHistoryModel oldModel,
    ServicesHistoryModel newModel,
  );

  // Remove draft after submission
  Future<void> removeDraftById(String id);

  // Submit service to Firestore
  Future<void> saveService(String docId, ServicesHistoryModel model);

  // Update existing submitted service
  Future<void> updateService(String docId, ServicesHistoryModel model);

  // Save SLA configuration to SharedPreferences
  Future<void> saveSlaToPrefs({
    required String slaOne,
    required String slaTwo,
    required bool notifyRequesterChecked,
    required bool notifyProviderChecked,
    required bool notifyManagerChecked,
    required bool notifyRequesterSwitch0,
    required bool notifyManagerSwitch1,
    required List<String> extraSlaList,
    required List<String> extraSlaTwoList,
    required Map<String, Map<int, bool>> notificationSwitches,
  });

  // Select service provider
  Future<Map<String, dynamic>?> selectServiceProvider(String serviceId);

  // Fetch a raw service document (services collection) by id
  Future<Map<String, dynamic>?> getServiceDocById(String serviceId);

  // Requested services where the given email is a requester (for count aggregation)
  Future<List<ServicesHistoryModel>> getMyRequestServicesByRequester(
    String? email,
  );

  // Append a state + timestamp to the request doc identified by id + requester email
  Future<void> appendRequestState({
    required String serviceId,
    required String? requesterEmail,
    required String newState,
  });

  // Fetch a user document (users collection) by email
  Future<Map<String, dynamic>?> getUserByEmail(String email);

  /// Function Name: [resolveRequestProvider]
  ///
  /// Purpose: The provider of [request]; assigns and saves the least busy
  /// provider when none was assigned yet.
  ///
  /// Parameters:
  /// - [request]: the request.
  ///
  /// Returns: the provider, or null when there is none.
  Future<ServiceEmployeeModel?> resolveRequestProvider(
    ServicesHistoryModel request,
  );

  /// Function Name: [getParentServiceDetails]
  ///
  /// Purpose: The current name, description, duration and image of the
  /// service a request was made for.
  ///
  /// Parameters:
  /// - [parentServiceId]: the CreateServices document id.
  ///
  /// Returns: the details, or [ParentServiceDetails.empty] when the service
  /// no longer exists. Read errors are thrown.
  Future<ParentServiceDetails> getParentServiceDetails(String parentServiceId);

  // Fetch a raw CreateServices doc (Demo/{companyId}/Modules/services/CreateServices/{id}) by id
  Future<Map<String, dynamic>?> getCreateServiceDocById(String serviceId);

  /// All CreateServices docs (raw), for building the dashboard's service
  /// dropdown and resolving parent-service names by id.
  Future<List<Map<String, dynamic>>> getAllCreateServiceDocs();

  /// Every CreateServices document as (id -> data) entries (dashboards group
  /// requests by service id).
  Future<List<MapEntry<String, Map<String, dynamic>>>>
      getCreateServiceDocEntries();

  /// A single CreateServices doc (raw) by id, resolved under the tenant's
  /// CreateServices root (`getBaseUrl(FirestoreCollections.createServicesRoot)`).
  /// Used to resolve a request's parent-service name when the request doc
  /// doesn't carry it directly.
  Future<Map<String, dynamic>?> getCreateServiceDocByIdUnderTenantRoot(
    String parentId,
  );
}
