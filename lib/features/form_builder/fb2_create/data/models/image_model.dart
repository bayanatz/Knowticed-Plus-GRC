/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: image_model.dart
/// Description: `ImageModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageModel {
  List<String?>? image;

  ImageModel({
    this.image,
  });

  ImageModel copyWith({
    List<String?>? image,
    List<Timestamp?>? timestamps,
  }) {
    return ImageModel(
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Image': image,
    };
  }

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      image: map['Image'] != null
          ? List<String?>.from(
              (map['Image']),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ImageModel.fromJson(String source) =>
      ImageModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
