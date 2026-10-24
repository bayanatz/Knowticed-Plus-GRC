/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_template_path_test.dart
/// Purpose: Notification templates live grouped by module:
///          Demo/{companyId}/Modules/notification_templates/{module}/{event}.
/// Created At: 23/10/2026
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_template_service.dart';

void main() {
  test('a module\'s templates are one collection under notification_templates',
      () {
    ApiConstants.baseUri = 'Demo/75440689';
    expect(NotificationTemplateService.modulePath('services'),
        'Demo/75440689/Modules/notification_templates/services');
    expect(NotificationTemplateService.modulePath('time_tracker'),
        'Demo/75440689/Modules/notification_templates/time_tracker');
  });
}
