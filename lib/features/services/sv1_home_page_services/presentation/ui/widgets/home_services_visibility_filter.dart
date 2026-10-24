/// Module: services / sv1_home_page_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: home_services_visibility_filter.dart
/// Purpose: Pure visibility/filtering logic for the home services page: decides
///          whether the current employee can see a given service (drafts are
///          creator-only, admins see everything, department-limited services
///          check the allowed-department list), applies the
///          name/visibility/department-chip filter, processes a service's
///          allowed-department list, and builds the sorted department-count map
///          used by the chip filter.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: EmployeeEntityPro, ServicesHistoryModel
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Extracted from home_page_services.dart
///     (fix item 1c — build-method/class-size decomposition).
///   - 02/07/2026 (Knowticed Team): Added getFilteredServices — moved from
///     home_page_services.dart's _getFilteredServices() to bring the page
///     back under the 800-LOC target after the item-10 GetX-audit header
///     additions pushed it over.
library;

import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/domain/enums/service_display_status.dart';
import 'package:knowticed_plus/features/services/data/utils/service_department_access.dart';
import 'package:knowticed_plus/features/services/helpers/services_module_access.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/widgets/home_services_department_utils.dart';

class HomeServicesVisibilityFilter {
  const HomeServicesVisibilityFilter._();

  /// How a service should be classified for the Active / Inactive / Draft
  /// chips. Shared so the row filter and the chip COUNTS
  /// (`HomeServicesStatusFilter`) cannot drift apart — they did, and a draft
  /// ended up counted under Active by one and under nothing by the other.
  static ServiceDisplayStatus displayStatusOf(ServicesHistoryModel service) =>
      ServiceDisplayStatus.of(
        state: service.currentState,
        status: service.currentStatus,
      );

  /// Whether [employeeEntity] is allowed to see [service]. Draft services
  /// are only visible to their creator; people who manage services (the real
  /// Services permissions, not a role name containing "admin") see all
  /// non-draft services; department-limited services compare DEPARTMENT IDS
  /// (SVC-HOME-01) — [departmentNameToId] turns a stored department name into
  /// its id with an exact lookup.
  static bool canUserSeeService({
    required EmployeeEntityPro? employeeEntity,
    required ServicesHistoryModel service,
    required String? Function(String departmentName) departmentNameToId,
  }) {
    if (employeeEntity == null) {
      return false;
    }

    final currentUserEmail = (employeeEntity.email ?? '').toLowerCase().trim();
    final serviceEmail = (service.currentEmailRequester).toLowerCase().trim();

    final state = service.currentState.toLowerCase().trim();
    final isDraft = state == 'draft';
    final isCreator = serviceEmail == currentUserEmail;

    // Draft services — only creator can see their own drafts
    if (isDraft) {
      return isCreator;
    }

    // SVC-HOME-01: was `role.contains("admin")`, which also matched roles
    // such as "Administrative Assistant".
    if (managesServices) {
      return true;
    }

    // Non-draft services: check visibility rules
    if (!service.currentLimitAvailability) {
      return true;
    }

    // The creator can always see their own service.
    if (isCreator) return true;

    return ServiceDepartmentAccess.isAllowed(
      allowedDepartments: service.currentSelectDepartment,
      userDepartmentId: employeeEntity.departmentId,
      nameToId: departmentNameToId,
    );
  }

  /// People allowed to manage services see every non-draft service.
  static bool get managesServices =>
      ServicesModuleAccess.canEditService ||
      ServicesModuleAccess.canChangeServiceStatus ||
      ServicesModuleAccess.canDeleteService;

