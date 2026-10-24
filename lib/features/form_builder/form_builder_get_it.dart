/// Module: form_builder_module/presentation
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_cubits.dart
/// Description: Dependency injection for the Form Builder (get_it).
///              Data sources, repositories, use cases and services are
///              registered once here; cubits receive them through their
///              constructors and widgets never construct them.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/features/form_builder/helpers/form_builder_directory.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_notifier.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_notifier_impl.dart';
import 'package:knowticed_plus/core/helper/csv_helper.dart';
import 'package:knowticed_plus/core/app_services/media_picker_service.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/data/data_source/remote_data_source/home_remote_data_source.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/data/repository/home_repository.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/base_repository/home_base_repository.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/data_source/remote_data_source/form_data_source.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/mappers/person_entity_factory.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/repository/form_repo_impl.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/base_repository/form_repo.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/data/data_source/remote_data_source/response_data_source.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/data/repository/response_repo_impl.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/base_repository/response_repo.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/use_cases/send_response_use_case.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/presentation/controller/form_submissions_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/data/data_source/remote_data_source/result_remote_data_source.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/data/repository/result_repository.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/data/utils/media_handler.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/base_repository/result_base_repository.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/use_cases/get_users_responses_use_case.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_analytics_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/upload_media_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/data/data_source/remote_data_source/group_data_source.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/data/data_source/remote_data_source/share_remote_data_source.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/data/repository/group_repository.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/data/repository/share_repository.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/domain/base_repository/group_base_repository.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/domain/base_repository/share_base_repository.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/domain/use_cases/get_user_groups_use_case.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/share_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb7_convert_pdf/presentation/controller/pdf_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb7_convert_pdf/presentation/utils/pdf_export_service.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

/// The Form Builder's own service locator (separate from any app-wide one).
final GetIt formBuilderLocator = GetIt.asNewInstance();

/// Function Name: [setupFormBuilderDependencies]
///
/// Purpose: registers the Form Builder's dependencies once. Safe to call on
/// every mount of the module; later calls do nothing.
void setupFormBuilderDependencies() {
  final GetIt sl = formBuilderLocator;
  if (sl.isRegistered<ResponseRepo>()) return;

  // ── Services ────────────────────────────────────────────────────────
  sl.registerLazySingleton<FormBuilderNotifier>(
    () => const FormBuilderNotifierImpl(),
  );
  sl.registerLazySingleton<MediaPickerService>(() => MediaPickerService());
  sl.registerLazySingleton<CSVHelper>(() => CSVHelper());
  sl.registerLazySingleton<MediaHandler>(() => MediaHandler());

  // ── Responses (f5_submissions owns the one response store) ──────────
  sl.registerLazySingleton<ResponseDataSource>(() => ResponseDataSource());
  sl.registerLazySingleton<ResponseRepo>(
    () => ResponseRepoImpl(responseDataSource: sl<ResponseDataSource>()),
  );
  sl.registerFactory<SendResponseUseCase>(
    () => SendResponseUseCase(
      responseRepo: sl<ResponseRepo>(),
      notifier: sl<FormBuilderNotifier>(),
    ),
  );

  // ── App-wide controllers (registered with GetX by the app shell; read
  //    here, in ONE place, so no cubit or widget looks them up) ──────────
  sl.registerFactory<MainCoreEmployeeController>(
    () => Get.find<MainCoreEmployeeController>(),
  );
  sl.registerFactory<MainCoreDepartmentCubit>(
    () => Get.find<MainCoreDepartmentCubit>(),
  );

  // ── Home & create ───────────────────────────────────────────────────
  sl.registerLazySingleton<HomeRemoteDataSource>(() => HomeRemoteDataSource());
  sl.registerLazySingleton<HomeBaseRepository>(
    () => HomeRepository(homeRemoteDataSource: sl<HomeRemoteDataSource>()),
  );
  sl.registerLazySingleton<FormDataSource>(() => FormDataSource());
  sl.registerLazySingleton<FormRepo>(
    () => FormRepoImpl(formDataSource: sl<FormDataSource>()),
  );

  // ── Share & groups ──────────────────────────────────────────────────
  sl.registerLazySingleton<GroupDataSource>(() => GroupDataSource());
  sl.registerLazySingleton<GroupBaseRepository>(
    () => GroupRepository(groupDataSource: sl<GroupDataSource>()),
  );
  sl.registerFactory<GetUserGroupsUseCase>(
    () => GetUserGroupsUseCase(groupRepository: sl<GroupBaseRepository>()),
  );
  sl.registerLazySingleton<ShareRemoteDataSource>(
    () => ShareRemoteDataSource(),
  );
  sl.registerLazySingleton<ShareBaseRepository>(
    () => ShareRepository(shareRemoteDataSource: sl<ShareRemoteDataSource>()),
  );

  // ── PDF ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PdfExportService>(
    () => PdfExportService(csvHelper: sl<CSVHelper>()),
  );

  // ── Results ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<ResultRemoteDataSource>(
    () => ResultRemoteDataSource(),
  );
  sl.registerLazySingleton<ResultBaseRepository>(
    () => ResultRepository(
      responseRepo: sl<ResponseRepo>(),
      remoteDataSource: sl<ResultRemoteDataSource>(),
    ),
  );
  sl.registerFactory<GetUsersResponsesUseCase>(
    () => GetUsersResponsesUseCase(
      resultRepository: sl<ResultBaseRepository>(),
      personOf: PersonEntityFactory.fromEmail,
    ),
  );
}

