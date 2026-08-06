/******************** FILE INFO ********************/
/// File Name: messages_permissions.dart
/// Purpose: Enum for Messaging module permissions.
/// Note: Lives inside features/messaging so the module stays self-contained.
///       Implements the app-wide role interface from r1_role_management.
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';

enum MessagesPermissions implements ModulePermissionsSectionsPermission {
  createGroup,
  seenAndUnseen,
  editMessage,
  deleteMessage,
  reactions,
  forwardMessage;

  @override
  bool get isChild => false;

  @override
  String get getDataBaseName {
    switch (this) {
      case createGroup:
        return 'Create_Group';
      case seenAndUnseen:
        return 'Seen_and_Unseen';
      case editMessage:
        return 'Edit_Message';
      case deleteMessage:
        return 'Delete_Message';
      case reactions:
        return 'Reactions';
      case forwardMessage:
        return 'Forward_Message';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case createGroup:
        return 'Create Group';
      case seenAndUnseen:
        return 'Seen and Unseen';
      case editMessage:
        return 'Edit Message';
      case deleteMessage:
        return 'Delete Message';
      case reactions:
        return 'Reactions';
      case forwardMessage:
        return 'Forward Message';
    }
  }
}
