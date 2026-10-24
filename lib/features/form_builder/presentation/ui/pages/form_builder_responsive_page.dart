/// Module: form_builder_module/presentation
///
///*************************** FILE INFO ****************************///
/// File Name: form_responsive_page_layout.dart
/// Description: `FormResponsivePageLayout`, the Form Builder module page:
///              provides the module's cubits and hosts its Navigator.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Cubits from FormBuilderCubits; routes in
///                       FormBuilderRouter.
/// Updated: 23/10/2026 - The pending Results page is opened from initState /
///                       didUpdateWidget, not from build() (Share rule 4).
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/form_builder/helpers/form_navigator_service.dart';
import 'package:knowticed_plus/core/constants/app_routes.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/form_editor_keys.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/presentation/controller/form_submissions_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_analytics_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/upload_media_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/pages/result_screen.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/share_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb7_convert_pdf/presentation/controller/pdf_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb7_convert_pdf/presentation/utils/pdf_page_keys.dart';
import 'package:knowticed_plus/features/form_builder/form_builder_get_it.dart';
import 'package:knowticed_plus/features/form_builder/presentation/navigation/form_builder_router.dart';
import 'package:knowticed_plus/features/notification/data/repository/form_builder_notification_scheduler.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/settings/presentation/controller/settings_controller.dart';

/// The Form Builder module: provides its cubits once and hosts the module's
/// own Navigator (routes in [FormBuilderRouter]).
class FormResponsivePageLayout extends StatefulWidget {
  const FormResponsivePageLayout({super.key});

  /// Set by the Home "Forms
  /// Submission" card before it opens this module; consumed (and cleared)
  /// when the module page is mounted or updated, which then opens that
  /// form's Results page inside the module so the Form Builder's own
  /// providers are available.
  static FormEntity? pendingResultForm;

  @override
  State<FormResponsivePageLayout> createState() =>
      _FormResponsivePageLayoutState();
}

class _FormResponsivePageLayoutState extends State<FormResponsivePageLayout> {
  final _formNavigatorService = FormBuilderNavigatorService();

