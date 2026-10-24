import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/comment_section/data/models/comment_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/comment_section/data/repository/comment_repository.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';

part 'qiyas_comment_state.dart';

class QiyasCommentCubit extends Cubit<QiyasCommentState> {
  QiyasCommentCubit() : super(QiyasCommentInitial());
  String criteriaNumber = '';
  String evidenceNumber = '';
  CommentRepository commentRepository = CommentRepository();
  List<CommentModel> comments = [];
  TextEditingController commentController = TextEditingController();
  File? selectedFile;
  StreamSubscription? _commentsSubscription;

  void getComments() {
    _commentsSubscription = commentRepository
        .getStreamOfComments(
      criteriaNumber: criteriaNumber,
      evidenceNumber: evidenceNumber,
    )
        .listen((either) {
      if (either.isRight()) {
        comments = List<CommentModel>.from(either.fold((_) => [], (r) => r));
        debugPrint('Comments loaded: ${comments.length}');
        emit(QiyasCommentLoaded());
      }
    });
  }

  void addComment() {
    debugPrint("Adding comment: ${commentController.text}");

    if (commentController.text.isEmpty && selectedFile == null) {
      return;
    }
    debugPrint("Adding comment: ${commentController.text}");

    commentRepository.addComment(
      commentText: (commentController.text.isEmpty || selectedFile != null)
          ? null
          : commentController.text,
      currentUserId:
          Get.find<MainCoreEmployeeController>().employeeEntity!.email!,
      criteriaNumber: criteriaNumber,
      evidenceNumber: evidenceNumber,
      mediaPath: selectedFile?.path,
    );
    selectedFile = null;
    commentController.clear();
  }

  void initCubit(
      {required String criteriaNumber, required String evidenceNumber}) {
    this.criteriaNumber = criteriaNumber;
    this.evidenceNumber = evidenceNumber;
    _commentsSubscription?.cancel();

    getComments();
  }

  @override
  Future<void> close() {
    _commentsSubscription?.cancel();
    return super.close();
  }

  Future<void> selectFile() async {
    await FilePicker.platform.pickFiles().then((result) {
      if (result != null) {
        if (result.files.isNotEmpty) {
          selectedFile = File(result.files.first.path!);
          debugPrint("Selected file: ${selectedFile!.path}");
        } else {
          selectedFile = null;
          debugPrint("No file selected");
        }
      } else {
        selectedFile = null;

        debugPrint("File selection was cancelled or failed");
      }
      addComment();
    }).catchError((error) {
      debugPrint("Error selecting file: $error");
    });
  }
}
