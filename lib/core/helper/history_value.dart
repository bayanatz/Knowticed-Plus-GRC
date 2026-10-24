/// Module: core / helper
///
///*************************** FILE INFO ****************************///
/// File Name: history_value.dart
/// Description: The CURRENT value of a Firestore history field.
/// Author: Moataz Handousa
/// Created at: 18/10/2026
///
/// Many fields are stored as history arrays (state: pending → approved →
/// done; rejectComment: [text]). `.toString()` on them printed "[text]" with
/// brackets, and `.first` read the OLDEST value. The current value is the
/// LAST element.
library;

/// Last element of a List, the value itself otherwise, as trimmed text
/// ('' for null).
///
/// 21/10/2026: also the tracked-value map `{Values: [...], ...}`
/// (`SingleValueTrackingModel` — Messages' group name / image). It printed
/// the whole map ("{Values: [Digita…") on the Group Messages card.
String historyLast(Object? raw) {
  final Object? list = raw is Map ? raw['Values'] : raw;
  final Object? v = list is List ? (list.isEmpty ? null : list.last) : list;
  return (v ?? '').toString().trim();
}