/// Builds the Form Builder cubits with their injected dependencies.
class FormBuilderCubits {
  const FormBuilderCubits._();

  /// Method Name: [home]
  ///
  /// Returns: a new [HomeCubit].
  static HomeCubit home() {
    setupFormBuilderDependencies();
    return HomeCubit(
      homeRepository: formBuilderLocator<HomeBaseRepository>(),
      formRepo: formBuilderLocator<FormRepo>(),
      responseRepo: formBuilderLocator<ResponseRepo>(),
      mainCoreEmployeeController:
          formBuilderLocator<MainCoreEmployeeController>(),
    );
  }

  /// Method Name: [createFormHead]
  ///
  /// Returns: a new [CreateFormHeadCubit].
  static CreateFormHeadCubit createFormHead() => CreateFormHeadCubit();

  /// Method Name: [createFormData]
  ///
  /// Parameters:
  /// - [headCubit]: the editor's header cubit.
  ///
  /// Returns: a new [CreateFormDataCubit].
  static CreateFormDataCubit createFormData(CreateFormHeadCubit headCubit) {
    setupFormBuilderDependencies();
    return CreateFormDataCubit(
      mainCoreEmployeeController:
          formBuilderLocator<MainCoreEmployeeController>(),
      addDepartmentController: formBuilderLocator<MainCoreDepartmentCubit>(),
      createFormHeadCubit: headCubit,
    );
  }

  /// Method Name: [formsGroup]
  ///
  /// Returns: a new [FormsGroupCubit].
  static FormsGroupCubit formsGroup() {
    setupFormBuilderDependencies();
    return FormsGroupCubit(
      groupRepository: formBuilderLocator<GroupBaseRepository>(),
      getUserGroupsUseCase: formBuilderLocator<GetUserGroupsUseCase>(),
      mainCoreEmployeeController:
          formBuilderLocator<MainCoreEmployeeController>(),
      departmentCubit: formBuilderLocator<MainCoreDepartmentCubit>(),
    );
  }

  /// Method Name: [share]
  ///
  /// Returns: a new [ShareCubit].
  static ShareCubit share() {
    setupFormBuilderDependencies();
    return ShareCubit(
      shareRepository: formBuilderLocator<ShareBaseRepository>(),
      mainCoreEmployeeController:
          formBuilderLocator<MainCoreEmployeeController>(),
      departmentCubit: formBuilderLocator<MainCoreDepartmentCubit>(),
    );
  }

  /// Method Name: [pdf]
  ///
  /// Returns: a new [PdfCubit].
  static PdfCubit pdf() => PdfCubit();

  /// The PDF capture and save service.
  static PdfExportService get pdfExport {
    setupFormBuilderDependencies();
    return formBuilderLocator<PdfExportService>();
  }

  /// Method Name: [submissions]
  ///
  /// Returns: a new [FormSubmissionsCubit].
  static FormSubmissionsCubit submissions() {
    setupFormBuilderDependencies();
    return FormSubmissionsCubit(
      sendResponseUseCase: formBuilderLocator<SendResponseUseCase>(),
      currentUserEmail: () => FormBuilderDirectory.currentUserEmail,
    );
  }

  /// Method Name: [result]
  ///
  /// Returns: a new [ResultCubit].
  static ResultCubit result() {
    setupFormBuilderDependencies();
    return ResultCubit(
      resultRepository: formBuilderLocator<ResultBaseRepository>(),
      usersResponsesUseCase: formBuilderLocator<GetUsersResponsesUseCase>(),
      notifier: formBuilderLocator<FormBuilderNotifier>(),
      csvHelper: formBuilderLocator<CSVHelper>(),
      ensureDepartmentsLoaded: FormBuilderDirectory.ensureDepartmentsLoaded,
    );
  }

  /// Method Name: [resultAnalytics]
  ///
  /// Returns: a new [ResultAnalyticsCubit].
  static ResultAnalyticsCubit resultAnalytics() => ResultAnalyticsCubit();

  /// Method Name: [uploadMedia]
  ///
  /// Returns: a new [UploadMediaCubit].
  static UploadMediaCubit uploadMedia() {
    setupFormBuilderDependencies();
    return UploadMediaCubit(mediaHandler: formBuilderLocator<MediaHandler>());
  }

  /// The shared file / image picker (widgets use this instead of creating
  /// their own).
  static MediaPickerService get mediaPicker {
    setupFormBuilderDependencies();
    return formBuilderLocator<MediaPickerService>();
  }
}
