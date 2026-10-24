/// Module: messaging / helpers / debug
///
///*************************** FILE INFO ****************************///
/// File Name: messages_view_tests.dart
/// Purpose: DEBUG ONLY — sends the signed-in user one Messages notification
///          per View landing, each pointing at a REAL group / colleague, so
///          "View opens the conversation" can be tried by hand.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Owner, 22/10/2026: approved test notifications in the demo accounts. Reads
/// one group only; sends no chat message and writes nothing but notification
/// documents.
///
/// WHY NOT THROUGH `MessagesNotificationService`: its `_send` drops the signed
/// in user from the recipients (nobody is told about their own action), and
/// here the signed-in user IS the receiver. So this calls the same
/// `AppNotificationSender.sendEvent` it ends in, with the same event, page key
/// and `Request_Id` encoding (a group id, or the chat partner's email), and
/// with a group member as the sender where the real event would have one.
library;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/domain/entities/group_entity.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/domain/entities/member_entity.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/controller/groups_controller.dart';
import 'package:knowticed_plus/features/notification/domain/enums/messages/messages_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/messages/messages_notification_pages.dart';
import 'package:knowticed_plus/features/notification/helpers/services/app_notification_sender.dart';

/// Function Name: [sendMessagesViewTests]
///
/// Purpose: One notification per Messages View landing, to [receiverEmail]:
///   Group message (GroupChat)            → that group's conversation
///   Poll vote (PollDetails)              → that group's conversation
///   Scheduled message sent to a group    → that group's conversation
///   Direct message (Chat) from a member  → the chat with that member
///   Group deleted (MessagingHome)        → the Messages list
///
/// Uses a group from the Messages module's own loaded list
/// (`GroupsCubit.allGroups`) — one that has another member if possible — so
/// View is guaranteed to find it. Nothing is sent when none is loaded. The direct message is skipped when that group has no other
/// member. Never throws.
///
/// Return type: [Future<int>] — how many were stored.
Future<int> sendMessagesViewTests({
  required String receiverEmail,
  required bool isArabic,
}) async {
  try {
    final String me = receiverEmail.trim();
    if (me.isEmpty) {
      debugPrint('[MessagesViewTests] no receiver — nothing sent');
      return 0;
    }

    // The group must be one the Messages module itself lists, or View has
    // nothing to open: take it from the live GroupsCubit.allGroups, and use its
    // `groupId` (what the module matches on), not the Firestore document id.
    String groupId = '';
    String groupName = '';
    String other = '';
    if (Get.isRegistered<GroupsCubit>()) {
      final List<GroupEntity> mine = Get.find<GroupsCubit>().allGroups;
      for (final GroupEntity g in mine) {
        final String partner = g.members
            .map((MemberEntity m) => m.memberId.trim())
            .firstWhere(
                (String id) =>
                    id.isNotEmpty && id.toLowerCase() != me.toLowerCase(),
                orElse: () => '');
        groupId = g.groupId;
        groupName = g.primaryLanguageName;
        other = partner;
        if (partner.isNotEmpty) break;
      }
    }
    if (groupId.isEmpty) {
      debugPrint('[MessagesViewTests] Messages has no group loaded for $me '
          '(open Messages once first) — nothing sent');
      return 0;
    }
    // A group event needs someone to have acted; yourself if alone.
    final String actor = other.isEmpty ? me : other;
    // 23/10/2026 (Moataz: "why the email? his name"): the sample cards used the
    // member's EMAIL as the sender name ("رسالة جديدة من x@y.test") and the
    // text "View test" as the voter. They now use the person's real name, like
    // a real notification; the email only if the directory has no name.
    String nameOf(String email) {
      if (email.trim().isEmpty ||
          !Get.isRegistered<MainCoreEmployeeController>()) {
        return email;
      }
      final String name =
          Get.find<MainCoreEmployeeController>().getEmployeeName(email).trim();
      return name.isEmpty ? email : name;
    }

    final String actorName = actor == me ? 'View test' : nameOf(actor);

    int sent = 0;
    Future<void> send({
      required MessagesNotificationEvent event,
      required MessagesNotificationPage page,
      required String sender,
      required Map<TemplateVariable, String> variables,
      String requestId = '',
    }) async {
      final bool ok = await AppNotificationSender.sendEvent(
        event: event,
        pageKey: page.key,
        senderEmail: sender,
        receiverEmail: me,
        isArabic: isArabic,
        variables: variables,
        requestId: requestId,
      );
      if (ok) sent++;
    }

    await send(
      event: MessagesNotificationEvent.textMessageReceived,
      page: MessagesNotificationPage.groupChat,
      sender: actor,
      requestId: groupId,
      variables: <TemplateVariable, String>{
        TemplateVariable.senderName: actorName,
        TemplateVariable.messagePreview: 'View test — opens $groupName',
      },
    );

    await send(
      event: MessagesNotificationEvent.userVotedInPoll,
      page: MessagesNotificationPage.pollDetails,
      sender: actor,
      requestId: groupId,
      variables: <TemplateVariable, String>{
        TemplateVariable.voterName: actorName,
        TemplateVariable.optionName: 'Yes',
        TemplateVariable.pollQuestion: 'View test poll',
      },
    );

    await send(
      event: MessagesNotificationEvent.scheduledMessageSent,
      page: MessagesNotificationPage.groupChat,
      sender: me,
      requestId: groupId,
      variables: <TemplateVariable, String>{
        TemplateVariable.recipientName: groupName,
      },
    );

    if (other.isEmpty) {
      debugPrint('[MessagesViewTests] "$groupName" has no other member — '
          'skipped the direct message');
    } else {
      await send(
        event: MessagesNotificationEvent.textMessageReceived,
        page: MessagesNotificationPage.chat,
        sender: other,
        requestId: other,
        variables: <TemplateVariable, String>{
          TemplateVariable.senderName: nameOf(other),
          TemplateVariable.messagePreview: 'View test — opens this chat',
        },
      );
    }

    await send(
      event: MessagesNotificationEvent.groupDeleted,
      page: MessagesNotificationPage.messagingHome,
      sender: actor,
      variables: <TemplateVariable, String>{
        TemplateVariable.groupName: groupName,
        TemplateVariable.deletedByName: actorName,
      },
    );

    debugPrint('[MessagesViewTests] sent $sent for group "$groupName" '
        '($groupId), partner ${other.isEmpty ? '—' : other}');
    return sent;
  } catch (e) {
    debugPrint('[MessagesViewTests] failed: $e');
    return 0;
  }
}
