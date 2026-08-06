// Module Permission Models - Based on your exact 6 modules with detailed permissions
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

// Base class for all module permissions
abstract class BaseModulePermission {
  final List<int> timestamps;
  final String roleId;

  BaseModulePermission({
    required this.timestamps,
    required this.roleId,
  });

  Map<String, dynamic> toMap();
  int? get currentTimestamp => timestamps.isNotEmpty ? timestamps.last : null;

  // Helper methods for all classes
  static List<int> _parseTimestamps(dynamic value) {
    if (value == null) return [DateTime.now().millisecondsSinceEpoch];
    if (value is List) return value.map((e) => e is int ? e : (e as num).toInt()).toList();
    return [DateTime.now().millisecondsSinceEpoch];
  }

  static List<bool> _parseBoolList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e == true).toList();
    return [value == true];
  }
}

// 1. Messages Module Permissions
class MessagesModulePermission extends BaseModulePermission {
  // Messages Permissions
  final List<bool> createGroup;
  final List<bool> seenAndUnseen;
  final List<bool> editMessage;
  final List<bool> deleteMessage;
  final List<bool> reactions;
  final List<bool> forwardMessages;

  // More Permissions
  final List<bool> contact;
  final List<bool> location;
  final List<bool> photo;
  final List<bool> documents;
  final List<bool> poll;
  final List<bool> muteNotifications;
  final List<bool> disappearingMessages;
  final List<bool> scheduleMessages;

  MessagesModulePermission({
    required super.timestamps,
    required super.roleId,
    required this.createGroup,
    required this.seenAndUnseen,
    required this.editMessage,
    required this.deleteMessage,
    required this.reactions,
    required this.forwardMessages,
    required this.contact,
    required this.location,
    required this.photo,
    required this.documents,
    required this.poll,
    required this.muteNotifications,
    required this.disappearingMessages,
    required this.scheduleMessages,
  });

  // Current values getters
  bool get currentCreateGroup => createGroup.isNotEmpty ? createGroup.last : false;
  bool get currentSeenAndUnseen => seenAndUnseen.isNotEmpty ? seenAndUnseen.last : false;
  bool get currentEditMessage => editMessage.isNotEmpty ? editMessage.last : false;
  bool get currentDeleteMessage => deleteMessage.isNotEmpty ? deleteMessage.last : false;
  bool get currentReactions => reactions.isNotEmpty ? reactions.last : false;
  bool get currentForwardMessages => forwardMessages.isNotEmpty ? forwardMessages.last : false;
  bool get currentContact => contact.isNotEmpty ? contact.last : false;
  bool get currentLocation => location.isNotEmpty ? location.last : false;
  bool get currentPhoto => photo.isNotEmpty ? photo.last : false;
  bool get currentDocuments => documents.isNotEmpty ? documents.last : false;
  bool get currentPoll => poll.isNotEmpty ? poll.last : false;
  bool get currentMuteNotifications => muteNotifications.isNotEmpty ? muteNotifications.last : false;
  bool get currentDisappearingMessages => disappearingMessages.isNotEmpty ? disappearingMessages.last : false;
  bool get currentScheduleMessages => scheduleMessages.isNotEmpty ? scheduleMessages.last : false;

  static const String ROLE_ID_KEY = 'Role_Id';
  static const String CREATE_GROUP_KEY = 'Create_Group';
  static const String SEEN_AND_UNSEEN_KEY = 'Seen_And_Unseen';
  static const String EDIT_MESSAGE_KEY = 'Edit_Message';
  static const String DELETE_MESSAGE_KEY = 'Delete_Message';
  static const String REACTIONS_KEY = 'Reactions';
  static const String FORWARD_MESSAGES_KEY = 'Forward_Messages';
  static const String CONTACT_KEY = 'Contact';
  static const String LOCATION_KEY = 'Location';
  static const String PHOTO_KEY = 'Photo';
  static const String DOCUMENTS_KEY = 'Documents';
  static const String POLL_KEY = 'Poll';
  static const String MUTE_NOTIFICATIONS_KEY = 'Mute_Notifications';
  static const String DISAPPEARING_MESSAGES_KEY = 'Disappearing_Messages';
  static const String SCHEDULE_MESSAGES_KEY = 'Schedule_Messages';
  static const String TIMESTAMPS_KEY = 'timestamps';

  @override
  Map<String, dynamic> toMap() {
    return {
      ROLE_ID_KEY: roleId,
      CREATE_GROUP_KEY: createGroup,
      SEEN_AND_UNSEEN_KEY: seenAndUnseen,
      EDIT_MESSAGE_KEY: editMessage,
      DELETE_MESSAGE_KEY: deleteMessage,
      REACTIONS_KEY: reactions,
      FORWARD_MESSAGES_KEY: forwardMessages,
      CONTACT_KEY: contact,
      LOCATION_KEY: location,
      PHOTO_KEY: photo,
      DOCUMENTS_KEY: documents,
      POLL_KEY: poll,
      MUTE_NOTIFICATIONS_KEY: muteNotifications,
      DISAPPEARING_MESSAGES_KEY: disappearingMessages,
      SCHEDULE_MESSAGES_KEY: scheduleMessages,
      TIMESTAMPS_KEY: timestamps,
    };
  }

  factory MessagesModulePermission.fromMap(Map<String, dynamic> map) {
    return MessagesModulePermission(
      timestamps: BaseModulePermission._parseTimestamps(map[TIMESTAMPS_KEY]),
      roleId: map[ROLE_ID_KEY] ?? '',
      createGroup: BaseModulePermission._parseBoolList(map[CREATE_GROUP_KEY]),
      seenAndUnseen: BaseModulePermission._parseBoolList(map[SEEN_AND_UNSEEN_KEY]),
      editMessage: BaseModulePermission._parseBoolList(map[EDIT_MESSAGE_KEY]),
      deleteMessage: BaseModulePermission._parseBoolList(map[DELETE_MESSAGE_KEY]),
      reactions: BaseModulePermission._parseBoolList(map[REACTIONS_KEY]),
      forwardMessages: BaseModulePermission._parseBoolList(map[FORWARD_MESSAGES_KEY]),
      contact: BaseModulePermission._parseBoolList(map[CONTACT_KEY]),
      location: BaseModulePermission._parseBoolList(map[LOCATION_KEY]),
      photo: BaseModulePermission._parseBoolList(map[PHOTO_KEY]),
      documents: BaseModulePermission._parseBoolList(map[DOCUMENTS_KEY]),
      poll: BaseModulePermission._parseBoolList(map[POLL_KEY]),
      muteNotifications: BaseModulePermission._parseBoolList(map[MUTE_NOTIFICATIONS_KEY]),
      disappearingMessages: BaseModulePermission._parseBoolList(map[DISAPPEARING_MESSAGES_KEY]),
      scheduleMessages: BaseModulePermission._parseBoolList(map[SCHEDULE_MESSAGES_KEY]),
    );
  }

  factory MessagesModulePermission.createNew({required String roleId}) {
    return MessagesModulePermission(
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      roleId: roleId,
      createGroup: [false],
      seenAndUnseen: [false],
      editMessage: [false],
      deleteMessage: [false],
      reactions: [false],
      forwardMessages: [false],
      contact: [false],
      location: [false],
      photo: [false],
      documents: [false],
      poll: [false],
      muteNotifications: [false],
      disappearingMessages: [false],
      scheduleMessages: [false],
    );
  }

  MessagesModulePermission copyWith({
    bool? createGroup,
    bool? seenAndUnseen,
    bool? editMessage,
    bool? deleteMessage,
    bool? reactions,
    bool? forwardMessages,
    bool? contact,
    bool? location,
    bool? photo,
    bool? documents,
    bool? poll,
    bool? muteNotifications,
    bool? disappearingMessages,
    bool? scheduleMessages,
  }) {
    final newTimestamps = List<int>.from(timestamps)..add(DateTime.now().millisecondsSinceEpoch);

    return MessagesModulePermission(
      timestamps: newTimestamps,
      roleId: roleId,
      createGroup: createGroup != null ? (List<bool>.from(this.createGroup)..add(createGroup)) : this.createGroup,
      seenAndUnseen: seenAndUnseen != null ? (List<bool>.from(this.seenAndUnseen)..add(seenAndUnseen)) : this.seenAndUnseen,
      editMessage: editMessage != null ? (List<bool>.from(this.editMessage)..add(editMessage)) : this.editMessage,
      deleteMessage: deleteMessage != null ? (List<bool>.from(this.deleteMessage)..add(deleteMessage)) : this.deleteMessage,
      reactions: reactions != null ? (List<bool>.from(this.reactions)..add(reactions)) : this.reactions,
      forwardMessages: forwardMessages != null ? (List<bool>.from(this.forwardMessages)..add(forwardMessages)) : this.forwardMessages,
      contact: contact != null ? (List<bool>.from(this.contact)..add(contact)) : this.contact,
      location: location != null ? (List<bool>.from(this.location)..add(location)) : this.location,
      photo: photo != null ? (List<bool>.from(this.photo)..add(photo)) : this.photo,
      documents: documents != null ? (List<bool>.from(this.documents)..add(documents)) : this.documents,
      poll: poll != null ? (List<bool>.from(this.poll)..add(poll)) : this.poll,
      muteNotifications: muteNotifications != null ? (List<bool>.from(this.muteNotifications)..add(muteNotifications)) : this.muteNotifications,
      disappearingMessages: disappearingMessages != null ? (List<bool>.from(this.disappearingMessages)..add(disappearingMessages)) : this.disappearingMessages,
      scheduleMessages: scheduleMessages != null ? (List<bool>.from(this.scheduleMessages)..add(scheduleMessages)) : this.scheduleMessages,
    );
  }
}
// 2. Service Module Permissions
class ServicesModulePermission extends BaseModulePermission {
  // Service Permissions
  final List<bool> createService;
  final List<bool> bulkUpload;
  final List<bool> exportService;
  final List<bool> editService;
  final List<bool> deleteService;
  final List<bool> changeServiceStatus;
  final List<bool> viewRequesters;
  final List<bool> exportRequestedServices;

