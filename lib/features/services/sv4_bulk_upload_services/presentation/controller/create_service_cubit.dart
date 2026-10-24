/// Module: services / sv4_bulk_upload_services / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: create_service_cubit.dart
/// Purpose: Create service cubit — declares CreateServiceCubit,
///          DuplicateCheckResult.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'dart:io';

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/service_image_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/app_services/media_picker_service.dart';
import 'package:knowticed_plus/features/services/data/utils/shared.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/data/models/create_service_form_data.dart';
import 'package:knowticed_plus/features/services/data/repository/firebase_draft_repository.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/controller/create_service_state.dart';

import 'package:knowticed_plus/features/services/domain/enums/service_duration_unit.dart';

class CreateServiceCubit extends Cubit<CreateServiceState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final ServicesManagerCubit _servicesManagerCubit;
  // S4-006: pickers live in the shared service, not in the cubit.
  // C4: both are injected (the page passes the module's instances).
  final MediaPickerService _mediaPicker;
  // C2: Storage calls live in the data layer.
  final ServiceImageStorage _imageStorage;

  CreateServiceCubit(
    this._servicesManagerCubit, {
    required MediaPickerService mediaPicker,
    required ServiceImageStorage imageStorage,
  })  : _mediaPicker = mediaPicker,
        _imageStorage = imageStorage,
        super(const CreateServiceInitial());

  /// The picture the saved service points to (edit mode). SVC-CREATE-05: it
  /// is only deleted from storage after the edit is SAVED (in the
  /// repository), never when "remove picture" is pressed.
  String? _savedImageUrl;

  // ✅ CLEAN Initialize - NO SharedPreferences loading at all
  Future<void> initialize({
    ServicesHistoryModel? editingModel,
    String? docId,
  }) async {
    emit(const CreateServiceLoading());

    if (editingModel != null) {
      _savedImageUrl = editingModel.currentImageUrl.isEmpty
          ? null
          : editingModel.currentImageUrl;
      // Edit mode - load from model ONLY
      final formData = CreateServiceFormData(
        docId: docId,
        serviceNameEn: editingModel.currentServiceNameEnglish,
        serviceNameAr: editingModel.currentServiceNameArabic,
        descriptionEn: editingModel.currentServiceDescriptionEnglish,
        descriptionAr: editingModel.currentServiceDescriptionArabic,
        durationValue: editingModel.currentDurationOfServices,
        // Rule "Constants, no magic values": the form works with the unit
        // KEY; an old record's Arabic text is turned into it here.
        durationUnit: editingModel.currentSelectedDurationUnit.isEmpty
            ? ServiceDurationUnit.minute.key
            : ServiceDurationUnit.normalizeKey(
                editingModel.currentSelectedDurationUnit,
              ),
        imageUrl: editingModel.currentImageUrl.isEmpty
            ? null
            : editingModel.currentImageUrl,
        // ✅ FIX (draft bug #1): a draft document stores `status: ['draft']`,
        // which is a lifecycle marker, not an availability status. The old
        // `== "active"` test turned every resumed draft into isActive=false,
        // which was then persisted as an INACTIVE service when the wizard
        // finished. Only an explicit 'inactive' means inactive.
        isActive: _isActiveFromStatus(editingModel.currentStatus),
        isEditMode: true,
        state: editingModel.currentState,
        providers: editingModel.currentProviderServices,
      );

      _servicesManagerCubit.saveServiceDraft(editingModel);
      emit(CreateServiceLoaded(formData: formData));

      // ✅ FIX (bug report p11): seed the shared 'service_status' pref from the
      // service being edited.
      //
      // The save path (SlaNotificationCubit.updateAndSaveModel) reads this pref
      // and defaults to `true` when it is absent, but nothing wrote it on load
      // — only toggleStatus did. So opening a service for editing and saving
      // without touching the switch wrote back whatever the *previous* service
      // had left in the pref, and an inactive service silently flipped to
      // active. That is why the status switch appeared not to work.
      await SharedPrefsHelper.setBool('service_status', formData.isActive);

      // Load real status from Firestore if docId exists
      if (docId != null) {
        await _loadCurrentStatusFromFirestore(docId);
      }
    } else {
      // ✅ Create mode - ALWAYS START WITH CLEAN EMPTY FORM
      emit(const CreateServiceLoaded(formData: CreateServiceFormData()));
      // ✅ FIX (bug report p11): reset the shared pref too, so a new service
      // starts from the form's default (active) instead of inheriting the
      // status left behind by the last service that was edited.
      await SharedPrefsHelper.setBool(
        'service_status',
        const CreateServiceFormData().isActive,
      );

      // ✅ FIX 26/8/2026 — "saving a draft removed the previous draft".
      //
      // Neither of these two was ever cleared, so a brand-new service inherited
      // the LAST service's identity and then wrote over it:
      //
      //   • `current_service_docId` is how the wizard keeps ONE `services/`
      //     document across its four pages —
      //     `SlaNotificationCubit._ensureDraftDoc` restores it from prefs
      //     rather than minting a new id. Right within one run, wrong at the
      //     start of the next: service B reused service A's document.
      //   • `ServiceDraftManager`'s in-memory draft id is what makes a repeated
      //     Save For Later UPDATE the same draft instead of piling up copies.
      //     Also right within one run — and it meant service B's first save
      //     found service A's draft id still sitting there and updated THAT
      //     document. Draft A was never deleted; it was overwritten with B's
      //     data, which is why the list never grew.
      //
      // Clearing both here, and only here, keeps each behaviour where it
      // belongs: inside one service, saves keep landing on the same pair of
      // documents; a new service starts from neither.
      //
      // Deliberately NOT in the edit branch above — resuming a draft has to go
      // on writing to the draft it came from.
      await SharedPrefsHelper.remove('current_service_docId');
      _servicesManagerCubit.clearCurrentDraft();
    }
  }

  /// True unless the status is an explicit 'inactive'.
  ///
  /// Drafts carry `status: 'draft'` (a lifecycle marker) and brand-new
  /// services can carry an empty status; neither means "inactive", so both
  /// fall back to the form default (active).
  static bool _isActiveFromStatus(String? rawStatus) =>
      (rawStatus ?? '').trim().toLowerCase() != 'inactive';

  Future<void> _loadCurrentStatusFromFirestore(String docId) async {
    // S4-004: status read goes through the repository, not Firestore directly.
    // B7 FIX: on a read failure keep the value already seeded into the form
    // instead of forcing 'active' (which silently corrupted inactive services).
    String? status;
    try {
      status = await _servicesManagerCubit.repository.getServiceStatus(docId);
    } catch (_) {
      return; // preserve the seeded isActive value
    }

    // No status recorded on the doc → keep the seeded value rather than defaulting.
    if (status == null) return;

    // ✅ FIX (draft bug #1): a draft doc stores status 'draft'. Reading it back
    // here used to flip isActive to false and overwrite the pref, so finishing
    // a draft always produced an INACTIVE service. Only real availability
    // values are authoritative; anything else keeps the seeded value.
    final normalized = status.trim().toLowerCase();
    if (normalized != 'active' && normalized != 'inactive') return;

    if (isClosed) return;

    if (state is CreateServiceLoaded) {
      final currentState = state as CreateServiceLoaded;
      final isActive = normalized == 'active';
      emit(
        currentState.copyWith(
          formData: currentState.formData.copyWith(isActive: isActive),
        ),
      );
      // ✅ FIX (bug report p11): keep the pref in step with the authoritative
      // Firestore value, otherwise the save path can still write a stale one.
      await SharedPrefsHelper.setBool('service_status', isActive);
    }
  }

  String _extractEmail() {
    try {
      final controller = AppControllers.employee;
      final email = controller.employeeEntity?.email ?? '';

      if (email.isNotEmpty) {
        return email;
      }

      return '';
    } catch (e) {
      return '';
    }
  }

  // Form field updates
  void updateServiceNameEn(String value) {
    _updateFormData((data) => data.copyWith(serviceNameEn: value));
  }

  void updateServiceNameAr(String value) {
    _updateFormData((data) => data.copyWith(serviceNameAr: value));
  }

  void updateDescriptionEn(String value) {
    _updateFormData((data) => data.copyWith(descriptionEn: value));
  }

  void updateDescriptionAr(String value) {
    _updateFormData((data) => data.copyWith(descriptionAr: value));
  }

  void updateDurationValue(String value) {
    _updateFormData((data) => data.copyWith(durationValue: value));
  }

  void updateDurationUnit(String value) {
    _updateFormData((data) => data.copyWith(durationUnit: value));
  }

  void _updateFormData(
    CreateServiceFormData Function(CreateServiceFormData) updater,
  ) {
    if (state is CreateServiceLoaded) {
      final currentState = state as CreateServiceLoaded;
      emit(currentState.copyWith(formData: updater(currentState.formData)));
    }
  }

  // Image handling
  Future<void> pickImage() async {
    if (state is! CreateServiceLoaded) return;

    final currentState = state as CreateServiceLoaded;
    if (currentState.isUploadingImage) return;

    try {
      final picked = await _mediaPicker.pickGalleryImage();

      if (picked != null) {
        // ✅ FIX 26/8/2026 — `selectedImage: null` / `webImage: null` were
        // no-ops (see `CreateServiceLoaded.copyWith`), so the clears below
        // never happened. `clearImageUrl` is new here rather than a repair:
        // picking a SECOND image left the previous upload's `imageUrl` in
        // place, and `ImageUploadWidget._getImageProvider` prefers it over the
        // freshly picked file — so the avatar went on showing the old picture
        // through the whole upload and only changed once the new URL landed.
        if (kIsWeb) {
          emit(
            currentState.copyWith(
              webImage: picked.bytes,
              clearSelectedImage: true,
              formData: currentState.formData.copyWith(clearImageUrl: true),
            ),
          );
        } else if (picked.path != null) {
          emit(
            currentState.copyWith(
              selectedImage: File(picked.path!),
              clearWebImage: true,
              formData: currentState.formData.copyWith(clearImageUrl: true),
            ),
          );
        }
        await _uploadImageToFirebase();
      }
    } catch (e) {
      emit(CreateServiceError(CreateServiceIssue.imagePickFailed, '$e'));
      if (state is CreateServiceLoaded) emit(currentState);
    }
  }

  /// Accepts a file the UI already picked and validated, then runs the same
  /// upload [pickImage] does.
  ///
  /// Added so `ImageUploadWidget` can hand over the file that
  /// `CustomImagePicker` (core/custom/46) produced. That widget owns the
  /// picking, the format whitelist and the decode check; the cubit keeps
  /// owning the state transition and the Firebase upload. [pickImage] stays
  /// for any call site that still wants the cubit to open the gallery itself.
  Future<void> setPickedImage(File file) async {
    if (state is! CreateServiceLoaded) return;

    final currentState = state as CreateServiceLoaded;
    if (currentState.isUploadingImage) return;

    try {
      // Same clears as pickImage: a second pick must drop the previous
      // upload's URL, or _getImageProvider keeps preferring the old picture.
      emit(
        currentState.copyWith(
          selectedImage: file,
          clearWebImage: true,
          formData: currentState.formData.copyWith(clearImageUrl: true),
        ),
      );
      await _uploadImageToFirebase();
    } catch (e) {
      emit(CreateServiceError(CreateServiceIssue.imagePickFailed, '$e'));
      if (state is CreateServiceLoaded) emit(currentState);
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (state is! CreateServiceLoaded) return;
    final currentState = state as CreateServiceLoaded;

    if ((currentState.selectedImage == null && currentState.webImage == null)) {
      return;
    }

    emit(currentState.copyWith(isUploadingImage: true));

    try {
      final downloadURL = await _imageStorage.upload(
        bytes: currentState.webImage,
        file: currentState.selectedImage,
      );

      // ✅ FIX 26/8/2026 — THE FORM USED TO DIE HERE.
      //
      // This method ended on `emit(CreateServiceImageUploaded(...))` and never
      // came back, so a SUCCESSFUL upload left the cubit resting in a
      // transient state forever. Every other transient state in this file is
      // careful to restore the loaded one — `CreateServiceNavigateToProviders`
      // does it two lines later, and all three error paths do it too. This one
      // was the exception, and three separate bugs came out of it:
      //
      //  1. THE IMAGE DISAPPEARED. `ImageUploadWidget.buildWhen` returns true
      //     for `CreateServiceImageUploaded`, so it rebuilt — and its builder
      //     opens with `if (state is! CreateServiceLoaded) return
      //     SizedBox.shrink()`. The avatar, the camera badge and the delete
      //     button were all replaced by an empty box the moment the upload
      //     succeeded. The one thing the user had just proved worked was the
      //     one thing that vanished.
      //
      //  2. EVERY FIELD WENT DEAD. `_updateFormData` is guarded by
      //     `if (state is CreateServiceLoaded)`. With the cubit parked on
      //     `CreateServiceImageUploaded` that guard was false, so
      //     `updateDurationUnit`, both names, both descriptions,
      //     `updateDurationValue` and `toggleStatus` all silently emitted
      //     nothing. The duration dropdown is simply where it shows first:
      //     `CustomDropdown` is fully controlled — its `_selectedItem` is
      //     derived from `widget.value` and it keeps no selection of its own —
      //     so with no new state to rebuild from, every choice snapped back to
      //     the old one. Nothing was wrong with the dropdown.
      //
      //  3. THE FORM COULD NOT BE SUBMITTED. `submitForm()` opens with
      //     `if (state is! CreateServiceLoaded) return;` and returned straight
      //     away, so after uploading an image the Next button did nothing at
      //     all.
      //
      // The upload state is now built once and emitted on BOTH sides of the
      // notification: the announcement still reaches the listener in
      // `create_new_services.dart` that shows the success dialog, and the
      // cubit lands back where the form can carry on.
      final CreateServiceLoaded uploaded = currentState.copyWith(
        isUploadingImage: false,
        formData: currentState.formData.copyWith(imageUrl: downloadURL),
      );

      emit(uploaded);
      emit(CreateServiceImageUploaded(downloadURL));
      emit(uploaded);
    } catch (e) {
      emit(currentState.copyWith(isUploadingImage: false));
      emit(CreateServiceError(CreateServiceIssue.imageUploadFailed, '$e'));
      emit(currentState.copyWith(isUploadingImage: false));
    }
  }

  /// Removes the picture and reports whether it actually went.
  ///
  /// Returns `false` when there is no loaded form to act on, so the caller's
  /// confirm → success flow does not claim a deletion that never happened.
  /// A Storage delete that fails is still a success from here: the object may
  /// already be gone, and the form must not keep pointing at a URL the user
  /// asked to drop.
  Future<bool> removeImage() async {
    if (state is! CreateServiceLoaded) return false;
    final currentState = state as CreateServiceLoaded;

    // SVC-CREATE-05: only clear the picture in the form. The live service's
    // picture is deleted by the repository after the edit is saved; deleting
    // it here left the service pointing at a missing file when the user went
    // back without saving. A picture uploaded in THIS session (not used by
    // any saved service) can still be removed right away.
    final url = currentState.formData.imageUrl;
    if (url != null && url != _savedImageUrl) {
      await _imageStorage.deleteQuietly(url);
    }

    // ✅ FIX 26/8/2026 — all three of these were no-ops. `??` treats null as
    // "not supplied", so every one of them fell through to the existing value
    // and this method deleted the file from Storage without changing a single
    // thing on screen: the avatar kept rendering, the delete button kept
    // showing, and the URL it pointed at was now a 404.
    emit(
      currentState.copyWith(
        clearSelectedImage: true,
        clearWebImage: true,
        formData: currentState.formData.copyWith(clearImageUrl: true),
      ),
    );

    return true;
  }

  void resetToDuplicateState() {
    if (state is CreateServiceDuplicateName) {
      final duplicateState = state as CreateServiceDuplicateName;
      if (duplicateState.formData != null) {
        emit(CreateServiceLoaded(formData: duplicateState.formData!));
      }
    }
  }

  // ✅ CLEAN Submit - NO SharedPreferences saving
  Future<void> submitForm() async {
    if (state is! CreateServiceLoaded) return;
    final currentState = state as CreateServiceLoaded;

    emit(currentState.copyWith(submitted: true));

    if (!currentState.formData.isFormValid) {
      return;
    }

    if (currentState.isUploadingImage) {
      emit(const CreateServiceError(CreateServiceIssue.imageUploadInProgress));
      // ✅ Restore loaded state after error
      emit(currentState.copyWith(submitted: true));
      return;
    }

    try {
      final String userEmail = _extractEmail();

      final duplicateCheckResult = await _checkForDuplicates(
        serviceNameEn: currentState.formData.serviceNameEn.trim(),
        serviceNameAr: currentState.formData.serviceNameAr.trim(),
        userEmail: userEmail,
        currentDocId: currentState.formData.docId,
        isEditMode: currentState.formData.isEditMode,
      );

      if (duplicateCheckResult.isDuplicate) {
        emit(
          CreateServiceDuplicateName(
            duplicateField: duplicateCheckResult.duplicateField,
            duplicateValue: duplicateCheckResult.duplicateValue,
            formData: currentState.formData,
          ),
        );
        return; // ← resetToDuplicateState() handles restoring from here
      }

      await SharedPrefsHelper.setBool(
        'service_status',
        currentState.formData.isActive,
      );

      final providersToUse = currentState.formData.providers;

      final completeModel = ServicesHistoryFactory.createNew(
        id: currentState.formData.docId ?? '',
        state: currentState.formData.state,
        status: currentState.formData.isActive ? "active" : "inactive",
        serviceNameEnglish: currentState.formData.serviceNameEn,
        serviceNameArabic: currentState.formData.serviceNameAr,
        serviceDescriptionEnglish: currentState.formData.descriptionEn,
        serviceDescriptionArabic: currentState.formData.descriptionAr,
        durationOfServices: currentState.formData.durationValue,
        selectedDurationUnit: currentState.formData.durationUnit,
        imageUrl: currentState.formData.imageUrl ?? '',
        providerServices: providersToUse,
      );

      await _servicesManagerCubit.saveServiceDraft(completeModel);
      _servicesManagerCubit.setDocService(completeModel);

      // ✅ FIX: Emit nav state then immediately restore loaded state
      emit(
        CreateServiceNavigateToProviders(
          docId: currentState.formData.docId,
          formData: currentState.formData.copyWith(providers: providersToUse),
        ),
      );

      // ✅ This is the key fix — when user presses back from provider page,
      // the cubit is already in loaded state, button works correctly
      emit(
        currentState.copyWith(
          submitted: false, // ✅ Reset submitted so validation UI clears
        ),
      );
    } catch (e) {
      emit(CreateServiceError(CreateServiceIssue.unexpected, '$e'));
      emit(currentState); // ✅ Already existed, keep it
    }
  }

  void toggleStatus(bool value) {
    _updateFormData((data) => data.copyWith(isActive: value));
    // ✅ Persist immediately so draft saves mid-flow also carry correct status
    SharedPrefsHelper.setBool('service_status', value);
  }

  Future<DuplicateCheckResult> _checkForDuplicates({
    required String serviceNameEn,
    required String serviceNameAr,
    required String userEmail,
    String? currentDocId,
    required bool isEditMode,
  }) async {
    // S4-004: read services via the repository instead of Firestore directly.
    // SVC-CREATE-07: check the name against ALL of the company's services,
    // not only the ones the signed-in user created.
    final services =
        await _servicesManagerCubit.repository.getAllRequestServices();

    for (final model in services) {
      if (model.isDeleted) continue;
      if (isEditMode && model.currentId == currentDocId) continue;
      // SVC-CREATE-12: someone else's unfinished draft does not own a name.
      if (model.isDraftState &&
          model.currentEmailRequester.trim().toLowerCase() !=
              userEmail.trim().toLowerCase()) {
        continue;
      }

      final existingNameEn = model.currentServiceNameEnglish;
      if (existingNameEn.trim().toLowerCase() == serviceNameEn.toLowerCase()) {
        return DuplicateCheckResult(
          isDuplicate: true,
          duplicateField: 'Service_Name_English',
          duplicateValue: existingNameEn,
        );
      }

      // Check Arabic Name (only if not empty)
      if (serviceNameAr.isNotEmpty) {
        final existingNameAr = model.currentServiceNameArabic;
        if (existingNameAr.trim() == serviceNameAr.trim()) {
          return DuplicateCheckResult(
            isDuplicate: true,
            duplicateField: 'Service_Name_Arabic',
            duplicateValue: existingNameAr,
          );
        }
      }
    }

    return DuplicateCheckResult(isDuplicate: false);
  }

  /// 🔥 Save draft from page 1
  Future<void> saveDraftFromPage1() async {
    if (state is! CreateServiceLoaded) return;
    final currentState = state as CreateServiceLoaded;

    try {
      final model = ServicesHistoryFactory.createNew(
        id: currentState.formData.docId ?? '',
        state: "draft",
        // ✅ FIX (draft bug #1): carry the real availability so the draft can
        // be published with it. The repository still stores 'draft' in the
        // document's own status field; this value is kept in draftMetadata.
        status: currentState.formData.isActive ? "active" : "inactive",
        serviceNameEnglish: currentState.formData.serviceNameEn,
        serviceNameArabic: currentState.formData.serviceNameAr,
        serviceDescriptionEnglish: currentState.formData.descriptionEn,
        serviceDescriptionArabic: currentState.formData.descriptionAr,
        durationOfServices: currentState.formData.durationValue,
        selectedDurationUnit: currentState.formData.durationUnit,
        imageUrl: currentState.formData.imageUrl ?? '',
        providerServices: [],
      );

      final draftId = await _servicesManagerCubit.saveDraftToFirebase(
        model: model,
        currentPage: FirebaseDraftRepository.pageCreateService,
      );

      emit(CreateServiceDraftSaved(draftId: draftId));
    } catch (e) {
      emit(CreateServiceError(CreateServiceIssue.draftSaveFailed, '$e'));
    }
  }
}

class DuplicateCheckResult {
  final bool isDuplicate;
  final String duplicateField;
  final String duplicateValue;

  const DuplicateCheckResult({
    required this.isDuplicate,
    this.duplicateField = '',
    this.duplicateValue = '',
  });
}
