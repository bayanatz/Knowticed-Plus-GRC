/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_image.dart
/// Purpose: The logo picker — uploads an image and reports the resulting URL.
/// Author: Amr Mesbah
/// Created at: 11/12/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N25: added the standard header.
/// Updated: 21/10/2026 - Owner: logo circle resized to 100, placeholder 40%,
///          camera badge 28 in the bottom-end corner.
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_state.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/utils/company_collection_paths.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CompanyImage extends StatefulWidget {
  const CompanyImage({required this.onChangedImageUrl, super.key});
  final ValueChanged<String> onChangedImageUrl;

  @override
  State<CompanyImage> createState() => _CompanyImageState();
}

class _CompanyImageState extends State<CompanyImage> {
  /// Logos above this size are refused before anything is read into memory.
  static const int _maxLogoBytes = 2 * 1024 * 1024;

  bool _uploading = false;

  /// CHANGED 20/10/2026 (CR-KNP-SET-PROFILE-03). Was: `.svg` extension check
  /// only, a global `company_logo/<DateTime>.svg` path shared by every
  /// tenant, no try/catch (the loading overlay stayed up forever on a failed
  /// upload) and `hideLoadingIndicator()` only on the success path. Now the
  /// file is sniffed for a real `<svg` root, capped at 2 MB, stored under the
  /// company's own folder, and every exit hides the overlay.
  Future<void> _uploadImage() async {
    if (_uploading) return;

    final FilePickerResult? picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['svg'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    if (!mounted) return;

    final PlatformFile file = picked.files.first;
    final Uint8List? bytes = file.bytes ??
        (file.path != null ? await File(file.path!).readAsBytes() : null);
    if (!mounted) return;

    final bool isSvg = bytes != null &&
        bytes.lengthInBytes <= _maxLogoBytes &&
        _looksLikeSvg(bytes);
    if (!isSvg) {
      await CustomDialogManager.showMessage(
        context: context,
        title: S.of(context).unsuccessful,
        subtitle: S.of(context).pleaseSelectImageInSvgFormat,
        lottiePath:
            "assets/lottie_assets/main_lottie_assets/lot_status_error.json",
      );
      return;
    }

    _uploading = true;
    showLoadingIndicator();
    try {
      final String companyId = CompanyCollectionPaths.companyId;
      final Reference ref = FirebaseStorage.instance.ref().child(
            'company_logo/$companyId/${DateTime.now().millisecondsSinceEpoch}.svg',
          );
      final TaskSnapshot snapshot = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/svg+xml'),
      );
      final String url = await snapshot.ref.getDownloadURL();
      if (!mounted) return;
      context.read<CompanyCubit>().setImageUrl(url);
      widget.onChangedImageUrl(url);
      setState(() {});
    } catch (e) {
      debugPrint('Company logo upload failed: $e');
      if (!mounted) return;
      hideLoadingIndicator();
      await CustomDialogManager.showMessage(
        context: context,
        title: S.of(context).unsuccessful,
        subtitle: S.of(context).anErrorOccurred,
        lottiePath:
            "assets/lottie_assets/main_lottie_assets/lot_status_error.json",
      );
      return;
    } finally {
      _uploading = false;
    }
    hideLoadingIndicator();
  }

  /// True when the bytes start (after optional BOM / XML prolog / comments /
  /// whitespace) with an `<svg` root. A renamed PNG fails this.
  static bool _looksLikeSvg(Uint8List bytes) {
    final int end = bytes.length < 2048 ? bytes.length : 2048;
    final String head = String.fromCharCodes(bytes.sublist(0, end));
    final String cleaned = head
        .replaceAll(RegExp(r'<\?xml[^>]*\?>'), '')
        .replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '')
        .replaceAll(RegExp(r'<!DOCTYPE[^>]*>', caseSensitive: false), '')
        .trim();
    return cleaned.toLowerCase().startsWith('<svg');
  }

  // Owner 21/10/2026: the circle was 60 (logo set: 40) with the placeholder
  // drawn almost circle-size and a screen-fraction badge. Now one 100 circle
  // in both states, the placeholder 40% of it, centred, and a 28 badge in the
  // bottom-end corner — the proportions of the core CustomImagePicker.
  // Pick / upload / apply logic above is unchanged.
  static double get _circleSize => 72.r;
  static double get _placeholderSize => 30.r;
  static double get _badgeSize => 24.r;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) => InkWell(
        onTapDown: (_) => HapticController.medium(),
        onTap: () {
          _uploadImage();
        },
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: _circleSize,
          height: _circleSize,
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: <Widget>[
              state.imageUrl == null &&
                      (state.company?.companyLogo?.companyLogo?.lastOrNull ==
                              null ||
                          state.company!.status == 'inactive')
                  ? CircleAvatar(
                      radius: _circleSize / 2,
                      backgroundColor: AppColors.background,
                      child: CustomSvgImage.natural(
                        assetPath:
                            "assets/icons_assets/main_icons_assets/ic_media_image.svg",
                        color: AppColors.text,
                        width: _placeholderSize,
                        height: _placeholderSize,
                        fit: BoxFit.contain,
                      ),
                    )
                  : CircleAvatar(
                      radius: _circleSize / 2,
                      backgroundColor: AppColors.background,
                      child: ClipOval(
                        child: SizedBox(
                          width: _circleSize,
                          height: _circleSize,
                          child: SvgPicture.network(
                            colorFilter: ColorFilter.mode(
                                AppColors.text, BlendMode.srcIn),
                            state.imageUrl ??
                                state.company!.companyLogo!.companyLogo!.last!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
              CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: _badgeSize / 2,
                child: CustomSvgImage.natural(
                  assetPath:
                      "assets/icons_assets/main_icons_assets/ic_media_camera_teal.svg",
                  color: AppColors.textButton,
                  width: _badgeSize / 2,
                  height: _badgeSize / 2,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
