/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: row_model.dart
/// Description: `RowModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/data/models/column_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/models/num_of_columns.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/models/status_model.dart';

class RowModel {
  List<ColumnModel> columns;

  RowModel({
    required this.columns,
  });

  RowModel copyWith({
    List<ColumnModel>? columns,
    NumOfColumns? numOfColumns,
    StatusModel? status,
  }) {
    return RowModel(
      columns: columns ?? this.columns,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Columns': columns.map((x) => x.toMap()).toList(),
    };
  }

  factory RowModel.fromMap(Map<String, dynamic> map) {
    return RowModel(
      columns: List<ColumnModel>.from(
        (map['Columns']).map<ColumnModel>(
          (x) => ColumnModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}
