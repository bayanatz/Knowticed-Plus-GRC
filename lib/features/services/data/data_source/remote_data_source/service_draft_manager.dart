/// Module: services / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: service_draft_manager.dart
/// Purpose: Coordinates draft persistence (FirebaseDraftRepository) with the
///          in-memory draft-tracking session (DraftSessionService). Extracted
///          from ServicesManagerCubit.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/features/services/data/data_source/local_data_source/draft_session_service.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/repository/firebase_draft_repository.dart';

class ServiceDraftManager {
  ServiceDraftManager({
    FirebaseDraftRepository? draftRepository,
    DraftSessionService? draftSession,
  })  : _draftRepository = draftRepository ?? FirebaseDraftRepository(),
        _draftSession = draftSession ?? DraftSessionService();

  final FirebaseDraftRepository _draftRepository;
  final DraftSessionService _draftSession;

  String? get currentDraftId => _draftSession.currentDraftId;
  int? get currentDraftPage => _draftSession.currentDraftPage;

  void setCurrentDraft(String? draftId, int page) =>
      _draftSession.setCurrentDraft(draftId, page);

  void clearCurrentDraft() => _draftSession.clear();

  /// Save draft to Firebase from any page.
  Future<String> saveDraftToFirebase({
    required ServicesHistoryModel model,
    required int currentPage,
  }) async {
    try {
      // ✅ CRITICAL: Check if we already have a draft ID from previous save
      // If not, check if model already has a draft ID in its currentId
      String? existingId = _draftSession.currentDraftId;

      if (existingId == null || existingId.isEmpty) {
        // Try to get from model's currentId if it's a draft
        if (model.currentId.startsWith('draft_')) {
          existingId = model.currentId;
          _draftSession.setCurrentDraft(existingId, currentPage); // Track it
        }
      }

      final draftId = await _draftRepository.saveDraft(
        model: model,
        currentPage: currentPage,
        existingDraftId: existingId, // ✅ Pass the existing ID
      );

      // Track this draft
      _draftSession.setCurrentDraft(draftId, currentPage);

      return draftId;
    } catch (e) {
      rethrow;
    }
  }

  /// Update existing draft page.
  Future<void> updateDraftPage({
    required String draftId,
    required int currentPage,
    required ServicesHistoryModel model,
  }) async {
    try {
      await _draftRepository.updateDraftPage(
        draftId: draftId,
        currentPage: currentPage,
        updatedModel: model,
      );

      _draftSession.setCurrentDraft(draftId, currentPage);
    } catch (e) {
      rethrow;
    }
  }

  /// Refresh drafts list after publishing - removes published draft from list.
  Future<void> refreshDraftsAfterPublish(
    String publishedDraftId,
    String userEmail,
  ) async {
    // Clear current draft tracking
    if (_draftSession.currentDraftId == publishedDraftId) {
      clearCurrentDraft();
    }

    // Reload drafts from Firebase - this will exclude the published one
    await getFirebaseDrafts(userEmail);
  }

  /// Get all user drafts from Firebase.
  Future<List<ServicesHistoryModel>> getFirebaseDrafts(String userEmail) async {
    try {
      if (userEmail.isEmpty) {
        return [];
      }

      // ✅ FIXED: Use the draft repository which queries CreateServices, not requestServices
      final drafts = await _draftRepository.getUserDrafts();

      return drafts;
    } catch (e) {
      // SVC-HOME-05: let the caller show an error instead of "no drafts".
      rethrow;
    }
  }

  /// Get draft with page info for resuming.
  Future<DraftWithPage?> getDraftWithPage(String draftId) async {
    DraftWithPage? result;
    try {
      result = await _draftRepository.getDraftWithPage(draftId);
    } catch (e) {
      // The card falls back to opening the model it already has; the
      // failure is logged by the repository.
      return null;
    }

    if (result != null) {
      // ✅ CRITICAL: Track this draft ID so subsequent saves update it
      _draftSession.setCurrentDraft(draftId, result.currentPage);
    }

    return result;
  }

  /// Delete draft when done.
  Future<void> deleteDraft(String draftId) async {
    await _draftRepository.deleteDraft(draftId);
    if (_draftSession.currentDraftId == draftId) {
      _draftSession.clear();
    }
  }

  /// Remove a draft whose contents have just been published as a live service.
  ///
  /// ✅ FIX (draft bug #2 — the finished service kept showing up under Drafts):
  /// completing the wizard writes a brand new `User…` document and left the
  /// original `draft_…` document untouched, still carrying
  /// `state: ['draft']`. The home page lists every document in that state, so
  /// the service appeared twice: once live, once as a stale draft.
  ///
  /// [ServiceDraftManager.deleteDraft] is not enough here — it only flips
  /// `draftMetadata.draftState` to 'completed', which hides the draft from
  /// [getFirebaseDrafts] but not from the home page's own `state == 'draft'`
  /// scan. The published content now lives in the new document, so the draft
  /// document is removed outright.
  Future<void> discardPublishedDraft(String draftId) async {
    if (draftId.isEmpty) return;

    await _draftRepository.permanentlyDeleteDraft(draftId);

    if (_draftSession.currentDraftId == draftId) {
      _draftSession.clear();
    }
  }
}