  // Employees Permissions
  final List<bool> requestServicePermission;
  final List<bool> requestService;
  final List<bool> cancelService;

  // Dashboard Permissions
  final List<bool> adminDashboard;
  final List<bool> departmentDashboard;

  // Approval Permissions
  final List<bool> requestedServices;

  ServicesModulePermission({
    required super.timestamps,
    required super.roleId,
    required this.createService,
    required this.bulkUpload,
    required this.exportService,
    required this.editService,
    required this.deleteService,
    required this.changeServiceStatus,
    required this.viewRequesters,
    required this.exportRequestedServices,
    required this.requestServicePermission,
    required this.requestService,
    required this.cancelService,
    required this.adminDashboard,
    required this.departmentDashboard,
    required this.requestedServices,
  });

  // Current values getters
  bool get currentCreateService => createService.isNotEmpty ? createService.last : false;
  bool get currentBulkUpload => bulkUpload.isNotEmpty ? bulkUpload.last : false;
  bool get currentExportService => exportService.isNotEmpty ? exportService.last : false;
  bool get currentEditService => editService.isNotEmpty ? editService.last : false;
  bool get currentDeleteService => deleteService.isNotEmpty ? deleteService.last : false;
  bool get currentChangeServiceStatus => changeServiceStatus.isNotEmpty ? changeServiceStatus.last : false;
  bool get currentViewRequesters => viewRequesters.isNotEmpty ? viewRequesters.last : false;
  bool get currentExportRequestedServices => exportRequestedServices.isNotEmpty ? exportRequestedServices.last : false;
  bool get currentRequestServicePermission => requestServicePermission.isNotEmpty ? requestServicePermission.last : false;
  bool get currentRequestService => requestService.isNotEmpty ? requestService.last : false;
  bool get currentCancelService => cancelService.isNotEmpty ? cancelService.last : false;
  bool get currentAdminDashboard => adminDashboard.isNotEmpty ? adminDashboard.last : false;
  bool get currentDepartmentDashboard => departmentDashboard.isNotEmpty ? departmentDashboard.last : false;
  bool get currentRequestedServices => requestedServices.isNotEmpty ? requestedServices.last : false;

  static const String ROLE_ID_KEY = 'Role_Id';
  static const String CREATE_SERVICE_KEY = 'Create_Service';
  static const String BULK_UPLOAD_KEY = 'Bulk_Upload';
  static const String EXPORT_SERVICE_KEY = 'Export_Service';
  static const String EDIT_SERVICE_KEY = 'Edit_Service';
  static const String DELETE_SERVICE_KEY = 'Delete_Service';
  static const String CHANGE_SERVICE_STATUS_KEY = 'Change_Service_Status';
  static const String VIEW_REQUESTERS_KEY = 'View_Requesters';
  static const String EXPORT_REQUESTED_SERVICES_KEY = 'Export_Requested_Services';
  static const String REQUEST_SERVICE_PERMISSION_KEY = 'Request_Service_Permission';
  static const String REQUEST_SERVICE_KEY = 'Request_Service';
  static const String CANCEL_SERVICE_KEY = 'Cancel_Service';
  static const String ADMIN_DASHBOARD_KEY = 'Admin_Dashboard';
  static const String DEPARTMENT_DASHBOARD_KEY = 'Department_Dashboard';
  static const String REQUESTED_SERVICES_KEY = 'Requested_Services';
  static const String TIMESTAMPS_KEY = 'timestamps';

  @override
  Map<String, dynamic> toMap() {
    return {
      ROLE_ID_KEY: roleId,
      CREATE_SERVICE_KEY: createService,
      BULK_UPLOAD_KEY: bulkUpload,
      EXPORT_SERVICE_KEY: exportService,
      EDIT_SERVICE_KEY: editService,
      DELETE_SERVICE_KEY: deleteService,
      CHANGE_SERVICE_STATUS_KEY: changeServiceStatus,
      VIEW_REQUESTERS_KEY: viewRequesters,
      EXPORT_REQUESTED_SERVICES_KEY: exportRequestedServices,
      REQUEST_SERVICE_PERMISSION_KEY: requestServicePermission,
      REQUEST_SERVICE_KEY: requestService,
      CANCEL_SERVICE_KEY: cancelService,
      ADMIN_DASHBOARD_KEY: adminDashboard,
      DEPARTMENT_DASHBOARD_KEY: departmentDashboard,
      REQUESTED_SERVICES_KEY: requestedServices,
      TIMESTAMPS_KEY: timestamps,
    };
  }

  factory ServicesModulePermission.fromMap(Map<String, dynamic> map) {
    return ServicesModulePermission(
      timestamps: BaseModulePermission._parseTimestamps(map[TIMESTAMPS_KEY]),
      roleId: map[ROLE_ID_KEY] ?? '',
      createService: BaseModulePermission._parseBoolList(map[CREATE_SERVICE_KEY]),
      bulkUpload: BaseModulePermission._parseBoolList(map[BULK_UPLOAD_KEY]),
      exportService: BaseModulePermission._parseBoolList(map[EXPORT_SERVICE_KEY]),
      editService: BaseModulePermission._parseBoolList(map[EDIT_SERVICE_KEY]),
      deleteService: BaseModulePermission._parseBoolList(map[DELETE_SERVICE_KEY]),
      changeServiceStatus: BaseModulePermission._parseBoolList(map[CHANGE_SERVICE_STATUS_KEY]),
      viewRequesters: BaseModulePermission._parseBoolList(map[VIEW_REQUESTERS_KEY]),
      exportRequestedServices: BaseModulePermission._parseBoolList(map[EXPORT_REQUESTED_SERVICES_KEY]),
      requestServicePermission: BaseModulePermission._parseBoolList(map[REQUEST_SERVICE_PERMISSION_KEY]),
      requestService: BaseModulePermission._parseBoolList(map[REQUEST_SERVICE_KEY]),
      cancelService: BaseModulePermission._parseBoolList(map[CANCEL_SERVICE_KEY]),
      adminDashboard: BaseModulePermission._parseBoolList(map[ADMIN_DASHBOARD_KEY]),
      departmentDashboard: BaseModulePermission._parseBoolList(map[DEPARTMENT_DASHBOARD_KEY]),
      requestedServices: BaseModulePermission._parseBoolList(map[REQUESTED_SERVICES_KEY]),
    );
  }

  factory ServicesModulePermission.createNew({required String roleId}) {
    return ServicesModulePermission(
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      roleId: roleId,
      createService: [false],
      bulkUpload: [false],
      exportService: [false],
      editService: [false],
      deleteService: [false],
      changeServiceStatus: [false],
      viewRequesters: [false],
      exportRequestedServices: [false],
      requestServicePermission: [false],
      requestService: [false],
      cancelService: [false],
      adminDashboard: [false],
      departmentDashboard: [false],
      requestedServices: [false],
    );
  }

  ServicesModulePermission copyWith({
    bool? createService,
    bool? bulkUpload,
    bool? exportService,
    bool? editService,
    bool? deleteService,
    bool? changeServiceStatus,
    bool? viewRequesters,
    bool? exportRequestedServices,
    bool? requestServicePermission,
    bool? requestService,
    bool? cancelService,
    bool? adminDashboard,
    bool? departmentDashboard,
    bool? requestedServices,
  }) {
    final newTimestamps = List<int>.from(timestamps)..add(DateTime.now().millisecondsSinceEpoch);

    return ServicesModulePermission(
      timestamps: newTimestamps,
      roleId: roleId,
      createService: createService != null ? (List<bool>.from(this.createService)..add(createService)) : this.createService,
      bulkUpload: bulkUpload != null ? (List<bool>.from(this.bulkUpload)..add(bulkUpload)) : this.bulkUpload,
      exportService: exportService != null ? (List<bool>.from(this.exportService)..add(exportService)) : this.exportService,
      editService: editService != null ? (List<bool>.from(this.editService)..add(editService)) : this.editService,
      deleteService: deleteService != null ? (List<bool>.from(this.deleteService)..add(deleteService)) : this.deleteService,
      changeServiceStatus: changeServiceStatus != null ? (List<bool>.from(this.changeServiceStatus)..add(changeServiceStatus)) : this.changeServiceStatus,
      viewRequesters: viewRequesters != null ? (List<bool>.from(this.viewRequesters)..add(viewRequesters)) : this.viewRequesters,
      exportRequestedServices: exportRequestedServices != null ? (List<bool>.from(this.exportRequestedServices)..add(exportRequestedServices)) : this.exportRequestedServices,
      requestServicePermission: requestServicePermission != null ? (List<bool>.from(this.requestServicePermission)..add(requestServicePermission)) : this.requestServicePermission,
      requestService: requestService != null ? (List<bool>.from(this.requestService)..add(requestService)) : this.requestService,
      cancelService: cancelService != null ? (List<bool>.from(this.cancelService)..add(cancelService)) : this.cancelService,
      adminDashboard: adminDashboard != null ? (List<bool>.from(this.adminDashboard)..add(adminDashboard)) : this.adminDashboard,
      departmentDashboard: departmentDashboard != null ? (List<bool>.from(this.departmentDashboard)..add(departmentDashboard)) : this.departmentDashboard,
      requestedServices: requestedServices != null ? (List<bool>.from(this.requestedServices)..add(requestedServices)) : this.requestedServices,
    );
  }
}
// 3. Inventory Module Permissions
class InventoryModulePermission extends BaseModulePermission {
  // Product Permissions
  final List<bool> addProduct;
  final List<bool> bulkUpload;
  final List<bool> restock;
  final List<bool> existingBatch;
  final List<bool> newBatch;
  final List<bool> viewAllocatedProduct;

