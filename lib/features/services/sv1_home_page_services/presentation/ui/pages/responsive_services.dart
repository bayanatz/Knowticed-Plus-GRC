/// Module: services / sv1_home_page_services / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: responsive_services.dart
/// Purpose: Responsive services. Module composition root — owns the
///          BlocProvider<ServicesManagerCubit> that every screen under the
///          services module resolves via ServicesManagerCubit.get().
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

// ADDED 22/10/2026 — open the notification's request. See [_openRecord].
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/notification/domain/routing/pending_notification_record.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/parent_service_details_fetcher.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_notification_record.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/ui/pages/employee_details_services.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/pages/my_request_details_toggle.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/ui/pages/approval_request_details_toggle.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/services_dependencies.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_routes.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/service_doc_fetcher.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/service_draft_manager.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/service_provider_selector.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_filter_loader.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_notification_service.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/new_request_cubit.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
// ADDED 12/9/2026 — the notification deep-link landing. See [pendingSection].
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/features/notification/domain/routing/notification_deep_link.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/pages/request_services_toggle.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/ui/pages/approval_request_toggle.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/ui/pages/employee_services.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/pages/select_services_provider_toggle.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

// REMOVED 8/9/2026: the ResponsiveHelper import went with the split branches —
// mobile and tablet now build the same tree. See build().

class ServicesResponsivePage extends StatelessWidget {
  const ServicesResponsivePage({super.key});

  /// The screen to open on top of the services home, left here by the
  /// notification inbox before it selects this module in the drawer.
  ///
  /// ADDED 12/9/2026 with the deep-link router. Requests, Approvals and the
  /// provider dashboard are not tabs — they are `navigateTo(context, X())`
  /// pushes from the home screen's buttons — so a deep link is a push
  /// scheduled after the home page's first frame, which also leaves the reader
  /// a back button to the module.
  ///
  /// Same shape as `RoleScreenHost.pendingInitialTab`.
  ///
  /// ⚠️ Read-and-cleared on the first build, used or not: a hint left armed
  /// would hijack the next unrelated visit to Services.
  static NotificationServicesSection? pendingSection;

