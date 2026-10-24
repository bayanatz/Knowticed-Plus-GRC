/// Module: database / db3_create_table / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: create_table_assets.dart
/// Description: Declares `CreateTableAssets`.
/// Author: Amr Mesbah
/// Created at: 24/10/2026
///
/// The icons the table screens draw.
library;

/// Icons the Creating Table card uses, all already in the app's asset bundle.
///
/// Named constants rather than inline strings because a renamed asset should
/// break the build in one place, not go missing from a button at runtime.
abstract final class CreateTableAssets {
  /// The duplicate glyph on each column block (Figma `solar:copy-linear`,
  /// 7398:6608). Already in the bundle as the form builder's copy icon.
  static const String duplicateColumn =
      'assets/icons_assets/main_icons_assets/ic_action_copy.svg';

  /// The red remove glyph on each column block (Figma `zondicons:minus-solid`,
  /// 7398:6613).
  static const String removeColumn =
      'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg';

  /// The speech bubble on the "Comments" button of the Table Name Details card
  /// (Figma 7398:4102, `Frame 1597883021`).
  static const String comments =
      'assets/icons_assets/main_icons_assets/ic_messages_new.svg';

  /// The paper plane in the composer's send button (Figma 7398:8232).
  static const String send =
      'assets/icons_assets/main_icons_assets/ic_action_send_white.svg';

  /// The thumb under a bubble.
  ///
  /// ONE asset for BOTH reactions. The bundle ships a thumbs-UP and no
  /// thumbs-down, and the Figma's two glyphs are the same shape mirrored — so
  /// `TableCommentBubble` flips this one on the X axis for dislike rather than
  /// this file naming an asset that is not there. A real thumbs-down svg can
  /// replace the flip later without touching anything else.
  static const String thumb =
      'assets/icons_assets/main_icons_assets/ic_reaction_like.svg';

  /// The cloud on the Import Table dialog (Figma 7398:4041).
  static const String cloudUpload =
      'assets/icons_assets/main_icons_assets/ic_cloud_upload.svg';

  /// The arrow on that dialog's "Upload File" button.
  static const String uploadArrow =
      'assets/icons_assets/main_icons_assets/ic_action_upload.svg';

  /// The sheet-with-an-arrow beside the dialog's title, and on the Import
  /// button that opens it from Table Name Details (7398:3042).
  static const String importTable =
      'assets/icons_assets/main_icons_assets/ic_action_upload_rounded.svg';
}
