import 'package:cloud_firestore/cloud_firestore.dart';

class CardImage {
  CardImage({
    this.cardImage,
    this.timestamp,
  });

  CardImage.fromJson(dynamic json) {
    cardImage =
        json['Card_Image'] != null ? json['Card_Image'].cast<String>() : [];
    timestamp =
        json['Timestamp'] != null ? json['Timestamp'].cast<Timestamp>() : [];
  }
  List<String>? cardImage;
  List<Timestamp>? timestamp;
  CardImage copyWith({
    List<String>? cardImage,
    List<Timestamp>? timestamp,
  }) =>
      CardImage(
        cardImage: cardImage ?? this.cardImage,
        timestamp: timestamp ?? this.timestamp,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Card_Image'] = cardImage;
    map['Timestamp'] = timestamp;
    return map;
  }
}
