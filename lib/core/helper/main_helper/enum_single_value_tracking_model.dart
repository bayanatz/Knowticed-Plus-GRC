///********************* FILE INFO ********************///
/// File Name: enum_single_value_tracking_model.dart
/// Purpose: Contains the model for tracking a enum single value over time.
/// Author: Amr Mesbah
/// Created At: 1/1/2025
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/company_size_list.dart';
import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/industry.dart';


class EnumSingleValueTrackingModel<T> {
  List<T> values;
  List<Timestamp> timestamps;

  EnumSingleValueTrackingModel({
    required this.values,
    required this.timestamps,
  });

  static const String VALUES = 'Values';
  static const String TIMESTAMPS = 'Timestamps';

  Map<String, dynamic> toMap() {
    return {
      VALUES: values.map((e) => (e as Enum).name).toList(),
      TIMESTAMPS: timestamps,
    };
  }

  factory EnumSingleValueTrackingModel.fromMap(Map<String, dynamic> map) {
    List<T> _getValuesFromMap(Map<String, dynamic> map) {
      List<T> values = [];
      List<String> valuesString = List<String>.from(map[VALUES]);
      for (var value in valuesString) {
        if (T == Industry) {
          values.add(Industry.values.firstWhere((element) => element.name == value) as T);
        } else if (T == CompanySize) {
          values.add(CompanySize.values.firstWhere((element) => element.name == value) as T);
        }
      }
      return values;
    }

    return EnumSingleValueTrackingModel(
      values: _getValuesFromMap(map),
      timestamps: List<Timestamp>.from(map[TIMESTAMPS]),
    );

  }

}
