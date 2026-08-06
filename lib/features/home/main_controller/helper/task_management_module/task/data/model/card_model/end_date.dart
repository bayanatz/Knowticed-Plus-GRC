import 'package:cloud_firestore/cloud_firestore.dart';

class EndDate {
  EndDate({
    this.endDate,
    this.timestamp,
  });

  EndDate.fromJson(dynamic json) {
    endDate = json['End_Date'] != null ? json['End_Date'].cast<String>() : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }
  List<String>? endDate;
  List<Timestamp>? timestamp;
  EndDate copyWith({
    List<String>? endDate,
    List<Timestamp>? timestamp,
  }) =>
      EndDate(
        endDate: endDate ?? this.endDate,
        timestamp: timestamp ?? this.timestamp,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['End_Date'] = endDate;
    map['Timestamp'] = timestamp;
    return map;
  }
}
