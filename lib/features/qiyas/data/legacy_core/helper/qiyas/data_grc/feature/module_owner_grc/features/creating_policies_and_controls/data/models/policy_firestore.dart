// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PolicyFirestore {
  List<String> id;
  List<Timestamp> timeStamp;
  List<String> image;
  List<String> name;
  List<String> nameArabic;
  List<String> description;
  List<String> descriptionArabic;
  List<String> number;
  List<String> startDate;
  List<String> endDate;
  List<String> weight;
  List<String> documentURL;
  List<String> documentName;
  List<String> status;
  List<String> numberArabic;

  PolicyFirestore({
    required this.id,
    required this.timeStamp,
    required this.image,
    required this.name,
    required this.nameArabic,
    required this.description,
    required this.descriptionArabic,
    required this.number,
    required this.startDate,
    required this.endDate,
    required this.weight,
    required this.documentURL,
    required this.documentName,
    required this.status,
    required this.numberArabic,
  });

  PolicyFirestore copyWith({
    List<String>? id,
    List<Timestamp>? timeStamp,
    List<String>? image,
    List<String>? name,
    List<String>? nameArabic,
    List<String>? description,
    List<String>? descriptionArabic,
    List<String>? number,
    List<String>? startDate,
    List<String>? endDate,
    List<String>? weight,
    List<String>? documentURL,
    List<String>? documentName,
    List<String>? status,
    List<String>? numberArabic,
  }) {
    return PolicyFirestore(
      id: id ?? this.id,
      timeStamp: timeStamp ?? this.timeStamp,
      image: image ?? this.image,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      description: description ?? this.description,
      descriptionArabic: descriptionArabic ?? this.descriptionArabic,
      number: number ?? this.number,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      weight: weight ?? this.weight,
      documentURL: documentURL ?? this.documentURL,
      documentName: documentName ?? this.documentName,
      status: status ?? this.status,
      numberArabic: numberArabic ?? this.numberArabic,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'timeStamp': timeStamp.map((x) => x).toList(),
      'image': image,
      'name': name,
      'nameArabic': nameArabic,
      'description': description,
      'descriptionArabic': descriptionArabic,
      'number': number,
      'startDate': startDate,
      'endDate': endDate,
      'weight': weight,
      'documentURL': documentURL,
      'documentName': documentName,
      'status': status,
      'numberArabic': numberArabic,
    };
  }

  factory PolicyFirestore.fromMap(Map<String, dynamic> map) {
    return PolicyFirestore(
      id: (map['id'] as List<dynamic>).map((e) => e as String).toList(),
      timeStamp: (map['timeStamp'] as List<dynamic>)
          .map((e) => e as Timestamp)
          .toList(),
      image: (map['image'] as List<dynamic>).map((e) => e as String).toList(),
      name: (map['name'] as List<dynamic>).map((e) => e as String).toList(),
      nameArabic:
          (map['nameArabic'] as List<dynamic>).map((e) => e as String).toList(),
      description: (map['description'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      descriptionArabic: (map['descriptionArabic'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      number: (map['number'] as List<dynamic>).map((e) => e as String).toList(),
      startDate:
          (map['startDate'] as List<dynamic>).map((e) => e as String).toList(),
      endDate:
          (map['endDate'] as List<dynamic>).map((e) => e as String).toList(),
      weight: (map['weight'] as List<dynamic>).map((e) => e as String).toList(),
      documentURL: (map['documentURL'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      documentName: (map['documentName'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: (map['status'] as List<dynamic>).map((e) => e as String).toList(),
      numberArabic: (map['numberArabic'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory PolicyFirestore.fromJson(String source) =>
      PolicyFirestore.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Policy(id: $id, timeStamp: $timeStamp, image: $image,name: $name, nameArabic: $nameArabic, description: $description, descriptionArabic: $descriptionArabic, number: $number,startDate: $startDate,endDate: $endDate,weight: $weight,documentURL: $documentURL,documentName: $documentName,status: $status,numberArabic: $numberArabic)';
  }

  @override
  bool operator ==(covariant PolicyFirestore other) {
    if (identical(this, other)) return true;

    return listEquals(other.id, id) &&
        listEquals(other.timeStamp, timeStamp) &&
        listEquals(other.image, image) &&
        listEquals(other.name, name) &&
        listEquals(other.nameArabic, nameArabic) &&
        listEquals(other.description, description) &&
        listEquals(other.descriptionArabic, descriptionArabic) &&
        listEquals(other.number, number) &&
        listEquals(other.startDate, startDate) &&
        listEquals(other.endDate, endDate) &&
        listEquals(other.weight, weight) &&
        listEquals(other.documentURL, documentURL) &&
        listEquals(other.documentName, documentName) &&
        listEquals(other.status, status) &&
        listEquals(other.numberArabic, numberArabic);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        timeStamp.hashCode ^
        image.hashCode ^
        name.hashCode ^
        nameArabic.hashCode ^
        description.hashCode ^
        descriptionArabic.hashCode ^
        number.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        weight.hashCode ^
        documentURL.hashCode ^
        documentName.hashCode ^
        status.hashCode ^
        numberArabic.hashCode;
  }
}
