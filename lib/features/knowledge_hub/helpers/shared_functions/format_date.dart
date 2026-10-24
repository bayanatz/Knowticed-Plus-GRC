/// Module: knowledge_hub/data/utils/shared_functions
/// ************************* FILE INFO *************************** ///
/// File Name: format_date.dart
/// Description: Format date — knowledge_hub core/widgets.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:intl/intl.dart';

String formatDate(DateTime? date) {
  if (date == null) return '-';
  return DateFormat('dd MMM yyyy').format(date);
}
