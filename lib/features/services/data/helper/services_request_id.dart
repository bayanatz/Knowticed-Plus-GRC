/// Module: services / data / helper
///
///*************************** FILE INFO ****************************///
/// File Name: services_request_id.dart
/// Description: Readable, collision-free ids for new service requests.
/// Author: Moataz Handousa
/// Created at: 18/10/2026
///
/// Request ids used to be "Request{random 0-99}{MMMdd_yyyy}" written with
/// `.set()`: two requests on the same day collided 1 time in 100 and the
/// second silently overwrote the first. New requests take the next number
/// from `Modules/services/Counters/requests` inside a transaction:
/// REQ-2026-0001, REQ-2026-0002 … (numbering restarts each year).
/// Old "Request…" ids keep working; only new requests use this.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

abstract final class ServicesRequestId {
  const ServicesRequestId._();

  static const String counterPath = 'Modules/services/Counters/requests';

  /// `REQ-{year}-{4-digit number}` for [number] in [year].
  static String format(int year, int number) =>
      'REQ-$year-${number.toString().padLeft(4, '0')}';

  /// The next request number for [year], given the counter document [data]
  /// (`{year, last}`); a new year starts again at 1.
  static int nextNumber(Map<String, dynamic>? data, int year) {
    final int? storedYear = (data?['year'] as num?)?.toInt();
    final int last =
        storedYear == year ? ((data?['last'] as num?)?.toInt() ?? 0) : 0;
    return last + 1;
  }

  /// Reserves and returns the next request id.
  static Future<String> next({FirebaseFirestore? firestore}) async {
    final FirebaseFirestore db = firestore ?? FirebaseFirestore.instance;
    final int year = DateTime.now().year;
    final DocumentReference<Map<String, dynamic>> ref =
        db.doc(getBaseUrl(counterPath));
    final int number = await db.runTransaction<int>((tx) async {
      final snap = await tx.get(ref);
      final int n = nextNumber(snap.data(), year);
      tx.set(ref, <String, dynamic>{'year': year, 'last': n});
      return n;
    });
    return format(year, number);
  }
}
