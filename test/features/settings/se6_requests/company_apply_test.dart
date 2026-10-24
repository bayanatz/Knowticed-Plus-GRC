// 21/10/2026 (Moataz): an approved Company Information request appends to
// the COMPANY document.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/data_source/remote_data_source/requests_remote_data_source.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';

void main() {
  final Timestamp t0 = Timestamp.fromMillisecondsSinceEpoch(0);
  final Timestamp now = Timestamp.fromMillisecondsSinceEpoch(1000);

  test('appends the new value and a timestamp to the company field', () {
    final r = RequestsRemoteDataSource.applyChangesToCompany(
      <String, dynamic>{
        'Company_Name': <String, dynamic>{
          'Company_Name': <String>['Bayanatz'],
          'Timestamp': <Timestamp>[t0],
        },
      },
      const <FieldChange>[
        FieldChange(fieldName: 'companyName', oldValue: 'Bayanatz', newValue: 'Bayanatz Ltd'),
        FieldChange(fieldName: 'address', oldValue: '', newValue: 'Madinty B12'),
      ],
      now,
    );
    expect(r.skipped, isEmpty);
    expect(r.update['Company_Name']['Company_Name'], <String>['Bayanatz', 'Bayanatz Ltd']);
    expect(r.update['Company_Name']['Timestamp'], <Timestamp>[t0, now]);
    expect(r.update['Company_Address']['Address'], <String>['Madinty B12']);
  });

  test('an unknown field is skipped, not written', () {
    final r = RequestsRemoteDataSource.applyChangesToCompany(
      <String, dynamic>{},
      const <FieldChange>[FieldChange(fieldName: 'logo', newValue: 'x')],
      now,
    );
    expect(r.skipped, <String>['logo']);
    expect(r.update, isEmpty);
  });
}
