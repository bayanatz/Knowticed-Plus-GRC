// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/enums/enum.dart';

class ChampionFirestore {
  List<Timestamp> timeStamp;
  List<String> moduleId;
  List<String> controlChampion;
  List<String> controls;
  List<String> policies;
  List<String> championStatus;
  List<String> startDate;
  List<String> endDate;

  ChampionFirestore({
    required this.timeStamp,
    required this.moduleId,
    required this.controlChampion,
    required this.controls,
    required this.policies,
    required this.championStatus,
    required this.startDate,
    required this.endDate,
  });

  ChampionFirestore copyWith({
    List<Timestamp>? timeStamp,
    List<String>? moduleId,
    List<String>? controlChampion,
    List<String>? controls,
    List<String>? policies,
    List<String>? championStatus,
    List<String>? startDate,
    List<String>? endDate,
  }) {
    return ChampionFirestore(
      timeStamp: timeStamp ?? this.timeStamp,
      moduleId: moduleId ?? this.moduleId,
      controlChampion: controlChampion ?? this.controlChampion,
      controls: controls ?? this.controls,
      championStatus: championStatus ?? this.championStatus,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      policies: policies ?? this.policies,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'timeStamp': timeStamp,
      'moduleId': moduleId,
      'controlChampion': controlChampion,
      'controls': controls,
      'policies': policies,
      'championStatus': championStatus,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  factory ChampionFirestore.fromMap(Map<String, dynamic> map) {
    return ChampionFirestore(
      timeStamp: (map['timeStamp'] as List<dynamic>)
          .map((e) => e as Timestamp)
          .toList(),
      moduleId:
          (map['moduleId'] as List<dynamic>).map((e) => e as String).toList(),
      controlChampion: (map['controlChampion'] as List<dynamic>)
          .map((e) => capitalize(e as String))
          .toList(),
      policies: (map['policies'] as List<dynamic>)
          .map((e) => capitalize(e as String))
          .toList(),
      controls: (map['controls'] as List<dynamic>)
          .map((e) => capitalize(e as String))
          .toList(),
      championStatus: (map['championStatus'] as List<dynamic>)
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

  factory ChampionFirestore.fromJson(String source) =>
      ChampionFirestore.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChampionFirestore(timeStamp: $timeStamp, moduleId: $moduleId, controlChampion: $controlChampion, controls: $controls, championStatus: $championStatus, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(covariant ChampionFirestore other) {
    if (identical(this, other)) return true;

    return listEquals(other.timeStamp, timeStamp) &&
        listEquals(other.moduleId, moduleId) &&
        listEquals(other.controlChampion, controlChampion) &&
        listEquals(other.controls, controls) &&
        listEquals(other.championStatus, championStatus) &&
        listEquals(other.startDate, startDate) &&
        listEquals(other.endDate, endDate);
  }

  @override
  int get hashCode {
    return timeStamp.hashCode ^
        moduleId.hashCode ^
        controlChampion.hashCode ^
        controls.hashCode ^
        championStatus.hashCode ^
        startDate.hashCode ^
        endDate.hashCode;
  }
}
