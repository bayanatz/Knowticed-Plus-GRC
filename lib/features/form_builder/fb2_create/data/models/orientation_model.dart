/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: orientation_model.dart
/// Description: `OrientationModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrientationModel {
  List<String?>? orientation;

  OrientationModel({
    this.orientation,
  });

  OrientationModel copyWith({
    List<String?>? orientation,
    List<Timestamp?>? timestamps,
  }) {
    return OrientationModel(
      orientation: orientation ?? this.orientation,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Orientation': orientation,
    };
  }

  factory OrientationModel.fromMap(Map<String, dynamic> map) {
    return OrientationModel(
      orientation: map['Orientation'] != null
          ? List<String?>.from(
              (map['Orientation']),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrientationModel.fromJson(String source) =>
      OrientationModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
