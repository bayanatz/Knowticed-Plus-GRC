/// Module: services_management_module
/// ******************* FILE INFO *******************
/// File Name: history_append.dart
/// Description: Appends to the module's history-list fields (status, state,
///              timestamps, Approval_Cycle, Assigned_Provider_Email, ...).
///              Each field is a list whose LAST item is the current value.
///              FieldValue.arrayUnion skips values already in the list, so a
///              toggle back to an earlier value (active → inactive → active)
///              was never saved (SVC-HOME-02). This helper reads the document
///              and appends inside a transaction instead.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
/// *************************************************
library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// Marks a value that must be appended to a history list field, even when
/// the same value is already in the list.
class HistoryAppend {
  final Object? value;

  const HistoryAppend(this.value);
}

/// True when [data] contains at least one [HistoryAppend] value.
bool hasHistoryAppend(Map<String, dynamic> data) =>
    data.values.any((v) => v is HistoryAppend);

/// Updates [ref] with [data]. Plain values are written as-is; every
/// [HistoryAppend] value is appended to the end of the existing list in one
/// transaction (read-then-write), so concurrent writers cannot drop an entry.
///
/// Throws a [StateError] when the document does not exist.
Future<void> updateWithHistory(
  FirebaseFirestore firestore,
  DocumentReference<Map<String, dynamic>> ref,
  Map<String, dynamic> data,
) async {
  if (!hasHistoryAppend(data)) {
    await ref.update(data);
    return;
  }

  await firestore.runTransaction((tx) async {
    final snap = await tx.get(ref);
    if (!snap.exists) {
      throw StateError('Document not found: ${ref.path}');
    }
    final current = snap.data() ?? const <String, dynamic>{};
    final out = <String, dynamic>{};

    data.forEach((key, value) {
      if (value is HistoryAppend) {
        final existing = _readPath(current, key);
        final list = existing is List
            ? List<dynamic>.from(existing)
            : (existing == null ? <dynamic>[] : <dynamic>[existing]);
        list.add(value.value);
        out[key] = list;
      } else {
        out[key] = value;
      }
    });

    tx.update(ref, out);
  });
}

/// Reads a (possibly dotted) field path from a document map.
Object? _readPath(Map<String, dynamic> data, String path) {
  if (data.containsKey(path)) return data[path];
  Object? node = data;
  for (final part in path.split('.')) {
    if (node is Map && node.containsKey(part)) {
      node = node[part];
    } else {
      return null;
    }
  }
  return node;
}
