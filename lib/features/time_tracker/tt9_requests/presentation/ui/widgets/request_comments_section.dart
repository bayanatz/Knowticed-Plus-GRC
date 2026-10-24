/// Module: time_tracker / tt9_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_comments_section.dart
/// Purpose: Declares `RequestCommentsSection` — "Inquiries And Comments"
///          on a Time Tracker request.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Updated: 22/10/2026 - Moataz (Request Details, iPad): "this is the old
/// one … Settings → Requests is the perfect model, apply it everywhere".
/// The page-local box (its own bubbles, composer, Discard / Save editor) is
/// gone: this is now the shared `UniversalCommentSection` — the Settings
/// box — over Time Tracker's own thread, through [_TimeTrackerCommentSource].
/// What stays Time Tracker's: the `Requests/{id}/Comments` sub-collection
/// merged with an old request's embedded comments (read-only), the write
/// permission (`Comment_On_Requests` / `Comment_On_Approvals` →
/// `RequestActionsCubit.mayComment`), the soft delete and the failure
/// dialogs (`RequestFlows.afterAction`). Comments here are text only, so the
/// box shows no attachment button.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_comment_widget.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_comment_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/request_actions_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_state.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_flows.dart';

class RequestCommentsSection extends StatefulWidget {
  const RequestCommentsSection({
    super.key,
    required this.request,
    required this.state,
    required this.asApprover,
  });

  final TimeTrackerRequest request;
  final RequestsState state;
  final bool asApprover;

  @override
  State<RequestCommentsSection> createState() => _RequestCommentsSectionState();
}

class _RequestCommentsSectionState extends State<RequestCommentsSection> {
  @override
  Widget build(BuildContext context) {
    final TimeTrackerRequest request = widget.request;
    final bool asApprover = widget.asApprover;
    final bool isMobile = MediaQuery.sizeOf(context).shortestSide < 600;
    return UniversalCommentSection(
      currentUserId: GetIt.instance<TimeTrackerAccess>().currentUserEmail,
      source: _TimeTrackerCommentSource(
        request: request,
        asApprover: asApprover,
        actions: context.read<RequestActionsCubit>(),
        me: GetIt.instance<TimeTrackerAccess>().currentUserEmail,
        afterAction: () => RequestFlows.afterAction(context),
      ),
      // Same sizes as Settings → Request Details.
      collapsedHeight: isMobile ? 320.h : 400.h,
      fitBelowPageTopWhenExpanded: true,
    );
  }
}

/// Time Tracker's thread, as the shared box reads it.
class _TimeTrackerCommentSource extends CommentSource {
  const _TimeTrackerCommentSource({
    required this.request,
    required this.asApprover,
    required this.actions,
    required this.me,
    required this.afterAction,
  });

  final TimeTrackerRequest request;
  final bool asApprover;
  final RequestActionsCubit actions;
  final String me;

  /// Shows the failure dialog of the last action, if it failed.
  final Future<void> Function() afterAction;

  @override
  String get identity => 'time_tracker|${request.id}|$asApprover';

  @override
  bool get canWrite => actions.mayComment(request, asApprover: asApprover);

  @override
  bool get supportsFiles => false;

  @override
  Stream<List<CommentEntry>> watch() =>
      actions.watchComments(request.id).map((List<RequestComment> stored) =>
          RequestCommentRules.thread(stored, legacy: request.legacyComments)
              .map(_entry)
              .toList());

  CommentEntry _entry(RequestComment c) {
    final RequestAttachment? file =
        c.attachments.isEmpty ? null : c.attachments.first;
    return CommentEntry(
      id: c.id,
      text: c.text,
      commenterEmail: c.authorEmail,
      date: c.createdAt,
      fileUrl: file?.url,
      fileName:
          file == null ? null : (file.name.isEmpty ? file.url : file.name),
      isEdited: c.editedAt != null,
      canModify: RequestCommentRules.canModify(c, me),
    );
  }

  @override
  Future<void> add({
    required String currentUserId,
    String? text,
    String? fileUrl,
    String? fileName,
    String? fileSize,
  }) async {
    if (text == null || text.isEmpty) return;
    await actions.addComment(request, text, asApprover: asApprover);
    await afterAction();
  }

  @override
  Future<void> edit(CommentEntry comment, String text) async {
    await actions.editComment(request, comment.id, text,
        asApprover: asApprover);
    await afterAction();
  }

  @override
  Future<bool> delete(CommentEntry comment) async {
    final bool ok = await actions.deleteComment(request, comment.id,
        asApprover: asApprover);
    // After the box's confirm dialog has closed.
    if (!ok) {
      unawaited(
          Future<void>.delayed(const Duration(milliseconds: 350), afterAction));
    }
    return ok;
  }
}
