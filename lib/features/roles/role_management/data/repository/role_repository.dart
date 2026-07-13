import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/home/home_page/data_source/models/acces_type_model/edit_by_model.dart';
import 'package:demo_app/core/network/get_base_url.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/settings/presentation/controller/add_company_controller.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/role_status.dart';
import 'package:demo_app/features/roles/role_management/data/data_source/remote_data_source/role_remote_data_source.dart';
import 'package:demo_app/features/roles/role_management/data/models/role_model.dart';

class RoleRepository {
  final RoleRemoteDataSource remoteDataSource = RoleRemoteDataSource();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Collection names
  static const String ROLES_COLLECTION = 'Roles';
  static const String SUBSCRIPTION_ADMIN_COLLECTION = 'Subscription_Admin';
  static const String SUBSCRIPTION_PERMISSION_ADMIN_COLLECTION = 'Subscription_Permission_Admin';

  // Regular employee permission collections
  static const String SERVICES_PERMISSIONS = 'services_module_permissions';
  static const String FORM_BUILDER_PERMISSIONS = 'form_builder_module_permissions';
  static const String MESSAGES_PERMISSIONS = 'messages_module_permissions';
  static const String INVENTORY_PERMISSIONS = 'inventory_module_permissions';
  static const String SETTINGS_PERMISSIONS = 'settings_module_permissions';
  static const String QIYAS_PERMISSIONS = 'qiyas_module_permissions';
  static const String GRC_PERMISSIONS = 'grc_module_permissions';
  static const String KNOWLEDGE_HUB_PERMISSIONS = 'knowledge_hub_module_permissions';
  static const String ROLES_PERMISSIONS = 'roles_permissions';
  static const String HR_PERMISSIONS = 'hr_module_permissions';
  static const String NOTIFICATION_PERMISSIONS = 'notification_module_permissions';

  // Helper method to get collection reference with base path
  CollectionReference _getCollection(String collectionName) {
    return firestore.collection(getBaseUrl(collectionName));
  }

  bool isCompanyAdminByEmail(String email) {
    try {
      CompanyController companyController = Get.find<CompanyController>();
      String? adminEmail = companyController.company?.email?.emails?.last;

      if (adminEmail == null || adminEmail.isEmpty) {
        return false;
      }

      bool isAdmin = (email.toLowerCase().trim() == adminEmail.toLowerCase().trim());
      return isAdmin;
    } catch (e) {
      return false;
    }
  }

