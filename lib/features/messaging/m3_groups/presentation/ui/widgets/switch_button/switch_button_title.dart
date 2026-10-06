import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:grc_module/core/custom/58-default_switch_button.dart';

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
