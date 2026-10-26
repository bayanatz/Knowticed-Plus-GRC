/// Module: home/h1_home_page / data / data_source / showcase
///
///*************************** FILE INFO ****************************///
/// File Name: showcase_audit.dart
/// Purpose: Owner-only, READ-ONLY listing of the entries in the main list
///          collections that are NOT showcase entries, so the owner can
///          decide which old QA / test entries to remove.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// Writes nothing and deletes nothing. Prints one `AUDIT|` line per entry
/// to the debug console:
///   `AUDIT|<area>|<doc id>|<TEST? or ok>|<text found in the entry>`
/// `TEST?` marks entries whose text matches a QA / test pattern.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/grc/helpers/constants/grc_firebase_paths.dart'; // [module:grc]
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_common.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/utils/request_collection_paths.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/data/utils/feedback_collection_paths.dart';
import 'package:knowticed_plus/features/todo/helpers/constants/todo_firestore_paths.dart';

abstract final class ShowcaseAudit {
  static final RegExp _testWords = RegExp(
    r'\b(test|testing|qa|demo|sample|auto-generated|lorem|dummy|asdf|xx+|sd|todo test|fake)\b',
    caseSensitive: false,
  );

  /// Function Name: [run]
  ///
  /// Purpose: Reads each list collection, prints the non-showcase entries,
  /// returns a per-area summary ("area: total (flagged)").
  static Future<List<String>> run({required String ownerEmail}) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final Map<String, CollectionReference<Map<String, dynamic>> Function()>
        areas = <String, CollectionReference<Map<String, dynamic>> Function()>{
      'Settings requests': () => db
          .doc(RequestCollectionPaths.rolesDoc)
          .collection(RequestCollectionPaths.requestsCollection),
      'Settings feedback': () => db
          .doc(FeedbackCollectionPaths.settingsDoc)
          .collection(FeedbackCollectionPaths.feedbackCollection),
      'To-Do': () =>
          db.collection(getBaseUrl(TodoFirestorePaths.todosOf(ownerEmail))),
      'Services (catalogue)': () =>
          db.collection(getBaseUrl('Modules/services/CreateServices')),
      'Services (requests)': () =>
          db.collection(getBaseUrl('Modules/services/RequestServices')),
      'Knowledge Hub': () =>
          db.collection(getBaseUrl('Modules/knowledge_hub/Create_Knowledge')),
      'Database': () =>
          db.collection(getBaseUrl('Modules/database_builder/Databases')),
      'GRC modules': () => db.collection(GrcFirebasePaths.modulesCollection), // [module:grc]
      'Roles': () => db.collection(getBaseUrl('Roles')),
      'Org chart (employees)': () =>
          db.collection(getBaseUrl('Employees_Info')),
      'Org chart (departments)': () => db.collection(getBaseUrl('Departments')),
    };

    final List<String> summary = <String>[];
    for (final MapEntry<String,
            CollectionReference<Map<String, dynamic>> Function()> a
        in areas.entries) {
      try {
        final QuerySnapshot<Map<String, dynamic>> snap = await a.value().get();
        int other = 0;
        int flagged = 0;
        for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs) {
          if (d.id.startsWith(ShowcaseCommon.idPrefix)) continue;
          other++;
          final String text = _texts(d.data()).join(' · ');
          final bool test = _testWords.hasMatch(text);
          if (test) flagged++;
          final String short =
              text.length > 170 ? '${text.substring(0, 170)}…' : text;
          debugPrint('AUDIT|${a.key}|${d.id}|${test ? 'TEST?' : 'ok'}|$short');
        }
        summary.add('${a.key}: $other other entries ($flagged look like tests)'
            ' · ${snap.docs.length - other} showcase');
      } catch (e) {
        summary.add('${a.key}: could not read ($e)');
      }
    }
    return summary;
  }

  /// Every readable string in [value] (maps and lists flattened), skipping
  /// ids, urls and long codes.
  static Iterable<String> _texts(Object? value) sync* {
    if (value is String) {
      final String s = value.trim();
      if (s.isNotEmpty &&
          s.length < 300 &&
          !s.startsWith('http') &&
          s.contains(RegExp(r'[A-Za-z؀-ۿ]{2}')) &&
          !RegExp(r'^[A-Za-z0-9_\-]{18,}$').hasMatch(s)) {
        yield s;
      }
    } else if (value is Map) {
      for (final Object? v in value.values) {
        yield* _texts(v);
      }
    } else if (value is Iterable) {
      for (final Object? v in value) {
        yield* _texts(v);
      }
    }
  }
}