  Future<Either<FirebaseFailure, Map<String, bool>>> getAdminRestrictionsForModule({
    required String companyId,
    required String moduleName,
  }) async {
    try {
      DocumentSnapshot demoPermDoc = await firestore
          .collection('Demo_Permissions')
          .doc(companyId)
          .get();

      if (!demoPermDoc.exists) {
        return Right({});
      }

      Map<String, dynamic> demoPermissions = demoPermDoc.data() as Map<String, dynamic>;

      if (!demoPermissions.containsKey(moduleName)) {
        return Right({});
      }

      if (demoPermissions[moduleName] is! Map) {
        return Right({});
      }

      Map<String, dynamic> modulePerms = Map<String, dynamic>.from(demoPermissions[moduleName]);
      Map<String, bool> restrictions = {};

      modulePerms.forEach((key, value) {
        if (key != 'Role_Id' && key != 'timestamps') {
          restrictions[key] = (value == true);
        }
      });

      return Right(restrictions);

    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<FirebaseFailure, RoleHistoryModel?>> getAdminRole() async {
    try {
      String? currentUserEmail;
      try {
        final employeeController = Get.find<MainCoreEmployeeController>();
        currentUserEmail = employeeController.employeeEntity?.email;

        if (currentUserEmail == null || currentUserEmail.isEmpty) {
          return Left(FirebaseFailure('Current user email not found'));
        }
      } catch (e) {
        return Left(FirebaseFailure('Cannot access employee controller'));
      }

      QuerySnapshot snapshot = await _getCollection(SUBSCRIPTION_ADMIN_COLLECTION)
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return Right(null);
      }

      Map<String, dynamic> data = snapshot.docs.first.data() as Map<String, dynamic>;
      data['_documentId'] = snapshot.docs.first.id;

      RoleHistoryModel role = RoleHistoryModel.fromMap(data);

      return Right(role);
    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<FirebaseFailure, Map<String, Map<String, bool>>>> getAdminPermissions(String roleId) async {
    try {
      DocumentSnapshot doc = await _getCollection(SUBSCRIPTION_PERMISSION_ADMIN_COLLECTION)
          .doc(roleId)
          .get();

      if (!doc.exists) {
        return Right({});
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Map<String, Map<String, bool>> adminPermissions = {};

      data.forEach((key, value) {
        if (key == 'companyId' ||
            key == 'roleId' ||
            key == 'createdAt' ||
            key == 'createdBy' ||
            key == 'timestamps') {
          return;
        }

        if (value is Map) {
          Map<String, bool> modulePerms = {};
          (value as Map).forEach((permKey, permValue) {
            modulePerms[permKey.toString()] = permValue == true;
          });
          adminPermissions[key] = modulePerms;
        }
      });

      return Right(adminPermissions);
    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<FirebaseFailure, Map<String, Map<String, bool>>>> validatePermissionsAgainstAdmin({
    required Map<String, Map<String, bool>> requestedPermissions,
    required String companyId,
  }) async {
    try {
      DocumentSnapshot demoPermDoc = await firestore
          .collection('Demo_Permissions')
          .doc(companyId)
          .get();

      if (!demoPermDoc.exists) {
        return Right(requestedPermissions);
      }

      Map<String, dynamic> demoPermissions = demoPermDoc.data() as Map<String, dynamic>;
      Map<String, Map<String, bool>> validatedPermissions = {};

      requestedPermissions.forEach((moduleName, modulePermissions) {
        if (demoPermissions.containsKey(moduleName) &&
            demoPermissions[moduleName] is Map) {
          Map<String, dynamic> adminModulePerms =
          Map<String, dynamic>.from(demoPermissions[moduleName]);

          Map<String, bool> validatedModulePerms = {};

          modulePermissions.forEach((permKey, requestedValue) {
            bool adminAllows = (adminModulePerms[permKey] == true);

            if (adminAllows) {
              validatedModulePerms[permKey] = requestedValue;
            } else {
              validatedModulePerms[permKey] = false;
            }
          });

          validatedPermissions[moduleName] = validatedModulePerms;
        } else {
          validatedPermissions[moduleName] = modulePermissions;
        }
      });

      return Right(validatedPermissions);

    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<bool> isPermissionAllowedByAdmin({
    required String companyId,
    required String moduleName,
    required String permissionKey,
  }) async {
    try {
      DocumentSnapshot demoPermDoc = await firestore
          .collection('Demo_Permissions')
          .doc(companyId)
          .get();

      if (!demoPermDoc.exists) {
        return true;
      }

      Map<String, dynamic> demoPermissions = demoPermDoc.data() as Map<String, dynamic>;

      if (demoPermissions.containsKey(moduleName) &&
          demoPermissions[moduleName] is Map) {
        Map<String, dynamic> modulePerms =
        Map<String, dynamic>.from(demoPermissions[moduleName]);

        return modulePerms[permissionKey] == true;
      }

      return true;

    } catch (e) {
      return false;
    }
  }

  Future<Either<Failure, dynamic>> addNewRole({
    required List<String> selectedModules,
    required String roleName,
    required String roleNameAr,
    required String roleDescription,
    required String roleDescriptionAr,
    required String createdBy,
    required String? roleImage,
    required Map<String, Map<String, bool>> modulePermissions,
    RoleStatus status = RoleStatus.active,
  }) async {
    try {
      String companyId = getBaseUrl('').split('/').where((s) => s.isNotEmpty).last;

      Either<FirebaseFailure, Map<String, Map<String, bool>>> validationResult =
      await validatePermissionsAgainstAdmin(
        requestedPermissions: modulePermissions,
        companyId: companyId,
      );

      if (validationResult.isLeft()) {
        return validationResult;
      }

      Map<String, Map<String, bool>> validatedPermissions =
      validationResult.getOrElse(() => {});

      for (var module in validatedPermissions.keys) {
        var perms = validatedPermissions[module];
        if (perms != null) {
          for (var permValue in perms.values) {
            if (permValue is List) {
              throw Exception("Nested array detected in module '$module' permissions");
            }
          }
        }
      }

      String roleId = await RoleHistoryModel.generateNextRoleId();

      DocumentSnapshot existingDoc = await _getCollection(ROLES_COLLECTION).doc(roleId).get();
      if (existingDoc.exists) {
        throw Exception("Role ID collision detected - ID $roleId already exists!");
      }

      String? roleImageLink;
      if (roleImage != null) {
        try {
          dynamic uploadResult = await remoteDataSource.uploadRoleImage(roleImage);

          if (uploadResult is Either) {
            dynamic value = uploadResult.fold(
                  (failure) => null,
                  (success) => success,
            );

            if (value == null) {
              Failure failure = uploadResult.fold((l) => l, (r) => FirebaseFailure('Unexpected'));
              return Left(failure);
            }

            roleImageLink = value.toString();
          } else {
            return Left(FirebaseFailure('Unexpected result type from image upload'));
          }
        } catch (imageError, stackTrace) {
          return Left(FirebaseFailure('Image upload failed: $imageError'));
        }
      }

      RoleHistoryModel role = RoleHistoryModel.createNew(
        roleId: roleId,
        roleName: roleName,
        roleNameAr: roleNameAr,
        roleDescription: roleDescription,
        roleDescriptionAr: roleDescriptionAr,
        roleImage: roleImageLink ?? '',
        createdAt: Timestamp.now(),
        createdBy: createdBy,
        status: status,
        selectedModules: selectedModules,
      );

      WriteBatch batch = firestore.batch();

      DocumentReference roleRef = _getCollection(ROLES_COLLECTION).doc(roleId);

      Map<String, dynamic> roleMap = role.toMap();

      if (roleMap['Selected_Modules'] is List) {
        var modules = roleMap['Selected_Modules'] as List;
        for (var module in modules) {
          if (module is List) {
            throw Exception("Nested arrays in Selected_Modules are not supported");
          }
        }
      }

      batch.set(roleRef, roleMap);

      await _createPermissionDocuments(batch, roleId, selectedModules, validatedPermissions);

      await batch.commit();

      return Right('Role created successfully');
    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  // ✅ FIXED: Added status parameter
  Future<Either<Failure, dynamic>> updateRole({
    required RoleHistoryModel role,
    required String currentUserEmail,
    required String roleDescription,
    required String roleDescriptionAr,
    String? roleNameAr,
    required String? roleImage,
    required List<String> selectedModules,
    required Map<String, Map<String, bool>> modulePermissions,
    RoleStatus status = RoleStatus.active, // ✅ ADDED
  }) async {
    try {
      String roleId = role.roleId;
      int timestamp = DateTime.now().millisecondsSinceEpoch;

      String companyId = getBaseUrl('').split('/').where((s) => s.isNotEmpty).last;

      Either<FirebaseFailure, Map<String, Map<String, bool>>> validationResult =
      await validatePermissionsAgainstAdmin(
        requestedPermissions: modulePermissions,
        companyId: companyId,
      );

      if (validationResult.isLeft()) {
        return validationResult;
      }

      Map<String, Map<String, bool>> validatedPermissions =
      validationResult.getOrElse(() => {});

      WriteBatch batch = firestore.batch();

      EditBy currentEditBy = role.currentEditBy ?? EditBy(editorEmail: [], timestamps: []);
      List<String?> editorEmails = List<String?>.from(currentEditBy.editorEmail ?? []);
      List<Timestamp?> editTimestamps = List<Timestamp?>.from(currentEditBy.timestamps ?? []);
      editorEmails.add(currentUserEmail);
      editTimestamps.add(Timestamp.now());
      EditBy updatedEditBy = EditBy(
        editorEmail: editorEmails,
        timestamps: editTimestamps,
      );

      String? roleImageLink;
      if (roleImage != null) {
        try {
          dynamic uploadResult = await remoteDataSource.uploadRoleImage(roleImage);

          if (uploadResult is Either) {
            dynamic value = uploadResult.fold(
                  (failure) => null,
                  (success) => success,
            );

            if (value == null) {
              Failure failure = uploadResult.fold((l) => l, (r) => FirebaseFailure('Unexpected'));
              return Left(failure);
            }

            roleImageLink = value.toString();
          } else {
            return Left(FirebaseFailure('Unexpected result type from image upload'));
          }
        } catch (imageError, stackTrace) {
          return Left(FirebaseFailure('Image upload failed: $imageError'));
        }
      }

      RoleHistoryModel updatedRole = role.copyWith(
        roleDescription: roleDescription,
        roleDescriptionAr: roleDescriptionAr,
        roleNameAr: roleNameAr,
        roleImage: roleImageLink,
        selectedModules: selectedModules,
        editBy: updatedEditBy,
        status: status.name, // ✅ ADDED
      );

      Map<String, dynamic> synchronizedRoleData = updatedRole.toMap();

      DocumentReference roleRef = _getCollection(ROLES_COLLECTION).doc(roleId);
      batch.update(roleRef, synchronizedRoleData);

      for (String moduleName in selectedModules) {
        String collectionName = _getPermissionCollectionName(moduleName);
        if (collectionName.isEmpty) continue;

        DocumentReference permRef = _getCollection(collectionName).doc(roleId);
        DocumentSnapshot permDoc = await permRef.get();

        Map<String, dynamic> synchronizedPermissionData;

        if (permDoc.exists) {
          Map<String, dynamic> existingPermissions = permDoc.data() as Map<String, dynamic>;
          synchronizedPermissionData = _synchronizeModulePermissions(
            existingPermissions: existingPermissions,
            newPermissions: validatedPermissions[moduleName] ?? {},
            timestamp: timestamp,
            roleId: roleId,
          );
        } else {
          synchronizedPermissionData = _createNewModulePermissions(
            permissions: validatedPermissions[moduleName] ?? {},
            timestamp: timestamp,
            roleId: roleId,
          );
        }

        batch.set(permRef, synchronizedPermissionData);
      }

      DocumentReference subPermRef = firestore
          .collection(getBaseUrl('Subscription_Permission_Admin'))
          .doc(roleId);

      Map<String, dynamic> subPermData = {
        'companyId': companyId,
        'roleId': roleId,
        'timestamps': FieldValue.arrayUnion([timestamp]),
      };

      for (String moduleName in selectedModules) {
        if (validatedPermissions.containsKey(moduleName)) {
          subPermData[moduleName] = validatedPermissions[moduleName];
        }
      }

      batch.set(subPermRef, subPermData, SetOptions(merge: true));

      List<String> oldModules = role.currentSelectedModules;
      List<String> removedModules = oldModules.where((m) => !selectedModules.contains(m)).toList();

      if (removedModules.isNotEmpty) {
        for (String moduleName in removedModules) {
          String collectionName = _getPermissionCollectionName(moduleName);
          if (collectionName.isNotEmpty) {
            DocumentReference permRef = _getCollection(collectionName).doc(roleId);
            batch.delete(permRef);
          }
        }
      }

      await batch.commit();

      return Right('Role updated successfully');
    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<FirebaseFailure, dynamic>> getUnDeletedRoles() async {
    try {
      List<RoleHistoryModel> roleTypeList = [];

      try {
        String subscriptionAdminPath = getBaseUrl(SUBSCRIPTION_ADMIN_COLLECTION);

        QuerySnapshot subscriptionSnapshot = await firestore
            .collection(subscriptionAdminPath)
            .get();

        for (QueryDocumentSnapshot doc in subscriptionSnapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['_documentId'] = doc.id;

            RoleHistoryModel role = RoleHistoryModel.fromMap(data);

            roleTypeList.add(role);

          } catch (e, stackTrace) {
            continue;
          }
        }

      } catch (e, stackTrace) {
      }

      try {
        String rolesPath = getBaseUrl(ROLES_COLLECTION);

        QuerySnapshot rolesSnapshot = await firestore
            .collection(rolesPath)
            .get();

        for (QueryDocumentSnapshot doc in rolesSnapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['_documentId'] = doc.id;

            RoleHistoryModel role = RoleHistoryModel.fromMap(data);

            if (role.currentStatus != RoleStatus.deleted) {
              roleTypeList.add(role);
            }
          } catch (e) {
            continue;
          }
        }

      } catch (e, stackTrace) {
      }

      return Right(roleTypeList);

    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<FirebaseFailure, dynamic>> deleteRole({
    required RoleHistoryModel role,
    required String currentUserEmail,
  }) async {
    try {
      String roleId = role.roleId;

      WriteBatch batch = firestore.batch();

      EditBy currentEditBy = role.currentEditBy ?? EditBy(editorEmail: [], timestamps: []);
      List<String?> editorEmails = List<String?>.from(currentEditBy.editorEmail ?? []);
      List<Timestamp?> editTimestamps = List<Timestamp?>.from(currentEditBy.timestamps ?? []);
      editorEmails.add(currentUserEmail);
      editTimestamps.add(Timestamp.now());
      EditBy updatedEditBy = EditBy(
        editorEmail: editorEmails,
        timestamps: editTimestamps,
      );

      RoleHistoryModel updatedRole = role.copyWith(
        status: RoleStatus.deleted.name,
        editBy: updatedEditBy,
      );

      DocumentReference roleRef = _getCollection(ROLES_COLLECTION).doc(roleId);
      DocumentSnapshot docSnapshot = await roleRef.get();

      if (!docSnapshot.exists) {
        return Left(FirebaseFailure('Role document not found with ID: $roleId'));
      }

      batch.update(roleRef, updatedRole.toMap());

      List<String> permissionCollections = [
        SERVICES_PERMISSIONS,
        FORM_BUILDER_PERMISSIONS,
        MESSAGES_PERMISSIONS,
        INVENTORY_PERMISSIONS,
        SETTINGS_PERMISSIONS,
        GRC_PERMISSIONS,
        QIYAS_PERMISSIONS,
        KNOWLEDGE_HUB_PERMISSIONS,
        ROLES_PERMISSIONS,
        HR_PERMISSIONS,
        NOTIFICATION_PERMISSIONS,
      ];

      for (String collection in permissionCollections) {
        DocumentReference permRef = _getCollection(collection).doc(roleId);
        DocumentSnapshot permSnapshot = await permRef.get();
        if (permSnapshot.exists) {
          batch.delete(permRef);
        }
      }

      String companyId = getBaseUrl('').split('/').where((s) => s.isNotEmpty).last;
      DocumentReference subPermRef = firestore
          .collection(getBaseUrl('Subscription_Permission_Admin'))
          .doc(roleId);

      batch.delete(subPermRef);

      await batch.commit();
      return Right('Role deleted successfully');
    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<FirebaseFailure, String>> fixCorruptedQiyasDocument(String roleId) async {
    try {
      DocumentReference permRef = _getCollection(QIYAS_PERMISSIONS).doc(roleId);
      await permRef.delete();

      Map<String, dynamic> properPermissions = {
        'Role_Id': roleId,
        'timestamps': [DateTime.now().millisecondsSinceEpoch],
        'Export_Table': [false],
        'Export_Champion_Table': [false],
        'Assigned_Evidence_Module': [false],
        'Delete_Qiyas': [false],
        'Champions_Module': [false],
        'Dashboard_Module': [false],
        'Edit_Evidence': [false],
        'Uploaded_Documents_Module': [false],
        'Remove_Champion': [false],
        'Assign_Champion': [false],
        'Edit_Qiyas_Details': [false],
        'Change_Submission_Status_Module': [false],
        'Qiyas_Permissions_Module': [false],
        'Approvals_Module': [false],
        'Reassign_Champion': [false],
        'Vision_Badges': [false],
        'Bulk_Upload': [false],
      };

      await permRef.set(properPermissions);
      return Right('Qiyas document fixed successfully');
    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<void> _createPermissionDocuments(
      WriteBatch batch,
      String roleId,
      List<String> selectedModules,
      Map<String, Map<String, bool>> modulePermissions,
      ) async {
    for (int i = 0; i < selectedModules.length; i++) {
      String module = selectedModules[i];
      String collectionName = _getPermissionCollectionName(module);

      if (collectionName.isEmpty) {
        continue;
      }

      DocumentReference permRef = _getCollection(collectionName).doc(roleId);

      Map<String, dynamic> permissionData = {
        'Role_Id': roleId,
        'timestamps': [DateTime.now().millisecondsSinceEpoch],
      };

      Map<String, bool>? permissions = modulePermissions[module];
      if (permissions != null && permissions.isNotEmpty) {
        permissions.forEach((key, value) {
          String dbKey = key.trim().replaceAll(RegExp(r'\s+'), '_');
          permissionData[dbKey] = [value];
        });
      }

      bool hasNestedArrays = false;
      permissionData.forEach((key, value) {
        if (value is List) {
          for (var item in value) {
            if (item is List) {
              hasNestedArrays = true;
            }
          }
        }
      });

      if (hasNestedArrays) {
        throw Exception("Nested arrays are not supported in Firestore");
      }

      batch.set(permRef, permissionData);
    }
  }

  String _getPermissionCollectionName(String module) {
    switch (module.toLowerCase()) {
      case 'services':
        return SERVICES_PERMISSIONS;
      case 'form_builder':
        return FORM_BUILDER_PERMISSIONS;
      case 'messages':
        return MESSAGES_PERMISSIONS;
      case 'inventory':
        return INVENTORY_PERMISSIONS;
      case 'settings':
        return SETTINGS_PERMISSIONS;
      case 'qiyas':
        return QIYAS_PERMISSIONS;
      case 'grc':
        return GRC_PERMISSIONS;
      case 'knowledge_hub':
        return KNOWLEDGE_HUB_PERMISSIONS;
      case 'roles':
        return ROLES_PERMISSIONS;
      case 'hr':
        return HR_PERMISSIONS;
      case 'notification':
        return NOTIFICATION_PERMISSIONS;
      default:
        return '';
    }
  }

  Map<String, dynamic> _synchronizeModulePermissions({
    required Map<String, dynamic> existingPermissions,
    required Map<String, bool> newPermissions,
    required int timestamp,
    required String roleId,
  }) {
    Map<String, dynamic> synchronizedData = {'Role_Id': roleId};

    List<int> timestamps = [];
    if (existingPermissions.containsKey('timestamps') && existingPermissions['timestamps'] is List) {
      timestamps = List<int>.from(existingPermissions['timestamps']).toList();
    }

    timestamps.add(timestamp);
    synchronizedData['timestamps'] = timestamps;

    Set<String> allPermissionKeys = {};

    existingPermissions.forEach((key, value) {
      if (key != 'Role_Id' && key != 'timestamps') {
        allPermissionKeys.add(key);
      }
    });

    newPermissions.forEach((key, value) {
      String dbKey = key.trim().replaceAll(RegExp(r'\s+'), '_');
      allPermissionKeys.add(dbKey);
    });

    for (String permissionKey in allPermissionKeys) {
      List<bool> permissionHistory = [];

      if (existingPermissions.containsKey(permissionKey) && existingPermissions[permissionKey] is List) {
        permissionHistory = List<bool>.from(
            existingPermissions[permissionKey].map((v) => v == true)
        ).toList();
      } else {
        permissionHistory = List.filled(timestamps.length - 1, false, growable: true);
      }

      bool currentValue = permissionHistory.isNotEmpty ? permissionHistory.last : false;
      bool newValue = currentValue;

      for (String newPermKey in newPermissions.keys) {
        String dbKey = newPermKey.trim().replaceAll(RegExp(r'\s+'), '_');
        if (dbKey == permissionKey) {
          newValue = newPermissions[newPermKey]!;
          break;
        }
      }

      permissionHistory.add(newValue);
      synchronizedData[permissionKey] = permissionHistory;
    }

    return synchronizedData;
  }

  Map<String, dynamic> _createNewModulePermissions({
    required Map<String, bool> permissions,
    required int timestamp,
    required String roleId,
  }) {
    Map<String, dynamic> permissionData = {
      'Role_Id': roleId,
      'timestamps': [timestamp],
    };

    permissions.forEach((key, value) {
      String dbKey = key.trim().replaceAll(RegExp(r'\s+'), '_');
      permissionData[dbKey] = [value];
    });

    return permissionData;
  }

  Future<Either<FirebaseFailure, Map<String, dynamic>?>> getRolePermissions({
    required String roleId,
    required String module,
  }) async {
    try {
      String collectionName = _getPermissionCollectionName(module);
      if (collectionName.isEmpty) {
        return Right(null);
      }

      DocumentSnapshot doc = await _getCollection(collectionName).doc(roleId).get();

      if (doc.exists) {
        return Right(doc.data() as Map<String, dynamic>);
      } else {
        return Right(null);
      }
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<FirebaseFailure, Map<String, Map<String, dynamic>>>> getAllRolePermissions({
    required String roleId,
    required List<String> selectedModules,
  }) async {
    try {
      Map<String, Map<String, dynamic>> allPermissions = {};

      for (String module in selectedModules) {
        Either<FirebaseFailure, Map<String, dynamic>?> result =
        await getRolePermissions(roleId: roleId, module: module);

        if (result.isRight()) {
          Map<String, dynamic>? permissions = result.getOrElse(() => null);
          if (permissions != null) {
            allPermissions[module] = permissions;
          }
        }
      }

      return Right(allPermissions);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<FirebaseFailure, String>> updateModulePermissions({
    required String roleId,
    required String module,
    required Map<String, bool> permissions,
  }) async {
    try {
      String collectionName = _getPermissionCollectionName(module);
      if (collectionName.isEmpty) {
        return Left(FirebaseFailure('Invalid module: $module'));
      }

      DocumentReference permRef = _getCollection(collectionName).doc(roleId);
      DocumentSnapshot doc = await permRef.get();

      Map<String, dynamic> existingData = {};

      if (doc.exists) {
        existingData = doc.data() as Map<String, dynamic>;
      } else {
        existingData = {
          'Role_Id': roleId,
          'timestamps': [],
        };
      }

      int newTimestamp = DateTime.now().millisecondsSinceEpoch;
      List<int> timestamps = List<int>.from(existingData['timestamps'] ?? []);
      timestamps.add(newTimestamp);
      existingData['timestamps'] = timestamps;

      permissions.forEach((key, value) {
        String dbKey = key.trim().replaceAll(RegExp(r'\s+'), '_');
        List<bool> permissionHistory = List<bool>.from(existingData[dbKey] ?? []);
        permissionHistory.add(value);
        existingData[dbKey] = permissionHistory;
      });

      await permRef.set(existingData);
      return Right('Module permissions updated successfully');
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
}