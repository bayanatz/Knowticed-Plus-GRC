import 'package:demo_app/features/roles/helper/form_builder_module/core/constants/strings.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/form_builder_module/core/constants/strings.dart';
import 'package:demo_app/features/roles/role_management/domain/interfaces/module_permissions_sections_permissions.dart';

enum GrcModulePermissions implements ModulePermissionsSectionsPermission {
  createSingleControl,
  createBulkUploadControl,
  draftControl,
  editControl,
  changeStatusOfControl,
  deleteControl,
  controlWeightIssue,
  editControlWeightIssue,
  previousControlOwners;

  @override
  bool get isChild => false;

  @override
  String get getDataBaseName {
    switch (this) {
      case createSingleControl:
        return 'Create_Single_Control';
      case createBulkUploadControl:
        return 'Create_Bulk_Upload_Control';
      case draftControl:
        return 'Draft_Control';
      case editControl:
        return 'Edit_Control';
      case changeStatusOfControl:
        return 'Change_Status_Of_Control';
      case deleteControl:
        return 'Delete_Control';
      case controlWeightIssue:
        return 'Control_Weight_Issue';
      case editControlWeightIssue:
        return 'Edit_Control_Weight_Issue';
      case previousControlOwners:
        return 'Previous_Control_Owners';
      
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case createSingleControl:
        return AppConstanstForm.createSingleControl.tr;
      case createBulkUploadControl:
        return AppConstanstForm.createBulkUploadControl.tr;
      case draftControl:
        return AppConstanstForm.draftControl.tr;
      case editControl:
        return AppConstanstForm.editControl.tr;
      case changeStatusOfControl:
        return AppConstanstForm.changeStatusOfControl.tr;
      case deleteControl:
        return AppConstanstForm.deleteControl.tr;
      case controlWeightIssue:
        return AppConstanstForm.controlWeightIssue.tr;
      case editControlWeightIssue:
        return AppConstanstForm.editControlWeightIssue.tr;
      case previousControlOwners:
        return AppConstanstForm.previousControlOwners.tr;
    }
  }
}

      