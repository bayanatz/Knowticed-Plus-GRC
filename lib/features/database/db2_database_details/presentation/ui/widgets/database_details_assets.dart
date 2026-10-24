/// Module: database / db2_database_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: database_details_assets.dart
/// Description: Declares `DatabaseDetailsAssets`.
/// Author: Amr Mesbah
/// Created at: 24/10/2026
///
/// The icons the database details screens draw.
library;

/// Icons this section uses, all already in the app's asset bundle.
///
/// Named constants rather than inline strings because the same icon appears on
/// two or three screens each — the Access button is on the details page and
/// the edit-access footer — and a renamed asset should break the build in one
/// place, not go missing from a button at runtime.
abstract final class DatabaseDetailsAssets {
  static const String _main = 'assets/icons_assets/main_icons_assets';
  static const String _roles = 'assets/icons_assets/roles_assets';
  static const String _database = 'assets/icons_assets/database_builder_assets';

  /// The people-and-key glyph on the "Access" button (Figma 7398:735).
  static const String access =
      'assets/icons_assets/main_icons_assets/ic_security_access_workflow.svg';

  /// "Edit Access" on the Access screen (Figma 7398:10662).
  static const String editAccess =
      'assets/icons_assets/main_icons_assets/ic_security_edit_access.svg';

  static const String edit =
      'assets/icons_assets/main_icons_assets/ic_action_edit.svg';

  /// Note the space in the file name — that is how the asset is named in
  /// `assets/icons_assets/main_icons_assets`, and pubspec ships the folder.
  static const String delete =
      'assets/icons_assets/main_icons_assets/ic_delete_trash_red.svg';

  static const String export =
      'assets/icons_assets/main_icons_assets/ic_action_export.svg';

  /// The "+" on the "+ Table" button.
  static const String addTable =
      'assets/icons_assets/main_icons_assets/ic_action_plus.svg';

  /// Placeholder inside the info card's thumbnail.
  static const String databaseGlyph =
      'assets/icons_assets/main_icons_assets/ic_create_data_base.svg';
}
