import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import '../../../controller/message_controller.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

class EditCard extends StatelessWidget {
  final String? content;

  const EditCard({super.key, this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      margin: EdgeInsets.only(bottom: 8.h),
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: 60.h, minHeight: 40.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: ContextExtension(context).isPhone
            ? AppColors.darkGrey.withOpacity(0.1)
            : AppColors.background,
      ),
      child: Text(
        content ?? '',
        style: AppTextStyles.font14BlackCairoRegular
            .copyWith(color: AppColors.text),
      ),
    );
  }
}