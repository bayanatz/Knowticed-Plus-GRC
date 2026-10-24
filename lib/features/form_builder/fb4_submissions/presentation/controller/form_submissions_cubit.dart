/// Module: form_builder_module/f5_submissions
///
///*************************** FILE INFO ****************************///
/// File Name: form_submissions_cubit.dart
/// Description: `FormSubmissionsCubit`, the state of a form being filled
///              out or read. No BuildContext, dialogs, navigation or
///              controllers here: the page owns the field controllers and
///              shows the dialogs; this cubit validates, submits and emits.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/form_builder/helpers/form_builder_log_service.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/form_answer_format.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/form_demo_answers.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/page_controller_model.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/use_cases/send_response_use_case.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/presentation/controller/submission_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';

/// State of a form being filled out or read.
class FormSubmissionsCubit extends Cubit<SubmissionsState> {
  /// Saves the response (injected).
  final SendResponseUseCase sendResponseUseCase;

  /// Email of the signed-in person (injected, not looked up here).
  final String Function() currentUserEmail;

  FormSubmissionsCubit({
    required this.sendResponseUseCase,
    required this.currentUserEmail,
  }) : super(SubmissionsInitial());

  /// Method Name: [init]
  ///
  /// Purpose: opens [model]. A submitted form opens read-only.
  /// FB-RESULT-08: an answer can be edited only when the form allows editing
  /// AND the user's access window is still open.
  ///
  /// Parameters:
  /// - [model]: the form.
  void init({required FormEntity model}) {
    final bool submitted = model.status == FormStatus.submissions;
    emit(SubmissionsLoaded(
      isSubmitted: submitted,
      isReadOnly: submitted,
      canEdit: model.isEdit && model.isHasAccess,
    ));
  }

  SubmissionsLoaded? get _loaded =>
      state is SubmissionsLoaded ? state as SubmissionsLoaded : null;

  /// Method Name: [answersChanged]
  ///
  /// Purpose: an answer changed on a controller the page owns; rebuilds.
  void answersChanged() {
    final SubmissionsLoaded? current = _loaded;
    if (current == null || isClosed) return;
    emit(current.copyWith(revision: current.revision + 1));
  }

  /// Method Name: [prepareSubmit]
  ///
  /// Purpose: marks the form as submitted (shows field errors) and runs the
  /// checks that are not part of the Form widget.
  ///
  /// Parameters:
  /// - [pages]: the page's field controllers.
  ///
  /// Returns: true when those checks pass; false while a submission is
  /// already in flight (double-tap guard).
  bool prepareSubmit(List<PageControllerModel> pages) {
    final SubmissionsLoaded? current = _loaded;
    if (current == null || current.isSubmitting) return false;
    emit(current.copyWith(isSubmitted: true, revision: current.revision + 1));
    for (final page in pages) {
      for (final row in page.rows) {
        for (final controller in row.controllers) {
          if (controller.getIsValidated() == false) return false;
        }
      }
    }
    return true;
  }

  /// Method Name: [submit]
  ///
  /// Purpose: saves the answers. The page shows the confirm and success
  /// dialogs; a failure is emitted as [SubmissionsLoaded.errorMessage] (a
  /// translated message, never the raw error, FB-RESULT-08).
  ///
  /// Parameters:
  /// - [model]: the form.
  /// - [pages]: the page's field controllers holding the answers.
  /// - [isEdit]: true when an existing answer is re-sent.
  ///
  /// Returns: true when the response was saved.
  Future<bool> submit({
    required FormEntity model,
    required List<PageControllerModel> pages,
    required bool isEdit,
  }) async {
    final SubmissionsLoaded? current = _loaded;
    if (current == null || current.isSubmitting) return false;

    // FB-RESULT-08: an edit is not saved after the form has closed.
    if (isEdit && !current.canEdit) {
      _emitError(S.current.formEditingClosed);
      return false;
    }

    final FormEntity answered = _answeredForm(model, pages);
    emit(current.copyWith(isSubmitting: true));

    try {
      final result = await sendResponseUseCase.execute(
        model: answered,
        isEdit: isEdit,
        responderEmail: currentUserEmail(),
      );
      return await result.fold(
        (failure) {
          _emitError(failure.message);
          return false;
        },
        (_) {
          FormBuilderLogService.log(isEdit
              ? FormBuilderLogService.actionUpdateSubmittedResponse
              : FormBuilderLogService.actionSubmitFormResponse);
          return true;
        },
      );
    } catch (_) {
      _emitError(S.current.submitFailedTryAgain);
      return false;
    }
  }

  /// Method Name: [submitFinished]
  ///
  /// Purpose: unlocks the form after the success dialog closed.
  void submitFinished() {
    final SubmissionsLoaded? current = _loaded;
    if (current == null || isClosed) return;
    emit(current.copyWith(isSubmitting: false));
  }

  void _emitError(String message) {
    final SubmissionsLoaded? current = _loaded;
    if (current == null || isClosed) return;
    emit(current.copyWith(
      isSubmitting: false,
      errorMessage: message,
      errorId: current.errorId + 1,
    ));
  }

  /// A copy of [oldModel] holding the answers of [pages].
  FormEntity _answeredForm(
      FormEntity oldModel, List<PageControllerModel> pages) {
    final FormEntity formModel = FormEntity(
      personEntity: oldModel.personEntity,
      pages: [],
      id: oldModel.id,
      status: oldModel.status,
      formHeadModel: oldModel.formHeadModel,
      createDate: oldModel.createDate,
      requestedBy: oldModel.requestedBy,
    );
    for (final page in pages) {
      formModel.pages.add(page.toModel(isSetData: true));
    }
    return formModel;
  }

  /// Method Name: [allRequiredAnswered]
  ///
  /// Purpose: Submit stays locked until every REQUIRED field has an answer
  /// and no Email / Link / Phone answer is in the wrong format (form bug
  /// report #16/#22).
  ///
  /// Parameters:
  /// - [pages]: the page's field controllers.
  ///
  /// Returns: true when the form may be submitted.
  bool allRequiredAnswered(List<PageControllerModel> pages) {
    for (final page in pages) {
      for (final row in page.rows) {
        for (final controller in row.controllers) {
          if (controller.getIsRequired() && !controller.isAnswerFilled()) {
            return false;
          }
          if (FormAnswerFormat.errorFor(controller) != null) return false;
        }
      }
    }
    return true;
  }

  /// Method Name: [editClicked]
  ///
  /// Purpose: makes a submitted answer editable. FB-RESULT-08: does nothing
  /// once the form has closed.
  void editClicked() {
    final SubmissionsLoaded? current = _loaded;
    if (current == null || !current.canEdit) return;
    emit(current.copyWith(isReadOnly: false));
  }

  /// Method Name: [fillDemoAnswers]
  ///
  /// Purpose: "Fill demo data" (test builds / demo accounts): a sample
  /// answer in every field that can take one.
  ///
  /// Parameters:
  /// - [pages]: the page's field controllers.
  ///
  /// Returns: how many fields were filled.
  int fillDemoAnswers(List<PageControllerModel> pages) {
    final SubmissionsLoaded? current = _loaded;
    if (current == null || current.isReadOnly) return 0;
    final int n = FormDemoAnswers.fill(pages);
    answersChanged();
    return n;
  }
}
