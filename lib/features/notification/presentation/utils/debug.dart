import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/notification/notification_permissions.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/notification/notification_permissions_sections.dart';

/// DEBUG WIDGET - Add this to your notification control page temporarily
/// to see exactly what the permission checker is doing
class DebugPermissionChecker extends StatelessWidget {
  const DebugPermissionChecker({super.key});

  void _debugPermissionCheck(BuildContext context) {
    print('');
    print('╔══════════════════════════════════════════════════════════╗');
    print('║           DEEP PERMISSION DEBUG CHECK                   ║');
    print('╚══════════════════════════════════════════════════════════╝');

    try {
      final controller = Get.find<MainCoreEmployeeController>();
      print('✅ Controller found');

      // Try to access the controller's internal state
      print('');
      print('📋 Controller State:');
      print('   └─ Controller type: ${controller.runtimeType}');

      // Check if we can see any permission-related properties
      // You might need to adjust these based on your actual controller structure
      print('');
      print('🔍 Attempting to inspect controller internals...');

      // Test the actual permission check
      print('');
      print('🧪 Testing Services Permission Check:');
      print('   Module: ${Modules.notification}');
      print('   Section: ${NotificationPermissionsSections.notificationModule}');
      print('   Permission: ${NotificationPermissions.showServicesNotifications}');
      print('   Database name: ${NotificationPermissions.showServicesNotifications.getDataBaseName}');

      final result = controller.isHasPermission(
        module: Modules.notification,
        section: NotificationPermissionsSections.notificationModule,
        permission: NotificationPermissions.showServicesNotifications,
      );

      print('   Result: $result');
      print('');

      // Try to understand how the method constructs the check
      print('🔍 Understanding the permission path:');
      print('   1. Module name: ${Modules.notification.toString()}');
      print('   2. Section name: ${NotificationPermissionsSections.notificationModule.toString()}');
      print('   3. Permission name: ${NotificationPermissions.showServicesNotifications.toString()}');
      print('   4. Database name: ${NotificationPermissions.showServicesNotifications.getDataBaseName}');

      // Check other permissions too
      print('');
      print('🧪 Testing ALL Notification Permissions:');
      for (var perm in NotificationPermissions.values) {
        final testResult = controller.isHasPermission(
          module: Modules.notification,
          section: NotificationPermissionsSections.notificationModule,
          permission: perm,
        );
        print('   ${perm.getDataBaseName}: $testResult');
      }

    } catch (e, stackTrace) {
      print('❌ ERROR: $e');
      print('Stack trace:');
      print(stackTrace);
    }

    print('╚══════════════════════════════════════════════════════════╝');
    print('');
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _debugPermissionCheck(context),
      child: Text('DEBUG PERMISSIONS'),
    );
  }
}


/// INSTRUCTIONS TO USE:
///
/// Add this widget temporarily to your notification control page:
///
/// In the build method, add somewhere visible:
///
/// if (kDebugMode)  // Only show in debug mode
///   DebugPermissionChecker(),
///
/// Then tap the button to see detailed permission checking info