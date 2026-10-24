/// Module: GRC
///
///*************************** FILE INFO ****************************///
/// File Name: grc_notification_opener.dart
/// Purpose: Opens the record a GRC notification's View points at, on top of
///          the GRC module list.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Owner, 22/10/2026: every notification's View opens the place you act on
/// it, not the module's main page. The senders write the record into
/// `Request_Id` ([GrcNotificationRecord]); `NotificationRouting` hands it to
/// [PendingNotificationRecord]; `GovernanceRiskAndCompliancePage` takes it on
/// its first build and calls [GrcNotificationOpener.open].
///
/// THE STACK IS THE ONE A USER WOULD HAVE TAPPED THROUGH — module details,
/// then the policy, then the control — so Back walks out one level at a time
/// and the breadcrumbs (which pop a fixed number of routes) still land right.
///
/// Anything that cannot be read any more (a deleted policy, a control taken
/// off this user) opens the nearest level that still exists.
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/grc/data/services/grc_notification_support.dart';
import 'package:knowticed_plus/features/grc/grc10_request/presentation/ui/pages/grc_requests_list_page.dart';
import 'package:knowticed_plus/features/grc/grc11_module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/grc11_module/presentation/ui/pages/grc_module_details_page.dart';
import 'package:knowticed_plus/features/grc/grc11_module/presentation/ui/pages/grc_previous_module_owners_page.dart';
import 'package:knowticed_plus/features/grc/grc12_my_audit/presentation/ui/pages/my_audits_list_page.dart';
import 'package:knowticed_plus/features/grc/grc13_policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/grc13_policy/presentation/ui/pages/policy_details_page.dart';
import 'package:knowticed_plus/features/grc/grc13_policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_page.dart';
import 'package:knowticed_plus/features/grc/grc2_approval/presentation/ui/pages/approvals_list_page.dart';
import 'package:knowticed_plus/features/grc/grc4_assignment_control/presentation/ui/pages/assignment_controls_list_page.dart';
import 'package:knowticed_plus/features/grc/grc5_control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/grc5_control/presentation/ui/pages/control_details_page.dart';
import 'package:knowticed_plus/features/grc/grc5_control/presentation/ui/pages/control_weight_issue/control_weight_issue_page.dart';
import 'package:knowticed_plus/features/grc/grc6_control_champion/presentation/ui/pages/control_champion_details_page.dart';
import 'package:knowticed_plus/features/grc/grc7_control_owner/presentation/ui/pages/control_owner_details_page.dart';
import 'package:knowticed_plus/features/grc/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/helpers/grc_notification_record.dart';
import 'package:knowticed_plus/features/notification/domain/enums/grc/grc_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/routing/pending_notification_record.dart';

abstract final class GrcNotificationOpener {
  /// Pushes [pending]'s record onto [navigator]. Resolves false when there
  /// was nothing to open — an id this file cannot read, or a module that no
  /// longer exists — so the caller keeps its old landing.
  ///
  /// [onBack] runs when the user is back on the list (the list reloads).
  /// A removed module has no details page, only the restore form the list
  /// owns, so [onRemovedModule] opens it.
  static Future<bool> open(
    NavigatorState navigator,
    PendingNotificationRecord pending, {
    required VoidCallback onBack,
    required void Function(GRCModuleEntity module) onRemovedModule,
  }) async {
    final GrcNotificationRecord? record =
        GrcNotificationRecord.parse(pending.recordId);
    if (record == null) return false;
    final GRCModuleEntity? module = await GrcNotify.module(record.moduleId);
    if (module == null || !navigator.mounted) return false;
    if (module.isRemoved) {
      onRemovedModule(module);
      return true;
    }

    final List<Route<Object?>> routes = await _stackFor(
      GrcNotificationPage.fromKey(pending.pageKey),
      record,
      module,
    );
    if (!navigator.mounted || routes.isEmpty) return false;
    navigator.push<Object?>(routes.first).then((_) => onBack());
    for (final Route<Object?> route in routes.skip(1)) {
      navigator.push<Object?>(route);
    }
    return true;
  }