  // Storage Locations Permissions
  final List<bool> viewStorageLocations;
  final List<bool> addStorageLocation;
  final List<bool> editStorageLocation;
  final List<bool> deactivateStorageLocation;
  final List<bool> assignEmployees;
  final List<bool> changeTitles;
  final List<bool> transferBetweenLocations;

  // Edit Product Permissions
  final List<bool> editProductInformation;
  final List<bool> updateMaintenanceSchedule;
  final List<bool> inventoryAudit;
  final List<bool> temporarilyUnavailable;
  final List<bool> writeOff;

  // Supplier Permissions
  final List<bool> viewSuppliers;
  final List<bool> addSuppliers;
  final List<bool> editSupplier;
  final List<bool> changeSupplierRank;
  final List<bool> supplierPurchaseHistory;

  // Orders Permissions
  final List<bool> createOrder;
  final List<bool> existingProduct;
  final List<bool> newProduct;
  final List<bool> viewOrdersHistory;
  final List<bool> changeOrderStatus;
  final List<bool> cancelOrder;

  // Employees Permissions
  final List<bool> addMaintenanceEmployee;
  final List<bool> assignProductToMaintenanceEmployees;
  final List<bool> addReceivingOfficer;
  final List<bool> addStockAuditorOfficer;
  final List<bool> addComplianceAndSafetyOfficer;
  final List<bool> assignPermissions;
  final List<bool> assignProductToEmployee;
  final List<bool> retrieveProduct;
  final List<bool> viewAssignedProduct;

  // Approval Permissions
  final List<bool> viewerOnly;
  final List<bool> approveProductRequests;
  final List<bool> approveWriteOffs;

  InventoryModulePermission({
    required super.timestamps,
    required super.roleId,
    required this.addProduct,
    required this.bulkUpload,
    required this.restock,
    required this.existingBatch,
    required this.newBatch,
    required this.viewAllocatedProduct,
    required this.viewStorageLocations,
    required this.addStorageLocation,
    required this.editStorageLocation,
    required this.deactivateStorageLocation,
    required this.assignEmployees,
    required this.changeTitles,
    required this.transferBetweenLocations,
    required this.editProductInformation,
    required this.updateMaintenanceSchedule,
    required this.inventoryAudit,
    required this.temporarilyUnavailable,
    required this.writeOff,
    required this.viewSuppliers,
    required this.addSuppliers,
    required this.editSupplier,
    required this.changeSupplierRank,
    required this.supplierPurchaseHistory,
    required this.createOrder,
    required this.existingProduct,
    required this.newProduct,
    required this.viewOrdersHistory,
    required this.changeOrderStatus,
    required this.cancelOrder,
    required this.addMaintenanceEmployee,
    required this.assignProductToMaintenanceEmployees,
    required this.addReceivingOfficer,
    required this.addStockAuditorOfficer,
    required this.addComplianceAndSafetyOfficer,
    required this.assignPermissions,
    required this.assignProductToEmployee,
    required this.retrieveProduct,
    required this.viewAssignedProduct,
    required this.viewerOnly,
    required this.approveProductRequests,
    required this.approveWriteOffs,
  });

  // Current values getters
  bool get currentAddProduct => addProduct.isNotEmpty ? addProduct.last : false;
  bool get currentBulkUpload => bulkUpload.isNotEmpty ? bulkUpload.last : false;
  bool get currentRestock => restock.isNotEmpty ? restock.last : false;
  bool get currentExistingBatch => existingBatch.isNotEmpty ? existingBatch.last : false;
  bool get currentNewBatch => newBatch.isNotEmpty ? newBatch.last : false;
  bool get currentViewAllocatedProduct => viewAllocatedProduct.isNotEmpty ? viewAllocatedProduct.last : false;
  bool get currentViewStorageLocations => viewStorageLocations.isNotEmpty ? viewStorageLocations.last : false;
  bool get currentAddStorageLocation => addStorageLocation.isNotEmpty ? addStorageLocation.last : false;
  bool get currentEditStorageLocation => editStorageLocation.isNotEmpty ? editStorageLocation.last : false;
  bool get currentDeactivateStorageLocation => deactivateStorageLocation.isNotEmpty ? deactivateStorageLocation.last : false;
  bool get currentAssignEmployees => assignEmployees.isNotEmpty ? assignEmployees.last : false;
  bool get currentChangeTitles => changeTitles.isNotEmpty ? changeTitles.last : false;
  bool get currentTransferBetweenLocations => transferBetweenLocations.isNotEmpty ? transferBetweenLocations.last : false;
  bool get currentEditProductInformation => editProductInformation.isNotEmpty ? editProductInformation.last : false;
  bool get currentUpdateMaintenanceSchedule => updateMaintenanceSchedule.isNotEmpty ? updateMaintenanceSchedule.last : false;
  bool get currentInventoryAudit => inventoryAudit.isNotEmpty ? inventoryAudit.last : false;
  bool get currentTemporarilyUnavailable => temporarilyUnavailable.isNotEmpty ? temporarilyUnavailable.last : false;
  bool get currentWriteOff => writeOff.isNotEmpty ? writeOff.last : false;
  bool get currentViewSuppliers => viewSuppliers.isNotEmpty ? viewSuppliers.last : false;
  bool get currentAddSuppliers => addSuppliers.isNotEmpty ? addSuppliers.last : false;
  bool get currentEditSupplier => editSupplier.isNotEmpty ? editSupplier.last : false;
  bool get currentChangeSupplierRank => changeSupplierRank.isNotEmpty ? changeSupplierRank.last : false;
  bool get currentSupplierPurchaseHistory => supplierPurchaseHistory.isNotEmpty ? supplierPurchaseHistory.last : false;
  bool get currentCreateOrder => createOrder.isNotEmpty ? createOrder.last : false;
  bool get currentExistingProduct => existingProduct.isNotEmpty ? existingProduct.last : false;
  bool get currentNewProduct => newProduct.isNotEmpty ? newProduct.last : false;
  bool get currentViewOrdersHistory => viewOrdersHistory.isNotEmpty ? viewOrdersHistory.last : false;
  bool get currentChangeOrderStatus => changeOrderStatus.isNotEmpty ? changeOrderStatus.last : false;
  bool get currentCancelOrder => cancelOrder.isNotEmpty ? cancelOrder.last : false;
  bool get currentAddMaintenanceEmployee => addMaintenanceEmployee.isNotEmpty ? addMaintenanceEmployee.last : false;
  bool get currentAssignProductToMaintenanceEmployees => assignProductToMaintenanceEmployees.isNotEmpty ? assignProductToMaintenanceEmployees.last : false;
  bool get currentAddReceivingOfficer => addReceivingOfficer.isNotEmpty ? addReceivingOfficer.last : false;
  bool get currentAddStockAuditorOfficer => addStockAuditorOfficer.isNotEmpty ? addStockAuditorOfficer.last : false;
  bool get currentAddComplianceAndSafetyOfficer => addComplianceAndSafetyOfficer.isNotEmpty ? addComplianceAndSafetyOfficer.last : false;
  bool get currentAssignPermissions => assignPermissions.isNotEmpty ? assignPermissions.last : false;
  bool get currentAssignProductToEmployee => assignProductToEmployee.isNotEmpty ? assignProductToEmployee.last : false;
  bool get currentRetrieveProduct => retrieveProduct.isNotEmpty ? retrieveProduct.last : false;
  bool get currentViewAssignedProduct => viewAssignedProduct.isNotEmpty ? viewAssignedProduct.last : false;
  bool get currentViewerOnly => viewerOnly.isNotEmpty ? viewerOnly.last : false;
  bool get currentApproveProductRequests => approveProductRequests.isNotEmpty ? approveProductRequests.last : false;
  bool get currentApproveWriteOffs => approveWriteOffs.isNotEmpty ? approveWriteOffs.last : false;