  // A navigator key UNIQUE to this page mount.
  //
  // The shared singleton key on FormBuilderNavigatorService was attached to
  // the Navigator below, so re-entering Form Builder (or a page transition
  // that briefly keeps the old page mounted) put the SAME GlobalKey on two
  // live Navigators and crashed with
  // "'_elements.contains(element)': is not true". A fresh key per State means
  // two mounts can never collide; the service is pointed at this one in
  // initState so its navigateTo/pop helpers still target the visible navigator.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// Key of the widget under the providers, so the pending Results page can
  /// read the module's cubits.
  final GlobalKey _providersChildKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _registerAppControllers();
    setupFormBuilderDependencies();
    _formNavigatorService.bindNavigatorKey(_navigatorKey);
    _runNotificationSweep();
    _consumePendingResult();
  }

  @override
  void didUpdateWidget(covariant FormResponsivePageLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The Home card can set a pending form while this page stays mounted.
    _consumePendingResult();
  }

  /// Share rule 2: the app-wide controllers are registered once, here, not
  /// on every build().
  ///
  /// MainCoreDepartmentCubit is created once in main.dart and registered
  /// both with Get and with BlocProvider.value, so it is normally already
  /// present. If it somehow is not, the instance from the widget tree is
  /// adopted rather than constructing a new one (the cubit reads every
  /// department from Firestore when it is created).
  void _registerAppControllers() {
    if (!Get.isRegistered<MainCoreDepartmentCubit>()) {
      Get.put(context.read<MainCoreDepartmentCubit>());
    }
    if (!Get.isRegistered<MainCoreEmployeeController>()) {
      Get.put(MainCoreEmployeeController());
    }
    if (!Get.isRegistered<SettingsController>()) {
      Get.put(SettingsController());
    }
  }

  /// Raise any "Form Access Ends in 14 Days" / "Form Access
  /// Has Ended" notification that fell due since the last time anybody opened
  /// the module (the app has no server cron). Deliberately not awaited; it
  /// runs once per session. See FormBuilderNotificationScheduler.
  void _runNotificationSweep() {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return;
    final String email =
        formBuilderLocator<MainCoreEmployeeController>()
            .employeeEntity
            ?.email ??
        '';
    FormBuilderNotificationScheduler.sweep(actingUserEmail: email);
  }

  @override
  Widget build(BuildContext context) {
    // Every cubit comes from FormBuilderCubits (dependencies injected in
    // presentation/di); nothing is constructed inline here (Share rule 1).
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FormEditorKeys>(create: (_) => FormEditorKeys()),
        RepositoryProvider<PdfPageKeys>(create: (_) => PdfPageKeys()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<CreateFormHeadCubit>(
            create: (_) => FormBuilderCubits.createFormHead(),
            lazy: false,
          ),
          BlocProvider<CreateFormDataCubit>(
            create: (context) => FormBuilderCubits.createFormData(
              context.read<CreateFormHeadCubit>(),
            ),
            lazy: false,
          ),
          BlocProvider<HomeCubit>(
            create: (_) => FormBuilderCubits.home(),
            lazy: false,
          ),
          BlocProvider<FormSubmissionsCubit>(
            create: (_) => FormBuilderCubits.submissions(),
            lazy: true,
          ),
          BlocProvider<FormsGroupCubit>(
            create: (_) => FormBuilderCubits.formsGroup(),
            lazy: true,
          ),
          BlocProvider<ShareCubit>(
            create: (_) => FormBuilderCubits.share(),
            lazy: true,
          ),
          BlocProvider<ResultCubit>(
            create: (_) => FormBuilderCubits.result(),
            lazy: true,
          ),
          BlocProvider<ResultAnalyticsCubit>(
            create: (_) => FormBuilderCubits.resultAnalytics(),
            lazy: true,
          ),
          BlocProvider<UploadMediaCubit>(
            create: (_) => FormBuilderCubits.uploadMedia(),
            lazy: true,
          ),
          BlocProvider<PdfCubit>(
            create: (_) => FormBuilderCubits.pdf(),
            lazy: true,
          ),
        ],
        child: _FormNavigatorWidget(
          key: _providersChildKey,
          navigatorKey: _navigatorKey,
        ),
      ),
    );
  }

  /// Opens [FormResponsivePageLayout.pendingResultForm]'s Results page once,
  /// after the frame (never from build()).
  void _consumePendingResult() {
    final FormEntity? form = FormResponsivePageLayout.pendingResultForm;
    if (form == null) return;
    FormResponsivePageLayout.pendingResultForm = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final BuildContext? providerContext = _providersChildKey.currentContext;
      if (providerContext == null) return;
      final NavigatorState? nested = _navigatorKey.currentState;
      if (nested != null) {
        // Tablet / desktop: the module's own Navigator, inside the shell.
        nested.pushNamed(Routes.resultScreen, arguments: form);
        return;
      }
      // Phone: no nested Navigator, so carry the cubits the page reads.
      Navigator.of(providerContext).push(
        MaterialPageRoute<void>(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<ResultCubit>.value(
                value: providerContext.read<ResultCubit>(),
              ),
              BlocProvider<UploadMediaCubit>.value(
                value: providerContext.read<UploadMediaCubit>(),
              ),
              BlocProvider<ResultAnalyticsCubit>.value(
                value: providerContext.read<ResultAnalyticsCubit>(),
              ),
            ],
            child: ResultScreen(form: form),
          ),
        ),
      );
    });
  }
}

// Separated widget to fix framework assertion error
class _FormNavigatorWidget extends StatelessWidget {
  /// Owned by the parent State (unique per mount) rather than pulled from the
  /// singleton service, so this Navigator's key can never clash with another
  /// live form-builder Navigator.
  final GlobalKey<NavigatorState> navigatorKey;

  const _FormNavigatorWidget({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    // Phones used to get
    // `FormBuilderHomeScreen()` directly, with NO Navigator of the module's
    // own. Every push from the module therefore landed on the bottom-nav
    // tab's Navigator — a sibling of this page's MultiBlocProvider, not a
    // child of it — so the pushed screen could not find HomeCubit,
    // CreateFormHeadCubit, FormSubmissionsCubit, ResultCubit… and painted the
    // grey error screen (Edit, Fill Out Form, Submissions, Requested, Deleted),
    // or the tap threw before navigating (Create Form, the details-page
    // buttons). Named routes such as `Routes.create` also had no router to
    // resolve against. Phones now get the same nested Navigator as tablets,
    // inside the providers, so every module screen can read its cubits.
    //
    // NavigatorPopHandler forwards the system back gesture/button to this
    // nested Navigator first, so Back leaves a module screen instead of the
    // whole tab.
    return NavigatorPopHandler(
      onPopWithResult: (_) => navigatorKey.currentState?.maybePop(),
      child: Navigator(
        key: navigatorKey,
        initialRoute: FormBuilderRouter.initialRoute,
        onGenerateRoute: FormBuilderRouter.onGenerateRoute,
      ),
    );
  }
}
