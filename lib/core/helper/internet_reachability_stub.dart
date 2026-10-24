/// Module: core/helper
/// File Name: internet_reachability_stub.dart
/// Description: Web fallback — no dart:io, so the browser's own online flag
///              (what connectivity_plus reports) is trusted as is.
/// Author: Amr Mesbah
/// Created at: 14/10/2026
library;

/// null = cannot tell; the reported connectivity is kept.
Future<bool?> hasInternetAccess() async => null;
