/// Module: database / db3_create_table / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: table_comments_access.dart
/// Description: Declares `TableCommentsAccess`.
/// Author: Amr Mesbah
/// Created at: 16/8/2026
///
/// The two values the "Comments Access" dropdown offers on the Creating Table
/// card — Figma `Columns type` 7398:8220 (iPad H) / 7398:8224 (iPad V), the
/// 208x90 popover with just Private and Shared in it.
///
/// The Figma also draws a hover card next to that dropdown (`Hover Stat`,
/// 7398:6706) spelling out what each value means. Those two sentences are the
/// enum's own vocabulary: they are in the .arb files (rule 14) and read through
/// `TableCommentsAccessLabel.hint`, next to the value names.
library;

enum TableCommentsAccess {
  /// Only admins can view and manage the comments. The Figma shows this
  /// pre-selected, and it is the safe fallback for an unreadable value: least
  /// exposure, not most.
  private,

  /// All employees can view, reply to, and engage with the comments.
  shared;

  String get storageKey {
    switch (this) {
      case TableCommentsAccess.private:
        return 'private';
      case TableCommentsAccess.shared:
        return 'shared';
    }
  }

  static TableCommentsAccess fromStorageKey(String? key) {
    return TableCommentsAccess.values.firstWhere(
      (TableCommentsAccess access) => access.storageKey == key,
      orElse: () => TableCommentsAccess.private,
    );
  }
}
