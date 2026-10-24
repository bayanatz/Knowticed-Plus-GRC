/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: default_switch_button.dart
/// Description: Declares `DefaultSwitchButton`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class DefaultSwitchButton extends StatelessWidget {
  const DefaultSwitchButton({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Transform(
      alignment: Alignment.center,
      transform: isArabic ? Matrix4.rotationY(3.14159) : Matrix4.identity(),
      child: FlutterSwitch(
        width: 38.sp,
        height: 22.sp,
        padding: 3.sp,
        borderRadius: 20.sp,
        toggleSize: 16.sp,
        activeColor: AppColors.secondaryPrimary,
        inactiveColor: Colors.grey.withValues(alpha: .16),
        value: value,
        onToggle: (v) {
          HapticController.low();
          onChanged(v);
        },
      ),
    );
  }
}
