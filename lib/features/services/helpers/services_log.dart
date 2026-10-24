/// Module: services / helpers
///
///*************************** FILE INFO ****************************///
/// File Name: services_log.dart
/// Purpose: The services module's one logging call, replacing every
///          `print` / `debugPrint` (rule "No print / debugPrint"). Writes to
///          the developer log under the name "services", in debug builds
///          only, so nothing is printed in release.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Function Name: [svcLog]
///
/// Purpose: Logs [message] (and an optional [error] / [stackTrace]) to the
/// developer log in debug builds.
///
/// Parameters:
/// - [message]: what happened.
/// - [error]: the caught error, if any.
/// - [stackTrace]: its stack trace, if any.
void svcLog(Object? message, {Object? error, StackTrace? stackTrace}) {
  if (!kDebugMode) return;
  developer.log(
    '$message',
    name: 'services',
    error: error,
    stackTrace: stackTrace,
  );
}
