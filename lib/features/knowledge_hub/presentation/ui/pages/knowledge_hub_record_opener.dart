/// Module: knowledge_hub_module / presentation/ui/pages/knowledge_hub_record_opener.dart
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_hub_record_opener.dart
/// Description: Opens the Knowledge Hub document a notification is about.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Owner, 22/10/2026: a notification's View opens the place you act on it,
/// not the module's main page. Every Knowledge Hub notification stores the
/// document's `knowledgeId` as its `Request_Id`; `NotificationRouting` hands
/// it over as a `PendingNotificationRecord`, and [KnowledgeHubPage] calls
/// [KnowledgeHubRecordOpener.open] once its landing page is laid out.
///
/// Which screen opens comes from the notification's `name_of_page`:
///
///   ApprovalsDetails / Approvals     → Approvals queue, then the document's
///                                      approval details (Approve / Reject)
///   SubmissionDetails / Submissions  → My Submissions, then the submission's
///                                      details
///   anything else                    → the published document's details
///
/// The list goes under the details so Back lands on it, as if the reader had
/// tapped the card themselves. A document that cannot be found (deleted, or
/// no access) leaves the reader on the list.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/ui/pages/view_knowledge_details.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/ui/pages/submissions_screen.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/pages/submission_details_screen.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/controller/approvals_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/ui/pages/approvals_details_screen.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/ui/pages/approvals_screen.dart';
import 'package:knowticed_plus/features/knowledge_hub/knowledge_hub_get_it.dart';
import 'package:knowticed_plus/features/notification/domain/enums/knowledge_hub/knowledge_hub_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/routing/pending_notification_record.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Which view of a document a notification opens.
enum KhRecordView {
  /// The approver's details, with Approve / Reject.
  approval,

  /// The author's submission details, with its status history.
  submission,

  /// The published document, with its comments.
  document,
}

typedef KhDocumentFetcher = Future<CreateKnowledgeModel?> Function(
    String knowledgeId);

class KnowledgeHubRecordOpener {
  KnowledgeHubRecordOpener._();

  /// Loads a document by its `knowledgeId`. Tests swap it for a fake.
  @visibleForTesting
  static KhDocumentFetcher fetch = (String knowledgeId) => KnowledgeHubDI
      .knowledgeHubServices
      .fetchKnowledgeByKnowledgeId(knowledgeId);

  /// Replaces the real list / details screens in widget tests, which cannot
  /// build them without Firebase. [document] is null for the list.
  @visibleForTesting
  static Widget Function(KhRecordView view, CreateKnowledgeModel? document)?
      debugScreenBuilder;

  /// The view for a stored `name_of_page`.
  static KhRecordView viewFor(String pageKey) {
    switch (KnowledgeHubNotificationPage.fromKey(pageKey)) {
      case KnowledgeHubNotificationPage.approvals:
      case KnowledgeHubNotificationPage.approvalsDetails:
        return KhRecordView.approval;
      case KnowledgeHubNotificationPage.submissions:
      case KnowledgeHubNotificationPage.submissionDetails:
        return KhRecordView.submission;
      case KnowledgeHubNotificationPage.viewKnowledgeHub:
      case KnowledgeHubNotificationPage.viewKnowledgeDetails:
      case null:
        return KhRecordView.document;
    }
  }

  /// Pushes the list (for approval / submission views), loads the document,
  /// then pushes its details on top. [context] must sit below the module's
  /// bloc providers and inside the module's navigator.
  static Future<void> open(
    BuildContext context,
    PendingNotificationRecord record,
  ) async {
    final NavigatorState navigator = Navigator.of(context);
    final KhRecordView view = viewFor(record.pageKey);

    // One approvals cubit for the queue and the details: Approve / Reject
    // look the document up in the queue the list loads into it.
    final ApprovalsCubit? approvals =
        view == KhRecordView.approval && debugScreenBuilder == null
            ? KnowledgeHubDI.approvalsCubit()
            : null;

    final Widget? list = switch (view) {
      KhRecordView.approval => debugScreenBuilder?.call(view, null) ??
          BlocProvider<ApprovalsCubit>(
            create: (_) => approvals!,
            child: ApprovalsScreen(),
          ),
      KhRecordView.submission => debugScreenBuilder?.call(view, null) ??
          BlocProvider(
            create: (_) => KnowledgeHubDI.submissionsCubit(),
            child: SubmissionsScreen(),
          ),
      KhRecordView.document => null,
    };
    if (list != null) {
      navigator.push(MaterialPageRoute<void>(builder: (_) => list));
    }

    CreateKnowledgeModel? document;
    try {
      document = await fetch(record.recordId);
    } catch (e) {
      khLog('[KH-NOTIFY] open ${record.recordId} failed: $e');
    }
    if (document == null || !navigator.mounted) return;
    final CreateKnowledgeModel doc = document;

    navigator.push(
      MaterialPageRoute<void>(
        builder: (BuildContext ctx) =>
            debugScreenBuilder?.call(view, doc) ??
            _details(ctx, view, doc, approvals),
      ),
    );
  }