  static const String ROLE_ID_KEY = 'Role_Id';
  static const String ADD_PRODUCT_KEY = 'Add_Product';
  static const String BULK_UPLOAD_KEY = 'Bulk_Upload';
  static const String RESTOCK_KEY = 'Restock';
  static const String EXISTING_BATCH_KEY = 'Existing_Batch';
  static const String NEW_BATCH_KEY = 'New_Batch';
  static const String VIEW_ALLOCATED_PRODUCT_KEY = 'View_Allocated_Product';
  static const String VIEW_STORAGE_LOCATIONS_KEY = 'View_Storage_Locations';
  static const String ADD_STORAGE_LOCATION_KEY = 'Add_Storage_Location';
  static const String EDIT_STORAGE_LOCATION_KEY = 'Edit_Storage_Location';
  static const String DEACTIVATE_STORAGE_LOCATION_KEY = 'Deactivate_Storage_Location';
  static const String ASSIGN_EMPLOYEES_KEY = 'Assign_Employees';
  static const String CHANGE_TITLES_KEY = 'Change_Titles';
  static const String TRANSFER_BETWEEN_LOCATIONS_KEY = 'Transfer_Between_Locations';
  static const String EDIT_PRODUCT_INFORMATION_KEY = 'Edit_Product_Information';
  static const String UPDATE_MAINTENANCE_SCHEDULE_KEY = 'Update_Maintenance_Schedule';
  static const String INVENTORY_AUDIT_KEY = 'Inventory_Audit';
  static const String TEMPORARILY_UNAVAILABLE_KEY = 'Temporarily_Unavailable';
  static const String WRITE_OFF_KEY = 'Write_Off';
  static const String VIEW_SUPPLIERS_KEY = 'View_Suppliers';
  static const String ADD_SUPPLIERS_KEY = 'Add_Suppliers';
  static const String EDIT_SUPPLIER_KEY = 'Edit_Supplier';
  static const String CHANGE_SUPPLIER_RANK_KEY = 'Change_Supplier_Rank';
  static const String SUPPLIER_PURCHASE_HISTORY_KEY = 'Supplier_Purchase_History';
  static const String CREATE_ORDER_KEY = 'Create_Order';
  static const String EXISTING_PRODUCT_KEY = 'Existing_Product';
  static const String NEW_PRODUCT_KEY = 'New_Product';
  static const String VIEW_ORDERS_HISTORY_KEY = 'View_Orders_History';
  static const String CHANGE_ORDER_STATUS_KEY = 'Change_Order_Status';
  static const String CANCEL_ORDER_KEY = 'Cancel_Order';
  static const String ADD_MAINTENANCE_EMPLOYEE_KEY = 'Add_Maintenance_Employee';
  static const String ASSIGN_PRODUCT_TO_MAINTENANCE_EMPLOYEES_KEY = 'Assign_Product_To_Maintenance_Employees';
  static const String ADD_RECEIVING_OFFICER_KEY = 'Add_Receiving_Officer';
  static const String ADD_STOCK_AUDITOR_OFFICER_KEY = 'Add_Stock_Auditor_Officer';
  static const String ADD_COMPLIANCE_AND_SAFETY_OFFICER_KEY = 'Add_Compliance_And_Safety_Officer';
  static const String ASSIGN_PERMISSIONS_KEY = 'Assign_Permissions';
  static const String ASSIGN_PRODUCT_TO_EMPLOYEE_KEY = 'Assign_Product_To_Employee';
  static const String RETRIEVE_PRODUCT_KEY = 'Retrieve_Product';
  static const String VIEW_ASSIGNED_PRODUCT_KEY = 'View_Assigned_Product';
  static const String VIEWER_ONLY_KEY = 'Viewer_Only';
  static const String APPROVE_PRODUCT_REQUESTS_KEY = 'Approve_Product_Requests';
  static const String APPROVE_WRITE_OFFS_KEY = 'Approve_Write_Offs';
  static const String TIMESTAMPS_KEY = 'timestamps';

  @override
  Map<String, dynamic> toMap() {
    return {
      ROLE_ID_KEY: roleId,
      ADD_PRODUCT_KEY: addProduct,
      BULK_UPLOAD_KEY: bulkUpload,
      RESTOCK_KEY: restock,
      EXISTING_BATCH_KEY: existingBatch,
      NEW_BATCH_KEY: newBatch,
      VIEW_ALLOCATED_PRODUCT_KEY: viewAllocatedProduct,
      VIEW_STORAGE_LOCATIONS_KEY: viewStorageLocations,
      ADD_STORAGE_LOCATION_KEY: addStorageLocation,
      EDIT_STORAGE_LOCATION_KEY: editStorageLocation,
      DEACTIVATE_STORAGE_LOCATION_KEY: deactivateStorageLocation,
      ASSIGN_EMPLOYEES_KEY: assignEmployees,
      CHANGE_TITLES_KEY: changeTitles,
      TRANSFER_BETWEEN_LOCATIONS_KEY: transferBetweenLocations,
      EDIT_PRODUCT_INFORMATION_KEY: editProductInformation,
      UPDATE_MAINTENANCE_SCHEDULE_KEY: updateMaintenanceSchedule,
      INVENTORY_AUDIT_KEY: inventoryAudit,
      TEMPORARILY_UNAVAILABLE_KEY: temporarilyUnavailable,
      WRITE_OFF_KEY: writeOff,
      VIEW_SUPPLIERS_KEY: viewSuppliers,
      ADD_SUPPLIERS_KEY: addSuppliers,
      EDIT_SUPPLIER_KEY: editSupplier,
      CHANGE_SUPPLIER_RANK_KEY: changeSupplierRank,
      SUPPLIER_PURCHASE_HISTORY_KEY: supplierPurchaseHistory,
      CREATE_ORDER_KEY: createOrder,
      EXISTING_PRODUCT_KEY: existingProduct,
      NEW_PRODUCT_KEY: newProduct,
      VIEW_ORDERS_HISTORY_KEY: viewOrdersHistory,
      CHANGE_ORDER_STATUS_KEY: changeOrderStatus,
      CANCEL_ORDER_KEY: cancelOrder,
      ADD_MAINTENANCE_EMPLOYEE_KEY: addMaintenanceEmployee,
      ASSIGN_PRODUCT_TO_MAINTENANCE_EMPLOYEES_KEY: assignProductToMaintenanceEmployees,
      ADD_RECEIVING_OFFICER_KEY: addReceivingOfficer,
      ADD_STOCK_AUDITOR_OFFICER_KEY: addStockAuditorOfficer,
      ADD_COMPLIANCE_AND_SAFETY_OFFICER_KEY: addComplianceAndSafetyOfficer,
      ASSIGN_PERMISSIONS_KEY: assignPermissions,
      ASSIGN_PRODUCT_TO_EMPLOYEE_KEY: assignProductToEmployee,
      RETRIEVE_PRODUCT_KEY: retrieveProduct,
      VIEW_ASSIGNED_PRODUCT_KEY: viewAssignedProduct,
      VIEWER_ONLY_KEY: viewerOnly,
      APPROVE_PRODUCT_REQUESTS_KEY: approveProductRequests,
      APPROVE_WRITE_OFFS_KEY: approveWriteOffs,
      TIMESTAMPS_KEY: timestamps,
    };
  }

