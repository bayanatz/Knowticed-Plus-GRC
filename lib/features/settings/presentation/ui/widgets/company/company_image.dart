import 'dart:io';
import 'package:demo_app/core/theme/app_colors.dart';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/settings/core_widgets/dialogs/response_dialog.dart';
import 'package:demo_app/features/settings/presentation/controller/add_company_controller.dart';
import 'package:demo_app/generated/l10n.dart';

import 'package:demo_app/core/custom/loading.dart';

class CompanyImage extends StatefulWidget {
   CompanyImage({required this.onChangedImageUrl,super.key});
   final ValueChanged<String> onChangedImageUrl;

  @override
  State<CompanyImage> createState() => _CompanyImageState();
}

class _CompanyImageState extends State<CompanyImage> {
  final ImagePicker picker = ImagePicker();
  CompanyController companyController = Get.find();

  File? _image;

  Future<void> _uploadImage() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles();

    if (pickedFile != null) {
      if (pickedFile.paths[0]!.toLowerCase().endsWith('.svg')) {
        showLoadingIndicator();
        _image = File(pickedFile.paths[0]!);
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('/company_logo/${DateTime.now()}.svg');
        final metadata = SettableMetadata(contentType: 'image/svg+xml');
        UploadTask uploadTask = ref.putFile(_image!, metadata);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

        companyController.imageUrl = await taskSnapshot.ref.getDownloadURL();
        widget.onChangedImageUrl(companyController.imageUrl!);
        hideLoadingIndicator();
        setState(() {});
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return ResponseDialog(
                title: S.of(context).unsuccessful,
                subtitle: S.of(context).pleaseSelectImageInSvgFormat,
                lottieAsset: "assets/images/error.json",
              );
            });
        print('Please select an SVG file.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return   InkWell(
      onTap: () {
        _uploadImage();
      },
      child: Stack(
        children: <Widget>[
          companyController.imageUrl == null &&
              (companyController.company?.companyLogo
                  ?.companyLogo?.lastOrNull ==
                  null ||
                  companyController.company!.status ==
                      'inactive')
              ? CircleAvatar(
            radius: isTablet
                ? (isVertical ? 0.035.h : 0.03.w)
                : 0.04.h,
            backgroundColor: AppColors.barrierColor,
            child: Center(
              child: Transform.scale(
                  scale: isTablet ? 1.2 : 0.8,
                  child: SvgPicture.asset(
                      "assets/icons_assets/main_icons_assets/pic.svg")),
            ),
          )
              : CircleAvatar(
            radius: isTablet
                ? (isVertical ? 0.035.h : 0.03.w)
                : 0.045.h,
            backgroundColor: AppColors.barrierColor,
            child: ClipOval(
              child: SizedBox(
                width: isTablet
                    ? (isVertical ? 0.07.h : 0.06.w)
                    : 0.09.h,
                height: isTablet
                    ? (isVertical ? 0.07.h : 0.06.w)
                    : 0.09.h,
                child: SvgPicture.network(
                  companyController.imageUrl ??
                      companyController.company!.companyLogo!
                          .companyLogo!.last!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: AlignmentDirectional.bottomEnd,  // Changed from Alignment.bottomRight
              child: Transform.scale(
                scale: isTablet ? 1.5 : 1.4,
                child: CircleAvatar(
                    backgroundColor: AppColors.signOut,
                    radius: isVertical ? 0.01.h : 0.013.h,
                    child: SvgPicture.asset(
                      "assets/icons_assets/main_icons_assets/CameraIcon.svg",
                      color: AppColors.textButton,
                      height: 0.015.h,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
