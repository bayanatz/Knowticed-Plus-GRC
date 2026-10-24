/// Module: database / db1_create_database / data / data_source
///
///*************************** FILE INFO ****************************///
/// File Name: database_title_index.dart
/// Description: Declares `DatabaseTitleIndex` and `DuplicateTitleException`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// Unique titles (DB-CREATE-11). The duplicate check used to read first and
/// write later, so two people saving the same title at the same moment both
/// passed it. Now each title — English and Arabic, lower-cased — has one index
/// document, and the save claims it INSIDE its own transaction: the second
/// transaction sees the first one's claim and is refused.
///
/// The older title query still runs first; it catches titles saved before the
/// index existed (the backfill script fills the index for those).
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/models/create_database_collections.dart';

class DatabaseTitleIndex {
  const DatabaseTitleIndex(this._firestore);

  final FirebaseFirestore _firestore;

  static const String fDatabaseId = 'database_id';

  DocumentReference<Map<String, dynamic>> _keyFor(String lang, String title) =>
      _firestore
          .collection(getBaseUrl(CreateDatabaseCollections.titleIndex))
          .doc('${lang}_${Uri.encodeComponent(title.trim().toLowerCase())}');

  /// Function Name: [claim]
  ///
  /// Purpose: Inside [transaction], refuse when either title belongs to another
  /// database, reserve both for [databaseId], and release the previous titles
  /// when they changed. Only READS before its own writes, so call it after the
  /// caller's reads and before the caller's writes.
  ///
  /// Parameters: [databaseId]; [titleEn] / [titleAr] the titles being saved;
  /// [previousEn] / [previousAr] the titles stored before this save, if any.
  ///
  /// Returns: [Future<void>]; throws [DuplicateTitleException] when taken.
  Future<void> claim(
    Transaction transaction, {
    required String databaseId,
    required String titleEn,
    required String titleAr,
    String? previousEn,
    String? previousAr,
  }) async {
    final List<DocumentReference<Map<String, dynamic>>> wanted =
        <DocumentReference<Map<String, dynamic>>>[
      if (titleEn.trim().isNotEmpty) _keyFor('en', titleEn),
      if (titleAr.trim().isNotEmpty) _keyFor('ar', titleAr),
    ];
    final Set<String> wantedPaths = <String>{
      for (final DocumentReference<Map<String, dynamic>> r in wanted) r.path,
    };
    final List<DocumentReference<Map<String, dynamic>>> released =
        <DocumentReference<Map<String, dynamic>>>[
      if (previousEn != null && previousEn.trim().isNotEmpty)
        _keyFor('en', previousEn),
      if (previousAr != null && previousAr.trim().isNotEmpty)
        _keyFor('ar', previousAr),
    ]
            .where(
              (DocumentReference<Map<String, dynamic>> r) =>
                  !wantedPaths.contains(r.path),
            )
            .toList(growable: false);

    // Every read first — Firestore transactions require it.
    final List<DocumentSnapshot<Map<String, dynamic>>> claims =
        <DocumentSnapshot<Map<String, dynamic>>>[
      for (final DocumentReference<Map<String, dynamic>> r in wanted)
        await transaction.get(r),
    ];
    final List<DocumentSnapshot<Map<String, dynamic>>> old =
        <DocumentSnapshot<Map<String, dynamic>>>[
      for (final DocumentReference<Map<String, dynamic>> r in released)
        await transaction.get(r),
    ];

    for (final DocumentSnapshot<Map<String, dynamic>> claim in claims) {
      final Object? holder = claim.data()?[fDatabaseId];
      if (claim.exists && holder != databaseId) {
        throw const DuplicateTitleException();
      }
    }
    for (final DocumentReference<Map<String, dynamic>> r in wanted) {
      transaction.set(r, <String, Object>{fDatabaseId: databaseId});
    }
    for (final DocumentSnapshot<Map<String, dynamic>> was in old) {
      if (was.exists && was.data()?[fDatabaseId] == databaseId) {
        transaction.delete(was.reference);
      }
    }
  }
}

/// Another database already holds this title (DB-CREATE-11).
class DuplicateTitleException implements Exception {
  const DuplicateTitleException();
}
