// Date Created :22/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :22/November/2023
// Objectives: this is a widget to customize circle of the people will be in the meeting on meeting screen
import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';

import 'package:demo_app/core/theme/app_font_size.dart';

class ProfilesCircles extends StatelessWidget {
  const ProfilesCircles({
    super.key,
    required this.imageUrl,
  });
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.03.h,
      height: 0.03.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lightPrimary,
      ),
      child: Center(
        child: CircleAvatar(
          radius: 0.03.h,
          backgroundImage: AssetImage(imageUrl),
        ),
      ),
    );
  }
}
