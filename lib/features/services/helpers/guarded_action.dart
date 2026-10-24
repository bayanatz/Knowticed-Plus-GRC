/// Module: services / helpers
///
///*************************** FILE INFO ****************************///
/// File Name: guarded_action.dart
/// Purpose: One place that turns a failing async action into a value, so
///          pages and widgets react to the result instead of wrapping calls
///          in try/catch (rule C8).
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

/// Function Name: [svcGuard]
///
/// Purpose: Runs [action] and reports whether it failed.
///
/// Parameters:
/// - [action]: the work to run.
///
/// Returns: the error [action] threw (already logged), or `null` when it
/// finished.
Future<Object?> svcGuard(Future<void> Function() action) async {
  try {
    await action();
    return null;
  } catch (e, st) {
    svcLog('action failed', error: e, stackTrace: st);
    return e;
  }
}
