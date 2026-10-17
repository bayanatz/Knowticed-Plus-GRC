import 'package:flutter/material.dart';
import 'package:grc_module/core/custom/inputs/default_switch_button.dart';

import 'package:grc_module/core/theme/app_theme.dart';

class SwitchButtonTitle extends StatelessWidget {
  const SwitchButtonTitle({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: StyleText.fontSize14Weight500),
          ],
        ),
        Spacer(),
        DefaultSwitchButton(value: value, onChanged: onChanged),
      ],
    );
  }
}
