import 'package:cloud_firestore/cloud_firestore.dart';

class CardName {
  CardName({
    this.cardName,
    this.timestamp,
  });

  CardName.fromJson(dynamic json) {
    cardName =
        json['Card_Name'] != null ? json['Card_Name'].cast<String>() : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }

  List<String>? cardName;
  List<Timestamp>? timestamp;

  CardName copyWith({
    List<String>? cardName,
    List<Timestamp>? timestamp,
  }) =>
      CardName(
        cardName: cardName ?? this.cardName,
        timestamp: timestamp ?? this.timestamp,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Card_Name'] = cardName;
    map['Timestamp'] = timestamp;
    return map;
  }
}
