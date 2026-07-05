/// Module: Policy Management
/// Description: Handles uploading Policy images and Policy/Control documents
///              to Firebase Storage, returning public download URLs to be
///              stored in the Firestore document fields.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: firebase_storage
/// Revision History: 2025-01-15 - Initial creation

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_storage_data_source.dart
/// Purpose: Contains the PolicyStorageDataSource class responsible for
///          uploading and deleting Policy images and documents on Firebase
///          Storage.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

/// class name: [PolicyStorageDataSource]
///
/// purpose: upload Policy images and documents (Policy_Document,
///          Controls_Document) to Firebase Storage and return their public
///          download URLs, which are then saved inside the corresponding
///          Firestore fields. Each upload is stored under a structured path
///          that keeps policy and control files separated.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class PolicyStorageDataSource {
  PolicyStorageDataSource({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  // Storage folder structure:
  // Policies_Files/
  //   └── {policyId}/
  //         ├── Images/         ← policy image
  //         ├── Documents/      ← policy document
  //         └── Controls/
  //               └── {controlId}/
  //                     └── Documents/  ← control document
  static const String _rootFolder = 'Policies_Files';

  // ------------------------------------------------------------------
  // POLICY IMAGE
  // ------------------------------------------------------------------

  /// function name: [uploadPolicyImage]
  ///
  /// purpose: upload a Policy image file to Firebase Storage and return
  ///          its public download URL. The URL is what should be passed
  ///          as the [image] field in [PolicyModel.create] or
  ///          [PolicyModel.copyWithUpdate].
  ///
  /// parameters:
  ///            [String] policyId: id of the Policy the image belongs to
  ///            [File] imageFile: the local image file to upload
  ///
  /// return type: [Future<String>] - the download URL of the uploaded image, or throws an Exception on failure
  Future<String> uploadPolicyImage({
    required String policyId,
    required File imageFile,
  }) async {
    try {
      final fileName = _buildFileName(imageFile);
      final ref =
          _storage.ref('$_rootFolder/$policyId/Images/$fileName');
      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload the Policy image: $e');
    }
  }

  // ------------------------------------------------------------------
  // POLICY DOCUMENT
  // ------------------------------------------------------------------

  /// function name: [uploadPolicyDocument]
  ///
  /// purpose: upload a Policy document file to Firebase Storage and return
  ///          its public download URL. The URL is what should be passed as
  ///          the [policyDocument] field in [PolicyModel.create] or
  ///          [PolicyModel.copyWithUpdate].
  ///
  /// parameters:
  ///            [String] policyId: id of the Policy the document belongs to
  ///            [File] documentFile: the local document file to upload
  ///
  /// return type: [Future<String>] - the download URL of the uploaded document, or throws an Exception on failure
  Future<String> uploadPolicyDocument({
    required String policyId,
    required File documentFile,
  }) async {
    try {
      final fileName = _buildFileName(documentFile);
      final ref =
          _storage.ref('$_rootFolder/$policyId/Documents/$fileName');
      final uploadTask = await ref.putFile(documentFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload the Policy document: $e');
    }
  }

  // ------------------------------------------------------------------
  // CONTROL DOCUMENT
  // ------------------------------------------------------------------

  /// function name: [uploadControlDocument]
  ///
  /// purpose: upload a Control document file to Firebase Storage and return
  ///          its public download URL. The URL is what should be passed as
  ///          the [controlsDocument] field when building a [ControlModel].
  ///          Files are stored under the policy's folder to keep all
  ///          related assets together.
  ///
  /// parameters:
  ///            [String] policyId: id of the Policy that owns this Control
  ///            [String] controlId: id of the Control the document belongs to
  ///            [File] documentFile: the local document file to upload
  ///
  /// return type: [Future<String>] - the download URL of the uploaded control document, or throws an Exception on failure
  Future<String> uploadControlDocument({
    required String policyId,
    required String controlId,
    required File documentFile,
  }) async {
    try {
      final fileName = _buildFileName(documentFile);
      final ref = _storage.ref(
        '$_rootFolder/$policyId/Controls/$controlId/Documents/$fileName',
      );
      final uploadTask = await ref.putFile(documentFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload the Control document: $e');
    }
  }

  // ------------------------------------------------------------------
  // DELETE (shared for any file)
  // ------------------------------------------------------------------

  /// function name: [deleteFile]
  ///
  /// purpose: delete any previously uploaded file from Firebase Storage
  ///          using its download URL. Used to clean up old images or
  ///          documents when they are replaced by newer uploads.
  ///
  /// parameters:
  ///            [String] fileUrl: the download URL of the file to delete
  ///
  /// return type: [Future<void>] - completes when the deletion has finished, or throws an Exception on failure
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete the file from Storage: $e');
    }
  }

  // ------------------------------------------------------------------
  // PRIVATE HELPERS
  // ------------------------------------------------------------------

  /// function name: [_buildFileName]
  ///
  /// purpose: generate a unique file name by prefixing the original file
  ///          name with the current timestamp in milliseconds, preventing
  ///          name collisions on Storage when the same file is uploaded
  ///          multiple times.
  ///
  /// parameters:
  ///            [File] file: the local file whose name will be used as suffix
  ///
  /// return type: [String] - the generated unique file name
  String _buildFileName(File file) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final originalName = file.uri.pathSegments.last;
    return '${timestamp}_$originalName';
  }
}