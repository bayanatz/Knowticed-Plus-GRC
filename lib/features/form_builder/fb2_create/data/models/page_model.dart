/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: page_model.dart
/// Description: `PageModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/data/models/row_model.dart';

class PageModel {
  List<RowModel> rows;

  PageModel({
    required this.rows,
  });

  PageModel copyWith({
    List<RowModel>? rows,
  }) {
    return PageModel(
      rows: rows ?? this.rows,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Rows': rows.map((x) => x.toMap()).toList(),
    };
  }

  factory PageModel.fromMap(Map<String, dynamic> map) {
    return PageModel(
      rows: List<RowModel>.from((map['Rows'] as List<dynamic>)
          .map<RowModel>((x) => RowModel.fromMap(x as Map<String, dynamic>))),
    );
  }
}
