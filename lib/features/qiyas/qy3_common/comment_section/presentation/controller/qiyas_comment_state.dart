part of 'qiyas_comment_cubit.dart';

@immutable
sealed class QiyasCommentState {}

final class QiyasCommentInitial extends QiyasCommentState {}

final class QiyasCommentLoaded extends QiyasCommentState {}
