import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:get/get.dart';


import 'package:demo_app/core/theme/app_font_size.dart';

// ignore: must_be_immutable
class IndicatorColumn extends StatefulWidget {
  IndicatorColumn(
      {super.key,
      required this.title,
      required this.value,
      required this.widthStrok,
      required this.currentIndex,
      this.isCreateJob = false});
  final String title;
  double value;
  double widthStrok;
  bool currentIndex;
  final bool isCreateJob;

  @override
  State<IndicatorColumn> createState() => _IndicatorColumnState();
}

class _IndicatorColumnState extends State<IndicatorColumn> {
  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title.tr,
          style: AppFontStyle.cairoRegularStyle.copyWith(
              fontSize: isPortrait
                  ? widget.isCreateJob
                      ? FontConstants.fontSize015.h
                      : FontConstants.fontSize017.h
                  : FontConstants.fontSize016.w,
              fontWeight: widget.currentIndex == true
                  ? FontWeight.w600
                  : FontWeight.w500,
              color: Theme.of(context).colorScheme.inverseSurface),
        ),
        Padding(
          padding: EdgeInsets.only(top: 0.015.h),
          child: SizedBox(
            width: widget.widthStrok,
            child: LinearProgressIndicator(
              value: widget.value,
              minHeight: 0.015.h,
              borderRadius: BorderRadius.circular(64),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.signOut),
              backgroundColor: AppColors.transparent,
            ),
          ),
        )
      ],
    );
  }
}
