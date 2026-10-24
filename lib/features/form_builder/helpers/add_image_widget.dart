/// Module: core/helper/form_builder
///
///*************************** FILE INFO ****************************///
/// File Name: add_image_widget.dart
/// Description: The one round "add image" picker used by the form header
///              (cover) and by groups (group image).
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_image_picker.dart';

/// Round image picker with a camera badge, built on the app's
/// [CustomImagePicker]. It holds no state of its own: the caller passes the
/// current [image] and receives the picked file in [onImagePicked].
class AddImageWidget extends StatelessWidget {
  const AddImageWidget({
    super.key,
    required this.image,
    required this.onImagePicked,
    this.readOnly = false,
  });

  /// The current image: a local file path right after a pick, or an
  /// http(s) URL for a saved image. Null shows the placeholder.
  final String? image;

  /// Called with the file the user picked.
  final ValueChanged<File> onImagePicked;

  /// True hides the camera badge and disables picking.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final String? current = image;
    final bool isRemote = current != null &&
        (current.startsWith('http://') || current.startsWith('https://'));
    return CustomImagePicker(
      // Figma: 65px diameter.
      radius: 32.5.sp,
      badgeRadius: 12.sp,
      readOnly: readOnly,
      imageFile: (current == null || current.isEmpty || isRemote)
          ? null
          : File(current),
      imageUrl: isRemote ? current : null,
      placeholderSvg:
          'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg',
      badgeSvg: AppAssets.camera,
      onImagePicked: onImagePicked,
    );
  }
}
