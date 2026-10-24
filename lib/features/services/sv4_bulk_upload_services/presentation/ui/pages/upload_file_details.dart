/// Module: services / sv4_bulk_upload_services / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: upload_file_details.dart
/// Purpose: Upload and edit data which come from bulk upload (Master variant).
///          uploadToFirebase() (now on BulkServicesUploader) returns
///          Map`<String, String>` (serviceName -> docId) so Step 2 can use the
///          real Firestore document IDs for Parent_Service_Id.
/// Author: Amr Mesbah
/// Date: 2026-07-02
/// Dependencies: excel, permission_handler, MediaPickerService,
///               BulkServicesUploader, UploadFileDetailsTable
/// Revision History:
///   - uploadToFirebase() changed return type from Future`<void>` to
///     Future`<Map<String,String>`>; returns serviceName -> firestoreDocId map.
///   - 2026-07-02 (Knowticed Team): Moved all Firestore writes into
///     BulkServicesUploader and the row/header table rendering into
///     ui/widgets/upload_file_details_table.dart to bring this file under
///     the 800-LOC budget and remove direct .collection(/Timestamp usage
///     from the page (audit fix #1/#3).
library;

import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';

export 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/ui/widgets/custom_excel_text_field.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/ui/pages/data_upload_upload_file_details_toggle.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/services/helpers/constants/master_upload_headers.dart';
import 'package:knowticed_plus/core/app_services/media_picker_service.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/domain/use_cases/upload_file_row_validator.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/controller/bulk_services_uploader.dart';
import 'package:knowticed_plus/features/services/sv3_create_master_services/presentation/ui/widgets/upload_row_controllers.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/ui/widgets/upload_file_details_table.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/ui/widgets/upload_file_details_activate_flow.dart';

import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/ui/pages/upload_file_toggle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/features/services/data/utils/storage_permission.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/data/data_source/service_excel_reader.dart';
part 'upload_file_details_part2.dart';

// ✅ FIX (bug report p14/p38 "use same check box in figma"): a second
// CustomCheckBox was declared here, shadowing the shared
// core/custom/23-custom_check_box.dart component with drifted values (20.sp
// instead of 22.sp, radius 6.r instead of 4.r, AppColors.grey border instead
// of secondaryText@50%, Icons.check instead of Icons.check_rounded).
//
// It had no references, so it is removed outright — screens in this feature use
// the shared component.

class UploadFileDetailsTabletMaster extends StatefulWidget {
  const UploadFileDetailsTabletMaster({
    super.key,
    required this.formData,
    required this.validationErrors,
    this.selectedFileName,
    this.onActivated,
  });

  final List<Map<String, TextEditingController>> formData;
  final List<Map<String, String>> validationErrors;
  final String? selectedFileName;

  /// Called after the user confirms activation.
  /// In master flow: receives uploadToFirebase fn — MasterUploadScreen stores it,
  /// defers execution until Step 2 confirms.
  /// The fn now returns Map`<String, String>` (serviceName → firestoreDocId).
  final Future<void> Function(Future<Map<String, String>> Function() uploadFn)?
      onActivated;

  @override
  State<UploadFileDetailsTabletMaster> createState() =>
      _UploadFileDetailsTabletMasterState();
}
