// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/enums/enum.dart';

class ControlOwnerFirestore {
  List<String> moduleId;
  List<Timestamp> timeStamp;
  List<String> controlOwner;
  List<String> controls;
  List<String> policies;
  List<String> status;
  List<String> startDate;
  List<String> endDate;

  ControlOwnerFirestore(
      {required this.moduleId,
      required this.timeStamp,
      required this.controlOwner,
      required this.controls,
      required this.policies,
      required this.status,
      required this.startDate,
      required this.endDate});

  ControlOwnerFirestore copyWith(
      {List<String>? id,
      List<Timestamp>? timeStamp,
      List<String>? controlOwner,
      List<String>? controls,
      List<String>? policies,
      List<String>? status,
      List<String>? startDate,
      List<String>? endDate}) {
    return ControlOwnerFirestore(
        moduleId: id ?? moduleId,
        timeStamp: timeStamp ?? this.timeStamp,
        controlOwner: controlOwner ?? this.controlOwner,
        controls: controls ?? this.controls,
        policies: policies ?? this.policies,
        status: status ?? this.status,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'moduleId': moduleId,
      'timeStamp': timeStamp,
      'controlOwner': controlOwner,
      'controls': controls,
      'policies': policies,
      'status': status,
      'startDate': startDate,
      'endDate': endDate
    };
  }

  factory ControlOwnerFirestore.fromMap(Map<String, dynamic> map) {
    return ControlOwnerFirestore(
      moduleId:
          (map['moduleId'] as List<dynamic>).map((e) => e as String).toList(),
      timeStamp: (map['timeStamp'] as List<dynamic>)
          .map((e) => e as Timestamp)
          .toList(),
      controlOwner: (map['controlOwner'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      controls: (map['controls'] as List<dynamic>)
          .map((e) => capitalize(e as String))
          .toList(),
      policies: (map['policies'] as List<dynamic>)
          .map((e) => capitalize(e as String))
          .toList(),
      status: (map['status'] as List<dynamic>)
          .map((e) => capitalize(e as String))
          .toList(),
      startDate: (map['startDate'] as List<dynamic>)
          .map((e) => capitalize(e as String))
          .toList(),
      endDate: (map['endDate'] as List<dynamic>)
          .map((e) => capitalize(e as String))
          .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ControlOwnerFirestore.fromJson(String source) =>
      ControlOwnerFirestore.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ControlOwner(id: $moduleId, timeStamp: $timeStamp, controlOwner: $controlOwner, controls: $controls,status: $status, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(covariant ControlOwnerFirestore other) {
    if (identical(this, other)) return true;

    return listEquals(other.moduleId, moduleId) &&
        listEquals(other.timeStamp, timeStamp) &&
        listEquals(other.controlOwner, controlOwner) &&
        listEquals(other.controls, controls) &&
        listEquals(other.status, status) &&
        listEquals(other.startDate, startDate) &&
        listEquals(other.endDate, endDate);
  }

  @override
  int get hashCode {
    return moduleId.hashCode ^
        timeStamp.hashCode ^
        controlOwner.hashCode ^
        controls.hashCode ^
        status.hashCode ^
        startDate.hashCode ^
        endDate.hashCode;
  }
}