  factory InventoryModulePermission.fromMap(Map<String, dynamic> map) {
    return InventoryModulePermission(
      timestamps: BaseModulePermission._parseTimestamps(map[TIMESTAMPS_KEY]),
      roleId: map[ROLE_ID_KEY] ?? '',
      addProduct: BaseModulePermission._parseBoolList(map[ADD_PRODUCT_KEY]),
      bulkUpload: BaseModulePermission._parseBoolList(map[BULK_UPLOAD_KEY]),
      restock: BaseModulePermission._parseBoolList(map[RESTOCK_KEY]),
      existingBatch: BaseModulePermission._parseBoolList(map[EXISTING_BATCH_KEY]),
      newBatch: BaseModulePermission._parseBoolList(map[NEW_BATCH_KEY]),
      viewAllocatedProduct: BaseModulePermission._parseBoolList(map[VIEW_ALLOCATED_PRODUCT_KEY]),
      viewStorageLocations: BaseModulePermission._parseBoolList(map[VIEW_STORAGE_LOCATIONS_KEY]),
      addStorageLocation: BaseModulePermission._parseBoolList(map[ADD_STORAGE_LOCATION_KEY]),
      editStorageLocation: BaseModulePermission._parseBoolList(map[EDIT_STORAGE_LOCATION_KEY]),
      deactivateStorageLocation: BaseModulePermission._parseBoolList(map[DEACTIVATE_STORAGE_LOCATION_KEY]),
      assignEmployees: BaseModulePermission._parseBoolList(map[ASSIGN_EMPLOYEES_KEY]),
      changeTitles: BaseModulePermission._parseBoolList(map[CHANGE_TITLES_KEY]),
      transferBetweenLocations: BaseModulePermission._parseBoolList(map[TRANSFER_BETWEEN_LOCATIONS_KEY]),
      editProductInformation: BaseModulePermission._parseBoolList(map[EDIT_PRODUCT_INFORMATION_KEY]),
      updateMaintenanceSchedule: BaseModulePermission._parseBoolList(map[UPDATE_MAINTENANCE_SCHEDULE_KEY]),
      inventoryAudit: BaseModulePermission._parseBoolList(map[INVENTORY_AUDIT_KEY]),
      temporarilyUnavailable: BaseModulePermission._parseBoolList(map[TEMPORARILY_UNAVAILABLE_KEY]),
      writeOff: BaseModulePermission._parseBoolList(map[WRITE_OFF_KEY]),
      viewSuppliers: BaseModulePermission._parseBoolList(map[VIEW_SUPPLIERS_KEY]),
      addSuppliers: BaseModulePermission._parseBoolList(map[ADD_SUPPLIERS_KEY]),
      editSupplier: BaseModulePermission._parseBoolList(map[EDIT_SUPPLIER_KEY]),
      changeSupplierRank: BaseModulePermission._parseBoolList(map[CHANGE_SUPPLIER_RANK_KEY]),
      supplierPurchaseHistory: BaseModulePermission._parseBoolList(map[SUPPLIER_PURCHASE_HISTORY_KEY]),
      createOrder: BaseModulePermission._parseBoolList(map[CREATE_ORDER_KEY]),
      existingProduct: BaseModulePermission._parseBoolList(map[EXISTING_PRODUCT_KEY]),
      newProduct: BaseModulePermission._parseBoolList(map[NEW_PRODUCT_KEY]),
      viewOrdersHistory: BaseModulePermission._parseBoolList(map[VIEW_ORDERS_HISTORY_KEY]),
      changeOrderStatus: BaseModulePermission._parseBoolList(map[CHANGE_ORDER_STATUS_KEY]),
      cancelOrder: BaseModulePermission._parseBoolList(map[CANCEL_ORDER_KEY]),
      addMaintenanceEmployee: BaseModulePermission._parseBoolList(map[ADD_MAINTENANCE_EMPLOYEE_KEY]),
      assignProductToMaintenanceEmployees: BaseModulePermission._parseBoolList(map[ASSIGN_PRODUCT_TO_MAINTENANCE_EMPLOYEES_KEY]),
      addReceivingOfficer: BaseModulePermission._parseBoolList(map[ADD_RECEIVING_OFFICER_KEY]),
      addStockAuditorOfficer: BaseModulePermission._parseBoolList(map[ADD_STOCK_AUDITOR_OFFICER_KEY]),
      addComplianceAndSafetyOfficer: BaseModulePermission._parseBoolList(map[ADD_COMPLIANCE_AND_SAFETY_OFFICER_KEY]),
      assignPermissions: BaseModulePermission._parseBoolList(map[ASSIGN_PERMISSIONS_KEY]),
      assignProductToEmployee: BaseModulePermission._parseBoolList(map[ASSIGN_PRODUCT_TO_EMPLOYEE_KEY]),
      retrieveProduct: BaseModulePermission._parseBoolList(map[RETRIEVE_PRODUCT_KEY]),
      viewAssignedProduct: BaseModulePermission._parseBoolList(map[VIEW_ASSIGNED_PRODUCT_KEY]),
      viewerOnly: BaseModulePermission._parseBoolList(map[VIEWER_ONLY_KEY]),
      approveProductRequests: BaseModulePermission._parseBoolList(map[APPROVE_PRODUCT_REQUESTS_KEY]),
      approveWriteOffs: BaseModulePermission._parseBoolList(map[APPROVE_WRITE_OFFS_KEY]),
    );
  }

  factory InventoryModulePermission.createNew({required String roleId}) {
    return InventoryModulePermission(
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      roleId: roleId,
      addProduct: [false],
      bulkUpload: [false],
      restock: [false],
      existingBatch: [false],
      newBatch: [false],
      viewAllocatedProduct: [false],
      viewStorageLocations: [false],
      addStorageLocation: [false],
      editStorageLocation: [false],
      deactivateStorageLocation: [false],
      assignEmployees: [false],
      changeTitles: [false],
      transferBetweenLocations: [false],
      editProductInformation: [false],
      updateMaintenanceSchedule: [false],
      inventoryAudit: [false],
      temporarilyUnavailable: [false],
      writeOff: [false],
      viewSuppliers: [false],
      addSuppliers: [false],
      editSupplier: [false],
      changeSupplierRank: [false],
      supplierPurchaseHistory: [false],
      createOrder: [false],
      existingProduct: [false],
      newProduct: [false],
      viewOrdersHistory: [false],
      changeOrderStatus: [false],
      cancelOrder: [false],
      addMaintenanceEmployee: [false],
      assignProductToMaintenanceEmployees: [false],
      addReceivingOfficer: [false],
      addStockAuditorOfficer: [false],
      addComplianceAndSafetyOfficer: [false],
      assignPermissions: [false],
      assignProductToEmployee: [false],
      retrieveProduct: [false],
      viewAssignedProduct: [false],
      viewerOnly: [false],
      approveProductRequests: [false],
      approveWriteOffs: [false],
    );
  }

// Continue with copyWith method and other modules...
}
// 4. Form Module Permissions
class FormModulePermission extends BaseModulePermission {
  // Form Permissions
  final List<bool> createNewForm;
  final List<bool> editForm;
  final List<bool> deleteForm;
  final List<bool> restoreForm;
  final List<bool> duplicateForm;
  final List<bool> convertToPDF;
  final List<bool> fillOutForm;
  final List<bool> share;
  final List<bool> editPermission;

  // Results Permissions
  final List<bool> users;
  final List<bool> pendingSubmissions;
  final List<bool> viewSubmissions;
  final List<bool> exportSubmissionData;
  final List<bool> downloadSubmissions;
  final List<bool> downloadFormDigitalAssets;
  final List<bool> analytics;
  final List<bool> exportAnalyticsData;
  final List<bool> createGroupPermissions;

  FormModulePermission({
    required super.timestamps,
    required super.roleId,
    required this.createNewForm,
    required this.editForm,
    required this.deleteForm,
    required this.restoreForm,
    required this.duplicateForm,
    required this.convertToPDF,
    required this.fillOutForm,
    required this.share,
    required this.editPermission,
    required this.users,
    required this.pendingSubmissions,
    required this.viewSubmissions,
    required this.exportSubmissionData,
    required this.downloadSubmissions,
    required this.downloadFormDigitalAssets,
    required this.analytics,
    required this.exportAnalyticsData,
    required this.createGroupPermissions,
  });

  // Current values getters
  bool get currentCreateNewForm => createNewForm.isNotEmpty ? createNewForm.last : false;
  bool get currentEditForm => editForm.isNotEmpty ? editForm.last : false;
  bool get currentDeleteForm => deleteForm.isNotEmpty ? deleteForm.last : false;
  bool get currentRestoreForm => restoreForm.isNotEmpty ? restoreForm.last : false;
  bool get currentDuplicateForm => duplicateForm.isNotEmpty ? duplicateForm.last : false;
  bool get currentConvertToPDF => convertToPDF.isNotEmpty ? convertToPDF.last : false;
  bool get currentFillOutForm => fillOutForm.isNotEmpty ? fillOutForm.last : false;
  bool get currentShare => share.isNotEmpty ? share.last : false;
  bool get currentEditPermission => editPermission.isNotEmpty ? editPermission.last : false;
  bool get currentUsers => users.isNotEmpty ? users.last : false;
  bool get currentPendingSubmissions => pendingSubmissions.isNotEmpty ? pendingSubmissions.last : false;
  bool get currentViewSubmissions => viewSubmissions.isNotEmpty ? viewSubmissions.last : false;
  bool get currentExportSubmissionData => exportSubmissionData.isNotEmpty ? exportSubmissionData.last : false;
  bool get currentDownloadSubmissions => downloadSubmissions.isNotEmpty ? downloadSubmissions.last : false;
  bool get currentDownloadFormDigitalAssets => downloadFormDigitalAssets.isNotEmpty ? downloadFormDigitalAssets.last : false;
  bool get currentAnalytics => analytics.isNotEmpty ? analytics.last : false;
  bool get currentExportAnalyticsData => exportAnalyticsData.isNotEmpty ? exportAnalyticsData.last : false;
  bool get currentCreateGroupPermissions => createGroupPermissions.isNotEmpty ? createGroupPermissions.last : false;

  static const String ROLE_ID_KEY = 'Role_Id';
  static const String CREATE_NEW_FORM_KEY = 'Create_New_Form';
  static const String EDIT_FORM_KEY = 'Edit_Form';
  static const String DELETE_FORM_KEY = 'Delete_Form';
  static const String RESTORE_FORM_KEY = 'Restore_Form';
  static const String DUPLICATE_FORM_KEY = 'Duplicate_Form';
  static const String CONVERT_TO_PDF_KEY = 'Convert_To_PDF';
  static const String FILL_OUT_FORM_KEY = 'Fill_Out_Form';
  static const String SHARE_KEY = 'Share';
  static const String EDIT_PERMISSION_KEY = 'Edit_Permission';
  static const String USERS_KEY = 'Users';
  static const String PENDING_SUBMISSIONS_KEY = 'Pending_Submissions';
  static const String VIEW_SUBMISSIONS_KEY = 'View_Submissions';
  static const String EXPORT_SUBMISSION_DATA_KEY = 'Export_Submission_Data';
  static const String DOWNLOAD_SUBMISSIONS_KEY = 'Download_Submissions';
  static const String DOWNLOAD_FORM_DIGITAL_ASSETS_KEY = 'Download_Form_Digital_Assets';
  static const String ANALYTICS_KEY = 'Analytics';
  static const String EXPORT_ANALYTICS_DATA_KEY = 'Export_Analytics_Data';
  static const String CREATE_GROUP_PERMISSIONS_KEY = 'Create_Group_Permissions';
  static const String TIMESTAMPS_KEY = 'timestamps';

