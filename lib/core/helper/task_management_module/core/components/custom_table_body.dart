import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/utils/app_image_provider.dart';

class CustomTableBody extends StatefulWidget {
  final String text;
  final Color? textColor;
  final String? profileImage;

  const CustomTableBody({
    super.key,
    required this.text,
    this.textColor,
    this.profileImage,
  });

  @override
  _CustomTableBodyState createState() => _CustomTableBodyState();
}

class _CustomTableBodyState extends State<CustomTableBody> {
  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    TextStyle tableDataTextStyle = AppFontStyle.cairoRegularStyle.copyWith(
      fontSize: isPortrait
          ? FontConstants.fontSize015.h
          : FontConstants.fontSize022.h,
      fontWeight: FontWeight.w500,
    );

    Color textColor;

    String lowerCaseText = widget.text.toLowerCase();

    if (lowerCaseText == 'open' ||
        lowerCaseText == 'approved' ||
        lowerCaseText == 'done') {
      textColor = AppColors.unBlock;
    } else if (lowerCaseText == 'closed' ||
        lowerCaseText == 'rejected' ||
        lowerCaseText == 'canceled' ||
        lowerCaseText == 'exceeded deadline') {
      textColor = AppColors.delete;
    } else if (lowerCaseText == 'in progress') {
      textColor = AppColors.warning;
    } else if (lowerCaseText == 'not started') {
      textColor = AppColors.secondaryColor;
    } else if (lowerCaseText == 'pending') {
      textColor = AppColors.warning;
    } else if (lowerCaseText.contains('@') && lowerCaseText.contains('.')) {
      textColor = AppColors.blue;
      tableDataTextStyle =
          tableDataTextStyle.copyWith(decoration: TextDecoration.underline);
    } else if (lowerCaseText.contains('.pdf') ||
        lowerCaseText.contains('.docx')) {
      textColor = AppColors.blue;
      tableDataTextStyle =
          tableDataTextStyle.copyWith(decoration: TextDecoration.underline);
    } else {
      textColor = Theme.of(context).colorScheme.inverseSurface;
    }

    return SizedBox(
      width: isPortrait ? 0.2.w : 0.15.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.profileImage != null)
            CircleAvatar(
              radius: isPortrait ? 0.02.w : 0.012.w,
              backgroundColor: Colors.transparent,
              backgroundImage: appImageProvider(widget.profileImage!),
            ),
          if (widget.profileImage != null)
            SizedBox(
              width: 0.01.w,
            ),
          Flexible(
            child: Text(
              widget.text.capitalize!.tr,
              textAlign: TextAlign.center,
              style: tableDataTextStyle.copyWith(
                color: widget.textColor ?? textColor,
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
