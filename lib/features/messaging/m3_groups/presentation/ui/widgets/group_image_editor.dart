/// Module: messaging / groups / presentation/ui/widgets/group_image_editor.dart
/// ************************* FILE INFO *************************** ///
/// File Name: group_image_editor.dart
/// Purpose: Group image editor — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:io';
import 'package:grc_module/core/services/media_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:grc_module/core/constants/message_module/app_assets.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import '../../controller/groups_controller.dart';

class GroupImageEditor extends StatefulWidget {
  const GroupImageEditor({super.key});

  @override
  State<GroupImageEditor> createState() => _GroupImageEditorState();
}

class _GroupImageEditorState extends State<GroupImageEditor> {
  @override
  Widget build(BuildContext context) {
    final controller = context.read<GroupsCubit>();

    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        CircleAvatar(
          radius: 32.r,
          backgroundColor: AppColors.grey,
          child: ClipOval(
            child: SizedBox(
              width: 64.r,
              height: 64.r,
              child: controller.groupImage != null
                  ? Image.file(
                controller.groupImage!.absolute,
                fit: BoxFit.cover,
                width: 64.r,
                height: 64.r,
              )
                  : controller.selectedGroup?.groupImage != null &&
                  !controller.isCreateGroup
                  ? Image.network(
                controller.selectedGroup!.groupImage!,
                fit: BoxFit.cover,
                width: 64.r,
                height: 64.r,
              )
                  : Container(
                padding: EdgeInsets.all(8.r),
                child: Image.asset(AppAssets.blackGallery),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            final picked =
                await MediaPickerService().pickImage(fromCamera: false);
            if (picked?.path != null) {
              controller.setGroupImage(File(picked!.path!));
            }
            setState(() {});
          },
          child: CircleAvatar(
            radius: 12.r,
            backgroundColor: AppColors.primary,
            child: SvgPicture.asset(
              AppAssets.camera,
              width: 16.w,
              height: 16.h,
              color: AppColors.textButton,
            ),
          ),
        ),
      ],
    );
  }
}