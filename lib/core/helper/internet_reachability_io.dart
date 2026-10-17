/// Module: core/helper
/// File Name: internet_reachability_io.dart
/// Description: Real internet check (DNS lookup) for platforms with dart:io.
/// Author: Amr Mesbah
/// Created at: 14/10/2026
library;

import 'dart:io';

/// Host the app needs anyway (Firestore), so "reachable" means usable.
const String _kProbeHost = 'firestore.googleapis.com';

/// true = the internet answers, false = it does not, null = cannot tell.
Future<bool?> hasInternetAccess() async {
  try {
    final List<InternetAddress> result = await InternetAddress.lookup(
      _kProbeHost,
    ).timeout(const Duration(seconds: 4));
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}
