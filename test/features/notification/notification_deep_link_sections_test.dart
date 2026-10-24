/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_deep_link_sections_test.dart
/// Purpose: Form Builder submissions → Submissions tab; GRC task
///          notifications → Action Center (Owner, 22/10/2026).
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/form_builder/presentation/navigation/form_builder_shortcut.dart';
import 'package:knowticed_plus/features/notification/domain/enums/form_builder/form_builder_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/grc/grc_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/routing/notification_deep_link.dart';

NotificationDeepLink _link(Modules m, String key, String page) =>
    NotificationDeepLink.resolve(module: m, moduleKey: key, pageKey: page);

void main() {
  test('a Form Builder submission opens the Submissions tab', () {
    expect(
        _link(Modules.formBuilder, 'form_builder',
                FormBuilderNotificationPage.resultScreen.key)
            .formBuilderTab,
        FormBuilderShortcut.submissions);
    expect(
        _link(Modules.formBuilder, 'form_builder',
                FormBuilderNotificationPage.formDetailsScreen.key)
            .formBuilderTab,
        isNull);
  });

  test('GRC task notifications open the Action Center', () {
    for (final GrcNotificationPage p in <GrcNotificationPage>[
      GrcNotificationPage.grcAssignmentControls,
      GrcNotificationPage.grcApprovals,
      GrcNotificationPage.grcControlOwnerDetails,
    ]) {
      expect(_link(Modules.grc, 'grc', p.key).grcActionCenter, isTrue,
          reason: p.key);
    }
    expect(
        _link(Modules.grc, 'grc', GrcNotificationPage.grcModuleDetails.key)
            .grcActionCenter,
        isFalse);
  });
}
