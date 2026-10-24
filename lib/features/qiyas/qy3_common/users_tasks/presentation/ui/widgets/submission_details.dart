import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/presentation/ui/widgets/submission_item_details.dart';

import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';

class SubmissionDetails extends StatelessWidget {
  const SubmissionDetails(
      {required this.isOwner,
      required this.isManager,
      required this.isChampion,
      required this.submissions,
      super.key});
  final bool isOwner;
  final bool isManager;
  final bool isChampion;
  final List<EvidenceSubmissionModel> submissions;
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SingleChildScrollView(
            child: Column(
      spacing: 15.sp,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < submissions.length; i++)
          SubmissionItemDetails(
            submission: submissions[i],
            isFirst: i == 0,
            isOwner: isOwner,
            isManager: isManager,
            isChampion: isChampion,
          ),
      ],
    )));
  }
}
