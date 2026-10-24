/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: form_description_model.dart
/// Description: `FormDescriptionModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'dart:convert';

class FormDescriptionModel {
  List<String?>? description;

  FormDescriptionModel({
    required this.description,
  });

  FormDescriptionModel copyWith({
    List<String?>? description,
  }) {
    return FormDescriptionModel(
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Description': description,
    };
  }

  factory FormDescriptionModel.fromMap(Map<String, dynamic> map) {
    return FormDescriptionModel(
      description: map['Description'] != null
          ? List<String?>.from(
              (map['Description']),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory FormDescriptionModel.fromJson(String source) =>
      FormDescriptionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
