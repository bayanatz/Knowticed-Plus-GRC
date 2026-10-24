/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: form_title_model.dart
/// Description: `FormTitleModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'dart:convert';

class FormTitleModel {
  List<String?>? title;

  FormTitleModel({
    this.title,
  });

  FormTitleModel copyWith({
    List<String?>? title,
  }) {
    return FormTitleModel(
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Title': title,
    };
  }

  factory FormTitleModel.fromMap(Map<String, dynamic> map) {
    return FormTitleModel(
      title: map['Title'] != null
          ? List<String?>.from(
              (map['Title']),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory FormTitleModel.fromJson(String source) =>
      FormTitleModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
