/// Module: services / sv7_approvals / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: approval_details_shared_widgets.dart
/// Purpose: Small row widgets shared by the approval pages.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';

class CustomRowDetails extends StatelessWidget {
  const CustomRowDetails({
    super.key,
    required this.image,
    required this.title,
    required this.data,
    this.imagePerson,
  });

  final String image;
  final String title;
  final String data;
  final String? imagePerson;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomSvgImage.natural(
          assetPath: image,
          semanticsLabel: 'Icon',
          width: 20.w,
          height: 20.h,
          color: AppColors.secondaryText.withValues(alpha: .5),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.secondaryText.withValues(alpha: .5),
          ),
        ),
        if (imagePerson != null)
          Row(
            children: [
              ClipOval(
                child: CustomSvgImage.natural(
                  assetPath: imagePerson!,
                  semanticsLabel: 'Icon',
                  width: 32.w,
                  height: 32.h,
                ),
              ),
              SizedBox(width: 5.w),
            ],
          ),
        Text(
          data,
          style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
        ),
      ],
    );
  }
}

extension ApprovalEmployeeCopyWith on ServiceEmployeeModel {
  ServiceEmployeeModel copyWith({
    String? state,
    String? firstNameInArabic,
    String? lastNameInArabic,
    String? titleInArabic,
  }) {
    return ServiceEmployeeModel(
      id: id,
      email: email,
      title: title,
      titleInArabic: titleInArabic ?? this.titleInArabic,
      gender: gender,
      lastName: lastName,
      lastNameInArabic: lastNameInArabic ?? this.lastNameInArabic,
      firstName: firstName,
      firstNameInArabic: firstNameInArabic ?? this.firstNameInArabic,
      state: state ?? this.state,
    );
  }
}
