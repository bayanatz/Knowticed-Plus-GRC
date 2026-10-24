/// Module: home/h3_app_drawer
///
///*************************** FILE INFO ****************************///
/// File Name: drawer_order_keys_test.dart
/// Purpose: `Drawer_Order` stores the standard module keys (time_tracker,
///          knowledge_hub …), one per module, never the enum names.
/// Created At: 22/10/2026
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/data/utils/app_drawer_constant_modules.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';

void main() {
  test('drawer modules are saved with the standard module keys', () {
    expect(AppDrawerCubit.orderKey(Modules.timeTracker), 'time_tracker');
    expect(AppDrawerCubit.orderKey(Modules.knowledgeHub), 'knowledge_hub');
    expect(AppDrawerCubit.orderKey(Modules.formBuilder), 'form_builder');
    expect(AppDrawerCubit.orderKey(Modules.roles), 'role_management');
    expect(AppDrawerCubit.orderKey(Modules.todo), 'todo');
    expect(AppDrawerCubit.orderKey(Modules.hr), 'hr');
  });

  test('every drawer module has its own lower-case key', () {
    final List<String> keys = AppDrawerConstantModules.drawerModules
        .map(AppDrawerCubit.orderKey)
        .toList();
    expect(keys.toSet().length, keys.length);
    for (final String key in keys) {
      expect(key, matches(RegExp(r'^[a-z_]+$')));
    }
  });
}
