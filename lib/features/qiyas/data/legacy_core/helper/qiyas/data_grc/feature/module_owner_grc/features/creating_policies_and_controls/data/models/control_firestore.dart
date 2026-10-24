// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ControlFirestore {
  List<String> id;
  List<Timestamp> timeStamp;
  List<String> name;
  List<String> nameArabic;
  List<String> description;
  List<String> descriptionArabic;
  List<String> number;
  List<String> weight;
  List<String> frequencyWeight;
  List<String> documentURL;
  List<String> documentName;
  List<String> status;
  List<String> policyStatus;

  ControlFirestore({
    required this.id,
    required this.timeStamp,
    required this.name,
    required this.nameArabic,
    required this.description,
    required this.descriptionArabic,
    required this.number,
    required this.weight,
    required this.frequencyWeight,
    required this.documentURL,
    required this.documentName,
    required this.status,
    required this.policyStatus,
  });

  ControlFirestore copyWith({
    List<String>? id,
    List<Timestamp>? timeStamp,
    List<String>? name,
    List<String>? nameArabic,
    List<String>? description,
    List<String>? descriptionArabic,
    List<String>? number,
    List<String>? weight,
    List<String>? frequencyWeight,
    List<String>? documentURL,
    List<String>? documentName,
    List<String>? status,
    List<String>? policyStatus,
  }) {
    return ControlFirestore(
      id: id ?? this.id,
      timeStamp: timeStamp ?? this.timeStamp,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      description: description ?? this.description,
      descriptionArabic: descriptionArabic ?? this.descriptionArabic,
      number: number ?? this.number,
      weight: weight ?? this.weight,
      frequencyWeight: frequencyWeight ?? this.frequencyWeight,
      documentURL: documentURL ?? this.documentURL,
      documentName: documentName ?? this.documentName,
      status: status ?? this.status,
      policyStatus: policyStatus ?? this.policyStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'timeStamp': timeStamp.map((x) => x).toList(),
      'name': name,
      'nameArabic': nameArabic,
      'description': description,
      'descriptionArabic': descriptionArabic,
      'number': number,
      'weight': weight,
      'frequencyWeight': frequencyWeight,
      'documentURL': documentURL,
      'documentName': documentName,
      'status': status,
      'policyStatus': policyStatus
    };
  }

  factory ControlFirestore.fromMap(Map<String, dynamic> map) {
    return ControlFirestore(
      id: (map['id'] as List<dynamic>).map((e) => e as String).toList(),
      timeStamp: (map['timeStamp'] as List<dynamic>)
          .map((e) => e as Timestamp)
          .toList(),
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
      weight: (map['weight'] as List<dynamic>).map((e) => e as String).toList(),
      frequencyWeight: (map['frequencyWeight'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      documentURL: (map['documentURL'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      documentName: (map['documentName'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: (map['status'] as List<dynamic>).map((e) => e as String).toList(),
      policyStatus: (map['policyStatus'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ControlFirestore.fromJson(String source) =>
      ControlFirestore.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Control(id: $id, timeStamp: $timeStamp, name: $name, nameArabic: $nameArabic, description: $description, descriptionArabic: $descriptionArabic, number: $number,weight: $weight, frequencyWeight: $frequencyWeight,documentURL: $documentURL,documentName: $documentName,status: $status,policyStatus: $policyStatus)';
  }

  @override
  bool operator ==(covariant ControlFirestore other) {
    if (identical(this, other)) return true;

    return listEquals(other.id, id) &&
        listEquals(other.timeStamp, timeStamp) &&
        listEquals(other.name, name) &&
        listEquals(other.nameArabic, nameArabic) &&
        listEquals(other.description, description) &&
        listEquals(other.descriptionArabic, descriptionArabic) &&
        listEquals(other.number, number) &&
        listEquals(other.weight, weight) &&
        listEquals(other.frequencyWeight, frequencyWeight) &&
        listEquals(other.documentURL, documentURL) &&
        listEquals(other.documentName, documentName) &&
        listEquals(other.status, status) &&
        listEquals(other.policyStatus, policyStatus);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        timeStamp.hashCode ^
        name.hashCode ^
        nameArabic.hashCode ^
        description.hashCode ^
        descriptionArabic.hashCode ^
        number.hashCode ^
        weight.hashCode ^
        frequencyWeight.hashCode ^
        documentURL.hashCode ^
        documentName.hashCode ^
        status.hashCode ^
        policyStatus.hashCode;
  }
}
