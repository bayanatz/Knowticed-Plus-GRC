/// Module: services
///
///*************************** FILE INFO ****************************///
/// File Name: services_dependencies.dart
/// Purpose: Creates the services module's repositories and services ONCE, at
///          the module root, and provides them to every page below it.
///          Pages read them with `context.read<T>()` and pass them into the
///          cubits they create, so no cubit or widget builds its own
///          repository or service.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/app_services/media_picker_service.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_template_service.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/service_image_storage.dart';
import 'package:knowticed_plus/features/services/data/repository/chat_repository_impl.dart';
import 'package:knowticed_plus/features/services/data/repository/service_repository_impl.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/approval_decision_service.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_notification_service.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/chat_repository.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/presentation/controller/request_details_lookup.dart';
import 'package:knowticed_plus/features/services/data/data_source/local_data_source/draft_session_service.dart';
import 'package:knowticed_plus/features/services/data/data_source/local_data_source/services_local_data_source.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/parent_service_details_fetcher.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/request_provider_resolver.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/service_doc_fetcher.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/service_draft_manager.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/service_provider_selector.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_docs_data_source.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_filter_loader.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_remote_data_source.dart';
import 'package:knowticed_plus/features/services/data/repository/firebase_draft_repository.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/repository/role_repository.dart';

/// Provides the module's dependencies to [child].
class ServicesDependencies extends StatelessWidget {
  const ServicesDependencies({required this.child, super.key});

  /// The module's widget tree (its Navigator).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ServiceProviderSelector>(
          create: (_) =>
              ServiceProviderSelector(firestore: FirebaseFirestore.instance),
        ),
        // Rule "Inject repositories — never create them in cubits or
        // widgets": the repository's data sources and the module cubit's
        // collaborators are all built here, once.
        RepositoryProvider<CreateServicesRepository>(
          create: (context) {
            final firestore = FirebaseFirestore.instance;
            return GetServiceRepositoryImpl(
              firestore: firestore,
              docs: ServicesDocsDataSource(firestore),
              parentDetailsFetcher: ParentServiceDetailsFetcher(firestore),
              providerResolver: RequestProviderResolver(
                firestore,
                selector: context.read<ServiceProviderSelector>(),
              ),
              local: ServicesLocalDataSource(),
              remote: ServicesRemoteDataSource(firestore),
            );
          },
        ),
        RepositoryProvider<RoleRepository>(create: (_) => RoleRepository()),
        RepositoryProvider<ServiceDraftManager>(
          create: (_) => ServiceDraftManager(
            draftRepository: FirebaseDraftRepository(),
            draftSession: DraftSessionService(),
          ),
        ),
        RepositoryProvider<ServicesFilterLoader>(
          create: (_) =>
              ServicesFilterLoader(firestore: FirebaseFirestore.instance),
        ),
        RepositoryProvider<ServiceDocFetcher>(
          create: (_) =>
              ServiceDocFetcher(firestore: FirebaseFirestore.instance),
        ),
        RepositoryProvider<ChatRepository>(create: (_) => ChatRepositoryImpl()),
        RepositoryProvider<MediaPickerService>(
          create: (_) => MediaPickerService(),
        ),
        RepositoryProvider<ServiceImageStorage>(
          create: (_) => ServiceImageStorage(),
        ),
        RepositoryProvider<ServicesNotificationService>(
          create: (_) => const ServicesNotificationService(),
        ),
        RepositoryProvider<NotificationTemplateService>(
          create: (_) => NotificationTemplateService(),
        ),
        RepositoryProvider<ApprovalDecisionService>(
          create: (context) => ApprovalDecisionService(
            repository: context.read<CreateServicesRepository>(),
            notifications: context.read<ServicesNotificationService>(),
          ),
        ),
        RepositoryProvider<RequestDetailsLookup>(
          create: (context) => RequestDetailsLookup(
            repository: context.read<CreateServicesRepository>(),
            departments: context.read<MainCoreDepartmentCubit>(),
            findEmployee: (email) =>
                AppControllers.employee.mapOfEmployeesWithEmailKey[email],
          ),
        ),
      ],
      child: child,
    );
  }
}
