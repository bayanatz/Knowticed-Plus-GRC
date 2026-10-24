/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: sort.dart
/// Purpose: The sort button of the request and approval lists (Date
///          requested / Duration / Last update), built on the shared
///          CustomSortButton. Picking the active option again goes back to
///          the Date requested default.
/// Author: Amr Mesbah
/// Created at: 02/07/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_sort_button.dart';
import 'package:knowticed_plus/features/services/domain/enums/request_sort.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class ServicesSortButton extends StatelessWidget {
  const ServicesSortButton({
    super.key,
    required this.selectedOption,
    required this.onSortSelected,
  });

  /// The order used when nothing else is picked.
  static const RequestSort defaultOption = RequestSort.dateRequested;

  final RequestSort selectedOption;
  final ValueChanged<RequestSort> onSortSelected;

  String _label(S s, RequestSort option) {
    switch (option) {
      case RequestSort.duration:
        return s.duration;
      case RequestSort.lastUpdate:
        return s.lastUpdate;
      case RequestSort.dateRequested:
        return s.dateRequested;
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return CustomSortButton<RequestSort>(
      value: selectedOption,
      items: RequestSort.values,
      labelBuilder: (RequestSort option) => _label(s, option),
      onChanged: (RequestSort? v) {
        if (v == null) return;
        onSortSelected(v == selectedOption ? defaultOption : v);
      },
    );
  }
}