  @override
  Map<String, dynamic> toMap() {
    return {
      ROLE_ID_KEY: roleId,
      CREATE_NEW_FORM_KEY: createNewForm,
      EDIT_FORM_KEY: editForm,
      DELETE_FORM_KEY: deleteForm,
      RESTORE_FORM_KEY: restoreForm,
      DUPLICATE_FORM_KEY: duplicateForm,
      CONVERT_TO_PDF_KEY: convertToPDF,
      FILL_OUT_FORM_KEY: fillOutForm,
      SHARE_KEY: share,
      EDIT_PERMISSION_KEY: editPermission,
      USERS_KEY: users,
      PENDING_SUBMISSIONS_KEY: pendingSubmissions,
      VIEW_SUBMISSIONS_KEY: viewSubmissions,
      EXPORT_SUBMISSION_DATA_KEY: exportSubmissionData,
      DOWNLOAD_SUBMISSIONS_KEY: downloadSubmissions,
      DOWNLOAD_FORM_DIGITAL_ASSETS_KEY: downloadFormDigitalAssets,
      ANALYTICS_KEY: analytics,
      EXPORT_ANALYTICS_DATA_KEY: exportAnalyticsData,
      CREATE_GROUP_PERMISSIONS_KEY: createGroupPermissions,
      TIMESTAMPS_KEY: timestamps,
    };
  }

  factory FormModulePermission.fromMap(Map<String, dynamic> map) {
    return FormModulePermission(
      timestamps: BaseModulePermission._parseTimestamps(map[TIMESTAMPS_KEY]),
      roleId: map[ROLE_ID_KEY] ?? '',
      createNewForm: BaseModulePermission._parseBoolList(map[CREATE_NEW_FORM_KEY]),
      editForm: BaseModulePermission._parseBoolList(map[EDIT_FORM_KEY]),
      deleteForm: BaseModulePermission._parseBoolList(map[DELETE_FORM_KEY]),
      restoreForm: BaseModulePermission._parseBoolList(map[RESTORE_FORM_KEY]),
      duplicateForm: BaseModulePermission._parseBoolList(map[DUPLICATE_FORM_KEY]),
      convertToPDF: BaseModulePermission._parseBoolList(map[CONVERT_TO_PDF_KEY]),
      fillOutForm: BaseModulePermission._parseBoolList(map[FILL_OUT_FORM_KEY]),
      share: BaseModulePermission._parseBoolList(map[SHARE_KEY]),
      editPermission: BaseModulePermission._parseBoolList(map[EDIT_PERMISSION_KEY]),
      users: BaseModulePermission._parseBoolList(map[USERS_KEY]),
      pendingSubmissions: BaseModulePermission._parseBoolList(map[PENDING_SUBMISSIONS_KEY]),
      viewSubmissions: BaseModulePermission._parseBoolList(map[VIEW_SUBMISSIONS_KEY]),
      exportSubmissionData: BaseModulePermission._parseBoolList(map[EXPORT_SUBMISSION_DATA_KEY]),
      downloadSubmissions: BaseModulePermission._parseBoolList(map[DOWNLOAD_SUBMISSIONS_KEY]),
      downloadFormDigitalAssets: BaseModulePermission._parseBoolList(map[DOWNLOAD_FORM_DIGITAL_ASSETS_KEY]),
      analytics: BaseModulePermission._parseBoolList(map[ANALYTICS_KEY]),
      exportAnalyticsData: BaseModulePermission._parseBoolList(map[EXPORT_ANALYTICS_DATA_KEY]),
      createGroupPermissions: BaseModulePermission._parseBoolList(map[CREATE_GROUP_PERMISSIONS_KEY]),
    );
  }

  factory FormModulePermission.createNew({required String roleId}) {
    return FormModulePermission(
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      roleId: roleId,
      createNewForm: [false],
      editForm: [false],
      deleteForm: [false],
      restoreForm: [false],
      duplicateForm: [false],
      convertToPDF: [false],
      fillOutForm: [false],
      share: [false],
      editPermission: [false],
      users: [false],
      pendingSubmissions: [false],
      viewSubmissions: [false],
      exportSubmissionData: [false],
      downloadSubmissions: [false],
      downloadFormDigitalAssets: [false],
      analytics: [false],
      exportAnalyticsData: [false],
      createGroupPermissions: [false],
    );
  }
}
// 5. Qiyas Module Permissions
class QiyasModulePermission extends BaseModulePermission {
  // Qiyas Permissions
  final List<bool> bulkUpload;
  final List<bool> editQiyasDetails;
  final List<bool> deleteQiyas;
  final List<bool> exportQiyasTable;
  final List<bool> assignChampion;
  final List<bool> dashboard;
  final List<bool> approvals;
  final List<bool> changeSubmissionStatus;

  // Champions Permissions
  final List<bool> editEvidence;
  final List<bool> removeChampion;
  final List<bool> reassignChampion;
  final List<bool> exportChampionTables;
  final List<bool> uploadedSupportingDocuments;
  final List<bool> approvedAndRejectedSubmissions;
  final List<bool> approvedOnly;

  QiyasModulePermission({
    required super.timestamps,
    required super.roleId,
    required this.bulkUpload,
    required this.editQiyasDetails,
    required this.deleteQiyas,
    required this.exportQiyasTable,
    required this.assignChampion,
    required this.dashboard,
    required this.approvals,
    required this.changeSubmissionStatus,
    required this.editEvidence,
    required this.removeChampion,
    required this.reassignChampion,
    required this.exportChampionTables,
    required this.uploadedSupportingDocuments,
    required this.approvedAndRejectedSubmissions,
    required this.approvedOnly,
  });

  // Current values getters
  bool get currentBulkUpload => bulkUpload.isNotEmpty ? bulkUpload.last : false;
  bool get currentEditQiyasDetails => editQiyasDetails.isNotEmpty ? editQiyasDetails.last : false;
  bool get currentDeleteQiyas => deleteQiyas.isNotEmpty ? deleteQiyas.last : false;
  bool get currentExportQiyasTable => exportQiyasTable.isNotEmpty ? exportQiyasTable.last : false;
  bool get currentAssignChampion => assignChampion.isNotEmpty ? assignChampion.last : false;
  bool get currentDashboard => dashboard.isNotEmpty ? dashboard.last : false;
  bool get currentApprovals => approvals.isNotEmpty ? approvals.last : false;
  bool get currentChangeSubmissionStatus => changeSubmissionStatus.isNotEmpty ? changeSubmissionStatus.last : false;
  bool get currentEditEvidence => editEvidence.isNotEmpty ? editEvidence.last : false;
  bool get currentRemoveChampion => removeChampion.isNotEmpty ? removeChampion.last : false;
  bool get currentReassignChampion => reassignChampion.isNotEmpty ? reassignChampion.last : false;
  bool get currentExportChampionTables => exportChampionTables.isNotEmpty ? exportChampionTables.last : false;
  bool get currentUploadedSupportingDocuments => uploadedSupportingDocuments.isNotEmpty ? uploadedSupportingDocuments.last : false;
  bool get currentApprovedAndRejectedSubmissions => approvedAndRejectedSubmissions.isNotEmpty ? approvedAndRejectedSubmissions.last : false;
  bool get currentApprovedOnly => approvedOnly.isNotEmpty ? approvedOnly.last : false;

  static const String ROLE_ID_KEY = 'Role_Id';
  static const String BULK_UPLOAD_KEY = 'Bulk_Upload';
  static const String EDIT_QIYAS_DETAILS_KEY = 'Edit_Qiyas_Details';
  static const String DELETE_QIYAS_KEY = 'Delete_Qiyas';
  static const String EXPORT_QIYAS_TABLE_KEY = 'Export_Qiyas_Table';
  static const String ASSIGN_CHAMPION_KEY = 'Assign_Champion';
  static const String DASHBOARD_KEY = 'Dashboard';
  static const String APPROVALS_KEY = 'Approvals';
  static const String CHANGE_SUBMISSION_STATUS_KEY = 'Change_Submission_Status';
  static const String EDIT_EVIDENCE_KEY = 'Edit_Evidence';
  static const String REMOVE_CHAMPION_KEY = 'Remove_Champion';
  static const String REASSIGN_CHAMPION_KEY = 'Reassign_Champion';
  static const String EXPORT_CHAMPION_TABLES_KEY = 'Export_Champion_Tables';
  static const String UPLOADED_SUPPORTING_DOCUMENTS_KEY = 'Uploaded_Supporting_Documents';
  static const String APPROVED_AND_REJECTED_SUBMISSIONS_KEY = 'Approved_And_Rejected_Submissions';
  static const String APPROVED_ONLY_KEY = 'Approved_Only';
  static const String TIMESTAMPS_KEY = 'timestamps';

  @override
  Map<String, dynamic> toMap() {
    return {
      ROLE_ID_KEY: roleId,
      BULK_UPLOAD_KEY: bulkUpload,
      EDIT_QIYAS_DETAILS_KEY: editQiyasDetails,
      DELETE_QIYAS_KEY: deleteQiyas,
      EXPORT_QIYAS_TABLE_KEY: exportQiyasTable,
      ASSIGN_CHAMPION_KEY: assignChampion,
      DASHBOARD_KEY: dashboard,
      APPROVALS_KEY: approvals,
      CHANGE_SUBMISSION_STATUS_KEY: changeSubmissionStatus,
      EDIT_EVIDENCE_KEY: editEvidence,
      REMOVE_CHAMPION_KEY: removeChampion,
      REASSIGN_CHAMPION_KEY: reassignChampion,
      EXPORT_CHAMPION_TABLES_KEY: exportChampionTables,
      UPLOADED_SUPPORTING_DOCUMENTS_KEY: uploadedSupportingDocuments,
      APPROVED_AND_REJECTED_SUBMISSIONS_KEY: approvedAndRejectedSubmissions,
      APPROVED_ONLY_KEY: approvedOnly,
      TIMESTAMPS_KEY: timestamps,
    };
  }

