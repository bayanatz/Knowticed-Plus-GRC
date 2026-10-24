/// Module: services / helpers
///
///*************************** FILE INFO ****************************///
/// File Name: services_feedback.dart
/// Purpose: Short messages shown after an action that was refused or only
///          partly worked — a refused approve/reject (SVC-REQ-10) or a saved
///          change whose notification could not be sent (SVC-REQ-08,
///          SVC-PROV-12). One place, so every screen words them the same.
/// Author: Amr Mesbah
/// Created at: 22/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/domain/entities/approval_decision.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Class Name: [ServicesFeedback]
///
/// Purpose: Builds and shows the warning messages of the services module.
class ServicesFeedback {
  const ServicesFeedback._();

  /// Function Name: [refusalText]
  ///
  /// Purpose: Why an approve / reject was not saved.
  static String refusalText(S s, ApprovalRefusal? refusal) {
    switch (refusal) {
      case ApprovalRefusal.notFound:
        return s.svcRequestNotFound;
      case ApprovalRefusal.notPending:
        return s.svcRequestNoLongerPending;
      case ApprovalRefusal.notYourTurn:
        return s.svcNotYourTurnToDecide;
      case null:
        return s.svcDecisionFailed;
    }
  }

  /// Function Name: [showWarning]
  ///
  /// Purpose: Shows [text] in a SnackBar. Take [messenger] before any await.
  static void showWarning(ScaffoldMessengerState messenger, String text) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: AppColors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
