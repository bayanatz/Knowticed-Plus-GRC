/// Module: GRC (debug)
///
///*************************** FILE INFO ****************************///
/// File Name: grc_view_tests.dart
/// Purpose: Sends the signed-in user one GRC notification per View landing,
///          each pointing at a REAL record, so "View opens the record" can be
///          checked by hand on a device.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Owner, 22/10/2026: approved test notifications in the demo accounts.
/// Reads existing modules / policies / controls / champions / requests and
/// sends through the real GRC senders (same template, `pageKey` and
/// `Request_Id` encoding as production) with [receiverEmail] as the only
/// recipient. Writes notification documents only — no business record is
/// touched. A kind with no matching record is skipped with a debugPrint.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:knowticed_plus/features/grc/data/services/grc_assignee_notification_service.dart';
import 'package:knowticed_plus/features/grc/data/services/grc_notification_support.dart';
import 'package:knowticed_plus/features/grc/grc10_request/data/models/grc_request_model.dart';
import 'package:knowticed_plus/features/grc/grc10_request/domain/entities/grc_request_entity.dart';
import 'package:knowticed_plus/features/grc/grc10_request/domain/entities/grc_request_type.dart';
import 'package:knowticed_plus/features/grc/grc11_module/data/models/grc_module_model.dart';
import 'package:knowticed_plus/features/grc/grc11_module/data/services/grc_module_notification_service.dart';
import 'package:knowticed_plus/features/grc/grc11_module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/grc13_policy/data/models/policy_model.dart';
import 'package:knowticed_plus/features/grc/grc13_policy/data/services/grc_policy_notification_service.dart';
import 'package:knowticed_plus/features/grc/grc13_policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/grc4_assignment_control/data/services/grc_evidence_notification_service.dart';
import 'package:knowticed_plus/features/grc/grc5_control/data/services/grc_control_notification_service.dart';
import 'package:knowticed_plus/features/grc/grc5_control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/grc5_control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/helpers/constants/grc_firebase_paths.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_template_service.dart';
import 'package:knowticed_plus/features/notification/domain/enums/grc/grc_events.dart';

/// Returns how many notifications were sent. Never throws.
Future<int> sendGrcViewTests({
  required String receiverEmail,
  required bool isArabic,
}) async {
  final String me = receiverEmail.trim();
  debugPrint('[grc-view-test] START receiver="$me"');
  if (me.isEmpty) {
    debugPrint('[grc-view-test] no receiver - nothing sent');
    return 0;
  }
  try {
    final _Records r = await _Records.find(me);
    debugPrint('[grc-view-test] records: modules=${r.modulesRead} '
        'parseFailures=${r.parseFailures} module=${r.module?.moduleId} '
        'policy=${r.policy?.id} control=${r.control?.id} '
        'assignment=${r.assignment?.pair.controlId} '
        'championAssignment=${r.championAssignment?.pair.controlId} '
        'request=${r.request?.request.id}');
    final List<String> to = <String>[me];
    int sent = 0;

    Future<void> send(
      String kind,
      GrcNotificationEvent event,
      Future<int> Function()? run,
    ) async {
      if (run == null) {
        debugPrint('[grc-view-test] $kind skipped - no record found');
        return;
      }
      try {
        final int n = await run();
        sent += n;
        debugPrint('[grc-view-test] $kind sent=$n');
        if (n == 0) await _explainNoSend(kind, event);
      } catch (e) {
        debugPrint('[grc-view-test] $kind failed - $e');
      }
    }

    final GRCModuleEntity? module = r.module;
    final PolicyEntity? policy = r.policy;
    final ControlEntity? control = r.control;

    // 1. Module details.
    await send(
      'module',
      GrcNotificationEvent.moduleUpdatedEdited,
      module == null
          ? null
          : () => GrcModuleNotificationService.moduleUpdated(
                actorEmail: me,
                moduleId: module.moduleId,
                moduleName: module.moduleNameEn,
                recipients: to,
                isArabic: isArabic,
              ),
    );

    // 2. Policy details.
    await send(
      'policy',
      GrcNotificationEvent.policyUpdatedEdited,
      module == null || policy == null
          ? null
          : () => GrcPolicyNotificationService.policyUpdated(
                actorEmail: me,
                moduleId: module.moduleId,
                policyId: policy.id,
                policyName: policy.policyNameEn,
                moduleName: module.moduleNameEn,
                recipients: to,
                isArabic: isArabic,
              ),
    );

    // 3. Control details.
    await send(
      'control',
      GrcNotificationEvent.controlUpdated,
      module == null || policy == null || control == null
          ? null
          : () => GrcControlNotificationService.controlUpdated(
                actorEmail: me,
                moduleId: module.moduleId,
                policyId: policy.id,
                controlId: control.id,
                controlName: control.controlsNameEn,
                policyName: policy.policyNameEn,
                recipients: to,
                isArabic: isArabic,
              ),
    );

    // 4. Champion / owner view — the receiver's own entry.
    final _Assignment? a = r.assignment;
    await send(
      'assignee',
      a?.role == GrcAssigneeRole.owner
          ? GrcNotificationEvent.controlOwnerAssigned
          : GrcNotificationEvent.controlAssignedToChampion,
      a == null
          ? null
          : () async => GrcAssigneeNotificationService.assigned(
                role: a.role,
                actorEmail: me,
                moduleId: a.module.moduleId,
                policyId: a.pair.policyId,
                controlId: a.pair.controlId,
                controlName: await GrcNotify.controlName(
                    a.module.moduleId, a.pair.policyId, a.pair.controlId),
                policyName: await GrcNotify.policyName(
                    a.module.moduleId, a.pair.policyId),
                assigneeEmails: to,
                isArabic: isArabic,
              ),
    );

    // 5. Task item — the receiver's Assignment Controls, that control open.
    final _Assignment? task = r.championAssignment;
    await send(
      'task',
      GrcNotificationEvent.departmentManagerRejected,
      task == null
          ? null
          : () async => GrcEvidenceNotificationService.managerRejected(
                actorEmail: me,
                moduleId: task.module.moduleId,
                policyId: task.pair.policyId,
                controlId: task.pair.controlId,
                controlName: await GrcNotify.controlName(task.module.moduleId,
                    task.pair.policyId, task.pair.controlId),
                departmentManagerName: GrcNotify.personName(me),
                championEmails: to,
                isArabic: isArabic,
              ),
    );

    // 6. Request — the module's Requests, that request open.
    final _Request? req = r.request;
    await send(
      'request',
      req?.role == GrcAssigneeRole.owner
          ? GrcNotificationEvent.controlOwnerReassignmentRequestSubmitted
          : GrcNotificationEvent.controlChampionReassignmentRequestSubmitted,
      req == null
          ? null
          : () => GrcAssigneeNotificationService.reassignmentSubmitted(
                role: req.role,
                actorEmail: me,
                moduleId: req.request.moduleId,
                requestId: req.request.id,
                requesterName: GrcNotify.personName(req.request.requestedBy),
                moduleName: req.moduleName,
                approverEmails: to,
                isArabic: isArabic,
              ),
    );

    debugPrint('[grc-view-test] done - $sent sent to $me');
    return sent;
  } catch (e, st) {
    debugPrint('[grc-view-test] aborted - $e\n$st');
    return 0;
  }
}

