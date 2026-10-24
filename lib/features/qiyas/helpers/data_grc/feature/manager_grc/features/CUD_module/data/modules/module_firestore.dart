// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/enums/enum.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/CUD_module/domain/entity/module_entity.dart';

class ModuleFirestore {
  List<Timestamp> timeStamp;
  List<String> name;
  List<String> nameArabic;
  List<String> describtion;
  List<String> describtionArabic;
  List<String> owningDepartment;
  List<String> activationDate;
  List<String> imageUrl;
  List<String> status;
  List<String> moduleOwnerId;
  ModuleFirestore({
    required this.timeStamp,
    required this.name,
    required this.nameArabic,
    required this.describtion,
    required this.describtionArabic,
    required this.owningDepartment,
    required this.activationDate,
    required this.imageUrl,
    required this.status,
    required this.moduleOwnerId,
  });

  ModuleFirestore copyWith({
    List<Timestamp>? timeStamp,
    List<String>? name,
    List<String>? nameArabic,
    List<String>? describtion,
    List<String>? describtionArabic,
    List<String>? owningDepartment,
    List<String>? activationDate,
    List<String>? imageUrl,
    List<String>? status,
    List<String>? moduleOwnerId,
  }) {
    return ModuleFirestore(
      timeStamp: timeStamp ?? this.timeStamp,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      describtion: describtion ?? this.describtion,
      describtionArabic: describtionArabic ?? this.describtionArabic,
      owningDepartment: owningDepartment ?? this.owningDepartment,
      activationDate: activationDate ?? this.activationDate,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      moduleOwnerId: moduleOwnerId ?? this.moduleOwnerId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'timeStamp': timeStamp,
      'name': name,
      'nameArabic': nameArabic,
      'describtion': describtion,
      'describtionArabic': describtionArabic,
      'owningDepartment': owningDepartment,
      'activationDate': activationDate,
      'imageUrl': imageUrl,
      'status': status,
      'moduleOwnerId': moduleOwnerId,
    };
  }

  factory ModuleFirestore.fromMap(Map<String, dynamic> map) {
    return ModuleFirestore(
      timeStamp: (map['timeStamp'] as List<dynamic>)
          .map((e) => e as Timestamp)
          .toList(),
      name: (map['name'] as List<dynamic>)
          .map((e) => capitalize(e as String))
          .toList(),
      nameArabic: (map['nameArabic'] as List<dynamic>)
          .map((e) => capitalize(e as String))
          .toList(),
      describtion: (map['describtion'] as List<dynamic>)
          .map((e) => capitalize(e as String))
          .toList(),
      describtionArabic: (map['describtionArabic'] as List<dynamic>)
          .map((e) => capitalize(e as String))
          .toList(),
      owningDepartment: (map['owningDepartment'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      activationDate: (map['activationDate'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      imageUrl:
          (map['imageUrl'] as List<dynamic>).map((e) => e as String).toList(),
      status: (map['status'] as List<dynamic>)
          .map((e) => capitalize(e as String))
          .toList(),
      moduleOwnerId: [],
    );
  }

  String toJson() => json.encode(toMap());

  factory ModuleFirestore.fromJson(String source) =>
      ModuleFirestore.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ModuleEntity(timeStamp: $timeStamp, name: $name, nameArabic: $nameArabic, describtion: $describtion, describtionArabic: $describtionArabic, owningDepartment: $owningDepartment, activationDate: $activationDate, imageUrl: $imageUrl, status: $status)';
  }

  ModuleFirestore editModuleFirestore(ModuleEntity moduleEntity) {
    return ModuleFirestore(
      timeStamp: (timeStamp..add(Timestamp.now())),
      name: (name..add(moduleEntity.name.toLowerCase().trim())),
      nameArabic: (nameArabic
        ..add(moduleEntity.nameArabic.toLowerCase().trim())),
      describtion: (describtion
        ..add(moduleEntity.describtion.toLowerCase().trim())),
      describtionArabic: (describtionArabic
        ..add(moduleEntity.describtionArabic.toLowerCase().trim())),
      activationDate: (activationDate..add(moduleEntity.activationDate)),
      imageUrl: (imageUrl..add(moduleEntity.imageUrl)),
      owningDepartment: (owningDepartment
        ..add(moduleEntity.department.toLowerCase().trim())),
      moduleOwnerId: moduleEntity.moduleOwner,
      status: List.generate(
          status.length, (index) => status[index].toLowerCase().trim()),
    );
  }

  @override
  bool operator ==(covariant ModuleFirestore other) {
    if (identical(this, other)) return true;

    return listEquals(other.timeStamp, timeStamp) &&
        listEquals(other.name, name) &&
        listEquals(other.nameArabic, nameArabic) &&
        listEquals(other.describtion, describtion) &&
        listEquals(other.describtionArabic, describtionArabic) &&
        listEquals(other.owningDepartment, owningDepartment) &&
        listEquals(other.activationDate, activationDate) &&
        listEquals(other.imageUrl, imageUrl) &&
        listEquals(other.status, status);
  }

  @override
  int get hashCode {
    return timeStamp.hashCode ^
        name.hashCode ^
        nameArabic.hashCode ^
        describtion.hashCode ^
        describtionArabic.hashCode ^
        owningDepartment.hashCode ^
        activationDate.hashCode ^
        imageUrl.hashCode ^
        status.hashCode;
  }
}
