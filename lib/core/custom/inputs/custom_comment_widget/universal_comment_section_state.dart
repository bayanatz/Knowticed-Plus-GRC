/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: universal_comment_section_state.dart
/// Description: `_UniversalCommentSectionState` widget — split out of `36-custom_comment_widget.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_comment_widget.dart';

// Split from 36-custom_comment_widget.dart to keep every file under 700 lines.

class _UniversalCommentSectionState extends StatefulWidget {
  final String collectionPath;
  final Map<String, dynamic> filterFields;
  final String sortByField;
  final String currentUserId;
  final CommentSectionStyle style;
  final Function(Map<String, dynamic>)? onCommentAdded;
  final bool enableFileAttachment;
  final bool isExpandable;
  final double? fixedHeight;
  final double? collapsedHeight;
  final Function(bool isExpanded)? onExpandChanged;
  final Future<void> Function({
    required String currentUserId,
    String? commentText,
    String? mediaPath,
  })? customAddComment;

  const _UniversalCommentSectionState({
    required this.collectionPath,
    required this.filterFields,
    required this.sortByField,
    required this.currentUserId,
    required this.style,
    this.onCommentAdded,
    required this.enableFileAttachment,
    required this.isExpandable,
    this.fixedHeight,
    this.collapsedHeight,
    this.onExpandChanged,
    this.customAddComment,
  });

  @override
  State<_UniversalCommentSectionState> createState() =>
      _UniversalCommentSectionStateImpl();
}
