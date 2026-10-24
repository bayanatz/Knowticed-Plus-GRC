/// Module: home/h3_app_drawer
///
///*************************** FILE INFO ****************************///
/// File Name: app_drawer_remote_data_source.dart
/// Purpose: Firestore reads for the drawer's company-licence lookup, and the
///          user's drawer order.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Extracted from `app_drawer_cubit`, which used to call
/// `FirebaseFirestore.instance.collection('Demo_Requests')` directly.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/constants/firebase_collections.dart';
// `hide`: api_constants.dart also declares a FirebaseCollections class, which
// made the name ambiguous and stopped the whole app from building (22/10/2026).
import 'package:knowticed_plus/core/network/api_constants.dart'
    hide FirebaseCollections;

class AppDrawerRemoteDataSource {
  AppDrawerRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Function Name: [getDemoRequestDocument]
  ///
  /// Purpose: Fetch the raw demo-request document for a company.
  ///
  /// Parameters:
  /// - [companyId]: Document id of the company's demo-request record.
  ///
  /// Returns: [Future<Map<String, dynamic>?>] — `null` when the document does
  ///          not exist or carries no data.
  Future<Map<String, dynamic>?> getDemoRequestDocument(String companyId) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(FirebaseCollections.demoRequests)
        .doc(companyId)
        .get();

    if (!snapshot.exists) return null;
    return snapshot.data();
  }

  /// Field on the user's Home Layout document that holds the drawer order.
  static const String drawerOrderKey = 'Drawer_Order';

  /// Function Name: [getDrawerOrder]
  ///
  /// Purpose: Read the user's drawer order from their Home Layout document.
  ///
  /// Parameters:
  /// - [email]: The user's email (the Home Layout document id).
  ///
  /// Returns: [Future<List<String>?>] — module ids in order; `null` when no
  ///          order was ever saved, an empty list after a reset.
  Future<List<String>?> getDrawerOrder(String email) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection(ApiConstants.homeLayout).doc(email).get();
    final dynamic order = snapshot.data()?[drawerOrderKey];
    if (order is! List) return null;
    return order.map((dynamic e) => e.toString()).toList();
  }

  /// Function Name: [saveDrawerOrder]
  ///
  /// Purpose: Write the user's drawer order next to their Home Layout, so every
  ///          device they sign in on shows the same order.
  ///
  /// Parameters:
  /// - [email]: The user's email (the Home Layout document id).
  /// - [order]: Module ids in order; empty = back to the default order.
  Future<void> saveDrawerOrder(String email, List<String> order) async {
    await _firestore
        .collection(ApiConstants.homeLayout)
        .doc(email)
        .set(<String, dynamic>{drawerOrderKey: order}, SetOptions(merge: true));
  }
}
