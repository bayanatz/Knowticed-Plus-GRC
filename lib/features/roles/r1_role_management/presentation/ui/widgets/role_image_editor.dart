import 'package:flutter/material.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';

class RoleImageEditor extends StatefulWidget {
  RoleImageEditor({super.key});

  @override
  State<RoleImageEditor> createState() => _RoleImageEditorState();
}

class _RoleImageEditorState extends State<RoleImageEditor> {
  late RoleCubit controller;

  @override
  Widget build(BuildContext context) {
    controller = context.read<RoleCubit>();

    return BlocListener<RoleCubit, RoleState>(
      listener: (context, state) {
        if (state is RoleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (state is RoleImagePicked) {
          setState(() {});
        }
      },
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          CircleAvatar(
            radius: 32.r,
            backgroundColor: AppColors.grey,
            child: controller.roleImage != null
                ? CircleAvatar(
              radius: 32.r,
              backgroundImage:
              FileImage(controller.roleImage!.absolute),
            )
                : controller.selectedRole?.currentRoleImage != null &&
                controller
                    .selectedRole!.currentRoleImage.isNotEmpty
                ? CircleAvatar(
              radius: 32.r,
              backgroundImage: NetworkImage(
                controller.selectedRole!.currentRoleImage,
              ),
              onBackgroundImageError: (_, __) {},
            )
                : Container(
              padding: EdgeInsets.all(8.sp),
              child: CustomSvgImage(assetPath: 
                'assets/icons_assets/roles_assets/roles_people_gear.svg',
                width: 26.sp,
                height: 26.sp,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await controller.pickRoleImage(camera: false);
            },
            child: CircleAvatar(
              radius: 12.r,
              backgroundColor: AppColors.primary,
              child: CustomSvgImage(assetPath: 
                'assets/icons_assets/messaging_assets/camera.svg',
                width: 16.w,
                height: 16.h,
                color: AppColors.textButton,
              ),
            ),
          ),
        ],
      ),
    );
  }
}