  /// Function Name: [_consumeDeepLink]
  ///
  /// Purpose: Open the screen a notification pointed at, once the home page
  /// exists.
  ///
  /// [context] MUST be the one from the route builder below — it is the only
  /// one under this module's Navigator, and the whole point of that Navigator
  /// (see the fix note in [build]) is that pushes stay inside the module and
  /// keep the provider above them.
  ///
  /// Read-and-clear happens synchronously, before the post-frame callback: a
  /// route builder can run again on rebuild, and taking the value out up front
  /// is what stops a second push.
  static void _consumeDeepLink(BuildContext context) {
    // ADDED 22/10/2026 — View opens the request itself (owner). Taken here,
    // with the section, so both are read-and-cleared together.
    final PendingNotificationRecord? record = PendingNotificationRecord.take(
      Modules.services,
    );
    final ServicesRecordView? view = record == null
        ? null
        : ServicesNotificationRecord.viewFor(record.pageKey);

    // The record's list goes under its details, so Back lands on the list
    // even when the stored page key resolved no section of its own.
    final NotificationServicesSection? section =
        pendingSection ?? view?.section;
    pendingSection = null;
    if (section == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      // All three are const, no-argument widgets — the same ones
      // `request_services_button.dart` and `management_widget.dart` push.
      navigateTo(
          context,
          switch (section) {
            NotificationServicesSection.requests =>
              const RequestServicesToggle(),
            NotificationServicesSection.approvals => const ApprovalToggle(),
            // ⚠️ The stored page key is `ServiceProviderDashboard`, which is not
            // a class in this codebase; the provider's screen is this one.
            NotificationServicesSection.providerDashboard =>
              const EmployeeServicesScreen(),
          });
      if (record != null && view != null) {
        _openRecord(context, record.recordId, view);
      }
    });
  }

  /// Function Name: [_openRecord]
  ///
  /// Purpose: Load request [recordId] and push its details page on top of the
  /// list [_consumeDeepLink] just opened — the same widgets the list cards
  /// push. A request that no longer exists leaves the reader on the list.
  static Future<void> _openRecord(
    BuildContext context,
    String recordId,
    ServicesRecordView view,
  ) async {
    final ServicesHistoryModel? request = await ServicesNotificationRecord.load(
      repository: ServicesManagerCubit.get(context).repository,
      recordId: recordId,
      fetchNames: ParentServiceDetailsFetcher(FirebaseFirestore.instance).fetch,
    );
    if (request == null || !context.mounted) return;

    navigateTo(
        context,
        switch (view) {
          ServicesRecordView.approver => ServicesApprovalDetailsToggle(
              index: 0,
              approvalModel: request,
            ),
          ServicesRecordView.provider =>
            EmployeeDetailsServicesScreen(approvalModel: request),
          ServicesRecordView.requester => MyRequestDetailsServicesToggle(
              myRequestDetailsModel: request,
            ),
        });
  }

  @override
  Widget build(BuildContext context) {
    // TEMP DIAGNOSTIC — proves this build of the file is the one running.
    svcLog('PERMDIAG >>> ServicesResponsivePage.build reached');

    // The provider sits above the module's Navigator, so every route pushed
    // inside the module inherits it.
    //
    // FIXED 8/9/2026 — "Could not find the correct Provider<ServicesManagerCubit>".
    //
    // The mobile branch used to be a bare `LayoutScreenServices()` with NO
    // Navigator of its own; only tablet got one. `navigateTo` is
    // `Navigator.push(context, ...)`, which finds the NEAREST navigator:
    //
    //   • tablet — the nearest one was this module's own, created BELOW the
    //     provider, so a pushed page could still resolve
    //     `ServicesManagerCubit.get(context)`;
    //   • mobile — there was none here, so the nearest was the one OUTSIDE
    //     this widget (the bottom-bar tab's). Every page pushed inside the
    //     module therefore landed ABOVE the provider and threw the moment it
    //     built a BlocListener or BlocBuilder for ServicesManagerCubit.
    //
    // RequestServicesPage was just the first one anybody opened; every other
    // pushed screen in this module had the same fault, so fixing it here fixes
    // them all rather than patching one call site at a time.
    //
    // ResponsiveHelper is gone with it: both of its branches now build the
    // identical tree, so it had nothing left to choose between. Dropping it
    // also means the Navigator survives a phone/tablet size change instead of
    // the subtree being swapped out underneath it.
    // The module's repositories and services are created once here and
    // injected into every page and cubit below (ServicesDependencies).
    return ServicesDependencies(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ServicesManagerCubit>(
            create: (context) => ServicesManagerCubit(
              context.read<CreateServicesRepository>(),
              draftManager: context.read<ServiceDraftManager>(),
              providerSelector: context.read<ServiceProviderSelector>(),
              filterLoader: context.read<ServicesFilterLoader>(),
              docFetcher: context.read<ServiceDocFetcher>(),
              employeeEntity: Get.isRegistered<MainCoreEmployeeController>()
                  ? AppControllers.employee.employeeEntity
                  : null,
            ),
          ),
          // The Request button on every service card (Home, Service requests,
          // service details) creates requests through this cubit.
          BlocProvider<NewRequestCubit>(
            create: (context) {
              final manager = context.read<ServicesManagerCubit>();
              return NewRequestCubit(
                manager: manager,
                notifications: context.read<ServicesNotificationService>(),
                requester:
                    manager.hasEmployeeEntity ? manager.employeeEntity : null,
              );
            },
          ),
        ],
        child: Navigator(
          initialRoute: ServicesRoutes.home,
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case ServicesRoutes.editProvider:
                final request = settings.arguments as ServicesHistoryModel;
                return appSlideRoute<void>(
                  ServicesProviderLayout(
                    editingModel: request,
                    docId: request.currentId,
                    editProvider: request,
                  ),
                );
              case ServicesRoutes.home:
              default:
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (BuildContext context) {
                    _consumeDeepLink(context);
                    return const LayoutScreenServices();
                  },
                );
            }
          },
        ),
      ),
    );
  }
}
