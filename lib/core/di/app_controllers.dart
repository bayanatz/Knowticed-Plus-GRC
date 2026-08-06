// ******************* FILE INFO *******************
// File Name: app_controllers.dart
// Description: Single dependency-injection seam over the GetX service locator
//              for the app-wide controllers the services module depends on.
//              Centralising `Get.find<...>()` here means the eventual GetX
//              removal is a one-file change instead of touching ~160 call
//              sites. Call sites use `AppControllers.employee` /
//              `AppControllers.employee` and never reference GetX directly.
// Module: core / di
// *************************************************

import 'package:get/get.dart';

import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:grc_module/features/settings/se3_company/presentation/controller/company_cubit.dart';

/// Resolves the shared "MainCore" controllers.
///
/// This is the ONLY place in the services module that should call
/// `Get.find` for these controllers. To drop GetX later, swap the two getter
/// bodies to your new DI container (e.g. `getIt<...>()`) — nothing else changes.
class AppControllers {
  const AppControllers._();

  static MainCoreEmployeeController get employee =>
      Get.find<MainCoreEmployeeController>();

  /// The app-wide company branding/info cubit, created and owned by main().
  ///
  /// Widgets should NOT use this — they get the cubit from the root
  /// BlocProvider via `context.read<CompanyCubit>()` / BlocBuilder. This seam
  /// exists only for the two non-widget leaves that have no context and no
  /// caller able to pass one down: RoleRepository.isCompanyAdminByEmail and
  /// UserManagementCubit's company-email lookup.
  static CompanyCubit get company => Get.find<CompanyCubit>();
}
