/// Module: services / sv1_home_page_services / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: home_page_services.dart
/// Purpose: Home page for services — the management view (grid/table of the
///          services + filters + export).
///          Employee/department bootstrap and Firebase draft fetching are owned
///          by HomePageServicesCubit; this page keeps the animation controller,
///          search/filter local state and orchestrates navigation.
/// Author: Amr Mesbah
/// Date: 02/07/2026
/// Dependencies: HomePageServicesCubit, ServicesManagerCubit,
///              ManagementWidget,
///              HomeServicesLoadingView, HomeServicesErrorView
/// Revision History:
///   - Initial version.
///   - 02/07/2026 (Knowticed Team): Extracted HomePageServicesCubit (fix
///     item 1a/1b) — moved employee bootstrap, department-fallback lookup,
///     provider-selection clearing, startApp persistence and Firebase-draft
///     fetching (6 of 9 try/catch blocks) out of the page. The remaining 3
///     try/catches live inside _applyFilters()'s BuildContext-dependent
///     department-reload fallback — kept on the page (see cubit file header
///     for rationale). Extracted loading/error views into ui/widgets/ (fix
///     item 1c). Deleted dead commented-out //print banner lines (fix
///     item 1d). Replaced several inline TextStyle literals with
///     StyleText getters (fix item 7b).
///   - 02/07/2026 (Knowticed Team, fix item 10): Audited remaining
///     `package:get/get.dart` usage in this file — only
///     AppControllers.employee remains (2 call sites). Kept
///     intentionally: MainCoreEmployeeController/MainCoreDepartmentCubit
///     are registered as GetX singletons app-wide with no Provider/BlocProvider
///     equivalent anywhere in the codebase (verified via grep), so removing
///     Get.find here would break employee/department lookups. No other GetX
///     APIs (Get.to, Get.off, GetBuilder, GetX widget) are used in this file.
library;

import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/widgets/management_widget.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/widgets/request_services_button.dart'
    show approvalAndServicesRequest;

import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/widgets/home_services_loading_view.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/widgets/home_services_error_view.dart';

import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/widgets/home_services_duration_utils.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/widgets/home_services_status_filter.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/widgets/home_services_visibility_filter.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/controller/home_page_services_cubit.dart';

import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/services/helpers/service_visibility_keys.dart';

part 'home_page_services_part2.dart';

class ServicesScreenTablet extends StatefulWidget {
  const ServicesScreenTablet({super.key});

  @override
  State<ServicesScreenTablet> createState() => _ServicesScreenTabletState();
}
