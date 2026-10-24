/// Module: knowledge_hub/kh5_submission_details/presentation/controller
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_removal_cubit.dart
/// Description: Removes a published document with a justification and tells
///              its author (and the author's supervisor) — the work the
///              "Reason of removing" dialog used to do itself.
/// Author: Amr Mesbah
/// Created at: 11/10/2026
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/domain/base_repository/submissions_base_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';

/// Why a removal failed — the widget turns it into translated text.
enum KnowledgeRemovalError { notFound, failed }

sealed class KnowledgeRemovalState {
  const KnowledgeRemovalState();
}

class KnowledgeRemovalIdle extends KnowledgeRemovalState {
  const KnowledgeRemovalIdle();
}

class KnowledgeRemovalLoading extends KnowledgeRemovalState {
  const KnowledgeRemovalLoading();
}

class KnowledgeRemovalSuccess extends KnowledgeRemovalState {
  const KnowledgeRemovalSuccess();
}

class KnowledgeRemovalFailure extends KnowledgeRemovalState {
  const KnowledgeRemovalFailure(this.error);
  final KnowledgeRemovalError error;
}

class KnowledgeRemovalCubit extends Cubit<KnowledgeRemovalState> {
  KnowledgeRemovalCubit(this._repository) : super(const KnowledgeRemovalIdle());

  final SubmissionsBaseRepository _repository;

  @override
  void emit(KnowledgeRemovalState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Marks [documentId] removed with [justification], then sends the
  /// "document withdrawn" notification to the author and their supervisor.
  /// A failed notification does not undo the removal.
  Future<void> remove({
    required String documentId,
    required String currentUserEmail,
    required String justification,
  }) async {
    if (justification.trim().isEmpty) return;
    emit(const KnowledgeRemovalLoading());
    try {
      final result = await _repository.removeKnowledgeWithReason(
        documentId: documentId,
        currentUserEmail: currentUserEmail,
        justification: justification.trim(),
      );
      if (result == null) {
        emit(const KnowledgeRemovalFailure(KnowledgeRemovalError.notFound));
        return;
      }
      await _notifyAuthorAndSupervisor(
        documentId: documentId,
        senderEmail: currentUserEmail,
        creatorEmail: result.creatorEmail,
        documentNameEn: result.documentNameEnglish,
        documentNameAr: result.documentNameArabic,
      );
      emit(const KnowledgeRemovalSuccess());
    } catch (e) {
      khLog('Knowledge removal failed: $e', name: 'KnowledgeRemoval');
      emit(const KnowledgeRemovalFailure(KnowledgeRemovalError.failed));
    }
  }

  Future<void> _notifyAuthorAndSupervisor({
    required String documentId,
    required String senderEmail,
    required String creatorEmail,
    required String documentNameEn,
    required String documentNameAr,
  }) async {
    if (creatorEmail.isEmpty) return;
    final bool isArabic = KhLocale.isArabicNow;
    try {
      await _repository.notifyOfRemoval(
        documentId: documentId,
        senderEmail: senderEmail,
        receiverEmail: creatorEmail,
        documentNameEn: documentNameEn,
        documentNameAr: documentNameAr,
        isArabic: isArabic,
      );
      final creator = await _repository.fetchUserDataByEmail(creatorEmail);
      final String supervisor = creator?.currentemployeeSupervisor ?? '';
      if (supervisor.isNotEmpty) {
        await _repository.notifyOfRemoval(
          documentId: documentId,
          senderEmail: senderEmail,
          receiverEmail: supervisor,
          documentNameEn: documentNameEn,
          documentNameAr: documentNameAr,
          isArabic: isArabic,
        );
      }
    } catch (e) {
      khLog('Removal notification failed: $e', name: 'KnowledgeRemoval');
    }
  }
}
