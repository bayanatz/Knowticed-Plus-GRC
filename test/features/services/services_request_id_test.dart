import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/services/data/helper/services_request_id.dart';

void main() {
  test('format pads the number to 4 digits', () {
    expect(ServicesRequestId.format(2026, 7), 'REQ-2026-0007');
    expect(ServicesRequestId.format(2026, 12345), 'REQ-2026-12345');
  });

  test('nextNumber continues the same year and restarts on a new year', () {
    expect(ServicesRequestId.nextNumber(null, 2026), 1);
    expect(ServicesRequestId.nextNumber({'year': 2026, 'last': 41}, 2026), 42);
    expect(ServicesRequestId.nextNumber({'year': 2025, 'last': 900}, 2026), 1);
  });
}
