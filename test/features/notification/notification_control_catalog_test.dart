// Notification Control — every notification the admin controls (owner
// 22/10/2026: "did you test all of these notifications?").
//
// For EVERY event in NotificationCatalog:
//  - the default EN and AR title/body exist;
//  - every {{variable}} in them is one the sender fills (the event's own
//    variables or NotificationAutoVariables) — otherwise it arrives raw;
//  - EN and AR use the same variables;
//  - the default push text fits the 150 limit;
//  - it sits in a titled section with an Arabic title;
//  - its module has a tab in Notification Control;
//  - its key is unique in its module.
import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_model.dart';
import 'package:knowticed_plus/features/notification/domain/enums/notification_catalog.dart';
import 'package:knowticed_plus/features/notification/domain/enums/notification_event.dart';
import 'package:knowticed_plus/features/notification/helpers/services/notification_auto_variables.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/notification_control.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_sections_list.dart';

/// Same fields as NotificationTemplateService.templateFromEvent (which needs
/// Firebase to construct the service).
NotificationTemplateModel _template(NotificationEvent e) =>
    NotificationTemplateModel(
      id: e.templateId,
      module: e.module.key,
      eventType: e.key,
      isEnabled: true,
      selectedNotificationTypes: const <String>['email', 'push'],
      subjectEnglish: e.titleEn,
      subjectArabic: e.titleAr,
      bodyEnglish: e.bodyEn,
      bodyArabic: e.bodyAr,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

Set<String> _tokens(String text) =>
    RegExp(r'\{\{(\w+)\}\}').allMatches(text).map((m) => m.group(1)!).toSet();

void main() {
  final List<NotificationEvent> events = NotificationCatalog.allEvents;
  final Set<String> auto =
      NotificationAutoVariables.all.map((TemplateVariable v) => v.key).toSet();

  test('the catalog is not empty', () {
    expect(events.length, greaterThan(200));
  });

  for (final module in NotificationCatalog.modules) {
    final List<NotificationEvent> list = NotificationCatalog.eventsOf(module);

    group(module.key, () {
      test('has a tab in Notification Control', () {
        expect(NotificationTab.forModule(module), isNotNull);
      });

      test('event keys are unique', () {
        final List<String> keys = list.map((e) => e.key).toList();
        expect(keys.toSet().length, keys.length);
      });

      for (final NotificationEvent e in list) {
        group(e.key, () {
          test('default EN/AR text exists', () {
            final NotificationTemplateModel t =
                _template(e);
            expect(t.subjectEnglish.trim(), isNotEmpty);
            expect(t.subjectArabic.trim(), isNotEmpty);
            expect(t.bodyEnglish.trim(), isNotEmpty);
            expect(t.bodyArabic.trim(), isNotEmpty);
          });

          test('every {{variable}} is filled when sending', () {
            final Set<String> allowed = <String>{
              ...e.variables.map((TemplateVariable v) => v.key),
              ...auto,
            };
            for (final String text in <String>[
              e.titleEn,
              e.titleAr,
              e.bodyEn,
              e.bodyAr,
            ]) {
              expect(_tokens(text).difference(allowed), isEmpty, reason: text);
            }
          });

          test('EN and AR use the same variables', () {
            expect(
              _tokens(e.titleAr + e.bodyAr),
              _tokens(e.titleEn + e.bodyEn),
            );
          });

          test('default push text fits 150', () {
            final NotificationTemplateModel t =
                _template(e);
            expect(t.pushBodyEn.length, lessThanOrEqualTo(150));
            expect(t.pushBodyAr.length, lessThanOrEqualTo(150));
          });

          test('is in a section with an Arabic title', () {
            expect(e.group, isNotEmpty);
            expect(notificationGroupLabel(e.group, isArabic: true),
                isNot(e.group));
          });
        });
      }
    });
  }
}