  /// The same screens, with the same arguments, the lists open on a tap
  /// (`approvals_screen_sections_builders.dart`,
  /// `submitted_documents_view_builders.dart`, `view_knowledge_hub.dart`).
  static Widget _details(
    BuildContext context,
    KhRecordView view,
    CreateKnowledgeModel doc,
    ApprovalsCubit? approvals,
  ) {
    switch (view) {
      case KhRecordView.approval:
        return BlocProvider<ApprovalsCubit>.value(
          value: approvals!,
          child: ApprovalsDetailsScreen(
            documentName: KhLocale.pick(context,
                en: doc.currentNameEnglish, ar: doc.currentNameArabic),
            knowledgeId: doc.currentKnowledgeId,
            fileName: doc.currentDocumentFileName,
            fileType: doc.currentKnowledgeDocumentType,
            fileUrl: doc.currentDocumentUrl,
            department: doc.currentOwningDepartment,
            documentDesc: KhLocale.pick(context,
                en: doc.currentDescriptionEnglish,
                ar: doc.currentDescriptionArabic),
            createdByEmail: doc.currentCreatedByEmail,
            createdTimestamp: doc.currentTimestamp,
            status: doc.currentStatus,
            fileExtension: doc.currentDocumentExtension,
            startDate: doc.currentStartDateTime,
            endDate: doc.currentEndDateTime,
            startTime: doc.currentStartTime,
            endTime: doc.currentEndTime,
          ),
        );
      case KhRecordView.submission:
        final int? uploadMillis =
            doc.timestamps.isNotEmpty ? doc.timestamps.first : null;
        return BlocProvider(
          create: (_) => KnowledgeHubDI.submissionsCubit(),
          child: SubmissionDetailsScreen(
            createdBy: doc.currentCreatedByEmail,
            statusHistory: doc.status,
            documentNameAr: doc.currentNameArabic,
            documentName: doc.currentNameEnglish,
            documentEnglishDescription: doc.currentDescriptionEnglish,
            documentEnglishDescriptionAr: doc.currentDescriptionArabic,
            documentExtension: doc.currentDocumentExtension,
            documentType: doc.currentKnowledgeDocumentType,
            fileType: doc.currentKnowledgeDocumentType,
            fileUrl: doc.currentDocumentUrl,
            knowledgeId: doc.currentKnowledgeId,
            owningDepartment: doc.currentOwningDepartment,
            submissionDate: uploadMillis != null
                ? KhLocale.formatDate(
                    context,
                    DateTime.fromMillisecondsSinceEpoch(uploadMillis),
                    'dd MMM yyyy')
                : S.of(context).notAvailable,
            currentStatus: doc.currentStatus,
            limitedDepartments: doc.currentLimitedDepartmentsList,
            startDate: _firstOf(doc.startDateTime),
            endDate: _firstOf(doc.endDateTime),
            startTime: doc.currentStartTime,
            endTime: doc.currentEndTime,
          ),
        );
      case KhRecordView.document:
        final DateTime? publishedAt = doc.publishedAt;
        return ViewKnowledgeDetails(
          emailUser: doc.currentCreatedByEmail,
          knowledgeId: doc.currentKnowledgeId,
          documentName: doc.currentNameEnglish,
          documentNameAr: doc.currentNameArabic,
          publishDate: publishedAt == null
              ? '-'
              : KhLocale.formatDate(context, publishedAt, 'dd MMM yyyy'),
          documentType: doc.currentKnowledgeDocumentType,
          owningDepartment: doc.currentOwningDepartment,
          documentEnglishDescription: doc.currentDescriptionEnglish,
          documentEnglishDescriptionAr: doc.currentDescriptionArabic,
          fileType: doc.currentDocumentExtension,
          fileUrl: doc.currentDocumentUrl,
          documentExtension: doc.currentDocumentExtension,
        );
    }
  }

  /// The first entry of a stored date list, as the submissions list passes it.
  static dynamic _firstOf(dynamic value) =>
      value is List ? (value.isNotEmpty ? value.first : value) : value;
}