  factory QiyasModulePermission.fromMap(Map<String, dynamic> map) {
    return QiyasModulePermission(
      timestamps: BaseModulePermission._parseTimestamps(map[TIMESTAMPS_KEY]),
      roleId: map[ROLE_ID_KEY] ?? '',
      bulkUpload: BaseModulePermission._parseBoolList(map[BULK_UPLOAD_KEY]),
      editQiyasDetails: BaseModulePermission._parseBoolList(map[EDIT_QIYAS_DETAILS_KEY]),
      deleteQiyas: BaseModulePermission._parseBoolList(map[DELETE_QIYAS_KEY]),
      exportQiyasTable: BaseModulePermission._parseBoolList(map[EXPORT_QIYAS_TABLE_KEY]),
      assignChampion: BaseModulePermission._parseBoolList(map[ASSIGN_CHAMPION_KEY]),
      dashboard: BaseModulePermission._parseBoolList(map[DASHBOARD_KEY]),
      approvals: BaseModulePermission._parseBoolList(map[APPROVALS_KEY]),
      changeSubmissionStatus: BaseModulePermission._parseBoolList(map[CHANGE_SUBMISSION_STATUS_KEY]),
      editEvidence: BaseModulePermission._parseBoolList(map[EDIT_EVIDENCE_KEY]),
      removeChampion: BaseModulePermission._parseBoolList(map[REMOVE_CHAMPION_KEY]),
      reassignChampion: BaseModulePermission._parseBoolList(map[REASSIGN_CHAMPION_KEY]),
      exportChampionTables: BaseModulePermission._parseBoolList(map[EXPORT_CHAMPION_TABLES_KEY]),
      uploadedSupportingDocuments: BaseModulePermission._parseBoolList(map[UPLOADED_SUPPORTING_DOCUMENTS_KEY]),
      approvedAndRejectedSubmissions: BaseModulePermission._parseBoolList(map[APPROVED_AND_REJECTED_SUBMISSIONS_KEY]),
      approvedOnly: BaseModulePermission._parseBoolList(map[APPROVED_ONLY_KEY]),
    );
  }

  factory QiyasModulePermission.createNew({required String roleId}) {
    return QiyasModulePermission(
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      roleId: roleId,
      bulkUpload: [false],
      editQiyasDetails: [false],
      deleteQiyas: [false],
      exportQiyasTable: [false],
      assignChampion: [false],
      dashboard: [false],
      approvals: [false],
      changeSubmissionStatus: [false],
      editEvidence: [false],
      removeChampion: [false],
      reassignChampion: [false],
      exportChampionTables: [false],
      uploadedSupportingDocuments: [false],
      approvedAndRejectedSubmissions: [false],
      approvedOnly: [false],
    );
  }

  QiyasModulePermission copyWith({
    bool? bulkUpload,
    bool? editQiyasDetails,
    bool? deleteQiyas,
    bool? exportQiyasTable,
    bool? assignChampion,
    bool? dashboard,
    bool? approvals,
    bool? changeSubmissionStatus,
    bool? editEvidence,
    bool? removeChampion,
    bool? reassignChampion,
    bool? exportChampionTables,
    bool? uploadedSupportingDocuments,
    bool? approvedAndRejectedSubmissions,
    bool? approvedOnly,
  }) {
    final newTimestamps = List<int>.from(timestamps)..add(DateTime.now().millisecondsSinceEpoch);

    return QiyasModulePermission(
      timestamps: newTimestamps,
      roleId: roleId,
      bulkUpload: bulkUpload != null ? (List<bool>.from(this.bulkUpload)..add(bulkUpload)) : this.bulkUpload,
      editQiyasDetails: editQiyasDetails != null ? (List<bool>.from(this.editQiyasDetails)..add(editQiyasDetails)) : this.editQiyasDetails,
      deleteQiyas: deleteQiyas != null ? (List<bool>.from(this.deleteQiyas)..add(deleteQiyas)) : this.deleteQiyas,
      exportQiyasTable: exportQiyasTable != null ? (List<bool>.from(this.exportQiyasTable)..add(exportQiyasTable)) : this.exportQiyasTable,
      assignChampion: assignChampion != null ? (List<bool>.from(this.assignChampion)..add(assignChampion)) : this.assignChampion,
      dashboard: dashboard != null ? (List<bool>.from(this.dashboard)..add(dashboard)) : this.dashboard,
      approvals: approvals != null ? (List<bool>.from(this.approvals)..add(approvals)) : this.approvals,
      changeSubmissionStatus: changeSubmissionStatus != null ? (List<bool>.from(this.changeSubmissionStatus)..add(changeSubmissionStatus)) : this.changeSubmissionStatus,
      editEvidence: editEvidence != null ? (List<bool>.from(this.editEvidence)..add(editEvidence)) : this.editEvidence,
      removeChampion: removeChampion != null ? (List<bool>.from(this.removeChampion)..add(removeChampion)) : this.removeChampion,
      reassignChampion: reassignChampion != null ? (List<bool>.from(this.reassignChampion)..add(reassignChampion)) : this.reassignChampion,
      exportChampionTables: exportChampionTables != null ? (List<bool>.from(this.exportChampionTables)..add(exportChampionTables)) : this.exportChampionTables,
      uploadedSupportingDocuments: uploadedSupportingDocuments != null ? (List<bool>.from(this.uploadedSupportingDocuments)..add(uploadedSupportingDocuments)) : this.uploadedSupportingDocuments,
      approvedAndRejectedSubmissions: approvedAndRejectedSubmissions != null ? (List<bool>.from(this.approvedAndRejectedSubmissions)..add(approvedAndRejectedSubmissions)) : this.approvedAndRejectedSubmissions,
      approvedOnly: approvedOnly != null ? (List<bool>.from(this.approvedOnly)..add(approvedOnly)) : this.approvedOnly,
    );
  }
}
// 6. Knowledge Hub Module Permissions
class KnowledgeHubModulePermission extends BaseModulePermission {
  // Knowledge Hub Permissions
  final List<bool> createKnowledgeHub;
  final List<bool> selectOwningDepartment;
  final List<bool> downloadDocuments;
  final List<bool> viewDocuments;
  final List<bool> analytics;
  final List<bool> statistics;
  final List<bool> inquiriesAndComments;
  final List<bool> allowsRemovingDocumentsOwnedByAnyone;

  // Submissions Permissions
  final List<bool> editDocumentWithApproval;
  final List<bool> editDocumentWithoutApproval;
  final List<bool> removeDocuments;
  final List<bool> exportStatisticsTable;

  // Approval Permissions
  final List<bool> approvedAndRejected;
  final List<bool> approvedOnly;
  final List<bool> dashboard;

  KnowledgeHubModulePermission({
    required super.timestamps,
    required super.roleId,
    required this.createKnowledgeHub,
    required this.selectOwningDepartment,
    required this.downloadDocuments,
    required this.viewDocuments,
    required this.analytics,
    required this.statistics,
    required this.inquiriesAndComments,
    required this.allowsRemovingDocumentsOwnedByAnyone,
    required this.editDocumentWithApproval,
    required this.editDocumentWithoutApproval,
    required this.removeDocuments,
    required this.exportStatisticsTable,
    required this.approvedAndRejected,
    required this.approvedOnly,
    required this.dashboard,
  });

  // Current values getters
  bool get currentCreateKnowledgeHub => createKnowledgeHub.isNotEmpty ? createKnowledgeHub.last : false;
  bool get currentSelectOwningDepartment => selectOwningDepartment.isNotEmpty ? selectOwningDepartment.last : false;
  bool get currentDownloadDocuments => downloadDocuments.isNotEmpty ? downloadDocuments.last : false;
  bool get currentViewDocuments => viewDocuments.isNotEmpty ? viewDocuments.last : false;
  bool get currentAnalytics => analytics.isNotEmpty ? analytics.last : false;
  bool get currentStatistics => statistics.isNotEmpty ? statistics.last : false;
  bool get currentInquiriesAndComments => inquiriesAndComments.isNotEmpty ? inquiriesAndComments.last : false;
  bool get currentAllowsRemovingDocumentsOwnedByAnyone => allowsRemovingDocumentsOwnedByAnyone.isNotEmpty ? allowsRemovingDocumentsOwnedByAnyone.last : false;
  bool get currentEditDocumentWithApproval => editDocumentWithApproval.isNotEmpty ? editDocumentWithApproval.last : false;
  bool get currentEditDocumentWithoutApproval => editDocumentWithoutApproval.isNotEmpty ? editDocumentWithoutApproval.last : false;
  bool get currentRemoveDocuments => removeDocuments.isNotEmpty ? removeDocuments.last : false;
  bool get currentExportStatisticsTable => exportStatisticsTable.isNotEmpty ? exportStatisticsTable.last : false;
  bool get currentApprovedAndRejected => approvedAndRejected.isNotEmpty ? approvedAndRejected.last : false;
  bool get currentApprovedOnly => approvedOnly.isNotEmpty ? approvedOnly.last : false;
  bool get currentDashboard => dashboard.isNotEmpty ? dashboard.last : false;

