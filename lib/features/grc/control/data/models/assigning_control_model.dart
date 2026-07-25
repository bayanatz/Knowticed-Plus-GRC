import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:intl/intl.dart';

final DateFormat _assigningControlDateFormat = DateFormat('d MMM yyyy', 'en');

class AssigningControlModel {
  final String policyId;
  final String controlId;
  final DateTime? expiresOn;

  const AssigningControlModel({
    required this.policyId,
    required this.controlId,
    this.expiresOn,
  });

  Map<String, dynamic> toJson() {
    return {
      'Policy_ID': policyId,
      'Control_ID': controlId,
      'Expires_On':
          expiresOn != null ? _assigningControlDateFormat.format(expiresOn!) : null,
    };
  }

  factory AssigningControlModel.fromJson(Map<String, dynamic> json) {
    final expiresOnRaw = json['Expires_On'] as String?;
    return AssigningControlModel(
      policyId: json['Policy_ID'] as String,
      controlId: json['Control_ID'] as String,
      expiresOn:
          expiresOnRaw != null ? _assigningControlDateFormat.parse(expiresOnRaw) : null,
    );
  }

  AssigningControlEntity toEntity() {
    return AssigningControlEntity(
      policyId: policyId,
      controlId: controlId,
      expiresOn: expiresOn,
    );
  }
}
