/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/comments_section/build_comments_list.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_comments_list.dart
/// Description: Contains the comments created for each file in knowledge hub.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
/// Updated: Refactored to pass cubit for user data access
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_error_state.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/controller/comments_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/controller/comments_states.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/ui/widgets/comments_section/build_comments_text_field.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/ui/widgets/comments_section/comments_list_view.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

Widget buildCommentsSection(
  BuildContext context, {
  required bool showFullComments,
  required String knowledgeId,
}) {
  return Expanded(
    flex: showFullComments ? 3 : 1,
    child: Column(
      children: [
        Expanded(child: _buildCommentsList(context, knowledgeId)),
        SizedBox(height: 10.h),
        buildCommentInput(context, knowledgeId: knowledgeId),
      ],
    ),
  );
}

Widget _buildCommentsList(BuildContext context, String knowledgeId) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(8.r),
    ),
    padding: EdgeInsets.all(15.w),
    child: BlocBuilder<CommentsCubit, CommentsState>(
      builder: (context, state) {
        // Get cubit instance for accessing user cache
        final cubit = context.read<CommentsCubit>();

        if (state is CommentsLoading) {
          return Center(child: CircleProgressMaster.inline());
        } else if (state is CommentsLoadedSuccess) {
          if (state.comments.isEmpty) {
            return Center(
              child: Text(
                S.of(context).khNoCommentsBeFirst,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.colorGrey,
                ),
              ),
            );
          }
          // ✅ Pass cubit to access user data cache
          return commentsListView(comments: state.comments, cubit: cubit);
        } else if (state is CommentsLoadedFailure) {
          // KH-CREATE-24 pattern: translated message with Retry.
          return CustomErrorState(
            title: S.of(context).khCommentsLoadFailed,
            onRetry: () => cubit.fetchComments(knowledgeId),
          );
        }

        // For other states, show the current comments list
        if (cubit.commentsList.isEmpty) {
          return Center(
            child: Text(
              S.of(context).khNoCommentsBeFirst,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.colorGrey,
              ),
            ),
          );
        }
        // ✅ Pass cubit to access user data cache
        return commentsListView(comments: cubit.commentsList, cubit: cubit);
      },
    ),
  );
}