  static const String ROLE_ID_KEY = 'Role_Id';
  static const String CREATE_KNOWLEDGE_HUB_KEY = 'Create_Knowledge_Hub';
  static const String SELECT_OWNING_DEPARTMENT_KEY = 'Select_Owning_Department';
  static const String DOWNLOAD_DOCUMENTS_KEY = 'Download_Documents';
  static const String VIEW_DOCUMENTS_KEY = 'View_Documents';
  static const String ANALYTICS_KEY = 'Analytics';
  static const String STATISTICS_KEY = 'Statistics';
  static const String INQUIRIES_AND_COMMENTS_KEY = 'Inquiries_And_Comments';
  static const String ALLOWS_REMOVING_DOCUMENTS_OWNED_BY_ANYONE_KEY = 'Allows_Removing_Documents_Owned_By_Anyone';
  static const String EDIT_DOCUMENT_WITH_APPROVAL_KEY = 'Edit_Document_With_Approval';
  static const String EDIT_DOCUMENT_WITHOUT_APPROVAL_KEY = 'Edit_Document_Without_Approval';
  static const String REMOVE_DOCUMENTS_KEY = 'Remove_Documents';
  static const String EXPORT_STATISTICS_TABLE_KEY = 'Export_Statistics_Table';
  static const String APPROVED_AND_REJECTED_KEY = 'Approved_And_Rejected';
  static const String APPROVED_ONLY_KEY = 'Approved_Only';
  static const String DASHBOARD_KEY = 'Dashboard';
  static const String TIMESTAMPS_KEY = 'timestamps';

  @override
  Map<String, dynamic> toMap() {
    return {
      ROLE_ID_KEY: roleId,
      CREATE_KNOWLEDGE_HUB_KEY: createKnowledgeHub,
      SELECT_OWNING_DEPARTMENT_KEY: selectOwningDepartment,
      DOWNLOAD_DOCUMENTS_KEY: downloadDocuments,
      VIEW_DOCUMENTS_KEY: viewDocuments,
      ANALYTICS_KEY: analytics,
      STATISTICS_KEY: statistics,
      INQUIRIES_AND_COMMENTS_KEY: inquiriesAndComments,
      ALLOWS_REMOVING_DOCUMENTS_OWNED_BY_ANYONE_KEY: allowsRemovingDocumentsOwnedByAnyone,
      EDIT_DOCUMENT_WITH_APPROVAL_KEY: editDocumentWithApproval,
      EDIT_DOCUMENT_WITHOUT_APPROVAL_KEY: editDocumentWithoutApproval,
      REMOVE_DOCUMENTS_KEY: removeDocuments,
      EXPORT_STATISTICS_TABLE_KEY: exportStatisticsTable,
      APPROVED_AND_REJECTED_KEY: approvedAndRejected,
      APPROVED_ONLY_KEY: approvedOnly,
      DASHBOARD_KEY: dashboard,
      TIMESTAMPS_KEY: timestamps,
    };
  }

  factory KnowledgeHubModulePermission.fromMap(Map<String, dynamic> map) {
    return KnowledgeHubModulePermission(
      timestamps: BaseModulePermission._parseTimestamps(map[TIMESTAMPS_KEY]),
      roleId: map[ROLE_ID_KEY] ?? '',
      createKnowledgeHub: BaseModulePermission._parseBoolList(map[CREATE_KNOWLEDGE_HUB_KEY]),
      selectOwningDepartment: BaseModulePermission._parseBoolList(map[SELECT_OWNING_DEPARTMENT_KEY]),
      downloadDocuments: BaseModulePermission._parseBoolList(map[DOWNLOAD_DOCUMENTS_KEY]),
      viewDocuments: BaseModulePermission._parseBoolList(map[VIEW_DOCUMENTS_KEY]),
      analytics: BaseModulePermission._parseBoolList(map[ANALYTICS_KEY]),
      statistics: BaseModulePermission._parseBoolList(map[STATISTICS_KEY]),
      inquiriesAndComments: BaseModulePermission._parseBoolList(map[INQUIRIES_AND_COMMENTS_KEY]),
      allowsRemovingDocumentsOwnedByAnyone: BaseModulePermission._parseBoolList(map[ALLOWS_REMOVING_DOCUMENTS_OWNED_BY_ANYONE_KEY]),
      editDocumentWithApproval: BaseModulePermission._parseBoolList(map[EDIT_DOCUMENT_WITH_APPROVAL_KEY]),
      editDocumentWithoutApproval: BaseModulePermission._parseBoolList(map[EDIT_DOCUMENT_WITHOUT_APPROVAL_KEY]),
      removeDocuments: BaseModulePermission._parseBoolList(map[REMOVE_DOCUMENTS_KEY]),
      exportStatisticsTable: BaseModulePermission._parseBoolList(map[EXPORT_STATISTICS_TABLE_KEY]),
      approvedAndRejected: BaseModulePermission._parseBoolList(map[APPROVED_AND_REJECTED_KEY]),
      approvedOnly: BaseModulePermission._parseBoolList(map[APPROVED_ONLY_KEY]),
      dashboard: BaseModulePermission._parseBoolList(map[DASHBOARD_KEY]),
    );
  }

  factory KnowledgeHubModulePermission.createNew({required String roleId}) {
    return KnowledgeHubModulePermission(
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      roleId: roleId,
      createKnowledgeHub: [false],
      selectOwningDepartment: [false],
      downloadDocuments: [false],
      viewDocuments: [false],
      analytics: [false],
      statistics: [false],
      inquiriesAndComments: [false],
      allowsRemovingDocumentsOwnedByAnyone: [false],
      editDocumentWithApproval: [false],
      editDocumentWithoutApproval: [false],
      removeDocuments: [false],
      exportStatisticsTable: [false],
      approvedAndRejected: [false],
      approvedOnly: [false],
      dashboard: [false],
    );
  }

  KnowledgeHubModulePermission copyWith({
    bool? createKnowledgeHub,
    bool? selectOwningDepartment,
    bool? downloadDocuments,
    bool? viewDocuments,
    bool? analytics,
    bool? statistics,
    bool? inquiriesAndComments,
    bool? allowsRemovingDocumentsOwnedByAnyone,
    bool? editDocumentWithApproval,
    bool? editDocumentWithoutApproval,
    bool? removeDocuments,
    bool? exportStatisticsTable,
    bool? approvedAndRejected,
    bool? approvedOnly,
    bool? dashboard,
  }) {
    final newTimestamps = List<int>.from(timestamps)..add(DateTime.now().millisecondsSinceEpoch);

    return KnowledgeHubModulePermission(
      timestamps: newTimestamps,
      roleId: roleId,
      createKnowledgeHub: createKnowledgeHub != null ? (List<bool>.from(this.createKnowledgeHub)..add(createKnowledgeHub)) : this.createKnowledgeHub,
      selectOwningDepartment: selectOwningDepartment != null ? (List<bool>.from(this.selectOwningDepartment)..add(selectOwningDepartment)) : this.selectOwningDepartment,
      downloadDocuments: downloadDocuments != null ? (List<bool>.from(this.downloadDocuments)..add(downloadDocuments)) : this.downloadDocuments,
      viewDocuments: viewDocuments != null ? (List<bool>.from(this.viewDocuments)..add(viewDocuments)) : this.viewDocuments,
      analytics: analytics != null ? (List<bool>.from(this.analytics)..add(analytics)) : this.analytics,
      statistics: statistics != null ? (List<bool>.from(this.statistics)..add(statistics)) : this.statistics,
      inquiriesAndComments: inquiriesAndComments != null ? (List<bool>.from(this.inquiriesAndComments)..add(inquiriesAndComments)) : this.inquiriesAndComments,
      allowsRemovingDocumentsOwnedByAnyone: allowsRemovingDocumentsOwnedByAnyone != null ? (List<bool>.from(this.allowsRemovingDocumentsOwnedByAnyone)..add(allowsRemovingDocumentsOwnedByAnyone)) : this.allowsRemovingDocumentsOwnedByAnyone,
      editDocumentWithApproval: editDocumentWithApproval != null ? (List<bool>.from(this.editDocumentWithApproval)..add(editDocumentWithApproval)) : this.editDocumentWithApproval,
      editDocumentWithoutApproval: editDocumentWithoutApproval != null ? (List<bool>.from(this.editDocumentWithoutApproval)..add(editDocumentWithoutApproval)) : this.editDocumentWithoutApproval,
      removeDocuments: removeDocuments != null ? (List<bool>.from(this.removeDocuments)..add(removeDocuments)) : this.removeDocuments,
      exportStatisticsTable: exportStatisticsTable != null ? (List<bool>.from(this.exportStatisticsTable)..add(exportStatisticsTable)) : this.exportStatisticsTable,
      approvedAndRejected: approvedAndRejected != null ? (List<bool>.from(this.approvedAndRejected)..add(approvedAndRejected)) : this.approvedAndRejected,
      approvedOnly: approvedOnly != null ? (List<bool>.from(this.approvedOnly)..add(approvedOnly)) : this.approvedOnly,
      dashboard: dashboard != null ? (List<bool>.from(this.dashboard)..add(dashboard)) : this.dashboard,
    );
  }
}

