/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/comments_section/comments_list_view.dart
/// ************************* FILE INFO *************************** ///
/// File Name: comments_list_view.dart
/// Description: Contains all the comments on specific file in knowledge hub.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
/// Updated: Refactored to fetch user data from cubit cache
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_new_comment_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/controller/comments_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/ui/widgets/comments_section/comments_item.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';

Widget commentsListView({
  required List<CreateNewCommentModel> comments,
  required CommentsCubit cubit, // ✅ Required to access user data cache
}) {
  final employeeEntity = cubit.people.signedInEmployee!;
  khLog(employeeEntity.id ?? 'No id found', name: 'Employee Id');

  return ListView.builder(
    shrinkWrap: true,
    itemBuilder: (context, index) {
      final comment = comments[index];

      // ✅ Check if this is the current user's comment
      final isMyComment = comment.currentCreatedById == employeeEntity.id;

      return Padding(
        padding: EdgeInsets.only(bottom: 36.h),
        child: commentItem(
          context,
          comment: comment,
          isMyComment: isMyComment,
          cubit: cubit, // ✅ Pass cubit to access user data
        ),
      );
    },
    itemCount: comments.length,
  );
}