  /// Applies the name/visibility/department-chip filter to [services].
  static List<ServicesHistoryModel> applyAllFilters({
    required List<ServicesHistoryModel> services,
    required String query,
    required String selectedKeyCanonical,
    required EmployeeEntityPro? employeeEntity,
    required String? Function(String departmentName) departmentNameToId,
  }) {
    final filteredList = <ServicesHistoryModel>[];

    for (final service in services) {
      final nameEn = service.currentServiceNameEnglish.toLowerCase();
      final nameAr = service.currentServiceNameArabic.toLowerCase();
      final matchesName =
          query.isEmpty || nameEn.contains(query) || nameAr.contains(query);

      final passesVisibility = canUserSeeService(
        employeeEntity: employeeEntity,
        service: service,
        departmentNameToId: departmentNameToId,
      );

      final serviceDeptCanonical = HomeServicesDepartmentUtils.normalize(
        service.currentDepartmentRequester,
      );

      // For "All", show all visible services (including user's drafts).
      // For specific departments, exclude drafts since they're personal.
      bool matchesDeptChip;
      if (selectedKeyCanonical == "All") {
        matchesDeptChip = true;
      } else {
        final isDraft = service.currentState.toLowerCase().trim() == 'draft';
        matchesDeptChip =
            !isDraft && (serviceDeptCanonical == selectedKeyCanonical);
      }

      if (matchesName && passesVisibility && matchesDeptChip) {
        filteredList.add(service);
      }
    }

    return filteredList;
  }

  /// Builds a department -> count map sorted by count descending.
  static Map<String, int> createSortedDepartmentMap(
    Map<String, int> unsortedMap,
  ) {
    final sortedEntries = unsortedMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sortedMap = <String, int>{};
    for (final entry in sortedEntries) {
      sortedMap[entry.key] = entry.value;
    }
    return sortedMap;
  }

  /// Filters [allServices] down to the current user's own services matching
  /// [searchQuery] (by service name, either language) and [selectedStatusIndex]
  /// (0=All, 1=Active, 2=Inactive, 3=Draft). Used by the "request services"
  /// (non-admin) view's own-services list.
  static List<ServicesHistoryModel> getFilteredServices({
    required List<ServicesHistoryModel> allServices,
    required String searchQuery,
    required String currentUserEmail,
    required int selectedStatusIndex,
  }) {
    final query = searchQuery.toLowerCase();
    final email = currentUserEmail.toLowerCase().trim();

    var userServices = allServices.where((service) {
      final serviceEmail = (service.currentEmailRequester).toLowerCase().trim();
      return serviceEmail == email;
    }).toList();

    if (query.isNotEmpty) {
      userServices = userServices.where((item) {
        final serviceNameEn = (item.currentServiceNameEnglish).toLowerCase();
        final serviceNameAr = (item.currentServiceNameArabic).toLowerCase();
        return serviceNameEn.contains(query) || serviceNameAr.contains(query);
      }).toList();
    }

    // Use English key directly from index
    String selectedKey;
    switch (selectedStatusIndex) {
      case 0:
        selectedKey = "All";
        break;
      case 1:
        selectedKey = "Active";
        break;
      case 2:
        selectedKey = "Inactive";
        break;
      case 3:
        selectedKey = "Draft";
        break;
      default:
        selectedKey = "All";
    }

    // ✅ FIX 26/8/2026 — the Active and Inactive branches read `currentStatus`
    // ALONE, with no draft exclusion. A draft stores the availability it is
    // destined for once published, and that is 'active' by default, so every
    // saved draft matched the Active filter and appeared alongside real
    // services. The Draft branch was already right — which is what made the
    // bug so odd to look at: the same service showed up under Active AND under
    // Draft.
    //
    // All three now go through one classifier that sees both fields.
    // See [ServiceDisplayStatus.of].
    if (selectedKey == "Active") {
      userServices = userServices
          .where(
            (service) =>
                displayStatusOf(service) == ServiceDisplayStatus.active,
          )
          .toList();
    } else if (selectedKey == "Inactive") {
      userServices = userServices
          .where(
            (service) =>
                displayStatusOf(service) == ServiceDisplayStatus.inactive,
          )
          .toList();
    } else if (selectedKey == "Draft") {
      userServices = userServices
          .where(
            (service) => displayStatusOf(service) == ServiceDisplayStatus.draft,
          )
          .toList();
    }

    return userServices;
  }
}
