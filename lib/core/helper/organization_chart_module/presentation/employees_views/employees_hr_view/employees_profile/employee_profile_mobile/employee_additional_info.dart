// ignore_for_file: must_be_immutable, prefer_const_declarations, unused_local_variable, deprecated_member_use, duplicate_ignore, no_leading_underscores_for_local_identifiers, unrelated_type_equality_checks, unrelated_type_equality_checks, sdk_version_since, use_build_context_synchronously

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/organization_chart_module/widgets/custom_appbar_mobile.dart';
import 'package:demo_app/core/helper/settings/presentation/ui/widgets/custom_icon_container.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/settings_header.dart';
import 'package:demo_app/core/local_widgets/dialogs/response_dialog.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/organization_chart_module/requests/request_controller.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/request_to_change_dialog_mobile.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:demo_app/core/custom/33-custom_haptic.dart';

String? section;
String? whatChanged;


class EmployeeAdditionalInfoMobileScreen extends StatefulWidget {
  const EmployeeAdditionalInfoMobileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EmployeeAdditionalInfoMobileScreenState createState() =>
      _EmployeeAdditionalInfoMobileScreenState();
}

String? educationCertificate2;
String? idPhoto2;
String? armyCertificate2;
String? drivingLicense2;
String? maritalCertificate2;
String? insuranceCard2;

