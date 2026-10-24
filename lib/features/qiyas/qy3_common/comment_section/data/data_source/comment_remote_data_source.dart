import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/app_services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/api_constant.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/comment_section/data/models/comment_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';

class CommentRemoteDataSource {
  Future<Either<FirebaseFailure, void>> submitCommit(
      CommentModel commentModel) async {
    return await FirebaseRepository.setDocumentWithId(
        collection: getBaseUrl(ApiConstant.kQiyascommentcollection),
        data: commentModel.toMap(),
        documentId: commentModel.commentId);
  }

  Future<Either<FirebaseFailure, String>> uploadMedia(String mediaPath) async {
    return await FirebaseRepository.uploadFile(
      filePath: mediaPath,
      collectionName: getBaseUrl(ApiConstant.kQiyascommentcollection),
      documentName: mediaPath.split('/').last, // Use the file name as ID
    );
  }

  Stream<Either<Failure, List<dynamic>>> getStreamOfComments(
      {required String criteriaNumber, required String evidenceNumber}) async* {
    yield* FirebaseRepository.getStreamOfDocumentsWithTwoFieldsSortedSorted(
      collectionPath: getBaseUrl(ApiConstant.kQiyascommentcollection),
      firstField: CommentModel.criteriaNumberField,
      firstValue: criteriaNumber,
      secondField: CommentModel.evidenceNumberField,
      secondValue: evidenceNumber,
      sortedBy: CommentModel.commentDateField,
    );
  }
}
