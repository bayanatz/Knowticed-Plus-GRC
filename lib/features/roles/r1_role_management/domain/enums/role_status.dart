import 'package:flutter/material.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/generated/l10n.dart';

enum RoleStatus {
  all,
  active,
  inactive,
  draft,
  deleted;

  static List<RoleStatus> get filterStatus => [
    all,
    active,
    inactive,
    draft,
  ];

  Color get color {
    switch (this) {
      case RoleStatus.all:
        return AppColors.text;
      case RoleStatus.active:
        return Colors.green;
      case RoleStatus.inactive:
        return Colors.red;
      case RoleStatus.draft:
        return AppColors.secondaryText;
      case RoleStatus.deleted:
        return Colors.black54;
    }
  }

  /// Localized display name, resolved from the app's ARB strings.
  String getLocalizedName(BuildContext context) {
    switch (this) {
      case RoleStatus.all:
        return S.of(context).all;
      case RoleStatus.active:
        return S.of(context).active;
      case RoleStatus.inactive:
        return S.of(context).inactive;
      case RoleStatus.draft:
        return S.of(context).draft;
      case RoleStatus.deleted:
        return S.of(context).deleted;
    }
  }

  /// Alias kept so call sites can read `status.localizedName(context)`.
  String localizedName(BuildContext context) => getLocalizedName(context);
}