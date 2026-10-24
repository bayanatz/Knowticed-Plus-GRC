// 21/10/2026 (Moataz): "Send Reminder" — once per 24 hours per request.
import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';

void main() {
  final DateTime now = DateTime(2026, 10, 21, 17, 0);

  test('never sent → allowed', () {
    expect(const ChangeRequest().canSendReminderAt(now), isTrue);
  });

  test('sent 23 hours ago → refused', () {
    final ChangeRequest r = ChangeRequest(
        lastReminderAt: now.subtract(const Duration(hours: 23)));
    expect(r.canSendReminderAt(now), isFalse);
  });

  test('sent exactly 24 hours ago → allowed', () {
    final ChangeRequest r = ChangeRequest(
        lastReminderAt: now.subtract(const Duration(hours: 24)));
    expect(r.canSendReminderAt(now), isTrue);
  });
}
