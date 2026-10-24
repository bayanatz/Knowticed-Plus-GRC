/// Module: knowledge_hub
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_hub_di.dart
/// Description: The ONE place the Knowledge Hub's services and cubits are
///              created (Rule Bug 1 — "inject repositories, never create them
///              in cubits or widgets").
/// Author: Amr Mesbah
/// Created at: 11/10/2026
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_people.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/app_services/media_picker_service.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/data/repository/submissions_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/domain/base_repository/submissions_base_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/controller/submissions_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/controller/knowledge_removal_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/data/repository/approvals_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/domain/base_repository/approvals_base_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/controller/approvals_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/data/repository/create_knowledge_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/data/repository/comments_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/domain/base_repository/comments_base_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/controller/comments_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/domain/base_repository/create_knowledge_base_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/data/repository/dashboard_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/domain/base_repository/dashboard_base_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/presentation/controller/dashboard_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/dashboard_firebase_services.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/knowledge_seed_service.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/repository/analytics_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/approvals_firebase_services.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/create_comment_firebase_service.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/knowledge_hub_firebase_services.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/submissions_firebase_service.dart';
import 'package:knowticed_plus/features/knowledge_hub/domain/base_repository/analytics_base_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/controller/analytics/analytics_cubit.dart';

/// Pages and buttons ask this seam for what they need instead of calling
/// `ApprovalsFirebaseServices()` / `ApprovalsCubit(...)` themselves. Services
/// are registered once (GetX, the app's locator — see core/di/app_controllers)
/// and shared; cubits are created fresh per screen, with the shared service
/// injected.
class KnowledgeHubDI {
  const KnowledgeHubDI._();

  static T _single<T>(T Function() build) {
    if (!Get.isRegistered<T>()) Get.put<T>(build(), permanent: true);
    return Get.find<T>();
  }

  /// The signed-in employee and the employee / department lists, resolved
  /// from the controllers registered at app start. Handed to every cubit so
  /// widgets never call Get.find.
  static KhPeople get people => _single(
    () => KhPeople(
      employees: () => Get.isRegistered<MainCoreEmployeeController>()
          ? Get.find<MainCoreEmployeeController>()
          : null,
      departments: () => Get.isRegistered<MainCoreDepartmentCubit>()
          ? Get.find<MainCoreDepartmentCubit>()
          : null,
    ),
  );

  static ApprovalsFirebaseServices get approvalsServices =>
      _single(ApprovalsFirebaseServices.new);

  static KnowledgeHubFirebaseServices get knowledgeHubServices =>
      _single(KnowledgeHubFirebaseServices.new);

  /// A new approvals cubit for one screen, with the shared service injected.
  static ApprovalsBaseRepository get approvalsRepository =>
      _single<ApprovalsBaseRepository>(
        () => ApprovalsRepository(
          approvalsServices: approvalsServices,
          knowledgeHubServices: knowledgeHubServices,
        ),
      );

  static ApprovalsCubit approvalsCubit() =>
      ApprovalsCubit(approvalsRepository, people);

  static SubmissionsFirebaseServices get submissionsServices =>
      _single(SubmissionsFirebaseServices.new);

  static CommentsFirebaseServices get commentsServices =>
      _single(CommentsFirebaseServices.new);

  static SubmissionsBaseRepository get submissionsRepository =>
      _single<SubmissionsBaseRepository>(
        () => SubmissionsRepository(
          submissionsServices: submissionsServices,
          knowledgeHubServices: knowledgeHubServices,
          approvalsServices: approvalsServices,
        ),
      );

  static AnalyticsBaseRepository get analyticsRepository =>
      _single<AnalyticsBaseRepository>(
        () => AnalyticsRepository(commentsServices),
      );

  /// A new submissions cubit for one screen, with the shared repository.
  static SubmissionsCubit submissionsCubit() =>
      SubmissionsCubit(submissionsRepository, people);

  /// A new analytics cubit for one screen, with the shared repository.
  static AnalyticsCubit analyticsCubit() =>
      AnalyticsCubit(analyticsRepository, people);

  /// A new removal cubit for one "Reason of removing" dialog.
  static KnowledgeRemovalCubit knowledgeRemovalCubit() =>
      KnowledgeRemovalCubit(submissionsRepository);

  static DashboardBaseRepository get dashboardRepository =>
      _single<DashboardBaseRepository>(
        () => DashboardRepository(_single(DashboardFirebaseServices.new)),
      );

  /// A new dashboard cubit for one screen. The department cubit is the one
  /// registered once at app start (main.dart).
  static DashboardCubit dashboardCubit() =>
      DashboardCubit(dashboardRepository, Get.find<MainCoreDepartmentCubit>());

  static CreateKnowledgeBaseRepository get createKnowledgeRepository =>
      _single<CreateKnowledgeBaseRepository>(
        () => CreateKnowledgeRepository(knowledgeHubServices, seedService),
      );

  /// A new hub / create cubit for one screen, with the shared repository.
  static CreateKnowledgeCubit createKnowledgeCubit() =>
      CreateKnowledgeCubit(createKnowledgeRepository, people);

  static CommentsBaseRepository get commentsRepository =>
      _single<CommentsBaseRepository>(
        () => CommentsRepository(commentsServices, knowledgeHubServices),
      );

  /// A new comments cubit for one document page, with the shared repository.
  static CommentsCubit commentsCubit() =>
      CommentsCubit(commentsRepository, people);

  static MediaPickerService get mediaPicker => _single(MediaPickerService.new);

  static KnowledgeSeedService get seedService =>
      _single(KnowledgeSeedService.new);
}