  static Future<List<Route<Object?>>> _stackFor(
    GrcNotificationPage? page,
    GrcNotificationRecord record,
    GRCModuleEntity module,
  ) async {
    final Route<Object?> moduleDetails = MaterialPageRoute<Object?>(
      builder: (_) => GrcModuleDetailsPage(module: module),
    );
    final String? controlId =
        record.controlId.isEmpty ? null : record.controlId;
    final String? requestId =
        record.requestId.isEmpty ? null : record.requestId;

    switch (page) {
      case GrcNotificationPage.grcPreviousModuleOwners:
        // The list opens this straight from a module's "..." menu.
        return <Route<Object?>>[
          _fade(GrcPreviousModuleOwnersPage(module: module)),
        ];

      case GrcNotificationPage.grcPolicyDetails:
      case GrcNotificationPage.grcControlDetails:
      case GrcNotificationPage.grcControlWeightIssue:
        final PolicyEntity? policy =
            await GrcNotify.policy(module.moduleId, record.policyId);
        if (policy == null) return <Route<Object?>>[moduleDetails];
        final List<Route<Object?>> stack = <Route<Object?>>[
          moduleDetails,
          _fade(PolicyDetailsPage(
            policyId: policy.id,
            moduleId: module.moduleId,
            module: module,
          )),
        ];
        if (page == GrcNotificationPage.grcControlWeightIssue) {
          stack.add(_fade(ControlWeightIssuePage(
            module: module,
            policy: policy,
          )));
        } else if (page == GrcNotificationPage.grcControlDetails &&
            controlId != null) {
          final List<ControlEntity> controls =
              await GrcNotify.policyControls(module.moduleId, policy.id);
          final ControlEntity? control =
              controls.where((c) => c.id == controlId).firstOrNull;
          if (control != null) {
            stack.add(_fade(ControlDetailsPage(
              module: module,
              policy: policy,
              control: control,
              siblingControls: controls,
            )));
          }
        }
        return stack;

      case GrcNotificationPage.grcPolicyWeightIssue:
        return <Route<Object?>>[
          moduleDetails,
          _fade(PolicyWeightIssuePage(module: module)),
        ];

      // Sent to the champion / owner themselves, so the record to open is
      // the signed-in user's own champion / owner entry in this module.
      case GrcNotificationPage.grcControlChampionDetails:
        final champion =
            await GrcNotify.champion(module.moduleId, currentGrcUserEmail());
        return <Route<Object?>>[
          moduleDetails,
          if (champion != null)
            _fade(ControlChampionDetailsPage(
              champion: champion,
              module: module,
            )),
        ];
      case GrcNotificationPage.grcControlOwnerDetails:
        final owner =
            await GrcNotify.owner(module.moduleId, currentGrcUserEmail());
        return <Route<Object?>>[
          moduleDetails,
          if (owner != null)
            _fade(ControlOwnerDetailsPage(owner: owner, module: module)),
        ];

      // Evidence work: the list the user acts from, with the one control's
      // item opened on top once the list has loaded.
      case GrcNotificationPage.grcAssignmentControls:
        return <Route<Object?>>[
          moduleDetails,
          _fade(AssignmentControlsListPage(
            module: module,
            focusControlId: controlId,
          )),
        ];
      case GrcNotificationPage.grcApprovals:
        return <Route<Object?>>[
          moduleDetails,
          _fade(ApprovalsListPage(module: module, focusControlId: controlId)),
        ];
      case GrcNotificationPage.grcMyAudits:
        return <Route<Object?>>[
          moduleDetails,
          _fade(MyAuditsListPage(module: module, focusControlId: controlId)),
        ];

      // Reassignment requests. Approvers get the module's requests; the
      // requester gets "My Requests", where their own request can be
      // cancelled — the same split the module tabs make.
      case GrcNotificationPage.grcRequests:
        return <Route<Object?>>[
          moduleDetails,
          MaterialPageRoute<Object?>(
            builder: (_) => GrcRequestsListPage(
              module: module,
              focusRequestId: requestId,
            ),
          ),
        ];
      case GrcNotificationPage.grcRequestDetails:
        return <Route<Object?>>[
          moduleDetails,
          MaterialPageRoute<Object?>(
            builder: (_) => GrcRequestsListPage(
              module: module,
              onlyRequestedBy: currentGrcUserEmail(),
              focusRequestId: requestId,
            ),
          ),
        ];

      case GrcNotificationPage.grcModules:
      case GrcNotificationPage.grcModuleDetails:
      case null:
        return <Route<Object?>>[moduleDetails];
    }
  }

  static Route<Object?> _fade(Widget page) => PageRouteBuilder<Object?>(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      );
}
