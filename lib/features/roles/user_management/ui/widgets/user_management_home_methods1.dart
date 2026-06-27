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
// ✅ DEBUG PANEL - Shows live limit status
  // ✅ SIMPLE DEBUG PANEL - No Either, no Failure
  Widget _buildDebugPanel() {
    return Container(
      margin: EdgeInsets.all(10.sp),
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        border: Border.all(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: Colors.red),
              SizedBox(width: 10.w),
              Text(
                '🐛 DEBUG PANEL - Module Limits',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: Colors.red.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Live data display
          FutureBuilder<Map<String, dynamic>>(
            future: _getDebugData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('Loading...', style: TextStyle(color: Colors.orange));
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red));
              }

              final data = snapshot.data ?? {};
              final limits = data['limits'] as Map<String, int>? ?? {};
              final counts = data['counts'] as Map<String, int>? ?? {};
              final companyId = data['companyId'] as String? ?? 'unknown';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Company ID: $companyId',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),

                  // Limits table
                  Container(
                    padding: EdgeInsets.all(8.sp),
                    color: Colors.white,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text('Module', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(child: Text('Limit', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(child: Text('Current', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                        Divider(),
                        ...limits.entries.map((entry) {
                          final module = entry.key;
                          final limit = entry.value;
                          final count = counts[module] ?? 0;
                          final remaining = limit - count;
                          final isFull = count >= limit;

                          return Row(
                            children: [
                              Expanded(child: Text(module)),
                              Expanded(child: Text('$limit')),
                              Expanded(child: Text('$count')),
                              Expanded(
                                child: Text(
                                  isFull ? '🔴 FULL' : '🟢 $remaining left',
                                  style: TextStyle(
                                    color: isFull ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),

                        if (limits.isEmpty)
                          Text('⚠️ NO LIMITS SET', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Test buttons
                  Wrap(
                    spacing: 10.w,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _testLimitCheck(context),
                        icon: Icon(Icons.play_arrow),
                        label: Text('TEST LIMIT CHECK'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => setState(() {}),
                        icon: Icon(Icons.refresh),
                        label: Text('REFRESH'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
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
    showDialog(
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
                  Icon(Icons.block, color: Colors.red, size: 50),
                  SizedBox(height: 10),
                  Text(
                    '✅ LIMIT WORKING!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Blocked with message:'),
                  Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.red.shade100,
                    child: Text(result),
                  ),
                ],
              );
            } else {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.orange, size: 50),
                  SizedBox(height: 10),
                  Text(
                    '⚠️ LIMIT NOT BLOCKING',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
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
