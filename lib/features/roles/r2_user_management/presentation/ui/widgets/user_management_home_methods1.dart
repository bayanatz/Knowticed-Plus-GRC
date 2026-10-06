/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: user_management_home_methods1.dart
/// Purpose: Declares `UserManagementHomeMethods1`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of '../pages/user_management_home.dart';

extension UserManagementHomeMethods1 on _UserManagementHomeState {
  /// ✅ A role chip is visible ONLY if its key resolves to a role that still
  /// exists in RoleCubit.roles.
  ///
  /// KEY INSIGHT (confirmed via logs): RoleCubit.roles already EXCLUDES
  /// deleted/inactive roles. So a key from `roleFilteredUsersPermissions` that
  /// does NOT resolve means the role was deleted/inactive → hide it (and drop
  /// its users from the count/grid).
  bool _isRoleVisible(String roleKey) {
    try {
      final RoleCubit roleCubit = context.read<RoleCubit>();

      // Roles not loaded yet → don't hide anything (avoids an empty bar flicker
      // on first frame before RoleCubit populates).
      if (roleCubit.roles.isEmpty) return true;

      final RoleHistoryModel? role = _resolveRole(roleKey);

      // Not in the active roles list → deleted / inactive / removed → hide.
      if (role == null) return false;

      // Present, but double-check its current status as a safety net.
      final String statusName = role.currentStatus.name.trim().toLowerCase();
      return !_UserManagementHomeState._hiddenRoleStatuses.contains(statusName);
    } catch (e) {
      return true; // fail open on unexpected errors
    }
  }
  List<MapEntry<String, int>> _getSortedRolesWithAll() {
    // ✅ Only roles that still exist (non-deleted/non-inactive) in RoleCubit.
    final visibleEntries = controller.roleFilteredUsersPermissions.entries
        .where((e) => _isRoleVisible(e.key))
        .toList();

    // ✅ "all" count reflects ONLY the visible roles, so the badge matches the
    // grid below.
    int totalCount = 0;
    for (final entry in visibleEntries) {
      totalCount += entry.value.length;
    }

    List<MapEntry<String, int>> sortedRoles = [
      MapEntry('all', totalCount),
    ];

    var otherRoles = visibleEntries
        .map((e) => MapEntry(e.key, e.value.length))
        .toList();

    otherRoles.sort((a, b) => b.value.compareTo(a.value));
    sortedRoles.addAll(otherRoles);

    return sortedRoles;
  }
  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }
  // REMOVED 12/8/2026: `_buildDebugPanel()` — a debug panel shipped in the
  // production UI with no call sites.
// ✅ SIMPLE: Get debug data
  Future<Map<String, dynamic>> _getDebugData() async {
    final repo = UserManagementAccessRepository();
    final companyId = _getCompanyId();


    final limits = await repo.getModuleUserLimits(companyId);

    // Get counts for all modules
    final counts = <String, int>{};
    for (final module in limits.keys) {
      counts[module] = await repo.getModuleUserCount(companyId, module);
    }

    return {
      'companyId': companyId,
      'limits': limits,
      'counts': counts,
    };
  }
// ✅ SIMPLE: Test limit check with normal strings
  Future<void> _testLimitCheck(BuildContext context) async {
    showAppDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Testing Limit Check'),
        content: FutureBuilder<String>(
          future: _runLimitTest(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Testing limit check for "super admin" role...'),
                ],
              );
            }

            if (snapshot.hasError) {
              return Text('❌ ERROR: ${snapshot.error}');
            }

            final result = snapshot.data ?? 'Unknown result';

            // Check if result contains "limit reached" or similar
            final isBlocked = result.toLowerCase().contains('limit') &&
                result.toLowerCase().contains('reached');

            if (isBlocked) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.block, color: AppColors.red, size: 50),
                  SizedBox(height: 10),
                  Text(
                    '✅ LIMIT WORKING!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Blocked with message:'),
                  Container(
                    padding: EdgeInsets.all(10),
                    color: AppColors.red,
                    child: Text(result),
                  ),
                ],
              );
            } else {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: AppColors.orange, size: 50),
                  SizedBox(height: 10),
                  Text(
                    '⚠️ LIMIT NOT BLOCKING',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.orange,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Result: $result'),
                  SizedBox(height: 10),
                  Text('Either:'),
                  Text('• No limits set'),
                  Text('• Limit not reached yet'),
                  Text('• Role has no modules'),
                ],
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
// ✅ SIMPLE: Run limit test, return string result
  Future<String> _runLimitTest() async {
    final repo = UserManagementAccessRepository();
    final companyId = _getCompanyId();

    // Call the check function and get string result
    final result = await repo.checkModuleUserLimitsSimple(
      companyId: companyId,
      roleName: 'Master Admin',  // <-- Change from 'super admin' to 'Master Admin'
    );

    return result;
  }
  String _getCompanyId() {
    String baseUri = ApiConstants.baseUri;
    if (baseUri.contains('/')) {
      return baseUri.split('/').last;
    }
    return baseUri;
  }
}
