/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: menu.dart
/// Description: `MenuEnum` enum, extension methods of `MenuEnum`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/generated/l10n.dart';

enum MenuEnum {
  duplicate,
  edit,
  convertToPDF,
  delete,

  /// For the Deleted tab's card menu.
  ///
  /// NOT part of any "every action" list: it is the only entry the Deleted tab
  /// Offers, and it is meaningless on every other tab. `home_grid_item_view`
  /// Therefore passes an EXPLICIT list per tab rather than `MenuEnum.values` —
  /// Which is what it used to pass, and what would have put "Restore" in the
  /// Publish card's menu the moment this value was added. Any new call site
  /// Should name the entries it wants for the same reason.
  restore,
}

extension MenuEnumExtension on MenuEnum {
  /// STABLE identifier. NOT translated; see [label].
  String get name {
    switch (this) {
      case MenuEnum.duplicate:
        return 'Duplicate';
      case MenuEnum.edit:
        return 'Edit';
      case MenuEnum.convertToPDF:
        return 'Convert to PDF';
      case MenuEnum.delete:
        return 'Delete';
      case MenuEnum.restore:
        return 'Restore';
    }
  }

  /// Translated label — what the user actually reads in the card menu.
  String get label {
    final s = S.current;
    switch (this) {
      case MenuEnum.duplicate:
        return s.menuDuplicate;
      case MenuEnum.edit:
        return s.edit;
      case MenuEnum.convertToPDF:
        return s.convertToPdf;
      case MenuEnum.delete:
        return s.delete;
      case MenuEnum.restore:
        return s.restore;
    }
  }
}
