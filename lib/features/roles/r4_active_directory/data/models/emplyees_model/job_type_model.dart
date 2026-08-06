import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class JobType {
  List<String?>? jobType;
  List<Timestamp?>? timestamps;
  JobType({
    this.jobType,
    this.timestamps,
  });

  JobType copyWith({
    List<String?>? jobType,
    List<Timestamp?>? timestamps,
  }) {
    return JobType(
      jobType: jobType ?? this.jobType,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Job_Type': jobType,
      'Timestamp': timestamps,
    };
  }

  factory JobType.fromMap(Map<String, dynamic> map) {
    return JobType(
      jobType: map['Job_Type'] != null
          ? List<String?>.from(
              (map['Job_Type']),
            )
          : null,
      timestamps: map['Timestamp'] != null
          ? List<Timestamp?>.from(
              (map['Timestamp']),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory JobType.fromJson(String source) =>
      JobType.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'JobType(Job_Type: $jobType, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant JobType other) {
    if (identical(this, other)) return true;

    return listEquals(other.jobType, jobType) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => jobType.hashCode ^ timestamps.hashCode;
}
