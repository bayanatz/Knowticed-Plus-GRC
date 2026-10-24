/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: submitted_document_info.dart
/// Description: Submitted document info — Submission Details (S5) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/submitted_document_data_row.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget submittedDocumentInfo(
  BuildContext context, {
  required String documentName,
  required String documentDescription,
  required bool isMobile,
  required bool lightMode,
}) {
  final isMobile = ContextExtension(context).isPhone;
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildInfoRow(
        iconPath: 'assets/icons_assets/knowledge_hub_assets/ic_file_name.svg',
        // 14/10/2026 — KH mobile report p.11/p.19: on a phone the
        // "Document Name:" label is struck out — the name stands alone (and
        // ends in "…" if long), which also stops it running off the card.
        label: isMobile ? '' : '${S.of(context).document_name}: ',
        value: documentName,
        lightMode: lightMode,
      ),
      SizedBox(height: 6.sp),
      if (!isMobile) ...[
        buildSubmittedDocumentDescription(
          context,
          documentDescription: documentDescription,
          isMobile: isMobile,
          lightMode: lightMode,
        ),
      ],
    ],
  );
}
