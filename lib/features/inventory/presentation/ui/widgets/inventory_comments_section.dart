/// Module: inventory
///
///*************************** FILE INFO ****************************///
/// File Name: inventory_comments_section.dart
/// Purpose: Declares `InventoryCommentsSection` — "Inquiries And Comments"
///          on the Inventory details pages.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Moataz 22/10/2026: "Settings → Requests, Inquiries And Comments is the
/// perfect model — apply it everywhere." Replaces the `ChatCommentSection`
/// each details page carried its own copy of. That copy was always opened
/// with an empty service / model id, so it read `Demo//RequestServices//…`
/// and never showed a comment.
///
/// The details pages take no record id yet, so a thread is kept per page
/// ([screen]) in `Modules/inventory/Comments`. When a page gets its record's
/// id, pass it as [recordId] and the thread becomes that record's.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_comment_widget.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/inventory/helpers/inventory_paths.dart';

class InventoryCommentsSection extends StatelessWidget {
  const InventoryCommentsSection({
    super.key,
    required this.screen,
    this.recordId = '',
  });

  /// Which details page this is (one thread per page until [recordId]).
  final String screen;

  /// The product / request the thread belongs to; '' = not wired yet.
  final String recordId;

  @override
  Widget build(BuildContext context) {
    return UniversalCommentSection(
      collectionPath: getBaseUrl('Modules/inventory/Comments'),
      filterFields: <String, dynamic>{
        'Screen': screen,
        'Record_Id': recordId,
      },
      currentUserId: InventoryPaths.userEmail,
      // Same sizes as Settings → Request Details.
      collapsedHeight: kpIsPhoneLayout(context) ? 320.h : 400.h,
      fitBelowPageTopWhenExpanded: true,
    );
  }
}
