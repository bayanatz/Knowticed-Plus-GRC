// [module-file:form_builder] — deleted when the form_builder module is split out
/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: forms_submission_summary.dart
/// Description: Real data for the Home "Forms Submission" card (form bug report
///          #25): the signed-in user's latest PUBLISHED form, and how many of
///          the people it was sent to have submitted it.
/// Author: Amr Mesbah
/// Created at: 26/9/2026
library;

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/models/form_model.dart';
import 'package:knowticed_plus/features/form_builder/data/models/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/data_source/remote_data_source/form_data_source.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/repository/form_repo_impl.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/data/mappers/form_entity_mapper.dart';
import 'package:knowticed_plus/features/form_builder/form_builder_get_it.dart';

/// Loads the latest published form and keeps a [ResultCubit] for it, so the
/// card can show the completion ring and send reminders with the exact same
/// logic as the Form Builder's Pending tab.
class FormsSubmissionSummary {
  // 22/10/2026: built on first use, not with the card — a user with no
  // published form never needs one (and never opens its Firestore reads).
  ResultCubit? _resultCubit;
  ResultCubit get resultCubit => _resultCubit ??= FormBuilderCubits.result();

  FormEntity? form;

  int get submitted {
    final s = _resultCubit?.state;
    return s is ResultLoaded ? s.submittedUsers.length : 0;
  }

  int get pending {
    final s = _resultCubit?.state;
    return s is ResultLoaded ? s.pendingUsers.length : 0;
  }

  double get completion {
    final total = submitted + pending;
    return total == 0 ? 0 : submitted / total;
  }

  /// Returns false when the user has no published form. [formId] = the form
  /// picked in the card's gear; missing / no longer published = the latest.
  Future<bool> load({String formId = ''}) async {
    final List<FormModel> published = await _publishedModels();
    if (published.isEmpty) return false;
    final FormModel chosen = published.firstWhere(
        (FormModel m) => m.id == formId,
        orElse: () => published.first);
    // Privacy (who the form is sent to) is read for the ONE form the card
    // shows, not for every form the user has.
    FormPrivacyModel privacy = FormPrivacyModel();
    final privacyResult = await _repo.getFormPrivacy(chosen.id);
    privacyResult.fold((_) {}, (p) => privacy = p);
    form = FormEntityMapper.fromModel(chosen, privacy);
    await resultCubit.initialize(form!);
    return true;
  }

  static FormRepoImpl get _repo =>
      FormRepoImpl(formDataSource: FormDataSource());

  /// The signed-in user's published forms, newest first, as raw models — one
  /// query. The status lives on the form itself, so no per-form request is
  /// needed to tell which are published.
  static Future<List<FormModel>> _publishedModels() async {
    if (!Get.isRegistered<MainCoreEmployeeController>()) {
      return const <FormModel>[];
    }
    final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
    if (email == null || email.isEmpty) return const <FormModel>[];

    final Either<Failure, dynamic> result =
        await _repo.getMyCreatedForms(email);
    if (result.isLeft()) return const <FormModel>[];

    final List<FormModel> models =
        List<FormModel>.from(result.getOrElse(() => <FormModel>[]) as List);
    final List<FormModel> published = <FormModel>[
      for (final FormModel m in models)
        if (m.formStatus.last.toLowerCase() ==
            FormStatus.publish.name.toLowerCase())
          m,
    ];
    published.sort((FormModel a, FormModel b) =>
        b.timestamps.first.compareTo(a.timestamps.first));
    return published;
  }

  /// The signed-in user's published forms, newest first — the choices of the
  /// Forms Submission gear (Owner 21/10/2026). Light: no privacy lookups, so
  /// the gear opens after ONE request instead of one per form.
  static Future<List<FormEntity>> publishedForms() async {
    final List<FormModel> models = await _publishedModels();
    return <FormEntity>[
      for (final FormModel m in models)
        FormEntityMapper.fromModel(m, FormPrivacyModel()),
    ];
  }

  /// Sends every due reminder; returns how many went out.
  Future<int> remindAll() => resultCubit.remindAllClicked();

  void dispose() => _resultCubit?.close();
}
