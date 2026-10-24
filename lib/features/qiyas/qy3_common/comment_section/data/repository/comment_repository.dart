import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/comment_section/data/models/comment_model.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/comment_section/data/data_source/comment_remote_data_source.dart';

class CommentRepository {
  CommentRemoteDataSource commentRemoteDataSource = CommentRemoteDataSource();

  Future<Either<FirebaseFailure, void>> addComment(
      {required String criteriaNumber,
      required String evidenceNumber,
      required String currentUserId,
      String? commentText,
      String? mediaPath}) async {
    debugPrint(" Adding comment: $commentText, mediaPath: $mediaPath");
    String? fileName =
        mediaPath?.split('/').last; // Extract file name from path
    String? fileSize = mediaPath != null
        ? '${(mediaPath.length / (1024 * 1024)).toStringAsFixed(2)} MB' // Convert to MB
        : null; // Get file size if mediaPath is provided
    if (mediaPath != null) {
      await commentRemoteDataSource.uploadMedia(mediaPath);
      /* if (result.isLeft()) return result;
      mediaPath = result.fold((_) => '', (r) => r);*/
    }
    CommentModel commentModel = CommentModel(
      criteriaNumber: criteriaNumber,
      evidenceNumber: evidenceNumber,
      commentText: commentText,
      commentId: '${currentUserId}_${Timestamp.now().microsecondsSinceEpoch}',
      commentDate: Timestamp.now(),
      commentLink: mediaPath,
      fileName: fileName,
      fileSize: fileSize,
      // Extract file name from path
      commenterId: currentUserId,
    );
    return await commentRemoteDataSource.submitCommit(commentModel);
  }

  Stream<Either<Failure, List<dynamic>>> getStreamOfComments(
      {required String criteriaNumber, required String evidenceNumber}) async* {
    Stream<Either<Failure, List<dynamic>>> stream =
        commentRemoteDataSource.getStreamOfComments(
      criteriaNumber: criteriaNumber,
      evidenceNumber: evidenceNumber,
    );
    await for (final comment in stream) {
      if (comment.isLeft()) {
        yield comment;
        return;
      }
      List<Map<String, dynamic>> commentsData =
          List<Map<String, dynamic>>.from(comment.fold((_) => [], (r) => r));
      List<CommentModel> comments =
          commentsData.map((e) => CommentModel.fromMap(e)).toList();
      yield Right(comments);
    }
  }
}
