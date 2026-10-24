/// Module: form_builder_module/data
///
///*************************** FILE INFO ****************************///
/// File Name: users_model.dart
/// Description: `UsersModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UsersModel {
  List<String>? emails;
  List<String>? status;
  List<Timestamp?>? accessEnd;
  List<Timestamp?>? accessBegin;
  List<bool>? editPermission;

  /// Parallel to [emails]: `true` when that recipient was
  /// added from the Share screen (an existing form shared with them), `false`
  /// or missing when they were assigned at publish. The calendar uses it to
  /// tell "Form Shared With You" from "Form Assigned". Older documents have no
  /// list at all, which reads as "assigned".
  List<bool>? shared;
  UsersModel({
    this.emails,
    this.status,
    this.accessEnd,
    this.accessBegin,
    this.editPermission,
    this.shared,
  });

  static const String kEmailsfeild = "Emails";
  static const String kStatusfield = "Status";
  static const String kAccessbegin = "Access Begin";
  static const String kAccessend = "Access End";
  static const String kEditpermission = "Edit Permission";
  static const String kShared = "Shared";

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      kEmailsfeild: emails,
      kStatusfield: status,
      kAccessend: accessEnd,
      kAccessbegin: accessBegin,
      kEditpermission: editPermission,
      // Always written, even as null: the privacy document is saved with
      // merge, which merges nested maps key by key — omitting the key would
      // leave a stale list from an earlier save misaligned with [emails].
      kShared: shared,
    };
  }

  factory UsersModel.fromMap(Map<String, dynamic> map) {
    return UsersModel(
      emails: List<String>.from((map[kEmailsfeild])),
      status: List<String>.from((map[kStatusfield])),
      accessEnd: map[kAccessend] != null
          ? List<Timestamp?>.from((map[kAccessend]))
          : null,
      accessBegin: map[kAccessbegin] != null
          ? List<Timestamp?>.from((map[kAccessbegin]))
          : null,
      editPermission: map[kEditpermission] != null
          ? List<bool>.from((map[kEditpermission]))
          : null,
      shared: map[kShared] != null ? List<bool>.from((map[kShared])) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UsersModel.fromJson(String source) =>
      UsersModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
