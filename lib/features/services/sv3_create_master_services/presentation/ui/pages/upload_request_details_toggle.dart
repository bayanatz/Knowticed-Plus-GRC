/// Module: services / sv3_create_master_services / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: upload_request_details_toggle.dart
/// Purpose: Toggle for upload request details screen. Passes
///          step1UploadFunction so Step 2 can call Step 1's upload first,
///          receive the serviceName → docId map, and use real Firestore doc
///          IDs. Created by: Amr Mesbah
///
/// CHANGE LOG:
/// - step1UploadFunction signature updated to return Future`<Map<String,String>`>
///   (serviceName → firestoreDocId) instead of Future`<void>`.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/sv3_create_master_services/presentation/ui/pages/upload_details.dart';

class UploadRequestsDetailsToggle extends StatelessWidget {
  const UploadRequestsDetailsToggle({
    super.key,
    required this.formData,
    required this.validationErrors,
    this.selectedFileName,
    required this.uploadedServicesFormData,
    this.step1UploadFunction,
  });

  final List<Map<String, TextEditingController>> formData;
  final List<Map<String, String>> validationErrors;
  final String? selectedFileName;
  final List<Map<String, TextEditingController>> uploadedServicesFormData;

  /// Step 1's uploadToFirebase function, stored by MasterUploadScreen.
  /// Returns Map`<String, String>` (serviceName → firestoreDocId).
  /// Called BEFORE Step 2 uploads so Parent_Service_Id uses real doc IDs.
  final Future<Map<String, String>> Function()? step1UploadFunction;

  @override
  Widget build(BuildContext context) {
    return UploadRequestsDetailsScreen(
      formData: formData,
      validationErrors: validationErrors,
      selectedFileName: selectedFileName,
      uploadedServicesFormData: uploadedServicesFormData,
      step1UploadFunction: step1UploadFunction,
    );
  }
}
