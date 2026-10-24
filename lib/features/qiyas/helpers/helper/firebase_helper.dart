import 'package:flutter/foundation.dart';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';

// const String MODULE_NAME_COLLECTION = "Modules";
// const String POLICY_NAME_COLLECTION = "Policies";
// const String CONTROL_NAME_COLLECTION = "Controls";
// const String CONTROL_OWNER_NAME_COLLECTION = "ControlOwners";

// class CrudHelper {
//   final CollectionReference users =
//       FirebaseFirestore.instance.collection(MODULE_NAME_COLLECTION);

//   Future<void> addModule(ModuleFirestore module) {
//     return users
//         .add(module.toMap())
//         .then((value) => log("User added successfully!"))
//         .catchError((error) => throw (ServerFailure(error.toString())));
//   }

//   Future<List<ModuleFirestore>> getModules() async {
//     // Get docs from collection reference
//     QuerySnapshot querySnapshot = await users.get();

//     // Get data from docs and convert map to List
//     List<ModuleFirestore> allModules = querySnapshot.docs
//         .map((doc) =>
//             ModuleFirestore.fromMap(doc.data() as Map<String, dynamic>))
//         .toList();
//     return allModules;
//   }

//   Future<void> editModule(String name, Map<String, dynamic> newData) async {
//     var querySnapshot = await users.where("name", arrayContains: name).get();
//     if (querySnapshot.docs.isNotEmpty) {
//       String docId = querySnapshot.docs.first.id; // Get the document ID
//       await users.doc(docId).update(newData);
//       log("Edited successfully!");
//     } else {
//       print("No document found for name: $name");
//     }
//   }

//   final CollectionReference policies =
//       FirebaseFirestore.instance.collection(POLICY_NAME_COLLECTION);

//   Future<void> addPolicy(PolicyFirestore policy) {
//     return policies
//         .add(policy.toMap())
//         .then((value) => log("Policy added successfully!"))
//         .catchError((error) => throw (ServerFailure(error.toString())));
//   }

//   Future<List<PolicyFirestore>> getPolicies() async {
//     // Get docs from collection reference
//     QuerySnapshot querySnapshot = await policies.get();

//     // Get data from docs and convert map to List
//     List<PolicyFirestore> allPolicies = querySnapshot.docs
//         .map((doc) =>
//             PolicyFirestore.fromMap(doc.data() as Map<String, dynamic>))
//         .toList();
//     return allPolicies;
//   }

//   Future<void> editPolicy(String name, Map<String, dynamic> newData) async {
//     var querySnapshot = await policies.where("name", isEqualTo: name).get();
//     if (querySnapshot.docs.isNotEmpty) {
//       String docId = querySnapshot.docs.first.id; // Get the document ID
//       await policies.doc(docId).update(newData);
//       log("Edited successfully!");
//     } else {
//       print("No document found for name: $name");
//     }
//   }

//   Future<String> getModuleId(String moduleName) async {
//     var querySnapshot =
//         await users.where("name", arrayContains: moduleName).get();
//     if (querySnapshot.docs.isNotEmpty) {
//       String docId = querySnapshot.docs.first.id; // Get the document ID
//       return docId;
//     } else {
//       print("No document found for name: $moduleName");
//       return "";
//     }
//   }

//   final CollectionReference controls =
//       FirebaseFirestore.instance.collection(CONTROL_NAME_COLLECTION);

//   Future<void> addControl(ControlFirestore control) {
//     return controls
//         .add(control.toMap())
//         .then((value) => log("Control added successfully!"))
//         .catchError((error) => throw (ServerFailure(error.toString())));
//   }

//   Future<List<ControlFirestore>> getControls() async {
//     // Get docs from collection reference
//     QuerySnapshot querySnapshot = await controls.get();

//     // Get data from docs and convert map to List
//     List<ControlFirestore> allControls = querySnapshot.docs
//         .map((doc) =>
//             ControlFirestore.fromMap(doc.data() as Map<String, dynamic>))
//         .toList();
//     return allControls;
//   }

//   Future<void> editControl(String name, Map<String, dynamic> newData) async {
//     var querySnapshot = await controls.where("name", isEqualTo: name).get();
//     if (querySnapshot.docs.isNotEmpty) {
//       String docId = querySnapshot.docs.first.id; // Get the document ID
//       await controls.doc(docId).update(newData);
//       log("Edited successfully!");
//     } else {
//       print("No document found for name: $name");
//     }
//   }

//   Future<String> getPolicyId(String policyName) async {
//     var querySnapshot =
//         await policies.where("name", arrayContains: policyName).get();
//     if (querySnapshot.docs.isNotEmpty) {
//       String docId = querySnapshot.docs.first.id; // Get the document ID
//       return docId;
//     } else {
//       print("No document found for name: $policyName");
//       return "";
//     }
//   }

//   final CollectionReference controlOwners =
//       FirebaseFirestore.instance.collection(CONTROL_OWNER_NAME_COLLECTION);

//   Future<void> addControlOwner(ControlOwnerFirestore controlOwner) {
//     return controlOwners
//         .add(controlOwner.toMap())
//         .then((value) => log("Control Owner added successfully!"))
//         .catchError((error) => throw (ServerFailure(error.toString())));
//   }

//   Future<List<ControlOwnerFirestore>> getControlOwners() async {
//     // Get docs from collection reference
//     QuerySnapshot querySnapshot = await controlOwners.get();

//     // Get data from docs and convert map to List
//     List<ControlOwnerFirestore> allControlOwners = querySnapshot.docs
//         .map((doc) =>
//             ControlOwnerFirestore.fromMap(doc.data() as Map<String, dynamic>))
//         .toList();
//     return allControlOwners;
//   }

//   Future<void> editControlOwner(
//       String name, Map<String, dynamic> newData) async {
//     var querySnapshot =
//         await controlOwners.where("name", isEqualTo: name).get();
//     if (querySnapshot.docs.isNotEmpty) {
//       String docId = querySnapshot.docs.first.id; // Get the document ID
//       await controlOwners.doc(docId).update(newData);
//       log("Edited successfully!");
//     } else {
//       print("No document found for name: $name");
//     }
//   }
// }

class FireBaseHelper<T> {
  final String collectionName;
  final T Function(Map<String, dynamic>) fromMap;

  FireBaseHelper({required this.collectionName, required this.fromMap});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection(collectionName);

  Future<void> addItem(Map<String, dynamic> data) async {
    try {
      await _collection.add(data);
      log("$collectionName item added successfully!");
    } catch (error) {
      debugPrint("Error adding item: $error");
      throw ServerFailure(error.toString());
    }
  }

  Future<List<T>> getItems() async {
    try {
      debugPrint("collection name: $collectionName");
      QuerySnapshot querySnapshot = await _collection.get();
      return querySnapshot.docs
          .map((doc) => fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw ServerFailure(error.toString());
    }
  }

  Future<void> editItem(
      String fieldName, String fieldValue, Map<String, dynamic> newData) async {
    var querySnapshot = await _collection
        .where(fieldName, arrayContains: fieldValue.toLowerCase().trim())
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      String docId = querySnapshot.docs.first.id;
      await _collection.doc(docId).update(newData);
      log("Item updated successfully!");
    } else {
      log("No document found for $fieldName: $fieldValue");
    }
  }

  Future<String?> getItemId(String fieldName, String fieldValue) async {
    var querySnapshot = await _collection
        .where(fieldName, arrayContains: fieldValue.toLowerCase().trim())
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    }
    log("No document found for $fieldName: $fieldValue");
    return null;
  }
}
