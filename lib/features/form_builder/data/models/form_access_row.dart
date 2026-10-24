/// Module: form_builder_module/data
///
///*************************** FILE INFO ****************************///
/// File Name: form_access_row.dart
/// Description: One recipient's row of a form's privacy document, read out of
///          the parallel lists in [UsersModel].
/// Author: Amr Mesbah
/// Created at: 12/10/2026
///
/// `Form Privacy/<formId>.Users` stores every recipient as the same index
/// across `Emails`, `Status`, `Access Begin`, `Access End`, `Edit Permission`
/// and `Shared`. Every reader used to index those lists by hand — and the
/// lists are not guaranteed to be the same length on older documents. This
/// does it once, safely, for the notification service, the notification
/// sweep and the calendar.
library;

import 'package:knowticed_plus/features/form_builder/data/models/users_model.dart';

class FormAccessRow {
  const FormAccessRow({
    required this.email,
    required this.isActive,
    required this.accessBegin,
    required this.accessEnd,
    required this.editPermission,
    required this.isShared,
  });

  final String email;
  final bool isActive;
  final DateTime? accessBegin;
  final DateTime? accessEnd;
  final bool editPermission;

  /// Added from the Share screen rather than assigned at publish.
  final bool isShared;

  /// Every recipient in [users], keyed by lower-cased email.
  ///
  /// When an email appears more than once the LAST row wins — the lists are
  /// append-only, so the last row is the current state.
  static Map<String, FormAccessRow> mapFrom(UsersModel? users) {
    final Map<String, FormAccessRow> rows = <String, FormAccessRow>{};
    if (users == null) return rows;
    final List<String> emails = users.emails ?? const <String>[];
    for (int i = 0; i < emails.length; i++) {
      final String email = emails[i].trim();
      if (email.isEmpty) continue;
      rows[email.toLowerCase()] = FormAccessRow(
        email: email,
        isActive: _at(users.status, i)?.toLowerCase() != 'inactive',
        accessBegin: _at(users.accessBegin, i)?.toDate(),
        accessEnd: _at(users.accessEnd, i)?.toDate(),
        editPermission: _at(users.editPermission, i) ?? false,
        isShared: _at(users.shared, i) ?? false,
      );
    }
    return rows;
  }

  /// Only the recipients who currently hold access.
  static List<FormAccessRow> activeFrom(UsersModel? users) =>
      mapFrom(users).values.where((FormAccessRow r) => r.isActive).toList();

  static T? _at<T>(List<T>? list, int i) =>
      (list != null && i >= 0 && i < list.length) ? list[i] : null;
}
