/// Module: Core · Custom · Image Picker
/// Description: Reusable circular avatar with a built-in image picker badge.
///              Extracted from role_image_editor.dart but decoupled from
///              RoleCubit so it can be used anywhere. Shows (in priority
///              order): externally provided File, internally picked File,
///              network image URL, or a placeholder svg. The small primary
///              camera badge opens the gallery/camera, validates the picked
///              image (format + decodability) and reports it via callback.
/// Author: Knowticed Team
/// Date: 06/07/2026
/// Dependencies: image_picker, flutter_svg, flutter_screenutil,
///               SkeletonAssets, AppColors.
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import 'package:demo_app/core/constants/skeleton_assets.dart';
import 'package:demo_app/core/theme/app_colors.dart';

class CustomImagePicker extends StatefulWidget {
  /// Externally controlled picked file (takes priority over internal state).
  final File? imageFile;

  /// Fallback network image shown when no file is picked.
  final String? imageUrl;

  /// Called with the validated picked file.
  final ValueChanged<File> onImagePicked;

  /// Called with an error message; if null a red SnackBar is shown.
  final ValueChanged<String>? onError;

  /// Pick from camera instead of gallery.
  final bool camera;

  /// Avatar radius (defaults to 32.r).
  final double? radius;

  /// Badge radius (defaults to 12.r).
  final double? badgeRadius;

  final String placeholderSvg;
  final String badgeSvg;

  const CustomImagePicker({
    super.key,
    required this.onImagePicked,
    this.imageFile,
    this.imageUrl,
    this.onError,
    this.camera = false,
    this.radius,
    this.badgeRadius,
    this.placeholderSvg = SkeletonAssets.imageAvatar,
    this.badgeSvg = SkeletonAssets.cameraIcon,
  });

  @override
  State<CustomImagePicker> createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  static const List<String> _validFormats = [
    'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic',
  ];

  File? _pickedFile;

  File? get _effectiveFile => widget.imageFile ?? _pickedFile;

  Future<void> _pick() async {
    try {
      final ImagePicker picker = ImagePicker();

      final result = await picker.pickImage(
        source: widget.camera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (result == null) return;

      // Validate image format.
      final extension = result.path.split('.').last.toLowerCase();
      if (!_validFormats.contains(extension)) {
        _fail('Invalid format. Please use JPG, PNG, or WEBP');
        return;
      }

      final file = File(result.path);
      if (!await file.exists()) {
        _fail('Image file not found');
        return;
      }

      // Try to decode image to verify it's valid.
      try {
        final bytes = await result.readAsBytes();
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frameInfo = await codec.getNextFrame();
        frameInfo.image.dispose();
        codec.dispose();
      } catch (_) {
        _fail('Invalid or corrupted image file');
        return;
      }

      setState(() => _pickedFile = file);
      widget.onImagePicked(file);
    } catch (_) {
      _fail('Failed to pick image');
    }
  }

  void _fail(String message) {
    if (widget.onError != null) {
      widget.onError!(message);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double radius = widget.radius ?? 32.r;
    final double badgeRadius = widget.badgeRadius ?? 12.r;
    final file = _effectiveFile;

    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.grey,
          child: file != null
              ? CircleAvatar(
                  radius: radius,
                  backgroundImage: FileImage(file.absolute),
                )
              : widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                  ? CircleAvatar(
                      radius: radius,
                      backgroundImage: NetworkImage(widget.imageUrl!),
                      onBackgroundImageError: (_, __) {},
                    )
                  : Container(
                      padding: EdgeInsets.all(8.sp),
                      child: SvgPicture.asset(
                        widget.placeholderSvg,
                        width: 30.sp,
                        height: 30.sp,
                      ),
                    ),
        ),
        GestureDetector(
          onTap: _pick,
          child: CircleAvatar(
            radius: badgeRadius,
            backgroundColor: AppColors.primary,
            child: SvgPicture.asset(
              widget.badgeSvg,
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
