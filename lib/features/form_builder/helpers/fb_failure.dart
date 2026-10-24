/// Module: core/helper/form_builder
///
///*************************** FILE INFO ****************************///
/// File Name: fb_failure.dart
/// Description: Turns a caught error into a Failure with a translated
///              message; the raw error is only logged in debug builds.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Function Name: [fbFailure]
///
/// Purpose: The user must never read `e.toString()` (Firestore codes,
/// stack-trace text). This keeps the raw [error] for debugging and gives the
/// UI a translated message.
///
/// Parameters:
/// - [error]: the caught error.
/// - [stackTrace]: its stack trace, when there is one.
///
/// Returns: a [FirebaseFailure] carrying a translated "please try again".
FirebaseFailure fbFailure(Object error, [StackTrace? stackTrace]) {
  if (kDebugMode) {
    developer.log('$error',
        name: 'FormBuilder', error: error, stackTrace: stackTrace);
  }
  return FirebaseFailure(S.current.errorOccuredPleaseTryAgain);
}
