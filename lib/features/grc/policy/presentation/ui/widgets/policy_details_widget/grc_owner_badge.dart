/// Module: GRC Module Management
/// Description: Compact "Module Owner" badge that shows ONLY the first
///              assigned owner (avatar + name) alongside a "Message"
///              action button. Use this next to GrcOwnerSection when a
///              single-line summary is needed instead of the full grid.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-18
/// Dependencies: GrcOwnerCubit
/// Revision History: 2026-07-18 - Initial creation
library;

import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// class name: [GrcOwnerBadge]
///
/// purpose: shows only the first owner assigned to a GRC Module as a
///          small badge: "Module Owner:" label + avatar + name, plus a
///          "Message" pill button. This is a separate widget from
///          [GrcOwnerSection] (which is left untouched) and is meant for
///          compact places (module header / list row) where the full
///          owner grid is not needed.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 18/7/2026
class GrcOwnerBadge extends StatefulWidget {
  /// Emails of owners already assigned to the module. Only the first
  /// matched owner is displayed.
  final List<String> ownerEmails;

  /// Called with the displayed owner when the "Message" button is tapped.
  final void Function(OwnerData owner)? onMessageTap;

  const GrcOwnerBadge({
    super.key,
    this.ownerEmails = const [],
    this.onMessageTap,
  });

  @override
  State<GrcOwnerBadge> createState() => _GrcOwnerBadgeState();
}

class _GrcOwnerBadgeState extends State<GrcOwnerBadge> {
  late final GrcOwnerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GrcOwnerCubit();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _cubit.loadOwners(
        context,
        initialOwnerEmails: widget.ownerEmails,
      ),
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<GrcOwnerCubit, GrcOwnerState>(
        builder: (context, state) {
          // Only the selected/assigned owners matter here, we just take
          // the first one.
          final owners =
              _cubit.filteredOwners.where((o) => o.isSelected).toList();

          if (owners.isEmpty) return const SizedBox.shrink();

          final owner = owners.first;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Module Owner:'.tr,
                style: AppTextStyles.font16BlackRegularCairo.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(width: 8.w),
              CircleAvatar(
                radius: 16.r,
                child: Image.network(owner.photo,
                    errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.person, size: 16.sp);
                }),
              ),
              SizedBox(width: 8.w),
              Text(
                owner.name,
                style: AppTextStyles.font16BlackRegularCairo.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 16.w),
              _MessageButton(
                onTap: () => widget.onMessageTap?.call(owner),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// class name: [_MessageButton]
///
/// purpose: pill-shaped yellow button with a chat-bubble icon + "Message"
///          label, matching the action button shown next to the owner
///          badge in the design.
class _MessageButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _MessageButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return customButtonWithSvg(
      colorBorder: AppColors.primary,
      space: 10.w,
      radius: 8.r,
      widthImage: 16.w,
      heightImage: 16.h,
      image: "assets/icons_assets/data_grc_assets/messages_new.svg",
      title: "Message".tr,
      function: onTap!,
      width: 40.w,
      color: AppColors.primary,
      textStyle:
          StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
    );
  }
}
