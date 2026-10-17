import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:grc_module/core/extensions/screen_fraction_extension.dart';

// ignore: must_be_immutable
class CustomPhotoContainer extends StatelessWidget {
  CustomPhotoContainer(
      {super.key,
      required this.imageUrl,
      required this.borderColor,
      required this.backColor,
      required this.photoColor});
  final String imageUrl;
  Color borderColor;
  Color? photoColor;
  Color backColor;

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
          color: backColor),
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: 0.01.h, horizontal: isPortrait ? 0.02.w : 0.012.w),
        child: Center(
          child: CustomSvgImage.natural(
            assetPath: imageUrl,
            // ignore: deprecated_member_use
            color: photoColor,
          ),
        ),
      ),
    );
  }
}
