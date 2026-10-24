import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/comment_section/presentation/controller/qiyas_comment_cubit.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CommentTextField extends StatelessWidget {
  CommentTextField({super.key});
  final QiyasCommentCubit controller = sl();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            height: 38,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) {
              if (Platform.isMacOS || Platform.isWindows) {
                controller.addComment();
              }
            },
            hint: 'اكتب تعليقا',
            maxLines: 1,

            prefixIcon: InkWell(
              onTapDown: (_) => HapticController.low(),
              onTap: () {
                controller.selectFile();
              },
              child: SvgPicture.asset(
                'assets/icons_assets/qiyas_assets/ic_file_attachment.svg',
                fit: BoxFit.contain,
                colorFilter:
                    ColorFilter.mode(AppColors.secondaryText, BlendMode.srcIn),
              ),
            ),

            hintStyle: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryText)
                .copyWith(color: AppColors.greyIcon),
            //style: style ?? StyleText.fontSize12Weight400,
            fillColor: AppColors.card,
            controller: controller.commentController,

            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.sp,
              vertical: 7.sp,
            ),
          ),
        ),
        SizedBox(width: 10.sp),
        InkWell(
          onTapDown: (_) => HapticController.medium(),
          onTap: () {
            debugPrint("Adding comment: ${controller.commentController.text}");
            controller.addComment();
          },
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: Container(
            height: 38.sp,
            width: 38.sp,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: Transform.rotate(
              angle: -3.14 / 2,
              child: SvgPicture.asset(
                'assets/icons_assets/qiyas_assets/ic_comms_comment.svg',
                width: 20.sp,
                height: 20.sp,
                colorFilter:
                    ColorFilter.mode(AppColors.textButton, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
