/// Module: Settings · Data · Company Remote Data Source
/// Description: Remote data source for the company document. Wraps Firestore
///              read/write so the controller/repository never call
///              FirebaseFirestore.instance directly.
/// Author: Mohamed Elrashidy
/// Date: 25/06/2026
/// Dependencies: cloud_firestore, ApiConstants
/// Revision History:
///   - 25/06/2026 (Amr Mesbah): Implemented CRUD (was an empty stub).
///
/// ************************ FILE INFO ********************************///
/// File Name: company_remote_data_source.dart
/// Purpose: Firestore-backed remote data source for the company document.
/// Author: Mohamed Elrashidy
/// Created At: 25/06/2026
/// Dependencies: cloud_firestore, ApiConstants
library;

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:demo_app/core/network/api_constants.dart';

class CompanyRemoteDataSource {
  CollectionReference<Map<String, dynamic>> get _companies =>
      FirebaseFirestore.instance
          .collection(ApiConstants.company)
          .withConverter<Map<String, dynamic>>(
            fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
            toFirestore: (value, _) => value,
          );

  /// Create or merge the company document identified by [companyId].
  Future<void> setCompany({
    required String companyId,
    required Map<String, dynamic> data,
  }) async {
    await _companies.doc(companyId).set(data, SetOptions(merge: true));
  }

  /// Fetch the raw company document map, or `null` when it does not exist.
  Future<Map<String, dynamic>?> getCompany({required String companyId}) async {
    final snapshot = await _companies.doc(companyId).get();
    if (!snapshot.exists) return null;
    return snapshot.data();
  }

  /// Uploads a company logo file to Firebase Storage and returns its public
  /// download URL. [contentType] should match the file (e.g. 'image/svg+xml').
  Future<String> uploadCompanyLogo({
    required File file,
    required String contentType,
    required String extension,
  }) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('/company_logo/${DateTime.now()}.$extension');
    final metadata = SettableMetadata(contentType: contentType);
    final uploadTask = ref.putFile(file, metadata);
    final taskSnapshot = await uploadTask.whenComplete(() {});
    return taskSnapshot.ref.getDownloadURL();
  }
}
