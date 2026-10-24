/// Module: qiyas / qy3_common / comment_section
///
///*************************** FILE INFO ****************************///
/// File Name: comment_section.dart
/// Purpose: Declares `CommentSection` — the discussion of one Qiyas
///          criteria + evidence.
/// Author: Knowticed Plus team
///
/// Updated: 22/10/2026 - Moataz: "Settings → Requests, Inquiries And
/// Comments is the perfect model — apply it everywhere." The Qiyas-only box
/// (its own bubbles, text field and full-screen overlay) is gone; this is the
/// shared `UniversalCommentSection`. Qiyas comments already use the same
/// fields (`Comment_Text`, `Commenter_Id`, `Comment_Date`, `Comment_Link`,
/// `File_Name`, `File_Size`) in `ApiConstant.kQiyascommentcollection`,
/// filtered by criteria + evidence, so every existing comment still shows.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_comment_widget.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/api_constant.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/comment_section/data/models/comment_model.dart';

class CommentSection extends StatefulWidget {
  const CommentSection({
    required this.criteriaNumber,
    this.isExpanded = true,
    required this.evidenceNumber,
    super.key,
  });

  /// true = fills the rest of the page's column (the callers place it in
  /// one); false = the box at its usual height.
  final bool isExpanded;
  final String criteriaNumber;
  final String evidenceNumber;

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  String get _currentUserEmail {
    try {
      return Get.find<MainCoreEmployeeController>().employeeEntity?.email ?? '';
    } catch (_) {
      return '';
    }
  }

  Widget _box({double? height}) => UniversalCommentSection(
        collectionPath: getBaseUrl(ApiConstant.kQiyascommentcollection),
        filterFields: <String, dynamic>{
          CommentModel.criteriaNumberField: widget.criteriaNumber,
          CommentModel.evidenceNumberField: widget.evidenceNumber,
        },
        currentUserId: _currentUserEmail,
        // Same sizes as Settings → Request Details, unless the page gives
        // the box a fixed space to fill.
        collapsedHeight: height ?? (kpIsPhoneLayout(context) ? 320.h : 400.h),
        fixedHeight: height,
        fitBelowPageTopWhenExpanded: height == null,
      );

  @override
  Widget build(BuildContext context) {
    if (!widget.isExpanded) return _box();
    // The old box was an `Expanded` here; the shared one fills the same
    // space — minus its title row.
    return Expanded(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) => _box(
          height: (c.maxHeight - 40.sp - 5.h).clamp(200.0, double.infinity),
        ),
      ),
    );
  }
}