class _EmployeeAdditionalInfoMobileScreenState
    extends State<EmployeeAdditionalInfoMobileScreen> {
  int selectedContainerIndex = 0;
  bool isEnglish = Get.locale.toString().contains('en');
  @override
  void initState() {
    educationCertificate2 = null;
    idPhoto2 = null;
    armyCertificate2 = null;
    drivingLicense2 = null;
    maritalCertificate2 = null;
    insuranceCard2 = null;
    section = null;
    whatChanged = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBarMobile(
            showIcon: true,
            showMoreIcon: false,
            title: "Additional Information",
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 0.04.w, vertical: 0.0.w),
                child: Column(
                  children: [
                    Container(
                        child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 0.0.w, vertical: 0.0.h),
                      child: const AdditionalFieldsContacts(),
                    )),
                    SizedBox(
                      height: 0.02.h,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// additional info

class AdditionalFieldsContacts extends StatefulWidget {
  const AdditionalFieldsContacts({super.key});

  @override
  State<AdditionalFieldsContacts> createState() =>
      _AdditionalFieldsContactsState();
}

class _AdditionalFieldsContactsState extends State<AdditionalFieldsContacts> {
  @override
  void initState() {
    super.initState();
  }

  String? educationFileName;
  String? idPhotoFileName;
  String? armyFileName;
  String? driveFileName;
  String? maritalFileName;
  String? insuranceFileName;
  Connectiontype selectedCommunication = Connectiontype.text;
  List<String> imageExtentions = [
    ".PSD",
    ".XCF",
    ".AI",
    ".CDR",
    ".tif",
    ".tiff",
    ".bmp",
    ".jpg",
    ".jpeg",
    ".gif",
    ".png",
    ".eps",
    ".raw",
    ".cr2",
    ".nef",
    ".orf",
    ".sr2"
  ];
  String getFileNameFromPath(String path) {
    List<String> splitedPath = path.split('/');
    String fileName = splitedPath.last;
    return fileName;
  }

  bool isImage(String filePath) {
    bool flag = false;
    for (String imageExtention in imageExtentions) {
      if (filePath.contains(imageExtention)) {
        return true;
      }
    }
    return flag;
  }

  Future<void> pickAndUploadFile(int index, String name) async {
    FilePickerResult? pickedPdf = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (pickedPdf != null) {
      showLoadingIndicator();
      final file = File(pickedPdf.files.single.path!);
      String filePath = pickedPdf.files.single.path!;
      setState(() {
        index == 0
            ? educationFileName = getFileNameFromPath(filePath)
            : index == 1
                ? idPhotoFileName = getFileNameFromPath(filePath)
                : index == 2
                    ? armyFileName = getFileNameFromPath(filePath)
                    : index == 3
                        ? driveFileName = getFileNameFromPath(filePath)
                        : index == 4
                            ? maritalFileName = getFileNameFromPath(filePath)
                            : insuranceFileName = getFileNameFromPath(filePath);
      });

      if (isImage(filePath)) {
        Reference ref = FirebaseStorage.instance.ref().child(
            'employee/$name/${index == 0 ? "education_certificate_photo" : index == 1 ? "id_photo" : index == 2 ? "army_certificate_photo" : index == 3 ? "driving_license_photo" : index == 4 ? "marital_certificate_photo" : "insurance_card_photo"}_${DateTime.now()}.png');
        final metadata = SettableMetadata(contentType: 'image/jpeg');
        final TaskSnapshot task = await ref.putFile(file, metadata);
        index == 0
            ? educationCertificate2 = await task.ref.getDownloadURL()
            : index == 1
                ? idPhoto2 = await task.ref.getDownloadURL()
                : index == 2
                    ? armyCertificate2 = await task.ref.getDownloadURL()
                    : index == 3
                        ? drivingLicense2 = await task.ref.getDownloadURL()
                        : index == 4
                            ? maritalCertificate2 =
                                await task.ref.getDownloadURL()
                            : insuranceCard2 = await task.ref.getDownloadURL();
      } else {
        final Reference storageRef = FirebaseStorage.instance.ref().child(
            'employee/$name/${index == 0 ? "education_certificate_file" : index == 1 ? "id_file" : index == 2 ? "army_certificate_file" : index == 3 ? "driving_license_file" : index == 4 ? "marital_certificate_file" : "insurance_card_file"}_${DateTime.now()}.pdf');
        final metadata = SettableMetadata(contentType: 'application/pdf');
        final TaskSnapshot task = await storageRef.putFile(file, metadata);
        index == 0
            ? educationCertificate2 = await task.ref.getDownloadURL()
            : index == 1
                ? idPhoto2 = await task.ref.getDownloadURL()
                : index == 2
                    ? armyCertificate2 = await task.ref.getDownloadURL()
                    : index == 3
                        ? drivingLicense2 = await task.ref.getDownloadURL()
                        : index == 4
                            ? maritalCertificate2 =
                                await task.ref.getDownloadURL()
                            : insuranceCard2 = await task.ref.getDownloadURL();
      }
      setState(() {});
      hideLoadingIndicator();
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    double height = 0.02.h;
    return /*Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 0.04.w, vertical: 0.01.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 0.02.h, top: 0.01.h),
            child: SettingsHeader(
              imagePath: 'assets/icons_assets/main_icons_assets/newAddInfo.svg',
              text: 'Additional Information'.tr,
            ),
          ),
          Row(
            children: [
              employee!.educationCertificate?.educationCertificate
                          ?.lastOrNull ==
                      null
                  ? Expanded(
                      child: CustomIconContainer(
                        text: 'Education Certificate'.tr,
                        image: 'assets/image/male_avater.png',
                        onPressed: () async {},
                      ),
                    )
                  : Expanded(
                      child: CustomIconContainer(
                        text: 'Education Certificate'.tr,
                        image: isImage(employee!.educationCertificate!
                                .educationCertificate!.lastOrNull!)
                            ? employee!.educationCertificate!
                                .educationCertificate!.lastOrNull!
                            : null,
                        onPressed: () async {
                          var link = Uri.parse(employee!.educationCertificate!
                              .educationCertificate!.lastOrNull!);
                          isImage(employee!.educationCertificate!
                                  .educationCertificate!.lastOrNull!)
                              ? showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return RequestExcalateDialog(
                                      isSetting: true,
                                      title: "",
                                      imageUrl: employee!.educationCertificate!
                                          .educationCertificate!.lastOrNull!,
                                      isExclate: false,
                                      isToShowImage: true,
                                    );
                                  },
                                )
                              : await launchUrl(
                                  link,
                                  mode: LaunchMode.externalApplication,
                                );
                        },
                      ),
                    ),
            ],
          ),
          SizedBox(
            height: height,
          ),
          Row(
            children: [
              employee!.idPhoto?.idPhoto?.lastOrNull == null
                  ? Expanded(
                      child: CustomIconContainer(
                        text: 'ID Photo'.tr,
                        image: 'assets/image/male_avater.png',
                        onPressed: () async {},
                      ),
                    )
                  : Expanded(
                      child: CustomIconContainer(
                        text: 'ID Photo'.tr,
                        image: isImage(employee!.idPhoto!.idPhoto!.lastOrNull!)
                            ? employee!.idPhoto!.idPhoto!.lastOrNull!
                            : null,
                        onPressed: () async {
                          var link = Uri.parse(
                              employee!.idPhoto!.idPhoto!.lastOrNull!);
                          isImage(employee!.idPhoto!.idPhoto!.lastOrNull!)
                              ? showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return RequestExcalateDialog(
                                      isSetting: true,
                                      title: "",
                                      imageUrl: employee!
                                          .idPhoto!.idPhoto!.lastOrNull!,
                                      isExclate: false,
                                      isToShowImage: true,
                                    );
                                  },
                                )
                              : await launchUrl(
                                  link,
                                  mode: LaunchMode.externalApplication,
                                );
                        },
                      ),
                    ),
            ],
          ),
          SizedBox(
            height: height,
          ),
        ],
      ),
    )*/Container();
  }
}
