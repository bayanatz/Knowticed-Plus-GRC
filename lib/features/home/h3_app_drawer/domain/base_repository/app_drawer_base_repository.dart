/// Module: home/h3_app_drawer
///
///*************************** FILE INFO ****************************///
/// File Name: app_drawer_base_repository.dart
/// Purpose: Domain contract for drawer module-licence lookups and the user's
///          drawer order.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Which modules a company may see is business logic, so it gets a domain
/// contract rather than living as a raw Firestore call inside the cubit.
library;

abstract class AppDrawerBaseRepository {
  /// Function Name: [getCompanyLicensedModules]
  ///
  /// Purpose: Resolve which modules the given company is licensed for.
  ///
  /// Parameters:
  /// - [companyId]: Document id of the company's demo-request record.
  ///
  /// Returns: [Future<Map<String, bool>>] keyed by lowercased module name.
  ///          An **empty map means "no licence data"**, which callers treat as
  ///          "block every non-system module" — it is not the same as a map of
  ///          all-false, and it is what is returned on a read failure.
  Future<Map<String, bool>> getCompanyLicensedModules(String companyId);

  /// Function Name: [getDrawerOrder]
  ///
  /// Purpose: The user's saved drawer order (module ids), shared by all their
  ///          devices.
  ///
  /// Returns: `null` when none was saved or the read failed; empty after a
  ///          reset to the default order.
  Future<List<String>?> getDrawerOrder(String email);

  /// Function Name: [saveDrawerOrder]
  ///
  /// Purpose: Save the user's drawer order (module ids) to their account.
  ///
  /// Returns: [Future<bool>] — false when the write failed.
  Future<bool> saveDrawerOrder(String email, List<String> order);
}
