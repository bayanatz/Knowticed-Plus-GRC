/// Module: services / sv10_services_provider / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_status_dropdown.dart
/// Purpose: The provider's status menu on the request page ("Status: …").
///          A done request shows its status read-only. Moved out of the page
///          (Provider rule 6).
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services/data/utils/request_status.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Class Name: [RequestStatusDropdown]
///
/// Purpose: Lets the provider pick the next status.
class RequestStatusDropdown extends StatelessWidget {
  const RequestStatusDropdown({
    required this.currentState,
    required this.selectedState,
    required this.options,
    required this.onChanged,
    super.key,
  });

  /// The request's status.
  final String currentState;

  /// The status the provider picked, if any.
  final String? selectedState;

  /// The statuses the menu offers.
  final List<String> options;
  final ValueChanged<String> onChanged;

  String _label(BuildContext context, String state) {
    final s = S.of(context);
    switch (state) {
      case RequestStatus.inProgress:
        return s.sm_inprogress;
      case RequestStatus.done:
        return s.sm_done;
      default:
        return s.status_approved;
    }
  }

  Color _color(String state) {
    switch (state) {
      case RequestStatus.inProgress:
        return AppColors.orange;
      case RequestStatus.approved:
      case RequestStatus.done:
        return AppColors.lightGreen;
      default:
        return AppColors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final unique = options.toSet().toList();
    final safeSelected = unique.contains(selectedState) ? selectedState : null;
    final effective = (safeSelected ?? currentState).toLowerCase();

    final Widget field;
    if (effective == RequestStatus.done) {
      field = Container(
        alignment: AlignmentDirectional.centerStart,
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        child: Text(
          _label(context, RequestStatus.done),
          overflow: TextOverflow.ellipsis,
          style: StyleText.fontSize12Weight400.copyWith(
            color: _color(RequestStatus.done),
          ),
        ),
      );
    } else {
      field = DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          value: safeSelected,
          isExpanded: true,
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(color: AppColors.card),
            elevation: 2,
            offset: Offset.zero,
          ),
          items: unique
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    _label(context, e),
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: _color(e),
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
          hint: Padding(
            padding: rtl ? EdgeInsets.only(top: 4.sp) : EdgeInsets.zero,
            child: Text(
              _label(
                context,
                effective.isEmpty ? RequestStatus.approved : effective,
              ),
              style: StyleText.fontSize10Weight400.copyWith(
                color: currentState == RequestStatus.inProgress
                    ? AppColors.orange
                    : AppColors.green,
              ),
            ),
          ),
          iconStyleData: IconStyleData(
            icon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.sp),
              child: CustomSvgImage.natural(
                assetPath:
                    'assets/icons_assets/main_icons_assets/ic_nav_chevron_down.svg',
                width: 20.sp,
                height: 20.sp,
                fit: BoxFit.fill,
                color:
                    lightMode ? AppColors.secondaryText : AppColors.whiteShadow,
              ),
            ),
          ),
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.blackButton,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomSvgImage.natural(
          assetPath: 'assets/icons_assets/main_icons_assets/ic_status.svg',
          width: 12.sp,
          height: 12.sp,
          color: AppColors.blackButton,
          fit: BoxFit.fill,
        ),
        SizedBox(width: 5.sp),
        Text(
          '${S.of(context).status}: ',
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.blackButton,
          ),
        ),
        SizedBox(width: 4.sp),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            width: 135.sp,
            height: 30.sp,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: effective == RequestStatus.done
                ? IgnorePointer(child: field)
                : field,
          ),
        ),
      ],
    );
  }
}
