/// Module: services / sv2_create_single_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: sla_mobile_manager_switches.dart
/// Purpose: The two switches of the provider-manager section on the phone
///          SLA step. Each switch is one stored value (SlaMobileForm) — the
///          old version keyed them by their translated label (Provider
///          rule 5).
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';

import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Class Name: [SlaMobileManagerSwitches]
///
/// Purpose: "When service requested and approved" and "When service status
/// changes".
class SlaMobileManagerSwitches extends StatelessWidget {
  const SlaMobileManagerSwitches({
    required this.whenRequestedAndApproved,
    required this.whenStatusChanges,
    required this.onRequestedAndApproved,
    required this.onStatusChanges,
    super.key,
  });

  final bool whenRequestedAndApproved;
  final bool whenStatusChanges;
  final ValueChanged<bool> onRequestedAndApproved;
  final ValueChanged<bool> onStatusChanges;

  Widget _switch(bool value, ValueChanged<bool> onToggle) => FlutterSwitch(
        activeColor: AppColors.secondaryPrimary,
        height: 22.sp,
        padding: 3.sp,
        width: 38.sp,
        borderRadius: 20.sp,
        toggleSize: 16.sp,
        // QA p.3: a visible grey off track.
        inactiveColor: AppColors.lighterGrey,
        value: value,
        onToggle: onToggle,
      );

  @override
  Widget build(BuildContext context) {
    final label = StyleText.fontSize10Weight400.copyWith(
      color: AppColors.secondaryText,
    );
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 26.sp, top: 15.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FormatHelper.capitalize(
              S.of(context).WhenServiceRequestedAndApproved,
            ),
            style: label,
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(S.of(context).ManagerIfItRequiresApproval, style: label),
              SizedBox(width: 10.sp),
              _switch(whenRequestedAndApproved, onRequestedAndApproved),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Text(
                FormatHelper.capitalize(S.of(context).whenServiceStatusChanges),
                style: label,
              ),
              SizedBox(width: 10.sp),
              _switch(whenStatusChanges, onStatusChanges),
            ],
          ),
        ],
      ),
    );
  }
}