/// Why a send that resolved to 0 wrote nothing: a missing or switched-off
/// template is the only silent refusal `AppNotificationSender` has.
Future<void> _explainNoSend(String kind, GrcNotificationEvent event) async {
  try {
    final template = await NotificationTemplateService()
        .getTemplate(module: event.module.key, eventType: event.key);
    if (template == null) {
      debugPrint('[grc-view-test] $kind: no template for '
          '${event.module.key}_${event.key} (not in catalog or read failed)');
    } else if (!template.isEnabled) {
      debugPrint('[grc-view-test] $kind: template '
          '${event.module.key}_${event.key} is switched OFF in '
          'Notification Control');
    } else {
      debugPrint('[grc-view-test] $kind: template fine - the Firestore write '
          'failed (rules / path); see the sender');
    }
  } catch (e) {
    debugPrint('[grc-view-test] $kind: template check failed - $e');
  }
}

class _Assignment {
  const _Assignment(this.module, this.role, this.pair);
  final GRCModuleEntity module;
  final GrcAssigneeRole role;
  final AssigningControlEntity pair;
}

class _Request {
  const _Request(this.request, this.role, this.moduleName);
  final GrcRequestEntity request;
  final GrcAssigneeRole role;
  final String moduleName;
}

/// The first real records of each kind, read once.
class _Records {
  int modulesRead = 0;
  int parseFailures = 0;
  GRCModuleEntity? module;
  PolicyEntity? policy;
  ControlEntity? control;
  _Assignment? assignment;
  _Assignment? championAssignment;
  _Request? request;

  static Future<_Records> find(String me) async {
    final _Records r = _Records();
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final modules =
        await db.collection(GrcFirebasePaths.modulesCollection).get();
    for (final doc in modules.docs) {
      final GRCModuleEntity module;
      try {
        module = GRCModuleModel.fromJson(doc.data()).toEntity();
      } catch (e) {
        r.parseFailures++;
        debugPrint('[grc-view-test] module ${doc.id} unreadable - $e');
        continue;
      }
      if (module.isRemoved || module.moduleId.isEmpty) continue;
      r.modulesRead++;
      final ref = doc.reference;

      if (r.control == null) {
        final policies = await ref.collection('Policies').get();
        for (final p in policies.docs) {
          final PolicyEntity policy;
          try {
            policy = PolicyModel.fromJson(p.data()).toEntity();
          } catch (_) {
            continue;
          }
          if (policy.id.isEmpty) continue;
          final controls =
              await GrcNotify.policyControls(module.moduleId, policy.id);
          if (r.policy == null || controls.isNotEmpty) {
            r.module = module;
            r.policy = policy;
            r.control = controls.isEmpty ? null : controls.first;
          }
          if (r.control != null) break;
        }
        r.module ??= module;
      }

      if (r.championAssignment == null) {
        final champion = await GrcNotify.champion(module.moduleId, me);
        if (champion != null && champion.assigningControls.isNotEmpty) {
          r.championAssignment = _Assignment(module, GrcAssigneeRole.champion,
              champion.assigningControls.first);
          r.assignment ??= r.championAssignment;
        }
      }
      if (r.assignment == null) {
        final owner = await GrcNotify.owner(module.moduleId, me);
        if (owner != null && owner.assigningControls.isNotEmpty) {
          r.assignment = _Assignment(
              module, GrcAssigneeRole.owner, owner.assigningControls.first);
        }
      }

      if (r.request == null) {
        final requests = await ref.collection('Requests').get();
        for (final q in requests.docs) {
          try {
            final GrcRequestEntity e =
                GrcRequestModel.fromJson(q.data()).toEntity();
            if (!e.type.isReassignment || e.id.isEmpty) continue;
            final GrcAssigneeRole role = e.type == GrcRequestType.reassignOwner
                ? GrcAssigneeRole.owner
                : GrcAssigneeRole.champion;
            r.request = _Request(e, role, module.moduleNameEn);
            break;
          } catch (_) {
            continue;
          }
        }
      }

      if (r.control != null &&
          r.championAssignment != null &&
          r.assignment != null &&
          r.request != null) {
        break;
      }
    }
    return r;
  }
}
