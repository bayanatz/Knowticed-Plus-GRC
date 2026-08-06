/// ************************* FILE INFO ************************* ///
/// File Name: permission_sync_service.dart
/// Purpose: Handles real-time synchronization between Demo_Permissions,
///          Subscription_Permission_Admin, and module permission collections
/// Author: [Amr Mesbah Hosny]
/// Created At: [11/12/2025]
/// FIXED: Now correctly syncs FALSE→TRUE by iterating Demo_Permissions keys
/// DEBUG VERSION: Extensive logging to identify sync issues
///
/// SYNC FLOW:
/// 1. Demo_Permissions → Master Admin Subscription_Permission_Admin
/// 2. Demo_Permissions → Employee Subscription_Permission_Admin (enforce restrictions)
/// 3. Employee Subscription_Permission_Admin → Module collections

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/network/api_constants.dart';

import 'package:grc_module/core/network/get_base_url.dart';

class PermissionSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, StreamSubscription> _subscriptions = {};
  String? _companyId;

  void initialize(String companyId) {
    //print("\n🔄 ════════════════════════════════════════");
    //print("🔄 PermissionSyncService.initialize()");
    //print("🔄 Company ID: $companyId");
    //print("🔄 ════════════════════════════════════════");
    _companyId = companyId;
  }

  void startDemoPermissionsListener() {
    if (_companyId == null || _companyId!.isEmpty) {
      //print("❌ Cannot start Demo_Permissions listener - no company ID");
      return;
    }

    //print("\n🎧 Starting Demo_Permissions listener...");
    //print("   Path: Demo_Permissions/$_companyId");

    _subscriptions['demo_permissions']?.cancel();

    _subscriptions['demo_permissions'] = _firestore
        .collection('Demo_Permissions')
        .doc(_companyId)
        .snapshots()
        .listen(
          (snapshot) async {
        if (!snapshot.exists) {
          //print("⚠️ Demo_Permissions document does not exist");
          return;
        }

        // Firestore delivers a local echo before the server ack, so every write
        // arrives twice. Ignore the pending-write copy or the sync runs (and
        // appends) twice per change.
        if (snapshot.metadata.hasPendingWrites) {
          //print("⏭️ Skipping local echo of Demo_Permissions write");
          return;
        }

        //print("\n🔔 Demo_Permissions changed!");
        //print("   Timestamp: ${DateTime.now()}");

        await _syncDemoPermissionsToAllRoles(snapshot);
      },
      onError: (error) {
        //print("❌ Error in Demo_Permissions listener: $error");
      },
    );

    //print("✅ Demo_Permissions listener started");
  }

  /// ✅ FIXED: Iterate through Demo_Permissions keys, not current subscription keys
  Future<void> _syncDemoPermissionsToAllRoles(
      DocumentSnapshot<Map<String, dynamic>> demoPermSnapshot) async {
    try {
      //print("\n📤 ════════════════════════════════════════");
      //print("📤 [START] _syncDemoPermissionsToAllRoles()");
      //print("📤 Syncing Demo_Permissions to all roles_module");
      //print("📤 ════════════════════════════════════════");

      if (!demoPermSnapshot.exists) {
        //print("⚠️ Demo_Permissions document doesn't exist");
        return;
      }

      Map<String, dynamic> demoPermissions = demoPermSnapshot.data()!;
      //print("🔍 Demo_Permissions has ${demoPermissions.keys.length} keys");

      QuerySnapshot rolesSnapshot = await _firestore

          .collection(getBaseUrl('Roles'))
          .get();

      //print("📊 [_syncDemoPermissionsToAllRoles] Found ${rolesSnapshot.docs.length} roles_module");

      WriteBatch batch = _firestore.batch();
      int updateCount = 0;

      for (var roleDoc in rolesSnapshot.docs) {
        //print("\n🔄 [LOOP START] Processing role document...");

        Map<String, dynamic> roleData = roleDoc.data() as Map<String, dynamic>;
        String roleId = roleDoc.id;
        String roleName = '';

        if (roleData['roleName'] is List && (roleData['roleName'] as List).isNotEmpty) {
          roleName = roleData['roleName'][0].toString();
        } else if (roleData['roleName'] is String) {
          roleName = roleData['roleName'];
        }

        //print("   🎭 [ROLE] Name: '$roleName' | ID: $roleId");

        bool isMasterAdmin = roleName.toLowerCase().contains('master') &&
            roleName.toLowerCase().contains('admin');

        //print("   🔍 [CHECK] Is Master Admin? $isMasterAdmin");

        DocumentReference subPermRef = _firestore

            .collection(getBaseUrl('Subscription_Permission_Admin'))
            .doc(roleId);

        //print("   📍 [PATH] Subscription_Permission_Admin/$roleId");

        DocumentSnapshot subPermDoc = await subPermRef.get();

        if (!subPermDoc.exists) {
          //print("      ⚠️ [SKIP] No Subscription_Permission_Admin found for this role");
          continue;
        }

        //print("   ✅ [FOUND] Subscription_Permission_Admin document exists");

        Map<String, dynamic> currentSubPerm = subPermDoc.data() as Map<String, dynamic>;
        //print("   📊 [DATA] Current subscription has ${currentSubPerm.keys.length} keys");

        Map<String, dynamic> updatedSubPerm = {
          'companyId': _companyId,
          'roleId': roleId,
        };

        // Preserve timestamps
        if (currentSubPerm.containsKey('timestamps')) {
          List<int> timestamps = List<int>.from(currentSubPerm['timestamps']);
          timestamps.add(DateTime.now().millisecondsSinceEpoch);
          updatedSubPerm['timestamps'] = timestamps;
        } else {
          updatedSubPerm['timestamps'] = [DateTime.now().millisecondsSinceEpoch];
        }

        int restrictedCount = 0;
        int allowedCount = 0;
        int changesDetected = 0;

        //print("   🔄 [MODULES] Starting to iterate Demo_Permissions modules...");

        // ✅ FIX: Iterate through Demo_Permissions modules (the source of truth)
        for (String moduleName in demoPermissions.keys) {
          if (moduleName == 'companyId' || moduleName == 'roleId' ||
              moduleName == 'timestamps' || moduleName == 'createdAt' ||
              moduleName == 'createdBy') {
            continue;
          }

          if (demoPermissions[moduleName] is! Map) {
            //print("      ⚠️ [SKIP] Module '$moduleName' is not a Map");
            continue;
          }

          //print("      📦 [MODULE] Processing: $moduleName");

          Map<String, dynamic> demoModulePerms =
          Map<String, dynamic>.from(demoPermissions[moduleName]);

          //print("         📊 [PERMS] Demo_Permissions has ${demoModulePerms.keys.length} permissions for $moduleName");

          // Get current module perms (if they exist)
          Map<String, dynamic> currentModulePerms = {};
          if (currentSubPerm.containsKey(moduleName) && currentSubPerm[moduleName] is Map) {
            currentModulePerms = Map<String, dynamic>.from(currentSubPerm[moduleName]);
            //print("         📊 [PERMS] Current subscription has ${currentModulePerms.keys.length} permissions for $moduleName");
          } else {
            //print("         ⚠️ [NEW] Module '$moduleName' not found in current subscription");
          }

          Map<String, bool> updatedModulePerms = {};

          // ✅ FIX: Loop through Demo_Permissions keys (not current keys)
          //print("         🔄 [ITERATE] Looping through Demo_Permissions keys for $moduleName...");

          demoModulePerms.forEach((permKey, demoValue) {
            bool adminAllows = (demoValue == true);
            bool currentValue = (currentModulePerms[permKey] == true);

            if (isMasterAdmin) {
              // ✅ Master Admin: Always copy from Demo_Permissions
              updatedModulePerms[permKey] = adminAllows;

              if (adminAllows != currentValue) {
                //print("            🔄 [CHANGE] $moduleName.$permKey: $currentValue → $adminAllows");
                changesDetected++;
              }
            } else {
              // Employee: If admin blocks it, force false; otherwise keep employee value
              if (adminAllows) {
                updatedModulePerms[permKey] = currentValue;
                allowedCount++;
              } else {
                updatedModulePerms[permKey] = false;
                restrictedCount++;
                if (currentValue) {
                  //print("            ❌ [FORCE] Forcing $moduleName.$permKey to FALSE");
                }
              }
            }
          });

          //print("         ✅ [DONE] Module $moduleName processed with ${updatedModulePerms.keys.length} permissions");

          updatedSubPerm[moduleName] = updatedModulePerms;
        }

        //print("   📊 [SUMMARY] Changes detected: $changesDetected");

        if (isMasterAdmin) {
          //print("      ✅ [MASTER] Master Admin synced from Demo_Permissions");
        } else if (restrictedCount > 0) {
          //print("      ✅ [EMPLOYEE] Allowed: $allowedCount, ❌ Restricted: $restrictedCount");
        }

        // `changesDetected` above only counts the Master-Admin branch, so
        // compare the rebuilt module maps against what is already stored.
        // Writing an identical document still notifies the
        // Subscription_Permission_Admin listener, which then appends another
        // history entry to every module collection — the main source of the
        // runaway index growth.
        bool roleChanged = false;
        for (final entry in updatedSubPerm.entries) {
          if (entry.value is! Map) continue;
          final Map newMap = entry.value as Map;
          final Map oldMap = currentSubPerm[entry.key] is Map
              ? currentSubPerm[entry.key] as Map
              : const {};
          if (newMap.length != oldMap.length) {
            roleChanged = true;
            break;
          }
          for (final k in newMap.keys) {
            if ((oldMap[k] == true) != (newMap[k] == true)) {
              roleChanged = true;
              break;
            }
          }
          if (roleChanged) break;
        }

        if (!roleChanged) {
          //print("   ⏭️ [SKIP] Subscription unchanged for role $roleId");
          continue;
        }

        //print("   💾 [BATCH] Adding role to batch update");
        batch.set(subPermRef, updatedSubPerm);
        updateCount++;

        //print("🔄 [LOOP END] Role processed\n");
      }

      //print("═══════════════════════════════════════════");
      //print("📊 [FINAL] Total roles_module to update: $updateCount");

      if (updateCount > 0) {
        //print("\n💾 [COMMIT START] Committing batch: ${updateCount} roles_module");
        await batch.commit();
        //print("✅ [COMMIT SUCCESS] Batch committed: Updated $updateCount roles_module");

        // Sync ALL roles_module to module collections
        //print("\n🔄 [MODULE SYNC START] Syncing all roles_module to module collections...");
        for (var roleDoc in rolesSnapshot.docs) {
          String roleId = roleDoc.id;

          //print("   🔄 [FETCH] Getting updated subscription for role $roleId");

          DocumentSnapshot updatedSubPermDoc = await _firestore

              .collection(getBaseUrl('Subscription_Permission_Admin'))
              .doc(roleId)
              .get();

          if (updatedSubPermDoc.exists) {
            Map<String, dynamic> subPermData = updatedSubPermDoc.data() as Map<String, dynamic>;

            //print("   🔄 [SYNC] Calling _syncSubscriptionToModuleCollections for role $roleId");
            await _syncSubscriptionToModuleCollections(
              roleId: roleId,
              subscriptionPermData: subPermData,
            );
          }
        }
        //print("✅ [MODULE SYNC END] All roles_module synced to module collections");
      } else {
        //print("⚠️ [NO UPDATES] No roles_module needed updating");
      }

      //print("\n📤 [END] _syncDemoPermissionsToAllRoles()");
      //print("📤 ════════════════════════════════════════\n");

    } catch (e, stackTrace) {
      //print("❌ [ERROR] Error syncing Demo_Permissions: $e");
      //print("Stack trace: $stackTrace");
    }
  }

  void startEmployeeSubscriptionListener(String roleId) {
    if (_companyId == null || _companyId!.isEmpty) {
      //print("❌ Cannot start employee listener - no company ID");
      return;
    }

    //print("\n🎧 Starting employee subscription listener...");
    //print("   Role ID: $roleId");
    //print("   Path: Demo/$_companyId/Subscription_Permission_Admin/$roleId");

    String listenerKey = 'employee_sub_$roleId';
    _subscriptions[listenerKey]?.cancel();

    _subscriptions[listenerKey] = _firestore

        .collection(getBaseUrl('Subscription_Permission_Admin'))
        .doc(roleId)
        .snapshots()
        .listen(
          (snapshot) async {
        if (!snapshot.exists) {
          //print("⚠️ Subscription_Permission_Admin document does not exist for role $roleId");
          return;
        }

        // Ignore the local-write echo (see Demo_Permissions listener above).
        if (snapshot.metadata.hasPendingWrites) {
          //print("⏭️ Skipping local echo for role $roleId");
          return;
        }

        //print("\n🔔 Employee Subscription changed!");
        //print("   Role ID: $roleId");
        //print("   Timestamp: ${DateTime.now()}");

        Map<String, dynamic> subscriptionPermissions =
        snapshot.data() as Map<String, dynamic>;

        await _syncSubscriptionToModuleCollections(
          roleId: roleId,
          subscriptionPermData: subscriptionPermissions,
        );
      },
      onError: (error) {
        //print("❌ Error in employee subscription listener for $roleId: $error");
      },
    );

    //print("✅ Employee subscription listener started for role $roleId");
  }

  Future<void> _syncSubscriptionToModuleCollections({
    required String roleId,
    required Map<String, dynamic> subscriptionPermData,
  }) async {
    try {
      //print("\n🔄 ════════════════════════════════════════");
      //print("🔄 [START] _syncSubscriptionToModuleCollections()");
      //print("🔄 Role ID: $roleId");
      //print("🔄 ════════════════════════════════════════");

      DocumentSnapshot demoPermDoc = await _firestore
          .collection('Demo_Permissions')
          .doc(_companyId)
          .get();

      Map<String, dynamic>? demoPermissions;
      if (demoPermDoc.exists) {
        demoPermissions = demoPermDoc.data() as Map<String, dynamic>?;
        //print("✅ Demo_Permissions loaded for validation");
      } else {
        //print("⚠️ Demo_Permissions not found - no restrictions to enforce");
      }

      int timestamp = DateTime.now().millisecondsSinceEpoch;
      WriteBatch batch = _firestore.batch();
      int updateCount = 0;

      for (String key in subscriptionPermData.keys) {
        if (key == 'companyId' ||
            key == 'roleId' ||
            key == 'timestamps' ||
            key == 'createdAt' ||
            key == 'createdBy') {
          continue;
        }

        String moduleName = key;
        //print("\n   📦 Processing module: $moduleName");

        if (subscriptionPermData[moduleName] is! Map) {
          //print("      ⚠️ Skipping - not a map");
          continue;
        }

        Map<String, dynamic> modulePerms =
        Map<String, dynamic>.from(subscriptionPermData[moduleName]);

        Map<String, bool> validatedPerms = {};

        if (demoPermissions != null &&
            demoPermissions.containsKey(moduleName) &&
            demoPermissions[moduleName] is Map) {

          Map<String, dynamic> adminModulePerms =
          Map<String, dynamic>.from(demoPermissions[moduleName]);

          //print("      🔒 Validating against admin restrictions...");
          int blocked = 0;
          int allowed = 0;

          modulePerms.forEach((permKey, permValue) {
            bool adminAllows = (adminModulePerms[permKey] == true);
            bool employeeValue = (permValue == true);

            if (adminAllows) {
              validatedPerms[permKey] = employeeValue;
              allowed++;
            } else {
              validatedPerms[permKey] = false;
              blocked++;
              if (employeeValue) {
                //print("         ❌ Forcing $permKey to FALSE (admin blocked)");
              }
            }
          });

          //print("      ✅ Allowed: $allowed, ❌ Blocked: $blocked");
        } else {
          //print("      ⚠️ No admin restrictions for this module");
          modulePerms.forEach((permKey, permValue) {
            validatedPerms[permKey] = (permValue == true);
          });
        }

        String collectionName = _getModuleCollectionName(moduleName);
        if (collectionName.isEmpty) {
          //print("      ⚠️ Unknown collection for module: $moduleName");
          continue;
        }

        DocumentReference docRef = _firestore

            .collection(getBaseUrl(collectionName))
            .doc(roleId);

        DocumentSnapshot existingDoc = await docRef.get();

        Map<String, dynamic> updateData = {
          'Role_Id': roleId,
        };

        if (existingDoc.exists) {
          Map<String, dynamic> existingData =
          existingDoc.data() as Map<String, dynamic>;

          // Only record a new history entry when a permission actually changed.
          // This method also runs when a listener re-delivers an unchanged
          // document (on attach, and again as the local-write echo), so
          // appending unconditionally grew every field by one element per
          // delivery — thousands of entries for a handful of real edits.
          bool anyChanged = false;
          final Map<String, List<bool>> histories = {};

          validatedPerms.forEach((permKey, newValue) {
            String dbKey = permKey.trim().replaceAll(RegExp(r'\s+'), '_');
            List<bool> history =
            List<bool>.from(existingData[dbKey] ?? []);
            histories[dbKey] = history;
            final bool lastValue = history.isNotEmpty ? history.last : false;
            if (history.isEmpty || lastValue != newValue) {
              anyChanged = true;
            }
          });

          if (!anyChanged) {
            //print("      ⏭️ No permission changed - skipping write");
            continue;
          }

          // Something changed: append to every field so the permission arrays
          // stay index-aligned with `timestamps`.
          List<int> timestamps =
          List<int>.from(existingData['timestamps'] ?? []);
          timestamps.add(timestamp);
          updateData['timestamps'] = timestamps;

          validatedPerms.forEach((permKey, newValue) {
            String dbKey = permKey.trim().replaceAll(RegExp(r'\s+'), '_');
            final List<bool> history = histories[dbKey]!..add(newValue);
            updateData[dbKey] = history;
          });

          //print("      ✅ Updating existing document with validated permissions");
        } else {
          updateData['timestamps'] = [timestamp];

          validatedPerms.forEach((permKey, value) {
            String dbKey = permKey.trim().replaceAll(RegExp(r'\s+'), '_');
            updateData[dbKey] = [value];
          });

          //print("      ✅ Creating new document with validated permissions");
        }

        batch.set(docRef, updateData);
        updateCount++;
      }

      if (updateCount > 0) {
        //print("\n💾 Committing batch: $updateCount module collections");
        await batch.commit();
        //print("✅ Module collections synced successfully with admin restrictions enforced");
      } else {
        //print("⚠️ No module collections to update");
      }

      //print("🔄 [END] _syncSubscriptionToModuleCollections()");
      //print("🔄 ════════════════════════════════════════\n");

    } catch (e, stackTrace) {
      //print("❌ Error syncing to module collections: $e");
      //print("Stack trace: $stackTrace");
    }
  }

  String _getModuleCollectionName(String moduleName) {
    switch (moduleName.toLowerCase()) {
      case 'services':
        return 'services_module_permissions';
      case 'services_app':
        return 'services_app_module_permissions';
      case 'messages':
        return 'messages_module_permissions';
      case 'inventory':
        return 'inventory_module_permissions';
      case 'settings':
        return 'settings_module_permissions';
      case 'qiyas':
        return 'qiyas_module_permissions';
      case 'grc':
        return 'grc_module_permissions';
      case 'knowledge_hub':
        return 'knowledge_hub_module_permissions';
      case 'roles':
        return 'roles_permissions';
      default:
        return '';
    }
  }

  Future<void> startAllEmployeeListeners() async {
    if (_companyId == null || _companyId!.isEmpty) {
      //print("❌ Cannot start employee listeners - no company ID");
      return;
    }

    //print("\n🎧 ════════════════════════════════════════");
    //print("🎧 [START] startAllEmployeeListeners()");
    //print("🎧 Starting ALL employee subscription listeners");
    //print("🎧 ════════════════════════════════════════");

    try {
      QuerySnapshot rolesSnapshot = await _firestore

          .collection(getBaseUrl('Roles'))
          .get();

      //print("📊 [startAllEmployeeListeners] Found ${rolesSnapshot.docs.length} roles_module");

      for (var roleDoc in rolesSnapshot.docs) {
        String roleId = roleDoc.id;
        Map<String, dynamic> roleData = roleDoc.data() as Map<String, dynamic>;

        String roleName = '';
        if (roleData['roleName'] is List && (roleData['roleName'] as List).isNotEmpty) {
          roleName = roleData['roleName'].last;
        }

        bool isMasterAdmin = roleName.toLowerCase().contains('master admin');

        if (!isMasterAdmin) {
          //print("   🎧 Starting listener for: $roleName (ID: $roleId)");
          startEmployeeSubscriptionListener(roleId);
        } else {
          //print("   ⏭️  [startAllEmployeeListeners] Skipping Master Admin: $roleName");
        }
      }

      //print("\n✅ All employee listeners started");

    } catch (e, stackTrace) {
      //print("\n❌ Error starting employee listeners: $e");
      //print("Stack trace: $stackTrace");
    }

    //print("🎧 [END] startAllEmployeeListeners()");
    //print("🎧 ════════════════════════════════════════\n");
  }

  void dispose() {
    //print("\n🛑 ════════════════════════════════════════");
    //print("🛑 Disposing PermissionSyncService");
    //print("🛑 Active listeners: ${_subscriptions.length}");
    //print("🛑 ════════════════════════════════════════");

    for (var entry in _subscriptions.entries) {
      //print("   🛑 Cancelling: ${entry.key}");
      entry.value.cancel();
    }

    _subscriptions.clear();
    _companyId = null;

    //print("✅ PermissionSyncService disposed");
    //print("🛑 ════════════════════════════════════════\n");
  }

  Future<bool> isPermissionAllowedByAdmin(String moduleName, String permissionKey) async {
    if (_companyId == null || _companyId!.isEmpty) {
      return false;
    }

    try {
      DocumentSnapshot demoPermDoc = await _firestore
          .collection('Demo_Permissions')
          .doc(_companyId)
          .get();

      if (!demoPermDoc.exists) {
        return false;
      }

      Map<String, dynamic> demoPermissions =
      demoPermDoc.data() as Map<String, dynamic>;

      if (demoPermissions.containsKey(moduleName) &&
          demoPermissions[moduleName] is Map) {
        Map<String, dynamic> modulePerms =
        Map<String, dynamic>.from(demoPermissions[moduleName]);

        return modulePerms[permissionKey] == true;
      }

      return false;

    } catch (e) {
      //print("❌ Error checking admin permission: $e");
      return false;
    }
  }

  Future<Map<String, bool>> getAdminRestrictionsForModule(String moduleName) async {
    if (_companyId == null || _companyId!.isEmpty) {
      return {};
    }

    try {
      DocumentSnapshot demoPermDoc = await _firestore
          .collection('Demo_Permissions')
          .doc(_companyId)
          .get();

      if (!demoPermDoc.exists) {
        return {};
      }

      Map<String, dynamic> demoPermissions =
      demoPermDoc.data() as Map<String, dynamic>;

      if (demoPermissions.containsKey(moduleName) &&
          demoPermissions[moduleName] is Map) {
        return Map<String, bool>.from(demoPermissions[moduleName]);
      }

      return {};

    } catch (e) {
      //print("❌ Error getting admin restrictions: $e");
      return {};
    }
  }
}