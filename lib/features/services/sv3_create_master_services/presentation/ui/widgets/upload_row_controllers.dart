/// Module: services / sv3_create_master_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: upload_row_controllers.dart
/// Purpose: Turns parsed upload rows (plain header → value maps from the
///          cubit) into the TextEditingControllers the editable table uses,
///          and back. Rule "No text controllers in models or cubits": the
///          controllers exist only on the widget side.
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:flutter/widgets.dart';

/// Function Name: [toRowControllers]
///
/// Purpose: One controller per cell, for the page to own (and dispose).
List<Map<String, TextEditingController>> toRowControllers(
  List<Map<String, String>> rows,
) =>
    [
      for (final row in rows)
        {
          for (final cell in row.entries)
            cell.key: TextEditingController(text: cell.value),
        },
    ];

/// Function Name: [toRowValues]
///
/// Purpose: The current cell texts, for the cubit.
List<Map<String, String>> toRowValues(
  List<Map<String, TextEditingController>> rows,
) =>
    [
      for (final row in rows)
        {for (final cell in row.entries) cell.key: cell.value.text},
    ];
