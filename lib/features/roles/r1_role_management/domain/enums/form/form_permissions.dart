import 'package:get/get.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';
enum FormPermissions implements ModulePermissionsSectionsPermission {
  createNewForm,
  editForm,
  deleteForm,
  restoreForm,
  duplicateForm,
  convertToPdf,
  fillOutForm,
  share,
  editPermission;

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
      case createNewForm:
        return 'Create_New_Form';
      case editForm:
        return 'Edit_Form';
      case deleteForm:
        return 'Delete_Form';
      case duplicateForm:
        return 'Duplicate_Form';
      case convertToPdf:
        return 'Convert_to_PDF';
      case share:
        return 'Share';
      case restoreForm:
        return 'Restore_Form';
      case fillOutForm:
        return 'Fill_Out_Form';
      case editPermission:
        return 'Edit_Permission';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case createNewForm:
        return 'Create New Form';
      case editForm:
        return 'Editing Form';
      case deleteForm:
        return 'Delete Form';
      case duplicateForm:
        return 'Duplicate Form';
      case convertToPdf:
        return 'Convert to PDF';
      case share:
        return 'Share';
      case restoreForm:
        return 'Restore Form';
      case fillOutForm:
        return 'Fill Out Form';
      case editPermission:
        return 'Edit Permission';
    }
  }
}