// 21/10/2026 (Moataz): the same value in another form is not a change.
import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/presentation/ui/pages/edit_page_request_health.dart';

void main() {
  test('case and outer spaces do not count', () {
    expect(HealthValueCompare.same('firstContact_relationship', 'spouse', ' Spouse '), isTrue);
  });

  test('a stored number without +code equals the same number with +20', () {
    expect(HealthValueCompare.same('firstContact_phone', '1059081935', '+20 1059081935'), isTrue);
  });

  test('a different number or another country code is a change', () {
    expect(HealthValueCompare.same('firstContact_phone', '1059081935', '+20 1059081936'), isFalse);
    expect(HealthValueCompare.same('firstContact_phone', '1059081935', '+965 1059081935'), isFalse);
  });

  test('a different text is a change', () {
    expect(HealthValueCompare.same('insuranceName', 'Silver', 'Gold'), isFalse);
  });
}
