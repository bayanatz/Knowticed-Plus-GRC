/// Module: knowledge_hub/presentation/ui/widgets
///
///*************************** FILE INFO ****************************///
/// File Name: upload_image_widget.dart
/// Description: `uploadImageWidget()`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

Widget uploadImageWidget({
  required BuildContext context,
  void Function()? pickImage,
  void Function()? removeImage,
  File? selectedImage,
  Uint8List? webImage, // For web support
  String? imageUrl,
  bool isUploadingImage = false,
}) {
  final ImageProvider? image = _imageProvider(
    webImage: webImage,
    selectedImage: selectedImage,
    imageUrl: imageUrl,
  );
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      GestureDetector(
        onTapDown: isUploadingImage ? null : (_) => HapticController.medium(),
        onTap: isUploadingImage ? null : pickImage,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor: AppColors.background,
              backgroundImage: image,
              // Placeholder icon when there is no image yet.
              child: image != null
                  ? null
                  : CustomSvgImage(
                      assetPath: 'assets/icons_assets/main_icons_assets/ic_media_image.svg',
                      height: 35.h,
                      width: 35.w,
                      fit: BoxFit.scaleDown,
                      color: AppColors.secondaryText,
                    ),
            ),
            // The camera badge, or a spinner while the image uploads.
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: _buildImageBadge(isUploadingImage),
            ),
          ],
        ),
      ),
    ],
  );
}

/// The picked image (web bytes or file) or the saved one, if any.
ImageProvider? _imageProvider({
  Uint8List? webImage,
  File? selectedImage,
  String? imageUrl,
}) {
  if (webImage != null) return MemoryImage(webImage);
  if (selectedImage != null) return FileImage(selectedImage);
  if (imageUrl != null && imageUrl.isNotEmpty) return NetworkImage(imageUrl);
  return null;
}

Widget _buildImageBadge(bool isUploading) {
  return Container(
    width: 20.sp,
    height: 20.sp,
    decoration: BoxDecoration(
      color: isUploading ? AppColors.grey : AppColors.primary,
      shape: BoxShape.circle,
    ),
    child: isUploading
        ? SizedBox(
            width: 12.sp,
            height: 12.sp,
            child: CircleProgressMaster.inline(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          )
        : CustomSvgImage.natural(
            assetPath:
                "assets/icons_assets/main_icons_assets/ic_media_camera.svg",
            width: 12.sp,
            height: 12.sp,
            color: AppColors.textButton,
            fit: BoxFit.scaleDown,
          ),
  );
}
