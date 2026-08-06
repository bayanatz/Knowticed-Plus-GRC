import 'package:get/get.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';
enum ActiveDirectory implements ModulePermissionsSectionsPermission {
  uploadDocument,
  restoreData,
  exportData,
  editUploadedDocument,
  removeEmployee;

  @override
  bool get isChild {
    switch (this) {
      default:
        return false;
    }
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case uploadDocument:
        return 'Upload_Document';
      case restoreData:
        return 'Restore_Data';
      case exportData:
        return 'Export_Data';
      case editUploadedDocument:
        return 'Edit_Uploaded_Document';
      case removeEmployee:
        return 'Remove_Employee';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case uploadDocument:
        return 'Upload Document';  // ✅ With translation
      case restoreData:
        return 'Restore Data';  // ✅ With translation
      case exportData:
        return 'Export Data';  // ✅ With translation
      case editUploadedDocument:
        return 'Edit Uploaded Document';  // ✅ With translation
      case removeEmployee:
        return 'Remove Employee';  // ✅ With translation
    }
  }

}